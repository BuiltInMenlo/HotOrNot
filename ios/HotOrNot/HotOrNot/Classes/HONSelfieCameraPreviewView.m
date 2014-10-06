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

#import "PCCandyStorePurchaseController.h"

#import "HONSelfieCameraPreviewView.h"
#import "HONInsetOverlayView.h"
#import "HONHeaderView.h"
#import "HONUserVO.h"
#import "HONTrivialUserVO.h"
#import "HONEmotionsPickerDisplayView.h"
#import "HONEmotionsPickerView.h"

#define PREVIEW_SIZE 176.0f

@interface HONSelfieCameraPreviewView () <HONEmotionsPickerDisplayViewDelegate, HONEmotionsPickerViewDelegate, HONInsetOverlayViewDelegate, PCCandyStorePurchaseControllerDelegate>
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) NSMutableArray *subjectNames;
@property (nonatomic, strong) NSMutableArray *selectedEmotions;
@property (nonatomic, strong) NSMutableArray *emotionsPickerViews;
@property (nonatomic, strong) NSMutableArray *emotionsPickerButtons;
@property (nonatomic, strong) UIView *emotionsPickerHolderView;
@property (nonatomic, strong) UIView *tabButtonsHolderView;

@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) HONInsetOverlayView *insetOverlayView;
//@property (nonatomic, strong) HONEmotionsPickerView *emotionsPickerView;

@property (nonatomic, strong) HONEmotionsPickerDisplayView *emotionsDisplayView;

@property (nonatomic, strong) dispatch_queue_t purchase_content_request_queue;
@end

@implementation HONSelfieCameraPreviewView
@synthesize delegate = _delegate;


- (id)initWithFrame:(CGRect)frame withPreviewImage:(UIImage *)image {
	if ((self = [super initWithFrame:frame])) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_reloadEmotionPicker:)
													 name:@"RELOAD_EMOTION_PICKER" object:nil];
		
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

- (void)updateProcessedImage:(UIImage *)image {
	[_closeButton setBackgroundImage:[UIImage imageNamed:@"closeLightButton_nonActive"] forState:UIControlStateNormal];
	[_closeButton setBackgroundImage:[UIImage imageNamed:@"closeLightButtonActive"] forState:UIControlStateHighlighted];
	[_nextButton setBackgroundImage:[UIImage imageNamed:@"nextLightButton_nonActive"] forState:UIControlStateNormal];
	[_nextButton setBackgroundImage:[UIImage imageNamed:@"nextLightButton_Active"] forState:UIControlStateHighlighted];
	
	[_headerView toggleLightStyle:YES];
	[_emotionsDisplayView updatePreview:[[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:image toSize:CGSizeMake(852.0, kSnapLargeSize.height * 2.0)] toRect:CGRectMake(106.0, 0.0, kSnapLargeSize.width * 2.0, kSnapLargeSize.height * 2.0)]];
}

