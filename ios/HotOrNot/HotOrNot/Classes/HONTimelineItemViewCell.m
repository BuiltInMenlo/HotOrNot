//
//  HONTimelineItemViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "Mixpanel.h"
#import "UIImageView+AFNetworking.h"

#import "HONTimelineItemViewCell.h"
#import "HONAppDelegate.h"
#import "HONVoterVO.h"


@interface HONTimelineItemViewCell() <AVAudioPlayerDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) UIView *lHolderView;
@property (nonatomic, strong) UIView *rHolderView;
@property (nonatomic, strong) UIView *tappedOverlayView;
@property (nonatomic, strong) UILabel *lScoreLabel;
@property (nonatomic, strong) UILabel *rScoreLabel;
@property (nonatomic, strong) UIButton *votesButton;
@property (nonatomic, strong) UILabel *votesLabel;
@property (nonatomic, strong) UIView *loserOverlayView;
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
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 463.0)];
		bgImgView.image = [UIImage imageNamed:@"nonAcceptedRowBackground"];
		[self addSubview:bgImgView];
	}
	
	return (self);
}

- (id)initAsStartedCell {
	if ((self = [super init])) {
		_hasChallenger = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_upvoteCreator:) name:@"UPVOTE_CREATOR" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_upvoteChallenger:) name:@"UPVOTE_CHALLENGER" object:nil];
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 309.0)];
		bgImgView.image = [UIImage imageNamed:@"acceptedRowBackground"];
		[self addSubview:bgImgView];
	}
	
	return (self);
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
		
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 8.0, 200.0, 24.0)];
	subjectLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:16];
	subjectLabel.textColor = [HONAppDelegate honBlueTxtColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _challengeVO.subjectName;
	[self addSubview:subjectLabel];
	
	UIButton *subjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
	subjectButton.frame = subjectLabel.frame;
	[subjectButton addTarget:self action:@selector(_goSubjectTimeline) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:subjectButton];
	
	if ([_challengeVO.rechallengedUsers length] > 0) {
		UIButton *rechallengedButton = [UIButton buttonWithType:UIButtonTypeCustom];
		rechallengedButton.frame = CGRectMake(210.0, 8.0, 90.0, 24.0);
		[rechallengedButton setBackgroundImage:[UIImage imageNamed:@"reSnappedIcon"] forState:UIControlStateNormal];
		[rechallengedButton setBackgroundImage:[UIImage imageNamed:@"reSnappedIcon"] forState:UIControlStateHighlighted];
		//[rechallengedButton addTarget:self action:@selector(_goCreateChallenge) forControlEvents:UIControlEventTouchUpInside];
		rechallengedButton.titleLabel.font = [[HONAppDelegate qualcommBold] fontWithSize:12];
		[rechallengedButton setTitleColor:[HONAppDelegate honGreyTxtColor] forState:UIControlStateNormal];
		[self addSubview:rechallengedButton];
	}
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(240.0, 10.0, 60.0, 16.0)];
	timeLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
	timeLabel.textColor = [HONAppDelegate honGreyTxtColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = [HONAppDelegate timeSinceDate:_challengeVO.startedDate];
	[self addSubview:timeLabel];
	
	UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
	moreButton.frame = CGRectMake(266.0, 245.0, 44.0, 44.0);
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive"] forState:UIControlStateNormal];
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive"] forState:UIControlStateHighlighted];
	[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:moreButton];
	
	if (_hasChallenger) {
		_lHolderView = [[UIView alloc] initWithFrame:CGRectMake(7.0, 46.0, 153.0, 153.0)];
		_lHolderView.clipsToBounds = YES;
		[self addSubview:_lHolderView];
		
		UIImageView *lImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -25.0, kMediumW, kMediumH)];
		lImgView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		[lImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", challengeVO.creatorImgPrefix]] placeholderImage:nil];
		lImgView.userInteractionEnabled = YES;
		[_lHolderView addSubview:lImgView];
		
//		UIImageView *lScoreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 123.0, 153.0, 30.0)];
//		lScoreImageView.image = [UIImage imageNamed:@"challengeWallScore_Overlay"];
//		[_lHolderView addSubview:lScoreImageView];
//		
//		_lScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 7.0, 144.0, 18.0)];
//		_lScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
//		_lScoreLabel.backgroundColor = [UIColor clearColor];
//		_lScoreLabel.textColor = [UIColor whiteColor];
//		_lScoreLabel.textAlignment = NSTextAlignmentRight;
//		_lScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.creatorScore];
//		[lScoreImageView addSubview:_lScoreLabel];
		
		UIImageView *creatorAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 215.0, 35.0, 35.0)];
		creatorAvatarImageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		[creatorAvatarImageView setImageWithURL:[NSURL URLWithString:_challengeVO.creatorAvatar] placeholderImage:nil];
		creatorAvatarImageView.userInteractionEnabled = YES;
		[self addSubview:creatorAvatarImageView];
		
		UIButton *creatorAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		creatorAvatarButton.frame = creatorAvatarImageView.frame;
		[creatorAvatarButton addTarget:self action:@selector(_goCreatorTimeline) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:creatorAvatarButton];
		
		UILabel *creatorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 220.0, 100.0, 20.0)];
		creatorNameLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
		creatorNameLabel.textColor = [HONAppDelegate honGreyTxtColor];
		creatorNameLabel.backgroundColor = [UIColor clearColor];
		creatorNameLabel.text = _challengeVO.creatorName;
		[self addSubview:creatorNameLabel];
				
		UIButton *creatorNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
		creatorNameButton.frame = creatorNameLabel.frame;
		[creatorNameButton addTarget:self action:@selector(_goCreatorTimeline) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:creatorNameButton];
		
		
		_rHolderView = [[UIView alloc] initWithFrame:CGRectMake(160.0, 46.0, 153.0, 153.0)];
		_rHolderView.clipsToBounds = YES;
		[self addSubview:_rHolderView];
		
		UIImageView *rImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -25.0, kMediumW, kMediumH)];
		rImgView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		[rImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", challengeVO.challengerImgPrefix]] placeholderImage:nil];
		rImgView.userInteractionEnabled = YES;
		[_rHolderView addSubview:rImgView];
		
		UIImageView *challengerAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(160.0, 215.0, 35.0, 35.0)];
		challengerAvatarImageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		[challengerAvatarImageView setImageWithURL:[NSURL URLWithString:_challengeVO.challengerAvatar] placeholderImage:nil];
		challengerAvatarImageView.userInteractionEnabled = YES;
		[self addSubview:challengerAvatarImageView];
		
		UIButton *challengerAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		challengerAvatarButton.frame = challengerAvatarImageView.frame;
		[challengerAvatarButton addTarget:self action:@selector(_goChallengerTimeline) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:challengerAvatarButton];
		
		UILabel *challengerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(200.0, 220.0, 100.0, 20.0)];
		challengerNameLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
		challengerNameLabel.textColor = [HONAppDelegate honGreyTxtColor];
		challengerNameLabel.backgroundColor = [UIColor clearColor];
		challengerNameLabel.text = _challengeVO.challengerName;
		[self addSubview:challengerNameLabel];
		
		UIButton *challengerNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
		challengerNameButton.frame = challengerNameLabel.frame;
		[challengerNameButton addTarget:self action:@selector(_goChallengerTimeline) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:challengerNameButton];
		
