//
//  HONToggleTableViewCell.m
//  HotOrNot
//
//  Created by BIM  on 9/12/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONToggleTableViewCell.h"

@interface HONToggleTableViewCell ()
@end

@implementation HONToggleTableViewCell
@synthesize delegate = _delegate;
@synthesize isSelected = _isSelected;


+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		[self hideChevron];
		
		_toggledOffButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toggledOffButton_nonActive"]];// [UIButton buttonWithType:UIButtonTypeCustom];
		_toggledOffButton.frame = CGRectMake(260.0, 10.0, 44.0, 44.0);
//		[_toggledOffButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_Active"] forState:UIControlStateNormal];
//		[_toggledOffButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_nonActive"] forState:UIControlStateHighlighted];
//		[_toggledOffButton addTarget:self action:@selector(_goSelect) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_toggledOffButton];
		
		_toggledOnButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toggledOnButton_nonActive"]];//[UIButton buttonWithType:UIButtonTypeCustom];
		_toggledOnButton.frame = _toggledOffButton.frame;
//		[_toggledOnButton setBackgroundImage:[UIImage imageNamed:@"toggledOnButton_Active"] forState:UIControlStateNormal];
//		[_toggledOnButton setBackgroundImage:[UIImage imageNamed:@"toggledOnButton_nonActive"] forState:UIControlStateHighlighted];
//		[_toggledOffButton addTarget:self action:@selector(_goDeselect) forControlEvents:UIControlEventTouchUpInside];
		_toggledOnButton.alpha = 0.0;
		[self.contentView addSubview:_toggledOnButton];
	}
	
	return (self);
}

- (id)initAsSelected:(BOOL)isSelected {
	if ((self = [self init])) {
		_isSelected = isSelected;
		_toggledOnButton.alpha = (int)_isSelected;
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setSize:(CGSize)size {
	[super setSize:size];
	
	_toggledOffButton.frame = CGRectMake(_toggledOffButton.frame.origin.x, MAX(0, (size.height - _toggledOffButton.frame.size.height) * 0.5), _toggledOffButton.frame.size.width, _toggledOffButton.frame.size.height);
	_toggledOnButton.frame = CGRectMake(_toggledOnButton.frame.origin.x, MAX(0, (size.height - _toggledOnButton.frame.size.height) * 0.5), _toggledOnButton.frame.size.width, _toggledOnButton.frame.size.height);
}


- (void)invertSelected {
	[self toggleSelected:!_isSelected];
}

- (void)toggleOnWithReset:(BOOL)isReset {
	_isSelected = YES;
	
	[UIView animateWithDuration:0.125 animations:^(void) {
		_toggledOnButton.alpha = _isSelected;
	} completion:^(BOOL finished) {
		if (isReset)
			_toggledOnButton.alpha = 0.0;
	}];
}

- (void)toggleSelected:(BOOL)isSelected {
	_isSelected = isSelected;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_toggledOnButton.alpha = (int)_isSelected;
	} completion:^(BOOL finished) {
	}];
}

- (void)toggleUI:(BOOL)isEnabled {
	_toggledOffButton.hidden = !isEnabled;
	_toggledOnButton.hidden = !isEnabled;
}


#pragma mark - Navigation
- (void)_goDeselect {
	_isSelected = NO;
	[self _transitionState];
}

- (void)_goSelect {
	_isSelected = YES;
	[self _transitionState];
}


#pragma mark - UI Presentation
- (void)_transitionState {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_toggledOnButton.alpha = (int)_isSelected;
	} completion:^(BOOL finished) {
		if ([self.delegate respondsToSelector:@selector(tableToggleViewCell:toggledToState:)])
			[self.delegate tableToggleViewCell:self toggledToState:_isSelected];
	}];
}

@end
