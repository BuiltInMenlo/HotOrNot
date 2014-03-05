//
//  JLBPagedViewController.m
//  NavigationTest
//
//  Created by Jesse Boley on 2/27/14.
//  Copyright (c) 2014 Jesse Boley. All rights reserved.
//

#import "JLBPagedViewController.h"
#import "JLBPagedView.h"

//#import "JLBPopSlideTransition.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

@interface JLBPagedViewPopGesture : UIGestureRecognizer
@property(nonatomic, readonly) CGPoint translation;
@end

@interface JLBPagedViewController () <JLBPagedViewControllerDataSource, UIScrollViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation JLBPagedViewController
{
	JLBPagedViewPopGesture *_interactiveDismissGesture;
	BOOL _isDismissing;
}

- (id)init
{
	if ((self = [super init])) {
		self.automaticallyAdjustsScrollViewInsets = NO;
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_pagedScrollView = [[JLBPagedView alloc] initWithFrame:self.view.bounds];
	_pagedScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_pagedScrollView.dataSource = self;
	_pagedScrollView.delegate = self;
	[self.view addSubview:_pagedScrollView];
	
	_interactiveDismissGesture = [[JLBPagedViewPopGesture alloc] initWithTarget:self action:@selector(_interactiveDismiss:)];
	_interactiveDismissGesture.delegate = self;
	[self.view addGestureRecognizer:_interactiveDismissGesture];
}

#pragma mark - JLBPagedViewDataSource

- (NSUInteger)numberOfItemsForPagedView:(JLBPagedView *)pagedView
{
	NSAssert(NO, @"Subclasses should implement -numberOfItemsForPagedView:");
	return 0;
}

- (id)pagedView:(JLBPagedView *)pagedView itemAtIndex:(NSUInteger)index
{
	NSAssert(NO, @"Subclasses should implement -pagedView:itemAtIndex:");
	return nil;
}

- (id)pagedView:(JLBPagedView *)pagedView viewControllerForItem:(id)item atIndex:(NSUInteger)index
{
	NSAssert(NO, @"Subclasses should implement -pagedView:viewControllerForItem:atIndex:");
	return nil;
}

#pragma mark - Interactive Pop Gesture

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	BOOL atFirstPage = ([_pagedScrollView currentPageIndex] == 0);
	_pagedScrollView.bounces = !atFirstPage;
	_interactiveDismissGesture.enabled = atFirstPage;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gesture
{
	BOOL result = YES;
	if (gesture == _interactiveDismissGesture) {
		result = [[self transitioningDelegate] conformsToProtocol:@protocol(UIViewControllerInteractiveTransitioning)];
	}
	return result;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	if ((gestureRecognizer == _interactiveDismissGesture) && (otherGestureRecognizer == _pagedScrollView.panGestureRecognizer))
		return YES;
	
	return NO;
}

- (id<UIViewControllerContextTransitioning>)_popTransition
{
	return (id<UIViewControllerContextTransitioning>)self.transitioningDelegate;
}

- (void)_interactiveDismiss:(UIGestureRecognizer *)gesture
{
	switch (_interactiveDismissGesture.state) {
		case UIGestureRecognizerStateBegan: {
			_pagedScrollView.scrollEnabled = NO;
			[self dismissViewControllerAnimated:YES completion:nil];
			break;
		}
			
		case UIGestureRecognizerStateChanged: {
			CGFloat offset = _interactiveDismissGesture.translation.x;
			CGFloat progress = offset / 320.0;
			[[self _popTransition] updateInteractiveTransition:progress];
			break;
		}
			
		case UIGestureRecognizerStateEnded: {
			CGFloat offset = _interactiveDismissGesture.translation.x;
			CGFloat progress = offset / 320.0;
			if (progress > 0.4) {
				[[self _popTransition] finishInteractiveTransition];
			}
			else {
				[[self _popTransition] cancelInteractiveTransition];
			}
			break;
		}
			
		case UIGestureRecognizerStateCancelled:
			[[self _popTransition] cancelInteractiveTransition];
			break;
			
		case UIGestureRecognizerStateFailed:
		case UIGestureRecognizerStatePossible:
			break;
	}
}

@end

@implementation JLBPagedViewPopGesture
{
	UITouch *_activeTouch;
	CGPoint _startPoint;
	CGPoint _lastPoint;
}

- (CGPoint)translation
{
	return CGPointMake(_lastPoint.x - _startPoint.x, _lastPoint.y - _startPoint.y);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	
	if ((_activeTouch != nil) || ([touches count] > 1)) {
		if (self.state == UIGestureRecognizerStatePossible) {
			self.state = UIGestureRecognizerStateFailed;
		}
		else {
			for (UITouch *touch in touches)
				[self ignoreTouch:touch forEvent:event];
		}
	}
	else {
		_activeTouch = [touches anyObject];
		_startPoint = [self locationInView:self.view.window];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];

	_lastPoint = [self locationInView:self.view.window];
	CGPoint translation = self.translation;
	if ((self.state != UIGestureRecognizerStateBegan) && (self.state != UIGestureRecognizerStateChanged)) {
		if (fabsf(translation.y) > 9.0) { // Fail if the touch starts moving up or down
			self.state = UIGestureRecognizerStateFailed;
		}
		else if (translation.x < -9.0) { // Fail if the touch starts moving left (away from the first page)
			self.state = UIGestureRecognizerStateFailed;
		}
		else if (translation.x > 9.0) {
			if (self.state == UIGestureRecognizerStatePossible)
				self.state = UIGestureRecognizerStateBegan;
		}
	}
	else {
		self.state = UIGestureRecognizerStateChanged;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	
	self.state = UIGestureRecognizerStateEnded;
	_activeTouch = nil;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
	
	self.state = UIGestureRecognizerStateCancelled;
	_activeTouch = nil;
}

- (void)reset
{
	[super reset];
	
	_startPoint = CGPointZero;
	_lastPoint = CGPointZero;
	_activeTouch = nil;
}

@end
