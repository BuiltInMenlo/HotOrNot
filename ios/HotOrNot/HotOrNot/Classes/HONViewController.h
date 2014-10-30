//
//  HONViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 07/26/2014 @ 17:40 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONStateMitigatorEnums.h"

@interface HONViewController : UIViewController <UIGestureRecognizerDelegate> {
	UINavigationController *_presentedNavigationController;
	UIViewController *_sireViewController;
	UIViewController *_currentViewController;
	UIViewController *_nextViewController;
	UIViewController *_presentedViewController;
	
	UIPanGestureRecognizer *_panGestureRecognizer;
	NSString *_className;
	BOOL _isPushing;
	
	HONStateMitigatorViewStateType _viewStateType;
	HONStateMitigatorTotalType _totalType;
}

+ (NSString *)className;
- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)destroy;
@end
