//
//  HONAvatarCameraOverlayView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.19.13 @ 09:23 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "HONAvatarCameraOverlayView.h"
#import "HONImagingDepictor.h"

@interface HONAvatarCameraOverlayView () <UIAlertViewDelegate>
@property (nonatomic, strong) UIImageView *irisImageView;
@property (nonatomic, strong) UIView *controlsHolderView;
@property (nonatomic, strong) UIView *previewHolderView;
@property (nonatomic, strong) UIImageView *infoHolderImageView;
@property (nonatomic, strong) UIImageView *circleFillImageView;
@end

@implementation HONAvatarCameraOverlayView

@synthesize delegate = _delegate;


#pragma mark - View Lifecycle
- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_previewHolderView = [[UIView alloc] initWithFrame:self.frame];
		[self addSubview:_previewHolderView];
		
		_irisImageView = [[UIImageView alloc] initWithFrame:self.frame];
		_irisImageView.image = [UIImage imageNamed:@"cameraViewShutter"];
		_irisImageView.alpha = 0.0;
		//[self addSubview:_irisImageView];
		
		//hide overlay - [self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"OverlayCoverCamera-568h@2x" : @"OverlayCoverCamera"]]];
		
		_controlsHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.frame.size.height * 2.0)];
		[self addSubview:_controlsHolderView];
		
		UIImageView *captionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, (self.frame.size.height - 12.0) * 0.5, 320.0, 24.0)];
		captionImageView.image = [UIImage imageNamed:@"takePhotoOverlay"];
		//[_controlsHolderView addSubview:captionImageView];
		
//		float offset = ([HONAppDelegate isRetina5]) ? 469.0 : 389.0;
		UIButton *cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraRollButton.frame = CGRectMake(15.0, 267.0, 64.0, 44.0);
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive"] forState:UIControlStateNormal];
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active"] forState:UIControlStateHighlighted];
		[cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
//		[_controlsHolderView addSubview:cameraRollButton];
		
		_circleFillImageView = [[UIImageView alloc] initWithFrame:CGRectMake(96.0, self.frame.size.height - 150.0, 128.0, 128.0)];
		_circleFillImageView.image = [UIImage imageNamed:@"cameraAnimation_001"];
		[_controlsHolderView addSubview:_circleFillImageView];
		
		UIButton *captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
		captureButton.frame = CGRectMake(123.0, [UIScreen mainScreen].bounds.size.height - 100.0, 74.0, 74.0);
		//captureButton.frame = CGRectMake(128.0, offset, 64.0, 64.0);
		[captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_nonActive"] forState:UIControlStateNormal];
		[captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_Active"] forState:UIControlStateHighlighted];
		[captureButton addTarget:self action:@selector(_goCapture) forControlEvents:UIControlEventTouchUpInside];
		//[_controlsHolderView addSubview:captureButton];
		
		_infoHolderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"whySelfie-568h@2x" : @"whySelfie"]];
		_infoHolderImageView.frame = [UIScreen mainScreen].bounds;
		_infoHolderImageView.userInteractionEnabled = YES;
		[self addSubview:_infoHolderImageView];
		
		UIButton *okInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
		okInfoButton.frame = _infoHolderImageView.frame;
		[okInfoButton addTarget:self action:@selector(_goOKInfo) forControlEvents:UIControlEventTouchUpInside];
		[_infoHolderImageView addSubview:okInfoButton];
		
		UIView *submitHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height + (([UIScreen mainScreen].bounds.size.height - 64.0) * 0.5), 320.0, 64.0)];
		[_controlsHolderView addSubview:submitHolderView];
		
		UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
		submitButton.frame = CGRectMake(0.0, 0.0, 105.0, 64.0);
		[submitButton setBackgroundImage:[UIImage imageNamed:@"findalSubmitButton_nonActive"] forState:UIControlStateNormal];
		[submitButton setBackgroundImage:[UIImage imageNamed:@"findalSubmitButton_Active"] forState:UIControlStateHighlighted];
		[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
		[submitHolderView addSubview:submitButton];
		
		UIButton *retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		retakeButton.frame = CGRectMake(108.0, 0.0, 105.0, 64.0);
		[retakeButton setBackgroundImage:[UIImage imageNamed:@"retakeButton_nonActive"] forState:UIControlStateNormal];
		[retakeButton setBackgroundImage:[UIImage imageNamed:@"retakeButton_Active"] forState:UIControlStateHighlighted];
		[retakeButton addTarget:self action:@selector(_goCameraBack) forControlEvents:UIControlEventTouchUpInside];
		[submitHolderView addSubview:retakeButton];
		
		UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		skipButton.frame = CGRectMake(215.0, 0.0, 105.0, 64.0);
		[skipButton setBackgroundImage:[UIImage imageNamed:@"doNotUseButton_nonActive"] forState:UIControlStateNormal];
		[skipButton setBackgroundImage:[UIImage imageNamed:@"doNotUseButton_Active"] forState:UIControlStateHighlighted];
		[skipButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		[submitHolderView addSubview:skipButton];

	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goOKInfo {
	[UIView animateWithDuration:0.25 animations:^(void){
		_infoHolderImageView.alpha = 0.0;
	}];
	
	[[Mixpanel sharedInstance] track:@"Register - OK Selfie"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self.delegate cameraOverlayViewStartClock:self];
}

- (void)_goCancel {
	[[Mixpanel sharedInstance] track:@"Register - Skip Photo"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:@"Not having a selfie can make you look fake! Please update your profile soon in your profile section.!"
													   delegate:self
											  cancelButtonTitle:@"Skip"
											  otherButtonTitles:@"Take Photo", nil];
	[alertView setTag:0];
	[alertView show];
}

- (void)_goSubmit {
	[self.delegate cameraOverlayViewSubmit:self];
}

- (void)_goCapture {
	[self _animateShutter];
	[self.delegate cameraOverlayViewTakePicture:self];
}

- (void)_goChangeCamera {
	[self.delegate cameraOverlayViewChangeCamera:self];
}

- (void)_goCameraRoll {
	[self.delegate cameraOverlayViewShowCameraRoll:self];
}

- (void)_goCameraBack {
	[self hidePreview];
	[self.delegate cameraOverlayViewRetake:self];
}


#pragma mark - UI Presentation
- (void)showPreview:(UIImage *)image {
	image = [HONImagingDepictor scaleImage:image toSize:CGSizeMake(480.0, 640.0)];
	UIImage *scaledImage = [UIImage imageWithCGImage:image.CGImage scale:1.5 orientation:UIImageOrientationUp];
	UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:scaledImage.CGImage scale:1.5 orientation:UIImageOrientationUp]];
	[_previewHolderView addSubview:imgView];
	_previewHolderView.hidden = NO;
	
	if ([HONAppDelegate isRetina5]) {
		CGRect frame = CGRectMake(-18.0, 0.0, 355.0, 475.0);
		imgView.frame = frame;
	}
}

