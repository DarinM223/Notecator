//
//  DMImagePreviewView.m
//  location-notes
//
//  Created by Darin Minamoto on 10/6/15.
//  Copyright © 2015 com.d_m. All rights reserved.
//

#import "DMImagePreviewView.h"

@interface DMImagePreviewView ()

@end

@implementation DMImagePreviewView

static CGFloat const AROUND_SPACING = 10.0;

- (CGFloat)imageSize {
    return self.bounds.size.height - 2 * AROUND_SPACING;
}

- (NSInteger)maxNumberOfImages {
    CGFloat I = [self imageSize];
    CGFloat result = (self.bounds.size.width - (2 * AROUND_SPACING) - I) / (self.spacing + I) + 1;
    return (NSInteger)floor(result);
}

- (UIImage *)resizeImage:(UIImage *)image imageSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.spacing = 10.0;
    }
    return self;
}

- (void)setImages:(NSArray *)images {
    _images = images;
    
    [self.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    NSLog(@"Max number of images: %ld", [self maxNumberOfImages]);
    
    NSInteger width = AROUND_SPACING;
    CGFloat I = [self imageSize];
    for (NSInteger i = 0; i < [self maxNumberOfImages]; i++) {
        if (i >= _images.count) {
            break;
        }
        
        // Get resized image
        UIImage *image = [images objectAtIndex:i];
        UIImage *resizedImage = [self resizeImage:image imageSize:CGSizeMake(I, I)];
        
        // Set imageview with resized image and set frame
        UIImageView *imageView = [[UIImageView alloc] initWithImage:resizedImage];
        imageView.frame = CGRectMake(width, self.bounds.size.height - AROUND_SPACING, I, I);
        [self addSubview:imageView];
        
        width += (I + self.spacing);
    }
}

//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}


@end
