//
//  HONAvatarCameraOverlayView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.19.13 @ 09:23 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HONAvatarCameraOverlayView.h"
#import "HONDeviceTraits.h"
#import "HONImagingDepictor.h"
#import "HONImageLoadingView.h"

@interface HONAvatarCameraOverlayView () <UIAlertViewDelegate>
@property (nonatomic, strong) UIView *irisView;
@property (nonatomic, strong) UIView *tintedMatteView;
@property (nonatomic, strong) UIView *submitHolderView;
@property (nonatomic, strong) UIView *previewHolderView;
@property (nonatomic, strong) UIButton *changeTintButton;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIImageView *infoHolderImageView;
@property (nonatomic, strong) HONImageLoadingView *imageLoadingView;
@property (nonatomic, strong) UIView *blackMatteView;
@property (nonatomic) int tintIndex;
@end

@implementation HONAvatarCameraOverlayView

@synthesize delegate = _delegate;


#pragma mark - View Lifecycle
- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_tintIndex = 0;
		
		_previewHolderView = [[UIView alloc] initWithFrame:self.frame];
		[self addSubview:_previewHolderView];
		
		[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headerFadeBackground"]]];
		
		_irisView = [[UIImageView alloc] initWithFrame:self.frame];
		_irisView.backgroundColor = [UIColor blackColor];
		_irisView.alpha = 0.0;
		[self addSubview:_irisView];
		
		_tintedMatteView = [[UIView alloc] initWithFrame:self.frame];
		_tintedMatteView.backgroundColor = [[HONAppDelegate colorsForOverlayTints] objectAtIndex:_tintIndex];
		[self addSubview:_tintedMatteView];
		
		UIView *headerBGView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)];
		headerBGView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
		[self addSubview:headerBGView];
		
		UIButton *flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		flipButton.frame = CGRectMake(3.0, 3.0, 44.0, 44.0);
		[flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_nonActive"] forState:UIControlStateNormal];
		[flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_Active"] forState:UIControlStateHighlighted];
		[flipButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
		[headerBGView addSubview:flipButton];
		
		UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cancelButton.frame = CGRectMake(250.0, 3.0, 64.0, 44.0);
		[cancelButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
		[cancelButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
		[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		[headerBGView addSubview:cancelButton];
		
		UIView *gutterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 141.0, 320.0, 141.0)];
		gutterView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
		[self addSubview:gutterView];
		
		_changeTintButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_changeTintButton.frame = CGRectMake(-5.0, [UIScreen mainScreen].bounds.size.height - 60.0, 64.0, 64.0);
		[_changeTintButton setBackgroundImage:[UIImage imageNamed:@"filterIcon_nonActive"] forState:UIControlStateNormal];
		[_changeTintButton setBackgroundImage:[UIImage imageNamed:@"filterIcon_Active"] forState:UIControlStateHighlighted];
		[_changeTintButton addTarget:self action:@selector(_goChangeTint) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_changeTintButton];
		
		_captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_captureButton.frame = CGRectMake(113.0, [UIScreen mainScreen].bounds.size.height - 118.0, 94.0, 94.0);
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"profileCameraButton_nonActive"] forState:UIControlStateNormal];
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"profileCameraButton_Active"] forState:UIControlStateHighlighted];
		[_captureButton addTarget:self action:@selector(_goTakePhoto) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_captureButton];
		
		UIButton *cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraRollButton.frame = CGRectMake(249.0, [UIScreen mainScreen].bounds.size.height - 42.0, 64.0, 44.0);
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive"] forState:UIControlStateNormal];
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active"] forState:UIControlStateHighlighted];
		[cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:cameraRollButton];
		
		_submitHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height, 320.0, 64.0)];
		[self addSubview:_submitHolderView];
		
		UIButton *retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		retakeButton.frame = CGRectMake(0.0, 0.0, 106.0, 64.0);
		[retakeButton setBackgroundImage:[UIImage imageNamed:@"retakeAvatarButton_nonActive"] forState:UIControlStateNormal];
		[retakeButton setBackgroundImage:[UIImage imageNamed:@"retakeAvatarButton_Active"] forState:UIControlStateHighlighted];
		[retakeButton addTarget:self action:@selector(_goCameraBack) forControlEvents:UIControlEventTouchUpInside];
		[_submitHolderView addSubview:retakeButton];
		
		UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		skipButton.frame = CGRectMake(106.0, 0.0, 106.0, 64.0);
		[skipButton setBackgroundImage:[UIImage imageNamed:@"doNotUseButton_nonActive"] forState:UIControlStateNormal];
		[skipButton setBackgroundImage:[UIImage imageNamed:@"doNotUseButton_Active"] forState:UIControlStateHighlighted];
		[skipButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		[_submitHolderView addSubview:skipButton];
		
		UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
		submitButton.frame = CGRectMake(256.0, 0.0, 64.0, 64.0);
		[submitButton setBackgroundImage:[UIImage imageNamed:@"avatarSendButton_nonActive"] forState:UIControlStateNormal];
		[submitButton setBackgroundImage:[UIImage imageNamed:@"avatarSendButton_Active"] forState:UIControlStateHighlighted];
		[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
		[_submitHolderView addSubview:submitButton];
		
		_blackMatteView = [[UIView alloc] initWithFrame:self.frame];
		_blackMatteView.backgroundColor = [UIColor blackColor];
		_blackMatteView.alpha = 0.0;
		[self addSubview:_blackMatteView];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)addPreview:(UIImage *)image {
	image = [HONImagingDepictor scaleImage:image toSize:CGSizeMake(480.0, 640.0)];
	UIImage *scaledImage = [UIImage imageWithCGImage:image.CGImage scale:1.5 orientation:UIImageOrientationUp];
	UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:scaledImage.CGImage scale:1.5 orientation:UIImageOrientationUp]];
	[_previewHolderView addSubview:imgView];
	_previewHolderView.hidden = NO;
	
	if ([[HONDeviceTraits sharedInstance] isRetina4Inch]) {
		CGRect frame = CGRectMake(-18.0, 0.0, 355.0, 475.0);
		imgView.frame = frame;
	}
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blackMatteView.alpha = 0.0;
	} completion:^(BOOL finished) {
		_blackMatteView.hidden = YES;
	}];
}

