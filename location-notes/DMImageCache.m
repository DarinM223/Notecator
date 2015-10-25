//
//  DMImageCache.m
//  location-notes
//
//  Created by Darin Minamoto on 10/18/15.
//  Copyright © 2015 com.d_m. All rights reserved.
//

#import "DMImageCache.h"
#import "DMKeyValueNode.h"
#import "DMImageCacheEncoder.h"

@interface DMImageCache ()

@property (nonatomic) NSInteger count;
@property (nonatomic, strong) NSMutableDictionary *hashMap;
@property (nonatomic, strong) DMKeyValueNode *front;
@property (nonatomic, strong) DMKeyValueNode *rear;

@end

@implementation DMImageCache

static long const maxNumImages = 50;
static NSString* const archiveFile = @"cache.archive";

// Don't use constructor since it is a singleton
- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[DMImageCache sharedCache]" userInfo:nil];
    return nil;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        DMImageCacheEncoder *encoder = [NSKeyedUnarchiver unarchiveObjectWithFile:[self archivePath]];
        if (!encoder) {
            self.hashMap = [[NSMutableDictionary alloc] init];
            self.count = 0;
            self.front = nil;
            self.rear = nil;
        } else {
            self.count = encoder.count;
            self.rear = encoder.rear;
            
            DMKeyValueNode *counter = self.rear;
            while (counter.next != nil) {
                [self.hashMap setValue:counter forKey:counter.key];
                counter = counter.next;
            }
            self.front = counter;
            [self.hashMap setValue:counter forKey:counter.key];
        }
    }
    return self;
}

+ (instancetype)sharedCache {
    static DMImageCache *sharedCache = nil;
    // Thread safe singleton
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[DMImageCache alloc] initPrivate];
    });
    return sharedCache;
}

- (NSString *)archivePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:archiveFile];
}

- (void)saveChanges {
    DMImageCacheEncoder *encoder = [[DMImageCacheEncoder alloc] initWithRearNode:self.rear count:self.count];
    [NSKeyedArchiver archiveRootObject:encoder toFile:[self archivePath]];
}

// Helper function for removing a node from the queue
- (void)removeFromQueue:(DMKeyValueNode *)node {
    if (node.prev != nil) {
        node.prev.next = node.next;
    } else {
        self.rear = node.next;
    }
    
    if (node.next != nil) {
        node.next.prev = node.prev;
    } else {
        self.front = node.prev;
    }
}

// Helper function for adding a node to the front of a queue
- (void)addToFrontOfQueue:(DMKeyValueNode *)node {
    node.next = NULL;
    node.prev = self.front;
    
    if (self.rear == nil) { // Case where node is the only node in the queue
        self.rear = node;
    } else { // Otherwise, just link the "front" to the new front
        self.front.next = node;
    }
    
    // Move the front pointer to the new front node
    self.front = node;
}

- (void)setImage:(UIImage *)image forObjectId:(NSString *)objectId {
    DMKeyValueNode *node = [self.hashMap objectForKey:objectId];
    if (node != nil) {
        [self removeFromQueue:node];
        
        // set the hashmap with the new node and add the new node to the front of the queue
        DMKeyValueNode *newNode = [[DMKeyValueNode alloc] initWithKey:objectId andValue:image];
        [self.hashMap setValue:newNode forKey:objectId];
        [self addToFrontOfQueue:newNode];
    } else {
        if (self.count == maxNumImages) {
            // if full, remove rear key from hash and evict the rear node from the queue
            [self.hashMap setValue:nil forKey:self.rear.key];
            [self removeFromQueue:self.rear];
            self.count--;
        }
        
        // add new node to the front of the queue add set the key-value pair in the hashmap
        DMKeyValueNode *newNode = [[DMKeyValueNode alloc] initWithKey:objectId andValue:image];
        [self addToFrontOfQueue:newNode];
        [self.hashMap setValue:newNode forKey:objectId];
        self.count++;
    }
}

- (UIImage *)imageForObjectId:(NSString *)objectId {
    DMKeyValueNode *node = [self.hashMap objectForKey:objectId];
    
    if (node == nil) {
        return nil;
    }
    
    // move the node with the key to the top of the queue
    if (node != self.front) {
        [self removeFromQueue:node];
        [self addToFrontOfQueue:node];
    }
    
    return (UIImage *)node.value;
}

@end
