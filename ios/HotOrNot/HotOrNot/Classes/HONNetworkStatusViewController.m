//
//  HONNetworkStatusViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 07/16/2014 @ 18:35 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONNetworkStatusViewController.h"


@interface HONNetworkStatusViewController ()
@end


@implementation HONNetworkStatusViewController

- (id)init {
	if ((self = [super initWithURL:@"https://www.twitter.com/selfiec_status"
							 title:NSLocalizedString(@"network_status", @"Network status")])) {
		
		_viewStateType = HONStateMitigatorViewStateTypeNetworkStatus;
		_totalType = HONStateMitigatorTotalTypeNetworkStatus;
	}
	
	return (self);
}


#pragma mark - View Lifecycle
#pragma mark - Navigation
- (void)_goClose {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Settings Tab - Network Status Close"];
	
	[super _goClose];
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
//	NSLog(@"[:|:] [%@]_goPanGesture:[%@]-=(%@)=-", self.class, NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Settings Tab - Network Status Close SWIPE"];
	[super _goPanGesture:gestureRecognizer];
}

@end
