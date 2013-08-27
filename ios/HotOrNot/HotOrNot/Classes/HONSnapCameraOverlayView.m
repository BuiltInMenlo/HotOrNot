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
@property (nonatomic, strong) UIImageView *infoImageView;
@property (nonatomic, strong) UIImageView *irisImageView;
@property (nonatomic, strong) UIView *previewHolderView;
@property (nonatomic, strong) UIView *blackMatteView;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIImageView *circleFillImageView;
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
@property (nonatomic) BOOL isPrivate;
@property (readonly, nonatomic, assign) HONChallengeExpireType expireType;
@end

@implementation HONSnapCameraOverlayView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame withSubject:(NSString *)subject withUsername:(NSString *)username {
	if ((self = [super initWithFrame:frame])) {
		_usernames = [NSArray arrayWithObject:username];
		_username = username;
		
		//NSLog(@"HONSnapCameraOverlayView:initWithFrame:withSubject:[%@] withUsername:[%@]", subject, username);
		//hide overlay - [self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"OverlayCoverCamera-568h@2x" : @"OverlayCoverCamera"]]];
		
		_irisImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6.0, ([_username length] > 0) ? kNavBarHeaderHeight + 33.0 : kNavBarHeaderHeight + 10.0, 307.0, 306.0)];
		_irisImageView.image = [UIImage imageNamed:@"cameraViewShutter"];
		_irisImageView.alpha = 0.0;
		//[self addSubview:_irisImageView];
		
		_previewHolderView = [[UIView alloc] initWithFrame:self.frame];
		[self addSubview:_previewHolderView];
		
		_controlsHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 640.0, self.frame.size.height)];
		[self addSubview:_controlsHolderView];
		
		_addFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_addFriendsButton.frame = CGRectMake(12.0, 11.0, 44.0, 44.0);
		[_addFriendsButton setBackgroundImage:[UIImage imageNamed:@"addButton_nonActive"] forState:UIControlStateNormal];
		[_addFriendsButton setBackgroundImage:[UIImage imageNamed:@"addButton_Active"] forState:UIControlStateHighlighted];
		//[_addFriendsButton addTarget:self action:@selector(_goAddFriends) forControlEvents:UIControlEventTouchUpInside];
		//_addFriendsButton.hidden = ([_username length] == 0);
		//[self addSubview:_addFriendsButton];
		
		UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 33.0, 33.0)];
		[avatarImageView setImageWithURL:[NSURL URLWithString:[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"]] placeholderImage:nil];
		//[self addSubview:avatarImageView];
		
		UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 19.0, 220.0, 16.0)];
		usernameLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:16];
		usernameLabel.textColor = [UIColor whiteColor];
		usernameLabel.backgroundColor = [UIColor clearColor];
		usernameLabel.text = [NSString stringWithFormat:@"@%@", [[HONAppDelegate infoForUser] objectForKey:@"username"]];
		//[self addSubview:usernameLabel];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(273.0, 5.0, 44.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCloseCamera) forControlEvents:UIControlEventTouchUpInside];
		//[self addSubview:_cancelButton];
		
		NSString *usernames = @"";
		for (NSString *username in _usernames)
			usernames = [usernames stringByAppendingFormat:@"%@, ", _username];
		
		_usernamesLabel = [[UILabel alloc] initWithFrame:CGRectMake(66.0, 21.0, 210.0, 24.0)];
		_usernamesLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:18];
		_usernamesLabel.textColor = [UIColor whiteColor];
		_usernamesLabel.backgroundColor = [UIColor clearColor];
		_usernamesLabel.text = ([_username length] > 0) ? [NSString stringWithFormat:@"@%@", _username] : @"";
		//[self addSubview:_usernamesLabel];
		
		_circleFillImageView = [[UIImageView alloc] initWithFrame:CGRectMake(123.0, self.frame.size.height - 150.0, 44.0, 44.0)];
		_circleFillImageView.image = [UIImage imageNamed:@"cameraAnimation_000"];
		[_controlsHolderView addSubview:_circleFillImageView];
				
		_optionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_optionsButton.frame = CGRectMake(16.0, [UIScreen mainScreen].bounds.size.height - 70.0, 84.0, 64.0);
		[_optionsButton setBackgroundImage:[UIImage imageNamed:@"iconForever_nonActive"] forState:UIControlStateNormal];
		[_optionsButton setBackgroundImage:[UIImage imageNamed:@"iconForever_Active"] forState:UIControlStateHighlighted];
		[_optionsButton addTarget:self action:@selector(_goChallengeOptions) forControlEvents:UIControlEventTouchUpInside];
