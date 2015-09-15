//
//  DMSpinner.m
//  location-notes
//
//  Created by Darin Minamoto on 9/15/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#include <UIKit/UIKit.h>
#import <MMMaterialDesignSpinner/MMMaterialDesignSpinner.h>
#import "DMSpinner.h"

static int const SPINNER_TAG = 9001;

@interface DMSpinner () {
    MMMaterialDesignSpinner *_spinnerView;
}

@end

@implementation DMSpinner

- (instancetype)initWithView:(UIView *)view color:(UIColor *)color {
    self = [super init];
    if (self) {
        self.view = view;
        self.color = color;
    }
    return self;
}

- (void)addSpinner {
    double width = self.view.bounds.size.width / 2, height = width;
    CGRect frame = CGRectMake(self.view.bounds.size.width / 2 - width / 2, self.view.bounds.size.height / 2 - height / 2, width, height);
    
    _spinnerView = [[MMMaterialDesignSpinner alloc] initWithFrame:frame];
    _spinnerView.lineWidth = 1.5f;
    _spinnerView.tintColor = self.color;
    _spinnerView.tag = SPINNER_TAG;
    [self.view addSubview:_spinnerView];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [_spinnerView startAnimating];
}

- (void)removeSpinner {
    if (_spinnerView != nil && [_spinnerView isAnimating]) {
        [_spinnerView stopAnimating];
    }
    
    // Remove spinner
    for (UIView *view in self.view.subviews) {
        if (view.tag == SPINNER_TAG) {
            [view removeFromSuperview];
            break;
        }
    }
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

@end
