//
//  JLBPopSlideTransition.m
//
//  Created by Jesse Boley on 2/27/14.
//  Copyright (c) 2014 Jesse Boley. All rights reserved.
//

#import "JLBPopSlideTransition.h"
#import "JLBAnimator.h"

#import "UIView+HONSnapshot.h"

#import <objc/runtime.h>

static const void *kJLBTransitionPresentedControllerKey = &kJLBTransitionPresentedControllerKey;

@interface JLBPopSlideTransition ()
@end

@implementation JLBPopSlideTransition
{
	BOOL _isDismissed;
	CGFloat _lastPercentComplete;
	
	UIImageView *_originalBlurredImageView;
	
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
	
	// Generate a blur of the view that's going away
	UIImage *blurredFromImage = [fromViewController.view blurRect:fromViewController.view.bounds withRadius:30.0 andSaturationBoost:1.0 andOverlayColor:[UIColor colorWithWhite:0.0 alpha:0.35]];
	_originalBlurredImageView = [[UIImageView alloc] initWithImage:blurredFromImage];
	_originalBlurredImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_originalBlurredImageView.alpha = 0.0;
	_originalBlurredImageView.frame = fromViewController.view.bounds;
	[fromViewController.view addSubview:_originalBlurredImageView];
	
	// Add the appearing view controller to the transition container
	CGRect finalAppearingFrame = [transitionContext finalFrameForViewController:toViewController];
	toViewController.view.frame = CGRectOffset(finalAppearingFrame, CGRectGetWidth(containerView.bounds), 0.0);
	[containerView addSubview:toViewController.view];
	
	// Scale back the disappearing view and start to fade it out
	CGAffineTransform fromFinalTransform = CGAffineTransformMakeScale(0.92, 0.92);
	CGFloat fromFinalAlpha = 0.5;

	[UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
		toViewController.view.frame = finalAppearingFrame;
		fromViewController.view.transform = fromFinalTransform;
		fromViewController.view.alpha = fromFinalAlpha;
		_originalBlurredImageView.alpha = 1.0;
	} completion:^(BOOL finished) {
		[transitionContext completeTransition:YES];
		fromViewController.view.alpha = 1.0;
		[_originalBlurredImageView removeFromSuperview];
	}];
}

- (void)_animateDismissTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
	UIView *containerView = [transitionContext containerView];
	UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	
	// Prep the view we're going back to
	toViewController.view.transform = CGAffineTransformMakeScale(0.92, 0.92);
	toViewController.view.alpha = 0.5;
	[containerView insertSubview:toViewController.view atIndex:0];
	_originalBlurredImageView.frame = toViewController.view.bounds;
	[toViewController.view addSubview:_originalBlurredImageView];
	
	[UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
		toViewController.view.transform = CGAffineTransformIdentity;
		toViewController.view.alpha = 1.0;
		fromViewController.view.frame = CGRectOffset(fromViewController.view.frame, CGRectGetWidth(containerView.bounds), 0.0);
		_originalBlurredImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[transitionContext completeTransition:YES];
		[_originalBlurredImageView removeFromSuperview];
	}];
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
	_interactiveTransitionContext = transitionContext;
	
	UIView *containerView = [transitionContext containerView];
	_interactiveFromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	_interactiveToViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	[containerView addSubview:_interactiveToViewController.view];
	[containerView bringSubviewToFront:_interactiveFromViewController.view];
	
	_originalBlurredImageView.frame = _interactiveToViewController.view.bounds;
	[_interactiveToViewController.view addSubview:_originalBlurredImageView];
	
	_toFinalFrame = [transitionContext finalFrameForViewController:_interactiveToViewController];
	_toStartFrame = _toFinalFrame;
	_interactiveToViewController.view.frame = _toStartFrame;
	
	_fromStartFrame = _interactiveFromViewController.view.frame;
	_fromFinalFrame = CGRectOffset(_fromStartFrame, CGRectGetWidth(containerView.bounds), 0.0);

	_animator = [JLBAnimator new];
	
	JLBAnimation *fromAnimation = [JLBAnimation animationWithKeyPath:@"frame"];
	[fromAnimation addKeyFrame:[JLBAnimationKeyFrame keyFrameWithTime:0.0 value:[NSValue valueWithCGRect:_fromStartFrame]]];
	[fromAnimation addKeyFrame:[JLBAnimationKeyFrame keyFrameWithTime:1.0 value:[NSValue valueWithCGRect:_fromFinalFrame]]];
	[_animator addAnimation:fromAnimation withKey:@"pop slide" toView:_interactiveFromViewController.view];
	
	JLBAnimation *toFadeAnimation = [JLBAnimation animationWithKeyPath:@"alpha"];
	[toFadeAnimation addKeyFrame:[JLBAnimationKeyFrame keyFrameWithTime:0.0 value:@(0.5)]];
	[toFadeAnimation addKeyFrame:[JLBAnimationKeyFrame keyFrameWithTime:1.0 value:@(1.0)]];
	[_animator addAnimation:toFadeAnimation withKey:@"to fade" toView:_interactiveToViewController.view];
	
	JLBAnimation *blurFadeAnimation = [JLBAnimation animationWithKeyPath:@"alpha"];
	[blurFadeAnimation addKeyFrame:[JLBAnimationKeyFrame keyFrameWithTime:0.4 value:@(1.0)]];
	[blurFadeAnimation addKeyFrame:[JLBAnimationKeyFrame keyFrameWithTime:1.0 value:@(0.0)]];
	[_animator addAnimation:blurFadeAnimation withKey:@"blur fade out" toView:_originalBlurredImageView];
	
	JLBAnimation *toScaleAnimation = [JLBAnimation animationWithKeyPath:@"transform"];
	[toScaleAnimation addKeyFrame:[JLBAnimationKeyFrame keyFrameWithTime:0.0 value:[NSValue valueWithCGAffineTransform:CGAffineTransformMakeScale(0.92, 0.92)]]];
	[toScaleAnimation addKeyFrame:[JLBAnimationKeyFrame keyFrameWithTime:1.0 value:[NSValue valueWithCGAffineTransform:CGAffineTransformIdentity]]];
	[_animator addAnimation:toScaleAnimation withKey:@"to scale" toView:_interactiveToViewController.view];
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
