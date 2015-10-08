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
@property (nonatomic, strong) DMImagePreviewView *previewView;

@end

@implementation DMNoteTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// Need to put the custom view in here because otherwise the width won't be correctly set
- (void)layoutSubviews {
    [super layoutSubviews];
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
    
    DMImageStore *imageStore = [[DMImageStore alloc] initWithNote:note];
    
    [imageStore loadImagesWithBlock:^(NSArray *errors) {
        NSMutableArray *imageArr = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < [imageStore imageCount]; i++) {
            [imageArr addObject:[imageStore imageForIndex:i]];
        }
        
        if (self.previewView != nil) {
            [self.previewView removeFromSuperview];
        }
        self.previewView = [[DMImagePreviewView alloc] initWithFrame:CGRectMake(0, 20, self.contentView.frame.size.width, 55)];
        self.previewView.spacing = 0;
        [self.previewView setImages:imageArr];
        [self addSubview:self.previewView];
    }];
}

@end
