//
//  DMAddNoteViewController.h
//  location-notes
//
//  Created by Darin Minamoto on 9/3/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFObject;

@interface DMAddNoteViewController : UIViewController

- (instancetype)initWithNote:(PFObject *)note;

@property (nonatomic, strong) PFObject *note;

@end
