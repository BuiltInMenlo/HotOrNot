//
//  HONGeoLocator.h
//  HotOrNot
//
//  Created by BIM  on 11/9/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

const CGFloat kMetersAccuracy;
const CGFloat kMetersPerMile;

@interface HONGeoLocator : NSObject
+ (HONGeoLocator *)sharedInstance;

- (BOOL)isWithinOrthodoxClub;
- (CGFloat)milesBetweenLocation:(CLLocation *)location andOtherLocation:(CLLocation *)otherLocation;
- (void)addressForLocation:(CLLocation *)location onCompletion:(void (^)(id result))completion;
@end
