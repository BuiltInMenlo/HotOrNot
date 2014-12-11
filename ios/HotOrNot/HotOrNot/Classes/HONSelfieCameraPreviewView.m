//
//  HONCreateChallengePreviewView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.15.13 @ 17:17 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "NSString+DataTypes.h"
#import "UIImage+ImageEffects.h"
#import "UIImageView+AFNetworking.h"

#import "HONSelfieCameraPreviewView.h"
#import "HONHeaderView.h"
#import "HONComposeDisplayView.h"
#import "HONStickerButtonsPickerView.h"

@interface HONSelfieCameraPreviewView () <HONComposeDisplayViewDelegate, HONStickerButtonsPickerViewDelegate>
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) NSMutableArray *subjectNames;
@property (nonatomic, strong) NSMutableArray *selectedEmotions;
@property (nonatomic, strong) NSMutableArray *emotionsPickerViews;
@property (nonatomic, strong) NSMutableArray *emotionsPickerButtons;
@property (nonatomic, strong) UIView *emotionsPickerHolderView;
@property (nonatomic, strong) UIView *tabButtonsHolderView;
@property (nonatomic, strong) UIImageView *bgSelectImageView;

@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) HONComposeDisplayView *emotionsDisplayView;

@property (nonatomic, strong) dispatch_queue_t purchase_content_request_queue;
@end

@implementation HONSelfieCameraPreviewView
@synthesize delegate = _delegate;


- (id)initWithFrame:(CGRect)frame withPreviewImage:(UIImage *)image {
	if ((self = [super initWithFrame:frame])) {
		_selectedEmotions = [NSMutableArray array];
		_subjectNames = [NSMutableArray array];
		_emotionsPickerViews = [NSMutableArray array];
		_emotionsPickerButtons = [NSMutableArray array];
		_previewImage = [[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:image toSize:CGSizeMake(176.0, 224.0)] toRect:CGRectMake(0.0, 24.0, 176.0, 176.0)];
		
		NSLog(@"PREVIEW -- SRC IMAGE:[%@]\nZOOMED IMAGE:[%@]", NSStringFromCGSize(image.size), NSStringFromCGSize(_previewImage.size));
		
		_purchase_content_request_queue = dispatch_queue_create("com.builtinmenlo.selfieclub.content-request", 0);
		
		[self _adoptUI];
	}
	
	return (self);
}

- (void)dealloc {
	_emotionsDisplayView.delegate = nil;
}


#pragma mark - Puplic APIs
- (NSArray *)getSubjectNames {
	return (_subjectNames);
}

- (void)updateProcessedAnimatedImageView:(FLAnimatedImageView *)animatedImageView {
	[_emotionsDisplayView updatePreviewWithAnimatedImageView:animatedImageView];
}

- (void)updateProcessedImage:(UIImage *)image {
	[_emotionsDisplayView updatePreview:[[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:image toSize:CGSizeMake(852.0, kSnapLargeSize.height * 2.0)] toRect:CGRectMake(106.0, 0.0, kSnapLargeSize.width * 2.0, kSnapLargeSize.height * 2.0)]];
}

