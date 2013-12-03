//
//  HONCameraOverlayView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONSnapCameraOverlayView.h"
#import "HONImagingDepictor.h"
#import "HONUserVO.h"
#import "HONContactUserVO.h"

@interface HONSnapCameraOverlayView()
@property (nonatomic, strong) UIImageView *infoImageView;
@property (nonatomic, strong) UIView *blackMatteView;
@property (nonatomic, strong) UIView *tintedMatteView;
@property (nonatomic, strong) UIView *headerBGView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *cameraRollButton;
@property (nonatomic, strong) UIButton *flipButton;
@property (nonatomic, strong) UIButton *changeTintButton;
@property (nonatomic, strong) UIButton *takePhotoButton;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic) HONSnapOverlayTint snapOverlayTint;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end

@implementation HONSnapCameraOverlayView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {//[UIColor colorWithRed:0.012 green:0.333 blue:0.827 alpha:1.0]
		
		_snapOverlayTint = HONSnapOverlayTintClear;
		_blackMatteView = [[UIView alloc] initWithFrame:self.frame];
		_blackMatteView.backgroundColor = [UIColor blackColor];
		_blackMatteView.hidden = YES;
		[self addSubview:_blackMatteView];
		
		_tintedMatteView = [[UIView alloc] initWithFrame:self.frame];
		_tintedMatteView.backgroundColor = [[HONAppDelegate colorsForOverlayTints] objectAtIndex:_snapOverlayTint];
		[self addSubview:_tintedMatteView];
		
		_headerBGView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
		_headerBGView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
		[self addSubview:_headerBGView];
		
		UIView *gutterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 142.0, 320.0, 142.0)];
		gutterView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
		[self addSubview:gutterView];
		
		_flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_flipButton.frame = CGRectMake(-2.0, 0.0, 44.0, 44.0);
		[_flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_nonActive"] forState:UIControlStateNormal];
		[_flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_Active"] forState:UIControlStateHighlighted];
		[_flipButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
		[_headerBGView addSubview:_flipButton];
		
		_cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cameraRollButton.frame = CGRectMake(138.0, 0.0, 44.0, 44.0);
		[_cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive"] forState:UIControlStateNormal];
		[_cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active"] forState:UIControlStateHighlighted];
		[_cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
		[_headerBGView addSubview:_cameraRollButton];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(248.0, 0.0, 64.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelWhiteButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelWhiteButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCloseCamera) forControlEvents:UIControlEventTouchUpInside];
		[_headerBGView addSubview:_cancelButton];
		
		_changeTintButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_changeTintButton.frame = CGRectMake(20.0, [UIScreen mainScreen].bounds.size.height - 100.0, 74.0, 74.0);
		[_changeTintButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_nonActive"] forState:UIControlStateNormal];
		[_changeTintButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_Active"] forState:UIControlStateHighlighted];
		[_changeTintButton addTarget:self action:@selector(_goChangeTint) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_changeTintButton];
		
		_takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_takePhotoButton.frame = CGRectMake(113.0, [UIScreen mainScreen].bounds.size.height - 119.0, 94.0, 94.0);
		[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_nonActive"] forState:UIControlStateNormal];
		[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_Active"] forState:UIControlStateHighlighted];
		[_takePhotoButton addTarget:self action:@selector(_goTakePhoto) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_takePhotoButton];
	}
	
	return (self);
}


#pragma mark - Public API
- (void)introWithTutorial:(BOOL)isTutorial {
	_blackMatteView.hidden = NO;
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		_blackMatteView.alpha = 0.0;
	} completion:^(BOOL fininshed) {
		_blackMatteView.hidden = YES;
		_blackMatteView.alpha = 1.0;
	}];
	
	if (isTutorial) {
//		_infoImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//		_infoImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina4Inch]) ? @"cameraInfoOverlay-568h@2x" : @"cameraInfoOverlay"];
//		[self addSubview:_infoImageView];
//		
//		UIButton *tutorialButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		tutorialButton.frame = _infoImageView.frame;
//		[tutorialButton addTarget:self action:@selector(_goCloseTutorial:) forControlEvents:UIControlEventTouchUpInside];
//		[self addSubview:tutorialButton];
//		
//		_headerBGImageView.hidden = YES;
//		_flipButton.hidden = YES;
//		_cancelButton.hidden = YES;
//		_takePhotoButton.hidden = YES;
		
		_tutorialImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate switchEnabledForKey:@"volley_brand"]) ? @"tutorial_camera_volley" : @"tutorial_camera_selfieclub"]];
		_tutorialImageView.frame = CGRectOffset(_tutorialImageView.frame, 0.0, [UIScreen mainScreen].bounds.size.height - 186.0);
		_tutorialImageView.alpha = 0.0;
		[self addSubview:_tutorialImageView];
	
		[UIView animateWithDuration:0.33 animations:^(void) {
			_tutorialImageView.alpha = 1.0;
		}];
	}
}

- (void)submitStep:(HONCreateChallengePreviewView *)previewView {
	[self addSubview:previewView];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blackMatteView.alpha = 0.0;
	} completion:^(BOOL finished) {
		_blackMatteView.hidden = YES;
	}];
}


