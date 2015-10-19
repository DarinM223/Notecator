//
//  DMKeyValueNode.m
//  location-notes
//
//  Created by Darin Minamoto on 10/18/15.
//  Copyright © 2015 com.d_m. All rights reserved.
//

#import "DMKeyValueNode.h"

@implementation DMKeyValueNode

- (instancetype)initWithKey:(NSString *)key andValue:(NSObject *)value {
    self = [super init];
    if (self) {
        self.key = key;
        self.value = value;
        
        self.next = nil;
        self.prev = nil;
    }
    return self;
}

@end
