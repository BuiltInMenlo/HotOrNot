//
//  HONVoteHeaderView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.03.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONVoteHeaderView.h"

@interface HONVoteHeaderView()
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation HONVoteHeaderView

@synthesize challengeVO = _challengeVO;
@synthesize titleLabel = _titleLabel;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 200.0, 16.0)];
		//_titleLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//_titleLabel = [SNAppDelegate snLinkColor];
		_titleLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_titleLabel];
		
		UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
		moreButton.frame = CGRectMake(280.0, 10.0, 34.0, 24.0);
		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreButton_nonActive.png"] forState:UIControlStateNormal];
		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreButton_Active.png"] forState:UIControlStateHighlighted];
		[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:moreButton];
	}
	
	return (self);
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	_titleLabel.text = [NSString stringWithFormat:@"#%@", challengeVO.subjectName];
}

#pragma mark - Navigation
- (void)_goMore {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VOTE_MORE" object:self.challengeVO];
}

@end
