//
//  HONInviteOverlayView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 22:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//
typedef enum{
    Overlaytypeinvite = 0,
    Overlaytypeunlock
} Overlaytype;
@class HONInviteOverlayView;
@protocol HONInviteOverlayViewDelegate <NSObject>
@optional
- (void)inviteOverlayViewClose:(HONInviteOverlayView *)inviteOverlayView;
- (void)inviteOverlayViewInvite:(HONInviteOverlayView *)inviteOverlayView;
- (void)inviteOverlayViewSkip:(HONInviteOverlayView *)inviteOverlayView;
@end

@interface HONInviteOverlayView : UIView
- (id)initWithOverlayType:(Overlaytype)type;
- (void)introWithCompletion:(void (^)(BOOL finished))completion;
- (void)outroWithCompletion:(void (^)(BOOL finished))completion;

@property (nonatomic, assign) id <HONInviteOverlayViewDelegate> delegate;
@end
