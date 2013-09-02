//
//  HONUserProfileView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 9/1/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol HONUserProfileViewDelegate;
@interface HONUserProfileView : UIView
- (void)show;
- (void)hide;

@property (nonatomic, assign) id <HONUserProfileViewDelegate> delegate;
@property (nonatomic) BOOL isOpen;
@end


@protocol HONUserProfileViewDelegate
- (void)userProfileViewChangeAvatar:(HONUserProfileView *)userProfileView;
- (void)userProfileViewInviteFriends:(HONUserProfileView *)userProfileView;
- (void)userProfileViewPromote:(HONUserProfileView *)userProfileView;
- (void)userProfileViewSettings:(HONUserProfileView *)userProfileView;
@end