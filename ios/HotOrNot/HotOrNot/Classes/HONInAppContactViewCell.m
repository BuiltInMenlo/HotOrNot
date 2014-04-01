//
//  HONInAppContactViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 18:20 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONInAppContactViewCell.h"

@interface HONInAppContactViewCell ()
@property (nonatomic, strong) UIButton *inviteCheckButton;
@property (nonatomic, strong) UIButton *inviteButton;
@end

@implementation HONInAppContactViewCell
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
		[_inviteCheckButton addTarget:self action:@selector(_goUninvite) forControlEvents:UIControlEventTouchUpInside];
		_inviteCheckButton.hidden = YES;
		[self.contentView addSubview:_inviteCheckButton];
		
		_inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_inviteButton.frame = _inviteCheckButton.frame;
		[_inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteButton_nonActive"] forState:UIControlStateNormal];
		[_inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteButton_Active"] forState:UIControlStateHighlighted];
		[_inviteButton addTarget:self action:@selector(_goInvite) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_inviteButton];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setUserVO:(HONTrivialUserVO *)userVO {
	[super setUserVO:userVO];
	
	_nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y, _nameLabel.frame.size.width - 50.0, _nameLabel.frame.size.height);
}


#pragma mark - Navigation
- (void)_goInvite {
	_inviteCheckButton.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_inviteButton.alpha = 0.0;
	} completion:^(BOOL finished) {
		_inviteButton.hidden = YES;
	}];
	
	[self.delegate inAppContactViewCell:self inviteUser:self.userVO toggleSelected:YES];
}

- (void)_goUninvite {
	_inviteButton.hidden = NO;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_inviteButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		_inviteCheckButton.hidden = YES;
	}];
	
	[self.delegate inAppContactViewCell:self inviteUser:self.userVO toggleSelected:NO];
}



@end
