//
//  HONAvatarCameraOverlayView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.19.13 @ 09:23 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HONAvatarCameraOverlayView.h"
#import "HONImagingDepictor.h"

@interface HONAvatarCameraOverlayView () <UIAlertViewDelegate>
@property (nonatomic, strong) UILabel *actionLabel;
@property (nonatomic, strong) UIView *irisView;
@property (nonatomic, strong) UIView *submitHolderView;
@property (nonatomic, strong) UIView *previewHolderView;
@property (nonatomic, strong) UIImageView *infoHolderImageView;
@property (nonatomic, strong) UIImageView *progressBarImageView;
@property (nonatomic, strong) UIImageView *verifyImageView;
@property (nonatomic, strong) UIView *blackMatteView;
@property (nonatomic, strong) UILongPressGestureRecognizer *lpGestureRecognizer;
@end

@implementation HONAvatarCameraOverlayView

@synthesize delegate = _delegate;


#pragma mark - View Lifecycle
- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_previewHolderView = [[UIView alloc] initWithFrame:self.frame];
		[self addSubview:_previewHolderView];
		
		[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headerFadeBackground"]]];
		
		_irisView = [[UIImageView alloc] initWithFrame:self.frame];
		_irisView.backgroundColor = [UIColor blackColor];
		_irisView.alpha = 0.0;
		[self addSubview:_irisView];
		
		UIButton *cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraRollButton.frame = CGRectMake(15.0, 267.0, 64.0, 44.0);
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive"] forState:UIControlStateNormal];
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active"] forState:UIControlStateHighlighted];
		[cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
//		[_controlsHolderView addSubview:cameraRollButton];
				
//		UIButton *captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		captureButton.frame = CGRectMake(123.0, [UIScreen mainScreen].bounds.size.height - 100.0, 74.0, 74.0);
//		//captureButton.frame = CGRectMake(128.0, offset, 64.0, 64.0);
//		[captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_nonActive"] forState:UIControlStateNormal];
//		[captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_Active"] forState:UIControlStateHighlighted];
//		[captureButton addTarget:self action:@selector(_goCapture) forControlEvents:UIControlEventTouchUpInside];
//		//[_controlsHolderView addSubview:captureButton];
		
		_infoHolderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"whySelfie-568h@2x" : @"whySelfie"]];
		_infoHolderImageView.frame = [UIScreen mainScreen].bounds;
		_infoHolderImageView.userInteractionEnabled = YES;
		[self addSubview:_infoHolderImageView];
		
		UIButton *okInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
		okInfoButton.frame = _infoHolderImageView.frame;
		[okInfoButton addTarget:self action:@selector(_goOKInfo) forControlEvents:UIControlEventTouchUpInside];
		[_infoHolderImageView addSubview:okInfoButton];
		
		UIView *progressBarBGImageView = [[UIView alloc] initWithFrame:CGRectMake(10.0, [UIScreen mainScreen].bounds.size.height - 14.0, 300.0, 2.0)];
		progressBarBGImageView.backgroundColor = [UIColor blackColor];
		[self addSubview:progressBarBGImageView];
		
		_submitHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 64.0, 320.0, 64.0)];
		_submitHolderView.hidden = YES;
		[self addSubview:_submitHolderView];
		
		UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		skipButton.frame = CGRectMake(0.0, 0.0, 106.0, 64.0);
		[skipButton setBackgroundImage:[UIImage imageNamed:@"doNotUseButton_nonActive"] forState:UIControlStateNormal];
		[skipButton setBackgroundImage:[UIImage imageNamed:@"doNotUseButton_Active"] forState:UIControlStateHighlighted];
		[skipButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		[_submitHolderView addSubview:skipButton];
		
		UIButton *retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		retakeButton.frame = CGRectMake(106.0, 0.0, 106.0, 64.0);
		[retakeButton setBackgroundImage:[UIImage imageNamed:@"retakeButton_nonActive"] forState:UIControlStateNormal];
		[retakeButton setBackgroundImage:[UIImage imageNamed:@"retakeButton_Active"] forState:UIControlStateHighlighted];
		[retakeButton addTarget:self action:@selector(_goCameraBack) forControlEvents:UIControlEventTouchUpInside];
		[_submitHolderView addSubview:retakeButton];
		
		UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
		submitButton.frame = CGRectMake(212.0, 0.0, 107.0, 64.0);
		[submitButton setBackgroundImage:[UIImage imageNamed:@"findalSubmitButton_nonActive"] forState:UIControlStateNormal];
		[submitButton setBackgroundImage:[UIImage imageNamed:@"findalSubmitButton_Active"] forState:UIControlStateHighlighted];
		[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
		[_submitHolderView addSubview:submitButton];
		
		_actionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 16.0, 260.0, 20.0)];
		_actionLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17];
		_actionLabel.textColor = [UIColor whiteColor];
		_actionLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_actionLabel];
		
		_blackMatteView = [[UIView alloc] initWithFrame:self.frame];
		_blackMatteView.backgroundColor = [UIColor blackColor];
		_blackMatteView.alpha = 0.0;
		[self addSubview:_blackMatteView];
		
		_lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
		_lpGestureRecognizer.minimumPressDuration = 0.05;
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)startProgress {
	if (_progressBarImageView != nil) {
		[_progressBarImageView.layer removeAllAnimations];
		[_progressBarImageView removeFromSuperview];
		_progressBarImageView = nil;
	}
	
	_progressBarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, [UIScreen mainScreen].bounds.size.height - 14.0, 4.0, 2.0)];
	_progressBarImageView.image = [UIImage imageNamed:@"whiteLoader"];
	[self addSubview:_progressBarImageView];
	
	[self _animateLoader];
}

