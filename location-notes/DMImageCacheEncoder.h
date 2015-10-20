//
//  DMImageCacheEncoder.h
//  location-notes
//
//  Created by Darin Minamoto on 10/19/15.
//  Copyright © 2015 com.d_m. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DMKeyValueNode;

@interface DMImageCacheEncoder : NSObject <NSCoding>

- (instancetype)initWithRearNode:(DMKeyValueNode *)rear
                           count:(NSInteger)count;

@property (nonatomic, weak) DMKeyValueNode *rear;
@property (nonatomic) NSInteger count;

@end
