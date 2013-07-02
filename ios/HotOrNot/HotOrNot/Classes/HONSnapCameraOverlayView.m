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
#import "HONImagingDepictor.h"
#import "HONCreateChallengeOptionsView.h"
#import "HONSnapCameraOptionsView.h"
#import "HONUserVO.h"
#import "HONContactUserVO.h"

@interface HONSnapCameraOverlayView() <HONCreateChallengeOptionsViewDelegate, HONSnapCameraOptionsViewDelegate>
@property (nonatomic, strong) UIImageView *irisImageView;
@property (nonatomic, strong) HONCreateChallengeOptionsView *challengeOptionsView;
@property (nonatomic, strong) HONSnapCameraOptionsView *cameraOptionsView;
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
		//hide overlay - [self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"OverlayCoverCamera-568h@2x" : @"OverlayCoverCamera"]]];
		
		_irisImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6.0, ([_username length] > 0) ? kNavBarHeaderHeight + 33.0 : kNavBarHeaderHeight + 10.0, 307.0, 306.0)];
		_irisImageView.image = [UIImage imageNamed:@"cameraViewShutter"];
		_irisImageView.alpha = 0.0;
		//[self addSubview:_irisImageView];
		
		_controlsHolderView = [[UIView alloc] initWithFrame:self.frame];
		_controlsHolderView.userInteractionEnabled = YES;
		[self addSubview:_controlsHolderView];
		
		_addFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_addFriendsButton.frame = CGRectMake(12.0, 11.0, 44.0, 44.0);
		[_addFriendsButton setBackgroundImage:[UIImage imageNamed:@"addButton_nonActive"] forState:UIControlStateNormal];
		[_addFriendsButton setBackgroundImage:[UIImage imageNamed:@"addButton_Active"] forState:UIControlStateHighlighted];
		[_addFriendsButton addTarget:self action:@selector(_goAddFriends) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_addFriendsButton];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(263.0, 11.0, 44.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCloseCamera) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_cancelButton];
		
		NSString *usernames = @"";
		for (NSString *username in _usernames)
			usernames = [usernames stringByAppendingFormat:@"%@, ", _username];
		
		_usernamesLabel = [[UILabel alloc] initWithFrame:CGRectMake(66.0, 21.0, 210.0, 24.0)];
		_usernamesLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:18];
		_usernamesLabel.textColor = [UIColor whiteColor];
		_usernamesLabel.backgroundColor = [UIColor clearColor];
		_usernamesLabel.text = ([_username length] > 0) ? [NSString stringWithFormat:@"@%@", _username] : @"";
		[self addSubview:_usernamesLabel];
				
		_optionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_optionsButton.frame = CGRectMake(16.0, [UIScreen mainScreen].bounds.size.height - 60.0, 44.0, 44.0);
		[_optionsButton setBackgroundImage:[UIImage imageNamed:@"timeButton_nonActive"] forState:UIControlStateNormal];
		[_optionsButton setBackgroundImage:[UIImage imageNamed:@"timeButton_Active"] forState:UIControlStateHighlighted];
		[_optionsButton addTarget:self action:@selector(_goChallengeOptions) forControlEvents:UIControlEventTouchUpInside];
		[_controlsHolderView addSubview:_optionsButton];
		
		_captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_captureButton.frame = CGRectMake(123.0, [UIScreen mainScreen].bounds.size.height - 100.0, 74.0, 74.0);
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_nonActive"] forState:UIControlStateNormal];
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_Active"] forState:UIControlStateHighlighted];
		[_captureButton addTarget:self action:@selector(_goTakePhoto) forControlEvents:UIControlEventTouchUpInside];
		[_controlsHolderView addSubview:_captureButton];
		
		UIButton *cameraOptionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraOptionsButton.frame = CGRectMake(248.0, [UIScreen mainScreen].bounds.size.height - 51.0, 64.0, 44.0);
		[cameraOptionsButton setBackgroundImage:[UIImage imageNamed:@"moreWhiteButton_nonActive"] forState:UIControlStateNormal];
		[cameraOptionsButton setBackgroundImage:[UIImage imageNamed:@"moreWhiteButton_Active"] forState:UIControlStateHighlighted];
		[cameraOptionsButton addTarget:self action:@selector(_goCameraOptions) forControlEvents:UIControlEventTouchUpInside];
		[_controlsHolderView addSubview:cameraOptionsButton];
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

