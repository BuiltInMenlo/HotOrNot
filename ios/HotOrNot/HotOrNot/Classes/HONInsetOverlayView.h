//
//  HONInsetOverlayView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 08/01/2014 @ 14:30 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONUserClubVO.h"

@class HONInsetOverlayView;
@protocol HONInsetOverlayViewDelegate <NSObject>
- (void)insetOverlayViewDidClose:(HONInsetOverlayView *)view;
@optional
- (void)insetOverlayViewDidUnlock:(HONInsetOverlayView *)view;
- (void)insetOverlayViewDidInvite:(HONInsetOverlayView *)view;
- (void)insetOverlayViewDidReview:(HONInsetOverlayView *)view;
- (void)insetOverlayViewDidAskForSuggestions:(HONInsetOverlayView *)view;

- (void)insetOverlayViewCopyPersonalClub:(HONInsetOverlayView *)view;
- (void)insetOverlayView:(HONInsetOverlayView *)view createSuggestedClub:(HONUserClubVO *)clubVO;
- (void)insetOverlayView:(HONInsetOverlayView *)view thresholdClub:(HONUserClubVO *)clubVO;
@end

@interface HONInsetOverlayView : UIView {
	UIImageView *_framingImageView;
	UIButton *_acknowledgeButton;
}

- (id)initAsType:(HONInsetOverlayViewType)insetType;
- (void)introWithCompletion:(void (^)(BOOL finished))completion;
- (void)outroWithCompletion:(void (^)(BOOL finished))completion;

@property (nonatomic, assign) id <HONInsetOverlayViewDelegate> delegate;
@end
