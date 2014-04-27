//
//  HONCreateChallengePreviewView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.15.13 @ 17:17 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIImage+ImageEffects.h"
#import "UIImageView+AFNetworking.h"

#import "HONSelfieCameraPreviewView.h"
#import "HONUserVO.h"
#import "HONTrivialUserVO.h"
#import "HONEmotionsPickerDisplayView.h"
#import "HONEmotionsPickerView.h"

@interface HONSelfieCameraPreviewView () <HONEmotionsPickerViewDelegate>
@property (nonatomic, assign, readonly) HONSelfieCameraSubmitType selfieSubmitType;
@property (nonatomic, strong) NSArray *recipients;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) NSString *creatorSubjectName;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) HONEmotionsPickerView *emotionsPickerView;

@property (nonatomic, strong) HONEmotionsPickerDisplayView *emotionsDisplayView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *overlayToggleButton;
@end

@implementation HONSelfieCameraPreviewView
@synthesize delegate = _delegate;


- (id)initWithFrame:(CGRect)frame withPreviewImage:(UIImage *)image asSubmittingType:(HONSelfieCameraSubmitType)selfieSubmitType withSubject:(NSString *)subject withRecipients:(NSArray *)recipients {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor whiteColor];
		
		_previewImage = [HONImagingDepictor scaleImage:image byFactor:([UIScreen mainScreen].bounds.size.height / 1280.0) * 2.0];
		_selfieSubmitType = selfieSubmitType;
		
		NSLog(@"PREVIEW -- SRC IMAGE:[%@]\nZOOMED IMAGE:[%@]", NSStringFromCGSize(image.size), NSStringFromCGSize(_previewImage.size));
		
		_subjectName = subject;
		_creatorSubjectName = (_selfieSubmitType == HONSelfieCameraSubmitTypeReplyChallenge) ? [NSString stringWithFormat:@"%@ : ", _subjectName] : @"";
		_recipients = recipients;
		
		[self _adoptUI];
	}
	
	return (self);
}


#pragma mark - Puplic APIs
- (void)uploadComplete {
	NSLog(@"uploadComplete");
}


#pragma mark - UI Presentation
- (void)_adoptUI {
	
	_previewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ABS(self.frame.size.width - (_previewImage.size.width * 0.5)) * -0.5, ABS(self.frame.size.height - (_previewImage.size.height * 0.5)) * ((self.frame.size.height < (_previewImage.size.height * 0.5)) ? -0.5 : 0.0), _previewImage.size.width * 0.5, _previewImage.size.height * 0.5)];
	_previewImageView.image = _previewImage;
	[self addSubview:_previewImageView];
	
	_blurredImageView = [[UIImageView alloc] initWithImage:[_previewImage applyBlurWithRadius:0.0
																					tintColor:[UIColor clearColor]
																		saturationDeltaFactor:1.0 maskImage:nil]];
	_blurredImageView.frame = _previewImageView.frame;
	_blurredImageView.alpha = 0.0;
//	[self addSubview:_blurredImageView];
	
	// !]~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~[¡]~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~[! //
	
	_overlayToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_overlayToggleButton.frame = self.frame;
	[_overlayToggleButton addTarget:self action:@selector(_goToggleOverlay) forControlEvents:UIControlEventTouchDown];
	[self addSubview:_overlayToggleButton];
	
	_headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
	_headerView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	[self addSubview:_headerView];
	
	UIButton *retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	retakeButton.frame = CGRectMake(10.0, 2.0, 64.0, 44.0);
	[retakeButton setBackgroundImage:[UIImage imageNamed:@"cameraReTakeButton_nonActive"] forState:UIControlStateNormal];
	[retakeButton setBackgroundImage:[UIImage imageNamed:@"cameraReTakeButton_Active"] forState:UIControlStateHighlighted];
	[retakeButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchDown];
	[_headerView addSubview:retakeButton];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake(236.0, 1.0, 74.0, 44.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"cameraSubmitButton_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"cameraSubmitButton_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchDown];
	[_headerView addSubview:submitButton];
		
	//]~=~=~=~=~=~=~=~=~=~=~=~=~=~[]~=~=~=~=~=~=~=~=~=~=~=~=~=~[
	
	_emotionsDisplayView = [[HONEmotionsPickerDisplayView alloc] initWithFrame:CGRectMake(10.0, 44.0, 300.0, 20.0) withExistingEmotions:[NSArray array]];
	_emotionsDisplayView.alpha = 0.0;
	_emotionsDisplayView.hidden = YES;
	[self addSubview:_emotionsDisplayView];
	
	_emotionsPickerView = [[HONEmotionsPickerView alloc] init];
	_emotionsPickerView.frame = CGRectOffset(_emotionsPickerView.frame, 0.0, self.frame.size.height);
	_emotionsPickerView.alpha = 0.0;
	_emotionsPickerView.hidden = YES;
	_emotionsPickerView.delegate = self;
	[self addSubview:_emotionsPickerView];
}


