//
//  HONProfileViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 04.26.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONPastChallengerViewCell.h"
#import "HONAppDelegate.h"

@interface HONPastChallengerViewCell()
@property (nonatomic) BOOL isRandom;
@end

@implementation HONPastChallengerViewCell
@synthesize userVO = _userVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initAsRandomUser:(BOOL)isAnonymous {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"genericRowBackground_nonActive"]];
		_isRandom = isAnonymous;
		
//		UIImageView *plusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(266.0, 10.0, 44.0, 44.0)];
//		plusImageView.image = [UIImage imageNamed:@"plusButton_nonActive"];
//		[self addSubview:plusImageView];
		
		UIImageView *chevronImageView = [[UIImageView alloc] initWithFrame:CGRectMake(285.0, 20.0, 24.0, 24.0)];
		chevronImageView.image = [UIImage imageNamed:@"chevron"];
		[self addSubview:chevronImageView];
	}
	
	return (self);
}


- (void)setUserVO:(HONUserVO *)userVO {
	_userVO = userVO;
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 12.0, 38.0, 38.0)];
	[avatarImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
	avatarImageView.backgroundColor = [UIColor colorWithWhite:0.950 alpha:1.0];
	avatarImageView.hidden = _isRandom;
	[self addSubview:avatarImageView];
	
	UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 24.0, 200.0, 20.0)];
	usernameLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:16];
	usernameLabel.textColor = [HONAppDelegate honBlueTextColor];
	usernameLabel.backgroundColor = [UIColor clearColor];
	usernameLabel.text = [NSString stringWithFormat:@"@%@", _userVO.username];
	[self addSubview:usernameLabel];
	
//	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake((_isRandom) ? 11.0 : 56.0, 27.0, 180.0, 20.0)];
//	nameLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:16];
//	nameLabel.textColor = [HONAppDelegate honGrey635Color];
//	nameLabel.backgroundColor = [UIColor clearColor];
//	nameLabel.text = [NSString stringWithFormat:(_isRandom) ? @"%@" : @"@%@", _userVO.username];
//	[self addSubview:nameLabel];
}


@end
