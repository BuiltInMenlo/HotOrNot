//
//  HONChallengeTableHeaderView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.05.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengeTableHeaderView.h"

@implementation HONChallengeTableHeaderView

@synthesize inviteFriendsButton = _inviteFriendsButton;
@synthesize dailyChallengeButton = _dailyChallengeButton;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_inviteFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_inviteFriendsButton.frame = CGRectMake(0.0, 0.0, 80.0, 78.0);
		[_inviteFriendsButton setBackgroundImage:[UIImage imageNamed:@"startChallengeButton.png"] forState:UIControlStateNormal];
		[_inviteFriendsButton setBackgroundImage:[UIImage imageNamed:@"startChallengeButton_active.png"] forState:UIControlStateHighlighted];
		[self addSubview:_inviteFriendsButton];
		
		_dailyChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_dailyChallengeButton.frame = CGRectMake(80.0, 0.0, 240.0, 78.0);
		[_dailyChallengeButton setBackgroundImage:[UIImage imageNamed:@"startChallengeButton.png"] forState:UIControlStateNormal];
		[_dailyChallengeButton setBackgroundImage:[UIImage imageNamed:@"startChallengeButton_active.png"] forState:UIControlStateHighlighted];
		[self addSubview:_dailyChallengeButton];
	}
	
	return (self);
}


@end
