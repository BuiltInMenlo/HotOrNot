//
//  HONRegisterCameraOverlayView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.03.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "Mixpanel.h"

#import "HONRegisterCameraOverlayView.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"

@interface HONRegisterCameraOverlayView()
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) UIImageView *irisImageView;
@property (nonatomic, strong) UIView *footerHolderView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIButton *cameraBackButton;
@property (nonatomic, strong) UIView *previewHolderView;
@property (nonatomic, strong) UILabel *captionLabel;
@end

@implementation HONRegisterCameraOverlayView

@synthesize delegate = _delegate;
@synthesize username = _username;


#pragma mark - View Lifecycle
- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_previewHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		[self addSubview:_previewHolderView];
		
		_irisImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, 320.0)];
		_irisImageView.image = [UIImage imageNamed:@"cameraViewShutter"];
		_irisImageView.alpha = 0.0;
		[self addSubview:_irisImageView];
		
		_bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, ([HONAppDelegate isRetina5]) ? 568.0 : 480.0)];
		_bgImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"cameraExperience_Overlay-568h" : @"cameraExperience_Overlay"];
		_bgImageView.userInteractionEnabled = YES;
		[self addSubview:_bgImageView];
		
		_footerHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, ([HONAppDelegate isRetina5]) ? 474.0 : 384.0, 640.0, 105.0)];
		[_bgImageView addSubview:_footerHolderView];
		
		_headerView = [[HONHeaderView alloc] initWithTitle:@"Take Pic"];
		[_headerView hideRefreshing];
		[self addSubview:_headerView];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(5.0, 0.0, 64.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"skipButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"skipButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addSubview:_cancelButton];
		
		_submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_submitButton.frame = CGRectMake(246.0, 0.0, 74.0, 44.0);
		[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_nonActive"] forState:UIControlStateNormal];
		[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_Active"] forState:UIControlStateHighlighted];
		[_submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
		_submitButton.hidden = YES;
		[_headerView addSubview:_submitButton];
		
		UIButton *cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraRollButton.frame = CGRectMake(20.0, 20.0, 64.0, 64.0);
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive"] forState:UIControlStateNormal];
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active"] forState:UIControlStateHighlighted];
		[cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
		//[_footerHolderView addSubview:cameraRollButton];
		
		_captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_captureButton.frame = CGRectMake(113.0, 0.0, 94.0, 94.0);
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_nonActive"] forState:UIControlStateNormal];
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_Active"] forState:UIControlStateHighlighted];
		[_captureButton addTarget:self action:@selector(_goCapture) forControlEvents:UIControlEventTouchUpInside];
		[_footerHolderView addSubview:_captureButton];
		
		UIButton *changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
		changeCameraButton.frame = CGRectMake(220.0, 20.0, 64.0, 64.0);
		[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"cameraFrontBack_nonActive"] forState:UIControlStateNormal];
		[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"cameraFrontBack_Active"] forState:UIControlStateHighlighted];
		[changeCameraButton addTarget:self action:@selector(_goChangeCamera) forControlEvents:UIControlEventTouchUpInside];
		//[_footerHolderView addSubview:changeCameraButton];
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, ([HONAppDelegate isRetina5]) ? 394.0 : 334.0, 320.0, 40.0)];
		_captionLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:16];
		_captionLabel.textColor = [UIColor whiteColor];
		_captionLabel.backgroundColor = [UIColor clearColor];
		_captionLabel.textAlignment = NSTextAlignmentCenter;
		_captionLabel.numberOfLines = 2;
		_captionLabel.text = @"Take your personal profile picture\n(no fakes allowed)";
		_captionLabel.hidden = ![HONAppDelegate isRetina5];
		[self addSubview:_captionLabel];
	}
	
	return (self);
}


#pragma mark - UI Presentation
- (void)showPreviewNormal:(UIImage *)image {
	_cancelButton.hidden = YES;
	[_submitButton setEnabled:YES];
	
	//[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
		_footerHolderView.frame = CGRectMake(-320.0, _footerHolderView.frame.origin.y, 640.0, 70.0);
	//} completion:nil];
	
	if (_cameraBackButton == nil) {
		_cameraBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cameraBackButton.frame = CGRectMake(5.0, 5.0, 74.0, 34.0);
		[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
		[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateHighlighted];
		[_cameraBackButton addTarget:self action:@selector(_goCameraBack) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addSubview:_cameraBackButton];
	}
	
	_submitButton.hidden = NO;
	_cameraBackButton.hidden = NO;
	_captionLabel.text = @"Look good? Alright, cool\nSubmit and lets get snapping…";
	
	image = [HONAppDelegate scaleImage:image toSize:CGSizeMake(480.0, 640.0)];
	UIImage *scaledImage = [UIImage imageWithCGImage:image.CGImage scale:1.5 orientation:UIImageOrientationUp];
	UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:scaledImage.CGImage scale:1.5 orientation:UIImageOrientationUp]];
	[_previewHolderView addSubview:imgView];
	_previewHolderView.hidden = NO;
	
	if ([HONAppDelegate isRetina5]) {
		CGRect frame = CGRectMake(-18.0, 0.0, 355.0, 475.0);
		imgView.frame = frame;
	}
}

- (void)showPreviewFlipped:(UIImage *)image {
	_cancelButton.hidden = YES;
	[_submitButton setEnabled:YES];
	
	//[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
		_footerHolderView.frame = CGRectMake(-320.0, _footerHolderView.frame.origin.y, 640.0, 70.0);
	//} completion:nil];
	
	if (_cameraBackButton == nil) {
		_cameraBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cameraBackButton.frame = CGRectMake(0.0, 0.0, 64.0, 44.0);
		[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
		[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateHighlighted];
		[_cameraBackButton addTarget:self action:@selector(_goCameraBack) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addSubview:_cameraBackButton];
	}
	
	_submitButton.hidden = NO;
	_cameraBackButton.hidden = NO;
	_captionLabel.text = @"Look good? Alright, cool\nSubmit and lets get snapping…";
	
	image = [HONAppDelegate scaleImage:image toSize:CGSizeMake(480.0, 640.0)];
	UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:image.CGImage scale:1.5 orientation:UIImageOrientationUpMirrored]];
	[_previewHolderView addSubview:imgView];
	_previewHolderView.hidden = NO;
	
	if ([HONAppDelegate isRetina5]) {
		CGRect frame = CGRectMake(-18.0, 0.0, 355.0, 475.0);
		imgView.frame = frame;
	}
}

- (void)hidePreview {
	_submitButton.hidden = YES;
	_previewHolderView.hidden = YES;
	_cameraBackButton.hidden = YES;
	_cancelButton.hidden = NO;
	
	_captionLabel.text = @"Take your personal profile picture\n(no fakes allowed)";
	
	//[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
		_footerHolderView.frame = CGRectMake(0.0, _footerHolderView.frame.origin.y, 640.0, 70.0);
	//} completion:nil];
}

- (void)_animateShutter {
	_irisImageView.alpha = 1.0;
	[UIView animateWithDuration:0.33 animations:^(void) {
		_irisImageView.alpha = 0.0;
	} completion:^(BOOL finished){}];
}

#pragma mark - Navigation
- (void)_goCancel {
	[self.delegate cameraOverlayViewCancelCamera:self];
}

- (void)_goSubmit {
	[self.delegate cameraOverlayViewSubmitWithUsername:self username:_username];
}

- (void)_goCapture {
	_captureButton.enabled = NO;
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
	_captureButton.enabled = YES;
	[self hidePreview];
}


@end
