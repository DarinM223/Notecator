//
//  DMLocationSearchTableViewController.m
//  location-notes
//
//  Created by Darin Minamoto on 9/8/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "DMLocationSearchTableViewController.h"

@interface DMLocationSearchTableViewController () <UISearchBarDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) NSArray *placemarks;
@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation DMLocationSearchTableViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.geocoder = [[CLGeocoder alloc] init];
    self.placemarks = [[NSArray alloc] init];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.scopeButtonTitles = @[
                                                          NSLocalizedString(@"ScopeButtonCountry", @"Country"),
                                                          NSLocalizedString(@"ScopeButtonCapital", @"Capital")
                                                          ];
    self.searchController.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UISearchResultsUpdating delegate methods

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    [self.geocoder geocodeAddressString:searchString completionHandler:^(NSArray *placemarks, NSError *error) {
        self.placemarks = placemarks;
        [self.tableView reloadData];
    }];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.placemarks.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    CLPlacemark *placemark = [self.placemarks objectAtIndex:indexPath.row];
    NSString *placemarkString = [NSString stringWithFormat:@"%@ (%@)", placemark.name, placemark.country];
    cell.textLabel.text = placemarkString;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CLPlacemark *placemark = [self.placemarks objectAtIndex:indexPath.row];
    [self.delegate locationSelected:placemark.location];
    [self.navigationController popViewControllerAnimated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
