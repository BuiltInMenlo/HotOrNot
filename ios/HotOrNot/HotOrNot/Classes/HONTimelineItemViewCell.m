//
//  HONTimelineItemViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"

#import "HONTimelineItemViewCell.h"
#import "HONAppDelegate.h"
#import "HONVoterVO.h"
#import "HONUserVO.h"


@interface HONTimelineItemViewCell() <AVAudioPlayerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) UIView *lHolderView;
@property (nonatomic, strong) UIView *rHolderView;
@property (nonatomic, strong) UILabel *lScoreLabel;
@property (nonatomic, strong) UILabel *rScoreLabel;
@property (nonatomic, strong) UIImageView *heartImageView;
@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, strong) UILabel *commentsLabel;
@property (nonatomic, strong) UIView *tappedOverlayView;
@property (nonatomic, strong) UIImageView *tapOverlayImageView;
@property (nonatomic, strong) UIButton *votesButton;
@property (nonatomic, strong) NSMutableArray *voters;
@property (nonatomic) BOOL hasChallenger;
@property (nonatomic, strong) AVAudioPlayer *sfxPlayer;
@end

@implementation HONTimelineItemViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initAsWaitingCell {
	if ((self = [super init])) {
		_hasChallenger = NO;
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 304.0)];
		bgImgView.image = [UIImage imageNamed:@"voteTimelineBackground"];
		[self addSubview:bgImgView];
	}
	
	return (self);
}

