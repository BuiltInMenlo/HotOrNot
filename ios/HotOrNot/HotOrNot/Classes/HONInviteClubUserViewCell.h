//
//  HONInviteClubUserViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/01/2014 @ 14:08 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONBaseAvatarViewCell.h"

@class HONInviteClubUserViewCell;
@protocol HONInviteClubUserViewCellDelegate <HONBaseAvatarViewCellDelegate>
- (void)inviteClubUserViewCell:(HONInviteClubUserViewCell *)viewCell toggleBlock:(BOOL)isSelected forUser:(HONTrivialUserVO *)vo;
- (void)inviteClubUserViewCell:(HONInviteClubUserViewCell *)viewCell toggleInvite:(BOOL)isSelected forUser:(HONTrivialUserVO *)vo;
@optional
- (void)inviteClubUserViewCell:(HONInviteClubUserViewCell *)viewCell clearSelectionForUser:(HONTrivialUserVO *)vo;
@end

@interface HONInviteClubUserViewCell : HONBaseAvatarViewCell
+ (NSString *)cellReuseIdentifier;

- (void)clearSelection;
- (void)toggleBlocked:(BOOL)isSelected;
- (void)toggleInvited:(BOOL)isSelected;

@property (nonatomic, assign) id<HONInviteClubUserViewCellDelegate> delegate;
@end