- (void)enableSubmitButton {
//	[_nextButton removeTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[_nextButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - UI Presentation
- (void)_adoptUI {
	
	//]~=~=~=~=~=~=~=~=~=~=~=~=~=~[]~=~=~=~=~=~=~=~=~=~=~=~=~=~[
	
	_emotionsDisplayView = [[HONEmotionsPickerDisplayView alloc] initWithFrame:self.frame withPreviewImage:_previewImage];
	_emotionsDisplayView.delegate = self;
	[self addSubview:_emotionsDisplayView];
	
	NSArray *assetNames = @[@"popularTab",
							@"emojiTab",
							@"quotesTab",
							@"stickersTab"];

	_emotionsPickerHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 290.0, 320.0, 241.0)];
	[self addSubview:_emotionsPickerHolderView];
	
	_tabButtonsHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 49.0, 320.0, 49.0)];
	_tabButtonsHolderView.backgroundColor = [[HONColorAuthority sharedInstance] honDebugDefaultColor];
	[self addSubview:_tabButtonsHolderView];

	for (HONStickerGroupType i=HONStickerGroupTypeStickers; i<=HONStickerGroupTypeObjects; i++) {
		HONEmotionsPickerView *pickerView = [[HONEmotionsPickerView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 241.0) asEmotionGroupType:i];
		[_emotionsPickerViews addObject:pickerView];
		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.frame = CGRectMake(i * 64.0, 0.0, 64.0, 49.0);
		[button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_nonActive", [assetNames objectAtIndex:i]]] forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_Active", [assetNames objectAtIndex:i]]] forState:UIControlStateHighlighted];
		[button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_Tapped", [assetNames objectAtIndex:i]]] forState:UIControlStateSelected];
		[button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_Tapped", [assetNames objectAtIndex:i]]] forState:(UIControlStateHighlighted|UIControlStateSelected)];
		[button addTarget:self action:@selector(_goGroup:) forControlEvents:UIControlEventTouchDown];
		[button setSelected:(i == HONStickerGroupTypeStickers)];
		[button setTag:i];
		[_tabButtonsHolderView addSubview:button];
	}
	
	HONEmotionsPickerView *pickerView = (HONEmotionsPickerView *)[_emotionsPickerViews firstObject];
	pickerView.delegate = self;
	[_emotionsPickerHolderView addSubview:pickerView];
	
	//]~=~=~=~=~=~=~=~=~=~=~=~=~=~[]~=~=~=~=~=~=~=~=~=~=~=~=~=~[
	
	_headerView = [[HONHeaderView alloc] initWithTitleUsingCartoGothic:@""];
	_headerView.frame = CGRectOffset(_headerView.frame, 0.0, -10.0);
	[_headerView removeBackground];
	[self addSubview:_headerView];
	
	_closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_closeButton.frame = CGRectMake(6.0, 2.0, 44.0, 44.0);
	[_closeButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
	[_closeButton setBackgroundImage:[UIImage imageNamed:@"closeButtonActive"] forState:UIControlStateHighlighted];
	[_closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:_closeButton];
	
	_nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_nextButton.frame = CGRectMake(276.0, 2.0, 44.0, 44.0);
	[_nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_nonActive"] forState:UIControlStateNormal];
	[_nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_Active"] forState:UIControlStateHighlighted];
	[_nextButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:_nextButton];
	
	
	UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	deleteButton.frame = CGRectMake(4 * 64.0, 0.0, 64.0, 49.0);
	[deleteButton setBackgroundImage:[UIImage imageNamed:@"emojiDeleteButton_nonActive"] forState:UIControlStateNormal];
	[deleteButton setBackgroundImage:[UIImage imageNamed:@"emojiDeleteButton_Active"] forState:UIControlStateHighlighted];
	[deleteButton addTarget:self action:@selector(_goDelete) forControlEvents:UIControlEventTouchDown];
	[_tabButtonsHolderView addSubview:deleteButton];
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
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_noemotions_title", @"You must select a foreground sticker to submit")
									message:NSLocalizedString(@"alert_noemotions_msg", @"")
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
	}
}

- (void)_goGroup:(id)sender {
	UIButton *button = (UIButton *)sender;
	
	[_tabButtonsHolderView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		UIButton *btn = (UIButton *)obj;
		[btn setSelected:btn.tag == button.tag];
	}];
	
//	[button setSelected:YES];
	
	HONStickerGroupType groupType = button.tag;
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Change Emotion Group"
									 withProperties:@{@"index"	: [@"" stringFromInt:groupType]}];
	
	for (UIView *view in _emotionsPickerHolderView.subviews) {
		((HONEmotionsPickerView *)view).delegate = nil;
//		[UIView animateWithDuration:0.125 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction)
//						 animations:^(void) {
//							 view.frame = CGRectOffset(view.frame, 0.0, 49.0);
//							 view.alpha = 0.0;
//						 } completion:^(BOOL finished) {
//							 view.frame = CGRectOffset(view.frame, 0.0, -49.0);
//							 [view removeFromSuperview];
//							 view.alpha = 1.0;
//						 }];
		
		[view removeFromSuperview];
	}
	
	[_emotionsPickerViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONEmotionsPickerView *pickerView = (HONEmotionsPickerView *)obj;
		
		if (pickerView.stickerGroupType == groupType) {
			pickerView.delegate = self;
			pickerView.alpha = 0.5;
			pickerView.frame = CGRectOffset(pickerView.frame, 0.0, 32.0);
			[_emotionsPickerHolderView addSubview:pickerView];
			[UIView animateWithDuration:0.333 delay:0.025
				 usingSpringWithDamping:0.800 initialSpringVelocity:0.010
								options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent) animations:^(void) {
								 pickerView.frame = CGRectOffset(pickerView.frame, 0.0, -32.0);
								 pickerView.alpha = 1.0;
							 } completion:^(BOOL finished) {
							 }];
			
		}
	}];
}

