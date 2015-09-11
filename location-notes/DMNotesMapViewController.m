//
//  DMNotesMapViewController.m
//  location-notes
//
//  Created by Darin Minamoto on 9/8/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "DMNotesMapViewController.h"
#import "DMNote.h"

@interface DMNotesMapViewController () <CLLocationManagerDelegate, MKMapViewDelegate> {
    CLLocationManager *locationManager;
    CLLocation *lastPulledLocation;
    NSMutableArray *annotations;
}

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

@implementation DMNotesMapViewController

// Maximum distance in kilometers to load notes before repulling
static double MAX_DISTANCE = 1000.0;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"Map";
        
        CGRect rect = CGRectMake(0, 0, 40, 40);
        UIImage *i = [UIImage imageNamed:@"map"];
        UIGraphicsBeginImageContext(rect.size);
        [i drawInRect:rect];
        UIImage *picture = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.tabBarItem.image = picture;
        annotations = [[NSMutableArray alloc] init];
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.mapView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        [locationManager requestWhenInUseAuthorization];
    }
    self.mapView.showsUserLocation = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Parse Querying methods

- (void)pullNotesByCoordinate:(CLLocationCoordinate2D)coordinate {
    PFGeoPoint *locationPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    PFQuery *noteQuery = [[PFQuery alloc] initWithClassName:@"Note"];
    [noteQuery whereKey:@"location" nearGeoPoint:locationPoint withinKilometers:MAX_DISTANCE];
    
    [noteQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        // Reload annotations array
        [annotations removeAllObjects];
        for (PFObject *object in results) {
            DMNote *note = [[DMNote alloc] initWithNote:object];
            [annotations addObject:note];
        }
        // Reload map view
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView addAnnotations:annotations];
    }];
}

#pragma mark -
#pragma mark MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    mapView.centerCoordinate = userLocation.coordinate;
    if (lastPulledLocation == nil) {
        lastPulledLocation = userLocation.location;
        [self pullNotesByCoordinate:userLocation.location.coordinate];
    } else {
        // Distance between last pulled location and recent location in meters
        CLLocationDistance distance = [userLocation.location distanceFromLocation:lastPulledLocation];
        
        CLLocationDistance distanceKilos = distance / 1000.0;
        
        // Repull note objects if greater than certain distance
        if (distanceKilos >= MAX_DISTANCE) {
            lastPulledLocation = userLocation.location;
            [self pullNotesByCoordinate:userLocation.location.coordinate];
        }
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
