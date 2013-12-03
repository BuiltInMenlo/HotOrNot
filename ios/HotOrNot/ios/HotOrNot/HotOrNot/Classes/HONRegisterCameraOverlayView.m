//
//  HONRegisterCameraOverlayView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.03.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONRegisterCameraOverlayView.h"
#import "HONAppDelegate.h"
#import "HONImagingDepictor.h"

@interface HONRegisterCameraOverlayView() <UIAlertViewDelegate>
@property (nonatomic, strong) UIImageView *irisImageView;
@property (nonatomic, strong) UIView *footerHolderView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIView *previewHolderView;
@property (nonatomic, strong) UILabel *headerLabel;
@end

@implementation HONRegisterCameraOverlayView

@synthesize delegate = _delegate;
@synthesize username = _username;


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
		
		_headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 18.0, 200.0, 24.0)];
		_headerLabel.backgroundColor = [UIColor clearColor];
		_headerLabel.font = [[HONAppDelegate cartoGothicBold] fontWithSize:18];
		_headerLabel.textColor = [UIColor whiteColor];
		_headerLabel.text = NSLocalizedString(@"header_register2", nil);
		[self addSubview:_headerLabel];
		
		UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		skipButton.frame = CGRectMake(270.0, 5.0, 44.0, 44.0);
		[skipButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
		[skipButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
		[skipButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:skipButton];
		
		_footerHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, ([HONAppDelegate isRetina5]) ? 477.0 : 397.0, 640.0, 80.0)];
		[self addSubview:_footerHolderView];
		
		UIButton *captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
		captureButton.frame = CGRectMake(115.0, 0.0, 90.0, 80.0);
		[captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_nonActive"] forState:UIControlStateNormal];
		[captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_Active"] forState:UIControlStateHighlighted];
		[captureButton addTarget:self action:@selector(_goCapture) forControlEvents:UIControlEventTouchUpInside];
		[_footerHolderView addSubview:captureButton];
		
		UIButton *retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		retakeButton.frame = CGRectMake(340.0, 16.0, 121.0, 53.0);
		[retakeButton setBackgroundImage:[UIImage imageNamed:@"previewRetakeButton_nonActive"] forState:UIControlStateNormal];
		[retakeButton setBackgroundImage:[UIImage imageNamed:@"previewRetakeButton_Active"] forState:UIControlStateHighlighted];
		[retakeButton addTarget:self action:@selector(_goCameraBack) forControlEvents:UIControlEventTouchUpInside];
		[_footerHolderView addSubview:retakeButton];
		
		UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
		submitButton.frame = CGRectMake(496.0, 16.0, 121.0, 53.0);
		[submitButton setBackgroundImage:[UIImage imageNamed:@"previewSubmitButton_nonActive"] forState:UIControlStateNormal];
		[submitButton setBackgroundImage:[UIImage imageNamed:@"previewSubmitButton_Active"] forState:UIControlStateHighlighted];
		[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
		[_footerHolderView addSubview:submitButton];
	}
	
	return (self);
}


#pragma mark - UI Presentation
- (void)showPreviewNormal:(UIImage *)image {
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
		_footerHolderView.frame = CGRectOffset(_footerHolderView.frame, -320.0, 0.0);
	} completion:nil];
	
	_headerLabel.text = NSLocalizedString(@"header_register3", nil);
	
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
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
		_footerHolderView.frame = CGRectOffset(_footerHolderView.frame, -320.0, 0.0);
	} completion:nil];
	
	_headerLabel.text = NSLocalizedString(@"header_register3", nil);
	
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
	_previewHolderView.hidden = YES;
	_headerLabel.text = NSLocalizedString(@"register_caption1", nil);
	
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
		_footerHolderView.frame = CGRectOffset(_footerHolderView.frame, 320.0, 0.0);
	} completion:nil];
}

- (void)_animateShutter {
	_irisImageView.alpha = 1.0;
	[UIView animateWithDuration:0.33 animations:^(void) {
		_irisImageView.alpha = 0.0;
	} completion:^(BOOL finished){}];
}

#pragma mark - Navigation
- (void)_goCancel {
	[[Mixpanel sharedInstance] track:@"Register - Skip Photo"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	

	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
																		 message:@"Your profile photo is how other people will know you're real!"
																		delegate:self
															cancelButtonTitle:@"Skip"
															otherButtonTitles:@"Take Photo", nil];
	[alertView setTag:0];
	[alertView show];
}

- (void)_goSubmit {
	[self.delegate cameraOverlayViewSubmitWithUsername:self username:_username];
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
	[self.delegate cameraOverlayViewRetake:self];
	[self hidePreview];
}


#pragma mark - AlertView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		switch(buttonIndex) {
			case 0:
				[[Mixpanel sharedInstance] track:@"Register - Skip Photo Confirm"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				[self.delegate cameraOverlayViewCancelCamera:self];
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
