//
//  HONVoterViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONVoterViewCell.h"
#import "HONAppDelegate.h"

#import "UIImageView+WebCache.h"

@interface HONVoterViewCell()
@property (nonatomic, strong) UIImageView *bgImgView;
@end

@implementation HONVoterViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		_bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 70.0)];
		[self addSubview:_bgImgView];
	}
	
	return (self);
}

- (id)initAsTopCell {
	if ((self = [self init])) {
		_bgImgView.frame = CGRectMake(0.0, 0.0, 320.0, 20.0);
		_bgImgView.image = [UIImage imageNamed:@"leaderTableHeader.png"];
	}
	
	return (self);
}

- (id)initAsBottomCell {
	if ((self = [self init])) {
		_bgImgView.image = [UIImage imageNamed:@"footerTableRow_nonActive.png"];
	}
	
	return (self);
}

- (id)initAsMidCell {
	if ((self = [self init])) {
		_bgImgView.image = [UIImage imageNamed:@"leaderTableRow_nonActive.png"];
	}
	
	return (self);
}


- (void)setVoterVO:(HONVoterVO *)voterVO {
	_voterVO = voterVO;
	
	UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(45.0, 10.0, 50.0, 50.0)];
	userImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	[userImageView setImageWithURL:[NSURL URLWithString:_voterVO.imageURL] placeholderImage:nil];
	[self addSubview:userImageView];
	
	UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(104.0, 19.0, 200.0, 16.0)];
	usernameLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
	usernameLabel.textColor = [HONAppDelegate honBlueTxtColor];
	usernameLabel.backgroundColor = [UIColor clearColor];
	usernameLabel.text = _voterVO.username;
	[self addSubview:usernameLabel];
	
	UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(104.0, 36.0, 200.0, 16.0)];
	scoreLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:12];
	scoreLabel.textColor = [HONAppDelegate honBlueTxtColor];
	scoreLabel.backgroundColor = [UIColor clearColor];
	scoreLabel.text = [NSString stringWithFormat:@"%d points", _voterVO.points];
	[self addSubview:scoreLabel];
	
	UIButton *challengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	challengeButton.frame = CGRectMake(211.0, 13.0, 84.0, 44.0);
	[challengeButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_nonActive.png"] forState:UIControlStateNormal];
	[challengeButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_Active.png"] forState:UIControlStateHighlighted];
	[challengeButton addTarget:self action:@selector(_goChallenge) forControlEvents:UIControlEventTouchUpInside];
	challengeButton.hidden = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _voterVO.userID);
	[self addSubview:challengeButton];
}


- (void)_goChallenge {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VOTER_CHALLENGE" object:_voterVO];
}

@end
