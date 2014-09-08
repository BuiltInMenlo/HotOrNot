//
//  HONUserToggleViewCell.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/30/2014 @ 15:24 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONTableViewCell.h"
#import "HONContactUserVO.h"
#import "HONTrivialUserVO.h"
#import "HONUserClubVO.h"

@class HONUserToggleViewCell;
@protocol HONUserToggleViewCellDelegate <NSObject>
@optional
- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didDeselectContactUser:(HONContactUserVO *)contactUserVO;
- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didSelectContactUser:(HONContactUserVO *)contactUserVO;
- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell showProfileForTrivialUser:(HONTrivialUserVO *)trivialUserVO;
- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didDeselectTrivialUser:(HONTrivialUserVO *)trivialUserVO;
- (void)userToggleViewCell:(HONUserToggleViewCell *)viewCell didSelectTrivialUser:(HONTrivialUserVO *)trivialUserVO;
@end

@interface HONUserToggleViewCell : HONTableViewCell {
	UIButton *_toggledOnButton;
	UIButton *_toggledOffButton;
}

- (void)invertSelected;
- (void)toggleOnWithReset:(BOOL)isReset;
- (void)toggleSelected:(BOOL)isSelected;
- (void)toggleUI:(BOOL)isEnabled;

@property (nonatomic, retain) HONContactUserVO *contactUserVO;
@property (nonatomic, retain) HONTrivialUserVO *trivialUserVO;
@property (nonatomic, retain) HONUserClubVO *clubVO;
@property (nonatomic, assign) id <HONUserToggleViewCellDelegate> delegate;

@end
