//
//  DMNote.h
//  location-notes
//
//  Created by Darin Minamoto on 9/7/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class PFObject;
@class PFUser;

@interface DMNote : NSObject <MKAnnotation>

- (instancetype)initWithNote:(PFObject *)note;
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                           andNote:(NSString *)note;

@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy, readonly) NSString *note;

@property (nonatomic, strong, readonly) PFObject *object;
@property (nonatomic, strong, readonly) PFUser *user;

@property (nonatomic, assign) MKPinAnnotationColor pinColor;

@end
