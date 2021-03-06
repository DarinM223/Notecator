//
//  DMLoginViewController.m
//  location-notes
//
//  Created by Darin Minamoto on 9/1/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

#import "DMLoginViewController.h"
#import "DMNotesMapViewController.h"
#import "DMNotesTableViewController.h"
#import "DMSpinner.h"

@interface DMLoginViewController ()

@end

@implementation DMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor colorWithRed:0.05 green:0.47 blue:0.91 alpha:1.0];
    self.imageView.image = [UIImage imageNamed:@"map"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

#pragma mark -
#pragma mark Interface Builder Actions

- (IBAction)onFacebookLoginClicked:(id)sender {
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships" ];
    DMSpinner *spinner = [[DMSpinner alloc] initWithView:self.view color:[UIColor greenColor]];
    [spinner addSpinner];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [spinner removeSpinner];
        
        if (!user) {
            NSString *alertMessage, *alertTitle;
            if (error) {
                FBErrorCategory errorCategory = [FBErrorUtility errorCategoryForError:error];
                if ([FBErrorUtility shouldNotifyUserForError:error]) {
                    alertTitle = @"Something went wrong";
                    alertMessage = [FBErrorUtility userMessageForError:error];
                } else if (errorCategory == FBErrorCategoryAuthenticationReopenSession) {
                    alertTitle = @"Session Error";
                    alertMessage = @"Your current session is no longer valid. Please log in again.";
                } else if (errorCategory == FBErrorCategoryUserCancelled) {
                    NSLog(@"User cancelled login");
                } else {
                    alertTitle = @"Unknown error";
                    alertMessage = @"Error. Please try again later.";
                }
            }
            
            if (alertMessage) {
                [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
            }
        } else {
            UITabBarController *tabBarController = [[UITabBarController alloc] init];
            DMNotesMapViewController *notesMapViewController = [[DMNotesMapViewController alloc] init];
            DMNotesTableViewController *notesTableViewController = [[DMNotesTableViewController alloc] initWithClassName:@"Note"];
            tabBarController.viewControllers = @[ notesTableViewController, notesMapViewController ];
            
            // Overwrite navigation stack with the tab bar controller
            self.navigationController.navigationBar.hidden = NO;
            [self.navigationController setViewControllers:@[tabBarController] animated:YES];
        }
    }];
}

@end
