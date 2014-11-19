//
//  HONPrivacyPolicyViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONPrivacyPolicyViewController.h"


@interface HONPrivacyPolicyViewController ()
@end

@implementation HONPrivacyPolicyViewController

- (id)init {
	if ((self = [super initWithURL:[HONAppDelegate customerServiceURLForKey:@"privacy"]
							 title:NSLocalizedString(@"privacy_policy", @"Privacy policy")])) {
		
		_viewStateType = HONStateMitigatorViewStateTypeLegal;
		_totalType = HONStateMitigatorTotalTypeLegal;
	}
	
	return (self);
}


#pragma mark - View Lifecycle
#pragma mark - Navigation
- (void)_goClose {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Settings Tab - Privacy Policy Close"];
	
	[super _goClose];
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
	NSLog(@"[:|:] _goPanGesture:[%@]-=(%@)=-", NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Settings Tab - Privacy Policy Close SWIPE"];
	[super _goPanGesture:gestureRecognizer];
}


@end
