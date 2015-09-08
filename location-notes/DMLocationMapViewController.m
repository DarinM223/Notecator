//
//  DMLocationMapViewController.m
//  location-notes
//
//  Created by Darin Minamoto on 9/7/15.
//  Copyright (c) 2015 com.d_m. All rights reserved.
//

#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import "DMLocationMapViewController.h"

@interface DMLocationMapViewController () <CLLocationManagerDelegate, MKMapViewDelegate> {
    CLLocationManager *locationManager;
}

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

@implementation DMLocationMapViewController

- (instancetype)initWithNote:(PFObject *)note {
    self = [super init];
    if (self) {
        self.note = note;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.mapView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(onSearch:)];
    self.navigationItem.rightBarButtonItem = searchButton;
    
    PFGeoPoint *locationObject = [self.note objectForKey:@"location"];
    if (locationObject == nil) {
        NSLog(@"Location is null!");
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
            [locationManager requestWhenInUseAuthorization];
        }
        self.mapView.showsUserLocation = YES;
    } else {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:locationObject.latitude longitude:locationObject.longitude];
        self.mapView.centerCoordinate = location.coordinate;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    PFGeoPoint *locationObject = [self.note objectForKey:@"location"];
    if (locationObject == nil) {
        locationObject = [PFGeoPoint geoPointWithLatitude:userLocation.location.coordinate.latitude longitude:userLocation.location.coordinate.longitude];
        [self.note setObject:locationObject forKey:@"location"];
        self.mapView.centerCoordinate = userLocation.location.coordinate;
    }
}

#pragma mark -
#pragma mark Actions

- (IBAction)onSearch:(id)sender {
    NSLog(@"Search button clicked!");
}

@end
