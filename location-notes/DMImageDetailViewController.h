//
//  DMImageDetailViewController.h
//  location-notes
//
//  Created by Darin Minamoto on 9/8/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DMImageStore;

@interface DMImageDetailViewController : UIViewController

- (instancetype)initWithImageStore:(DMImageStore *)imageStore
                        imageIndex:(NSInteger)imageIndex;

@property (nonatomic, strong) DMImageStore *imageStore;
@property (nonatomic) NSInteger imageIndex;

@end
