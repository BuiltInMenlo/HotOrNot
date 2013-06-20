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
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 63.0)];
		imageView.image = [UIImage imageNamed:@"nonMessaages"];
		[self addSubview:imageView];
		
		UIButton *findFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		findFriendsButton.frame = CGRectMake(0.0, 60.0, 320.0, 63.0);
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
