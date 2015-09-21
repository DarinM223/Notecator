//
//  DMImageDetailViewController.m
//  location-notes
//
//  Created by Darin Minamoto on 9/8/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <MessageUI/MFMailComposeViewController.h>
#import "DMImageDetailViewController.h"
#import "DMImageStore.h"

@interface DMImageDetailViewController () <UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate>

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
    
    // Add touch recognizers
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.delaysTouchesBegan = YES;
    tapRecognizer.delegate = self;
    [self.imageView addGestureRecognizer:tapRecognizer];
    
    // Add swipe recognizers
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightArrowSelected:)];
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftArrowSelected:)];
    
    leftSwipeRecognizer.delegate = self;
    rightSwipeRecognizer.delegate = self;
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
#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result == MFMailComposeResultFailed) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Email error" message:@"Error sending email" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Interface Builder Actions
                                             
- (IBAction)imageTapped:(id)sender {
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:@"Picture options" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *takePictureAction = [UIAlertAction actionWithTitle:@"Send through email" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = self;
        [mailController setSubject:[NSString stringWithFormat:@"Sending Note #%ld", self.imageIndex]];
        [mailController setMessageBody:@"Your image data is attached." isHTML:NO];
        
        // Attach image data to email
        UIImage *currentImage = [self.imageStore imageForIndex:self.imageIndex];
        NSData *jpegData = UIImageJPEGRepresentation(currentImage, 1);
        [mailController addAttachmentData:jpegData mimeType:@"image/jpeg" fileName:[NSString stringWithFormat:@"image%ld", self.imageIndex]];
        
        if (mailController && [MFMailComposeViewController canSendMail]) {
            [self presentViewController:mailController animated:YES completion:nil];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Email error" message:@"Cannot send email" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
    
    [actionSheetController addAction:cancelAction];
    [actionSheetController addAction:takePictureAction];
    
    [self presentViewController:actionSheetController animated:YES completion:nil];
}

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
    NSInteger oldImageCount = [self.imageStore imageCount];
    [self.imageStore markRemoveImage:self.imageIndex];
    // Go back if there are no more images
    if ([self.imageStore imageCount] == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if (self.imageIndex >= oldImageCount - 1) {
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
