//
//  DMImageCacheEncoder.m
//  location-notes
//
//  Created by Darin Minamoto on 10/19/15.
//  Copyright © 2015 com.d_m. All rights reserved.
//

#import "DMImageCacheEncoder.h"

@implementation DMImageCacheEncoder

static NSString* const ImageCacheEncoderRearKey = @"ImageCacheEncoderRearKey";
static NSString* const ImageCacheEncoderCountKey = @"ImageCacheEncoderCountKey";

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _rear = [aDecoder decodeObjectForKey:ImageCacheEncoderRearKey];
        _count = [aDecoder decodeIntegerForKey:ImageCacheEncoderCountKey];
    }
    return self;
}

- (instancetype)initWithRearNode:(DMKeyValueNode *)rear
                           count:(NSInteger)count {
    self = [super init];
    if (self) {
        _rear = rear;
        _count = count;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.rear forKey:ImageCacheEncoderRearKey];
    [aCoder encodeInteger:self.count forKey:ImageCacheEncoderCountKey];
}

@end