- (void)_goDelete {
	HONEmotionVO *emotionVO = (HONEmotionVO *)[_selectedEmotions lastObject];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Sticker Deleted"
										withEmotion:emotionVO];
	
//	if (emotionVO != nil) {
//		[_selectedEmotions removeObject:emotionVO];
//		[_subjectNames removeObject:emotionVO.emotionName];//] inRange:NSMakeRange([_subjectNames count] - 1, 1)];
		
//		if ([_selectedEmotions count] > 0)
//			[_selectedEmotions removeLastObject];
//
		if ([_subjectNames count] > 0)
			[_subjectNames removeLastObject];
	
		if ([_subjectNames count] == 0) {
//			[_selectedEmotions removeAllObjects];
			
			[_subjectNames removeAllObjects];
			_subjectNames = nil;
			_subjectNames = [NSMutableArray array];
//			[_emotionsDisplayView flushEmotions];
		}
	
	[_emotionsDisplayView removeLastEmotion];
		
		[_headerView transitionTitle:([_subjectNames count] > 0) ? [_subjectNames lastObject] : @""];
//	}
}


#pragma mark - Notifications
- (void)_reloadEmotionPicker:(NSNotification *)notification {
//	HONEmotionsPickerView *pickerView = (HONEmotionsPickerView *)[_emotionsPickerViews firstObject];
//	[pickerView reload];
}


#pragma mark - UI Presentation
- (void)_removeOverlayAndRemove:(BOOL)isRemoved {
	if (isRemoved) {
		if ([self.delegate respondsToSelector:@selector(cameraPreviewViewCancel:)])
			[self.delegate cameraPreviewViewCancel:self];
	}
}


#pragma mark - CandyStorePurchaseController
- (void)purchaseController:(id)controller downloadedStickerWithId:(NSString *)contentId {
	NSLog(@"[*:*] purchaseController:downloadedStickerWithId:[%@]", contentId);
}

-(void)purchaseController:(id)controller downloadStickerWithIdFailed:(NSString *)contentId {
	NSLog(@"[*:*] purchaseController:downloadedStickerWithIdFailed:[%@]", contentId);
}

- (void)purchaseController:(id)controller purchasedStickerWithId:(NSString *)contentId userInfo:(NSDictionary *)userInfo {
	NSLog(@"[*:*] purchaseController:purchasedStickerWithId:[%@] userInfo:[%@]", contentId, userInfo);
}

- (void)purchaseController:(id)controller purchaseStickerWithIdFailed:(NSString *)contentId userInfo:(NSDictionary *)userInfo {
	NSLog(@"[*:*] purchaseController:purchaseStickerWithIdFailed:[%@] userInfo:[%@]", contentId, userInfo);
}

- (void)purchaseController:(id)controller downloadedStickerPackWithId:(NSString *)contentGroupId {
	NSLog(@"[*:*] purchaseController:downloadedStickerPackWithId:[%@]", contentGroupId);
}

- (void)purchaseController:(id)controller downloadStickerPackWithIdFailed:(NSString *)contentGroupId {
	NSLog(@"[*:*] purchaseController:downloadStickerPackWithIdFailed:[%@]", contentGroupId);
}

