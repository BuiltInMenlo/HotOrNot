//
//  HONTimelineMapViewController.m
//  HotOrNot
//
//  Created by BIM  on 11/6/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONTimelineMapViewController.h"
#import "HONHeaderView.h"

#define kMETERS_PER_MILE				1609.344f
#define kMILES_PER_DEGREES_LATITUDE		69.0f

#define kMIN_THRESHOLD_METERS	1000.0f
#define kMAP_AREA_MILES			5.0f


@interface HONTimelineMapViewController ()
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic) CGPoint coordPt;

@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic) MKCoordinateRegion coordinateRegion;
//>> @property (nonatomic, strong) PPUserAnnotation *userAnnotation;
@property (nonatomic, strong) NSMutableArray *visibleMembers;
@end


@implementation HONTimelineMapViewController
@synthesize delegate = _delegate;

+ (NSString *)reuseIdentifierForAnnotationView {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		_geocoder = [[CLGeocoder alloc] init];
		_locationManager = [[CLLocationManager alloc] init];
		_visibleMembers = [NSMutableArray array];
		
		_coordPt = CGPointMake(-122.165486f, 37.463641f);
		
		_location = [[CLLocation alloc] initWithLatitude:_coordPt.y longitude:_coordPt.x];
		_coordinateRegion = MKCoordinateRegionMakeWithDistance(_location.coordinate, kMAP_AREA_MILES * kMETERS_PER_MILE, kMAP_AREA_MILES * kMETERS_PER_MILE);
		
		if ([CLLocationManager locationServicesEnabled]) {
			_locationManager.delegate = self;
			_locationManager.distanceFilter = kMIN_THRESHOLD_METERS;
			[_locationManager startUpdatingLocation];
		}
		
		_totalType = HONStateMitigatorTotalTypeStatusUpdate;
		_viewStateType = HONStateMitigatorViewStateTypeStatusUpdate;
		
		self.view.backgroundColor = [UIColor brownColor];
	}
	
	return (self);
}



#pragma mark - Public APIs
- (void)updateCoordPt:(CGPoint)coordPt {
	_coordPt = coordPt;
}


#pragma mark - View lifecycle
- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	_mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.view.bounds.size.height - (kNavHeaderHeight + 175.0))];
		_mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0, self.view.bounds.size.height - 190.0, 320.0, 190.0)];
	_mapView.mapType = MKMapTypeStandard;
	_mapView.delegate = self;
	[_mapView setUserTrackingMode:MKUserTrackingModeNone animated:NO];
	[_mapView setRegion:_coordinateRegion animated:NO];
	[self.view addSubview:_mapView];
	
	
	[self _updateMap];
}


#pragma mark - Data Calls
- (void)_updateMap {
	NSLog(@"\\-[%@ _updateMap:(%@)]-//", self.class, _location);
	_coordinateRegion = MKCoordinateRegionMakeWithDistance(_location.coordinate, kMAP_AREA_MILES * kMETERS_PER_MILE, kMAP_AREA_MILES * kMETERS_PER_MILE);
	[self.mapView setRegion:_coordinateRegion animated:YES];
	
	[_geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks, NSError *error) {
		CLPlacemark *placemark = (CLPlacemark *)[placemarks firstObject];
		NSString *address = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare];
		NSString *cityStateZip = [NSString stringWithFormat:@"%@, %@ %@", placemark.locality, placemark.administrativeArea, placemark.postalCode];
		NSLog(@"**_[%@ geocoder:reverseGeocodeLocation:(%@ // %@)]_**", self.class, address, cityStateZip);
	}];
}


#pragma mark - LocationManager Delegates
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	NSLog(@"**_[%@ locationManager:didUpdateLocations:(%@)]_**", self.class, locations);
	
//	_userLocation = (CLLocation *)[locations firstObject];
//	if (_userAnnotation == nil) {
//		_userAnnotation = [[PPUserAnnotation alloc] initWithLatitude:_userLocation.coordinate.latitude andLongitude:_userLocation.coordinate.longitude];
//		[self.mapView addAnnotation:_userAnnotation];
//	}
	
