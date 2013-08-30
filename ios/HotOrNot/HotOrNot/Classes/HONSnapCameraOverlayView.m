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
#import "HONUserVO.h"
#import "HONContactUserVO.h"

@interface HONSnapCameraOverlayView()
@property (nonatomic, strong) UIImageView *infoImageView;
@property (nonatomic, strong) UIView *irisView;
@property (nonatomic, strong) UIView *blackMatteView;
@property (nonatomic, strong) UIImageView *progressBarImageView;
@property (nonatomic, strong) UILabel *actionLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *subscribersButton;
@property (nonatomic, strong) NSArray *usernames;
@property (readonly, nonatomic, assign) HONChallengeExpireType expireType;
@end

@implementation HONSnapCameraOverlayView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame withSubject:(NSString *)subject withUsername:(NSString *)username {
	if ((self = [super initWithFrame:frame])) {
		_usernames = [NSArray arrayWithObject:username];
		
		//NSLog(@"HONSnapCameraOverlayView:initWithFrame:withSubject:[%@] withUsername:[%@]", subject, username);
		//hide overlay - [self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"OverlayCoverCamera-568h@2x" : @"OverlayCoverCamera"]]];
		
		_irisView = [[UIImageView alloc] initWithFrame:self.frame];
		_irisView.backgroundColor = [UIColor blackColor];
		_irisView.alpha = 0.0;
		[self addSubview:_irisView];
		
		_actionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 16.0, 200.0, 20.0)];
		_actionLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17];
		_actionLabel.textColor = [UIColor whiteColor];
		_actionLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_actionLabel];
		
		_subscribersButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_subscribersButton.frame = CGRectMake(9.0, 27.0, 44.0, 44.0);
		[_subscribersButton setBackgroundImage:[UIImage imageNamed:@"cameraMoreButton_nonActive"] forState:UIControlStateNormal];
		[_subscribersButton setBackgroundImage:[UIImage imageNamed:@"cameraMoreButton_nonActive"] forState:UIControlStateHighlighted];
		//[_subscribersButton addTarget:self action:@selector(_goSubscribers) forControlEvents:UIControlEventTouchUpInside];
		_subscribersButton.alpha = 0.5;
		[self addSubview:_subscribersButton];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(262.0, 14.0, 44.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCloseCamera) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_cancelButton];
		
		_blackMatteView = [[UIView alloc] initWithFrame:self.frame];
		_blackMatteView.backgroundColor = [UIColor blackColor];
		[self addSubview:_blackMatteView];
	}
	
	return (self);
}


#pragma mark - Public API
- (void)intro {
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
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
		
		_progressBarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 2.0) * 0.5, 4.0, 2.0)];
		_progressBarImageView.image = [UIImage imageNamed:@"whiteLoader"];
		[self addSubview:_progressBarImageView];
		
		[self _animateLoader:YES];
	
	} else {
		[_infoImageView removeFromSuperview];
		_infoImageView = nil;
		
		[_progressBarImageView removeFromSuperview];
		_progressBarImageView = nil;
	}
}

- (void)takePhoto {
	_irisView.alpha = 1.0;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_irisView.alpha = 0.65;
	} completion:^(BOOL finished){}];
	
//	_progressBarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"whiteLoader"]];
//	_progressBarImageView.frame = CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 2.0) * 0.5, 320.0, 2.0);
//	[self addSubview:_progressBarImageView];
}

- (void)updateChallengers:(NSArray *)challengers asJoining:(BOOL)isJoining {
	_usernames = challengers;
	_actionLabel.text = (isJoining) ? [NSString stringWithFormat:@"Joining %d other%@", [challengers count], ([challengers count] != 1 ? @"s" : @"")] : [NSString stringWithFormat:@"Sending to %d subscriber%@", [challengers count], ([challengers count] != 1 ? @"s" : @"")];
}

- (void)startProgress {
	if (_progressBarImageView != nil) {
		[_progressBarImageView removeFromSuperview];
		_progressBarImageView = nil;
	}
	
	_progressBarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 2.0) * 0.5, 4.0, 2.0)];
	_progressBarImageView.image = [UIImage imageNamed:@"whiteLoader"];
	[self addSubview:_progressBarImageView];
	
	[self _animateLoader:NO];
}

- (void)submitStep:(HONCreateChallengePreviewView *)previewView {
	[self addSubview:previewView];
}


#pragma mark - Navigation
- (void)_goToggleFlash {
	[self.delegate cameraOverlayViewChangeFlash:self];
}

- (void)_goCloseCamera {
	[self.delegate cameraOverlayViewCloseCamera:self];
}

#pragma mark - UI Presentation
- (void)_animateLoader:(BOOL)isRepeating {
	if (_progressBarImageView != nil) {
		[UIView animateWithDuration:1.6 animations:^(void) {
			_progressBarImageView.frame = CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 2.0) * 0.5, 320.0, 2.0);
		} completion:^(BOOL fishished) {
			if (isRepeating) {
				_progressBarImageView.frame = CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 2.0) * 0.5, 4.0, 2.0);
				[self _animateLoader:YES];
			
			} else {
//				[_progressBarImageView removeFromSuperview];
//				_progressBarImageView = nil;
			}
		}];
	}
}


@end
