//
//  HONCameraOverlayView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONCameraOverlayView.h"

#import "HONAppDelegate.h"

@interface HONCameraOverlayView()
@end

@implementation HONCameraOverlayView

@synthesize delegate, flashButton, captureButton, cameraRollButton;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.opaque = NO;
		
		float gutterHeight = ([[UIApplication sharedApplication] delegate].window.frame.size.height - 320.0) * 0.5;
		
		UIView *headerGutterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, gutterHeight)];
		headerGutterView.backgroundColor = [UIColor blackColor];
		[self addSubview:headerGutterView];
		
		UIView *footerGutterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 350.0, self.frame.size.height - gutterHeight, gutterHeight)];
		footerGutterView.backgroundColor = [UIColor blackColor];
		[self addSubview:footerGutterView];
		
		
		UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 45.0)];
		[headerImgView setImage:[UIImage imageNamed:@"headerTitleBackground.png"]];
		headerImgView.userInteractionEnabled = YES;
		[self addSubview:headerImgView];
		
		UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		backButton.frame = CGRectMake(255.0, 5.0, 54.0, 34.0);
		[backButton setBackgroundImage:[[UIImage imageNamed:@"genericButton_nonActive.png"] stretchableImageWithLeftCapWidth:16.0 topCapHeight:0.0] forState:UIControlStateNormal];
		[backButton setBackgroundImage:[[UIImage imageNamed:@"genericButton_Active.png"] stretchableImageWithLeftCapWidth:16.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
		[backButton addTarget:self action:@selector(closeCamera:) forControlEvents:UIControlEventTouchUpInside];
		//backButton = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
		[backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[backButton setTitle:@"Cancel" forState:UIControlStateNormal];
		[headerImgView addSubview:backButton];
		
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
		UIImageView *footerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 65.0, 320.0, 65.0)];
		footerImgView.backgroundColor = [UIColor blueColor];
		footerImgView.userInteractionEnabled = YES;
		[self addSubview:footerImgView];
		
		// Add the capture button
		self.captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.captureButton.frame = CGRectMake(106.0, 5.0, 108.0, 48.0);
		[self.captureButton setBackgroundImage:[UIImage imageNamed:@"playButton_nonActive.png"] forState:UIControlStateNormal];
		[self.captureButton setBackgroundImage:[UIImage imageNamed:@"playButton_Active.png"] forState:UIControlStateHighlighted];
		[self.captureButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
		[footerImgView addSubview:self.captureButton];
				
		// Add the gallery button
		self.cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.cameraRollButton.frame = CGRectMake(10.0, 10.0, 44.0, 44.0);
		[self.cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive.png"] forState:UIControlStateNormal];
		[self.cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active.png"] forState:UIControlStateHighlighted];
		[self.cameraRollButton addTarget:self action:@selector(showCameraRoll:) forControlEvents:UIControlEventTouchUpInside];
		[footerImgView addSubview:self.cameraRollButton];
		
		UIButton *changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
		changeCameraButton.frame = CGRectMake(270.0, 10.0, 44.0, 44.0);
		[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive.png"] forState:UIControlStateNormal];
		[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active.png"] forState:UIControlStateHighlighted];
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


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
