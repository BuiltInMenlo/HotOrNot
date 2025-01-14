//
//  HONAnimationOverseer.h
//  HotOrNot
//
//  Created by BIM  on 10/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HONViewController.h"

extern const CGFloat kProgressHUDMinDuration;
extern const CGFloat kProgressHUDErrorDuration;

@interface HONAnimationOverseer : NSObject
+ (HONAnimationOverseer *)sharedInstance;

- (BOOL)isScrollingAnimationEnabledForScrollView:(id)scrollView;
- (BOOL)isSegueAnimationEnabledForModalViewController:(UIViewController *)viewController;
- (BOOL)isSegueAnimationEnabledForPushViewController:(UIViewController *)viewController;

@end
