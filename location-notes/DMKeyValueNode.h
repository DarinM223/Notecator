//
//  DMKeyValueNode.h
//  location-notes
//
//  Created by Darin Minamoto on 10/18/15.
//  Copyright © 2015 com.d_m. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 A key/value node for a doubly-linked-list used for the LRU Cache implementation of DMImageCache
 */

@interface DMKeyValueNode : NSObject <NSCoding>

- (instancetype)initWithKey:(NSString *)key
                   andValue:(NSObject *)value;

@property (nonatomic, copy) NSString *key;
@property (nonatomic, strong) NSObject *value;

@property (nonatomic, weak) DMKeyValueNode *next;
@property (nonatomic, weak) DMKeyValueNode *prev;

@end
