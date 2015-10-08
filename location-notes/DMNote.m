//
//  DMNote.m
//  location-notes
//
//  Created by Darin Minamoto on 9/7/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <Parse/Parse.h>
#import "DMNote.h"

@implementation DMNote

- (instancetype)initWithNote:(PFObject *)note {
    self = [super init];
    if (self) {
        _object = note;
        _note = [note objectForKey:@"note"];
        _user = [note objectForKey:@"user"];
        PFGeoPoint *locationObject = [note objectForKey:@"location"];
        CLLocationCoordinate2D coordinate = [[CLLocation alloc] initWithLatitude:locationObject.latitude longitude:locationObject.longitude].coordinate;
        _coordinate = coordinate;
        self.title = _note;
    }
    return self;
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                           andNote:(NSString *)note {
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _note = note;
        self.title = _note;
    }
    return self;
}

#pragma mark -
#pragma mark Equality method

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[DMNote class]]) {
        return NO;
    }
    
    DMNote *otherNote = (DMNote*)object;
    if (otherNote.object && self.object) {
        return [self.object.objectId isEqualToString:otherNote.object.objectId];
    }
    
    return ([otherNote.note isEqualToString:self.note] &&
            otherNote.coordinate.latitude == self.coordinate.latitude &&
            otherNote.coordinate.longitude == self.coordinate.longitude);
}

#pragma mark -
#pragma mark MKAnnotation methods

- (MKPinAnnotationColor)pinColor {
    return MKPinAnnotationColorRed;
}

@end
