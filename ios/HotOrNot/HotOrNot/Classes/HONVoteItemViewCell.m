//
//  HONVoteItemViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "HONVoteItemViewCell.h"
#import "UIImageView+WebCache.h"

#import "HONAppDelegate.h"
#import "HONVoteHeaderView.h"


@interface HONVoteItemViewCell() <AVAudioPlayerDelegate>
@property (nonatomic, strong) UIView *lHolderView;
@property (nonatomic, strong) UIView *rHolderView;
@property (nonatomic, strong) UIButton *lVoteButton;
@property (nonatomic, strong) UIButton *rVoteButton;
@property (nonatomic, strong) HONVoteHeaderView *headerView;
@property (nonatomic) BOOL hasChallenger;
@property (nonatomic, strong) AVAudioPlayer *sfxPlayer;
@end

@implementation HONVoteItemViewCell

@synthesize lHolderView = _lHolderView;
@synthesize rHolderView = _rHolderView;

@synthesize lVoteButton = _lVoteButton;
@synthesize rVoteButton = _rVoteButton;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initAsTopCell:(int)points withSubject:(NSString *)subject {
	if ((self = [super init])) {
		UIButton *dailyButton = [UIButton buttonWithType:UIButtonTypeCustom];
		dailyButton.frame = CGRectMake(0.0, 0.0, 320.0, 55.0);
		[dailyButton setBackgroundImage:[UIImage imageNamed:@"headerTableRow_nonActive.png"] forState:UIControlStateNormal];
		[dailyButton setBackgroundImage:[UIImage imageNamed:@"headerTableRow_Active.png"] forState:UIControlStateHighlighted];
		[dailyButton addTarget:self action:@selector(_goDailyChallenge) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:dailyButton];
		
		UILabel *ptsLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 25.0, 50.0, 16.0)];
		ptsLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
		ptsLabel.textColor = [UIColor whiteColor];
		ptsLabel.backgroundColor = [UIColor clearColor];
		ptsLabel.textAlignment = NSTextAlignmentCenter;
		ptsLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
		ptsLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		ptsLabel.text = [NSString stringWithFormat:@"%d", points];
		[self addSubview:ptsLabel];
		
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 25.0, 140.0, 16.0)];
		subjectLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
		subjectLabel.textColor = [UIColor whiteColor];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.textAlignment = NSTextAlignmentCenter;
		subjectLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
		subjectLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		subjectLabel.text = subject;
		[self addSubview:subjectLabel];
	}
	
	return (self);
}

