//
//  HONRegisterCameraOverlayView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.03.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONRegisterCameraOverlayView.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"

@interface HONRegisterCameraOverlayView()
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) UIView *footerHolderView;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *cameraBackButton;
@end

@implementation HONRegisterCameraOverlayView

@synthesize delegate = _delegate;
@synthesize username = _username;


#pragma mark - View Lifecycle
- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, ([HONAppDelegate isRetina5]) ? 568.0 : 480.0)];
		bgImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"cameraExperience_Overlay-568h" : @"cameraExperience_Overlay"];
		bgImageView.userInteractionEnabled = YES;
		[self addSubview:bgImageView];
		
		_footerHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 367.0, 640.0, 105.0)];
		[bgImageView addSubview:_footerHolderView];
		
		_headerView = [[HONHeaderView alloc] initWithTitle:@"TAKE PHOTO"];
		[self addSubview:_headerView];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(5.0, 5.0, 64.0, 34.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addSubview:_cancelButton];
		
		UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
		submitButton.frame = CGRectMake(253.0, 5.0, 64.0, 34.0);
		[submitButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
		[submitButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
		[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addSubview:submitButton];
		
		// Add the gallery button
		UIButton *cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraRollButton.frame = CGRectMake(20.0, 20.0, 75.0, 75.0);
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive"] forState:UIControlStateNormal];
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active"] forState:UIControlStateHighlighted];
		[cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
		[_footerHolderView addSubview:cameraRollButton];
		
		// Add the capture button
		_captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_captureButton.frame = CGRectMake(108.0, 0.0, 105.0, 105.0);
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_nonActive"] forState:UIControlStateNormal];
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_Active"] forState:UIControlStateHighlighted];
		[_captureButton addTarget:self action:@selector(_goCapture) forControlEvents:UIControlEventTouchUpInside];
		[_footerHolderView addSubview:_captureButton];
		
		UIButton *changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
		changeCameraButton.frame = CGRectMake(220.0, 20.0, 75.0, 75.0);
		[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"flipCamera_nonActive"] forState:UIControlStateNormal];
		[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"flipCamera_Active"] forState:UIControlStateHighlighted];
		[changeCameraButton addTarget:self action:@selector(_goChangeCamera) forControlEvents:UIControlEventTouchUpInside];
		[_footerHolderView addSubview:changeCameraButton];
		
		UIImageView *usernameBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(340.0, 10.0, 274.0, 44.0)];
		usernameBGImageView.image = [UIImage imageNamed:@"cameraInputField_nonActive"];
		usernameBGImageView.userInteractionEnabled = YES;
		[_footerHolderView addSubview:usernameBGImageView];
		
		_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(16.0, 13.0, 270.0, 20.0)];
		[_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		_usernameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
		[_usernameTextField setReturnKeyType:UIReturnKeyDone];
		[_usernameTextField setTextColor:[UIColor blackColor]];
		[_usernameTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
		_usernameTextField.font = [[HONAppDelegate freightSansBlack] fontWithSize:16];
		_usernameTextField.keyboardType = UIKeyboardTypeDefault;
		_usernameTextField.text = [[HONAppDelegate infoForUser] objectForKey:@"name"];
		//_usernameTextField.delegate = self;
		[usernameBGImageView addSubview:_usernameTextField];
	}
	
	return (self);
}


#pragma mark - UI Presentation
- (void)showUsername {
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
		_footerHolderView.frame = CGRectMake(-320.0, _footerHolderView.frame.origin.y, 640.0, 70.0);
	} completion:nil];
	
	_cameraBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_cameraBackButton.frame = CGRectMake(5.0, 5.0, 74.0, 34.0);
	[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"cameraBackButton_nonActive"] forState:UIControlStateNormal];
	[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"cameraBackButton_Active"] forState:UIControlStateHighlighted];
	[_cameraBackButton addTarget:self action:@selector(_goCameraBack) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:_cameraBackButton];
}

- (void)hideUsername {
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
		_footerHolderView.frame = CGRectMake(0.0, _footerHolderView.frame.origin.y, 640.0, 70.0);
	} completion:nil];
}

#pragma mark - Navigation
- (void)_goCancel {
	[self.delegate cameraOverlayViewCancelCamera:self];
}

- (void)_goSubmit {
	
}

- (void)_goCapture {
	_captureButton.enabled = NO;
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
	[self hideUsername];
}

@end
