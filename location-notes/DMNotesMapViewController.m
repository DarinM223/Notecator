//
//  DMNotesMapViewController.m
//  location-notes
//
//  Created by Darin Minamoto on 9/3/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import "DMNotesMapViewController.h"

@interface DMNotesMapViewController ()

@end

@implementation DMNotesMapViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"Map";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