//		[_controlsHolderView addSubview:_optionsButton];
		
		_captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_captureButton.frame = CGRectMake(123.0, [UIScreen mainScreen].bounds.size.height - 100.0, 74.0, 74.0);
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_nonActive"] forState:UIControlStateNormal];
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_Active"] forState:UIControlStateHighlighted];
//		[_captureButton addTarget:self action:@selector(_goTakePhoto) forControlEvents:UIControlEventTouchUpInside];
//		[_controlsHolderView addSubview:_captureButton];
		
		UIButton *cameraOptionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraOptionsButton.frame = CGRectMake(248.0, [UIScreen mainScreen].bounds.size.height - 61.0, 64.0, 64.0);
		[cameraOptionsButton setBackgroundImage:[UIImage imageNamed:@"moreWhiteButton_nonActive"] forState:UIControlStateNormal];
		[cameraOptionsButton setBackgroundImage:[UIImage imageNamed:@"moreWhiteButton_Active"] forState:UIControlStateHighlighted];
		[cameraOptionsButton addTarget:self action:@selector(_goCameraOptions) forControlEvents:UIControlEventTouchUpInside];
//		[_controlsHolderView addSubview:cameraOptionsButton];
		
//		float offset = ([HONAppDelegate isRetina5]) ? 469.0 : 389.0;
//		UIButton *retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		retakeButton.frame = CGRectMake(340.0, offset + 24.0, 128.0, 49.0);
//		[retakeButton setBackgroundImage:[UIImage imageNamed:@"previewRetakeButton_nonActive"] forState:UIControlStateNormal];
//		[retakeButton setBackgroundImage:[UIImage imageNamed:@"previewRetakeButton_Active"] forState:UIControlStateHighlighted];
//		[retakeButton addTarget:self action:@selector(_goCameraBack) forControlEvents:UIControlEventTouchUpInside];
//		[_controlsHolderView addSubview:retakeButton];
//		
//		UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		submitButton.frame = CGRectMake(496.0, offset + 24.0, 128.0, 49.0);
//		[submitButton setBackgroundImage:[UIImage imageNamed:@"previewSubmitButton_nonActive"] forState:UIControlStateNormal];
//		[submitButton setBackgroundImage:[UIImage imageNamed:@"previewSubmitButton_Active"] forState:UIControlStateHighlighted];
//		[submitButton addTarget:self action:@selector(_goAcceptPhoto) forControlEvents:UIControlEventTouchUpInside];
//		[_controlsHolderView addSubview:submitButton];
		
		_blackMatteView = [[UIView alloc] initWithFrame:self.frame];
		_blackMatteView.backgroundColor = [UIColor blackColor];
		[self addSubview:_blackMatteView];
	}
	
	return (self);
}


#pragma mark - Public API
- (void)intro {
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void){
		_blackMatteView.alpha = 0.0;
		_cancelButton.frame = CGRectMake(273.0, 5.0, 44.0, 44.0);
	} completion:^(BOOL fininshed){
		[_blackMatteView removeFromSuperview];
	}];
}

- (void)toggleInfoOverlay:(BOOL)isIntro {
	if (isIntro) {
		_infoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"cameraInfoOverlay-568h@2x" : @"cameraInfoOverlay"]];
		[self addSubview:_infoImageView];
		
		UIImageView *clockImageView = [[UIImageView alloc] initWithFrame:CGRectMake(123.0, self.frame.size.height - 150.0, 44.0, 44.0)];
		clockImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"cameraAnimation_001"],
										  [UIImage imageNamed:@"cameraAnimation_002"],
										  [UIImage imageNamed:@"cameraAnimation_003"],
										  [UIImage imageNamed:@"cameraAnimation_004"],
										  [UIImage imageNamed:@"cameraAnimation_005"],
										  [UIImage imageNamed:@"cameraAnimation_006"],
										  [UIImage imageNamed:@"cameraAnimation_007"],
										  [UIImage imageNamed:@"cameraAnimation_008"], nil];
		clockImageView.animationDuration = 2.5f;
		clockImageView.animationRepeatCount = 0;
		[clockImageView startAnimating];
		[_infoImageView addSubview:clockImageView];
	
	} else {
		[_infoImageView removeFromSuperview];
		_infoImageView = nil;
	}
}

- (void)updateChallengers:(NSArray *)challengers asJoining:(BOOL)isJoining {
	_usernames = challengers;
	
	NSString *usernames = (isJoining) ? @"joining " : @"";
	for (NSString *username in _usernames) {
		if ([username length] > 0)
			usernames = [usernames stringByAppendingFormat:@"@%@, ", username];
	}
	
	//NSLog(@"updateChallengers:[%@]\nusernames:[%@]", _usernames, usernames);
	_usernamesLabel.text = ([usernames length] == 0) ? @"" : [usernames substringToIndex:[usernames length] - 2];
}