//		UIImageView *rScoreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 123.0, 153.0, 30.0)];
//		rScoreImageView.image = [UIImage imageNamed:@"challengeWallScore_Overlay"];
//		[_rHolderView addSubview:rScoreImageView];
//		
//		_rScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 7.0, 140.0, 18.0)];
//		_rScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
//		_rScoreLabel.backgroundColor = [UIColor clearColor];
//		_rScoreLabel.textColor = [UIColor whiteColor];
//		_rScoreLabel.textAlignment = NSTextAlignmentRight;
//		_rScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.challengerScore];
//		[rScoreImageView addSubview:_rScoreLabel];
		
		_loserOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 46.0, 153.0, 153.0)];
		_loserOverlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.67];
		_loserOverlayView.hidden = YES;
		[self addSubview:_loserOverlayView];
				
		_votesButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_votesButton.frame = CGRectMake(12.0, 250.0, 34.0, 34.0);
		[_votesButton setBackgroundImage:[UIImage imageNamed:@"heartIcon_nonActive"] forState:UIControlStateNormal];
		[_votesButton setBackgroundImage:[UIImage imageNamed:@"heartIcon_Active"] forState:UIControlStateHighlighted];
		[_votesButton addTarget:self action:@selector(_goScore) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_votesButton];
		
		_votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 245.0, 140.0, 44.0)];
		_votesLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:12];
		_votesLabel.backgroundColor = [UIColor clearColor];
		_votesLabel.textColor = [HONAppDelegate honGreyTxtColor];
		_votesLabel.text = [NSString stringWithFormat:(_challengeVO.creatorScore + _challengeVO.challengerScore == 1) ? @"%d vote" : @"%d votes", (_challengeVO.creatorScore + _challengeVO.challengerScore)];
		[self addSubview:_votesLabel];
		
		UIButton *commentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		commentsButton.frame = CGRectMake(120.0, 250.0, 34.0, 34.0);
		[commentsButton setBackgroundImage:[UIImage imageNamed:@"commentIcon_nonActive"] forState:UIControlStateNormal];
		[commentsButton setBackgroundImage:[UIImage imageNamed:@"commentIcon_Active"] forState:UIControlStateHighlighted];
		[commentsButton addTarget:self action:@selector(_goComments) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:commentsButton];
		
		UILabel *commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(160.0, 245.0, 140.0, 44.0)];
		commentsLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:12];
		commentsLabel.backgroundColor = [UIColor clearColor];
		commentsLabel.textColor = [HONAppDelegate honGreyTxtColor];
		commentsLabel.text = [NSString stringWithFormat:(_challengeVO.commentTotal == 1) ? @"%d comment" : @"%d comments", _challengeVO.commentTotal];
		[self addSubview:commentsLabel];
		
	} else {
		moreButton.frame = CGRectMake(266.0, 400.0, 44.0, 44.0);
		
		_lHolderView = [[UIView alloc] initWithFrame:CGRectMake(7.0, 46.0, 306.0, 306.0)];
		_lHolderView.clipsToBounds = YES;
		[self addSubview:_lHolderView];
		
		UIImageView *lImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW * 0.5, kLargeW * 0.5)]; //x408
		[lImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", challengeVO.creatorImgPrefix]] placeholderImage:nil];
		lImgView.userInteractionEnabled = YES;
		[_lHolderView addSubview:lImgView];
		
//		UIImageView *overlayWaitingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 236.0, 306.0, 70.0)];
//		overlayWaitingImageView.image = [UIImage imageNamed:@"waitingImageOverlay"];
//		overlayWaitingImageView.userInteractionEnabled = YES;
//		[lImgView addSubview:overlayWaitingImageView];
		
		UIImageView *creatorAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 360.0, 35.0, 35.0)];
		creatorAvatarImageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		[creatorAvatarImageView setImageWithURL:[NSURL URLWithString:_challengeVO.creatorAvatar] placeholderImage:nil];
		creatorAvatarImageView.userInteractionEnabled = YES;
		[self addSubview:creatorAvatarImageView];
		
		UIButton *creatorAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		creatorAvatarButton.frame = creatorAvatarImageView.frame;
		[creatorAvatarButton addTarget:self action:@selector(_goCreatorTimeline) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:creatorAvatarButton];
		
		CGSize size = [[NSString stringWithFormat:@"%@ is waiting for a match…", _challengeVO.creatorName] sizeWithFont:[[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12] constrainedToSize:CGSizeMake(250.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
		UIButton *creatorNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
		creatorNameButton.frame = CGRectMake(60.0, 370.0, size.width, 20.0);
		[creatorNameButton addTarget:self action:@selector(_goCreatorTimeline) forControlEvents:UIControlEventTouchUpInside];
		creatorNameButton.titleLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
		[creatorNameButton setTitleColor:[HONAppDelegate honGreyTxtColor] forState:UIControlStateNormal];
		[creatorNameButton setTitle:[NSString stringWithFormat:@"%@ is waiting for a match…", _challengeVO.creatorName] forState:UIControlStateNormal];
		[self addSubview:creatorNameButton];
		
//		size = [[NSString stringWithFormat:@"  Be the first to challenge %@, tap here  ", _challengeVO.creatorName] sizeWithFont:[[HONAppDelegate qualcommBold] fontWithSize:12] constrainedToSize:CGSizeMake(280.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
//		_votesButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		_votesButton.frame = CGRectMake(12.0, 400.0, size.width, 34.0);
//		[_votesButton setBackgroundImage:[[UIImage imageNamed:@"voteButton_nonActive"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
//		[_votesButton setBackgroundImage:[[UIImage imageNamed:@"voteButton_Active"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
//		[_votesButton addTarget:self action:@selector(_goCreateChallenge) forControlEvents:UIControlEventTouchUpInside];
//		_votesButton.titleLabel.font = [[HONAppDelegate qualcommBold] fontWithSize:12];
//		[_votesButton setTitleColor:[HONAppDelegate honGreyTxtColor] forState:UIControlStateNormal];
//		[_votesButton setTitle:[NSString stringWithFormat:@"Be the first to challenge %@, tap here", _challengeVO.creatorName] forState:UIControlStateNormal];
//		[self addSubview:_votesButton];
	}
}


#pragma mark - Touch Interactions
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch *touch = [touches anyObject];
	
	// this will cancel the single tap action
	if (touch.tapCount == 2) {
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch *touch = [touches anyObject];
	
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
	[self _showTapOverlayOnView:_lHolderView];
	
	if (_hasChallenger) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_IN_SESSION_CREATOR_DETAILS" object:_challengeVO];
	
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_NOT_IN_SESSION_DETAILS" object:_challengeVO];
	}
}

