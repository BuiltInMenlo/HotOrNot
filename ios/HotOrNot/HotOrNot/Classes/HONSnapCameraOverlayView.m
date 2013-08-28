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
#import "HONSnapCameraOptionsView.h"
#import "HONUserVO.h"
#import "HONContactUserVO.h"

@interface HONSnapCameraOverlayView() <HONSnapCameraOptionsViewDelegate>
@property (nonatomic, strong) UIImageView *infoImageView;
@property (nonatomic, strong) UIView *irisView;
@property (nonatomic, strong) UIView *previewHolderView;
@property (nonatomic, strong) UIView *blackMatteView;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIImageView *circleFillImageView;
@property (nonatomic, strong) HONSnapCameraOptionsView *cameraOptionsView;
@property (nonatomic, strong) UIView *controlsHolderView;
@property (nonatomic, strong) UILabel *actionLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIButton *subscribersButton;
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
		
		_irisView = [[UIImageView alloc] initWithFrame:self.frame];
		_irisView.backgroundColor = [UIColor blackColor];
		_irisView.alpha = 0.0;
		[self addSubview:_irisView];
		
		_previewHolderView = [[UIView alloc] initWithFrame:self.frame];
		[self addSubview:_previewHolderView];
		
		_controlsHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 640.0, self.frame.size.height)];
		[self addSubview:_controlsHolderView];
		
		_actionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 16.0, 200.0, 20.0)];
		_actionLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17];
		_actionLabel.textColor = [UIColor whiteColor];
		_actionLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_actionLabel];
		
		_subscribersButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_subscribersButton.frame = CGRectMake(13.0, 27.0, 44.0, 44.0);
		[_subscribersButton setBackgroundImage:[UIImage imageNamed:@"cameraMoreButton_nonActive"] forState:UIControlStateNormal];
		[_subscribersButton setBackgroundImage:[UIImage imageNamed:@"cameraMoreButton_nonActive"] forState:UIControlStateHighlighted];
		//[_subscribersButton addTarget:self action:@selector(_goSubscribers) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_subscribersButton];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(262.0, 14.0, 44.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCloseCamera) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_cancelButton];
		
		_circleFillImageView = [[UIImageView alloc] initWithFrame:CGRectMake(261.0, self.frame.size.height - 60.0, 44.0, 44.0)];
		_circleFillImageView.image = [UIImage imageNamed:@"cameraAnimation_000"];
		[_controlsHolderView addSubview:_circleFillImageView];
				
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
	} completion:^(BOOL fininshed){
		[_blackMatteView removeFromSuperview];
	}];
}

- (void)toggleInfoOverlay:(BOOL)isIntro {
	if (isIntro) {
		_infoImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_infoImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"cameraInfoOverlay-568h@2x" : @"cameraInfoOverlay"];
		[self addSubview:_infoImageView];
		
		UIImageView *clockImageView = [[UIImageView alloc] initWithFrame:CGRectMake(261.0, self.frame.size.height - 60.0, 44.0, 44.0)];
		clockImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"cameraAnimation_001"],
										  [UIImage imageNamed:@"cameraAnimation_002"],
										  [UIImage imageNamed:@"cameraAnimation_003"],
										  [UIImage imageNamed:@"cameraAnimation_004"],
										  [UIImage imageNamed:@"cameraAnimation_005"],
										  [UIImage imageNamed:@"cameraAnimation_006"],
										  [UIImage imageNamed:@"cameraAnimation_007"],
										  [UIImage imageNamed:@"cameraAnimation_008"],
										  [UIImage imageNamed:@"cameraAnimation_009"],
										  [UIImage imageNamed:@"cameraAnimation_010"],
										  [UIImage imageNamed:@"cameraAnimation_011"],
										  [UIImage imageNamed:@"cameraAnimation_012"],
										  [UIImage imageNamed:@"cameraAnimation_013"],
										  [UIImage imageNamed:@"cameraAnimation_014"],
										  [UIImage imageNamed:@"cameraAnimation_015"],
										  [UIImage imageNamed:@"cameraAnimation_016"], nil];
		clockImageView.animationDuration = 2.5f;
		clockImageView.animationRepeatCount = 0;
		[clockImageView startAnimating];
		[_infoImageView addSubview:clockImageView];
	
	} else {
		[_infoImageView removeFromSuperview];
		_infoImageView = nil;
	}
}

- (void)takePhoto {
	_irisView.alpha = 1.0;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_irisView.alpha = 0.65;
	} completion:^(BOOL finished){}];
}

- (void)updateChallengers:(NSArray *)challengers asJoining:(BOOL)isJoining {
	_usernames = challengers;
	_actionLabel.text = (isJoining) ? [NSString stringWithFormat:@"Joining %d other%@", [challengers count], ([challengers count] != 1 ? @"s" : @"")] : [NSString stringWithFormat:@"Sending to %d subscriber%@", [challengers count], ([challengers count] != 1 ? @"s" : @"")];
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


#pragma mark - Navigation
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