- (void)enableSubmitButton {
	[_nextButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - UI Presentation
- (void)_adoptUI {
	
	//]~=~=~=~=~=~=~=~=~=~=~=~=~=~[]~=~=~=~=~=~=~=~=~=~=~=~=~=~[
	
	_emotionsDisplayView = [[HONComposeDisplayView alloc] initWithFrame:self.frame];
	_emotionsDisplayView.delegate = self;
	[self addSubview:_emotionsDisplayView];
	
	_emotionsPickerHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 221.0, 320.0, 221.0)];
	[self addSubview:_emotionsPickerHolderView];
	
	_tabButtonsHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 44.0, 320.0, 44.0)];
	[self addSubview:_tabButtonsHolderView];

	for (int i=0; i<5; i++) {
		HONStickerButtonsPickerView *pickerView = [[HONStickerButtonsPickerView alloc] initWithFrame:CGRectMakeFromSize(CGSizeMake(320.0, 221.0)) asGroupIndex:i];
		[_emotionsPickerViews addObject:pickerView];
		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.frame = CGRectMake(i * 64.0, 0.0, 64.0, 44.0);
		[button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"stickerTab-%02d_nonActive", (i+1)]] forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"stickerTab-%02d_Active", (i+1)]] forState:UIControlStateHighlighted];
		[button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"stickerTab-%02d_Selected", (i+1)]] forState:UIControlStateSelected];
		[button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"stickerTab-%02d_Selected", (i+1)]] forState:(UIControlStateHighlighted|UIControlStateSelected)];
		[button addTarget:self action:@selector(_goGroup:) forControlEvents:UIControlEventTouchUpInside];
		[button setSelected:(i == 0)];
		[button setTag:i];
		[_tabButtonsHolderView addSubview:button];
	}
	
	
	
	HONStickerButtonsPickerView *pickerView = (HONStickerButtonsPickerView *)[_emotionsPickerViews firstObject];
	pickerView.delegate = self;
	[pickerView preloadImages];
	[_emotionsPickerHolderView addSubview:pickerView];
	
	//]~=~=~=~=~=~=~=~=~=~=~=~=~=~[]~=~=~=~=~=~=~=~=~=~=~=~=~=~[
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"Edit"];
	[self addSubview:_headerView];
	
	_closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_closeButton.frame = CGRectMake(-2.0, 1.0, 44.0, 44.0);
	[_closeButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
	[_closeButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
	[_closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:_closeButton];
	
	_nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_nextButton.frame = CGRectMake(282.0, 1.0, 44.0, 44.0);
	[_nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_nonActive"] forState:UIControlStateNormal];
	[_nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_Active"] forState:UIControlStateHighlighted];
	[_nextButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:_nextButton];
}


#pragma mark - Navigation
- (void)_goClose {
	[self _removeOverlayAndRemove:YES];
}

- (void)_goSubmit {
	if ([_subjectNames count] > 0) {
		if ([self.delegate respondsToSelector:@selector(cameraPreviewViewSubmit:withSubjects:)])
			[self.delegate cameraPreviewViewSubmit:self withSubjects:_subjectNames];
		
		[_nextButton removeTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	
	} else {
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_noemotions_title", @"")
									message:NSLocalizedString(@"alert_noemotions_msg", @"Please select a sticker to submit.")
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
	}
}

- (void)_goGroup:(id)sender {
	UIButton *button = (UIButton *)sender;
	
	int groupIndex = button.tag;
	if (groupIndex != 4) {
		[_tabButtonsHolderView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			UIButton *btn = (UIButton *)obj;
			[btn setSelected:(btn.tag == groupIndex)];
		}];
	}
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Change Emotion Group"
									 withProperties:@{@"index"	: [@"" stringFromInt:groupIndex]}];
	
	[_emotionsPickerViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONStickerButtonsPickerView *pickerView = (HONStickerButtonsPickerView *)obj;
		
		if (pickerView.stickerGroupIndex == groupIndex) {
			if (pickerView.stickerGroupIndex == 4) {
				if ([self.delegate respondsToSelector:@selector(cameraPreviewViewShowStore:)])
					[self.delegate cameraPreviewViewShowStore:self];
			
			} else {
				for (UIView *view in _emotionsPickerHolderView.subviews) {
					((HONStickerButtonsPickerView *)view).delegate = nil;
					[view removeFromSuperview];
				}
				
				pickerView.frame = CGRectOffset(pickerView.frame, 0.0, 0.0);
				pickerView.delegate = self;
				[pickerView preloadImages];
				[_emotionsPickerHolderView addSubview:pickerView];
				[UIView animateWithDuration:0.333 delay:0.000
					 usingSpringWithDamping:0.750 initialSpringVelocity:0.010
									options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent) animations:^(void) {
									 pickerView.frame = CGRectOffset(pickerView.frame, 0.0, 0.0);
								 } completion:^(BOOL finished) {
								 }];
			}
		}
	}];
}

- (void)_goDelete {
	HONEmotionVO *emotionVO = (HONEmotionVO *)[_selectedEmotions lastObject];
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Sticker Deleted"
										withEmotion:emotionVO];
	
	if ([_subjectNames count] > 0)
		[_subjectNames removeLastObject];

	if ([_subjectNames count] == 0) {
		[_subjectNames removeAllObjects];
		_subjectNames = nil;
		_subjectNames = [NSMutableArray array];
		}
	
	[_emotionsDisplayView removeLastEmotion];
	[_headerView transitionTitle:([_subjectNames count] > 0) ? [_subjectNames lastObject] : @"Compose"];
}


#pragma mark - UI Presentation
- (void)_removeOverlayAndRemove:(BOOL)isRemoved {
	if (isRemoved) {
		if ([self.delegate respondsToSelector:@selector(cameraPreviewViewCancel:)])
			[self.delegate cameraPreviewViewCancel:self];
	}
}


#pragma mark - EmotionsPickerView Delegates
- (void)stickerButtonsPickerView:(HONStickerButtonsPickerView *)emotionsPickerView selectedEmotion:(HONEmotionVO *)emotionVO {
	NSLog(@"[*:*] emotionItemView:(%@) selectedEmotion:(%@) [*:*]", self.class, emotionVO.emotionName);
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Sticker Selected"
										withEmotion:emotionVO];
	
