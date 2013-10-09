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
@property (nonatomic, strong) UIView *irisView;
@property (nonatomic, strong) UIView *submitHolderView;
@property (nonatomic, strong) UIView *previewHolderView;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIImageView *infoHolderImageView;
@property (nonatomic, strong) UIImageView *verifyImageView;
@property (nonatomic, strong) UIView *blackMatteView;
@property (nonatomic, strong) UIImageView *uploadingImageView;
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
		
		UIImageView *headerBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraBackgroundHeader"]];
		headerBGImageView.frame = CGRectOffset(headerBGImageView.frame, 0.0, -20.0);
		[self addSubview:headerBGImageView];
		
		UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cancelButton.frame = CGRectMake(253.0, 0.0, 64.0, 44.0);
		[cancelButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
		[cancelButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
		[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:cancelButton];
		
		UIButton *cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraRollButton.frame = CGRectMake(15.0, 267.0, 64.0, 44.0);
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive"] forState:UIControlStateNormal];
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active"] forState:UIControlStateHighlighted];
		[cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
//		[_controlsHolderView addSubview:cameraRollButton];
		
		UIView *gutterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 142.0, 320.0, 142.0)];
		gutterView.backgroundColor = [UIColor blackColor];
		[self addSubview:gutterView];
		
		_captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_captureButton.frame = CGRectMake(113.0, [UIScreen mainScreen].bounds.size.height - 133.0, 94.0, 94.0);
		//_captureButton.frame = CGRectMake(128.0, offset, 64.0, 64.0);
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_nonActive"] forState:UIControlStateNormal];
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_Active"] forState:UIControlStateHighlighted];
		[_captureButton addTarget:self action:@selector(_goTakePhoto) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_captureButton];
		
//		_infoHolderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"whySelfie-568h@2x" : @"whySelfie"]];
//		_infoHolderImageView.frame = [UIScreen mainScreen].bounds;
//		_infoHolderImageView.userInteractionEnabled = YES;
//		[self addSubview:_infoHolderImageView];
//		
//		UIButton *okInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		okInfoButton.frame = _infoHolderImageView.frame;
//		[okInfoButton addTarget:self action:@selector(_goOKInfo) forControlEvents:UIControlEventTouchUpInside];
//		[_infoHolderImageView addSubview:okInfoButton];
		
		_uploadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, 14.0, 54.0, 14.0)];
		_uploadingImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"cameraUpload_001"],
											   [UIImage imageNamed:@"cameraUpload_002"],
											   [UIImage imageNamed:@"cameraUpload_003"], nil];
		_uploadingImageView.animationDuration = 0.5f;
		_uploadingImageView.animationRepeatCount = 0;
		_uploadingImageView.alpha = 0.0;
//		[self addSubview:_uploadingImageView];
		
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
		[submitButton setBackgroundImage:[UIImage imageNamed:@"findalSubmitButton_nonActive"] forState:UIControlStateNormal];
		[submitButton setBackgroundImage:[UIImage imageNamed:@"findalSubmitButton_Active"] forState:UIControlStateHighlighted];
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
	
	if ([HONAppDelegate isRetina4Inch]) {
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
	image = [HONImagingDepictor scaleImage:image byFactor:([HONAppDelegate isRetina4Inch]) ? 0.55f : 0.83333f];
	
	UIImageView *previewImageView = [[UIImageView alloc] initWithImage:image];
	previewImageView.frame = CGRectOffset(previewImageView.frame, ABS(self.frame.size.width - image.size.width) * -0.5, (-26.0 + (ABS(self.frame.size.height - image.size.height) * -0.5)) + (-26.0 * [HONAppDelegate isRetina4Inch]));
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
	[_uploadingImageView stopAnimating];
	_uploadingImageView.alpha = 0.0;
}

- (void)animateAccept {
	[UIView animateWithDuration:0.125 animations:^(void) {
		_submitHolderView.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 64.0, 320.0, 64.0);
	}];
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
	
	_uploadingImageView.alpha = 1.0;
	[_uploadingImageView startAnimating];
	
	_blackMatteView.hidden = NO;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_blackMatteView.alpha = 1.0;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_blackMatteView.alpha = 0.0;
		}];
	}];
	
	[self.delegate cameraOverlayViewTakePicture:self];
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
	
	_captureButton.hidden = NO;
	[self.delegate cameraOverlayViewRetake:self];
}


#pragma mark - UI Presentation


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
				
				[self _goCameraBack];
				break;
		}
	}
}
@end
