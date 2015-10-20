//
//  DMKeyValueNode.m
//  location-notes
//
//  Created by Darin Minamoto on 10/18/15.
//  Copyright © 2015 com.d_m. All rights reserved.
//

#import "DMKeyValueNode.h"

@implementation DMKeyValueNode

static NSString* const KEY_NAME = @"KeyValueNodeKey";
static NSString* const VALUE_NAME = @"KeyValueNodeValue";
static NSString* const NEXT_NAME = @"KeyValueNodeNext";
static NSString* const PREV_NAME = @"KeyValueNodePrev";

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

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _key = [aDecoder decodeObjectForKey:KEY_NAME];
        _value = [aDecoder decodeObjectForKey:VALUE_NAME];
        _next = [aDecoder decodeObjectForKey:NEXT_NAME];
        _prev = [aDecoder decodeObjectForKey:PREV_NAME];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.key forKey:KEY_NAME];
    [aCoder encodeObject:self.value forKey:VALUE_NAME];
    [aCoder encodeObject:self.next forKey:NEXT_NAME];
    [aCoder encodeObject:self.prev forKey:PREV_NAME];
}

@end
