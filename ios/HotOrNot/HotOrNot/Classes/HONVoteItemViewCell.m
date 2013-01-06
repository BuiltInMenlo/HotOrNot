//
//  HONVoteItemViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "ASIFormDataRequest.h"
#import "Mixpanel.h"
#import "UIImageView+WebCache.h"

#import "HONVoteItemViewCell.h"
#import "HONAppDelegate.h"
#import "HONVoterVO.h"


@interface HONVoteItemViewCell() <AVAudioPlayerDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) UIView *lHolderView;
@property (nonatomic, strong) UIView *rHolderView;
@property (nonatomic, strong) UITapGestureRecognizer *rSingleTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *rDoubleTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *lSingleTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *lDoubleTapRecognizer;
@property (nonatomic, strong) NSMutableArray *voters;
@property (nonatomic) BOOL hasChallenger;
@property (nonatomic, strong) AVAudioPlayer *sfxPlayer;
@end

@implementation HONVoteItemViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initAsTopCell:(int)points withSubject:(NSString *)subject {
	if ((self = [super init])) {
		UIButton *dailyButton = [UIButton buttonWithType:UIButtonTypeCustom];
		dailyButton.frame = CGRectMake(0.0, 0.0, 320.0, 55.0);
		[dailyButton setBackgroundImage:[UIImage imageNamed:@"headerTableRow_nonActive"] forState:UIControlStateNormal];
		[dailyButton setBackgroundImage:[UIImage imageNamed:@"headerTableRow_Active"] forState:UIControlStateHighlighted];
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
		//bgImgView.image = [UIImage imageNamed:@"challengeBackground"];
		[self addSubview:bgImgView];
		
		UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
		moreButton.frame = CGRectMake(265.0, 16.0, 34.0, 34.0);
		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive"] forState:UIControlStateNormal];
		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive"] forState:UIControlStateHighlighted];
		[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:moreButton];
	}
	
	return (self);
}