- (id)initAsWaitingCell {
	if ((self = [super init])) {
		_hasChallenger = NO;
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 54.0, 320.0, 341.0)];
		bgImgView.image = [UIImage imageNamed:@"challengeBackground.png"];
		[self addSubview:bgImgView];
		
		_headerView = [[HONVoteHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 54.0) asPush:NO];
		[self addSubview:_headerView];
		
		_lVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_lVoteButton.frame = CGRectMake(30.0, 324.0, 106.0, 61.0);
		[_lVoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive.png"] forState:UIControlStateNormal];
		[_lVoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active.png"] forState:UIControlStateHighlighted];
		[_lVoteButton addTarget:self action:@selector(_goLeftVote) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_lVoteButton];
		
		_rVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_rVoteButton.frame = CGRectMake(182.0, 324.0, 106.0, 61.0);
		[_rVoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive.png"] forState:UIControlStateNormal];
		[_rVoteButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active.png"] forState:UIControlStateHighlighted];
		[_rVoteButton addTarget:self action:@selector(_goRightVote) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_rVoteButton];
	}
	
	return (self);
}


- (id)initAsStartedCell {
	if ((self = [super init])) {
		_hasChallenger = YES;
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 54.0, 320.0, 341.0)];
		bgImgView.image = [UIImage imageNamed:@"challengeBackground.png"];
		[self addSubview:bgImgView];
		
		_headerView = [[HONVoteHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 54.0) asPush:NO];
		[self addSubview:_headerView];
	}
	
	return (self);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[_headerView setChallengeVO:challengeVO];
	
	if (_hasChallenger) {
		_lHolderView = [[UIView alloc] initWithFrame:CGRectMake(25.0, 71.0, 120.0, 245.0)];
		_lHolderView.clipsToBounds = YES;
		[self addSubview:_lHolderView];
		
		UIImageView *lImgView = [[UIImageView alloc] initWithFrame:CGRectMake(-50.0, 0.0, kMediumW, kMediumH)];
		[lImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", challengeVO.imageURL]] placeholderImage:nil options:SDWebImageProgressiveDownload];
		[_lHolderView addSubview:lImgView];
		
		_rHolderView = [[UIView alloc] initWithFrame:CGRectMake(173.0, 71.0, 120.0, 245.0)];
		_rHolderView.clipsToBounds = YES;
		[self addSubview:_rHolderView];
		
		UIImageView *rImgView = [[UIImageView alloc] initWithFrame:CGRectMake(-50.0, 0.0, kMediumW, kMediumH)];
		[rImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", challengeVO.image2URL]] placeholderImage:nil options:SDWebImageProgressiveDownload];
		[_rHolderView addSubview:rImgView];
		
		UIImageView *creatorAvatarImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 25.0, 25.0)];
		[creatorAvatarImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", _challengeVO.creatorFB]] placeholderImage:nil];
		[_lHolderView addSubview:creatorAvatarImgView];
		
		UIImageView *challengerAvatarImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 25.0, 25.0)];
		[challengerAvatarImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", _challengeVO.challengerFB]] placeholderImage:nil];
		[_rHolderView addSubview:challengerAvatarImgView];
		
		_lVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_lVoteButton.frame = _lHolderView.frame;
		[_lVoteButton addTarget:self action:@selector(_goLeftVote) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_lVoteButton];
		
		_rVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_rVoteButton.frame = _rHolderView.frame;
		[_rVoteButton addTarget:self action:@selector(_goRightVote) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_rVoteButton];
		
		
		UIButton *scoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
		scoreButton.frame = CGRectMake(20.0, 404.0, 84.0, 16.0);
		[scoreButton setTitleColor:[HONAppDelegate honBlueTxtColor] forState:UIControlStateNormal];
		scoreButton.titleLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
		[scoreButton setTitle:[NSString stringWithFormat:@"%d votes", (_challengeVO.scoreCreator + _challengeVO.scoreChallenger)] forState:UIControlStateNormal];
		[scoreButton addTarget:self action:@selector(_goScore) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:scoreButton];
		
		if ([HONAppDelegate hasVoted:_challengeVO.challengeID]) {
			[_lVoteButton removeTarget:self action:@selector(_goLeftVote) forControlEvents:UIControlEventTouchUpInside];
			[_rVoteButton removeTarget:self action:@selector(_goRightVote) forControlEvents:UIControlEventTouchUpInside];
			
			UIImageView *lScoreImgView = [[UIImageView alloc] initWithFrame:CGRectMake(43.0, 146.0, 84.0, 84.0)];
			lScoreImgView.image = [UIImage imageNamed:@"likeOverlay.png"];
			[self addSubview:lScoreImgView];
			
			UIImageView *rScoreImgView = [[UIImageView alloc] initWithFrame:CGRectMake(190.0, 146.0, 84.0, 84.0)];
			rScoreImgView.image = [UIImage imageNamed:@"likeOverlay.png"];
			[self addSubview:rScoreImgView];
			
			UILabel *lScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 18.0, 84.0, 18.0)];
			lScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:18];
			lScoreLabel.backgroundColor = [UIColor clearColor];
			lScoreLabel.textColor = [UIColor whiteColor];
			lScoreLabel.textAlignment = NSTextAlignmentCenter;
			[lScoreImgView addSubview:lScoreLabel];
			
			UILabel *rScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 18.0, 84.0, 18.0)];
			rScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:18];
			rScoreLabel.backgroundColor = [UIColor clearColor];
			rScoreLabel.textColor = [UIColor whiteColor];
			rScoreLabel.textAlignment = NSTextAlignmentCenter;
			[rScoreImgView addSubview:rScoreLabel];

			
			if (_challengeVO.scoreCreator > _challengeVO.scoreChallenger) {
//				UIView *overlayView = [[UIView alloc] initWithFrame:_rHolderView.frame];
//				overlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.67];
//				[self addSubview:overlayView];
				
				lScoreLabel.text = [NSString stringWithFormat:@"%d Winning", (_challengeVO.scoreCreator + 1)];
				rScoreLabel.text = [NSString stringWithFormat:@"%d Losing", (_challengeVO.scoreChallenger + 1)];
				
			} else if (_challengeVO.scoreCreator < _challengeVO.scoreChallenger) {
//				UIView *overlayView = [[UIView alloc] initWithFrame:_lHolderView.frame];
//				overlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.67];
//				[self addSubview:overlayView];
				
				lScoreLabel.text = [NSString stringWithFormat:@"%d Losing", (_challengeVO.scoreCreator + 1)];
				rScoreLabel.text = [NSString stringWithFormat:@"%d Winning", (_challengeVO.scoreChallenger + 1)];
			
			} else {
				lScoreLabel.text = [NSString stringWithFormat:@"%d", (_challengeVO.scoreCreator + 1)];
				rScoreLabel.text = [NSString stringWithFormat:@"%d", (_challengeVO.scoreChallenger + 1)];
			}
		}
		
	} else {
		_lHolderView = [[UIView alloc] initWithFrame:CGRectMake(7.0, 71.0, kLargeW * 0.5, kLargeW * 0.5)];
		[self addSubview:_lHolderView];
		
		UIImageView *lImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW * 0.5, kLargeW * 0.5)];
		[lImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", challengeVO.imageURL]] placeholderImage:nil options:SDWebImageProgressiveDownload];
		[_lHolderView addSubview:lImgView];
		
		UIImageView *creatorAvatarImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 25.0, 25.0)];
		[creatorAvatarImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", _challengeVO.creatorFB]] placeholderImage:nil];
		[_lHolderView addSubview:creatorAvatarImgView];
		
		UIButton *lZoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
		lZoomButton.frame = lImgView.frame;
		[lZoomButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
		[_lHolderView addSubview:lZoomButton];
	}
}


