//
//  JLBPopSlideTransition.m
//
//  Created by Jesse Boley on 2/27/14.
//  Copyright (c) 2014 Jesse Boley. All rights reserved.
//

#import "JLBPopSlideTransition.h"
#import "JLBAnimator.h"

#import <objc/runtime.h>

static const void *kJLBTransitionPresentedControllerKey = &kJLBTransitionPresentedControllerKey;

@interface JLBPopSlideTransition ()
@end

@implementation JLBPopSlideTransition
{
	BOOL _isDismissed;
	CGFloat _lastPercentComplete;
	
	id<UIViewControllerContextTransitioning> _interactiveTransitionContext;
	UIViewController *_interactiveFromViewController;
	CGRect _fromStartFrame;
	CGRect _fromFinalFrame;
	
	UIViewController *_interactiveToViewController;
	CGRect _toStartFrame;
	CGRect _toFinalFrame;
	
	JLBAnimator *_animator;
}

- (id)init
{
	if ((self = [super init])) {
		_transitionDuration = 0.3;
		_interactiveDismissEnabled = YES;
	}
	return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
	objc_setAssociatedObject(presented, kJLBTransitionPresentedControllerKey, self, OBJC_ASSOCIATION_RETAIN);
	_isDismissed = NO;
	return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
	_isDismissed = YES;
	return self;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
{
	if (_interactivePresentEnabled) {
		_isDismissed = NO;
		return self;
	}
	return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
	if (_interactiveDismissEnabled) {
		_isDismissed = YES;
		return self;
	}
	return nil;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
	return _transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
	if (!_isDismissed)
		[self _animatePresentTransition:transitionContext];
	else
		[self _animateDismissTransition:transitionContext];
}

- (void)_animatePresentTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
	UIView *containerView = [transitionContext containerView];
	UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	
	// Add the appearing view controller to the transition container
	CGRect finalAppearingFrame = [transitionContext finalFrameForViewController:toViewController];
	toViewController.view.frame = CGRectOffset(finalAppearingFrame, CGRectGetWidth(containerView.bounds), 0.0);
	[containerView addSubview:toViewController.view];

	// The appearing view slides in to the cover the screen while the existing view slides a bit slower to create a parallax effect
	CGRect finalDisappearingFrame = CGRectOffset(fromViewController.view.frame, -floor(0.75 * CGRectGetWidth(containerView.bounds)), 0.0);
	
	[UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
		toViewController.view.frame = finalAppearingFrame;
		fromViewController.view.frame = finalDisappearingFrame;
	} completion:^(BOOL finished) {
		[transitionContext completeTransition:YES];
	}];
}

- (void)_animateDismissTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
	
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
	_interactiveTransitionContext = transitionContext;
	
	UIView *containerView = [transitionContext containerView];
	_interactiveFromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	_interactiveToViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	[containerView addSubview:_interactiveToViewController.view];
	[containerView bringSubviewToFront:_interactiveFromViewController.view];
	
	CGFloat offset = CGRectGetWidth(containerView.bounds);
	_toFinalFrame = [transitionContext finalFrameForViewController:_interactiveToViewController];
	_toStartFrame = CGRectOffset(_toFinalFrame, -offset + 100.0, 0.0);
	_interactiveToViewController.view.frame = _toStartFrame;
	
	_fromStartFrame = _interactiveFromViewController.view.frame;
	_fromFinalFrame = CGRectOffset(_fromStartFrame, CGRectGetWidth(containerView.bounds), 0.0);

	_animator = [JLBAnimator new];
	
	JLBAnimation *fromAnimation = [JLBAnimation animationWithKeyPath:@"frame"];
	[fromAnimation addKeyFrame:[JLBAnimationKeyFrame keyFrameWithTime:0.0 value:[NSValue valueWithCGRect:_fromStartFrame]]];
	[fromAnimation addKeyFrame:[JLBAnimationKeyFrame keyFrameWithTime:1.0 value:[NSValue valueWithCGRect:_fromFinalFrame]]];
	[_animator addAnimation:fromAnimation withKey:@"pop slide" toView:_interactiveFromViewController.view];
	
	JLBAnimation *toAnimation = [JLBAnimation animationWithKeyPath:@"frame"];
	[toAnimation addKeyFrame:[JLBAnimationKeyFrame keyFrameWithTime:0.0 value:[NSValue valueWithCGRect:_toStartFrame]]];
	[toAnimation addKeyFrame:[JLBAnimationKeyFrame keyFrameWithTime:1.0 value:[NSValue valueWithCGRect:_toFinalFrame]]];
	[_animator addAnimation:toAnimation withKey:@"pop slide" toView:_interactiveToViewController.view];
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete
{
	_lastPercentComplete = MAX(MIN(percentComplete, 1.0), 0.0);
	[_animator updateAnimationTime:_lastPercentComplete];
}

- (void)finishInteractiveTransition
{
	[_animator runToTime:1.0 withDuration:(_transitionDuration * (1.0 -_lastPercentComplete)) completion:^(BOOL finished) {
		_interactiveToViewController.view.frame = _toFinalFrame;
		[_interactiveTransitionContext completeTransition:YES];
	}];
}

- (void)animationEnded:(BOOL) transitionCompleted
{
	_animator = nil;
}

- (void)cancelInteractiveTransition
{
	[_animator runToTime:0.0 withDuration:(_transitionDuration * _lastPercentComplete) completion:^(BOOL finished) {
		_interactiveToViewController.view.frame = _toFinalFrame;
		[_interactiveTransitionContext completeTransition:NO];
	}];
}

@end