//	[self _updateMap];
	[_locationManager stopUpdatingLocation];
}


#pragma mark - MapView Delegates
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
	NSLog(@"**_[%@ mapView:viewForAnnotation:(%@)]_**", self.class, annotation);
	
//	if ([annotation isKindOfClass:[PPUserAnnotation class]]) {
//		MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:kUserAnnonationViewIdentifier];
//		
//		if (annotationView == nil) {
//			annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kUserAnnonationViewIdentifier];
//			annotationView.pinColor = MKPinAnnotationColorRed;
//			annotationView.canShowCallout = YES;
//			annotationView.animatesDrop = YES;
//			annotationView.draggable = YES;
//			
//		} else
//			annotationView.annotation = annotation;
//		
//		return (annotationView);
//		
//	} else if ([annotation isKindOfClass:[PPSupplierAnnotation class]]) {
//		PPSupplierAnnotationView *annotationView = (PPSupplierAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:kSupplierAnnonationViewIdentifier];
//		
//		if (annotationView == nil) {
//			annotationView = [[PPSupplierAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kSupplierAnnonationViewIdentifier];
//			annotationView.canShowCallout = YES;
//			annotationView.draggable = NO;
//			
//		} else
//			annotationView.annotation = annotation;
//		
//		for (PPSupplierVO *vo in _suppliers) {
//			if ([vo.annotation isEqual:annotation]) {
//				annotationView.supplierVO = vo;
//				break;
//			}
//		}
//		
//		if ([annotation isEqual:_supplierAnnotation])
//			[annotationView setSelected:YES animated:YES];
//		
//		return (annotationView);
//	}
	
	return (nil);
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	//	NSLog(@"**_[%@ mapView:didAddAnnotationViews:(%@)]_**", self.class, views);
	
//	for (MKAnnotationView *annotationView in views) {
//		if ([annotationView.annotation isEqual:_supplierAnnotation]) {
//			[self.mapView selectAnnotation:annotationView.annotation animated:YES];
//			break;
//		}
//	}
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	//	NSLog(@"**_[%@ mapView:didSelectAnnotationView:(%@)]_**", self.class, view);
	
//	if ([view isKindOfClass:[PPSupplierAnnotationView class]]) {
//		if (((PPSupplierAnnotationView *)view).supplierVO.isAvailable) {
//			_selectedSupplierVO = ((PPSupplierAnnotationView *)view).supplierVO;
//			_supplierAnnotation = _selectedSupplierVO.annotation;
//		}
//	}
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
	//	NSLog(@"**_[%@ mapView:didDeselectAnnotationView:(%@)]_**", self.class, view);
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	//	NSLog(@"**_[%@ mapView:annotationView:(%@)didChangeDragState:(%@) fromOldState:(%@)]_**", self.class, view, (newState == 0) ? @"None" : (newState == 1) ? @"Starting" : (newState == 2) ? @"Dragging" : (newState == 3) ? @"Canceling" : @"Ending", (oldState == 0) ? @"None" : (oldState == 1) ? @"Starting" : (oldState == 2) ? @"Dragging" : (oldState == 3) ? @"Canceling" : @"Ending");
	
	[self.mapView deselectAnnotation:view.annotation animated:YES];
	
	if (oldState == MKAnnotationViewDragStateEnding && newState == MKAnnotationViewDragStateNone) {
		CLLocation *location = [[CLLocation alloc] initWithLatitude:view.annotation.coordinate.latitude longitude:view.annotation.coordinate.longitude];
		if (CLLocationCoordinate2DIsValid(location.coordinate) && (location.coordinate.latitude !=location .coordinate.latitude || location.coordinate.longitude != _location.coordinate.longitude)) {
			_location = location;
			[self _updateMap];
		}
	}
}

@end