#pragma mark - Navigation
- (void)_goLeftVote {
	[_lVoteButton removeTarget:self action:@selector(_goLeftVote:) forControlEvents:UIControlEventTouchUpInside];
	[_rVoteButton removeTarget:self action:@selector(_goRightVote:) forControlEvents:UIControlEventTouchUpInside];
	
	UIView *overlayView = [[UIView alloc] initWithFrame:_rHolderView.frame];
	overlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.67];
	[self addSubview:overlayView];
	
	UIImageView *lScoreImgView = [[UIImageView alloc] initWithFrame:CGRectMake(43.0, 146.0, 84.0, 84.0)];
	lScoreImgView.image = [UIImage imageNamed:@"likeOverlay.png"];
	[self addSubview:lScoreImgView];
	
	UILabel *lScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 18.0, 84.0, 18.0)];
	lScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:18];
	lScoreLabel.backgroundColor = [UIColor clearColor];
	lScoreLabel.textColor = [UIColor whiteColor];
	lScoreLabel.textAlignment = NSTextAlignmentCenter;
	lScoreLabel.text = [NSString stringWithFormat:@"%d", (_challengeVO.scoreCreator + 1)];
	[lScoreImgView addSubview:lScoreLabel];
	
	if (_challengeVO.scoreCreator > _challengeVO.scoreChallenger)
		lScoreLabel.text = [NSString stringWithFormat:@"%d Winning", (_challengeVO.scoreCreator + 1)];
	
	else if (_challengeVO.scoreCreator < _challengeVO.scoreChallenger)
		lScoreLabel.text = [NSString stringWithFormat:@"%d Losing", (_challengeVO.scoreCreator + 1)];
	
	_sfxPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"fpo_upvote" withExtension:@"mp3"] error:NULL];
	_sfxPlayer.delegate = self;
	[_sfxPlayer play];
	
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"VOTE_MAIN" object:self.challengeVO];
}

- (void)_goRightVote {
	[_lVoteButton removeTarget:self action:@selector(_goLeftVote:) forControlEvents:UIControlEventTouchUpInside];
	[_rVoteButton removeTarget:self action:@selector(_goRightVote:) forControlEvents:UIControlEventTouchUpInside];
	
	UIView *overlayView = [[UIView alloc] initWithFrame:_lHolderView.frame];
	overlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.67];
	[self addSubview:overlayView];
	
	UIImageView *rScoreImgView = [[UIImageView alloc] initWithFrame:CGRectMake(190.0, 146.0, 84.0, 84.0)];
	rScoreImgView.image = [UIImage imageNamed:@"likeOverlay.png"];
	[self addSubview:rScoreImgView];
	
	UILabel *rScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 18.0, 84.0, 18.0)];
	rScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:18];
	rScoreLabel.backgroundColor = [UIColor clearColor];
	rScoreLabel.textColor = [UIColor whiteColor];
	rScoreLabel.textAlignment = NSTextAlignmentCenter;
	rScoreLabel.text = [NSString stringWithFormat:@"%d", (_challengeVO.scoreChallenger + 1)];
	[rScoreImgView addSubview:rScoreLabel];
	
	if (_challengeVO.scoreCreator > _challengeVO.scoreChallenger)
		rScoreLabel.text = [NSString stringWithFormat:@"%d Winning", (_challengeVO.scoreCreator + 1)];
	
	else if (_challengeVO.scoreCreator < _challengeVO.scoreChallenger)
		rScoreLabel.text = [NSString stringWithFormat:@"%d Losing", (_challengeVO.scoreCreator + 1)];
	
	_sfxPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"fpo_upvote" withExtension:@"mp3"] error:NULL];
	_sfxPlayer.delegate = self;
	[_sfxPlayer play];
	
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"VOTE_SUB" object:self.challengeVO];
}

- (void)_goScore {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_VOTERS" object:self.challengeVO];
}

- (void)_goDailyChallenge {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DAILY_CHALLENGE" object:nil];
}

- (void)_goMore {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"VOTE_MORE" object:self.challengeVO];
}

@end
