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

- (IBAction)leftArrowSelected:(id)sender {
    if (self.imageIndex - 1 >= 0) {
        self.imageIndex--;
        
        UIImage *image = [self.imageStore imageForIndex:self.imageIndex];
        self.imageView.image = image;
    }
}

- (IBAction)rightArrowSelected:(id)sender {
    if (self.imageIndex + 1 < [self.imageStore imageCount]) {
        self.imageIndex++;
        
        UIImage *image = [self.imageStore imageForIndex:self.imageIndex];
        self.imageView.image = image;
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
