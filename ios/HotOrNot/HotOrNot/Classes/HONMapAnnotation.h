//
//  HONMapAnnotation.h
//  HotOrNot
//
//  Created by BIM  on 11/6/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface HONMapAnnotation : NSObject <MKAnnotation> {
	CLLocationDegrees _latitude;
	CLLocationDegrees _longitude;
}

- (id)initWithCoordPt:(CGPoint)coordPt;
- (id)initWithLatitiude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude;

- (NSString *)title;
- (NSString *)subtitle;

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@end
