//
//  DMNoteTableViewCell.m
//  location-notes
//
//  Created by Darin Minamoto on 9/10/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <PromiseKit/PromiseKit.h>
#import "DMNoteTableViewCell.h"
#import "DMImageStore.h"
#import "DMImagePreviewView.h"
#import "DMImageCache.h"

@interface DMNoteTableViewCell ()

@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) DMImagePreviewView *previewView;
@property (nonatomic) NSInteger maxNumberOfImages;

@end

@implementation DMNoteTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.maxNumberOfImages = -1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// Need to put the custom view in here because otherwise the width won't be correctly set
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Set the maximum number of images
    DMImagePreviewView *tempView = [[DMImagePreviewView alloc] initWithFrame:CGRectMake(0, 20, self.contentView.frame.size.width, 55)];
    tempView.spacing = 0;
    self.maxNumberOfImages = [tempView maxNumberOfImages];
}

- (void)setLocation:(CLLocation *)location {
    _location = location;
    
    if (!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    [self.geocoder reverseGeocodeLocation:self.location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            self.locationDescription.text = error.description;
        } else {
            if (placemarks.count > 0) {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                self.locationDescription.text = placemark.country;
            } else {
                self.locationDescription.text = @"No country detected";
            }
        }
        [self setNeedsDisplay];
    }];
}

- (void)setNote:(PFObject *)note {
    if (self.maxNumberOfImages == -1) {
        [self layoutSubviews];
    }
    
    // Only download the images necessary to display the preview view
    PFQuery *query = [PFQuery queryWithClassName:@"Image"];
    [query whereKey:@"note" equalTo:note];
    [query setLimit:self.maxNumberOfImages];
    
    NSMutableArray *images = [[NSMutableArray alloc] init];

    [query findObjectsInBackgroundWithBlock:^(NSArray *imageObjects, NSError *error) {
        if (error) {
            NSLog(@"Error fetching images: %@", error);
            return;
        }
        
        // Create image download promises
        NSMutableArray *imageDownloadPromises = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < imageObjects.count; i++) {
            // Encapsulate the integer i in a function scope
            void (^wrappedFunction)(long) = ^void(long imageIndex) {
                [imageDownloadPromises addObject:[AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
                    PFObject *imageObject = imageObjects[imageIndex];
                    // check cache for image
                    UIImage *cachedImage = [[DMImageCache sharedCache] imageForObjectId:imageObject.objectId];
                    if (cachedImage == nil) {
                        // download manually if not in cache
                        PFFile *imageFile = [imageObject objectForKey:@"image"];
                        
                        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                            if (!error) {
                                UIImage *image = [UIImage imageWithData:data];
                                [images addObject:image];
                                
                                // save image in cache
                                [[DMImageCache sharedCache] setImage:image forObjectId:imageObject.objectId];
                                
                                resolve(nil);
                            } else {
                                resolve(error);
                            }
                        }];
                    } else {
                        [images addObject:cachedImage];
                        resolve(nil);
                    }
                }]];
            };
            wrappedFunction(i);
        }
        
        PMKJoin(imageDownloadPromises).then(^(NSArray *results, NSArray *errors) {
            if (errors.count != 0) {
                NSLog(@"Errors: %@", errors);
                return;
            }
            
            if (self.previewView != nil) {
                [self.previewView removeFromSuperview];
            }
            
            self.previewView = [[DMImagePreviewView alloc] initWithFrame:CGRectMake(0, 20, self.contentView.frame.size.width, 55)];
            self.previewView.spacing = 0;
            [self.previewView setImages:images];
            [self addSubview:self.previewView];
        });
    }];
}

@end
