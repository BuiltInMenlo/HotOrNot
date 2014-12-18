//
//  HONViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 07/26/2014 @ 17:40 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONViewController.h"


@interface HONViewController ()
@end


@implementation HONViewController
@synthesize isPresentedAsModal = _isPresentedAsModal;

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeUnknown;
		_viewStateType = HONStateMitigatorViewStateTypeUnknown;
		
		_className = (NSString *)self.class;
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	_panGestureRecognizer.delegate = nil;
}

- (BOOL)shouldAutorotate {
	return (NO);
}


#pragma mark - Static APIs
+ (NSString *)className {
	return ((NSString *)self.class);
}


#pragma mark - Public APIs
- (void)destroy {
	_panGestureRecognizer.delegate = nil;
}


#pragma mark - Data Calls
#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	self.edgesForExtendedLayout = UIRectEdgeNone;
//	self.automaticallyAdjustsScrollViewInsets = NO;
	
	_panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_goPanGesture:)];
	_panGestureRecognizer.minimumNumberOfTouches = 1;
	_panGestureRecognizer.maximumNumberOfTouches = UINT_MAX;
	_panGestureRecognizer.cancelsTouchesInView = YES;
	_panGestureRecognizer.delaysTouchesBegan = YES;
	_panGestureRecognizer.delaysTouchesEnded = NO;
	_panGestureRecognizer.delegate = self;
	_panGestureRecognizer.enabled = NO;
	[self.view addGestureRecognizer:_panGestureRecognizer];
	
	[[HONStateMitigator sharedInstance] incrementTotalCounterForType:_totalType];
	NSLog(@"[:|:] [%@]:[%@]-=(%d)=-", self.class, [[HONStateMitigator sharedInstance] _keyForTotalType:_totalType], [[HONStateMitigator sharedInstance] totalCounterForType:_totalType]);
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewWillAppear:animated];
	
	_isPushing = NO;
	
	_sireViewController = (UIViewController *)[self.navigationController.viewControllers firstObject];
	_currentViewController = (UIViewController *)[self.navigationController.viewControllers lastObject];
	_presentedNavigationController = (UINavigationController *)self.presentedViewController;
	_presentedViewController = (UIViewController *)[_presentedNavigationController.viewControllers lastObject];
	
//	NSLog(@"\n\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=||=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]");
//	NSLog(@"\nself.navigationController.VCs:[%@]\n_sireVC:[%@]\ncurrentVC:[%@]", self.navigationController.viewControllers, _sireViewController, _currentViewController);
//	NSLog(@"\nnavigationController.VCs:[%@]\npresentedVC:[%@]", _presentedNavigationController.viewControllers, _presentedViewController);
//	NSLog(@"[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=||=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n\n");
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewDidAppear:animated];
	
	[[HONStateMitigator sharedInstance] updateCurrentViewState:_viewStateType];
}

- (void)viewWillDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillDisappear:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewWillDisappear:animated];
	
	_nextViewController = (UIViewController *)[self.navigationController.viewControllers lastObject];
//	NSLog(@"\n\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=||=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]");
//	NSLog(@"\n_nextViewController:[%@]\nselfVC:[%@]", _nextViewController.class, self.class);
//	NSLog(@"\n\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=||=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]");
}

- (void)viewDidDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidDisappear:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
//	NSLog(@"[:|:] [%@]_goPanGesture:[%@]-=(%@)=-", self.class, NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	
	if (gestureRecognizer.state != UIGestureRecognizerStateBegan && gestureRecognizer.state != UIGestureRecognizerStateCancelled && gestureRecognizer.state != UIGestureRecognizerStateEnded)
		return;
}


@end
