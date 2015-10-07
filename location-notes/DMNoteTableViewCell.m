//
//  DMNoteTableViewCell.m
//  location-notes
//
//  Created by Darin Minamoto on 9/10/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "DMNoteTableViewCell.h"
#import "DMImageStore.h"
#import "DMImagePreviewView.h"

@interface DMNoteTableViewCell ()

@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) DMImageStore *imageStore;
@property (nonatomic, strong) DMImagePreviewView *previewView;

@end

@implementation DMNoteTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.previewView = [[DMImagePreviewView alloc] initWithFrame:CGRectMake(0, 20, self.bounds.size.width, 55)];
    self.previewView.spacing = 0;
    [self addSubview:self.previewView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
    self.imageStore = [[DMImageStore alloc] initWithNote:note];
    [self.imageStore loadImagesWithBlock:^(NSArray *images) {
        NSMutableArray *imageArr = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < [self.imageStore imageCount]; i++) {
            [imageArr addObject:[self.imageStore imageForIndex:i]];
        }
        
        [self.previewView setImages:imageArr];
    }];
}

@end
