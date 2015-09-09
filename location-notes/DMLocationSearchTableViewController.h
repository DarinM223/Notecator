//
//  DMLocationSearchTableViewController.h
//  location-notes
//
//  Created by Darin Minamoto on 9/8/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DMLocationSearchTableViewControllerDelegate <NSObject>

- (void)locationSelected:(CLLocation *)location;

@end

@interface DMLocationSearchTableViewController : UITableViewController

@property (nonatomic, assign) id<DMLocationSearchTableViewControllerDelegate> delegate;

@end
