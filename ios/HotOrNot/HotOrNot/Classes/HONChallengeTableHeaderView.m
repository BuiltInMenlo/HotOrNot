//
//  HONChallengeTableHeaderView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.05.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengeTableHeaderView.h"
#import "HONAppDelegate.h"

@implementation HONChallengeTableHeaderView

@synthesize inviteFriendsButton = _inviteFriendsButton;
@synthesize dailyChallengeButton = _dailyChallengeButton;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 71.0)];
		bgImageView.image = [UIImage imageNamed:@"lockedHeaderBackground.jpg"];
		[self addSubview:bgImageView];
		
		_inviteFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_inviteFriendsButton.frame = CGRectMake(0.0, 0.0, 91.0, 70.0);
		[_inviteFriendsButton setBackgroundImage:[UIImage imageNamed:@"inviteFriends_nonActive"] forState:UIControlStateNormal];
		[_inviteFriendsButton setBackgroundImage:[UIImage imageNamed:@"inviteFriends_Active"] forState:UIControlStateHighlighted];
		[self addSubview:_inviteFriendsButton];
		
		_dailyChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_dailyChallengeButton.frame = CGRectMake(91.0, 0.0, 229.0, 70.0);
		[_dailyChallengeButton setBackgroundImage:[UIImage imageNamed:@"startDailyChallenge_nonActive"] forState:UIControlStateNormal];
		[_dailyChallengeButton setBackgroundImage:[UIImage imageNamed:@"startDailyChallenge_Active"] forState:UIControlStateHighlighted];
		_dailyChallengeButton.titleLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
		[_dailyChallengeButton setTitleColor:[HONAppDelegate honGreyTxtColor] forState:UIControlStateNormal];
		[_dailyChallengeButton setTitle:[HONAppDelegate dailySubjectName] forState:UIControlStateNormal];
		[self addSubview:_dailyChallengeButton];
	}
	
	return (self);
}


@end
