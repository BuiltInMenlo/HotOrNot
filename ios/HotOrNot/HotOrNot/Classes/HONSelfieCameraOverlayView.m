//
//  HONSelfieCameraOverlayView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONSelfieCameraOverlayView.h"
#import "HONDeviceIntrinsics.h"
#import "HONImagingDepictor.h"
#import "HONUserVO.h"
#import "HONContactUserVO.h"

@interface HONSelfieCameraOverlayView()
@property (nonatomic, strong) UIImageView *infoImageView;
@property (nonatomic, strong) UIView *blackMatteView;
@property (nonatomic, strong) UIView *tintedMatteView;
@property (nonatomic, strong) UIView *headerBGView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *cameraRollButton;
@property (nonatomic, strong) UIButton *flipButton;
@property (nonatomic, strong) UIButton *changeTintButton;
@property (nonatomic, strong) UIButton *takePhotoButton;
@property (nonatomic) int tintIndex;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end

@implementation HONSelfieCameraOverlayView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
		_tintIndex = 0;
		_blackMatteView = [[UIView alloc] initWithFrame:self.frame];
		_blackMatteView.backgroundColor = [UIColor blackColor];
		_blackMatteView.hidden = YES;
		[self addSubview:_blackMatteView];
		
		UIImageView *gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraGradientOverlay"]];
		gradientImageView.frame = self.frame;
		[self addSubview:gradientImageView];
		
		_tintedMatteView = [[UIView alloc] initWithFrame:self.frame];
		_tintedMatteView.backgroundColor = [[HONAppDelegate colorsForOverlayTints] objectAtIndex:_tintIndex];
		[self addSubview:_tintedMatteView];
		
		_headerBGView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)];
		[self addSubview:_headerBGView];
				
		_flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_flipButton.frame = CGRectMake(0.0, 0.0, 64.0, 64.0);
		[_flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_nonActive"] forState:UIControlStateNormal];
		[_flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_Active"] forState:UIControlStateHighlighted];
		[_flipButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
		[_headerBGView addSubview:_flipButton];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(222.0, 0.0, 93.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelWhiteButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelWhiteButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCloseCamera) forControlEvents:UIControlEventTouchUpInside];
		[_headerBGView addSubview:_cancelButton];
		
		_changeTintButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_changeTintButton.frame = CGRectMake(-5.0, [UIScreen mainScreen].bounds.size.height - 60.0, 64.0, 64.0);
		[_changeTintButton setBackgroundImage:[UIImage imageNamed:@"filterIcon_nonActive"] forState:UIControlStateNormal];
		[_changeTintButton setBackgroundImage:[UIImage imageNamed:@"filterIcon_Active"] forState:UIControlStateHighlighted];
		[_changeTintButton addTarget:self action:@selector(_goChangeTint) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_changeTintButton];
		
		_takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_takePhotoButton.frame = CGRectMake(112.0, [UIScreen mainScreen].bounds.size.height - 113.0, 94.0, 94.0);
		[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_nonActive"] forState:UIControlStateNormal];
		[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_Active"] forState:UIControlStateHighlighted];
		[_takePhotoButton addTarget:self action:@selector(_goTakePhoto) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_takePhotoButton];
		
		_cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cameraRollButton.frame = CGRectMake(222.0, [UIScreen mainScreen].bounds.size.height - 45.0, 93.0, 44.0);
		[_cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRollButton_nonActive"] forState:UIControlStateNormal];
		[_cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRollButton_Active"] forState:UIControlStateHighlighted];
		[_cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_cameraRollButton];
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
	}
}

- (void)submitStep:(HONSelfieCameraPreviewView *)previewView {
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
	_blackMatteView.hidden = NO;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_blackMatteView.alpha = 1.0;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_blackMatteView.alpha = 0.0;
		}];
	}];
	
	[self.delegate cameraOverlayViewTakePhoto:self withTintIndex:_tintIndex];
}

- (void)_goChangeTint {
	_tintIndex = ++_tintIndex % [[HONAppDelegate colorsForOverlayTints] count];
	
	[[Mixpanel sharedInstance] track:@"Create Volley - Change Tint Overlay"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
//	UIColor *color = [[HONAppDelegate colorsForOverlayTints] objectAtIndex:_snapOverlayTint];
//	NSLog(@"TINT:[%@]", [color colorWithAlphaComponent:0.5]);
	
	[UIView beginAnimations:@"fade" context:nil];
	[UIView setAnimationDuration:0.33];
	[_tintedMatteView setBackgroundColor:[[HONAppDelegate colorsForOverlayTints] objectAtIndex:_tintIndex]];
	[UIView commitAnimations];
}


@end
