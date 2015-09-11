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

static NSString *_cellIdentifier = @"NoteCell";
static NSString *_noteNibName = @"DMNoteTableViewCell";

@interface DMNotesTableViewController () <DMAddNoteViewControllerDelegate>

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
        
        CGRect rect = CGRectMake(0, 0, 40, 40);
        UIImage *i = [UIImage imageNamed:@"note"];
        UIGraphicsBeginImageContext(rect.size);
        [i drawInRect:rect];
        UIImage *picture = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.tabBarItem.image = picture;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *noteNib = [UINib nibWithNibName:_noteNibName bundle:nil];
    [self.tableView registerNib:noteNib forCellReuseIdentifier:_cellIdentifier];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIBarButtonItem *addNoteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNote:)];
    self.tabBarController.navigationItem.rightBarButtonItem = addNoteButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark DMAddNoteViewControllerDelegate methods

- (void)didDismissModalWindow {
    [self loadObjects];
}

#pragma mark -
#pragma mark Actions

- (IBAction)addNote:(id)sender {
    // Push add note view controller to the stack
    DMAddNoteViewController *noteViewController = [[DMAddNoteViewController alloc] initWithNote:nil];
    noteViewController.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:noteViewController];
    [self presentViewController:navController animated:YES completion:nil];
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
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query orderByAscending:@"note"];
    return query;
}

- (PFTableViewCell *)tableView:(UITableView * __nonnull)tableView cellForRowAtIndexPath:(NSIndexPath * __nonnull)indexPath object:(nullable PFObject *)object {
    DMNoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier forIndexPath:indexPath];
    cell.noteDescription.text = [object objectForKey:@"note"];
    PFGeoPoint *locationPoint = [object objectForKey:@"location"];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:locationPoint.latitude longitude:locationPoint.longitude];
    cell.location = location;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *note = [self.objects objectAtIndex:indexPath.row];
    // Push add note view controller to the stack
    DMAddNoteViewController *noteViewController = [[DMAddNoteViewController alloc] initWithNote:note];
    noteViewController.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:noteViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeObjectAtIndexPath:indexPath animated:YES];
    }
}

@end