- (void)addPreviewAsFlipped:(UIImage *)image {
	image = [HONImagingDepictor scaleImage:image byFactor:([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? 0.55f : 0.83333f];
	
	UIImageView *previewImageView = [[UIImageView alloc] initWithImage:image];
	previewImageView.frame = CGRectOffset(previewImageView.frame, ABS(self.frame.size.width - image.size.width) * -0.5, (-26.0 + (ABS(self.frame.size.height - image.size.height) * -0.5)) + (-26.0 * [[HONDeviceTraits sharedInstance] isRetina4Inch]));
	previewImageView.transform = CGAffineTransformScale(previewImageView.transform, -1.0f, 1.0f);
	[_previewHolderView addSubview:previewImageView];
	_previewHolderView.hidden = NO;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blackMatteView.alpha = 0.0;
	} completion:^(BOOL finished) {
		_blackMatteView.hidden = YES;
	}];
}

- (void)removePreview {
	_previewHolderView.hidden = YES;
	for (UIView *subview in _previewHolderView.subviews)
		[subview removeFromSuperview];
	
	[UIView animateWithDuration:0.125 animations:^(void) {
		_submitHolderView.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height, 320.0, 64.0);
	}];
}

- (void)uploadComplete {
}

- (void)animateAccept {
	[UIView animateWithDuration:0.125 animations:^(void) {
		_submitHolderView.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 64.0, 320.0, 64.0);
	}];
}

- (void)resetControls {
	[self removePreview];
	
	_captureButton.hidden = NO;
}


