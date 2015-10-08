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
#import "DMAddNoteViewController.h"
#import "DMConstants.h"
#import "DMNote.h"

@interface DMNotesMapViewController () <CLLocationManagerDelegate, MKMapViewDelegate, DMAddNoteViewControllerDelegate> {
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    CLLocation *lastPulledLocation;
    NSMutableArray *annotations;
    BOOL zoom;
}

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

@implementation DMNotesMapViewController

static long const ZOOM_DISTANCE = 100;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"Map";
        zoom = YES;
        
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
    
    UIBarButtonItem *currentLocationButton = [[UIBarButtonItem alloc] initWithTitle:@"My Location" style:UIBarButtonItemStylePlain target:self action:@selector(currentLocationButtonClicked:)];
    self.tabBarController.navigationItem.rightBarButtonItem = currentLocationButton;
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
    [noteQuery whereKey:@"location" nearGeoPoint:locationPoint withinKilometers:MAX_PULL_DISTANCE];
    
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
    if (userLocation == nil) {
        return;
    }
    
    // Set location on map and zoom in initially
    if (zoom) {
        mapView.centerCoordinate = userLocation.coordinate;
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, ZOOM_DISTANCE, ZOOM_DISTANCE);
        MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
        [self.mapView setRegion:adjustedRegion];
        
        // Don't zoom after the first time
        zoom = NO;
    }
    
    currentLocation = userLocation.location;
    
    if (lastPulledLocation == nil) {
        lastPulledLocation = userLocation.location;
        [self pullNotesByCoordinate:userLocation.location.coordinate];
    } else {
        // Distance between last pulled location and recent location in meters
        CLLocationDistance distance = [userLocation.location distanceFromLocation:lastPulledLocation];
        
        CLLocationDistance distanceKilos = distance / 1000.0;
        
        // Repull note objects if greater than certain distance
        if (distanceKilos >= MAX_PULL_DISTANCE) {
            lastPulledLocation = userLocation.location;
            [self pullNotesByCoordinate:userLocation.location.coordinate];
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[DMNote class]]) {
        static NSString * const reuseIdentifier = @"pin";
        
        MKPinAnnotationView *customPinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
        if (customPinView == nil) {
            customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
            customPinView.pinColor = MKPinAnnotationColorRed;
            customPinView.canShowCallout = YES;
            customPinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        } else {
            customPinView.annotation = annotation;
        }
        
        return customPinView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    DMNote *note = (DMNote *)view.annotation;

    DMAddNoteViewController *editNoteController = [[DMAddNoteViewController alloc] initWithNote:note.object];
    editNoteController.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:editNoteController];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark -
#pragma mark DMAddNoteViewControllerDelegate methods

- (void)didDismissModalWindow {
    if (currentLocation) {
        [self pullNotesByCoordinate:currentLocation.coordinate];
    }
}

#pragma mark -
#pragma mark Actions

- (IBAction)currentLocationButtonClicked:(id)sender {
    if (currentLocation == nil) {
        return;
    }
    self.mapView.centerCoordinate = currentLocation.coordinate;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, ZOOM_DISTANCE, ZOOM_DISTANCE);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
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
