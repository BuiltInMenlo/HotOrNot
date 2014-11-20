//
//  HONGeoLocator.m
//  HotOrNot
//
//  Created by BIM  on 11/9/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONGeoLocator.h"

const CGFloat kMetersAccuracy = 1000.0f;
const CGFloat kMetersPerMile = 1609.344f;

@implementation HONGeoLocator
static HONGeoLocator *sharedInstance = nil;

+ (HONGeoLocator *)sharedInstance {
	static HONGeoLocator *s_sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		s_sharedInstance = [[self alloc] init];
	});
	
	return (s_sharedInstance);
}

- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}


- (BOOL)isWithinOrthodoxClub {
	CLLocation *orthodoxClubLocation = [[CLLocation alloc] initWithLatitude:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"orthodox_club"] objectForKey:@"lat"] doubleValue] longitude:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"orthodox_club"] objectForKey:@"long"] doubleValue]];
	return ([[HONGeoLocator sharedInstance] milesBetweenLocation:[[HONDeviceIntrinsics sharedInstance] deviceLocation] andOtherLocation:orthodoxClubLocation] <= [[[[NSUserDefaults standardUserDefaults] objectForKey:@"orthodox_club"] objectForKey:@"radius"] intValue]);
}

- (CGFloat)milesBetweenLocation:(CLLocation *)location andOtherLocation:(CLLocation *)otherLocation {
	return(MKMetersBetweenMapPoints(MKMapPointForCoordinate(location.coordinate), MKMapPointForCoordinate(otherLocation.coordinate)) / kMetersPerMile);
}

- (void)addressForLocation:(CLLocation *)location onCompletion:(void (^)(id result))completion {
	[[[CLGeocoder alloc] init] reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
		CLPlacemark *placemark = (CLPlacemark *)[placemarks firstObject];
		NSDictionary *result = @{@"address"	: [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare],
								 @"city"	: placemark.locality,
								 @"state"	: placemark.administrativeArea,
								 @"zip"		: placemark.postalCode,
								 @"country"	: placemark.country};
		if (completion)
			completion(result);
	}];
}

@end