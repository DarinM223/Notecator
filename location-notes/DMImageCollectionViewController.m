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
#import "DMImageDetailViewController.h"
#import "DMImageStore.h"

static NSString * const reuseIdentifier = @"ImageCell";

@interface DMImageCollectionViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) UIPopoverController *imagePickerPopover;

@end

@implementation DMImageCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cell classes
    [self.collectionView registerClass:[DMImageCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *addImageButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addImage:)];
    self.navigationItem.rightBarButtonItem = addImageButton;
    
    [self.imageStore loadImagesWithBlock:^(NSArray *errors) {
        if (errors.count != 0) {
            for (NSError *error in errors) {
                NSLog(@"Image loading error: %@", error.description);
            }
        } else {
            [self.collectionView reloadData];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // If another view controller is popped to this controller, reload
    if (self.isMovingToParentViewController == NO) {
        [self.collectionView reloadData];
    }
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
    return [self.imageStore imageCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DMImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    UIImage *image = [self.imageStore imageForIndex:indexPath.row];
    cell.imageView.image = image;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DMImageDetailViewController *detailController = [[DMImageDetailViewController alloc] initWithImageStore:self.imageStore imageIndex:indexPath.row];
    [self.navigationController pushViewController:detailController animated:YES];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self.imageStore markAddImage:image];
    [self.collectionView reloadData];
}

#pragma mark -
#pragma mark Actions

- (IBAction)addImage:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    imagePicker.delegate = self;
    
    if ([self.imagePickerPopover isPopoverVisible]) {
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
        return;
    }
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        self.imagePickerPopover.delegate = self;
        [self.imagePickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
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
