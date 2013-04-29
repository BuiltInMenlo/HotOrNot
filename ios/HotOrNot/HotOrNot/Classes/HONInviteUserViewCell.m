//
//  HONInviteUserViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 04.26.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONInviteUserViewCell.h"
#import "HONAppDelegate.h"

@implementation HONInviteUserViewCell
@synthesize contactUserVO = _contactUserVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 63.0)];
		bgImageView.image = [UIImage imageNamed:@"genericRowBackground_nonActive"];
		[self addSubview:bgImageView];
		
		UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		inviteButton.frame = CGRectMake(245.0, 10.0, 64.0, 44.0);
		[inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteButton_nonActive"] forState:UIControlStateNormal];
		[inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteButton_Active"] forState:UIControlStateHighlighted];
		[inviteButton addTarget:self action:@selector(_goInvite) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:inviteButton];
	}
	
	return (self);
}

- (void)setContactUserVO:(HONContactUserVO *)contactUserVO {
	_contactUserVO = contactUserVO;
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 22.0, 180.0, 16.0)];
	nameLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:12];
	nameLabel.textColor = [HONAppDelegate honGreyTxtColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = [NSString stringWithFormat:@"%@ (%@)", _contactUserVO.fullName, (_contactUserVO.isSMSAvailable) ? @"SMS" : @"EMAIL"];
	[self addSubview:nameLabel];
}


#pragma mark - Navigation
- (void)_goInvite {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"INVITE_CONTACT" object:_contactUserVO];
}

@end
