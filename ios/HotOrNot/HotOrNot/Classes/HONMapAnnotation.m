//
//  HONMapAnnotation.m
//  HotOrNot
//
//  Created by BIM  on 11/6/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "HONMapAnnotation.h"

@implementation HONMapAnnotation
@synthesize title = _title;
@synthesize subtitle = _subtitle;


- (id)initWithCoordPt:(CGPoint)coordPt {
	if ((self = [self initWithLatitiude:coordPt.y andLongitude:coordPt.x])) {
	}
	
	return (self);
}

- (id)initWithLatitiude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude {
	if ((self = [super init])) {
	}
	
	return (self);
}

- (NSString *)title {
	return (_title);
}

- (NSString *)subtitle {
	return (_subtitle);
}

- (CLLocationCoordinate2D)coordinate {
	return ([[CLLocation alloc] initWithLatitude:_latitude longitude:_longitude].coordinate);
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {
	_latitude = coordinate.latitude;
	_longitude = coordinate.longitude;
}

@end
