//
//  HONPopularUserViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONPopularUserViewCell.h"
#import "UIImageView+WebCache.h"

@interface HONPopularUserViewCell()
@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@end

@implementation HONPopularUserViewCell

@synthesize userImageView = _userImageView;
@synthesize usernameLabel = _usernameLabel;
@synthesize scoreLabel = _scoreLabel;

- (id)initAsMidCell:(int)index {
	if ((self = [super initAsMidCell:index])) {
		self.userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35.0, 10.0, 40.0, 40.0)];
		self.userImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
		[self addSubview:self.userImageView];
		
		self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(89.0, 15.0, 200.0, 16.0)];
		//usernameLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//usernameLabel = [SNAppDelegate snLinkColor];
		self.usernameLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:self.usernameLabel];
		
		self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(89.0, 35.0, 200.0, 16.0)];
		//scoreLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//scoreLabel = [SNAppDelegate snLinkColor];
		self.scoreLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:self.scoreLabel];
		
		UIButton *challengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		challengeButton.frame = CGRectMake(220.0, 10.0, 84.0, 44.0);
		[challengeButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_nonActive.png"] forState:UIControlStateNormal];
		[challengeButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_Active.png"] forState:UIControlStateHighlighted];
		[challengeButton addTarget:self action:@selector(_goChallenge) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:challengeButton];
	}
	
	return (self);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)setUserVO:(HONPopularUserVO *)userVO {
	_userVO = userVO;
	
	[self.userImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
	self.usernameLabel.text = _userVO.username;
	self.scoreLabel.text = [NSString stringWithFormat:@"%d points", _userVO.score];
}

- (void)_goChallenge {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"POPULAR_USER_CHALLENGE" object:_userVO];
}

@end