- (id)initAsStartedCell {
	if ((self = [super init])) {
		_hasChallenger = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_upvoteCreator:) name:@"UPVOTE_CREATOR" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_upvoteChallenger:) name:@"UPVOTE_CHALLENGER" object:nil];
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 304.0)];
		bgImgView.image = [UIImage imageNamed:@"voteTimelineBackground"];
		[self addSubview:bgImgView];
	}
	
	return (self);
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	_tapOverlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blackOverlay_50"]];
	_tapOverlayImageView.layer.cornerRadius = 2.0;
	_tapOverlayImageView.clipsToBounds = YES;
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 15.0, 200.0, 22.0)];
	subjectLabel.font = [[HONAppDelegate cartoGothicBold] fontWithSize:18];
	subjectLabel.textColor = [HONAppDelegate honBlueTxtColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _challengeVO.subjectName;
	[self addSubview:subjectLabel];
	
	UIButton *subjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
	subjectButton.frame = subjectLabel.frame;
	[subjectButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
	[subjectButton addTarget:self action:@selector(_goSubjectTimeline) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:subjectButton];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(238.0, 15.0, 60.0, 16.0)];
	timeLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:11];
	timeLabel.textColor = [HONAppDelegate honGrey635Color];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = [HONAppDelegate timeSinceDate:_challengeVO.updatedDate];
	[self addSubview:timeLabel];
	
	_lHolderView = [[UIView alloc] initWithFrame:CGRectMake(7.0, 46.0, 153.0, 153.0)];
	_lHolderView.clipsToBounds = YES;
	[self addSubview:_lHolderView];
	
	UIImageView *lImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -25.0, kSnapMediumSize.width, kSnapMediumSize.height)];
	lImgView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
	[lImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", challengeVO.creatorImgPrefix]] placeholderImage:nil];
	lImgView.userInteractionEnabled = YES;
	[_lHolderView addSubview:lImgView];
	
	UIImageView *creatorAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 209.0, 38.0, 38.0)];
	creatorAvatarImageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
	[creatorAvatarImageView setImageWithURL:[NSURL URLWithString:_challengeVO.creatorAvatar] placeholderImage:nil];
	creatorAvatarImageView.userInteractionEnabled = YES;
	[self addSubview:creatorAvatarImageView];
	
	UIButton *creatorAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	creatorAvatarButton.frame = creatorAvatarImageView.frame;
	[creatorAvatarButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
	[creatorAvatarButton addTarget:self action:@selector(_goCreatorTimeline) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:creatorAvatarButton];
	
	UILabel *creatorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(58.0, 221.0, 100.0, 20.0)];
	creatorNameLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:13];
	creatorNameLabel.textColor = [HONAppDelegate honGrey635Color];
	creatorNameLabel.backgroundColor = [UIColor clearColor];
	creatorNameLabel.text = [NSString stringWithFormat:@"@%@", _challengeVO.creatorName];
	[self addSubview:creatorNameLabel];
	
	UIButton *creatorNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	creatorNameButton.frame = creatorNameLabel.frame;
	[creatorNameButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
	[creatorNameButton addTarget:self action:@selector(_goCreatorTimeline) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:creatorNameButton];
	
	_rHolderView = [[UIView alloc] initWithFrame:CGRectMake(160.0, 46.0, 153.0, 153.0)];
	_rHolderView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	_rHolderView.clipsToBounds = YES;
	[self addSubview:_rHolderView];
	
	if (_hasChallenger) {
		UIImageView *rImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -25.0, kSnapMediumSize.width, kSnapMediumSize.height)];
		rImgView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		[rImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", challengeVO.challengerImgPrefix]] placeholderImage:nil];
		rImgView.userInteractionEnabled = YES;
		[_rHolderView addSubview:rImgView];
		
		UIImageView *challengerAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(160.0, 209.0, 38.0, 38.0)];
		challengerAvatarImageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		[challengerAvatarImageView setImageWithURL:[NSURL URLWithString:_challengeVO.challengerAvatar] placeholderImage:nil];
		challengerAvatarImageView.userInteractionEnabled = YES;
		challengerAvatarImageView.clipsToBounds = YES;
		[self addSubview:challengerAvatarImageView];
		
		UIButton *challengerAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		challengerAvatarButton.frame = challengerAvatarImageView.frame;
		[challengerAvatarButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
		[challengerAvatarButton addTarget:self action:@selector(_goChallengerTimeline) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:challengerAvatarButton];
		
		UILabel *challengerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(209.0, 221.0, 100.0, 20.0)];
		challengerNameLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:13];
		challengerNameLabel.textColor = [HONAppDelegate honGrey635Color];
		challengerNameLabel.backgroundColor = [UIColor clearColor];
		challengerNameLabel.text = [NSString stringWithFormat:@"@%@", _challengeVO.challengerName];
		[self addSubview:challengerNameLabel];
		
		UIButton *challengerNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
		challengerNameButton.frame = challengerNameLabel.frame;
		[challengerNameButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
		[challengerNameButton addTarget:self action:@selector(_goChallengerTimeline) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:challengerNameButton];
		
		
		UIImageView *likeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 256.0, 24.0, 24.0)];
		likeImageView.image = [UIImage imageNamed:@"heartIcon_nonActive"];
		[self addSubview:likeImageView];
		
		_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 256.0, 150.0, 24.0)];
		_likesLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:11];
		_likesLabel.textColor = [HONAppDelegate honGrey455Color];
		_likesLabel.backgroundColor = [UIColor clearColor];
		_likesLabel.text = [NSString stringWithFormat:(_challengeVO.creatorScore + _challengeVO.challengerScore == 1) ? NSLocalizedString(@"timeline_like", nil) : NSLocalizedString(@"timeline_likes", nil), (_challengeVO.creatorScore + _challengeVO.challengerScore)];
		[self addSubview:_likesLabel];
		
		UIButton *likesButton = [UIButton buttonWithType:UIButtonTypeCustom];
		likesButton.frame = CGRectMake(13.0, 256.0, 190.0, 24.0);
		[likesButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
		[likesButton addTarget:self action:@selector(_goScore) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:likesButton];
		
	} else {
		UIImageView *rImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 153.0, 153.0)];
		rImgView.image = [UIImage imageNamed:([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _challengeVO.creatorID) ? @"pokeThumb" : @"thumbCameraAction"];
		rImgView.userInteractionEnabled = YES;
		[_rHolderView addSubview:rImgView];
		
		if (_challengeVO.challengerID != 0) {
			UIImageView *challengerAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(160.0, 209.0, 38.0, 38.0)];
			challengerAvatarImageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
			[challengerAvatarImageView setImageWithURL:[NSURL URLWithString:_challengeVO.challengerAvatar] placeholderImage:nil];
			challengerAvatarImageView.userInteractionEnabled = YES;
			challengerAvatarImageView.clipsToBounds = YES;
			[self addSubview:challengerAvatarImageView];
			
			UIButton *challengerAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
			challengerAvatarButton.frame = challengerAvatarImageView.frame;
			[challengerAvatarButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
			[challengerAvatarButton addTarget:self action:@selector(_goChallengerTimeline) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:challengerAvatarButton];
			
			UILabel *challengerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(209.0, 221.0, 100.0, 20.0)];
			challengerNameLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:13];
			challengerNameLabel.textColor = [HONAppDelegate honGrey635Color];
			challengerNameLabel.backgroundColor = [UIColor clearColor];
			challengerNameLabel.text = [NSString stringWithFormat:@"@%@", _challengeVO.challengerName];
			[self addSubview:challengerNameLabel];
			
			UIButton *challengerNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
			challengerNameButton.frame = challengerNameLabel.frame;
			[challengerNameButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
			[challengerNameButton addTarget:self action:@selector(_goChallengerTimeline) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:challengerNameButton];
		}
	}
	
	UIImageView *lScoreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(4.0, 112.0, 34.0, 34.0)];
	lScoreImageView.image = [UIImage imageNamed:@"voteIconVoteTimeline"];
	[_lHolderView addSubview:lScoreImageView];
	
	_lScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(36.0, 107.0, 52.0, 52.0)];
	_lScoreLabel.font = [[HONAppDelegate cartoGothicBold] fontWithSize:24];
	_lScoreLabel.backgroundColor = [UIColor clearColor];
	_lScoreLabel.textColor = [UIColor whiteColor];
	_lScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.creatorScore];
	[_lHolderView addSubview:_lScoreLabel];
	
	
	UIImageView *rScoreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(4.0, 112.0, 34.0, 34.0)];
	rScoreImageView.image = [UIImage imageNamed:@"voteIconVoteTimeline"];
	[_rHolderView addSubview:rScoreImageView];
	
	_rScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(36.0, 107.0, 52.0, 52.0)];
	_rScoreLabel.font = [[HONAppDelegate cartoGothicBold] fontWithSize:24];
	_rScoreLabel.backgroundColor = [UIColor clearColor];
	_rScoreLabel.textColor = [UIColor whiteColor];
	_rScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.challengerScore];
	[_rHolderView addSubview:_rScoreLabel];
	
	UIImageView *commentsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, (_hasChallenger) ? 279.0 : 256.0, 24.0, 24.0)];
	commentsImageView.image = [UIImage imageNamed:@"commentIcon_nonActive"];
	[self addSubview:commentsImageView];
	
	_commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, (_hasChallenger) ? 279.0 : 254.0, 150.0, 24.0)];
	_commentsLabel.font = [[HONAppDelegate cartoGothicBold] fontWithSize:11];
	_commentsLabel.textColor = [HONAppDelegate honGrey455Color];
	_commentsLabel.backgroundColor = [UIColor clearColor];
	_commentsLabel.text = (_challengeVO.commentTotal == 0) ? NSLocalizedString(@"timeline_0comments", nil) : (_challengeVO.commentTotal > 99) ? NSLocalizedString(@"timeline_99comments", nil) : [NSString stringWithFormat:(_challengeVO.commentTotal == 1) ? NSLocalizedString(@"timeline_1comment", nil) : NSLocalizedString(@"timeline_comments", nil), _challengeVO.commentTotal];
	[self addSubview:_commentsLabel];
	
	UIButton *commentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	commentsButton.frame = _commentsLabel.frame;
	[commentsButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
	[commentsButton addTarget:self action:@selector(_goComments) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:commentsButton];
	
	UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
	moreButton.frame = CGRectMake(240.0, (_hasChallenger) ? 259.0 : 245.0, 64.0, 44.0);
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive"] forState:UIControlStateNormal];
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_Active"] forState:UIControlStateHighlighted];
	[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:moreButton];
}


