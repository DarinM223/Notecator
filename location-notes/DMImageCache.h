//
//  DMImageCache.h
//  location-notes
//
//  Created by Darin Minamoto on 10/18/15.
//  Copyright © 2015 com.d_m. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
 A lru cache that serializes to disk and stores memory
 */

@interface DMImageCache : NSObject

+ (instancetype)sharedCache;

- (void)setImage:(UIImage *)image
     forObjectId:(NSString *)objectId;

- (UIImage *)imageForObjectId:(NSString *)objectId;

@end
