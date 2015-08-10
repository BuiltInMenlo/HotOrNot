//
//  HONDiscoverViewController.m
//  HotOrNot
//
//  Created by BIM  on 8/7/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "HONDiscoverViewController.h"

@interface HONDiscoverViewController ()
@end


@implementation HONDiscoverViewController

- (id)init {
	if ((self = [super initWithURL:@"http://popup.rocks/app.php"
							 title:@""])) {
		
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


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSLog(@"[*:*] webView:shouldStartLoadWithRequest:[%@]", request.URL.absoluteString);
	
	if ([request.URL.absoluteString rangeOfString:@"popuprocks://"].location != NSNotFound)
		[self dismissViewControllerAnimated:NO completion:nil];
	
	return ([super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType]);
}

@end
