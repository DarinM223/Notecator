//
//  DMNotesTableViewController.m
//  location-notes
//
//  Created by Darin Minamoto on 9/2/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import "DMNotesTableViewController.h"
#import <Parse/Parse.h>

@interface DMNotesTableViewController ()

@end

@implementation DMNotesTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style className:(nullable NSString *)className {
    self = [super initWithStyle:style className:className];
    if (self) {
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 25;
        
        self.parseClassName = className;
        
        // Configure tab bar item
        self.tabBarItem.title = @"My Notes";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

// Find all notes owned by the current user
- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:@"Note"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    return query;
}

- (PFTableViewCell *)tableView:(UITableView * __nonnull)tableView cellForRowAtIndexPath:(NSIndexPath * __nonnull)indexPath object:(nullable PFObject *)object {
    
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotesTableViewCell" forIndexPath:indexPath];
    
    // TODO(darin): Use custom cell and set properties here
    
    return cell;
}

@end
