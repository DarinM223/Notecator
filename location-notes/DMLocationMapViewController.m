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
#import "DMLocationSearchTableViewController.h"
#import "DMNote.h"

@interface DMLocationMapViewController () <CLLocationManagerDelegate, MKMapViewDelegate, DMLocationSearchTableViewControllerDelegate> {
    CLLocationManager *locationManager;
    NSArray *annotations;
    BOOL locationUpdating;
    BOOL zoom;
}

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

@implementation DMLocationMapViewController

static long const ZOOM_DISTANCE = 100;

- (instancetype)initWithNote:(PFObject *)note {
    self = [super init];
    if (self) {
        self.note = note;
        annotations = [[NSArray alloc] init];
        zoom = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.mapView.delegate = self;
    
    // Add touch gestures
    UILongPressGestureRecognizer *changeLocationPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLocationChange:)];
    changeLocationPress.minimumPressDuration = 1;
    [self.mapView addGestureRecognizer:changeLocationPress];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(onSearch:)];
    self.navigationItem.rightBarButtonItem = searchButton;
    
    PFGeoPoint *locationObject = [self.note objectForKey:@"location"];
    if (locationObject == nil) {
        locationUpdating = YES;
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
            [locationManager requestWhenInUseAuthorization];
        }
        self.mapView.showsUserLocation = YES;
    } else {
        locationUpdating = NO;
        CLLocation *location = [[CLLocation alloc] initWithLatitude:locationObject.latitude longitude:locationObject.longitude];
        
        [self updateLocation:location.coordinate];
        
        // Add the annotation to the map if there already isn't an annotation
        if (self.mapView.annotations.count == 0) {
            DMNote *noteFromObject = [[DMNote alloc] initWithNote:self.note];
            [self.mapView addAnnotation:noteFromObject];
        }
    }
}

// Updates the location and zooms
- (void)updateLocation:(CLLocationCoordinate2D)location {
    self.mapView.centerCoordinate = location;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location, ZOOM_DISTANCE, ZOOM_DISTANCE);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    if (zoom) {
        [self.mapView setRegion:adjustedRegion animated:YES];
        zoom = NO;
    } else {
        [self.mapView setRegion:adjustedRegion animated:NO];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (locationUpdating) {
        PFGeoPoint *locationObject = [PFGeoPoint geoPointWithLatitude:userLocation.location.coordinate.latitude longitude:userLocation.location.coordinate.longitude];
        [self.note setObject:locationObject forKey:@"location"];
        
        [self updateLocation:userLocation.location.coordinate];
        
        // Remove existing annotations and add new annotation to the map
        if (mapView.annotations.count != 0) {
            [mapView removeAnnotations:mapView.annotations];
        }
        DMNote *noteFromObject = [[DMNote alloc] initWithNote:self.note];
        [mapView addAnnotation:noteFromObject];
    }
}

#pragma mark -
#pragma mark DMLocationSearchTableViewControllerDelegate methods

- (void)locationSelected:(CLLocation *)location {
    // Set note with new location
    PFGeoPoint *locationObject = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    [self.note setObject:locationObject forKey:@"location"];
    
    [self updateLocation:location.coordinate];
    
    // Remove existing annotations and add new annotation to the map
    if (self.mapView.annotations.count != 0) {
        [self.mapView removeAnnotations:self.mapView.annotations];
    }
    DMNote *noteFromObject = [[DMNote alloc] initWithNote:self.note];
    [self.mapView addAnnotation:noteFromObject];
}

#pragma mark -
#pragma mark Actions

- (void)onLocationChange:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    PFGeoPoint *locationObject = [PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [self.note setObject:locationObject forKey:@"location"];
    self.mapView.centerCoordinate = coordinate;
    
    // Turn off auto-follow user location
    locationUpdating = NO;
    
    if (self.mapView.annotations.count != 0) {
        [self.mapView removeAnnotations:self.mapView.annotations];
    }
    DMNote *noteFromObject = [[DMNote alloc] initWithNote:self.note];
    [self.mapView addAnnotation:noteFromObject];
}

- (IBAction)onSearch:(id)sender {
    DMLocationSearchTableViewController *searchController = [[DMLocationSearchTableViewController alloc] init];
    searchController.delegate = self;
    [self.navigationController pushViewController:searchController animated:YES];
}

@end
