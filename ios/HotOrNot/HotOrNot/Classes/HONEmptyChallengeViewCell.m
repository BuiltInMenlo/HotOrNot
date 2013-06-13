//
//  HONEmptyChallengeViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.12.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONEmptyChallengeViewCell.h"
#import "HONAppDelegate.h"


@implementation HONEmptyChallengeViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 18.0, 240.0, 20.0)];
		label.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:14];
		label.textColor = [HONAppDelegate honGrey455Color];
		label.textAlignment = NSTextAlignmentCenter;
		label.text = @"You have no older messages";
		[self addSubview:label];
		
		UIButton *findFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		findFriendsButton.frame = CGRectMake(35.0, 60.0, 249.0, 49.0);
		[findFriendsButton setBackgroundImage:[UIImage imageNamed:@"findVolleyFriends_nonActive"] forState:UIControlStateNormal];
		[findFriendsButton setBackgroundImage:[UIImage imageNamed:@"findVolleyFriends_Active"] forState:UIControlStateHighlighted];
		[findFriendsButton addTarget:self action:@selector(_goFindFriends) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:findFriendsButton];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goFindFriends {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_FIND_FRIENDS" object:nil];
}

@end