#pragma mark - Touch Interactions
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	if (touch.tapCount == 1) {
		if (CGRectContainsPoint(_lHolderView.frame, [touch locationInView:self])) {
			_tapOverlayImageView.frame = _lHolderView.frame;
			
		} else if (CGRectContainsPoint(_rHolderView.frame, [touch locationInView:self])) {
			_tapOverlayImageView.frame = _rHolderView.frame;
		}
		
		[self addSubview:_tapOverlayImageView];
			
	} else if (touch.tapCount == 2) {
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	//UITouch *touch = [touches anyObject];
	[_tapOverlayImageView removeFromSuperview];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	//UITouch *touch = [touches anyObject];
	[_tapOverlayImageView removeFromSuperview];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	[_tapOverlayImageView removeFromSuperview];
	
	// this is the single tap action
	if (touch.tapCount == 1) {
		if (CGRectContainsPoint(_lHolderView.frame, [touch locationInView:self])) {
			[self performSelector:@selector(_goSingleTapLeft) withObject:nil afterDelay:0.2];
		
		} else if (CGRectContainsPoint(_rHolderView.frame, [touch locationInView:self])) {
			[self performSelector:@selector(_goSingleTapRight) withObject:nil afterDelay:0.2];
			
		} else {
		}
		
	// this is the double tap action
	} else if (touch.tapCount == 2) {
		if (CGRectContainsPoint(_lHolderView.frame, [touch locationInView:self])) {
			[self _goDoubleTapLeft];
		
		} else if (CGRectContainsPoint(_rHolderView.frame, [touch locationInView:self])) {
			[self _goDoubleTapRight];
			
		} else {
		}
	}
}


