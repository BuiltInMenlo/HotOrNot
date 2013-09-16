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
@end

@implementation HONSnapCameraOverlayView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
		_irisView = [[UIImageView alloc] initWithFrame:self.frame];
		_irisView.backgroundColor = [UIColor blackColor];
		_irisView.alpha = 0.0;
		[self addSubview:_irisView];
		
		UIImageView *headerBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraBackgroundHeader"]];
		[self addSubview:headerBGImageView];
		
		UIImageView *opponentsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smallPersonIcon"]];
		opponentsImageView.frame = CGRectOffset(opponentsImageView.frame, 10.0, 12.0);
		[self addSubview:opponentsImageView];
		
		_actionLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 14.0, 100.0, 20.0)];
		_actionLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17];
		_actionLabel.textColor = [UIColor whiteColor];
		_actionLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_actionLabel];
		
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
		[closeButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
		[closeButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
		[closeButton addTarget:self action:@selector(_goCloseCamera) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:closeButton];
		
		_subscribersButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_subscribersButton.frame = CGRectMake(9.0, 27.0, 44.0, 44.0);
		[_subscribersButton setBackgroundImage:[UIImage imageNamed:@"cameraMoreButton_nonActive"] forState:UIControlStateNormal];
		[_subscribersButton setBackgroundImage:[UIImage imageNamed:@"cameraMoreButton_nonActive"] forState:UIControlStateHighlighted];
		//[_subscribersButton addTarget:self action:@selector(_goSubscribers) forControlEvents:UIControlEventTouchUpInside];
		_subscribersButton.alpha = 0.2;
//		[self addSubview:_subscribersButton];
		
		_blackMatteView = [[UIView alloc] initWithFrame:self.frame];
		_blackMatteView.backgroundColor = [UIColor blackColor];
//		[self addSubview:_blackMatteView];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(262.0, 14.0, 44.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCloseCamera) forControlEvents:UIControlEventTouchUpInside];
//		[self addSubview:_cancelButton];
		
		UIButton *flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
		flashButton.frame = CGRectMake(10.0, [UIScreen mainScreen].bounds.size.height - 54.0, 44.0, 44.0);
		[flashButton setBackgroundImage:[UIImage imageNamed:@"flashButton_nonActive"] forState:UIControlStateNormal];
		[flashButton setBackgroundImage:[UIImage imageNamed:@"flashButton_Active"] forState:UIControlStateHighlighted];
//		[flashButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:flashButton];
		
		UIButton *takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
		takePhotoButton.frame = CGRectMake(123.0, [UIScreen mainScreen].bounds.size.height - 104.0, 74.0, 74.0);
		[takePhotoButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_nonActive"] forState:UIControlStateNormal];
		[takePhotoButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_Active"] forState:UIControlStateHighlighted];
		[takePhotoButton addTarget:self action:@selector(_goTakePhoto) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:takePhotoButton];
		
		_flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_flipButton.frame = CGRectMake(10.0, [UIScreen mainScreen].bounds.size.height - 54.0, 44.0, 44.0);
		[_flipButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_nonActive"] forState:UIControlStateNormal];
		[_flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_Active"] forState:UIControlStateHighlighted];
		[_flipButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
		//[self addSubview:_flipButton];
		
		UIView *progressBarBGImageView = [[UIView alloc] initWithFrame:CGRectMake(10.0, [UIScreen mainScreen].bounds.size.height - 17.0, 300.0, 5.0)];
		progressBarBGImageView.backgroundColor = [UIColor blackColor];
//		[self addSubview:progressBarBGImageView];
				
//		UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
//		lpGestureRecognizer.minimumPressDuration = 0.05;
//		[_blackMatteView addGestureRecognizer:lpGestureRecognizer];
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

- (void)addMirroredPreview:(UIImage *)image {
	UIImageView *previewImageView = [[UIImageView alloc] initWithImage:image];
	previewImageView.frame = CGRectOffset(previewImageView.frame, ABS(self.frame.size.width - image.size.width) * -0.5, (-26.0 + (-26.0 * [HONAppDelegate isRetina5])) + (ABS(self.frame.size.height - image.size.height) * -0.5) - [[UIApplication sharedApplication] statusBarFrame].size.height);
	previewImageView.transform = CGAffineTransformScale(previewImageView.transform, -1.0f, 1.0f);
	[self addSubview:previewImageView];
}

- (void)updateChallengers:(NSArray *)challengers asJoining:(BOOL)isJoining {
	NSLog(@"updateChallengers:[%@]", challengers);
	_usernames = challengers;
	_actionLabel.text = [NSString stringWithFormat:@"%d", [challengers count]];//(isJoining) ? [NSString stringWithFormat:@"Joining %d other%@", [challengers count], ([challengers count] != 1 ? @"s" : @"")] : [NSString stringWithFormat:@"Sending to %d subscriber%@", [challengers count], ([challengers count] != 1 ? @"s" : @"")];
}

- (void)startProgress {
	if (_progressBarImageView != nil) {
		[_progressBarImageView removeFromSuperview];
		_progressBarImageView = nil;
	}
	
	_progressBarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, [UIScreen mainScreen].bounds.size.height - 17.0, 4.0, 5.0)];
	_progressBarImageView.image = [UIImage imageNamed:@"whiteLoader"];
//	[self addSubview:_progressBarImageView];
	
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
	NSLog(@"_goCloseCamera");
	[_progressBarImageView.layer removeAllAnimations];
	[_progressBarImageView removeFromSuperview];
	_progressBarImageView = nil;
	
	[self.delegate cameraOverlayViewCloseCamera:self];
}

- (void)_goTakePhoto {
	_irisView.alpha = 1.0;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_irisView.alpha = 0.33;
	} completion:^(BOOL finished){}];
	
	[self.delegate cameraOverlayViewTakePhoto:self];
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
