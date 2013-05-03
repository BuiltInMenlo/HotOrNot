//
//  HONAvatarCameraOverlayView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 04.30.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "Mixpanel.h"

#import "HONAvatarCameraOverlayView.h"
#import "HONAppDelegate.h"
#import "HONImagingDepictor.h"
#import "HONHeaderView.h"

@interface HONAvatarCameraOverlayView()
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) UIImageView *irisImageView;
@property (nonatomic, strong) UIView *footerHolderView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIButton *cameraBackButton;
@property (nonatomic, strong) UIView *previewHolderView;
@end

@implementation HONAvatarCameraOverlayView
@synthesize delegate = _delegate;

#pragma mark - View Lifecycle
- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_previewHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		[self addSubview:_previewHolderView];
		
		_irisImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, kNavBarHeaderHeight, 320.0, 320.0)];
		_irisImageView.image = [UIImage imageNamed:@"cameraViewShutter"];
		_irisImageView.alpha = 0.0;
		[self addSubview:_irisImageView];
		
		_bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, ([HONAppDelegate isRetina5]) ? 568.0 : 480.0)];
		_bgImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"FUEcameraViewBackground-568h" : @"FUEcameraViewBackground"];
		_bgImageView.userInteractionEnabled = YES;
		[self addSubview:_bgImageView];
		
		_footerHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, ([HONAppDelegate isRetina5]) ? 474.0 : 387.0, 640.0, 105.0)];
		[_bgImageView addSubview:_footerHolderView];
		
		_headerView = [[HONHeaderView alloc] initWithTitle:NSLocalizedString(@"header_register2", nil)];
		[_headerView hideRefreshing];
		[self addSubview:_headerView];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(1.0, 0.0, 64.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCloseCamera) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addSubview:_cancelButton];
		
		_submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_submitButton.frame = CGRectMake(254.0, 0.0, 64.0, 44.0);
		[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_nonActive"] forState:UIControlStateNormal];
		[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_Active"] forState:UIControlStateHighlighted];
		[_submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
		_submitButton.hidden = YES;
		[_headerView addSubview:_submitButton];
		
		UIButton *cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraRollButton.frame = CGRectMake(30.0, 30.0, 64.0, 44.0);
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive"] forState:UIControlStateNormal];
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active"] forState:UIControlStateHighlighted];
		[cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
		//[_footerHolderView addSubview:cameraRollButton];
		
		_captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_captureButton.frame = CGRectMake(128.0, 15.0, 64.0, 64.0);
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_nonActive"] forState:UIControlStateNormal];
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_Active"] forState:UIControlStateHighlighted];
		[_captureButton addTarget:self action:@selector(_goCapture) forControlEvents:UIControlEventTouchUpInside];
		[_footerHolderView addSubview:_captureButton];
		
		UIButton *changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
		changeCameraButton.frame = CGRectMake(230.0, 30.0, 74.0, 44.0);
		[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"cameraFrontBack_nonActive"] forState:UIControlStateNormal];
		[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"cameraFrontBack_Active"] forState:UIControlStateHighlighted];
		[changeCameraButton addTarget:self action:@selector(_goChangeCamera) forControlEvents:UIControlEventTouchUpInside];
		//[_footerHolderView addSubview:changeCameraButton];
	}
	
	return (self);
}


#pragma mark - UI Presentation
- (void)showPreviewNormal:(UIImage *)image {
	[_submitButton setEnabled:YES];
	_footerHolderView.frame = CGRectMake(-320.0, _footerHolderView.frame.origin.y, 640.0, 70.0);
	
	if (_cameraBackButton == nil) {
		_cameraBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cameraBackButton.frame = CGRectMake(8.0, 5.0, 74.0, 34.0);
		[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
		[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateHighlighted];
		[_cameraBackButton addTarget:self action:@selector(_goCameraBack) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addSubview:_cameraBackButton];
	}
	
	_submitButton.hidden = NO;
	_cancelButton.hidden = YES;
	_cameraBackButton.hidden = NO;
	[_headerView setTitle:NSLocalizedString(@"header_register3", nil)];
	
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

- (void)showPreviewFlipped:(UIImage *)image {
	[_submitButton setEnabled:YES];
	_footerHolderView.frame = CGRectMake(-320.0, _footerHolderView.frame.origin.y, 640.0, 70.0);
	
	if (_cameraBackButton == nil) {
		_cameraBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cameraBackButton.frame = CGRectMake(2.0, 0.0, 64.0, 44.0);
		[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
		[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateHighlighted];
		[_cameraBackButton addTarget:self action:@selector(_goCameraBack) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addSubview:_cameraBackButton];
	}
	
	_submitButton.hidden = NO;
	_cancelButton.hidden = YES;
	_cameraBackButton.hidden = NO;
	[_headerView setTitle:NSLocalizedString(@"header_register3", nil)];
	
	image = [HONImagingDepictor scaleImage:image toSize:CGSizeMake(480.0, 640.0)];
	UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:image.CGImage scale:1.5 orientation:UIImageOrientationUpMirrored]];
	[_previewHolderView addSubview:imgView];
	_previewHolderView.hidden = NO;
	
	if ([HONAppDelegate isRetina5]) {
		CGRect frame = CGRectMake(-18.0, 0.0, 355.0, 475.0);
		imgView.frame = frame;
	}
}

- (void)hidePreview {
	[[Mixpanel sharedInstance] track:@"Change Avatar - Back to Camera"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_cancelButton.hidden = NO;
	_submitButton.hidden = YES;
	_previewHolderView.hidden = YES;
	_cameraBackButton.hidden = YES;
	[_headerView setTitle:NSLocalizedString(@"header_register2", nil)];
	
	_footerHolderView.frame = CGRectMake(0.0, _footerHolderView.frame.origin.y, 640.0, 70.0);
}

- (void)_animateShutter {
	_irisImageView.alpha = 1.0;
	[UIView animateWithDuration:0.33 animations:^(void) {
		_irisImageView.alpha = 0.0;
	} completion:^(BOOL finished){}];
}

#pragma mark - Navigation
- (void)_goCloseCamera {
	[self.delegate cameraOverlayViewCancelCamera:self];
}

- (void)_goSubmit {
	[self.delegate cameraOverlayViewSubmit:self];
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
