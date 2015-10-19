//
//  DMImagePreviewView.h
//  location-notes
//
//  Created by Darin Minamoto on 10/6/15.
//  Copyright © 2015 com.d_m. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 Custom view that shows some preview images in the table view cell in a line
 Width calculated so that it can resize itself to differently sized devices
 */

@interface DMImagePreviewView : UIView

- (NSInteger)maxNumberOfImages;
- (CGFloat)imageSize;

@property (nonatomic) CGFloat spacing;
@property (nonatomic, setter=setImages:) NSArray *images;

@end