#pragma mark - Navigation
- (void)_goOKInfo {
	[UIView animateWithDuration:0.25 animations:^(void){
		_infoHolderImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[_infoHolderImageView removeFromSuperview];
	}];
}

- (void)_goTakePhoto {
	_captureButton.hidden = YES;
	
	_blackMatteView.hidden = NO;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_blackMatteView.alpha = 1.0;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_blackMatteView.alpha = 0.0;
		}];
	}];
	
	[self.delegate cameraOverlayViewTakePicture:self withTintIndex:_tintIndex];
}

- (void)_goCancel {
	[[Mixpanel sharedInstance] track:@"Change Avatar - Skip Photo"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:[NSString stringWithFormat:@"Your profile photo helps the %@ community know your real.",[HONAppDelegate brandedAppName]]
													   delegate:self
											  cancelButtonTitle:@"No Thanks"
											  otherButtonTitles:@"Take Photo", nil];
	[alertView setTag:0];
	[alertView show];
}

- (void)_goSubmit {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blackMatteView.alpha = 0.65;
	} completion:^(BOOL finished) {
		_submitHolderView.hidden = YES;
		[self.delegate cameraOverlayViewSubmit:self];
	}];
}

- (void)_goFlipCamera {
	[self.delegate cameraOverlayViewChangeCamera:self];
}

- (void)_goCameraRoll {
	[self.delegate cameraOverlayViewShowCameraRoll:self];
}

- (void)_goCameraBack {
	[self removePreview];
	
	_captureButton.hidden = NO;
	[self.delegate cameraOverlayViewRetake:self];
}

- (void)_goChangeTint {
	[[Mixpanel sharedInstance] track:@"Create Volley - Change Tint Overlay"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	_tintIndex = ++_tintIndex % [[HONAppDelegate colorsForOverlayTints] count];
	
	[UIView beginAnimations:@"fade" context:nil];
	[UIView setAnimationDuration:0.33];
	[_tintedMatteView setBackgroundColor:[[HONAppDelegate colorsForOverlayTints] objectAtIndex:_tintIndex]];
	[UIView commitAnimations];
}



#pragma mark - UI Presentation
- (void)_verifyOverlay:(BOOL)isIntro {
	if (isIntro) {
		_imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:[[UIApplication sharedApplication] delegate].window asLargeLoader:YES];
		_imageLoadingView.alpha = 0.0;
		[self addSubview:_imageLoadingView];
		
//		_verifyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(81.0, ([UIScreen mainScreen].bounds.size.height - 124.0) * 0.5, 150.0, 124.0)];
//		_verifyImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"overlayLoader001"],
//											[UIImage imageNamed:@"overlayLoader002"],
//											[UIImage imageNamed:@"overlayLoader003"], nil];
//		_verifyImageView.animationDuration = 0.5f;
//		_verifyImageView.animationRepeatCount = 0;
//		_verifyImageView.alpha = 0.0;
//		[_verifyImageView startAnimating];
//		[self addSubview:_verifyImageView];
		
//		[UIView animateWithDuration:0.25 animations:^(void) {
//			_verifyImageView.alpha = 1.0;
//		} completion:nil];
		
	} else {
//		[UIView animateWithDuration:0.25 animations:^(void) {
//			_verifyImageView.alpha = 0.0;
//		} completion:nil];
	}
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_imageLoadingView.alpha = ((int)isIntro);
	} completion:nil];
}


#pragma mark - AlertView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		switch(buttonIndex) {
			case 0:
				[[Mixpanel sharedInstance] track:@"Change Avatar - Skip Photo Confirm"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
				
				[self.delegate cameraOverlayViewCloseCamera:self];
				break;
				
			case 1:
				[[Mixpanel sharedInstance] track:@"Change Avatar - Skip Photo Cancel"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
				
				[self _goCameraBack];
				break;
		}
	}
}
@end
