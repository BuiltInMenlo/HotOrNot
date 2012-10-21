//
//  HONPhotoViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.04.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HONPhotoViewController.h"
#import "UIImageView+WebCache.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"
#import "MBProgressHUD.h"

@interface HONPhotoViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSString *imgURL;
@property (nonatomic, strong) NSString *subjectTitle;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic) CGFloat lastScale;
@end

@implementation HONPhotoViewController

@synthesize imgURL = _imgURL;
@synthesize subjectTitle = _subjectTitle;
@synthesize lastScale = _lastScale;
@synthesize progressHUD = _progressHUD;

- (id)initWithImagePath:(NSString *)imageURL withTitle:(NSString *)title {
	if ((self = [super init])) {
		_imgURL = imageURL;
		_subjectTitle = title;
		self.view.backgroundColor = [UIColor whiteColor];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Loading Photo…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.graceTime = 2.0;
	_progressHUD.taskInProgress = YES;
	
	UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 45.0, kLargeW * 0.5, kLargeH * 0.5)];
	imgView.userInteractionEnabled = YES;
	[imgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", self.imgURL]] placeholderImage:nil options:0 success:^(UIImage *image, BOOL cached) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	} failure:nil];
	 
	[self.view addSubview:imgView];
	
//	UIImageView *tmpView = [[UIImageView alloc] initWithFrame:CGRectMake(50.0, 100.0, 100.0, 100.0)];
//	tmpView.image = [HONAppDelegate cropImage:[UIImage imageNamed:@"firstRun_image01.png"] toRect:CGRectMake(30.0, 30.0, 100.0, 100.0)];
//	[self.view addSubview:tmpView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:[NSString stringWithFormat:@"#%@", _subjectTitle]];
	[self.view addSubview:headerView];
		
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(261.0, 5.0, 54.0, 34.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive.png"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active.png"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:doneButton];
	
	
	UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(_goPinch:)];
	[imgView addGestureRecognizer:pinchRecognizer];
	
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_goPan:)];
	[imgView addGestureRecognizer:panRecognizer];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return (YES);
}