#pragma mark - Navigation
- (void)_goSingleTapLeft {
	[[Mixpanel sharedInstance] track:@"Timeline - Single Tap Creator"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	if ([HONAppDelegate hasVoted:_challengeVO.challengeID] == 0) {
		[self _showTapOverlayOnView:_lHolderView];
		
		if (_hasChallenger)
			[[NSNotificationCenter defaultCenter] postNotificationName:@"UPVOTE_CREATOR" object:_challengeVO];
		
		else {
			if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != _challengeVO.creatorID) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_CREATOR_CHALLENGE" object:_challengeVO];
				
			} else {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_SUBJECT_CHALLENGE" object:_challengeVO];
			}
		}
	}
}

- (void)_goSingleTapRight {
	[[Mixpanel sharedInstance] track:@"Timeline - Single Tap Challenger"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	if ([HONAppDelegate hasVoted:_challengeVO.challengeID] == 0) {
		[self _showTapOverlayOnView:_rHolderView];
		
		if (_hasChallenger)
			[[NSNotificationCenter defaultCenter] postNotificationName:@"UPVOTE_CHALLENGER" object:_challengeVO];
		
		else {
			if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != _challengeVO.creatorID) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_CREATOR_CHALLENGE" object:_challengeVO];
				
			} else {
				HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
																					[NSString stringWithFormat:@"%d", _challengeVO.challengerID], @"id",
																					[NSString stringWithFormat:@"%d", 0], @"points",
																					[NSString stringWithFormat:@"%d", 0], @"votes",
																					[NSString stringWithFormat:@"%d", 0], @"pokes",
																					[NSString stringWithFormat:@"%d", 0], @"pics",
																					_challengeVO.challengerName, @"username",
																					_challengeVO.challengerFB, @"fb_id",
																					_challengeVO.challengerAvatar, @"avatar_url", nil]];
				
				[[NSNotificationCenter defaultCenter] postNotificationName:@"POKE_USER" object:userVO];
			}
		}
	}
}

- (void)_goDoubleTapLeft {
	[self _showTapOverlayOnView:_lHolderView];
	
	[[Mixpanel sharedInstance] track:@"Timeline - Double Tap Creator"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	if (_hasChallenger) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_IN_SESSION_CREATOR_DETAILS" object:_challengeVO];
		
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_NOT_IN_SESSION_DETAILS" object:_challengeVO];
	}
}

- (void)_goDoubleTapRight {
	[self _showTapOverlayOnView:_rHolderView];
	
	[[Mixpanel sharedInstance] track:@"Timeline - Double Tap Challenger"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	if (_hasChallenger)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_IN_SESSION_CHALLENGER_DETAILS" object:_challengeVO];
	
	else {
		if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != _challengeVO.creatorID) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_CREATOR_CHALLENGE" object:_challengeVO];
			
		} else {
			HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
																				[NSString stringWithFormat:@"%d", _challengeVO.challengerID], @"id",
																				[NSString stringWithFormat:@"%d", 0], @"points",
																				[NSString stringWithFormat:@"%d", 0], @"votes",
																				[NSString stringWithFormat:@"%d", 0], @"pokes",
																				[NSString stringWithFormat:@"%d", 0], @"pics",
																				_challengeVO.challengerName, @"username",
																				_challengeVO.challengerFB, @"fb_id",
																				_challengeVO.challengerAvatar, @"avatar_url", nil]];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"POKE_USER" object:userVO];
		}
	}
}

- (void)_goCreateChallenge {
	if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != _challengeVO.creatorID) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_CREATOR_CHALLENGE" object:_challengeVO];
		
	} else
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_SUBJECT_CHALLENGE" object:_challengeVO];
}

- (void)_goScore {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_VOTERS" object:_challengeVO];
}

- (void)_goComments {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_COMMENTS" object:_challengeVO];
}

