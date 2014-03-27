//
//  JLBPopSlideTransition.h
//  NavigationTest
//
//  Created by Jesse Boley on 2/27/14.
//  Copyright (c) 2014 Jesse Boley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JLBPopSlideTransition : UIPercentDrivenInteractiveTransition <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>
@property(nonatomic) NSTimeInterval transitionDuration;
@property(nonatomic) BOOL dismissed;
@property(nonatomic) BOOL interactivePresentEnabled;
@property(nonatomic) BOOL interactiveDismissEnabled;
@end