#pragma mark - Navigation
- (void)_goDone {
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Interaction
- (void)_goPinch:(UIPinchGestureRecognizer *)recognizer {
	
	
	if([recognizer state] == UIGestureRecognizerStateBegan) {
		// Reset the last scale, necessary if there are multiple objects with different scales
		_lastScale = [recognizer scale];
	}
	
	if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged) {
		CGFloat currentScale = [[[recognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
		
		// Constants to adjust the max/min values of zoom
		const CGFloat kMaxScale = 1.5;
		const CGFloat kMinScale = 0.85;
		const CGFloat kSpeed = 0.75;
		
		CGFloat newScale = 1 - (_lastScale - [recognizer scale]) * (kSpeed);
		newScale = MIN(newScale, kMaxScale / currentScale);
		newScale = MAX(newScale, kMinScale / currentScale);
		CGAffineTransform transform = CGAffineTransformScale([[recognizer view] transform], newScale, newScale);
		[recognizer view].transform = transform;
		
		_lastScale = [recognizer scale];  // Store the previous scale factor for the next pinch gesture call
	}



	//NSLog(@"%f", recognizer.scale);

//	//if (recognizer.view.transform.a >= 1.0 && recognizer.view.transform.a <= 2.0) {
//	recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
//	recognizer.scale = 1.0;
//	//}
//	
//	if (recognizer.state == UIGestureRecognizerStateEnded) {
//		if (recognizer.view.transform.a < 0.25) {
//			[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
//				CGAffineTransform transform = CGAffineTransformMake(0.25, 0.0, 0.0, 0.25, 0.0, 0.0);
//				recognizer.view.transform = CGAffineTransformRotate(transform, M_PI / 2);
//			} completion:nil];
//		}
//		
//		
//		if (recognizer.view.transform.a > 2.5) {
//			[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
//				CGAffineTransform transform = CGAffineTransformMake(2.5, 0.0, 0.0, 2.5, 0.0, 0.0);
//				recognizer.view.transform = CGAffineTransformRotate(transform, M_PI / 2);
//			} completion:nil];
//		}
//		
//		CGPoint finalPoint = recognizer.view.center;
//		if (recognizer.view.frame.size.width < self.view.bounds.size.width)
//			finalPoint.x = MIN(MAX(finalPoint.x, recognizer.view.frame.size.width * 0.5), self.view.bounds.size.width - (recognizer.view.frame.size.width * 0.5));
//		else
//			finalPoint.x = MAX(MIN(finalPoint.x, recognizer.view.frame.size.width * 0.5), self.view.bounds.size.width - (recognizer.view.frame.size.width * 0.5));
//		
//		if (recognizer.view.frame.size.height < self.view.bounds.size.height)
//			finalPoint.y = MIN(MAX(finalPoint.y, recognizer.view.frame.size.height * 0.5), self.view.bounds.size.height - (recognizer.view.frame.size.height * 0.5));
//		else
//			finalPoint.y = MAX(MIN(finalPoint.y, recognizer.view.frame.size.height * 0.5), self.view.bounds.size.height - (recognizer.view.frame.size.height * 0.5));
//		
//		[UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationCurveLinear animations:^{
//			recognizer.view.center = finalPoint;
//		} completion:nil];
//	}
//	
//	//CGFloat scale = MIN(MAX(recognizer.view.transform.a, 1.0), 2.0);
//	NSLog(@"(%f, %f)", recognizer.view.transform.a, recognizer.view.transform.a);
}


- (void)_goPan:(UIPanGestureRecognizer *)recognizer {
	UIView *myView = [recognizer view];
	CGPoint translate = [recognizer translationInView:[myView superview]];
	
	if ([recognizer state] == UIGestureRecognizerStateChanged || [recognizer state] == UIGestureRecognizerStateChanged) {
		[myView setCenter:CGPointMake(myView.center.x + translate.x, myView.center.y + translate.y)];
		[recognizer setTranslation:CGPointZero inView:[myView superview]];
	}
	
//	CGPoint translation = [recognizer translationInView:self.view];
//	recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
//	[recognizer setTranslation:CGPointMake(0.0, 0.0) inView:self.view];
//	
//	
//	if (recognizer.state == UIGestureRecognizerStateEnded) {
//		CGPoint velocity = [recognizer velocityInView:self.view];
//		float slideFactor = 0.2 * (sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y)) * 0.005);
//		
//		CGPoint finalPoint = CGPointMake(recognizer.view.center.x + (velocity.x * slideFactor), recognizer.view.center.y + (velocity.y * slideFactor));
//		if (recognizer.view.frame.size.width < self.view.bounds.size.width)
//			finalPoint.x = MIN(MAX(finalPoint.x, recognizer.view.frame.size.width * 0.5), self.view.bounds.size.width - (recognizer.view.frame.size.width * 0.5));
//		else
//			finalPoint.x = MAX(MIN(finalPoint.x, recognizer.view.frame.size.width * 0.5), self.view.bounds.size.width - (recognizer.view.frame.size.width * 0.5));
//		
//		if (recognizer.view.frame.size.height < self.view.bounds.size.height)
//			finalPoint.y = self.view.center.y;//MIN(MAX(finalPoint.y, recognizer.view.frame.size.height * 0.5), self.view.bounds.size.height - (recognizer.view.frame.size.height * 0.5));
//		else
//			finalPoint.y = MAX(MIN(finalPoint.y, recognizer.view.frame.size.height * 0.5), self.view.bounds.size.height - (recognizer.view.frame.size.height * 0.5));
//		
//		[UIView animateWithDuration:slideFactor delay:0 options:UIViewAnimationCurveLinear animations:^{
//			recognizer.view.center = finalPoint;
//		} completion:nil];
//	}
}


@end
