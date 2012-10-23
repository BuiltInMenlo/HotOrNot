//
//  HONCameraOverlayView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONCameraOverlayView.h"

#import "HONAppDelegate.h"
#import "HONHeaderView.h"

@interface HONCameraOverlayView()
@property (nonatomic, strong) UIImageView *overlayImgView;
@end

@implementation HONCameraOverlayView

@synthesize delegate, flashButton, captureButton, cameraRollButton;
@synthesize overlayImgView = _overlayImgView;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.opaque = NO;
		
		float gutterHeight = ([[UIApplication sharedApplication] delegate].window.frame.size.height - 320.0) * 0.5;
		
		_overlayImgView = [[UIImageView alloc] initWithFrame:self.bounds];
		_overlayImgView.image = [UIImage imageNamed:@"cameraCover.png"];
		_overlayImgView.hidden = YES;
		[self addSubview:_overlayImgView];
		
		UIView *headerGutterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, gutterHeight)];
		headerGutterView.backgroundColor = [UIColor blackColor];
		[self addSubview:headerGutterView];
		
		UIView *footerGutterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 350.0, self.frame.size.height - gutterHeight, gutterHeight)];
		footerGutterView.backgroundColor = [UIColor blackColor];
		[self addSubview:footerGutterView];
		
		HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Take Photo" hasFBSwitch:NO];
		[self addSubview:headerView];
		
		UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cancelButton.frame = CGRectMake(247.0, 0.0, 74.0, 44.0);
		[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive.png"] forState:UIControlStateNormal];
		[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active.png"] forState:UIControlStateHighlighted];
		[cancelButton addTarget:self action:@selector(closeCamera:) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:cancelButton];
		
//		UIImage *buttonImageNormal;
//		if ([UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear]) {
//			self.flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
//			self.flashButton.frame = CGRectMake(10, 30, 57.5, 57.5);
//			buttonImageNormal = [UIImage imageNamed:@"flash02"];
//			[self.flashButton setImage:buttonImageNormal forState:UIControlStateNormal];
//			[self.flashButton addTarget:self action:@selector(setFlash:) forControlEvents:UIControlEventTouchUpInside];
//			[self addSubview:self.flashButton];
//		}
//		
//		if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
//			self.changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
//			self.changeCameraButton.frame = CGRectMake(250, 30, 57.5, 57.5);
//			buttonImageNormal = [UIImage imageNamed:@"switch_button"];
//			[self.changeCameraButton setImage:buttonImageNormal forState:UIControlStateNormal];
//			[self.changeCameraButton addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
//			[self addSubview:self.changeCameraButton];
//		}
		
		// Add the bottom bar
		UIImageView *footerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 70.0, 320.0, 70.0)];
		footerImgView.image = [UIImage imageNamed:@"cameraFooterBG.png"];
		footerImgView.userInteractionEnabled = YES;
		[self addSubview:footerImgView];
		
		// Add the capture button
		self.captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.captureButton.frame = CGRectMake(103.0, 3.0, 114.0, 64.0);
		[self.captureButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_nonActive.png"] forState:UIControlStateNormal];
		[self.captureButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_Active.png"] forState:UIControlStateHighlighted];
		[self.captureButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
		[footerImgView addSubview:self.captureButton];
				
		// Add the gallery button
		self.cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.cameraRollButton.frame = CGRectMake(10.0, 10.0, 49.0, 49.0);
		[self.cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive.png"] forState:UIControlStateNormal];
		[self.cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active.png"] forState:UIControlStateHighlighted];
		[self.cameraRollButton addTarget:self action:@selector(showCameraRoll:) forControlEvents:UIControlEventTouchUpInside];
		[footerImgView addSubview:self.cameraRollButton];
		
		UIButton *changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
		changeCameraButton.frame = CGRectMake(263.0, 10.0, 49.0, 49.0);
		[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"flipCamera_nonActive.png"] forState:UIControlStateNormal];
		[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"flipCamera_Active.png"] forState:UIControlStateHighlighted];
		[changeCameraButton addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
		[footerImgView addSubview:changeCameraButton];
	}
	
	return (self);
}

- (void)takePicture:(id)sender {
	self.captureButton.enabled = NO;
	[self.delegate takePicture];
}

- (void)setFlash:(id)sender {
	//[self.delegate changeFlash:sender];
}

- (void)changeCamera:(id)sender {
	[self.delegate changeCamera];
}

- (void)showCameraRoll:(id)sender {
	[self.delegate showLibrary];
}

- (void)closeCamera:(id)sender {
	[self.delegate closeCamera];
}

- (void)hidePreview {
	_overlayImgView.hidden = NO;
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