- (void)_goSingleTapRight {
	[self _showTapOverlayOnView:_rHolderView];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_IN_SESSION_CHALLENGER_DETAILS" object:_challengeVO];
}

- (void)_goDoubleTapLeft {
	[self _showTapOverlayOnView:_lHolderView];
	
	if (_hasChallenger) {
//		if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != _challengeVO.creatorID)
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_CREATOR_CHALLENGE" object:_challengeVO];
//		
//		else
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_SUBJECT_CHALLENGE" object:_challengeVO];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"UPVOTE_CREATOR" object:_challengeVO];
		
	} else {
		if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != _challengeVO.creatorID) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_CREATOR_CHALLENGE" object:_challengeVO];
			
		} else
			[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_SUBJECT_CHALLENGE" object:_challengeVO];
	}
}

- (void)_goDoubleTapRight {
	[self _showTapOverlayOnView:_rHolderView];
	
//	if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != _challengeVO.challengerID)
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_CHALLENGER_CHALLENGE" object:_challengeVO];
//	
//	else
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_SUBJECT_CHALLENGE" object:_challengeVO];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UPVOTE_CHALLENGER" object:_challengeVO];
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
	[[Mixpanel sharedInstance] track:@"Vote - More"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"user", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																				delegate:self
																	cancelButtonTitle:@"Cancel"
															 destructiveButtonTitle:@"Report Abuse"
																	otherButtonTitles:[NSString stringWithFormat:@"%@ Challenge", _challengeVO.subjectName], @"Share", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	[actionSheet setTag:0];
	[actionSheet showInView:[HONAppDelegate appTabBarController].view];
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
		
		if ([HONAppDelegate hasVoted:_challengeVO.challengeID]) {
			_challengeVO.creatorScore++;
			_lScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.creatorScore];
			
			[self _clearResults];
			_loserOverlayView.frame = CGRectOffset(_loserOverlayView.frame, (_challengeVO.creatorScore > _challengeVO.challengerScore) ? 160.0 : 7.0, 0.0);
			_loserOverlayView.hidden = (_challengeVO.creatorScore == _challengeVO.challengerScore);
			
			_votesLabel.text = [NSString stringWithFormat:(_challengeVO.creatorScore + _challengeVO.challengerScore == 1) ? @"%d vote" : @"%d votes", (_challengeVO.creatorScore + _challengeVO.challengerScore)];
		
		} else {
			[[Mixpanel sharedInstance] track:@"Upvote Creator"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
														 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
			
			_lScoreLabel.text = [NSString stringWithFormat:@"%d", (_challengeVO.creatorScore + 1)];
			
			[self _clearResults];
			_loserOverlayView.frame = CGRectOffset(_loserOverlayView.frame, (_challengeVO.creatorScore > (_challengeVO.challengerScore + 1)) ? 160.0 : 7.0, 0.0);
			_loserOverlayView.hidden = ((_challengeVO.creatorScore + 1) == _challengeVO.challengerScore);
			
			_votesLabel.text = [NSString stringWithFormat:(1 + (_challengeVO.creatorScore + _challengeVO.challengerScore) == 1) ? @"%d vote" : @"%d votes", 1 + (_challengeVO.creatorScore + _challengeVO.challengerScore)];
//			[HONAppDelegate setVote:_challengeVO.challengeID];
//			
//			AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
//			NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//											[NSString stringWithFormat:@"%d", 6], @"action",
//											[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
//											[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
//											@"Y", @"creator",
//											nil];
//			
//			[httpClient postPath:kVotesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//				NSError *error = nil;
//				if (error != nil) {
//					NSLog(@"HONVoteItemViewCell AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
//					
//				} else {
//					NSDictionary *voteResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//					NSLog(@"HONVoteItemViewCell AFNetworking: %@", voteResult);
//				}
//				
//			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//				NSLog(@"VoteItemViewCell AFNetworking %@", [error localizedDescription]);
//			}];
		}
	}
}

