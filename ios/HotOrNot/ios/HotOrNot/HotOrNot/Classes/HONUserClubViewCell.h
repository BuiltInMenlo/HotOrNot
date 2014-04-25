//
//  HONUserClubViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/01/2014 @ 13:15 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONBaseRowViewCell.h"
#import "HONUserClubVO.h"


@class HONUserClubViewCell;
@protocol HONUserClubViewCellDelegate <NSObject>
@optional
- (void)userClubViewCell:(HONUserClubViewCell *)cell acceptInviteForClub:(HONUserClubVO *)userClubVO;
- (void)userClubViewCell:(HONUserClubViewCell *)cell settingsForClub:(HONUserClubVO *)userClubVO;
@end

@interface HONUserClubViewCell : HONBaseRowViewCell
- (id)initAsInviteCell:(BOOL)isInvite;
@property (nonatomic, strong) HONUserClubVO *userClubVO;
@property (nonatomic, assign) id <HONUserClubViewCellDelegate> delegate;
@end