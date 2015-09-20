//
//  ImageStore.m
//  location-notes
//
//  Created by Darin Minamoto on 9/5/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <Parse/Parse.h>
#import <PromiseKit/PromiseKit.h>
#import "DMImageStore.h"

@interface DMImageStore ()

@property (nonatomic, strong) PFObject *note;
@property (nonatomic, strong) NSMutableDictionary *objectToImage;
@property (nonatomic, strong) NSArray *images;

@property (nonatomic, strong) NSMutableArray *addedImages;
// Dictionary from image objectId to a boolean indicating if the image was removed
@property (nonatomic, strong) NSMutableDictionary *removedImages;

@end

@implementation DMImageStore

- (instancetype)initWithNote:(PFObject *)note {
    self = [super init];
    if (self) {
        self.note = note;
        self.images = [[NSArray alloc] init];
        self.addedImages = [[NSMutableArray alloc] init];
        self.objectToImage = [[NSMutableDictionary alloc] init];
        self.removedImages = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)loadImagesWithBlock:(ImageReturnCallback)block {
    // Don't load anything if note isn't initialized yet
    if (self.note.objectId == nil) {
        block([[NSArray alloc] init]);
        return;
    }
    PFQuery *query = [PFQuery queryWithClassName:@"Image"];
    [query whereKey:@"note" equalTo:self.note];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (!error) {
            self.images = results;
            [self populateImageDictionaryWithBlock:block];
        } else {
            NSLog(@"There was an error loading images: %@", error.description);
        }
    }];
}

- (void)populateImageDictionaryWithBlock:(ImageReturnCallback)block {
    // Creates an array of promises that download the images
    NSMutableArray *imageDownloadPromises = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < self.images.count; i++) {
        // Encapsulate the integer i into a function scope
        void (^wrappedFunction)(long) = ^void(long imageIndex) {
            [imageDownloadPromises addObject:[AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
                PFObject *imageObject = self.images[imageIndex];
                PFFile *imageFile = [imageObject objectForKey:@"image"];
                
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:data];
                        
                        // set image in dictionary
                        [self.objectToImage setObject:image forKey:imageObject.objectId];
                        resolve(image);
                    } else {
                        [self performSelector:@selector(populateImageDictionaryWithBlock:) withObject:block afterDelay:0];
                    }
                }];
            }]];
        };
        wrappedFunction(i);
    }
    
    PMKJoin(imageDownloadPromises).then(^(NSArray *results, NSArray *values, NSArray *errors) {
        block(errors);
    });
}

- (UIImage *)imageFromImageObjectId:(NSString *)objectId {
    return [self.objectToImage objectForKey:objectId];
}

- (NSInteger)imageCount {
    return (self.images.count - self.removedImages.count) + self.addedImages.count;
}

- (PFObject *)imageObjectForIndex:(NSInteger)index {
    // TODO(darin): replace with binary search
    NSInteger localIndex = 0, actualIndex;
    for (actualIndex = 0; actualIndex < self.images.count; actualIndex++) {
        PFObject *imageObject = [self.images objectAtIndex:actualIndex];
        if ([self.removedImages objectForKey:imageObject.objectId] == nil) {
            if (localIndex == index) {
                break;
            }
            localIndex++;
        }
    }
    
    PFObject *foundImageObject = [self.images objectAtIndex:actualIndex];
    return foundImageObject;
}

- (UIImage *)imageForIndex:(NSInteger)index {
    if (index >= (self.images.count - self.removedImages.count)) {
        NSInteger localizedIndex = index - (self.images.count - self.removedImages.count);
        return [self.addedImages objectAtIndex:localizedIndex];
    } else {
        PFObject *foundImageObject = [self imageObjectForIndex:index];
        return [self.objectToImage objectForKey:foundImageObject.objectId];
    }
}

- (void)markAddImage:(UIImage *)image {
    [self.addedImages addObject:image];
}

- (void)markRemoveImage:(NSInteger)index {
    // If image index is for a temporary image
    if (index >= (self.images.count - self.removedImages.count)) {
        // Remove the temporary image from the added images array
        NSInteger localizedIndex = index - (self.images.count - self.removedImages.count);
        [self.addedImages removeObjectAtIndex:localizedIndex];
    } else {
        // Otherwise, mark it as removed by adding to removed images dictionary
        PFObject *imageObject = [self imageObjectForIndex:index];
        [self.removedImages setObject:imageObject forKey:imageObject.objectId];
    }
}

- (void)cancelAllChanges {
    [self.addedImages removeAllObjects];
    [self.removedImages removeAllObjects];
}

- (void)saveChanges:(ImageReturnCallback)block {
    NSMutableArray *imageSavingPromises = [[NSMutableArray alloc] init];
    NSMutableArray *imageRemovingPromises = [[NSMutableArray alloc] init];
    
    // Create a new image object for every image
    for (NSInteger i = 0; i < self.addedImages.count; i++) {
        void (^wrappedFunction)(long) = ^void(long imageIndex) {
            UIImage *image = [self.addedImages objectAtIndex:imageIndex];
            PFObject *newImageObject = [[PFObject alloc] initWithClassName:@"Image"];
            [newImageObject setObject:self.note forKey:@"note"];
            [newImageObject setObject:[PFFile fileWithData:UIImageJPEGRepresentation(image, 0.1)] forKey:@"image"];
            [imageSavingPromises addObject:[AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
                [newImageObject saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
                    if (error != nil) {
                        @throw [NSError errorWithDomain:@"Image saving error" code:1 userInfo:nil];
                    }
                    
                    resolve([NSNumber numberWithBool:success]);
                }];
            }]];
        };
        
        wrappedFunction(i);
    }
    
    // Remove all of the marked images
    for (NSString *objectId in self.removedImages) {
        void (^wrappedFunction)(NSString *) = ^void(NSString *key) {
            PFObject *imageObject = [self.removedImages objectForKey:key];
            [imageRemovingPromises addObject:[AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
                [imageObject deleteInBackgroundWithBlock:^(BOOL success, NSError *error) {
                    if (error != nil) {
                        @throw [NSError errorWithDomain:@"Image removing error" code:2 userInfo:nil];
                    }
                    
                    resolve([NSNumber numberWithBool:success]);
                }];
            }]];
        };
        wrappedFunction(objectId);
    }
    
    NSArray *allPromises = [imageSavingPromises arrayByAddingObjectsFromArray:imageRemovingPromises];
    
    PMKJoin(allPromises).then(^(NSArray *results, NSArray *values, NSArray *errors) {
        if (errors.count == 0) {
            [self.addedImages removeAllObjects];
            [self.removedImages removeAllObjects];
            [self loadImagesWithBlock:block];
        } else {
            block(errors);
        }
    });
}

- (void)applyWithBlock:(ImageReturnCallback)block {
    if (self.note.objectId == nil) {
        // Create object first
        [self.note saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
            if (error != nil) {
                block([NSArray arrayWithObject:error]);
            } else {
                [self saveChanges:block];
            }
        }];
    } else {
        [self saveChanges:block];
    }
}

@end
