//
//  HONSelfieCameraClubViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 08:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONTableViewCell.h"
#import "HONUserClubVO.h"

@class HONSelfieCameraClubViewCell;
@protocol HONSelfieCameraClubViewCellDelegate <NSObject>
- (void)selfieCameraClubViewCell:(HONSelfieCameraClubViewCell *)viewCell selectedClub:(HONUserClubVO *)userClubVO;
- (void)selfieCameraClubViewCell:(HONSelfieCameraClubViewCell *)viewCell deselectedClub:(HONUserClubVO *)userClubVO;
- (void)selfieCameraClubViewCell:(HONSelfieCameraClubViewCell *)viewCell selectAllToggled:(BOOL)isSelected;
@end

@interface HONSelfieCameraClubViewCell : HONTableViewCell
- (id)initAsSelectAllCell:(BOOL)isSelectAll;
- (void)invertSelected;
- (void)toggleSelected:(BOOL)isSelected;
- (BOOL)isSelected;

@property (nonatomic, retain) HONUserClubVO *userClubVO;
@property (nonatomic, assign) id <HONSelfieCameraClubViewCellDelegate> delegate;
@end
