//
//  HONPopularUserViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONPopularUserViewCell.h"
#import "UIImageView+WebCache.h"
#import "HONAppDelegate.h"

@interface HONPopularUserViewCell()
@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UIButton *challengeButton;
@end

@implementation HONPopularUserViewCell

@synthesize userVO = _userVO;

- (id)initAsMidCell:(int)index {
	if ((self = [super initAsMidCell:index])) {
		UILabel *indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(23.0, 27.0, 50.0, 16.0)];
		indexLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
		indexLabel.textColor = [HONAppDelegate honGreyTxtColor];
		indexLabel.backgroundColor = [UIColor clearColor];
		indexLabel.text = [NSString stringWithFormat:@"%d.", index];
		[self addSubview:indexLabel];
		
		_userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(45.0, 10.0, 50.0, 50.0)];
		_userImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
		[self addSubview:_userImageView];
		
		_usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(104.0, 19.0, 200.0, 16.0)];
		_usernameLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
		_usernameLabel.textColor = [HONAppDelegate honBlueTxtColor];
		_usernameLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_usernameLabel];
		
		_scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(104.0, 36.0, 200.0, 16.0)];
		_scoreLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:12];
		_scoreLabel.textColor = [HONAppDelegate honBlueTxtColor];
		_scoreLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_scoreLabel];
		
		_challengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_challengeButton.frame = CGRectMake(211.0, 13.0, 84.0, 44.0);
		[_challengeButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_nonActive.png"] forState:UIControlStateNormal];
		[_challengeButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_Active.png"] forState:UIControlStateHighlighted];
		[_challengeButton addTarget:self action:@selector(_goChallenge) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_challengeButton];
	}
	
	return (self);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)setUserVO:(HONPopularUserVO *)userVO {
	_userVO = userVO;
	
	[_userImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
	_usernameLabel.text = _userVO.username;
	_scoreLabel.text = [NSString stringWithFormat:@"%d points", _userVO.score];
	
	_challengeButton.hidden = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID);
}

- (void)_goChallenge {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"POPULAR_USER_CHALLENGE" object:_userVO];
}

@end
