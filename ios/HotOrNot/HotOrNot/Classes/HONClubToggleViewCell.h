//
//  HONClubToggleViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 08:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONTableViewCell.h"
#import "HONUserClubVO.h"

@class HONClubToggleViewCell;
@protocol HONClubToggleViewCellDelegate <NSObject>
- (void)clubToggleViewCell:(HONClubToggleViewCell *)viewCell selectedClub:(HONUserClubVO *)userClubVO;
- (void)clubToggleViewCell:(HONClubToggleViewCell *)viewCell deselectedClub:(HONUserClubVO *)userClubVO;
- (void)clubToggleViewCell:(HONClubToggleViewCell *)viewCell selectAllToggled:(BOOL)isSelected;
@end

@interface HONClubToggleViewCell : HONTableViewCell
- (id)initAsSelectAllCell:(BOOL)isSelectAll;
- (void)invertSelected;
- (void)toggleSelected:(BOOL)isSelected;
- (BOOL)isSelected;

@property (nonatomic, retain) HONUserClubVO *userClubVO;
@property (nonatomic, assign) id <HONClubToggleViewCellDelegate> delegate;
@end
