//
//  DMSpinner.h
//  location-notes
//
//  Created by Darin Minamoto on 9/15/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Encapsulates the common task of creating a spinner when processing some asynchronous task to prevent 
 the user from messing around with the UI during that time
 */

@class UIView;
@class UIColor;

@interface DMSpinner : NSObject

- (instancetype)initWithView:(UIView *)view color:(UIColor *)color;

- (void)addSpinner;

- (void)removeSpinner;

@property (nonatomic, weak) UIView *view;
@property (nonatomic, weak) UIColor *color;

@end