- (void)showPreviewAsFlipped:(UIImage *)image {
	image = [HONImagingDepictor scaleImage:image byFactor:([HONAppDelegate isRetina5]) ? 0.55f : 0.83f];
	//image = [HONImagingDepictor scaleImage:image toSize:CGSizeMake(480.0, 640.0)];
	UIImageView *previewImageView = [[UIImageView alloc] initWithImage:image];
	previewImageView.frame = CGRectOffset(previewImageView.frame, ABS(self.frame.size.width - image.size.width) * -0.5, -24.0 + ([HONAppDelegate isRetina5] * -22.0) + (ABS(self.frame.size.height - image.size.height) * -0.5) - [[UIApplication sharedApplication] statusBarFrame].size.height);
	previewImageView.transform = CGAffineTransformScale(previewImageView.transform, -1.0f, 1.0f);
	[_previewHolderView addSubview:previewImageView];
	_previewHolderView.hidden = NO;
}

- (void)hidePreview {
	_previewHolderView.hidden = YES;
	for (UIView *subview in _previewHolderView.subviews)
		[subview removeFromSuperview];
	
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
		_controlsHolderView.frame = CGRectOffset(_controlsHolderView.frame, 0.0, [UIScreen mainScreen].bounds.size.height);
	} completion:nil];
}

- (void)animateSubmit {
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		_controlsHolderView.frame = CGRectOffset(_controlsHolderView.frame, 0.0, -[UIScreen mainScreen].bounds.size.height);
	} completion:^(BOOL finished) {
	}];
}

- (void)_animateShutter {
	_irisImageView.alpha = 1.0;
	[UIView animateWithDuration:0.33 animations:^(void) {
		_irisImageView.alpha = 0.0;
	} completion:^(BOOL finished){}];
}

- (void)updateClock:(int)tick {
	//NSLog(@"IMG:[cameraAnimation_%03d]", tick);
	_circleFillImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"cameraAnimation_%03d", tick]];
}

#pragma mark - AlertView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		switch(buttonIndex) {
			case 0:
				[[Mixpanel sharedInstance] track:@"Register - Skip Photo Confirm"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				[[Mixpanel sharedInstance] track:@"cancel alert button (first run)"
									  properties:[NSDictionary dictionaryWithObjectsAndKeys:
												  @"organic", @"user_type",
												  [[HONAppDelegate infoForUser] objectForKey:@"name"], @"username", nil]];
				
				[self.delegate cameraOverlayViewCloseCamera:self];
				break;
				
			case 1:
				[[Mixpanel sharedInstance] track:@"Register - Skip Photo Cancel"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				[[Mixpanel sharedInstance] track:@"cancel alert button Cancel (first run)"
									  properties:[NSDictionary dictionaryWithObjectsAndKeys:
												  @"organic", @"user_type",
												  [[HONAppDelegate infoForUser] objectForKey:@"name"], @"username", nil]];
				break;
		}
	}
}
@end
