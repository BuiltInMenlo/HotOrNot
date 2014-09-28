//
//  HONToggleTableViewCell.h
//  HotOrNot
//
//  Created by BIM  on 9/12/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONTableViewCell.h"


@class HONToggleViewCell;
@protocol HONToggleViewCellDelegate <NSObject>
@optional
- (void)toggleViewCell:(HONToggleViewCell *)viewCell changedToState:(BOOL)isSelected;
@end

@interface HONToggleViewCell : HONTableViewCell {
	UIImageView *_toggledOffButton;
	UIImageView *_toggledOnButton;
}

+ (NSString *)cellReuseIdentifier;
- (id)initAsSelected:(BOOL)isSelected;
- (void)invertSelected;
- (void)toggleSelected:(BOOL)isSelected;
- (void)toggleOnWithReset:(BOOL)isReset;

- (void)_goSelect;
- (void)_goDeselect;

@property (nonatomic) BOOL isSelected;
@property (nonatomic, assign) id <HONToggleViewCellDelegate> delegate;
@end