- (id)initAsStartedCell {
	if ((self = [super init])) {
		_hasChallenger = YES;
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 54.0, 320.0, 341.0)];
		//bgImgView.image = [UIImage imageNamed:@"challengeBackground"];
		[self addSubview:bgImgView];
		
		UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
		moreButton.frame = CGRectMake(265.0, 16.0, 34.0, 34.0);
		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive"] forState:UIControlStateNormal];
		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive"] forState:UIControlStateHighlighted];
		[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:moreButton];
	}
	
	return (self);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	UILabel *ctaLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 25.0, 260.0, 16.0)];
	ctaLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
	ctaLabel.textColor = [HONAppDelegate honBlueTxtColor];
	ctaLabel.backgroundColor = [UIColor clearColor];
	ctaLabel.text = [HONAppDelegate ctaForChallenge:_challengeVO];
	[self addSubview:ctaLabel];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 25.0, 200.0, 16.0)];
	titleLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
	titleLabel.textColor = [HONAppDelegate honBlueTxtColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.text = _challengeVO.subjectName;
	//[self addSubview:titleLabel];
	
	//[_headerView setChallengeVO:challengeVO];
	
	if (_hasChallenger) {
		_lHolderView = [[UIView alloc] initWithFrame:CGRectMake(25.0, 71.0, 120.0, 245.0)];
		_lHolderView.clipsToBounds = YES;
		[self addSubview:_lHolderView];
		
		UIImageView *lImgView = [[UIImageView alloc] initWithFrame:CGRectMake(-50.0, 0.0, kMediumW, kMediumH)];
		lImgView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		[lImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", challengeVO.creatorImgPrefix]] placeholderImage:nil options:SDWebImageLowPriority];
		lImgView.userInteractionEnabled = YES;
		[_lHolderView addSubview:lImgView];
		
		_rHolderView = [[UIView alloc] initWithFrame:CGRectMake(173.0, 71.0, 120.0, 245.0)];
		_rHolderView.clipsToBounds = YES;
		[self addSubview:_rHolderView];
		
		UIImageView *rImgView = [[UIImageView alloc] initWithFrame:CGRectMake(-50.0, 0.0, kMediumW, kMediumH)];
		rImgView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		[rImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", challengeVO.challengerImgPrefix]] placeholderImage:nil options:SDWebImageLowPriority];
		rImgView.userInteractionEnabled = YES;
		[_rHolderView addSubview:rImgView];
		
		UIImageView *creatorAvatarImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 25.0, 25.0)];
		[creatorAvatarImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", _challengeVO.creatorFB]] placeholderImage:nil];
		[_lHolderView addSubview:creatorAvatarImgView];
		
		UIImageView *challengerAvatarImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 25.0, 25.0)];
		[challengerAvatarImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", _challengeVO.challengerFB]] placeholderImage:nil];
		[_rHolderView addSubview:challengerAvatarImgView];
		
		_lSingleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_goSingleTap:)];
		_lDoubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_goDoubleTap:)];
		
		[_lSingleTapRecognizer requireGestureRecognizerToFail:_lDoubleTapRecognizer];
		[_lDoubleTapRecognizer setNumberOfTapsRequired:2];
		[lImgView addGestureRecognizer:_lSingleTapRecognizer];
		[lImgView addGestureRecognizer:_lDoubleTapRecognizer];
		
		_rSingleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_goSingleTap:)];
		_rDoubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_goDoubleTap:)];
		
		[_rSingleTapRecognizer requireGestureRecognizerToFail:_rDoubleTapRecognizer];
		[_rDoubleTapRecognizer setNumberOfTapsRequired:2];
		[rImgView addGestureRecognizer:_rSingleTapRecognizer];
		[rImgView addGestureRecognizer:_rDoubleTapRecognizer];
				
		UIButton *scoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
		scoreButton.frame = CGRectMake(20.0, 370.0, 84.0, 16.0);
		[scoreButton setTitleColor:[HONAppDelegate honBlueTxtColor] forState:UIControlStateNormal];
		scoreButton.titleLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
		[scoreButton setTitle:[NSString stringWithFormat:@"%d likes", (_challengeVO.creatorScore + _challengeVO.challengerScore)] forState:UIControlStateNormal];
		[scoreButton addTarget:self action:@selector(_goScore) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:scoreButton];
		
		if ([HONAppDelegate hasVoted:_challengeVO.challengeID]) {
			[lImgView removeGestureRecognizer:_lSingleTapRecognizer];
			[lImgView removeGestureRecognizer:_lDoubleTapRecognizer];
			
			[rImgView removeGestureRecognizer:_rSingleTapRecognizer];
			[rImgView removeGestureRecognizer:_rDoubleTapRecognizer];
			
			if (_challengeVO.creatorScore > _challengeVO.challengerScore) {
				UIImageView *lScoreImgView = [[UIImageView alloc] initWithFrame:CGRectMake(43.0, 146.0, 84.0, 84.0)];
				lScoreImgView.image = [UIImage imageNamed:@"likeOverlay"];
				[self addSubview:lScoreImgView];
				
				UILabel *lScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 18.0, 84.0, 18.0)];
				lScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:18];
				lScoreLabel.backgroundColor = [UIColor clearColor];
				lScoreLabel.textColor = [UIColor whiteColor];
				lScoreLabel.textAlignment = NSTextAlignmentCenter;
				lScoreLabel.text = [NSString stringWithFormat:@"%d Winning", (_challengeVO.creatorScore + 1)];
				[lScoreImgView addSubview:lScoreLabel];
				
				//rScoreLabel.text = [NSString stringWithFormat:@"%d Losing", (_challengeVO.challengerScore + 1)];
				
			} else if (_challengeVO.creatorScore < _challengeVO.challengerScore) {
				UIImageView *rScoreImgView = [[UIImageView alloc] initWithFrame:CGRectMake(190.0, 146.0, 84.0, 84.0)];
				rScoreImgView.image = [UIImage imageNamed:@"likeOverlay"];
				[self addSubview:rScoreImgView];
				
				UILabel *rScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 18.0, 84.0, 18.0)];
				rScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:18];
				rScoreLabel.backgroundColor = [UIColor clearColor];
				rScoreLabel.textColor = [UIColor whiteColor];
				rScoreLabel.textAlignment = NSTextAlignmentCenter;
				rScoreLabel.text = [NSString stringWithFormat:@"%d Winning", (_challengeVO.challengerScore + 1)];
				[rScoreImgView addSubview:rScoreLabel];
				
				//lScoreLabel.text = [NSString stringWithFormat:@"%d Losing", (_challengeVO.creatorScore + 1)];
			
			} else {
				UIImageView *rScoreImgView = [[UIImageView alloc] initWithFrame:CGRectMake(190.0, 146.0, 84.0, 84.0)];
				rScoreImgView.image = [UIImage imageNamed:@"likeOverlay"];
				[self addSubview:rScoreImgView];
				
				UILabel *rScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 18.0, 84.0, 18.0)];
				rScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:18];
				rScoreLabel.backgroundColor = [UIColor clearColor];
				rScoreLabel.textColor = [UIColor whiteColor];
				rScoreLabel.textAlignment = NSTextAlignmentCenter;
				rScoreLabel.text = [NSString stringWithFormat:@"%d", (_challengeVO.challengerScore + 1)];
				[rScoreImgView addSubview:rScoreLabel];
				
				UIImageView *lScoreImgView = [[UIImageView alloc] initWithFrame:CGRectMake(43.0, 146.0, 84.0, 84.0)];
				lScoreImgView.image = [UIImage imageNamed:@"likeOverlay"];
				[self addSubview:lScoreImgView];
				
				UILabel *lScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 18.0, 84.0, 18.0)];
				lScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:18];
				lScoreLabel.backgroundColor = [UIColor clearColor];
				lScoreLabel.textColor = [UIColor whiteColor];
				lScoreLabel.textAlignment = NSTextAlignmentCenter;
				lScoreLabel.text = [NSString stringWithFormat:@"%d", (_challengeVO.creatorScore + 1)];
				[lScoreImgView addSubview:lScoreLabel];
			}
		}
		
	} else {
		_lHolderView = [[UIView alloc] initWithFrame:CGRectMake(7.0, 71.0, kLargeW * 0.5, kLargeW * 0.5)];
		[self addSubview:_lHolderView];
		
		UIImageView *lImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW * 0.5, kLargeW * 0.5)];
		[lImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", challengeVO.creatorImgPrefix]] placeholderImage:nil options:SDWebImageProgressiveDownload];
		lImgView.userInteractionEnabled = YES;
		[_lHolderView addSubview:lImgView];
		
		UIImageView *creatorAvatarImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 25.0, 25.0)];
		[creatorAvatarImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", _challengeVO.creatorFB]] placeholderImage:nil];
		[_lHolderView addSubview:creatorAvatarImgView];
		
		_lSingleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_goSingleTap:)];
		_lDoubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_goDoubleTap:)];
		
		[_lSingleTapRecognizer requireGestureRecognizerToFail:_lDoubleTapRecognizer];
		[_lDoubleTapRecognizer setNumberOfTapsRequired:2];
		[lImgView addGestureRecognizer:_lSingleTapRecognizer];
		[lImgView addGestureRecognizer:_lDoubleTapRecognizer];
	}
}


