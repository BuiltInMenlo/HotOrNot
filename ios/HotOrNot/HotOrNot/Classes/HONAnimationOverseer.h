//
//  HONAnimationOverseer.h
//  HotOrNot
//
//  Created by BIM  on 10/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HONViewController.h"

@interface HONAnimationOverseer : NSObject
+ (HONAnimationOverseer *)sharedInstance;

- (BOOL)isScrollingAnimationEnabledForScrollView:(id)scrollView;
- (BOOL)isAnimationEnabledForViewControllerModalSegue:(UIViewController *)viewController;
- (BOOL)isAnimationEnabledForViewControllerPushSegue:(UIViewController *)viewController;

@end
