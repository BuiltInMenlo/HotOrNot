//
//  HONEmptyChallengeViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.12.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONEmptyChallengeViewCell.h"


@implementation HONEmptyChallengeViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {		
		UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noOlderSnaps"]];
		[self addSubview:imageView];
		
		UIButton *findFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		findFriendsButton.frame = CGRectMake(28.0, 60.0, 264.0, 64.0);
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
