//
//  DMImageDetailViewController.m
//  location-notes
//
//  Created by Darin Minamoto on 9/8/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import "DMImageDetailViewController.h"
#import "DMImageStore.h"

@interface DMImageDetailViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

static const double ANIMATION_DURATION = 0.5;

@implementation DMImageDetailViewController

- (instancetype)initWithImageStore:(DMImageStore *)imageStore imageIndex:(NSInteger)imageIndex {
    self = [super init];
    if (self) {
        self.imageStore = imageStore;
        self.imageIndex = imageIndex;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.imageView.userInteractionEnabled = YES;
    
    // Add swipe recognizers
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightArrowSelected:)];
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftArrowSelected:)];
    
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.imageView addGestureRecognizer:leftSwipeRecognizer];
    [self.imageView addGestureRecognizer:rightSwipeRecognizer];
    
    UIBarButtonItem *deleteImageButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteImage:)];
    self.navigationItem.rightBarButtonItem = deleteImageButton;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIImage *image = [self.imageStore imageForIndex:self.imageIndex];
    self.imageView.image = image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Interface Builder Actions

- (IBAction)leftArrowSelected:(UIGestureRecognizer *)gestureRecognizer {
    if (self.imageIndex - 1 >= 0) {
        self.imageIndex--;
        
        UIImage *image = [self.imageStore imageForIndex:self.imageIndex];
        self.imageView.image = image;
        
        CATransition *animation = [CATransition animation];
        [animation setDuration:ANIMATION_DURATION];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromLeft];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [[self.imageView layer] addAnimation:animation forKey:nil];
    }
}

- (IBAction)rightArrowSelected:(UIGestureRecognizer *)gestureRecognizer {
    if (self.imageIndex + 1 < [self.imageStore imageCount]) {
        self.imageIndex++;
        
        UIImage *image = [self.imageStore imageForIndex:self.imageIndex];
        self.imageView.image = image;
        
        CATransition *animation = [CATransition animation];
        [animation setDuration:ANIMATION_DURATION];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromRight];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [[self.imageView layer] addAnimation:animation forKey:nil];
    }
}

- (IBAction)deleteImage:(id)sender {
    [self.imageStore markRemoveImage:self.imageIndex];
    // Go back if there are no more images
    if ([self.imageStore imageCount] == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if (self.imageIndex >= [self.imageStore imageCount] - 1 && [self.imageStore imageCount] > 1) {
            self.imageIndex--;
        }
        UIImage *image = [self.imageStore imageForIndex:self.imageIndex];
        self.imageView.image = image;
        
        CATransition *animation = [CATransition animation];
        [animation setDuration:ANIMATION_DURATION];
        [animation setType:kCATransitionFade];
        [animation setSubtype:kCATransitionFromRight];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [[self.imageView layer] addAnimation:animation forKey:nil];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
