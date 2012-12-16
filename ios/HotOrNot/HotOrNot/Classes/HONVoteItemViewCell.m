//
//  HONVoteItemViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONVoteItemViewCell.h"
#import "UIImageView+WebCache.h"

#import "HONAppDelegate.h"


@interface HONVoteItemViewCell()
@property (nonatomic, strong) UIView *lHolderView;
@property (nonatomic, strong) UIView *rHolderView;
@property (nonatomic, strong) UIButton *lVoteButton;
@property (nonatomic, strong) UIButton *rVoteButton;
@end

@implementation HONVoteItemViewCell

@synthesize lHolderView = _lHolderView;
@synthesize rHolderView = _rHolderView;

@synthesize lVoteButton = _lVoteButton;
@synthesize rVoteButton = _rVoteButton;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		self.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 341.0)];
		bgImgView.image = [UIImage imageNamed:@"challengeBackground.png"];
		[self addSubview:bgImgView];
				
		_lVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_lVoteButton.frame = CGRectMake(30.0, 270.0, 106.0, 61.0);
		[_lVoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive.png"] forState:UIControlStateNormal];
		[_lVoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active.png"] forState:UIControlStateHighlighted];
		[_lVoteButton addTarget:self action:@selector(_goLeftVote) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_lVoteButton];
		
		_rVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_rVoteButton.frame = CGRectMake(182.0, 270.0, 106.0, 61.0);
		[_rVoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive.png"] forState:UIControlStateNormal];
		[_rVoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active.png"] forState:UIControlStateHighlighted];
		[_rVoteButton addTarget:self action:@selector(_goRightVote) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_rVoteButton];
	}
	
	return (self);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	_lHolderView = [[UIView alloc] initWithFrame:CGRectMake(25.0, 17.0, 120.0, 245.0)];
	_lHolderView.clipsToBounds = YES;
	[self addSubview:_lHolderView];
	
	UIImageView *lImgView = [[UIImageView alloc] initWithFrame:CGRectMake(-50.0, 0.0, kMediumW, kMediumH)];
	[lImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", challengeVO.imageURL]] placeholderImage:nil options:SDWebImageProgressiveDownload];
	[_lHolderView addSubview:lImgView];
	
	UIButton *lZoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
	lZoomButton.frame = lImgView.frame;
	[lZoomButton addTarget:self action:@selector(_goLeftZoom) forControlEvents:UIControlEventTouchUpInside];
	[_lHolderView addSubview:lZoomButton];
	
	_rHolderView = [[UIView alloc] initWithFrame:CGRectMake(173.0, 17.0, 120.0, 245.0)];
	_rHolderView.clipsToBounds = YES;
	[self addSubview:_rHolderView];
	
	UIImageView *rImgView = [[UIImageView alloc] initWithFrame:CGRectMake(-50.0, 0.0, kMediumW, kMediumH)];
	[rImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", challengeVO.image2URL]] placeholderImage:nil options:SDWebImageProgressiveDownload];
	[_rHolderView addSubview:rImgView];
	
	UIButton *rZoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
	rZoomButton.frame = rImgView.frame;
	[rZoomButton addTarget:self action:@selector(_goRightZoom) forControlEvents:UIControlEventTouchUpInside];
	[_rHolderView addSubview:rZoomButton];
	
	UIButton *scoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
	scoreButton.frame = CGRectMake(20.0, 350.0, 84.0, 16.0);
	[scoreButton setTitleColor:[HONAppDelegate honBlueTxtColor] forState:UIControlStateNormal];
	scoreButton.titleLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
	[scoreButton setTitle:[NSString stringWithFormat:@"%d votes", (_challengeVO.scoreCreator + _challengeVO.scoreChallenger)] forState:UIControlStateNormal];
	[scoreButton addTarget:self action:@selector(_goScore) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:scoreButton];
	
	if ([HONAppDelegate hasVoted:_challengeVO.challengeID]) {
		[_lVoteButton removeTarget:self action:@selector(_goLeftVote) forControlEvents:UIControlEventTouchUpInside];
		[_rVoteButton removeTarget:self action:@selector(_goRightVote) forControlEvents:UIControlEventTouchUpInside];
	}
}


#pragma mark - Navigation
- (void)_goLeftVote {
	[_lVoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_tapped.png"] forState:UIControlStateNormal];
	[_lVoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_tapped.png"] forState:UIControlStateHighlighted];
	[_rVoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive.png"] forState:UIControlStateHighlighted];
	[_lVoteButton removeTarget:self action:@selector(_goLeftVote:) forControlEvents:UIControlEventTouchUpInside];
	[_rVoteButton removeTarget:self action:@selector(_goRightVote:) forControlEvents:UIControlEventTouchUpInside];
	
	UIView *overlayView = [[UIView alloc] initWithFrame:_rHolderView.frame];
	overlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.67];
	[self addSubview:overlayView];
	
	UIImageView *lScoreImgView = [[UIImageView alloc] initWithFrame:CGRectMake(43.0, 92.0, 84.0, 84.0)];
	lScoreImgView.image = [UIImage imageNamed:@"likeOverlay.png"];
	[self addSubview:lScoreImgView];
	
	UILabel *lScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 18.0, 84.0, 18.0)];
	lScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:18];
	lScoreLabel.backgroundColor = [UIColor clearColor];
	lScoreLabel.textColor = [UIColor whiteColor];
	lScoreLabel.textAlignment = NSTextAlignmentCenter;
	lScoreLabel.text = [NSString stringWithFormat:@"%d", (_challengeVO.scoreCreator + 1)];
	[lScoreImgView addSubview:lScoreLabel];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VOTE_MAIN" object:self.challengeVO];
}

- (void)_goRightVote {
	[_lVoteButton removeTarget:self action:@selector(_goLeftVote:) forControlEvents:UIControlEventTouchUpInside];
	[_rVoteButton removeTarget:self action:@selector(_goRightVote:) forControlEvents:UIControlEventTouchUpInside];
	[_lVoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive.png"] forState:UIControlStateHighlighted];
	[_rVoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_tapped.png"] forState:UIControlStateNormal];
	[_rVoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_tapped.png"] forState:UIControlStateHighlighted];
	
	UIView *overlayView = [[UIView alloc] initWithFrame:_lHolderView.frame];
	overlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.67];
	[self addSubview:overlayView];
	
	UIImageView *rScoreImgView = [[UIImageView alloc] initWithFrame:CGRectMake(190.0, 92.0, 84.0, 84.0)];
	rScoreImgView.image = [UIImage imageNamed:@"likeOverlay.png"];
	[self addSubview:rScoreImgView];
	
	UILabel *rScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 18.0, 84.0, 18.0)];
	rScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:18];
	rScoreLabel.backgroundColor = [UIColor clearColor];
	rScoreLabel.textColor = [UIColor whiteColor];
	rScoreLabel.textAlignment = NSTextAlignmentCenter;
	rScoreLabel.text = [NSString stringWithFormat:@"%d", (_challengeVO.scoreChallenger + 1)];
	[rScoreImgView addSubview:rScoreLabel];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VOTE_SUB" object:self.challengeVO];
}

- (void)_goLeftZoom {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ZOOM_IMAGE" object:[NSDictionary dictionaryWithObjectsAndKeys:self.challengeVO.imageURL, @"img", self.challengeVO.subjectName, @"title", nil]];
}

- (void)_goRightZoom {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ZOOM_IMAGE" object:[NSDictionary dictionaryWithObjectsAndKeys:self.challengeVO.image2URL, @"img", self.challengeVO.subjectName, @"title", nil]];
}

- (void)_goScore {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_VOTERS" object:self.challengeVO];
}

@end
