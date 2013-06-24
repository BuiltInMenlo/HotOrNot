//
//  HONCameraOverlayView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"

#import "HONSnapCameraOverlayView.h"
#import "HONAppDelegate.h"
#import "HONImagingDepictor.h"
#import "HONCreateChallengeOptionsView.h"
#import "HONUserVO.h"
#import "HONContactUserVO.h"

@interface HONSnapCameraOverlayView()
@property (nonatomic, strong) UIImageView *irisImageView;
@property (nonatomic, strong) HONCreateChallengeOptionsView *optionsView;
@property (nonatomic, strong) UIView *controlsHolderView;
@property (nonatomic, strong) UIButton *addFriendsButton;
@property (nonatomic, strong) UILabel *usernamesLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *optionsButton;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) NSArray *usernames;
@property (nonatomic, strong) NSString *username;
@end

@implementation HONSnapCameraOverlayView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame withSubject:(NSString *)subject withUsername:(NSString *)username {
	if ((self = [super initWithFrame:frame])) {
		_usernames = [NSArray arrayWithObject:username];
		_username = username;
		
		NSLog(@"HONSnapCameraOverlayView:initWithFrame:withSubject:[%@] withUsername:[%@]", subject, username);
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_closeOptions:) name:@"CLOSE_OPTIONS" object:nil];
		
		_irisImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6.0, ([_username length] > 0) ? kNavBarHeaderHeight + 33.0 : kNavBarHeaderHeight + 10.0, 307.0, 306.0)];
		_irisImageView.image = [UIImage imageNamed:@"cameraViewShutter"];
		_irisImageView.alpha = 0.0;
		//[self addSubview:_irisImageView];
		
		//[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"OverlayCoverCamera-568h@2x" : @"OverlayCoverCamera-568h@2x"]]];
		[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"OverlayCoverCamera-568h@2x" : @"OverlayCoverCamera"]]];
		
		_controlsHolderView = [[UIView alloc] initWithFrame:self.frame];
		_controlsHolderView.userInteractionEnabled = YES;
		[self addSubview:_controlsHolderView];
		
		_addFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_addFriendsButton.frame = CGRectMake(5.0, 5.0, 44.0, 44.0);
		[_addFriendsButton setBackgroundImage:[UIImage imageNamed:@"addButton_nonActive"] forState:UIControlStateNormal];
		[_addFriendsButton setBackgroundImage:[UIImage imageNamed:@"addButton_Active"] forState:UIControlStateHighlighted];
		[_addFriendsButton addTarget:self action:@selector(_goAddFriends) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_addFriendsButton];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(270.0, 5.0, 44.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCloseCamera) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_cancelButton];
		
		NSString *usernames = @"";
		for (NSString *username in _usernames)
			usernames = [usernames stringByAppendingFormat:@"%@, ", _username];
		
		_usernamesLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 18.0, 210.0, 20.0)];
		_usernamesLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:14];
		_usernamesLabel.textColor = [UIColor whiteColor];
		_usernamesLabel.backgroundColor = [UIColor clearColor];
		_usernamesLabel.text = ([_username length] > 0) ? [NSString stringWithFormat:@"@%@", _username] : @"";
		[self addSubview:_usernamesLabel];
		
//		int opsOffset = ([_username length] > 0) ? 40 : ([HONAppDelegate isRetina5]) ? 55 : 0;
//		UIButton *cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		cameraRollButton.frame = CGRectMake(15.0, 267.0 + opsOffset, 64.0, 44.0);
//		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive"] forState:UIControlStateNormal];
//		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active"] forState:UIControlStateHighlighted];
//		[cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
//		[_controlsHolderView addSubview:cameraRollButton];
		
//
//		if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
//			UIButton *changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
//			changeCameraButton.frame = CGRectMake(233.0, 267.0 + opsOffset, 74.0, 44.0);
//			[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"cameraFrontBack_nonActive"] forState:UIControlStateNormal];
//			[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"cameraFrontBack_Active"] forState:UIControlStateHighlighted];
//			[changeCameraButton addTarget:self action:@selector(_goChangeCamera) forControlEvents:UIControlEventTouchUpInside];
//			[_controlsHolderView addSubview:changeCameraButton];
//		}
		
		UIButton *cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraRollButton.frame = CGRectMake(260.0, [UIScreen mainScreen].bounds.size.height - 60.0, 44.0, 44.0);
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive"] forState:UIControlStateNormal];
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_Active"] forState:UIControlStateHighlighted];
		[cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
		[_controlsHolderView addSubview:cameraRollButton];
		
		_captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_captureButton.frame = CGRectMake(128.0, ([HONAppDelegate isRetina5]) ? 471 : 382, 64.0, 64.0);
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_nonActive"] forState:UIControlStateNormal];
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_Active"] forState:UIControlStateHighlighted];
		[_captureButton addTarget:self action:@selector(_goTakePhoto) forControlEvents:UIControlEventTouchUpInside];
		[_controlsHolderView addSubview:_captureButton];
		
		_optionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_optionsButton.frame = CGRectMake(15.0, [UIScreen mainScreen].bounds.size.height - 60.0, 44.0, 44.0);
		[_optionsButton setBackgroundImage:[UIImage imageNamed:@"timeButton_nonActive"] forState:UIControlStateNormal];
		[_optionsButton setBackgroundImage:[UIImage imageNamed:@"timeButton_Active"] forState:UIControlStateHighlighted];
		[_optionsButton addTarget:self action:@selector(_goOptions) forControlEvents:UIControlEventTouchUpInside];
		[_controlsHolderView addSubview:_optionsButton];
	}
	
	return (self);
}


#pragma mark - Public API
- (void)updateChallengers:(NSArray *)challengers {
	_usernames = challengers;
	
	NSString *usernames = @"";
	for (NSString *username in _usernames)
		usernames = [usernames stringByAppendingFormat:@"@%@, ", username];
	
	NSLog(@"updateChallengers:[%@]\nusernames:[%@]", _usernames, usernames);
	_usernamesLabel.text = ([usernames length] == 0) ? @"" : [usernames substringToIndex:[usernames length] - 2];
}


#pragma mark - UI Presentation
- (void)_animateShutter {
	_irisImageView.alpha = 1.0;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_irisImageView.alpha = 0.0;
	} completion:^(BOOL finished){}];
}


#pragma mark - Navigation
- (void)_goAddFriends {
	[self.delegate cameraOverlayViewAddChallengers:self];
}

- (void)_goOptions {
	[[Mixpanel sharedInstance] track:@"Create Snap - Options"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_optionsView = [[HONCreateChallengeOptionsView alloc] initWithFrame:self.frame];
	_optionsView.frame = CGRectOffset(_optionsView.frame, 0.0, self.frame.size.height);
	[self addSubview:_optionsView];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationDelay:0.0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	_optionsView.frame = self.frame;
	[UIView commitAnimations];
}

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


#pragma mark - Notifications
- (void)_closeOptions:(NSNotification *)notification {
	[UIView animateWithDuration:0.25 delay:0.125 options:UIViewAnimationOptionCurveEaseIn animations:^(void) {
		_optionsView.frame = CGRectOffset(_optionsView.frame, 0.0, self.frame.size.height);
	} completion:^(BOOL finished) {
		[_optionsView removeFromSuperview];
		_optionsView = nil;
	}];
}


@end
