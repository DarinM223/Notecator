//
//  ImageStore.m
//  location-notes
//
//  Created by Darin Minamoto on 9/5/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <PromiseKit/PromiseKit.h>
#import "ImageStore.h"

@interface ImageStore ()

@property (nonatomic, strong) PFObject *note;
@property (nonatomic, strong) NSMutableDictionary *objectToImage;
@property (nonatomic, strong) NSArray *images;

@property (nonatomic, strong) NSMutableArray *addedImages;
// Dictionary from image objectId to a boolean indicating if the image was removed
@property (nonatomic, strong) NSMutableDictionary *removedImages;

@end

@implementation ImageStore

@synthesize delegate;

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

- (void)loadImages {
    PFQuery *query = [PFQuery queryWithClassName:@"Image"];
    if (self.images.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    }
    [query whereKey:@"note" equalTo:self.note];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (!error) {
            self.images = results;
            [self populateImageDictionary];
        } else {
            NSLog(@"There was an error loading images: %@", error.description);
        }
    }];
}

- (void)populateImageDictionary {
    // Creates an array of promises that download the images
    NSMutableArray *imageDownloadPromises = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < self.images.count; i++) {
        // Encapsulate the integer i into a function scope
        void (^wrappedFunction)(long) = ^void(long imageIndex) {
            [imageDownloadPromises addObject:[PMKPromise promiseWithResolverBlock:^(PMKResolver resolve) {
                PFObject *imageObject = self.images[imageIndex];
                PFFile *imageFile = [imageObject objectForKey:@"image"];
                
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:data];
                        
                        // set image in dictionary
                        [self.objectToImage setObject:image forKey:imageObject.objectId];
                        resolve(image);
                    } else {
                        NSLog(@"Error retrieving image: %@", error.description);
                    }
                }];
            }]];
        };
        wrappedFunction(i);
    }
    
    // Reload image collection cells after downloading images
    PMKJoin(imageDownloadPromises).then(^(NSArray *results, NSArray *values, NSArray *errors) {
        if (errors.count == 0) {
            // call delegate
            [self.delegate imagesFinishedLoading];
        } else {
            for (NSInteger i = 0; i < errors.count; i++) {
                NSLog(@"Error: %@", [[errors objectAtIndex:i] description]);
            }
        }
    }).catch(^(NSError *error) {
        NSLog(@"Error: %@", error.description);
    });
}

- (UIImage *)imageFromImageObjectId:(NSString *)objectId {
    return [self.objectToImage objectForKey:objectId];
}

- (NSInteger)imageCount {
    return (self.images.count - self.removedImages.count) + self.addedImages.count;
}

- (UIImage *)imageForIndex:(NSInteger)index {
    if (index >= (self.images.count - self.removedImages.count)) {
        NSInteger localizedIndex = index - (self.images.count - self.removedImages.count);
        return [self.addedImages objectAtIndex:localizedIndex];
    } else {
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
        return [self.objectToImage objectForKey:foundImageObject.objectId];
    }
}

- (void)markAddImage:(UIImage *)image {
    [self.addedImages addObject:image];
}

- (void)markRemoveImage:(NSInteger)index {
    // TODO(darin): check that image index is an index for a temporary image
    // if it is, just remove it from the addedImages array
    // otherwise, add the image object's objectId to the removedImages dictionary
}

- (void)cancelAllChanges {
    // TODO(darin): clear addedImages array and removedImages dictionary
}

- (void)apply {
    // TODO(darin): for every image in the addedImages, create a new image object
    // look up all removed image keys and delete them from the database
    // reload all images
}

@end
