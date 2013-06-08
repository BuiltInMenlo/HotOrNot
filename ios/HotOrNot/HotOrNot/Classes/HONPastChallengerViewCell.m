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
		
		UIImageView *chevronImageView = [[UIImageView alloc] initWithFrame:CGRectMake(283.0, 20.0, 24.0, 24.0)];
		chevronImageView.image = [UIImage imageNamed:@"chevron"];
		[self addSubview:chevronImageView];
	}
	
	return (self);
}


- (void)setUserVO:(HONUserVO *)userVO {
	_userVO = userVO;
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 13.0, 38.0, 38.0)];
	[avatarImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
	avatarImageView.hidden = _isRandom;
	[self addSubview:avatarImageView];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake((_isRandom) ? 11.0 : 56.0, 27.0, 180.0, 20.0)];
	nameLabel.font = [[HONAppDelegate cartoGothicBold] fontWithSize:16];
	nameLabel.textColor = [HONAppDelegate honGrey635Color];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = [NSString stringWithFormat:(_isRandom) ? @"%@" : @"@%@", _userVO.username];
	[self addSubview:nameLabel];
}


@end