- (void)_goMore {
	[[Mixpanel sharedInstance] track:@"Timeline - More Shelf"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	if (_hasChallenger) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																					delegate:self
																		cancelButtonTitle:@"Cancel"
																 destructiveButtonTitle:@"Report Abuse"
																		otherButtonTitles:[NSString stringWithFormat:@"Snap this %@", _challengeVO.subjectName], [NSString stringWithFormat:@"Snap @%@", _challengeVO.creatorName], [NSString stringWithFormat:@"Snap @%@", _challengeVO.challengerName], nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
		[actionSheet setTag:0];
		[actionSheet showInView:[HONAppDelegate appTabBarController].view];
	
	} else {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																					delegate:self
																		cancelButtonTitle:@"Cancel"
																 destructiveButtonTitle:@"Report Abuse"
																		otherButtonTitles:[NSString stringWithFormat:@"Snap this %@", _challengeVO.subjectName], @"Snap@Me", nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
		[actionSheet setTag:1];
		[actionSheet showInView:[HONAppDelegate appTabBarController].view];
	}
}

- (void)_goSubjectTimeline {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUBJECT_SEARCH_TIMELINE" object:_challengeVO.subjectName];
}

- (void)_goCreatorTimeline {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_USER_SEARCH_TIMELINE" object:_challengeVO.creatorName];
}

- (void)_goChallengerTimeline {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_USER_SEARCH_TIMELINE" object:_challengeVO.challengerName];
}


#pragma mark - Notifications
- (void)_upvoteCreator:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	if ([vo isEqual:_challengeVO]) {
		//[self _playVoteSFX];
		
		_heartImageView = [[UIImageView alloc] initWithFrame:CGRectMake(33.0, 85.0, 84.0, 84.0)];
		_heartImageView.image = [UIImage imageNamed:@"largeHeart_nonActive"];
		[self addSubview:_heartImageView];
		
		[UIView animateWithDuration:0.33 delay:0.125 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_heartImageView.alpha = 0.0;
		} completion:^(BOOL finished) {
			[_heartImageView removeFromSuperview];
			_heartImageView = nil;
		}];
		
		_challengeVO.creatorScore++;
		
		NSString *caption;
		if ([HONAppDelegate hasVoted:_challengeVO.challengeID] != 0) {
			_lScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.creatorScore];
			caption = [NSString stringWithFormat:(_challengeVO.creatorScore + _challengeVO.challengerScore == 1) ? @"%d Like" : @"%d Likes", (_challengeVO.creatorScore + _challengeVO.challengerScore)];
		
		} else {
			[[Mixpanel sharedInstance] track:@"Timeline - Upvote Creator"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
														 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
			
			_lScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.creatorScore];
			caption = [NSString stringWithFormat:(_challengeVO.creatorScore + _challengeVO.challengerScore == 1) ? @"%d Like" : @"%d Likes", _challengeVO.creatorScore + _challengeVO.challengerScore];
			
			[HONAppDelegate setVote:_challengeVO.challengeID forCreator:YES];
			
			AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
			NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
											[NSString stringWithFormat:@"%d", 6], @"action",
											[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
											[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
											@"Y", @"creator",
											nil];
			
			[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
				NSError *error = nil;
				if (error != nil) {
					NSLog(@"HONVoteItemViewCell AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
					
				} else {
					NSDictionary *voteResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
					NSLog(@"HONVoteItemViewCell AFNetworking: %@", voteResult);
				}
				
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				NSLog(@"VoteItemViewCell AFNetworking %@", [error localizedDescription]);
			}];
		}
		
		[self _animateUpVote];
		_likesLabel.text = caption;
	}
}

