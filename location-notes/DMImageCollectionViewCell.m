//
//  DMImageCollectionViewCell.m
//  location-notes
//
//  Created by Darin Minamoto on 9/4/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import "DMImageCollectionViewCell.h"

@implementation DMImageCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.imageView removeFromSuperview];
    self.imageView = nil;
}

@end
