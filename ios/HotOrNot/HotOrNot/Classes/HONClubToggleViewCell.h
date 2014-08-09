//
//  HONClubToggleViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 08:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONTableViewCell.h"
#import "HONUserClubVO.h"

typedef NS_ENUM(NSInteger, HONClubToggleViewCellType) {
	HONClubToggleViewCellTypeClub = 0,
	HONClubToggleViewCellTypeSelectAll,
	HONClubToggleViewCellTypeCreateClub
};

@class HONClubToggleViewCell;
@protocol HONClubToggleViewCellDelegate <NSObject>
- (void)clubToggleViewCell:(HONClubToggleViewCell *)viewCell selectedClub:(HONUserClubVO *)userClubVO;
- (void)clubToggleViewCell:(HONClubToggleViewCell *)viewCell deselectedClub:(HONUserClubVO *)userClubVO;
@optional
- (void)clubToggleViewCell:(HONClubToggleViewCell *)viewCell selectAllToggled:(BOOL)isSelected;
@end

@interface HONClubToggleViewCell : HONTableViewCell
- (id)initAsCellType:(HONClubToggleViewCellType)viewCellType;
- (void)invertSelected;
- (void)toggleOnWithReset:(BOOL)isReset;
- (void)toggleSelected:(BOOL)isSelected;
- (void)toggleIndicator:(BOOL)isEnabled;
- (BOOL)isSelected;

@property (nonatomic, retain) HONUserClubVO *userClubVO;
@property (nonatomic, assign) id <HONClubToggleViewCellDelegate> delegate;
@end