#pragma mark - Navigation
- (void)_goSingleTap:(UITapGestureRecognizer *)recogizer {
	if (_hasChallenger) {
		if ([recogizer isEqual:_lSingleTapRecognizer]) {
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																						delegate:self
																			cancelButtonTitle:@"Cancel"
																	 destructiveButtonTitle:nil
																			otherButtonTitles:
													[NSString stringWithFormat:@"Like - %dpts", [HONAppDelegate votePointMultiplier]],
													[NSString stringWithFormat:@"Challenge - %dpts", 5],
													[NSString stringWithFormat:@"Poke - %dpts", [HONAppDelegate pokePointMultiplier]], nil];
			actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
			
			[actionSheet setTag:0];
			[actionSheet showInView:[HONAppDelegate appTabBarController].view];
		
		} else {
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																						delegate:self
																			cancelButtonTitle:@"Cancel"
																	 destructiveButtonTitle:nil
																			otherButtonTitles:
													[NSString stringWithFormat:@"Like - %dpts", [HONAppDelegate votePointMultiplier]],
													[NSString stringWithFormat:@"Challenge - %dpts", 5],
													[NSString stringWithFormat:@"Poke - %dpts", [HONAppDelegate pokePointMultiplier]], nil];
			actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
			
			[actionSheet setTag:1];
			[actionSheet showInView:[HONAppDelegate appTabBarController].view];
		}
	
	} else {
		[self _goMore];
	}
}

