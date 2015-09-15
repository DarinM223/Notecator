//
//  DMSpinner.h
//  location-notes
//
//  Created by Darin Minamoto on 9/15/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIView;
@class UIColor;

@interface DMSpinner : NSObject

- (instancetype)initWithView:(UIView *)view color:(UIColor *)color;

- (void)addSpinner;

- (void)removeSpinner;

@property (nonatomic, weak) UIView *view;
@property (nonatomic, weak) UIColor *color;

@end
