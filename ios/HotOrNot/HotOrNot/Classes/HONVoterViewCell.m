//
//  HONVoterViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+AFNetworking.h"

#import "HONVoterViewCell.h"
#import "HONAppDelegate.h"

@interface HONVoterViewCell()
@end

@implementation HONVoterViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		[self hideChevron];
	}
	
	return (self);
}

- (void)setVoterVO:(HONVoterVO *)voterVO {
	_voterVO = voterVO;
	
	CALayer *avatarMask = [CALayer layer];
	avatarMask.contents = (id)[[UIImage imageNamed:@"smallAvatarMask.png"] CGImage];
	avatarMask.frame = CGRectMake(0.0, 0.0, 38.0, 38.0);
	
	//NSString *imgURL = ([_voterVO.fbID isEqualToString:@""]) ? @"https://s3.amazonaws.com/picchallenge/default_user.jpg" : _voterVO.imageURL;
	UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14.0, 12.0, 38.0, 38.0)];
	userImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	[userImageView setImageWithURL:[NSURL URLWithString:_voterVO.imageURL] placeholderImage:nil];
	userImageView.layer.mask = avatarMask;
	userImageView.layer.masksToBounds = YES;
	[self addSubview:userImageView];
	
//	UIImageView *creatorScoreBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14.0, 45.0, 50.0, 15.0)];
//	creatorScoreBGImageView.image = [UIImage imageNamed:@"smallRowScore_Overlay"];
//	[self addSubview:creatorScoreBGImageView];
//	
//	UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 45.0, 50.0, 15.0)];
//	scoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:11];
//	scoreLabel.textColor = [UIColor whiteColor];
//	scoreLabel.backgroundColor = [UIColor clearColor];
//	scoreLabel.textAlignment = NSTextAlignmentCenter;
//	scoreLabel.shadowColor = [UIColor blackColor];
//	scoreLabel.shadowOffset = CGSizeMake(1.0, 1.0);
//	scoreLabel.text = [NSString stringWithFormat:@"%d", _voterVO.score];
//	[self addSubview:scoreLabel];
	
//	UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(73.0, 19.0, 200.0, 16.0)];
//	usernameLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
//	usernameLabel.textColor = [HONAppDelegate honGreyTxtColor];
//	usernameLabel.backgroundColor = [UIColor clearColor];
//	usernameLabel.text = [NSString stringWithFormat:@"@%@", _voterVO.username];
//	[self addSubview:usernameLabel];
//	
	UILabel *voteLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 23.0, 220.0, 16.0)];
	voteLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:11];
	voteLabel.textColor = [HONAppDelegate honGreyTxtColor];
	voteLabel.backgroundColor = [UIColor clearColor];
	voteLabel.text = [NSString stringWithFormat:@"@%@ liked @%@ snap", _voterVO.username, _voterVO.challengerName];
	[self addSubview:voteLabel];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(246.0, 23.0, 60.0, 16.0)];
	timeLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:11];
	timeLabel.textColor = [HONAppDelegate honGreyTxtColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = [HONAppDelegate timeSinceDate:_voterVO.addedDate];
	[self addSubview:timeLabel];
}

@end
