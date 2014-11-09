//
//  HONTimelineMapViewController.h
//  HotOrNot
//
//  Created by BIM  on 11/6/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "HONViewController.h"


typedef NS_ENUM(NSUInteger, HONMapViewControllerAlertType) {
	HONMapViewControllerAlertTypeDefault = 0
};


@class HONTimelineMapViewController;
@protocol HONTimelineMapViewControllerDelegate <NSObject>
@optional
- (void)timelineMapViewController:(HONTimelineMapViewController *)viewController didChangeToCoordPt:(CGPoint)coordPt;
- (void)timelineMapViewController:(HONTimelineMapViewController *)viewController didChangeToLocation:(CLLocation *)location;
@end


@interface HONTimelineMapViewController : HONViewController <CLLocationManagerDelegate, MKMapViewDelegate, UIAlertViewDelegate>
+ (NSString *)reuseIdentifierForAnnotationView;

- (void)updateCoordPt:(CGPoint)coordPt;

@property (nonatomic, assign) id <HONTimelineMapViewControllerDelegate> delegate;
@end