- (void)_goDoubleTap:(UITapGestureRecognizer *)recogizer {
	
	if (_hasChallenger) {
		if ([recogizer isEqual:_lDoubleTapRecognizer]) {
			[[Mixpanel sharedInstance] track:@"Upvote Left"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
														 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
			
			[_lSingleTapRecognizer.view removeGestureRecognizer:_lSingleTapRecognizer];
			[_lDoubleTapRecognizer.view removeGestureRecognizer:_lDoubleTapRecognizer];
			
			[_rSingleTapRecognizer.view removeGestureRecognizer:_rSingleTapRecognizer];
			[_rDoubleTapRecognizer.view removeGestureRecognizer:_rDoubleTapRecognizer];
			
			UIView *overlayView = [[UIView alloc] initWithFrame:_rHolderView.frame];
			overlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.67];
			[self addSubview:overlayView];
			
			UIImageView *lScoreImgView = [[UIImageView alloc] initWithFrame:CGRectMake(43.0, 146.0, 84.0, 84.0)];
			lScoreImgView.image = [UIImage imageNamed:@"likeOverlay"];
			[self addSubview:lScoreImgView];
			
			UILabel *lScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 18.0, 84.0, 18.0)];
			lScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:18];
			lScoreLabel.backgroundColor = [UIColor clearColor];
			lScoreLabel.textColor = [UIColor whiteColor];
			lScoreLabel.textAlignment = NSTextAlignmentCenter;
			lScoreLabel.text = [NSString stringWithFormat:@"%d", (_challengeVO.creatorScore + 1)];
			[lScoreImgView addSubview:lScoreLabel];
			
			if (_challengeVO.creatorScore > _challengeVO.challengerScore)
				lScoreLabel.text = [NSString stringWithFormat:@"%d Winning", (_challengeVO.creatorScore + 1)];
			
			else if (_challengeVO.creatorScore < _challengeVO.challengerScore)
				lScoreLabel.text = [NSString stringWithFormat:@"%d Losing", (_challengeVO.creatorScore + 1)];
			
			_sfxPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"fpo_upvote" withExtension:@"mp3"] error:NULL];
			_sfxPlayer.delegate = self;
			[_sfxPlayer play];
			
			ASIFormDataRequest *voteRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kVotesAPI]]];
			[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
			[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
			[voteRequest setPostValue:[NSString stringWithFormat:@"%d", _challengeVO.challengeID] forKey:@"challengeID"];
			[voteRequest setPostValue:@"Y" forKey:@"creator"];
			[voteRequest startAsynchronous];
			
			[HONAppDelegate setVote:_challengeVO.challengeID];
		
		} else {
			[[Mixpanel sharedInstance] track:@"Upvote Right"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
														 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
			
			
			[_lSingleTapRecognizer.view removeGestureRecognizer:_lSingleTapRecognizer];
			[_lDoubleTapRecognizer.view removeGestureRecognizer:_lDoubleTapRecognizer];
			
			[_rSingleTapRecognizer.view removeGestureRecognizer:_rSingleTapRecognizer];
			[_rDoubleTapRecognizer.view removeGestureRecognizer:_rDoubleTapRecognizer];
			
			UIView *overlayView = [[UIView alloc] initWithFrame:_lHolderView.frame];
			overlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.67];
			[self addSubview:overlayView];
			
			UIImageView *rScoreImgView = [[UIImageView alloc] initWithFrame:CGRectMake(190.0, 146.0, 84.0, 84.0)];
			rScoreImgView.image = [UIImage imageNamed:@"likeOverlay"];
			[self addSubview:rScoreImgView];
			
			UILabel *rScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 18.0, 84.0, 18.0)];
			rScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:18];
			rScoreLabel.backgroundColor = [UIColor clearColor];
			rScoreLabel.textColor = [UIColor whiteColor];
			rScoreLabel.textAlignment = NSTextAlignmentCenter;
			rScoreLabel.text = [NSString stringWithFormat:@"%d", (_challengeVO.challengerScore + 1)];
			[rScoreImgView addSubview:rScoreLabel];
			
			if (_challengeVO.creatorScore > _challengeVO.challengerScore)
				rScoreLabel.text = [NSString stringWithFormat:@"%d Winning", (_challengeVO.creatorScore + 1)];
			
			else if (_challengeVO.creatorScore < _challengeVO.challengerScore)
				rScoreLabel.text = [NSString stringWithFormat:@"%d Losing", (_challengeVO.creatorScore + 1)];
			
			_sfxPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"fpo_upvote" withExtension:@"mp3"] error:NULL];
			_sfxPlayer.delegate = self;
			[_sfxPlayer play];
			
			ASIFormDataRequest *voteRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kVotesAPI]]];
			[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
			[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
			[voteRequest setPostValue:[NSString stringWithFormat:@"%d", _challengeVO.challengeID] forKey:@"challengeID"];
			[voteRequest setPostValue:@"N" forKey:@"creator"];
			[voteRequest startAsynchronous];
			
			[HONAppDelegate setVote:_challengeVO.challengeID];
		}
	
	} else {
		[[Mixpanel sharedInstance] track:@"Vote Wall - Challenge Challenger"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
													 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CHALLENGE_SUB" object:_challengeVO];
	}
}

