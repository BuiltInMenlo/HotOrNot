//
//  HONToggleViewCell.h
//  HotOrNot
//
//  Created by BIM  on 1/5/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "HONTableViewCell.h"

@class HONToggleViewCell;
@protocol HONToggleViewCellDelegate <HONTableViewCellDelegate>
@optional
- (void)toggleViewCell:(HONToggleViewCell *)viewCell changedToState:(BOOL)isSelected;
@end

@interface HONToggleViewCell : HONTableViewCell {
	UIImageView *_selectedBGImageView;
	UILabel *_captionLabel;
	UIButton *_selectButton;
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
