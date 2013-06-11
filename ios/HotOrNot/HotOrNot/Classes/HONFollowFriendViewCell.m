//
//  HONFollowFriendViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.10.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONFollowFriendViewCell.h"
#import "HONAppDelegate.h"
#import "HONUserVO.h"

@interface HONFollowFriendViewCell ()

@end

@implementation HONFollowFriendViewCell
@synthesize userVO = _userVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"genericRowBackground_nonActive"]];
		//self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rowGray_nonActive"]];
		
		UIButton *followButton = [UIButton buttonWithType:UIButtonTypeCustom];
		followButton.frame = CGRectMake(248.0, 9.0, 64.0, 44.0);
		[followButton setBackgroundImage:[UIImage imageNamed:@"addFriend_nonActive"] forState:UIControlStateNormal];
		[followButton setBackgroundImage:[UIImage imageNamed:@"addFriend_Active"] forState:UIControlStateHighlighted];
		[followButton addTarget:self action:@selector(_goFollow) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:followButton];
	}
	
	return (self);
}

- (void)setUserVO:(HONUserVO *)userVO {
	_userVO = userVO;
}


#pragma mark - Navigation
- (void)_goFollow {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FOLLOW_FRIEND" object:_userVO];
}

@end