- (void)_goScore {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_VOTERS" object:_challengeVO];
}

- (void)_goDailyChallenge {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DAILY_CHALLENGE" object:nil];
}

- (void)_goMore {
	[[Mixpanel sharedInstance] track:@"Vote - More"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"user", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																				delegate:self
																	cancelButtonTitle:@"Cancel"
															 destructiveButtonTitle:@"Report Abuse"
																	otherButtonTitles:[NSString stringWithFormat:@"Challenge - %dpts", 5],
											[NSString stringWithFormat:@"Poke - %dpts", [HONAppDelegate pokePointMultiplier]], nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	
	[actionSheet setTag:2];
	[actionSheet showInView:[HONAppDelegate appTabBarController].view];
}


#pragma mark - ActionSheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	ASIFormDataRequest *voteRequest;
	
	NSLog(@"BUTTON:[%d][%d]", buttonIndex, actionSheet.destructiveButtonIndex);
	
	if (actionSheet.tag == 0) {
		switch (buttonIndex) {
			case 0: {
				[[Mixpanel sharedInstance] track:@"Upvote Left"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
				
				[_lSingleTapRecognizer.view removeGestureRecognizer:_lSingleTapRecognizer];
				[_lDoubleTapRecognizer.view removeGestureRecognizer:_lDoubleTapRecognizer];
				
				[_rSingleTapRecognizer.view removeGestureRecognizer:_rSingleTapRecognizer];
				[_rDoubleTapRecognizer.view removeGestureRecognizer:_rDoubleTapRecognizer];
				
				UIView *overlayView = [[UIView alloc] initWithFrame:_rHolderView.frame];
				overlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.67];
				[self addSubview:overlayView];
				
				UIImageView *lScoreImgView = [[UIImageView alloc] initWithFrame:CGRectMake(43.0, 146.0, 84.0, 84.0)];
				lScoreImgView.image = [UIImage imageNamed:@"likeOverlay"];
				[self addSubview:lScoreImgView];
				
				UILabel *lScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 18.0, 84.0, 18.0)];
				lScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:18];
				lScoreLabel.backgroundColor = [UIColor clearColor];
				lScoreLabel.textColor = [UIColor whiteColor];
				lScoreLabel.textAlignment = NSTextAlignmentCenter;
				lScoreLabel.text = [NSString stringWithFormat:@"%d", (_challengeVO.creatorScore + 1)];
				[lScoreImgView addSubview:lScoreLabel];
				
				if (_challengeVO.creatorScore > _challengeVO.challengerScore)
					lScoreLabel.text = [NSString stringWithFormat:@"%d Winning", (_challengeVO.creatorScore + 1)];
				
				else if (_challengeVO.creatorScore < _challengeVO.challengerScore)
					lScoreLabel.text = [NSString stringWithFormat:@"%d Losing", (_challengeVO.creatorScore + 1)];
				
				_sfxPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"fpo_upvote" withExtension:@"mp3"] error:NULL];
				_sfxPlayer.delegate = self;
				[_sfxPlayer play];
				
				voteRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kVotesAPI]]];
				[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
				[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
				[voteRequest setPostValue:[NSString stringWithFormat:@"%d", _challengeVO.challengeID] forKey:@"challengeID"];
				[voteRequest setPostValue:@"Y" forKey:@"creator"];
				[voteRequest startAsynchronous];
				
				[HONAppDelegate setVote:_challengeVO.challengeID];
				break;}
				
			case 1:
				[[Mixpanel sharedInstance] track:@"Vote Wall - Challenge Creator"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
				
				[[NSNotificationCenter defaultCenter] postNotificationName:@"CHALLENGE_MAIN" object:_challengeVO];
				break;
				
			case 3:
				[[Mixpanel sharedInstance] track:@"Poke Creator"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
				
				voteRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kUsersAPI]]];
				[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
				[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"pokerID"];
				[voteRequest setPostValue:[NSString stringWithFormat:@"%d", _challengeVO.creatorID] forKey:@"pokeeID"];
				[voteRequest startAsynchronous];
				break;
		}
		
	} else if (actionSheet.tag == 1) {
		switch (buttonIndex) {
			case 0:{
				[[Mixpanel sharedInstance] track:@"Upvote Right"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
								
				[_lSingleTapRecognizer.view removeGestureRecognizer:_lSingleTapRecognizer];
				[_lDoubleTapRecognizer.view removeGestureRecognizer:_lDoubleTapRecognizer];
				
				[_rSingleTapRecognizer.view removeGestureRecognizer:_rSingleTapRecognizer];
				[_rDoubleTapRecognizer.view removeGestureRecognizer:_rDoubleTapRecognizer];
				
				UIView *overlayView = [[UIView alloc] initWithFrame:_lHolderView.frame];
				overlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.67];
				[self addSubview:overlayView];
				
				UIImageView *rScoreImgView = [[UIImageView alloc] initWithFrame:CGRectMake(190.0, 146.0, 84.0, 84.0)];
				rScoreImgView.image = [UIImage imageNamed:@"likeOverlay"];
				[self addSubview:rScoreImgView];
				
				UILabel *rScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 18.0, 84.0, 18.0)];
				rScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:18];
				rScoreLabel.backgroundColor = [UIColor clearColor];
				rScoreLabel.textColor = [UIColor whiteColor];
				rScoreLabel.textAlignment = NSTextAlignmentCenter;
				rScoreLabel.text = [NSString stringWithFormat:@"%d", (_challengeVO.challengerScore + 1)];
				[rScoreImgView addSubview:rScoreLabel];
				
				if (_challengeVO.creatorScore > _challengeVO.challengerScore)
					rScoreLabel.text = [NSString stringWithFormat:@"%d Winning", (_challengeVO.creatorScore + 1)];
				
				else if (_challengeVO.creatorScore < _challengeVO.challengerScore)
					rScoreLabel.text = [NSString stringWithFormat:@"%d Losing", (_challengeVO.creatorScore + 1)];
				
				_sfxPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"fpo_upvote" withExtension:@"mp3"] error:NULL];
				_sfxPlayer.delegate = self;
				[_sfxPlayer play];
				
				voteRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kVotesAPI]]];
				[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
				[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
				[voteRequest setPostValue:[NSString stringWithFormat:@"%d", _challengeVO.challengeID] forKey:@"challengeID"];
				[voteRequest setPostValue:@"N" forKey:@"creator"];
				[voteRequest startAsynchronous];
				
				[HONAppDelegate setVote:_challengeVO.challengeID];
				break;}
				
			case 1:
				[[Mixpanel sharedInstance] track:@"Vote Wall - Challenge Challenger"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
				
				[[NSNotificationCenter defaultCenter] postNotificationName:@"CHALLENGE_SUB" object:_challengeVO];
				break;
				
			case 3:
				[[Mixpanel sharedInstance] track:@"Vote Wall - Poke Challenger"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
				
				voteRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kUsersAPI]]];
				[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
				[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"pokerID"];
				[voteRequest setPostValue:[NSString stringWithFormat:@"%d", _challengeVO.challengerID] forKey:@"pokeeID"];
				[voteRequest startAsynchronous];
				break;
		}
	
	} else if (actionSheet.tag == 2) {
		switch (buttonIndex) {
			case 0:
				[[Mixpanel sharedInstance] track:@"Vote Wall - Flag"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"user", nil]];
				
				[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 11] forKey:@"action"];
				[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
				[voteRequest setPostValue:[NSString stringWithFormat:@"%d", _challengeVO.challengeID] forKey:@"challengeID"];
				[voteRequest startAsynchronous];
				break;
				
			case 1:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"VOTE_MORE" object:_challengeVO];
				break;
				
			case 2:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHARE_CHALLENGE" object:_challengeVO];
				break;
		}
	}
}


@end


