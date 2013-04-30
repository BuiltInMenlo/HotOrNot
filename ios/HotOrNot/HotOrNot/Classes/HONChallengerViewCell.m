//
//  HONChallengerViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 04.23.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONChallengerViewCell.h"
#import "HONAppDelegate.h"


@interface HONChallengerViewCell()
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic) BOOL isRandom;
@end

@implementation HONChallengerViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initAsRandomUser:(BOOL)isAnonymous {
	if ((self = [super init])) {
		_isRandom = isAnonymous;
	}
	
	return (self);
}


- (void)setUserVO:(HONUserVO *)userVO {
	_userVO = userVO;
	
	UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14.0, 12.0, 38.0, 38.0)];
	userImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	[userImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
	userImageView.hidden = _isRandom;
	[self addSubview:userImageView];
	
	UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake((_isRandom) ? 14.0 : 62.0, 22.0, 200.0, 18.0)];
	usernameLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:14];
	usernameLabel.textColor = [HONAppDelegate honGreyTxtColor];
	usernameLabel.backgroundColor = [UIColor clearColor];
	usernameLabel.text = [NSString stringWithFormat:(_isRandom) ? @"%@" : @"@%@", _userVO.username];
	[self addSubview:usernameLabel];
}

@end