- (void)takePhoto {
	if (_progressBarImageView != nil) {
		[_progressBarImageView.layer removeAllAnimations];
		[_progressBarImageView removeFromSuperview];
		_progressBarImageView = nil;
	}
	
	[self removeGestureRecognizer:_lpGestureRecognizer];
	
	_irisView.alpha = 1.0;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_irisView.alpha = 0.33;
	} completion:^(BOOL finished){}];
}

- (void)addPreview:(UIImage *)image {
	image = [HONImagingDepictor scaleImage:image toSize:CGSizeMake(480.0, 640.0)];
	UIImage *scaledImage = [UIImage imageWithCGImage:image.CGImage scale:1.5 orientation:UIImageOrientationUp];
	UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:scaledImage.CGImage scale:1.5 orientation:UIImageOrientationUp]];
	[_previewHolderView addSubview:imgView];
	_previewHolderView.hidden = NO;
	
	_actionLabel.text = @"Approve your profile picture";
	if ([HONAppDelegate isRetina5]) {
		CGRect frame = CGRectMake(-18.0, 0.0, 355.0, 475.0);
		imgView.frame = frame;
	}
}

- (void)addPreviewAsFlipped:(UIImage *)image {
	image = [HONImagingDepictor scaleImage:image byFactor:([HONAppDelegate isRetina5]) ? 0.55f : 0.83f];
	//image = [HONImagingDepictor scaleImage:image toSize:CGSizeMake(480.0, 640.0)];
	UIImageView *previewImageView = [[UIImageView alloc] initWithImage:image];
	previewImageView.frame = CGRectOffset(previewImageView.frame, ABS(self.frame.size.width - image.size.width) * -0.5, -26.0 + ([HONAppDelegate isRetina5] * -22.0) + (ABS(self.frame.size.height - image.size.height) * -0.5) - [[UIApplication sharedApplication] statusBarFrame].size.height);
	previewImageView.transform = CGAffineTransformScale(previewImageView.transform, -1.0f, 1.0f);
	[_previewHolderView addSubview:previewImageView];
	_previewHolderView.hidden = NO;
	
	_actionLabel.text = @"Approve your profile picture";
}

- (void)removePreview {
	_previewHolderView.hidden = YES;
	for (UIView *subview in _previewHolderView.subviews)
		[subview removeFromSuperview];
	
	_submitHolderView.hidden = YES;
}

- (void)animateAccept {
	_submitHolderView.hidden = NO;
}