#pragma mark - Navigation
- (void)_goCloseTutorial:(id)sender {
	[[Mixpanel sharedInstance] track:@"Create Volley - Close Overlay"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UIButton *button = (UIButton *)sender;
	[button removeFromSuperview];
	button = nil;
	
	[_infoImageView removeFromSuperview];
	_infoImageView = nil;
	
	_headerBGView.hidden = NO;
	_flipButton.hidden = NO;
	_cameraRollButton.hidden = NO;
	_cancelButton.hidden = NO;
	_takePhotoButton.hidden = NO;
	
	UIButton *closeTutorialButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeTutorialButton.frame = _tutorialImageView.frame;
	[closeTutorialButton addTarget:self action:@selector(_goCloseBubble) forControlEvents:UIControlEventTouchUpInside];
	[_tutorialImageView addSubview:closeTutorialButton];
}

- (void)_goCloseBubble {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_tutorialImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[_tutorialImageView removeFromSuperview];
		_tutorialImageView = nil;
	}];
}

- (void)_goFlipCamera {
	[self.delegate cameraOverlayViewChangeCamera:self];
}

- (void)_goToggleFlash {
	[self.delegate cameraOverlayViewChangeFlash:self];
}

- (void)_goCameraRoll {
	[self.delegate cameraOverlayViewShowCameraRoll:self];
}

- (void)_goCloseCamera {
	[self.delegate cameraOverlayViewCloseCamera:self];
}

- (void)_goTakePhoto {
	[self _goCloseBubble];
	
	_blackMatteView.hidden = NO;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_blackMatteView.alpha = 1.0;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_blackMatteView.alpha = 0.0;
		}];
	}];
	
	[self.delegate cameraOverlayViewTakePhoto:self withOverlayTint:_snapOverlayTint];
}

- (void)_goChangeTint {
	_snapOverlayTint = ++_snapOverlayTint % ([[HONAppDelegate colorsForOverlayTints] count] - 1);
	
	[[Mixpanel sharedInstance] track:@"Create Volley - Change Tint Overlay"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
//	UIColor *color = [[HONAppDelegate colorsForOverlayTints] objectAtIndex:_snapOverlayTint];
//	NSLog(@"TINT INDEX:[%d]COLOR:[%@][%f]", _snapOverlayTint, [color colorWithAlphaComponent:0.5], _tintedMatteView.alpha);
	
	[UIView beginAnimations:@"fade" context:nil];
	[UIView setAnimationDuration:0.33];
	[_tintedMatteView setBackgroundColor:[[HONAppDelegate colorsForOverlayTints] objectAtIndex:_snapOverlayTint]];
	[UIView commitAnimations];
	
	
}


@end
