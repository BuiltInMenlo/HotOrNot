//
//  HONSelfieCameraClubViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 08:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONSelfieCameraClubViewCell.h"

@interface HONSelfieCameraClubViewCell ()
@property (nonatomic) BOOL isSelectAllCell;
@property (nonatomic) BOOL isSelected;
@property (nonatomic, strong) UIImageView *selectedIndicatorImageView;
@end

@implementation HONSelfieCameraClubViewCell

- (id)initAsSelectAllCell:(BOOL)isSelectAll {
	if ((self = [super init])) {
		_isSelectAllCell = isSelectAll;
		_isSelected = NO;

		UIImageView *offIndicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greyDot"]];
		offIndicatorImageView.frame = CGRectOffset(offIndicatorImageView.frame, 285.0, 20.0);
		offIndicatorImageView.alpha = 0.0;
		[self.contentView addSubview:offIndicatorImageView];
		
		_selectedIndicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenDot"]];
		_selectedIndicatorImageView.frame = offIndicatorImageView.frame;
		_selectedIndicatorImageView.alpha = 0.0;
		[self.contentView addSubview:_selectedIndicatorImageView];
		
		UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
		toggleButton.frame = offIndicatorImageView.frame;
		[toggleButton addTarget:self action:(_isSelected) ? @selector(_goSelect) : @selector(_goDeselect) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:toggleButton];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)invertSelect {
	[self toggleSelected:!_isSelected];
}

- (void)toggleSelected:(BOOL)isSelected {
	_isSelected = isSelected;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_selectedIndicatorImageView.alpha = (int)_isSelected;
		
	} completion:^(BOOL finished) {
		
		if (_isSelected) {
			if ([self.delegate respondsToSelector:@selector(selfieCameraClubViewCell:selectedClub:)])
				[self.delegate selfieCameraClubViewCell:self selectedClub:self.userClubVO];
		
		} else {
			if ([self.delegate respondsToSelector:@selector(selfieCameraClubViewCell:deselectedClub:)])
				[self.delegate selfieCameraClubViewCell:self deselectedClub:self.userClubVO];
		}
	}];
}


#pragma mark - Navigation
- (void)_goSelect {
	[self toggleSelected:YES];
}

- (void)_goDeselect {
	[self toggleSelected:NO];
}


@end
