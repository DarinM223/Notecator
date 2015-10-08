//
//  DMImagePreviewView.h
//  location-notes
//
//  Created by Darin Minamoto on 10/6/15.
//  Copyright © 2015 com.d_m. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMImagePreviewView : UIView

@property (nonatomic) CGFloat spacing;
@property (nonatomic, setter=setImages:) NSArray *images;

@end