- (void)_upvoteChallenger:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	if ([vo isEqual:_challengeVO]) {
		//[self _playVoteSFX];
		
		_heartImageView = [[UIImageView alloc] initWithFrame:CGRectMake(200.0, 85.0, 84.0, 84.0)];
		_heartImageView.image = [UIImage imageNamed:@"largeHeart_nonActive"];
		[self addSubview:_heartImageView];
		
		[UIView animateWithDuration:0.33 delay:0.125 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_heartImageView.alpha = 0.0;
		} completion:^(BOOL finished) {
			[_heartImageView removeFromSuperview];
			_heartImageView = nil;
		}];
		
		_challengeVO.challengerScore++;
		
		NSString *caption;
		if ([HONAppDelegate hasVoted:_challengeVO.challengeID] != 0) {
			_rScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.challengerScore];
			caption = [NSString stringWithFormat:(_challengeVO.creatorScore + _challengeVO.challengerScore == 1) ? @"%d Like" : @"%d Likes", (_challengeVO.creatorScore + _challengeVO.challengerScore)];
			
		} else {
			[[Mixpanel sharedInstance] track:@"Timeline - Upvote Challenger"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
														 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
			
			_rScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.challengerScore];
			caption = [NSString stringWithFormat:(_challengeVO.creatorScore + _challengeVO.challengerScore == 1) ? @"%d Like" : @"%d Likes", _challengeVO.creatorScore + _challengeVO.challengerScore];
			[HONAppDelegate setVote:_challengeVO.challengeID forCreator:NO];
			
			AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
			NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
											[NSString stringWithFormat:@"%d", 6], @"action",
											[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
											[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
											@"N", @"creator",
											nil];
			
			[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
				NSError *error = nil;
				if (error != nil) {
					NSLog(@"HONVoteItemViewCell AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
					
				} else {
					NSDictionary *voteResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
					NSLog(@"HONVoteItemViewCell AFNetworking: %@", voteResult);
				}
				
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				NSLog(@"HONVoteItemViewCell AFNetworking %@", [error localizedDescription]);
			}];
		}
		
		[self _animateUpVote];
		_likesLabel.text = _likesLabel.text = caption;
	}
}


#pragma mark - Behaviors
- (void)_playVoteSFX {
	_sfxPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"fpo_upvote" withExtension:@"mp3"] error:NULL];
	_sfxPlayer.delegate = self;
	[_sfxPlayer play];
}

- (void)_showTapOverlayOnView:(UIView *)view {
	_tappedOverlayView = [[UIView alloc] initWithFrame:view.frame];
	_tappedOverlayView.backgroundColor = [UIColor colorWithWhite:0.33 alpha:0.33];
	[self addSubview:_tappedOverlayView];
	
	[self performSelector:@selector(_removeTapOverlay) withObject:self afterDelay:0.125];
}

- (void)_removeTapOverlay {
	[_tappedOverlayView removeFromSuperview];
	_tappedOverlayView = nil;
}

- (void)_animateUpVote {
}


#pragma mark - ActionSheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		switch (buttonIndex) {
			case 0: {
				[[Mixpanel sharedInstance] track:@"Timeline - Flag"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
				
				AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
				NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSString stringWithFormat:@"%d", 11], @"action",
												[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
												[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
												nil];
				
				[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					NSError *error = nil;
					if (error != nil) {
						NSLog(@"HONVoteItemViewCell AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
						
					} else {
						//NSDictionary *flagResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
						//NSLog(@"HONVoteItemViewCell AFNetworking: %@", flagResult);
						[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_VOTE_TAB" object:nil];
						
					}
					
				} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					NSLog(@"VoteItemViewCell AFNetworking %@", [error localizedDescription]);
				}];
				
			break;}
				
			case 1:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_SUBJECT_CHALLENGE" object:_challengeVO];
				break;
				
			case 2:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_CREATOR_CHALLENGE" object:_challengeVO];
				break;
				
			case 3:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_CHALLENGER_CHALLENGE" object:_challengeVO];
				break;
		}
	}
	
	else if (actionSheet.tag == 1) {
		switch (buttonIndex) {
			case 0: {
				[[Mixpanel sharedInstance] track:@"Timeline - Flag"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
				
				AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
				NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSString stringWithFormat:@"%d", 11], @"action",
												[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
												[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
												nil];
				
				[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					NSError *error = nil;
					if (error != nil) {
						NSLog(@"HONVoteItemViewCell AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
						
					} else {
						//NSDictionary *flagResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
						//NSLog(@"HONVoteItemViewCell AFNetworking: %@", flagResult);
						[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_VOTE_TAB" object:nil];
					}
					
				} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					NSLog(@"VoteItemViewCell AFNetworking %@", [error localizedDescription]);
				}];
				
				break;}
				
			case 1:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_SUBJECT_CHALLENGE" object:_challengeVO];
				break;
				
			case 2:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_CREATOR_CHALLENGE" object:_challengeVO];
				break;
		}
	}
}


#pragma mark - AlertView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		switch(buttonIndex) {
			case 0:
				break;
				
			case 1:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_VOTERS" object:_challengeVO];
				break;
		}
	}
}

@end


