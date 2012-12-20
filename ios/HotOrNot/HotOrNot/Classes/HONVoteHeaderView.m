//
//  HONVoteHeaderView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.03.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONVoteHeaderView.h"
#import "UIImageView+WebCache.h"
#import "HONAppDelegate.h"

@interface HONVoteHeaderView()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *creatorImgView;

@end

@implementation HONVoteHeaderView

@synthesize challengeVO = _challengeVO;
@synthesize titleLabel = _titleLabel;
@synthesize creatorImgView = _creatorImgView;

- (id)initWithFrame:(CGRect)frame asPush:(BOOL)isPush {
	if ((self = [super initWithFrame:frame])) {
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 56.0)];
		bgImgView.image = [UIImage imageNamed:@"challengeHeader.png"];
		[self addSubview:bgImgView];
		
		_creatorImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 15.0, 25.0, 25.0)];
		//[self addSubview:_creatorImgView];
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 25.0, 200.0, 16.0)];
		_titleLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
		_titleLabel.textColor = [HONAppDelegate honBlueTxtColor];
		_titleLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_titleLabel];
		
		if (!isPush) {
			UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
			moreButton.frame = CGRectMake(265.0, 16.0, 34.0, 34.0);
			[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive.png"] forState:UIControlStateNormal];
			[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_Active"] forState:UIControlStateHighlighted];
			[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:moreButton];
		}
	}
	
	return (self);
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	[_creatorImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", _challengeVO.creatorFB]] placeholderImage:nil options:SDWebImageProgressiveDownload];
	_titleLabel.text = challengeVO.subjectName;
}

#pragma mark - Navigation
- (void)_goMore {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VOTE_MORE" object:self.challengeVO];
}

@end
