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
#import "HONInviteContactsViewController.h"
#import "HONEmotionsPickerView.h"

#define PREVIEW_SIZE 176.0f

@interface HONSelfieCameraPreviewView () <HONEmotionsPickerViewDelegate, HONInsetOverlayViewDelegate, PCCandyStorePurchaseControllerDelegate>
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) NSMutableArray *subjectNames;

@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) HONInsetOverlayView *insetOverlayView;
@property (nonatomic, strong) HONEmotionsPickerView *emotionsPickerView;
@property (nonatomic, strong) HONEmotionsPickerDisplayView *emotionsDisplayView;

@property (nonatomic, strong) UIButton *overlayToggleButton;

@property (nonatomic, strong) dispatch_queue_t purchase_content_request_queue;
@end

@implementation HONSelfieCameraPreviewView
@synthesize delegate = _delegate;


- (id)initWithFrame:(CGRect)frame withPreviewImage:(UIImage *)image {
	if ((self = [super initWithFrame:frame])) {
		
		_subjectNames = [NSMutableArray array];
		_previewImage = [[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:image toSize:CGSizeMake(176.0, 224.0)] toRect:CGRectMake(0.0, 24.0, 176.0, 176.0)];
		
		NSLog(@"PREVIEW -- SRC IMAGE:[%@]\nZOOMED IMAGE:[%@]", NSStringFromCGSize(image.size), NSStringFromCGSize(_previewImage.size));
		
		_purchase_content_request_queue = dispatch_queue_create("com.builtinmenlo.selfieclub.content-request", 0);
		
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
	
	_headerView = [[HONHeaderView alloc] initWithTitle:NSLocalizedString(@"select_feeling", nil)]; //@"Select Feeling"];
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
	_emotionsPickerView.alpha = 0.0;
	_emotionsPickerView.hidden = YES;
	_emotionsPickerView.delegate = self;
	[self addSubview:_emotionsPickerView];
	
	//]~=~=~=~=~=~=~=~=~=~=~=~=~=~[]~=~=~=~=~=~=~=~=~=~=~=~=~=~[
	
	[self _showOverlay];
}


#pragma mark - Navigation
- (void)_goToggleOverlay {
	
	if (_emotionsPickerView.hidden)
		[self _showOverlay];
	
	else
		[self _removeOverlayAndRemove:NO];
}

- (void)_goBack {
//	[[UIApplication sharedApplication] performSelector:@selector(setStatusBarHidden:withAnimation:) withObject:@YES afterDelay:0.125];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	[self _removeOverlayAndRemove:YES];
}

- (void)_goSubmit {
	if ([_subjectNames count] > 0) {
		if ([self.delegate respondsToSelector:@selector(cameraPreviewViewSubmit:withSubjects:)])
			[self.delegate cameraPreviewViewSubmit:self withSubjects:_subjectNames];
	
	} else {
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_noemotions_title", nil) //@"No Emotions Selected!"
									message:NSLocalizedString(@"alert_noemotions_msg", nil) //@"You need to choose some emotions to make a status update."
								   delegate:nil
						  cancelButtonTitle:  NSLocalizedString(@"alert_ok", nil) //@"OK"
						  otherButtonTitles:nil] show];
	}
				
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
- (void)emotionsPickerView:(HONEmotionsPickerView *)emotionsPickerView selectedEmotion:(HONEmotionVO *)emotionVO {
	NSLog(@"[*:*] emotionItemView:(%@) selectedEmotion:(%@) [*:*]", self.class, emotionVO.emotionName);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step 2 - Sticker Selected"
										withEmotion:emotionVO];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if ([[HONStickerAssistant sharedInstance] candyBoxContainsContentGroupForContentGroupID:emotionVO.contentGroupID]) {
			NSLog(@"Content in CandyBox --(%@)", emotionVO.contentGroupID);
			
//			PicoSticker *sticker = [[HONStickerAssistant sharedInstance] stickerFromCandyBoxWithContentID:emotionVO.emotionID];
//			[sticker use];
//			emotionVO.picoSticker = [[HONStickerAssistant sharedInstance] stickerFromCandyBoxWithContentID:emotionVO.emotionID];
//			[emotionVO.picoSticker use];
	
		} else {
//			NSLog(@"Purchasing ContentGroup --(%@)", emotionVO.contentGroupID);
//			[[HONStickerAssistant sharedInstance] purchaseStickerPakWithContentGroupID:emotionVO.contentGroupID usingDelegate:self];
		}
	});
	
	[_subjectNames addObject:[emotionVO.emotionName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	[_emotionsDisplayView addEmotion:emotionVO];
}

- (void)emotionsPickerView:(HONEmotionsPickerView *)emotionsPickerView deselectedEmotion:(HONEmotionVO *)emotionVO {
	//NSLog(@"[*:*] emotionItemView:(%@) deselectedEmotion:(%@) [*:*]", self.class, emotionVO.emotionName);

	[_subjectNames removeObject:emotionVO.emotionName];
	[_emotionsDisplayView removeEmotion:emotionVO];
}

- (void)emotionsPickerView:(HONEmotionsPickerView *)emotionsPickerView didChangeToPage:(int)page withDirection:(int)direction {
	NSLog(@"[*:*] emotionItemView:(%@) didChangeToPage:(%d) withDirection:(%d) [*:*]", self.class, page, direction);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:[@"Camera Step 2 - Stickerboard Swipe " stringByAppendingString:(direction == 1) ? @"Right" : @"Left"]];
//	if ([[HONContactsAssistant sharedInstance] totalInvitedContacts] < [HONAppDelegate clubInvitesThreshold] && page == 1 && direction == 1) {
//		[_emotionsPickerView scrollToPage:0];
//		
//		if (_insetOverlayView == nil) {
//			_insetOverlayView = [[HONInsetOverlayView alloc] initAsType:HONInsetOverlayViewTypeUnlock];
//			_insetOverlayView.delegate = self;
//			
//			[[HONScreenManager sharedInstance] appWindowAdoptsView:_insetOverlayView];
//			[_insetOverlayView introWithCompletion:nil];
//		}
//	}
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
