//
//  HONVoterViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+WebCache.h"

#import "HONVoterViewCell.h"
#import "HONAppDelegate.h"

@interface HONVoterViewCell()
@property (nonatomic, strong) UIImageView *bgImgView;
@end

@implementation HONVoterViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (void)setVoterVO:(HONVoterVO *)voterVO {
	_voterVO = voterVO;
	
	UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0, 10.0, 50.0, 50.0)];
	userImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	[userImageView setImageWithURL:[NSURL URLWithString:_voterVO.imageURL] placeholderImage:nil];
	[self addSubview:userImageView];
	
	UIImageView *creatorScoreBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14.0, 45.0, 50.0, 15.0)];
	creatorScoreBGImageView.image = [UIImage imageNamed:@"smallRowScore_Overlay"];
	[self addSubview:creatorScoreBGImageView];
	
	UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 45.0, 50.0, 15.0)];
	scoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:11];
	scoreLabel.textColor = [UIColor whiteColor];
	scoreLabel.backgroundColor = [UIColor clearColor];
	scoreLabel.textAlignment = NSTextAlignmentCenter;
	scoreLabel.shadowColor = [UIColor blackColor];
	scoreLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	scoreLabel.text = [NSString stringWithFormat:@"%d", _voterVO.score];
	[self addSubview:scoreLabel];
	
	UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(73.0, 19.0, 200.0, 16.0)];
	usernameLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:14];
	usernameLabel.textColor = [HONAppDelegate honGreyTxtColor];
	usernameLabel.backgroundColor = [UIColor clearColor];
	usernameLabel.text = _voterVO.username;
	[self addSubview:usernameLabel];
	
	UILabel *voteLabel = [[UILabel alloc] initWithFrame:CGRectMake(73.0, 37.0, 200.0, 16.0)];
	voteLabel.font = [[HONAppDelegate freightSansBlack] fontWithSize:12];
	voteLabel.textColor = [HONAppDelegate honBlueTxtColor];
	voteLabel.backgroundColor = [UIColor clearColor];
	voteLabel.text = @"VOTED ON YOUR PHOTO";
	[self addSubview:voteLabel];
}

@end