- (void)_upvoteChallenger:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	if ([vo isEqual:_challengeVO]) {
		//[self _playVoteSFX];
		
		if ([HONAppDelegate hasVoted:_challengeVO.challengeID]) {
			_challengeVO.challengerScore++;
			
			_rScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.challengerScore];
			
			[self _clearResults];
			_loserOverlayView.frame = CGRectOffset(_loserOverlayView.frame, (_challengeVO.creatorScore > _challengeVO.challengerScore) ? 160.0 : 7.0, 0.0);
			_loserOverlayView.hidden = (_challengeVO.creatorScore == _challengeVO.challengerScore);
			
			_votesLabel.text = [NSString stringWithFormat:(_challengeVO.creatorScore + _challengeVO.challengerScore == 1) ? @"%d VOTE" : @"%d VOTES", (_challengeVO.creatorScore + _challengeVO.challengerScore)];
			
		} else {
			[[Mixpanel sharedInstance] track:@"Upvote Challenger"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
														 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
			
			_rScoreLabel.text = [NSString stringWithFormat:@"%d", (_challengeVO.challengerScore + 1)];
			
			[self _clearResults];
			_loserOverlayView.frame = CGRectOffset(_loserOverlayView.frame, (_challengeVO.creatorScore > (_challengeVO.challengerScore + 1)) ? 160.0 : 7.0, 0.0);
			_loserOverlayView.hidden = (_challengeVO.creatorScore == (_challengeVO.challengerScore + 1));
			
			_votesLabel.text = [NSString stringWithFormat:(1 + (_challengeVO.creatorScore + _challengeVO.challengerScore) == 1) ? @"%d VOTE" : @"%d VOTES", 1 + (_challengeVO.creatorScore + _challengeVO.challengerScore)];
//			[HONAppDelegate setVote:_challengeVO.challengeID];
//			
//			AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
//			NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//											[NSString stringWithFormat:@"%d", 6], @"action",
//											[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
//											[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
//											@"N", @"creator",
//											nil];
//			
//			[httpClient postPath:kVotesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//				NSError *error = nil;
//				if (error != nil) {
//					NSLog(@"HONVoteItemViewCell AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
//					
//				} else {
//					NSDictionary *voteResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//					NSLog(@"HONVoteItemViewCell AFNetworking: %@", voteResult);
//				}
//				
//			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//				NSLog(@"HONVoteItemViewCell AFNetworking %@", [error localizedDescription]);
//			}];
		}
	}
}


