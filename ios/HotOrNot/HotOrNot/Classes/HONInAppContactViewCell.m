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

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		_checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_checkButton.frame = CGRectMake(212.0, 10.0, 104.0, 44.0);
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"checkmarkButton_nonActive"] forState:UIControlStateNormal];
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"checkmarkButton_Active"] forState:UIControlStateHighlighted];
		[_checkButton addTarget:self action:@selector(_goDeselect) forControlEvents:UIControlEventTouchUpInside];
		_checkButton.hidden = YES;
		[self.contentView addSubview:_checkButton];
		
		_addButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_addButton.frame = _checkButton.frame;
		[_addButton setBackgroundImage:[UIImage imageNamed:@"followButton_nonActive"] forState:UIControlStateNormal];
		[_addButton setBackgroundImage:[UIImage imageNamed:@"followButton_Active"] forState:UIControlStateHighlighted];
		[_addButton addTarget:self action:@selector(_goSelect) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_addButton];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setUserVO:(HONTrivialUserVO *)userVO {
	[super setUserVO:userVO];
	
	//_nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y, _nameLabel.frame.size.width - 50.0, _nameLabel.frame.size.height);
}


#pragma mark - Navigation
- (void)_goSelect {
	_checkButton.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_addButton.alpha = 0.0;
	} completion:^(BOOL finished) {
		_addButton.hidden = YES;
		[self.delegate inAppContactViewCell:self addUser:self.userVO toggleSelected:YES];
	}];
}

- (void)_goDeselect {
	_addButton.hidden = NO;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_addButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		_checkButton.hidden = YES;
		[self.delegate inAppContactViewCell:self addUser:self.userVO toggleSelected:NO];
	}];
}

- (void)toggleSelected:(BOOL)isSelected {
	_addButton.alpha = (int)!isSelected;
	_addButton.hidden = isSelected;
	
	_checkButton.alpha = (int)isSelected;
	_checkButton.hidden = !isSelected;
}

@end
