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
#import "UIImageView+AFNetworking.h"

#import "HONSnapCameraOverlayView.h"
#import "HONImagingDepictor.h"
#import "HONUserVO.h"
#import "HONContactUserVO.h"

@interface HONSnapCameraOverlayView()
@property (nonatomic, strong) UIImageView *infoImageView;
@property (nonatomic, strong) UIView *blackMatteView;
@property (nonatomic, strong) UIView *whiteMatteView;
@property (nonatomic, strong) UILabel *actionLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *flipButton;
@end

@implementation HONSnapCameraOverlayView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
		_blackMatteView = [[UIView alloc] initWithFrame:self.frame];
		_blackMatteView.backgroundColor = [UIColor blackColor];
		_blackMatteView.hidden = YES;
		[self addSubview:_blackMatteView];
		
		UIImageView *headerBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraBackgroundHeader"]];
		[self addSubview:headerBGImageView];
		
		UIImageView *opponentsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smallPersonIcon"]];
		opponentsImageView.frame = CGRectOffset(opponentsImageView.frame, 30.0, 12.0);
		[self addSubview:opponentsImageView];
		
		_actionLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 34.0, 100.0, 20.0)];
		_actionLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17];
		_actionLabel.textColor = [UIColor whiteColor];
		_actionLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_actionLabel];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(252.0, 20.0, 64.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCloseCamera) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_cancelButton];
		
		UIButton *flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
		flashButton.frame = CGRectMake(10.0, [UIScreen mainScreen].bounds.size.height - 54.0, 44.0, 44.0);
		[flashButton setBackgroundImage:[UIImage imageNamed:@"flashButton_nonActive"] forState:UIControlStateNormal];
		[flashButton setBackgroundImage:[UIImage imageNamed:@"flashButton_Active"] forState:UIControlStateHighlighted];
//		[flashButton addTarget:self action:@selector(_goToggleFlash) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:flashButton];
		
		UIButton *takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
		takePhotoButton.frame = CGRectMake(113.0, [UIScreen mainScreen].bounds.size.height - 114.0, 94.0, 94.0);
		[takePhotoButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_nonActive"] forState:UIControlStateNormal];
		[takePhotoButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_Active"] forState:UIControlStateHighlighted];
		[takePhotoButton addTarget:self action:@selector(_goTakePhoto) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:takePhotoButton];
		
		_flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_flipButton.frame = CGRectMake(270.0, [UIScreen mainScreen].bounds.size.height - 54.0, 44.0, 44.0);
		[_flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_nonActive"] forState:UIControlStateNormal];
		[_flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_Active"] forState:UIControlStateHighlighted];
		[_flipButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_flipButton];
		
		_whiteMatteView = [[UIImageView alloc] initWithFrame:self.frame];
		_whiteMatteView.backgroundColor = [UIColor whiteColor];
		_whiteMatteView.hidden = YES;
		[self addSubview:_whiteMatteView];
	}
	
	return (self);
}


#pragma mark - Public API
- (void)intro {
	_blackMatteView.hidden = NO;
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		_blackMatteView.alpha = 0.0;
	} completion:^(BOOL fininshed) {
		_blackMatteView.hidden = YES;
		_blackMatteView.alpha = 1.0;
	}];
}

- (void)toggleInfoOverlay:(BOOL)isIntro {
	if (isIntro) {
		_infoImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_infoImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"cameraInfoOverlay-568h@2x" : @"cameraInfoOverlay"];
		[self addSubview:_infoImageView];
		
	} else {
		[_infoImageView removeFromSuperview];
		_infoImageView = nil;
	}
	
	_cancelButton.hidden = isIntro;
	_actionLabel.hidden = isIntro;
}

- (void)updateChallengers:(NSArray *)challengers asJoining:(BOOL)isJoining {
	NSLog(@"updateChallengers:[%@]", challengers);
	_actionLabel.text = [NSString stringWithFormat:@"%d", [challengers count]];
}

- (void)submitStep:(HONCreateChallengePreviewView *)previewView {
	[self addSubview:previewView];
}


#pragma mark - Navigation
- (void)_goFlipCamera {
	[self.delegate cameraOverlayViewChangeCamera:self];
}

- (void)_goToggleFlash {
	[self.delegate cameraOverlayViewChangeFlash:self];
}

- (void)_goCloseCamera {
	[self.delegate cameraOverlayViewCloseCamera:self];
}

- (void)_goTakePhoto {
	_blackMatteView.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blackMatteView.alpha = 0.33;
	} completion:^(BOOL finished) {
		_blackMatteView.hidden = YES;
	}];
	
	[self.delegate cameraOverlayViewTakePhoto:self];
}


@end
