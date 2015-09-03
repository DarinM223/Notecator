//
//  DMNotesTableViewController.m
//  location-notes
//
//  Created by Darin Minamoto on 9/2/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <Parse/Parse.h>

#import "DMNotesTableViewController.h"
#import "DMAddNoteViewController.h"
#import "DMNoteTableViewCell.h"

@interface DMNotesTableViewController () {
    NSString *_cellIdentifier;
}


@end

@implementation DMNotesTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style className:(nullable NSString *)className {
    self = [super initWithStyle:style className:className];
    if (self) {
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 25;
        
        self.parseClassName = className;
        
        _cellIdentifier = @"NoteCell";
        
        // Configure tab bar item
        self.tabBarItem.title = @"My Notes";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *addNoteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNote:)];
    self.tabBarController.navigationItem.rightBarButtonItem = addNoteButton;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DMNoteTableViewCell" bundle:nil] forCellReuseIdentifier:_cellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)addNote:(id)sender {
    // Push add note view controller to the stack
    DMAddNoteViewController *noteViewController = [[DMAddNoteViewController alloc] initWithNote:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:noteViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Table view data source

// Find all notes owned by the current user
- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:@"Note"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    return query;
}

- (PFTableViewCell *)tableView:(UITableView * __nonnull)tableView cellForRowAtIndexPath:(NSIndexPath * __nonnull)indexPath object:(nullable PFObject *)object {
    
    DMNoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell" forIndexPath:indexPath];
    
    NSLog(@"%@", object);
    
    cell.noteDescription.text = [object objectForKey:@"note"];
    
    return cell;
}

@end
