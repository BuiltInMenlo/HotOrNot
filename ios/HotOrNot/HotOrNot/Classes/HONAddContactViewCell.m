//
//  HONAddContactViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.10.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONAddContactViewCell.h"
#import "HONAppDelegate.h"

@implementation HONAddContactViewCell
@synthesize userVO = _userVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"genericRowBackground_nonActive"]];
		//self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rowGray_nonActive"]];
		
		UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		inviteButton.frame = CGRectMake(248.0, 9.0, 64.0, 44.0);
		[inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteFriend_nonActive"] forState:UIControlStateNormal];
		[inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteFriend_Active"] forState:UIControlStateHighlighted];
		[inviteButton addTarget:self action:@selector(_goInvite) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:inviteButton];
	}
	
	return (self);
}

- (void)setUserVO:(HONContactUserVO *)userVO {
	_userVO = userVO;
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 18.0, 180.0, 18.0)];
	nameLabel.font = [[HONAppDelegate cartoGothicBold] fontWithSize:14];
	nameLabel.textColor = [HONAppDelegate honBlueTxtColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	//nameLabel.text = [NSString stringWithFormat:@"%@ (%@)", _contactUserVO.fullName, (_contactUserVO.isSMSAvailable) ? @"SMS" : @"EMAIL"];
	nameLabel.text = _userVO.fullName;
	[self addSubview:nameLabel];
	
	UILabel *contactLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 32.0, 180.0, 18.0)];
	contactLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:12];
	contactLabel.textColor = [HONAppDelegate honGrey518Color];
	contactLabel.backgroundColor = [UIColor clearColor];
	//nameLabel.text = [NSString stringWithFormat:@"%@ (%@)", _contactUserVO.fullName, (_contactUserVO.isSMSAvailable) ? @"SMS" : @"EMAIL"];
	contactLabel.text = (_userVO.isSMSAvailable) ? _userVO.mobileNumber : _userVO.email;
	[self addSubview:contactLabel];
}


#pragma mark - Navigation
- (void)_goInvite {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"INVITE_CONTACT" object:_userVO];
}

@end
