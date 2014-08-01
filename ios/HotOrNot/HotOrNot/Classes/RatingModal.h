//
//  RatingModal.h
//  HotOrNot
//
//  Created by Eric on 8/1/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


@class HONInviteOverlayView;
@protocol HONInviteOverlayViewDelegate <NSObject>
@optional
- (void)inviteOverlayViewClose:(HONInviteOverlayView *)inviteOverlayView;
- (void)inviteOverlayViewInvite:(HONInviteOverlayView *)inviteOverlayView;
- (void)inviteOverlayViewSkip:(HONInviteOverlayView *)inviteOverlayView;
@end

@interface RatingModal : UIView
- (void)introWithCompletion:(void (^)(BOOL finished))completion;
- (void)outroWithCompletion:(void (^)(BOOL finished))completion;

@property (nonatomic, assign) id <HONInviteOverlayViewDelegate> delegate;
@end
