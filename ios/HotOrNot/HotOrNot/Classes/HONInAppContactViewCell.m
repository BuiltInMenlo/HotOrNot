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

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		_inviteCheckButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_inviteCheckButton.frame = CGRectMake(212.0, 10.0, 104.0, 44.0);
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


#pragma mark - Navigation
- (void)_goUninvite {
	
}

- (void)_goInvite {
	
}



@end
