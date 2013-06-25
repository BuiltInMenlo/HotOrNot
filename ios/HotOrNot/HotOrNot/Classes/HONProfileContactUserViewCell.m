//
//  HONProfileContactUserViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 04.26.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONProfileContactUserViewCell.h"
#import "HONAppDelegate.h"

@implementation HONProfileContactUserViewCell
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
		inviteButton.frame = CGRectMake(235.0, 10.0, 74.0, 44.0);
		[inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteButton_nonActive"] forState:UIControlStateNormal];
		[inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteButton_Active"] forState:UIControlStateHighlighted];
		[inviteButton addTarget:self action:@selector(_goInvite) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:inviteButton];
	}
	
	return (self);
}

- (void)setContactUserVO:(HONContactUserVO *)contactUserVO {
	_contactUserVO = contactUserVO;
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 15.0, 180.0, 20.0)];
	nameLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:16];
	nameLabel.textColor = [HONAppDelegate honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _contactUserVO.fullName;
	[self addSubview:nameLabel];
	
	UILabel *contactLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 31.0, 180.0, 18.0)];
	contactLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:15];
	contactLabel.textColor = [HONAppDelegate honGrey455Color];
	contactLabel.backgroundColor = [UIColor clearColor];
	contactLabel.text = (_contactUserVO.isSMSAvailable) ? _contactUserVO.mobileNumber : _contactUserVO.email;
	[self addSubview:contactLabel];
}


#pragma mark - Navigation
- (void)_goInvite {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"INVITE_CONTACT" object:_contactUserVO];
}

@end
