//
//  ImageStore.h
//  location-notes
//
//  Created by Darin Minamoto on 9/5/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@protocol DMImageStoreDelegate <NSObject>

// Called when all of the images are finished being downloaded
- (void)imagesFinishedLoading:(NSArray *)errors;

// Called whenever local changes are finished being saved to remote
- (void)imagesFinishedSaving:(NSArray *)errors;

@end

@interface DMImageStore : NSObject

// Initialized a new ImageStore based on a parent note
- (instancetype)initWithNote:(PFObject *)note;

// Populates the image store with the note's images by querying Parse API
// should be called after initialization
- (void)loadImages;

// "Adds" a new image but doesn't persist until changes are applied
- (void)markAddImage:(UIImage *)image;

// "Removes" an existing image from it's relative index
- (void)markRemoveImage:(NSInteger)index;

// Returns the total number of local images
- (NSInteger)imageCount;

// Retrieves an image for a specific local index
- (UIImage *)imageForIndex:(NSInteger)index;

// Retrieves a UIImage for a specific PFObject through the objectId
- (UIImage *)imageFromImageObjectId:(NSString *)objectId;

// Applies all local changes to server
- (void)apply;

// Cancels all of the local changes and reverts back to the original ones
- (void)cancelAllChanges;

@property (nonatomic, assign) id<DMImageStoreDelegate> delegate;

@end