#pragma mark - Behaviors
- (void)_clearResults {
	_loserOverlayView.frame = CGRectMake(0.0, 46.0, 153.0, 153.0);
	_loserOverlayView.hidden = YES;
}

- (void)_playVoteSFX {
	_sfxPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"fpo_upvote" withExtension:@"mp3"] error:NULL];
	_sfxPlayer.delegate = self;
	[_sfxPlayer play];
}

- (void)_showTapOverlayOnView:(UIView *)view {
	_tappedOverlayView = [[UIView alloc] initWithFrame:view.frame];
	_tappedOverlayView.backgroundColor = [UIColor colorWithWhite:0.33 alpha:0.33];
	[self addSubview:_tappedOverlayView];
	
	[self performSelector:@selector(_removeTapOverlay) withObject:self afterDelay:0.25];
}

- (void)_removeTapOverlay {
	[_tappedOverlayView removeFromSuperview];
	_tappedOverlayView = nil;
}


#pragma mark - ActionSheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		switch (buttonIndex) {
			case 0: {
				[[Mixpanel sharedInstance] track:@"Vote Wall - Flag"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"user", nil]];
				
				AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
				NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSString stringWithFormat:@"%d", 11], @"action",
												[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
												[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
												nil];
				
				[httpClient postPath:kChallengesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					NSError *error = nil;
					if (error != nil) {
						NSLog(@"HONVoteItemViewCell AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
						
					} else {
						//NSDictionary *flagResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
						//NSLog(@"HONVoteItemViewCell AFNetworking: %@", flagResult);
					}
					
				} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					NSLog(@"VoteItemViewCell AFNetworking %@", [error localizedDescription]);
				}];
				
			break;}
				
			case 1:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_SUBJECT_CHALLENGE" object:_challengeVO];
				break;
				
			case 2:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHARE_CHALLENGE" object:_challengeVO];
				break;
		}
	}
}


@end


