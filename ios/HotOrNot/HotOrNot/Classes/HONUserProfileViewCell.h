//
//  HONUserProfileViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 2/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONUserVO.h"


@protocol HONUserProfileViewCellDelegate;
@interface HONUserProfileViewCell : UITableViewCell
+ (NSString *)cellReuseIdentifier;
- (void)updateCell;

@property (nonatomic, assign) id <HONUserProfileViewCellDelegate> delegate;
@property (nonatomic, retain) HONUserVO *userVO;
@end


@protocol HONUserProfileViewCellDelegate
@optional
- (void)userProfileViewCellMore:(HONUserProfileViewCell *)cell asProfile:(BOOL)isUser;
- (void)userProfileViewCellShowSettings:(HONUserProfileViewCell *)cell;
- (void)userProfileViewCellFindFriends:(HONUserProfileViewCell *)cell;
- (void)userProfileViewCellTakeNewAvatar:(HONUserProfileViewCell *)cell;
- (void)userProfileViewCell:(HONUserProfileViewCell *)cell showUserTimeline:(HONUserVO *)userVO;
- (void)userProfileViewCell:(HONUserProfileViewCell *)cell addFriend:(HONUserVO *)userVO;
- (void)userProfileViewCell:(HONUserProfileViewCell *)cell removeFriend:(HONUserVO *)userVO;
- (void)userProfileViewCell:(HONUserProfileViewCell *)cell snapAtUser:(HONUserVO *)userVO;
@end