- (void)verifyOverlay:(BOOL)isIntro {
	if (isIntro) {
		_verifyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(81.0, ([UIScreen mainScreen].bounds.size.height - 124.0) * 0.5, 150.0, 124.0)];
		_verifyImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"overlayLoader001"],
											 [UIImage imageNamed:@"overlayLoader002"],
											 [UIImage imageNamed:@"overlayLoader003"], nil];
		_verifyImageView.animationDuration = 0.5f;
		_verifyImageView.animationRepeatCount = 0;
		_verifyImageView.alpha = 0.0;
		[_verifyImageView startAnimating];
		[self addSubview:_verifyImageView];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_verifyImageView.alpha = 1.0;
		} completion:nil];
		
	} else {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_verifyImageView.alpha = 0.0;
		} completion:nil];
	}
}



#pragma mark - Navigation
- (void)_goOKInfo {
	if (_progressBarImageView != nil) {
		[_progressBarImageView.layer removeAllAnimations];
		[_progressBarImageView removeFromSuperview];
		_progressBarImageView = nil;
	}
	
	[UIView animateWithDuration:0.25 animations:^(void){
		_infoHolderImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[_infoHolderImageView removeFromSuperview];
		
		[self addGestureRecognizer:_lpGestureRecognizer];
	}];
	
	[self.delegate cameraOverlayViewStartClock:self];
	_actionLabel.text = @"Taking profile photo…";
}

- (void)_goCancel {
	[[Mixpanel sharedInstance] track:@"Register - Skip Photo"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:@"Your profile photo helps the Volley community know your real."
													   delegate:self
											  cancelButtonTitle:@"No Thanks"
											  otherButtonTitles:@"Take Photo", nil];
	[alertView setTag:0];
	[alertView show];
}

- (void)_goSubmit {
	_actionLabel.text = @"";
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blackMatteView.alpha = 0.65;
	} completion:^(BOOL finished) {
		_submitHolderView.hidden = YES;
		[self.delegate cameraOverlayViewSubmit:self];
	}];
}

- (void)_goChangeCamera {
	[self.delegate cameraOverlayViewChangeCamera:self];
}

- (void)_goCameraRoll {
	[self.delegate cameraOverlayViewShowCameraRoll:self];
}

- (void)_goCameraBack {
	[self removePreview];
	
	_actionLabel.text = @"Taking profile photo…";
	
	[self addGestureRecognizer:_lpGestureRecognizer];
	[self.delegate cameraOverlayViewRetake:self];
}

-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	//CGPoint touchPoint = [lpGestureRecognizer locationInView:self];
	
	if (_progressBarImageView != nil) {
		[_progressBarImageView.layer removeAllAnimations];
		[_progressBarImageView removeFromSuperview];
		_progressBarImageView = nil;
	}
	
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		[self.delegate cameraOverlayView:self toggleLongPress:YES];
		
		_irisView.alpha = 0.0;
		[UIView animateWithDuration:0.125 animations:^(void) {
			_irisView.alpha = 0.35;
		} completion:^(BOOL finished){}];
		
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
		[self.delegate cameraOverlayView:self toggleLongPress:NO];
		
		[UIView animateWithDuration:0.125 animations:^(void) {
			_irisView.alpha = 0.0;
		} completion:^(BOOL finished){}];
	}
}


#pragma mark - UI Presentation
- (void)_animateLoader {
	_progressBarImageView.frame = CGRectMake(10.0, [UIScreen mainScreen].bounds.size.height - 14.0, 4.0, 2.0);
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.6];
	[UIView setAnimationDelay:0.0];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	_progressBarImageView.frame = CGRectMake(10.0, [UIScreen mainScreen].bounds.size.height - 14.0, 300.0, 2.0);
	[UIView commitAnimations];
}


#pragma mark - AlertView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		switch(buttonIndex) {
			case 0:
				[[Mixpanel sharedInstance] track:@"Register - Skip Photo Confirm"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				[self.delegate cameraOverlayViewCloseCamera:self];
				break;
				
			case 1:
				[[Mixpanel sharedInstance] track:@"Register - Skip Photo Cancel"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				break;
		}
	}
}
@end
