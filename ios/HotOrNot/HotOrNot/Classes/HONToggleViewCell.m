//
//  HONToggleViewCell.m
//  HotOrNot
//
//  Created by BIM  on 1/5/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "HONToggleViewCell.h"

@interface HONToggleViewCell ()
@end


@implementation HONToggleViewCell
@synthesize delegate = _delegate;
@synthesize isSelected = _isSelected;

- (id)init {
	if ((self = [super init])) {
		[self hideChevron];
		_isSelected = NO;
		
		_selectedBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"subjectRowBG_selected"]];
		_selectedBGImageView.alpha = 0.0;
		[self.contentView addSubview:_selectedBGImageView];
	}
	
	return (self);
}

- (id)initAsSelected:(BOOL)isSelected {
	if ((self == [self init])) {
		_isSelected = isSelected;
		
		if (_isSelected)
			[self toggleSelected:YES];
	}
	
	return (self);
}

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


#pragma mark - Public APIs
- (void)invertSelected {
	[self toggleSelected:!_isSelected];
}

- (void)toggleOnWithReset:(BOOL)isReset {
	_isSelected = YES;
	
	[UIView animateWithDuration:0.125 animations:^(void) {
		_selectedBGImageView.alpha = _isSelected;
	} completion:^(BOOL finished) {
		if (isReset)
			_selectedBGImageView.alpha = 0.0;
	}];
}

- (void)toggleSelected:(BOOL)isSelected {
	_isSelected = isSelected;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_selectedBGImageView.alpha = (int)_isSelected;
	} completion:^(BOOL finished) {
	}];
}


#pragma mark - Navigation
- (void)_goDeselect{
	_isSelected = NO;
}

- (void)_goSelect {
	_isSelected = YES;
}


@end
