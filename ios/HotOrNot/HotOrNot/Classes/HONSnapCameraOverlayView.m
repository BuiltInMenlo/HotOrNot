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
@property (nonatomic, strong) UIView *irisView;
@property (nonatomic, strong) UIView *blackMatteView;
@property (nonatomic, strong) UIImageView *progressBarImageView;
@property (nonatomic, strong) UILabel *actionLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *flipButton;
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
		_subscribersButton.alpha = 0.2;
		[self addSubview:_subscribersButton];
		
		_blackMatteView = [[UIView alloc] initWithFrame:self.frame];
		_blackMatteView.backgroundColor = [UIColor blackColor];
		[self addSubview:_blackMatteView];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(262.0, 14.0, 44.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCloseCamera) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_cancelButton];
		
		_flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_flipButton.frame = CGRectMake(10.0, [UIScreen mainScreen].bounds.size.height - 54.0, 44.0, 44.0);
		[_flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_nonActive"] forState:UIControlStateNormal];
		[_flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_Active"] forState:UIControlStateHighlighted];
		[_flipButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
		//[self addSubview:_flipButton];
		
		UIView *progressBarBGImageView = [[UIView alloc] initWithFrame:CGRectMake(10.0, [UIScreen mainScreen].bounds.size.height - 17.0, 300.0, 5.0)];
		progressBarBGImageView.backgroundColor = [UIColor blackColor];
		[self addSubview:progressBarBGImageView];
				
		UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
		lpGestureRecognizer.minimumPressDuration = 0.05;
		[_blackMatteView addGestureRecognizer:lpGestureRecognizer];
	}
	
	return (self);
}


#pragma mark - Public API
- (void)intro {
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		_blackMatteView.alpha = 0.0;
	} completion:^(BOOL fininshed){
		_blackMatteView.backgroundColor = [UIColor clearColor];
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
		
		[_progressBarImageView removeFromSuperview];
		_progressBarImageView = nil;
	}
	
	_cancelButton.hidden = isIntro;
	_subscribersButton.hidden = isIntro;
	_actionLabel.hidden = isIntro;
}

- (void)takePhoto {
//	[UIView animateWithDuration:0.1 animations:^(void) {
	_irisView.alpha = 1.0;
//	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_irisView.alpha = 0.33;
		} completion:^(BOOL finished){}];
//	}];
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
	
	_progressBarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, [UIScreen mainScreen].bounds.size.height - 17.0, 4.0, 5.0)];
	_progressBarImageView.image = [UIImage imageNamed:@"whiteLoader"];
	[self addSubview:_progressBarImageView];
	
	[self _animateLoader];
}

- (void)submitStep:(HONCreateChallengePreviewView *)previewView {
	[self addSubview:previewView];
}


#pragma mark - Navigation
- (void)_goFlipCamera {
	[_progressBarImageView.layer removeAllAnimations];
	[_progressBarImageView removeFromSuperview];
	_progressBarImageView = nil;
	
	[self.delegate cameraOverlayViewChangeCamera:self];
}

- (void)_goToggleFlash {
	[self.delegate cameraOverlayViewChangeFlash:self];
}

- (void)_goCloseCamera {
	[_progressBarImageView.layer removeAllAnimations];
	[_progressBarImageView removeFromSuperview];
	_progressBarImageView = nil;
	
	[self.delegate cameraOverlayViewCloseCamera:self];
}

-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	//CGPoint touchPoint = [lpGestureRecognizer locationInView:self];
	
	if (_progressBarImageView != nil) {
		[_progressBarImageView.layer removeAllAnimations];
		[_progressBarImageView removeFromSuperview];
		_progressBarImageView = nil;
	}
	
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		[self.delegate cameraOverlayView:self toggleLongPress:YES];
		
		_blackMatteView.alpha = 0.0;
		_blackMatteView.backgroundColor = [UIColor blackColor];
		[UIView animateWithDuration:0.25 animations:^(void) {
			_blackMatteView.alpha = 0.65;
		}];
		
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
		[self.delegate cameraOverlayView:self toggleLongPress:NO];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_blackMatteView.alpha = 0.0;
		} completion:^(BOOL finished) {
			_blackMatteView.backgroundColor = [UIColor clearColor];
			_blackMatteView.alpha = 1.0;
		}];
	}
}


#pragma mark - UI Presentation
- (void)_animateLoader {
	_progressBarImageView.frame = CGRectMake(10.0, [UIScreen mainScreen].bounds.size.height - 17.0, 4.0, 5.0);
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.6];
	[UIView setAnimationDelay:0.0];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	_progressBarImageView.frame = CGRectMake(10.0, [UIScreen mainScreen].bounds.size.height - 17.0, 300.0, 5.0);
	[UIView commitAnimations];
}


@end
