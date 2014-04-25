//
//  HONSelfieCameraClubViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 08:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONUserClubViewCell.h"

@class HONSelfieCameraClubViewCell;

@protocol HONSelfieCameraClubViewCellDelegate <HONUserClubViewCellDelegate>
- (void)selfieCameraClubViewCell:(HONSelfieCameraClubViewCell *)viewCell selectedClub:(HONUserClubVO *)userClubVO;
- (void)selfieCameraClubViewCell:(HONSelfieCameraClubViewCell *)viewCell deselectedClub:(HONUserClubVO *)userClubVO;
@end

@interface HONSelfieCameraClubViewCell : HONUserClubViewCell
- (id)initAsSelectAllCell:(BOOL)isSelectAll;
- (void)invertSelect;
- (void)toggleSelected:(BOOL)isSelected;

@property (nonatomic, assign) id <HONSelfieCameraClubViewCellDelegate> delegate;
@end