- (void)addPreview:(UIImage *)image {
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		_controlsHolderView.frame = CGRectOffset(_controlsHolderView.frame, -320.0, 0.0);
	} completion:nil];
	
	if (_previewImageView == nil) {
		_previewImageView = [[UIImageView alloc] initWithImage:[HONImagingDepictor scaleImage:image byFactor:(([HONAppDelegate isRetina5]) ? 1.25f : 1.125f) * (self.frame.size.width / image.size.width)]];
		[_previewHolderView addSubview:_previewImageView];
	}
}

- (void)addMirroredPreview:(UIImage *)image {
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		_controlsHolderView.frame = CGRectOffset(_controlsHolderView.frame, -320.0, 0.0);
	} completion:nil];
	
	if (_previewImageView == nil) {
		UIImage *scaledImage = [HONImagingDepictor scaleImage:image byFactor:([HONAppDelegate isRetina5]) ? 0.55f : 0.83f];
		_previewImageView = [[UIImageView alloc] initWithImage:scaledImage];
		_previewImageView.frame = CGRectOffset(_previewImageView.frame, ABS(self.frame.size.width - scaledImage.size.width) * -0.5, -12.0 + ABS(self.frame.size.width - scaledImage.size.width) * -0.5);
		_previewImageView.transform = CGAffineTransformScale(_previewImageView.transform, -1.0f, 1.0f);
		//[_previewHolderView addSubview:_previewImageView];
	}
}

- (void)removePreview {
	[_previewImageView removeFromSuperview];
	_previewImageView = nil;
	
	_controlsHolderView.frame = CGRectOffset(_controlsHolderView.frame, 320.0, 0.0);
}


- (void)updateClock:(int)tick {
	//NSLog(@"IMG:[cameraAnimation_%03d]", tick);
	_circleFillImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"cameraAnimation_%03d", tick]];
}

- (void)submitStep:(HONCreateChallengePreviewView *)previewView {
	[self addSubview:previewView];
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
	[_challengeOptionsView setExpireType:_expireType];
	[_challengeOptionsView setIsPrivate:_isPrivate];
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

- (void)_goToggleFlash {
	[self.delegate cameraOverlayViewChangeFlash:self];
}

- (void)_goCloseCamera {
	[self.delegate cameraOverlayViewCloseCamera:self];
}


#pragma mark - ChallengeOptionsView Delegates
- (void)challengeOptionsViewMakePublic:(HONCreateChallengeOptionsView *)createChallengeOptionsView {
	_isPrivate = NO;
//	[self.delegate cameraOverlayView:self challengeIsPublic:YES];
}

- (void)challengeOptionsViewMakePrivate:(HONCreateChallengeOptionsView *)createChallengeOptionsView {
	_isPrivate = YES;
//	[self.delegate cameraOverlayView:self challengeIsPublic:NO];
}

- (void)challengeOptionsViewMakeNonExpire:(HONCreateChallengeOptionsView *)createChallengeOptionsView {
	_expireType = HONChallengeExpireTypeNone;
	
	[_optionsButton setBackgroundImage:[UIImage imageNamed:@"iconForever_nonActive"] forState:UIControlStateNormal];
	[_optionsButton setBackgroundImage:[UIImage imageNamed:@"iconForever_Active"] forState:UIControlStateHighlighted];
	[self.delegate cameraOverlayViewMakeChallengeNonExpire:self];
}

- (void)challengeOptionsViewExpire10Minutes:(HONCreateChallengeOptionsView *)createChallengeOptionsView {
	_expireType = HONChallengeExpireType10Minutes;
	
	[_optionsButton setBackgroundImage:[UIImage imageNamed:@"icon10mins_nonActive"] forState:UIControlStateNormal];
	[_optionsButton setBackgroundImage:[UIImage imageNamed:@"icon10mins_Active"] forState:UIControlStateHighlighted];
	[self.delegate cameraOverlayViewExpires10Minutes:self];
}

- (void)challengeOptionsViewExpire24Hours:(HONCreateChallengeOptionsView *)createChallengeOptionsView {
	_expireType = HONChallengeExpireType24Hours;
	
	[_optionsButton setBackgroundImage:[UIImage imageNamed:@"icon24hours_nonActive"] forState:UIControlStateNormal];
	[_optionsButton setBackgroundImage:[UIImage imageNamed:@"icon24hours_Active"] forState:UIControlStateHighlighted];
	[self.delegate cameraOverlayViewExpires24Hours:self];
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
