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
#import "HONHeaderView.h"
#import "HONUserVO.h"
#import "HONTrivialUserVO.h"
#import "HONEmotionsPickerDisplayView.h"
#import "HONEmotionsPickerView.h"

#define PREVIEW_SIZE 176.0f

@interface HONSelfieCameraPreviewView () <HONEmotionsPickerViewDelegate>
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) NSMutableArray *subjectNames;

@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) HONEmotionsPickerView *emotionsPickerView;
@property (nonatomic, strong) HONEmotionsPickerDisplayView *emotionsDisplayView;

@property (nonatomic, strong) UIButton *overlayToggleButton;
@end

@implementation HONSelfieCameraPreviewView
@synthesize delegate = _delegate;


- (id)initWithFrame:(CGRect)frame withPreviewImage:(UIImage *)image {
	if ((self = [super initWithFrame:frame])) {
		
		_subjectNames = [NSMutableArray array];
		_previewImage = [HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:image toSize:CGSizeMake(176.0, 224.0)] toRect:CGRectMake(0.0, 24.0, 176.0, 176.0)];
		
		NSLog(@"PREVIEW -- SRC IMAGE:[%@]\nZOOMED IMAGE:[%@]", NSStringFromCGSize(image.size), NSStringFromCGSize(_previewImage.size));
		
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
	
	// !]~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~[¡]~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~[! //
	
	_overlayToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_overlayToggleButton.frame = self.frame;
	[_overlayToggleButton addTarget:self action:@selector(_goToggleOverlay) forControlEvents:UIControlEventTouchDown];
	[self addSubview:_overlayToggleButton];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"Select Feeling"];
	[self addSubview:_headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 1.0, 93.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:backButton];
	
	UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextButton.frame = CGRectMake(227.0, 1.0, 93.0, 44.0);
	[nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_nonActive"] forState:UIControlStateNormal];
	[nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_Active"] forState:UIControlStateHighlighted];
	[nextButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:nextButton];
		
	//]~=~=~=~=~=~=~=~=~=~=~=~=~=~[]~=~=~=~=~=~=~=~=~=~=~=~=~=~[
	
	_emotionsDisplayView = [[HONEmotionsPickerDisplayView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.frame.size.height - (kNavHeaderHeight + 308.0)) withPreviewImage:_previewImage];
	_emotionsDisplayView.alpha = 0.0;
	_emotionsDisplayView.hidden = YES;
	[self addSubview:_emotionsDisplayView];
		
	_emotionsPickerView = [[HONEmotionsPickerView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 308.0, 320.0, 308.0)];
//	_emotionsPickerView.frame = CGRectOffset(_emotionsPickerView.frame, 0.0, self.frame.size.height);
	_emotionsPickerView.alpha = 0.0;
	_emotionsPickerView.hidden = YES;
	_emotionsPickerView.delegate = self;
	[self addSubview:_emotionsPickerView];
	
	//]~=~=~=~=~=~=~=~=~=~=~=~=~=~[]~=~=~=~=~=~=~=~=~=~=~=~=~=~[
	
	[self _showOverlay];
}


#pragma mark - Navigation
- (void)_goToggleOverlay {
	[[HONAnalyticsParams sharedInstance] trackEvent:[@"Main Camera - Toggle Overlay " stringByAppendingString:(_emotionsPickerView.hidden) ? @"Up" : @"Down"]];
	
	if (_emotionsPickerView.hidden)
		[self _showOverlay];
	
	else
		[self _removeOverlayAndRemove:NO];
}

- (void)_goBack {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Main Camera - Back"];
//	[[UIApplication sharedApplication] performSelector:@selector(setStatusBarHidden:withAnimation:) withObject:@YES afterDelay:0.125];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	[self _removeOverlayAndRemove:YES];
}

- (void)_goSubmit {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Main Camera - Submit"];
	
	if ([self.delegate respondsToSelector:@selector(cameraPreviewViewSubmit:withSubjects:)])
		[self.delegate cameraPreviewViewSubmit:self withSubjects:_subjectNames];
				
}


#pragma mark - UI Presentation
- (void)_showOverlay {
	_emotionsDisplayView.hidden = NO;
	_emotionsPickerView.hidden = NO;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_emotionsDisplayView.alpha = 1.0;
		_emotionsPickerView.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
}

- (void)_removeOverlayAndRemove:(BOOL)isRemoved {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_emotionsPickerView.alpha = 0.0;
		_emotionsDisplayView.alpha = 0.0;
		
		if (isRemoved)
			_headerView.alpha = 0.0;
		
	} completion:^(BOOL finished) {
		_emotionsPickerView.hidden = YES;
		_emotionsDisplayView.hidden = YES;
		
		if (isRemoved) {
			[self removeFromSuperview];
			
		if ([self.delegate respondsToSelector:@selector(cameraPreviewViewBackToCamera:)])
			[self.delegate cameraPreviewViewBackToCamera:self];
		}
	}];
}


#pragma mark - EmotionsPickerView Delegates
- (void)emotionsPickerView:(HONEmotionsPickerView *)emotionsPickerView selectedEmotion:(HONEmotionVO *)emotionVO {
	NSLog(@"[*:*] emotionItemView:(%@) selectedEmotion:(%@) [*:*]", self.class, emotionVO.emotionName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Main Camera - Selected Emotion"
										withEmotion:emotionVO];
	
	
	[_subjectNames addObject:[emotionVO.emotionName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	[_emotionsDisplayView addEmotion:emotionVO];
}

- (void)emotionsPickerView:(HONEmotionsPickerView *)emotionsPickerView deselectedEmotion:(HONEmotionVO *)emotionVO {
	//NSLog(@"[*:*] emotionItemView:(%@) deselectedEmotion:(%@) [*:*]", self.class, emotionVO.emotionName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Main Camera - Deselected Emotion"
										withEmotion:emotionVO];
	
	[_subjectNames removeObject:emotionVO.emotionName];
	[_emotionsDisplayView removeEmotion:emotionVO];
}



@end