- (void)_goChallengeOptions {
	[[Mixpanel sharedInstance] track:@"Create Snap - Challenge Options"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_challengeOptionsView = [[HONCreateChallengeOptionsView alloc] initWithFrame:self.frame];
	_challengeOptionsView.frame = CGRectOffset(_challengeOptionsView.frame, 0.0, self.frame.size.height);
	_challengeOptionsView.delegate = self;
	[self addSubview:_challengeOptionsView];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationDelay:0.0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	_challengeOptionsView.frame = CGRectOffset(_challengeOptionsView.frame, 0.0, -self.frame.size.height);
	[UIView commitAnimations];
}

- (void)_goCameraOptions {
	[[Mixpanel sharedInstance] track:@"Create Snap - Camera Options"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_cameraOptionsView = [[HONSnapCameraOptionsView alloc] initWithFrame:self.frame];
	_cameraOptionsView.frame = CGRectOffset(_cameraOptionsView.frame, 0.0, self.frame.size.height);
	_cameraOptionsView.delegate = self;
	[self addSubview:_cameraOptionsView];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationDelay:0.0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	_cameraOptionsView.frame = CGRectOffset(_cameraOptionsView.frame, 0.0, -self.frame.size.height);
	[UIView commitAnimations];
}

- (void)_goTakePhoto {
	[self _animateShutter];
	[self.delegate cameraOverlayViewTakePicture:self];
}

- (void)_goToggleFlash {
	[self.delegate cameraOverlayViewChangeFlash:self];
}

- (void)_goCloseCamera {
	[self.delegate cameraOverlayViewCloseCamera:self];
}


#pragma mark - ChallengeOptionsView Delegates
- (void)challengeOptionsViewMakePublic:(HONCreateChallengeOptionsView *)createChallengeOptionsView {
	[self.delegate cameraOverlayView:self challengeIsPublic:YES];
}

- (void)challengeOptionsViewMakeRandom:(HONCreateChallengeOptionsView *)createChallengeOptionsView {
	[self.delegate cameraOverlayViewMakeChallengeRandom:self];
}

- (void)challengeOptionsViewMakePrivate:(HONCreateChallengeOptionsView *)createChallengeOptionsView {
	[self.delegate cameraOverlayView:self challengeIsPublic:NO];
}

- (void)challengeOptionsViewClose:(HONCreateChallengeOptionsView *)createChallengeOptionsView {
	[UIView animateWithDuration:0.25 delay:0.125 options:UIViewAnimationOptionCurveEaseIn animations:^(void) {
		_challengeOptionsView.frame = CGRectOffset(_challengeOptionsView.frame, 0.0, self.frame.size.height);
	} completion:^(BOOL finished) {
		[_challengeOptionsView removeFromSuperview];
		_challengeOptionsView = nil;
	}];
}


#pragma mark - CameraOptionsView Delegates
- (void)cameraOptionsViewCameraRoll:(HONSnapCameraOptionsView *)cameraOptionsView {
	[self.delegate cameraOverlayViewShowCameraRoll:self];
}

- (void)cameraOptionsViewFlipCamera:(HONSnapCameraOptionsView *)cameraOptionsView {
	[self.delegate cameraOverlayViewChangeCamera:self];
}

- (void)cameraOptionsViewClose:(HONSnapCameraOptionsView *)cameraOptionsView {
	[UIView animateWithDuration:0.25 delay:0.125 options:UIViewAnimationOptionCurveEaseIn animations:^(void) {
		_cameraOptionsView.frame = CGRectOffset(_cameraOptionsView.frame, 0.0, self.frame.size.height);
	} completion:^(BOOL finished) {
		[_cameraOptionsView removeFromSuperview];
		_cameraOptionsView = nil;
	}];
}

@end
