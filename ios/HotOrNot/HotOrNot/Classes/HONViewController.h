//
//  HONViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 07/26/2014 @ 17:40 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


@interface HONViewController : UIViewController <UIGestureRecognizerDelegate> {
	UIPanGestureRecognizer *_panGestureRecognizer;
	BOOL _isPushing;
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer;
@end
