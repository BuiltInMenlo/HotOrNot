//
//  HONTermsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.23.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONTermsViewController.h"


@interface HONTermsViewController ()
@end

@implementation HONTermsViewController

- (id)init {
	if ((self = [super initWithURL:[HONAppDelegate customerServiceURLForKey:@"terms"]
							 title:NSLocalizedString(@"header_terms", @"Terms of service")])) {
		
		_viewStateType = HONStateMitigatorViewStateTypeLegal;
		_totalType = HONStateMitigatorTotalTypeLegal;
	}
	
	return (self);
}


#pragma mark - View Lifecycle
#pragma mark - Navigation
- (void)_goClose {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Settings Tab - Terms of Service Close"];
	[super _goClose];
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
	NSLog(@"[:|:] _goPanGesture:[%@]-=(%@)=-", NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Settings Tab - Terms of Service Close SWIPE"];
	[super _goPanGesture:gestureRecognizer];
}

@end
