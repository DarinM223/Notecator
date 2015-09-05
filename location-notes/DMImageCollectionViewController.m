//
//  DMImageCollectionViewController.m
//  location-notes
//
//  Created by Darin Minamoto on 9/4/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <Parse/Parse.h>
#import <PromiseKit/PromiseKit.h>
#import "DMImageCollectionViewController.h"
#import "DMImageCollectionViewCell.h"

@interface DMImageCollectionViewController ()

@property (nonatomic, strong) NSArray *noteImages;

@end

@implementation DMImageCollectionViewController

static NSString * const reuseIdentifier = @"ImageCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cell classes
    [self.collectionView registerClass:[DMImageCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *addImageButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addImage:)];
    self.navigationItem.rightBarButtonItem = addImageButton;
    
    // Load images from note
    PFQuery *query = [PFQuery queryWithClassName:@"Image"];
    [query whereKey:@"note" equalTo:self.note];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (!error) {
            // Creates an array of promises that download the images
            NSMutableArray *imageDownloadPromises = [[NSMutableArray alloc] init];
            
            for (NSInteger i = 0; i < results.count; i++) {
                // Encapsulate the integer i into a function scope
                void (^wrappedFunction)(long) = ^void(long imageIndex) {
                    [imageDownloadPromises addObject:[PMKPromise promiseWithResolverBlock:^(PMKResolver resolve) {
                        PFObject *imageObject = results[imageIndex];
                        PFFile *imageFile = [imageObject objectForKey:@"image"];
                        
                        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                            if (!error) {
                                UIImage *image = [UIImage imageWithData:data];
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
                    self.noteImages = values;
                    [self.collectionView reloadData];
                } else {
                    for (NSInteger i = 0; i < errors.count; i++) {
                        NSLog(@"Error: %@", [[errors objectAtIndex:i] description]);
                    }
                }
            }).catch(^(NSError *error) {
                NSLog(@"Error: %@", error.description);
            });
        } else {
            UIAlertView *errAlert = [[UIAlertView alloc] initWithTitle:@"Loading Error" message:@"There was an error loading images" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [errAlert show];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.noteImages == nil) {
        return 0;
    }
    return self.noteImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DMImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    UIImage *image = self.noteImages[indexPath.row];
    cell.imageView.image = image;
    return cell;
}

#pragma mark -
#pragma mark Actions

- (IBAction)addImage:(id)sender {
    UIAlertView *imageAlert = [[UIAlertView alloc] initWithTitle:@"Image" message:@"Adding image" delegate:nil cancelButtonTitle:@"Dismiss"otherButtonTitles:nil];
    [imageAlert show];
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
