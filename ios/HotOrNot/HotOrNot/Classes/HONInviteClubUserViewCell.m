//
//  HONInviteClubUserViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/01/2014 @ 14:08 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONInviteClubUserViewCell.h"

@interface HONInviteClubUserViewCell ()
@property (nonatomic, strong) UIButton *inviteButton;
@property (nonatomic, strong) UIButton *inviteCheckButton;
@property (nonatomic, strong) UIButton *blockButton;
@property (nonatomic, strong) UIButton *blockCheckButton;
@property (nonatomic) BOOL isBlocked;
@property (nonatomic) BOOL isInvited;
@end

@implementation HONInviteClubUserViewCell
@synthesize delegate = _delegate;


+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		_inviteCheckButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_inviteCheckButton.frame = CGRectMake(128.0, 10.0, 104.0, 44.0);
		[_inviteCheckButton setBackgroundImage:[UIImage imageNamed:@"checkmarkButton_nonActive"] forState:UIControlStateNormal];
		[_inviteCheckButton setBackgroundImage:[UIImage imageNamed:@"checkmarkButton_Active"] forState:UIControlStateHighlighted];
		[_inviteCheckButton addTarget:self action:@selector(_goDeselectInvite) forControlEvents:UIControlEventTouchUpInside];
		_inviteCheckButton.hidden = YES;
		[self.contentView addSubview:_inviteCheckButton];
		
		_inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_inviteButton.frame = _inviteCheckButton.frame;
		[_inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteButton_nonActive"] forState:UIControlStateNormal];
		[_inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteButton_Active"] forState:UIControlStateHighlighted];
		[_inviteButton addTarget:self action:@selector(_goSelectInvite) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_inviteButton];
		
		_blockCheckButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_blockCheckButton.frame = CGRectMake(212.0, 10.0, 104.0, 44.0);
		[_blockCheckButton setBackgroundImage:[UIImage imageNamed:@"checkmarkButton_nonActive"] forState:UIControlStateNormal];
		[_blockCheckButton setBackgroundImage:[UIImage imageNamed:@"checkmarkButton_Active"] forState:UIControlStateHighlighted];
		[_blockCheckButton addTarget:self action:@selector(_goDeselectBlock) forControlEvents:UIControlEventTouchUpInside];
		_blockCheckButton.hidden = YES;
		[self.contentView addSubview:_blockCheckButton];
		
		_blockButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_blockButton.frame = _blockCheckButton.frame;
		[_blockButton setBackgroundImage:[UIImage imageNamed:@"followButton_nonActive"] forState:UIControlStateNormal];
		[_blockButton setBackgroundImage:[UIImage imageNamed:@"followButton_Active"] forState:UIControlStateHighlighted];
		[_blockButton addTarget:self action:@selector(_goSelectBlock) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_blockButton];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setUserVO:(HONTrivialUserVO *)userVO {
	[super setUserVO:userVO];
	
	_nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y, _nameLabel.frame.size.width - 50.0, _nameLabel.frame.size.height);
}

- (void)clearSelection {
	[self toggleBlocked:NO];
	[self toggleInvited:NO];
}

- (void)toggleBlocked:(BOOL)isSelected {
	_isBlocked = isSelected;
	
	_blockButton.hidden = isSelected;
	_blockCheckButton.hidden = !isSelected;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blockButton.alpha = (int)!isSelected;
		_blockCheckButton.alpha = (int)isSelected;
	} completion:^(BOOL finished) {
		_blockButton.hidden = isSelected;
		_blockCheckButton.hidden = !isSelected;
	}];
}

- (void)toggleInvited:(BOOL)isSelected {
	_isInvited = isSelected;
	
	_inviteButton.hidden = isSelected;
	_inviteCheckButton.hidden = !isSelected;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_inviteButton.alpha = (int)!isSelected;
		_inviteCheckButton.alpha = (int)isSelected;
	} completion:^(BOOL finished) {
		_inviteButton.hidden = isSelected;
		_inviteCheckButton.hidden = !isSelected;
	}];
}


#pragma mark - Navigation
- (void)_goSelectInvite {
	[self toggleInvited:YES];
	
	[self.delegate inviteClubUserViewCell:self toggleInvite:YES forUser:self.userVO];
}

- (void)_goDeselectInvite {
	[self toggleInvited:NO];
	
	[self.delegate inviteClubUserViewCell:self toggleInvite:NO forUser:self.userVO];
}

- (void)_goSelectBlock {
	[self toggleBlocked:YES];
	
	[self.delegate inviteClubUserViewCell:self toggleBlock:YES forUser:self.userVO];
}

- (void)_goDeselectBlock {
	[self toggleBlocked:NO];
	[self.delegate inviteClubUserViewCell:self toggleBlock:NO forUser:self.userVO];
}


@end
