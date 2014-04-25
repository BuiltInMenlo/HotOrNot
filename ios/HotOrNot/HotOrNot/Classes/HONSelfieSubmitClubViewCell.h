//
//  HONSelfieSubmitClubViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 08:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONUserClubViewCell.h"

@class HONSelfieSubmitClubViewCell;

@protocol HONSelfieSubmitClubViewCellDelegate <HONUserClubViewCellDelegate>
- (void)selfieSubmitClubViewCell:(HONSelfieSubmitClubViewCell *)viewCell selectedClub:(HONUserClubVO *)userClubVO;
- (void)selfieSubmitClubViewCell:(HONSelfieSubmitClubViewCell *)viewCell deselectedClub:(HONUserClubVO *)userClubVO;
@end

@interface HONSelfieSubmitClubViewCell : HONUserClubViewCell
- (id)initAsSelectAllCell:(BOOL)isSelectAll;
- (void)invertSelect;
- (void)toggleSelected:(BOOL)isSelected;

@property (nonatomic, assign) id <HONSelfieSubmitClubViewCellDelegate> delegate;
@end
