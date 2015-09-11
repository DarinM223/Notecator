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

@interface DMNoteTableViewCell ()

@property (nonatomic, strong) CLGeocoder *geocoder;

@end

@implementation DMNoteTableViewCell

- (void)awakeFromNib {
    // Initialization code
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

- (void)setImageStore:(DMImageStore *)imageStore {
    
}

@end