- (void)purchaseController:(id)controller purchasedStickerPackWithId:(NSString *)contentGroupId userInfo:(NSDictionary *)userInfo {
	NSLog(@"[*:*] purchaseController:downloadStickerPackWithIdFailed:[%@] userInfo:[%@]", contentGroupId, userInfo);
}

- (void)purchaseController:(id)controller purchaseStickerPackWithContentGroupFailed:(PCContentGroup *)contentGroup userInfo:(NSDictionary *)userInfo {
	NSLog(@"[*:*] purchaseController:purchaseStickerPackWithContentGroupFailed:[%@] userInfo:[%@]", contentGroup, userInfo);
}


#pragma mark - EmotionsPickerView Delegates
- (void)emotionsPickerDisplayViewGoFullScreen:(HONEmotionsPickerDisplayView *)pickerDisplayView {
	NSLog(@"[*:*] emotionsPickerDisplayViewGoFullScreen:(%@) [*:*]", self.class);
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Hide Stickerboard"];
	
	[_tabButtonsHolderView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		UIButton *btn = (UIButton *)obj;
		[btn setSelected:NO];
	}];
	
	for (UIView *view in _emotionsPickerHolderView.subviews) {
		((HONEmotionsPickerView *)view).delegate = nil;
		[UIView animateWithDuration:0.333 delay:0.000
			 usingSpringWithDamping:0.800 initialSpringVelocity:0.010
							options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction)
						 animations:^(void) {
							 view.frame = CGRectOffset(view.frame, 0.0, 64.0);
							 view.alpha = 0.0;
						 } completion:^(BOOL finished) {
							 view.frame = CGRectOffset(view.frame, 0.0, -64.0);
							 [view removeFromSuperview];
							 view.alpha = 1.0;
						 }];
	}
}

- (void)emotionsPickerView:(HONEmotionsPickerView *)emotionsPickerView selectedEmotion:(HONEmotionVO *)emotionVO {
	NSLog(@"[*:*] emotionItemView:(%@) selectedEmotion:(%@) [*:*]", self.class, emotionVO.emotionName);
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Sticker Selected"
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
	
	[_headerView transitionTitle:emotionVO.emotionName];
	[_selectedEmotions addObject:emotionVO];
	[_subjectNames addObject:emotionVO.emotionName];
	[_emotionsDisplayView addEmotion:emotionVO];
}

//- (void)emotionsPickerView:(HONEmotionsPickerView *)emotionsPickerView deselectedEmotion:(HONEmotionVO *)emotionVO {
////	NSLog(@"[*:*] emotionItemView:(%@) deselectedEmotion:(%@) [*:*]", self.class, emotionVO.emotionName);
//	
//	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Sticker Deleted"
//										withEmotion:emotionVO];
//	
//	[_subjectNames removeObject:emotionVO.emotionName inRange:NSMakeRange([_subjectNames count] - 1, 1)];
//	[_emotionsDisplayView removeEmotion:emotionVO];
//	
//	[_headerView transitionTitle:([_subjectNames count] > 0) ? [_subjectNames lastObject] : @""];
//}

//- (void)emotionsPickerView:(HONEmotionsPickerView *)emotionsPickerView changeGroup:(HONStickerGroupType)groupType {
//	NSLog(@"[*:*] emotionItemView:(%@) changeGroup:(%@) [*:*]", self.class, (groupType == HONStickerGroupTypeStickers) ? @"STICKERS" : (groupType == HONStickerGroupTypeFaces) ? @"FACES" : (groupType == HONStickerGroupTypeAnimals) ? @"ANIMALS" : (groupType == HONStickerGroupTypeObjects) ? @"OBJECTS" : @"OTHER");
//	
//	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Change Emotion Group"
//									 withProperties:@{@"type"	: (groupType == HONStickerGroupTypeStickers) ? @"stickers" : (groupType == HONStickerGroupTypeFaces) ? @"faces" : (groupType == HONStickerGroupTypeAnimals) ? @"animals" : (groupType == HONStickerGroupTypeObjects) ? @"objects" : @"other"}];
//	
//	for (UIView *view in self.subviews) {
//		if (view.tag >= 69) {
//			((HONEmotionsPickerView *)view).delegate = nil;
//			[view removeFromSuperview];
//		}
//	}
//	
//	[_emotionsPickerViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		HONEmotionsPickerView *pickerView = (HONEmotionsPickerView *)obj;
//		
//		if (pickerView.stickerGroupType == groupType) {
//			pickerView.delegate = self;
//			[self addSubview:pickerView];
//		}
//		
////		pickerView.hidden = (pickerView.stickerGroupType != groupType);
////		[UIView animateWithDuration:0.25 animations:^(void) {
////			pickerView.alpha = (int)(pickerView.stickerGroupType == groupType);
////		} completion:^(BOOL finished) {
////		}];
//	}];
//}

