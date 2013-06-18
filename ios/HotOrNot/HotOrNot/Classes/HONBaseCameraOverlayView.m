//
//  HONBaseCameraOverlayView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.17.13 @ 18:23 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "HONBaseCameraOverlayView.h"
#import "HONAppDelegate.h"
#import "HONImagingDepictor.h"

@interface HONBaseCameraOverlayView ()
@property (nonatomic, strong) UIImageView *irisImageView;
@property (nonatomic, strong) UIView *controlsHolderView;

@end

@implementation HONBaseCameraOverlayView
@synthesize cancelButton = _cancelButton;
@synthesize cameraRollButton = _cameraRollButton;
@synthesize changeCameraButton = _changeCameraButton;
@synthesize captureButton = _captureButton;
@synthesize submitButton = _submitButton;
@synthesize delegate = _delegate;


- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_irisImageView = [[UIImageView alloc] initWithFrame:self.frame];
		_irisImageView.image = [UIImage imageNamed:@"cameraViewShutter"];
		_irisImageView.alpha = 0.0;
		//[self addSubview:_irisImageView];
		
		_controlsHolderView = [[UIView alloc] initWithFrame:self.frame];
		_controlsHolderView.userInteractionEnabled = YES;
		[self addSubview:_controlsHolderView];
		
		UIButton *cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraRollButton.frame = CGRectMake(15.0, 267.0, 64.0, 44.0);
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive"] forState:UIControlStateNormal];
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active"] forState:UIControlStateHighlighted];
		[cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
		[_controlsHolderView addSubview:cameraRollButton];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(270.0, 5.0, 44.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCloseCamera) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_cancelButton];
		
		_cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cameraRollButton.frame = CGRectMake(15.0, 267.0, 64.0, 44.0);
		[_cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive"] forState:UIControlStateNormal];
		[_cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active"] forState:UIControlStateHighlighted];
		[_cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
		[_controlsHolderView addSubview:cameraRollButton];
		
//		if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
//			_changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
//			_changeCameraButton = CGRectMake(233.0, 267.0 + opsOffset, 74.0, 44.0);
//			[_changeCameraButton setBackgroundImage:[UIImage imageNamed:@"cameraFrontBack_nonActive"] forState:UIControlStateNormal];
//			[_changeCameraButton setBackgroundImage:[UIImage imageNamed:@"cameraFrontBack_Active"] forState:UIControlStateHighlighted];
//			[_changeCameraButton addTarget:self action:@selector(_goChangeCamera) forControlEvents:UIControlEventTouchUpInside];
//			[_controlsHolderView _changeCameraButton];
//		}
	}
	
	return (self);
}


#pragma mark - UI Presentation
- (void)_animateShutter {
	_irisImageView.alpha = 1.0;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_irisImageView.alpha = 0.0;
	} completion:^(BOOL finished){}];
}


#pragma mark - Navigation
- (void)_goTakePhoto {
	[self _animateShutter];
	[self.delegate cameraOverlayViewTakePicture:self];
}

- (void)_goToggleFlash {
	[self.delegate cameraOverlayViewChangeFlash:self];
}

- (void)_goChangeCamera {
	[self.delegate cameraOverlayViewChangeCamera:self];
}

- (void)_goCameraRoll {
	[self.delegate cameraOverlayViewShowCameraRoll:self];
}

- (void)_goCloseCamera {
	[self.delegate cameraOverlayViewCloseCamera:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
