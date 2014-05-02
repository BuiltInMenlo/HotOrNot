//
//  HONInAppContactViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 18:20 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONInAppContactViewCell.h"

@interface HONInAppContactViewCell ()
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UIButton *addButton;
@end

@implementation HONInAppContactViewCell
@synthesize delegate = _delegate;

- (id)init {
	if ((self = [super init])) {
		_checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_checkButton.frame = CGRectMake(250.0, 0.0, 64.0, 64.0);
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"toggledOnButton_nonActive"] forState:UIControlStateNormal];
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"toggledOnButton_Active"] forState:UIControlStateHighlighted];
		[_checkButton addTarget:self action:@selector(_goDeselect) forControlEvents:UIControlEventTouchUpInside];
		_checkButton.hidden = YES;
		[self.contentView addSubview:_checkButton];
		
		_addButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_addButton.frame = _checkButton.frame;
		[_addButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_nonActive"] forState:UIControlStateNormal];
		[_addButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_Active"] forState:UIControlStateHighlighted];
		[_addButton addTarget:self action:@selector(_goSelect) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_addButton];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setTrivialUserVO:(HONTrivialUserVO *)userVO {
	[super setTrivialUserVO:userVO];
	
	_nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y, _nameLabel.frame.size.width - 55.0, _nameLabel.frame.size.height);
}

- (void)toggleSelected:(BOOL)isSelected {
	_addButton.alpha = (int)!isSelected;
	_addButton.hidden = isSelected;
	
	_checkButton.alpha = (int)isSelected;
	_checkButton.hidden = !isSelected;
}


#pragma mark - Navigation
- (void)_goSelect {
	_checkButton.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_addButton.alpha = 0.0;
	} completion:^(BOOL finished) {
		_addButton.hidden = YES;
		[self.delegate inAppContactViewCell:self addUser:self.trivialUserVO toggleSelected:YES];
	}];
}

- (void)_goDeselect {
	_addButton.hidden = NO;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_addButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		_checkButton.hidden = YES;
		[self.delegate inAppContactViewCell:self addUser:self.trivialUserVO toggleSelected:NO];
	}];
}


@end