//	dispatch_async(dispatch_get_main_queue(), ^{
//		if ([[HONStickerAssistant sharedInstance] candyBoxContainsContentGroupForContentGroupID:emotionVO.contentGroupID]) {
//			NSLog(@"Content in CandyBox --(%@)", emotionVO.contentGroupID);
//			
////			PicoSticker *sticker = [[HONStickerAssistant sharedInstance] stickerFromCandyBoxWithContentID:emotionVO.emotionID];
////			[sticker use];
////			emotionVO.picoSticker = [[HONStickerAssistant sharedInstance] stickerFromCandyBoxWithContentID:emotionVO.emotionID];
////			[emotionVO.picoSticker use];
//	
//		} else {
////			NSLog(@"Purchasing ContentGroup --(%@)", emotionVO.contentGroupID);
////			[[HONStickerAssistant sharedInstance] purchaseStickerPakWithContentGroupID:emotionVO.contentGroupID usingDelegate:self];
//		}
//	});
	
	if (emotionsPickerView.stickerGroupIndex == 3) {
		NSString *imgURL = [NSString stringWithFormat:@"http://s3.amazonaws.com/hotornot-challenges/%@Large_640x1136.%@", emotionVO.emotionName, @"gif"];// (emotionVO.imageType == HONEmotionImageTypeGIF) ? @"gif" : @"jpg"];
		NSLog(@"imgURL:[%@]", imgURL);
		_bgSelectImageView = [[UIImageView alloc] initWithFrame:CGRectMakeFromSize(kSnapLargeSize)];
		[_bgSelectImageView setImageWithURL:[NSURL URLWithString:imgURL]];
		
		if (emotionVO.imageType == HONEmotionImageTypeGIF)
			[_emotionsDisplayView updatePreviewWithAnimatedImageView:emotionVO.animatedImageView];
		
		else
			[_emotionsDisplayView updatePreview:_bgSelectImageView.image];
		
		if ([self.delegate respondsToSelector:@selector(cameraPreviewView:selectedBackground:)])
			[self.delegate cameraPreviewView:self selectedBackground:[[imgURL componentsSeparatedByString:@"/"] lastObject]];
		
	} else {
		[_headerView transitionTitle:emotionVO.emotionName];
		[_selectedEmotions addObject:emotionVO];
		[_subjectNames addObject:emotionVO.emotionName];
		[_emotionsDisplayView addEmotion:emotionVO];
	}
}

- (void)emotionsPickerView:(HONStickerButtonsPickerView *)emotionsPickerView didChangeToPage:(int)page withDirection:(int)direction {
//	NSLog(@"[*:*] emotionItemView:(%@) didChangeToPage:(%d) withDirection:(%d) [*:*]", self.class, page, direction);
	//[[HONAnalyticsReporter sharedInstance] trackEvent:[@"Camera Step - Stickerboard Swipe " stringByAppendingString:(direction == 1) ? @"Right" : @"Left"]];
}


#pragma mark - EmotionsPickerDisplayView Delegates
- (void)emotionsPickerDisplayViewGoFullScreen:(HONComposeDisplayView *)pickerDisplayView {
	NSLog(@"[*:*] emotionsPickerDisplayViewGoFullScreen:(%@) [*:*]", self.class);
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Hide Stickerboard"];
	
	[_tabButtonsHolderView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		UIButton *btn = (UIButton *)obj;
		[btn setSelected:NO];
	}];
	
	for (UIView *view in _emotionsPickerHolderView.subviews) {
		((HONStickerButtonsPickerView *)view).delegate = nil;
		[UIView animateWithDuration:0.333 delay:0.000
			 usingSpringWithDamping:0.800 initialSpringVelocity:0.010
							options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction)
						 animations:^(void) {
							 view.frame = CGRectOffset(view.frame, 0.0, 64.0);
						 } completion:^(BOOL finished) {
							 view.frame = CGRectOffset(view.frame, 0.0, -64.0);
							 [view removeFromSuperview];
						 }];
	}
}

- (void)emotionsPickerDisplayViewShowCamera:(HONComposeDisplayView *)pickerDisplayView {
	if ([self.delegate respondsToSelector:@selector(cameraPreviewViewShowCamera:)])
		[self.delegate cameraPreviewViewShowCamera:self];
}

- (void)emotionsPickerDisplayView:(HONComposeDisplayView *)pickerDisplayView scrolledEmotionsToIndex:(int)index fromDirection:(int)dir {
//	NSLog(@"[*:*] emotionsPickerDisplayView:(%@) scrolledEmotionsToIndex:(%d/%d) fromDirection:(%d) [*:*]", self.class, index, MIN(MAX(0, index), [_selectedEmotions count] - 1), dir);
	
	if ([_subjectNames count] == 0) {
		[_headerView transitionTitle:@""];
		
	} else {
		int ind = MIN(MAX(0, index), [_subjectNames count] - 1);
		if (![_headerView.title isEqualToString:[_subjectNames objectAtIndex:ind]])
			[_headerView transitionTitle:[_subjectNames objectAtIndex:ind]];
	}
}

@end
