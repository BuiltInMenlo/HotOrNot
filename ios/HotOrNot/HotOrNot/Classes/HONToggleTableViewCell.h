//
//  HONToggleTableViewCell.h
//  HotOrNot
//
//  Created by BIM  on 9/12/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONTableViewCell.h"


@class HONToggleTableViewCell;
@protocol HONToggleTableViewCellDelegate <NSObject>
@optional
- (void)tableToggleViewCell:(HONToggleTableViewCell *)viewCell toggledToState:(BOOL)isSelected;
@end

@interface HONToggleTableViewCell : HONTableViewCell {
	UIButton *_toggledOffButton;
	UIButton *_toggledOnButton;
}

+ (NSString *)cellReuseIdentifier;
- (id)initAsSelected:(BOOL)isSelected;
- (void)invertSelected;
- (void)toggleUI:(BOOL)isEnabled;
- (void)toggleSelected:(BOOL)isSelected;
- (void)toggleOnWithReset:(BOOL)isReset;

- (void)_goSelect;
- (void)_goDeselect;

@property (nonatomic) BOOL isSelected;
@property (nonatomic, assign) id <HONToggleTableViewCellDelegate> delegate;
@end