- (void)emotionsPickerView:(HONEmotionsPickerView *)emotionsPickerView didChangeToPage:(int)page withDirection:(int)direction {
//	NSLog(@"[*:*] emotionItemView:(%@) didChangeToPage:(%d) withDirection:(%d) [*:*]", self.class, page, direction);
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:[@"Camera Step - Stickerboard Swipe " stringByAppendingString:(direction == 1) ? @"Right" : @"Left"]];
//	if ([[HONContactsAssistant sharedInstance] totalInvitedContacts] < [HONAppDelegate clubInvitesThreshold] && page == 2 && direction == 1) {
//		if (!_emotionsPickerView.hidden) {
//			[_emotionsPickerView disablePagesStartingAt:2];
//			[_emotionsPickerView scrollToPage:1];
//			
//			if (_insetOverlayView == nil)
//				_insetOverlayView = [[HONInsetOverlayView alloc] initAsType:HONInsetOverlayViewTypeUnlock];
//			_insetOverlayView.delegate = self;
//			
//			[[HONScreenManager sharedInstance] appWindowAdoptsView:_insetOverlayView];
//			[_insetOverlayView introWithCompletion:nil];
//		}
//	}
}


#pragma mark - EmotionsPickerDisplayView Delegates
- (void)emotionsPickerDisplayViewShowCamera:(HONEmotionsPickerDisplayView *)pickerDisplayView {
	if ([self.delegate respondsToSelector:@selector(cameraPreviewViewShowCamera:)])
		[self.delegate cameraPreviewViewShowCamera:self];
}

- (void)emotionsPickerDisplayView:(HONEmotionsPickerDisplayView *)pickerDisplayView scrolledEmotionsToIndex:(int)index fromDirection:(int)dir {
//	NSLog(@"[*:*] emotionsPickerDisplayView:(%@) scrolledEmotionsToIndex:(%d/%d) fromDirection:(%d) [*:*]", self.class, index, MIN(MAX(0, index), [_selectedEmotions count] - 1), dir);
	
	if ([_subjectNames count] == 0) {
		[_headerView transitionTitle:@""];
	} else {
	int ind = MIN(MAX(0, index), [_subjectNames count] - 1);
//	HONEmotionVO *vo = (HONEmotionVO *)[_selectedEmotions objectAtIndex:ind];
	if (![_headerView.title isEqualToString:[_subjectNames objectAtIndex:ind]]) {
		[_headerView transitionTitle:[_subjectNames objectAtIndex:ind]];
	}
	}
}


#pragma mark - InsetOverlay Delegates
- (void)insetOverlayViewDidClose:(HONInsetOverlayView *)view {
	[_insetOverlayView outroWithCompletion:^(BOOL finished) {
		[_insetOverlayView removeFromSuperview];
		_insetOverlayView = nil;
	}];
}

- (void)insetOverlayViewDidUnlock:(HONInsetOverlayView *)view {
	[_insetOverlayView outroWithCompletion:^(BOOL finished) {
		[_insetOverlayView removeFromSuperview];
		_insetOverlayView = nil;
		
		if ([self.delegate respondsToSelector:@selector(cameraPreviewViewShowInviteContacts:)])
			[self.delegate cameraPreviewViewShowInviteContacts:self];
	}];
}


@end
