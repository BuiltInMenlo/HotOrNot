//
//  HONVerifyHeaderView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/21/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONVerifyHeaderView.h"
#import "HONUserVO.h"

@interface HONVerifyHeaderView()
@property (nonatomic, retain) UILabel *ageLabel;
@property (nonatomic, retain) UILabel *stausLabel;
@end

@implementation HONVerifyHeaderView

@synthesize delegate = _delegate;
@synthesize challengeVO = _challengeVO;

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 61.0)])) {
		_challengeVO = vo;
		
		self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.85];
		
		UIImageView *creatorAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 9.0, 38.0, 38.0)];
		[creatorAvatarImageView setImageWithURL:[NSURL URLWithString:_challengeVO.creatorVO.avatarURL] placeholderImage:nil];
		creatorAvatarImageView.userInteractionEnabled = YES;
		[self addSubview:creatorAvatarImageView];
		
		UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(58.0, 9.0, 150.0, 19.0)];
		usernameLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:16];
		usernameLabel.textColor = [HONAppDelegate honGrey518Color];
		usernameLabel.backgroundColor = [UIColor clearColor];
		usernameLabel.text = [NSString stringWithFormat:@"@%@", _challengeVO.creatorVO.username];
		[self addSubview:usernameLabel];
		
		_ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(58.0, 31.0, 220.0, 16.0)];
		_ageLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:15];
		_ageLabel.textColor = [HONAppDelegate honBlueTextColor];
		_ageLabel.backgroundColor = [UIColor clearColor];
		_ageLabel.text = ([_challengeVO.creatorVO.birthday timeIntervalSince1970] == 0.0) ? @"hasn't set a birthday yet" : @"does this user look 13 to 19?";//[NSString stringWithFormat:@"does this new user look %d?", [HONAppDelegate ageForDate:_challengeVO.creatorVO.birthday]];
		[self addSubview:_ageLabel];
		
		_stausLabel = [[UILabel alloc] initWithFrame:CGRectMake(146.0, 8.0, 160.0, 12.0)];
		_stausLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:11];
		_stausLabel.textColor = [HONAppDelegate honOrthodoxGreenColor];
		_stausLabel.backgroundColor = [UIColor clearColor];
		_stausLabel.textAlignment = NSTextAlignmentRight;
		_stausLabel.text = @"just joined Volley";
		//[self addSubview:_stausLabel];
		
		UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(146.0, 21.0, 160.0, 16.0)];
		timeLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:13];
		timeLabel.textColor = [HONAppDelegate honGreyTimeColor];
		timeLabel.backgroundColor = [UIColor clearColor];
		timeLabel.textAlignment = NSTextAlignmentRight;
		timeLabel.text = (_challengeVO.expireSeconds > 0) ? [HONAppDelegate formattedExpireTime:_challengeVO.expireSeconds] : [HONAppDelegate timeSinceDate:_challengeVO.updatedDate];
		[self addSubview:timeLabel];
		
		UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		avatarButton.frame = creatorAvatarImageView.frame;
		[avatarButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
		[avatarButton addTarget:self action:@selector(_goCreatorTimeline) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:avatarButton];
	}
	
	return (self);
}

- (void)changeStatus:(NSString *)status {
	_stausLabel.text = status;
}


#pragma mark - Navigation
- (void)_goCreatorTimeline {
	[self.delegate verifyHeaderView:self showCreatorTimeline:_challengeVO];
}

@end
