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
        
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:_cellIdentifier];
        //[self.tableView registerNib:[UINib nibWithNibName:@"DMNoteTableViewCell" bundle:nil] forCellReuseIdentifier:_cellIdentifier];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *addNoteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNote:)];
    self.tabBarController.navigationItem.rightBarButtonItem = addNoteButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Actions

- (IBAction)addNote:(id)sender {
    // Push add note view controller to the stack
    DMAddNoteViewController *noteViewController = [[DMAddNoteViewController alloc] initWithNote:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:noteViewController];
    [self presentViewController:navController animated:YES completion:^{
        [self.tableView reloadData];
    }];
}

#pragma mark -
#pragma mark Table view data source

- (void)objectsDidLoad:(nullable NSError *)error {
    [super objectsDidLoad:error];
    
    if (error) {
        NSLog(@"Error loading objects: %@", error.description);
    }
}

// Find all notes owned by the current user
- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    if (self.objects == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query orderByAscending:@"note"];
    return query;
}

- (PFTableViewCell *)tableView:(UITableView * __nonnull)tableView cellForRowAtIndexPath:(NSIndexPath * __nonnull)indexPath object:(nullable PFObject *)object {
    
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:_cellIdentifier owner:self options:nil][0];
    }
    
    cell.textLabel.text = [object objectForKey:@"note"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *note = [self.objects objectAtIndex:indexPath.row];
    // Push add note view controller to the stack
    DMAddNoteViewController *noteViewController = [[DMAddNoteViewController alloc] initWithNote:note];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:noteViewController];
    [self presentViewController:navController animated:YES completion:^{
        [self.tableView reloadData];
    }];
}

@end
