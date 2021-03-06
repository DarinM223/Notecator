//
//  DMImageCollectionViewController.h
//  location-notes
//
//  Created by Darin Minamoto on 9/4/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFObject;
@class DMImageStore;

@interface DMImageCollectionViewController : UICollectionViewController

@property (nonatomic, strong) PFObject *note;
@property (nonatomic, strong) DMImageStore *imageStore;

@end