#pragma mark - Navigation
- (void)_goToggleOverlay {
	[[HONAnalyticsParams sharedInstance] trackEventWithUserProperty:[NSString stringWithFormat:@"Main Camera - Toggle Overlay %@", (_emotionsPickerView.hidden) ? @"Up" : @"Down"]];
	
	if (_emotionsPickerView.hidden)
		[self _showOverlay];
	
	else
		[self _removeOverlayAndRemove:NO];
}

- (void)_goClose {
	[[HONAnalyticsParams sharedInstance] trackEventWithUserProperty:@"Main Camera - Close"];
	
	[self _removeOverlayAndRemove:YES];
	[self.delegate cameraPreviewViewClose:self];
}

- (void)_goBack {
	[[HONAnalyticsParams sharedInstance] trackEventWithUserProperty:@"Main Camera - Back"];
	
	[self _removeOverlayAndRemove:YES];
	[self.delegate cameraPreviewViewBackToCamera:self];
}

- (void)_goSubmit {
	[[HONAnalyticsParams sharedInstance] trackEventWithUserProperty:@"Main Camera - Submit"];
	
	[self _removeOverlayAndRemove:YES];
	[self.delegate cameraPreviewViewSubmit:self withSubject:_subjectName];
}


#pragma mark - UI Presentation
- (void)_showOverlay {
	_emotionsDisplayView.hidden = NO;
	_emotionsPickerView.hidden = NO;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_emotionsPickerView.frame = CGRectOffset(_emotionsPickerView.frame, 0.0, -_emotionsPickerView.frame.size.height); //265
	} completion:^(BOOL finished) {
	}];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blurredImageView.alpha = 1.0;
		_emotionsDisplayView.alpha = 1.0;
		_emotionsPickerView.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
}

- (void)_removeOverlayAndRemove:(BOOL)isRemoved {
	[UIView animateWithDuration:0.20 animations:^(void) {
		_emotionsPickerView.frame = CGRectOffset(_emotionsPickerView.frame, 0.0, _emotionsPickerView.frame.size.height);
	} completion:^(BOOL finished) {
	}];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blurredImageView.alpha = 0.0;
		_emotionsDisplayView.alpha = 0.0;
		_emotionsPickerView.alpha = 0.0;
		
	} completion:^(BOOL finished) {
		_emotionsDisplayView.hidden = YES;
		_emotionsPickerView.hidden = YES;
		
		if (isRemoved)
			[self removeFromSuperview];
	}];
}


#pragma mark - EmotionsPickerView Delegates
- (void)emotionsPickerView:(HONEmotionsPickerView *)emotionsPickerView selectedEmotion:(HONEmotionVO *)emotionVO {
	//NSLog(@"[*:*] emotionItemView:(%@) selectedEmotion:(%@) [*:*]", emotionsPickerView.class, emotionVO.emotionName);
	
	[[HONAnalyticsParams sharedInstance] trackEventWithUserProperty:@"Main Camera - Selected Emotion"
												  includeProperties:[[HONAnalyticsParams sharedInstance] propertyForEmotion:emotionVO]];
	
	[_emotionsDisplayView addEmotion:emotionVO];
}

- (void)emotionsPickerView:(HONEmotionsPickerView *)emotionsPickerView deselectedEmotion:(HONEmotionVO *)emotionVO {
	//NSLog(@"[*:*] emotionItemView:(%@) deselectedEmotion:(%@) [*:*]", emotionsPickerView.class, emotionVO.emotionName);
	
	[[HONAnalyticsParams sharedInstance] trackEventWithUserProperty:@"Main Camera - Deselected Emotion"
												  includeProperties:[[HONAnalyticsParams sharedInstance] propertyForEmotion:emotionVO]];
	
	[_emotionsDisplayView removeEmotion:emotionVO];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
	}
}


@end
