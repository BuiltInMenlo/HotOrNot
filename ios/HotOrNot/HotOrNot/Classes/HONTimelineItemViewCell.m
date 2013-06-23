//
//  HONTimelineItemViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"

#import "HONTimelineItemViewCell.h"
#import "HONAppDelegate.h"
#import "HONImageLoadingView.h"
#import "HONVoterVO.h"
#import "HONUserVO.h"


@interface HONTimelineItemViewCell() <UIActionSheetDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) UIView *lHolderView;
@property (nonatomic, strong) UIView *rHolderView;
@property (nonatomic, strong) UIImageView *lChallengeImageView;
@property (nonatomic, strong) UIImageView *rChallengeImageView;
@property (nonatomic, strong) UILabel *lScoreLabel;
@property (nonatomic, strong) UILabel *rScoreLabel;
@property (nonatomic, strong) UILabel *commentsLabel;
@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, strong) UIImageView *upvoteImageView;
@property (nonatomic, strong) UIView *tappedOverlayView;
@property (nonatomic, strong) NSMutableArray *voters;
@property (nonatomic) BOOL hasOponentRetorted;
@property (nonatomic, strong) HONImageLoadingView *lImageLoading;
@property (nonatomic, strong) HONImageLoadingView *rImageLoading;

@end

@implementation HONTimelineItemViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initAsWaitingCell {
	if ((self = [super init])) {
		_hasOponentRetorted = NO;
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timelineRowBackground"]];
		[self addSubview:bgImgView];
	}
	
	return (self);
}

- (id)initAsStartedCell {
	if ((self = [super init])) {
		_hasOponentRetorted = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_upvoteCreator:) name:@"UPVOTE_CREATOR" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_upvoteChallenger:) name:@"UPVOTE_CHALLENGER" object:nil];
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timelineRowBackground"]];
		[self addSubview:bgImgView];
	}
	
	return (self);
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	__weak typeof(self) weakSelf = self;
	//NSLog(@"setChallengeVO:%@[%@](%d)", challengeVO.subjectName, challengeVO.status, (int)_hasOponentRetorted);
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 18.0, 200.0, 28.0)];
	subjectLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:24];
	subjectLabel.textColor = [HONAppDelegate honBlueTextColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _challengeVO.subjectName;
	[self addSubview:subjectLabel];
	
	UIButton *subjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
	subjectButton.frame = subjectLabel.frame;
	[subjectButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
	[subjectButton addTarget:self action:@selector(_goSubjectTimeline) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:subjectButton];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(246.0, 20.0, 60.0, 16.0)];
	timeLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:13];
	timeLabel.textColor = [HONAppDelegate honOffGreyLightColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = [HONAppDelegate timeSinceDate:_challengeVO.updatedDate];
	[self addSubview:timeLabel];
	
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 55.0, 320.0, kSnapLargeDim)];
	scrollView.contentSize = CGSizeMake(10.0 + ((kSnapLargeDim + 10.0) * (2.0 + (int)_hasOponentRetorted)), kSnapLargeDim);
	scrollView.pagingEnabled = NO;
	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.backgroundColor = [UIColor whiteColor];
	[self addSubview:scrollView];
	
	_lHolderView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, kSnapLargeDim, kSnapLargeDim)];
	_lHolderView.clipsToBounds = YES;
	[scrollView addSubview:_lHolderView];
	
	_lImageLoading = [[HONImageLoadingView alloc] initAtPos:CGPointMake(93.0, 93.0)];
	[_lHolderView addSubview:_lImageLoading];
	
	_lChallengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapLargeDim, kSnapLargeDim)];
	_lChallengeImageView.userInteractionEnabled = YES;
	_lChallengeImageView.alpha = 0.0;
	[_lHolderView addSubview:_lChallengeImageView];
	
	[_lChallengeImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", challengeVO.creatorImgPrefix]]
																  cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
								placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
									weakSelf.lChallengeImageView.image = image;
									[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.lChallengeImageView.alpha = 1.0; } completion:nil];
								} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
	
	
	UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
	leftButton.frame = _lChallengeImageView.frame;
	[leftButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
	[leftButton addTarget:self action:@selector(_goSingleTapLeft) forControlEvents:UIControlEventTouchUpInside];
	[_lHolderView addSubview:leftButton];
	
	UIImageView *creatorAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 162.0, 38.0, 38.0)];
	[creatorAvatarImageView setImageWithURL:[NSURL URLWithString:_challengeVO.creatorAvatar] placeholderImage:nil];
	creatorAvatarImageView.userInteractionEnabled = YES;
	[_lHolderView addSubview:creatorAvatarImageView];
	
	UIButton *creatorAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	creatorAvatarButton.frame = creatorAvatarImageView.frame;
	[creatorAvatarButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
	[creatorAvatarButton addTarget:self action:@selector(_goCreatorTimeline) forControlEvents:UIControlEventTouchUpInside];
	[_lHolderView addSubview:creatorAvatarButton];
	
	UILabel *creatorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(61.0, 170.0, 150.0, 22.0)];
	creatorNameLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17];
	creatorNameLabel.textColor = [UIColor whiteColor];
	creatorNameLabel.backgroundColor = [UIColor clearColor];
	creatorNameLabel.text = [NSString stringWithFormat:@"@%@", _challengeVO.creatorName];
	[_lHolderView addSubview:creatorNameLabel];
	
	UIButton *creatorNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	creatorNameButton.frame = creatorNameLabel.frame;
	[creatorNameButton addTarget:self action:@selector(_goCreatorTimeline) forControlEvents:UIControlEventTouchUpInside];
	[_lHolderView addSubview:creatorNameButton];
	
	_rHolderView = [[UIView alloc] initWithFrame:CGRectMake(20.0 + kSnapLargeDim, 0.0, kSnapLargeDim, kSnapLargeDim)];//[[UIView alloc] initWithFrame:CGRectMake(225.0, 0.0, 210.0, 210.0)];
	_rHolderView.clipsToBounds = YES;
	[scrollView addSubview:_rHolderView];
	
	_rImageLoading = [[HONImageLoadingView alloc] initAtPos:CGPointMake(93.0, 93.0)];
	[_rHolderView addSubview:_rImageLoading];
	
	if (_hasOponentRetorted) {
		_rChallengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapLargeDim, kSnapLargeDim)];
		_rChallengeImageView.alpha = 0.0;
		_rChallengeImageView.userInteractionEnabled = YES;
		[_rHolderView addSubview:_rChallengeImageView];
		
		[_rChallengeImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", challengeVO.challengerImgPrefix]]
																	  cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
									placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
										weakSelf.rChallengeImageView.image = image;
										[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.rChallengeImageView.alpha = 1.0; } completion:nil];
									} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
		
		
		
		
//		UIImageView *lScoreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 0.0, 24.0, 24.0)];
//		lScoreImageView.image = [UIImage imageNamed:@"smallHeart"];
//		[_lHolderView addSubview:lScoreImageView];
//		
//		UIImageView *rScoreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 0.0, 24.0, 24.0)];
//		rScoreImageView.image = [UIImage imageNamed:@"smallHeart"];
//		[_rHolderView addSubview:rScoreImageView];
		
		UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
		rightButton.frame = _lChallengeImageView.frame;
		[rightButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
		[rightButton addTarget:self action:@selector(_goSingleTapRight) forControlEvents:UIControlEventTouchUpInside];
		[_rHolderView addSubview:rightButton];
		
		UIImageView *challengerAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 162.0, 38.0, 38.0)];
		[challengerAvatarImageView setImageWithURL:[NSURL URLWithString:_challengeVO.challengerAvatar] placeholderImage:nil];
		challengerAvatarImageView.userInteractionEnabled = YES;
		challengerAvatarImageView.clipsToBounds = YES;
		[_rHolderView addSubview:challengerAvatarImageView];
		
		UIButton *challengerAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		challengerAvatarButton.frame = challengerAvatarImageView.frame;
		[challengerAvatarButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
		[challengerAvatarButton addTarget:self action:@selector(_goChallengerTimeline) forControlEvents:UIControlEventTouchUpInside];
		[_rHolderView addSubview:challengerAvatarButton];
		
		UILabel *challengerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(61.0, 170.0, 150.0, 22.0)];
		challengerNameLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17];
		challengerNameLabel.textColor = [UIColor whiteColor];
		challengerNameLabel.backgroundColor = [UIColor clearColor];
		challengerNameLabel.text = [NSString stringWithFormat:@"@%@", _challengeVO.challengerName];
		[_rHolderView addSubview:challengerNameLabel];
		
		UIButton *challengerNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
		challengerNameButton.frame = challengerNameLabel.frame;
		[challengerNameButton addTarget:self action:@selector(_goChallengerTimeline) forControlEvents:UIControlEventTouchUpInside];
		[_rHolderView addSubview:challengerNameButton];
		
		UIButton *likesButton = [UIButton buttonWithType:UIButtonTypeCustom];
		likesButton.frame = CGRectMake(79.0, 280.0, 24.0, 24.0);
		[likesButton setBackgroundImage:[UIImage imageNamed:@"heartIcon"] forState:UIControlStateNormal];
		[likesButton setBackgroundImage:[UIImage imageNamed:@"heartIcon"] forState:UIControlStateHighlighted];
		[likesButton addTarget:self action:@selector(_goScore) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:likesButton];
				
		_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(108.0, 281.0, 40.0, 22.0)];
		_likesLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17];
		_likesLabel.textColor = [HONAppDelegate honBlueTextColor];
		_likesLabel.backgroundColor = [UIColor clearColor];
		_likesLabel.text = (_challengeVO.creatorScore + _challengeVO.challengerScore > 99) ? @"99+" : [NSString stringWithFormat:@"%d", (_challengeVO.creatorScore + _challengeVO.challengerScore)];
		[self addSubview:_likesLabel];
		
		UIButton *likesLabelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		likesLabelButton.frame = _likesLabel.frame;
		[likesLabelButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
		[likesLabelButton addTarget:self action:@selector(_goScore) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:likesLabelButton];
		
		UIView *joinHolderView = [[UIView alloc] initWithFrame:CGRectMake(442.0, 0.0, 210.0, 210.0)];
		joinHolderView.backgroundColor = [UIColor colorWithWhite:0.894 alpha:1.0];
		[scrollView addSubview:joinHolderView];
		
		UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
		joinButton.frame = CGRectMake(48.0, 73.0, 114.0, 64.0);
		[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_nonActive"] forState:UIControlStateNormal];
		[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_Active"] forState:UIControlStateHighlighted];
		[joinButton addTarget:self action:@selector(_goNewSubjectChallenge) forControlEvents:UIControlEventTouchUpInside];
		[joinHolderView addSubview:joinButton];
		
	} else {
		UIImageView *rImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapLargeDim, kSnapLargeDim)];
		rImgView.image = [UIImage imageNamed:([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _challengeVO.creatorID) ? @"pokeThumb" : @"thumbCameraAction"];
		rImgView.userInteractionEnabled = YES;
		[_rHolderView addSubview:rImgView];
		
		if (_challengeVO.challengerID != 0) {
			UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
			rightButton.frame = _lChallengeImageView.frame;
			[rightButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
			[rightButton addTarget:self action:@selector(_goSingleTapRight) forControlEvents:UIControlEventTouchUpInside];
			[_rHolderView addSubview:rightButton];
			
			UIImageView *challengerAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 162.0, 38.0, 38.0)];
			[challengerAvatarImageView setImageWithURL:[NSURL URLWithString:_challengeVO.challengerAvatar] placeholderImage:nil];
			challengerAvatarImageView.userInteractionEnabled = YES;
			challengerAvatarImageView.clipsToBounds = YES;
			[_rHolderView addSubview:challengerAvatarImageView];
			
			UIButton *challengerAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
			challengerAvatarButton.frame = challengerAvatarImageView.frame;
			[challengerAvatarButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
			[challengerAvatarButton addTarget:self action:@selector(_goChallengerTimeline) forControlEvents:UIControlEventTouchUpInside];
			[_rHolderView addSubview:challengerAvatarButton];
			
			UILabel *challengerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(61.0, 170.0, 150.0, 22.0)];
			challengerNameLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17];
			challengerNameLabel.textColor = [UIColor whiteColor];
			challengerNameLabel.backgroundColor = [UIColor clearColor];
			challengerNameLabel.text = [NSString stringWithFormat:@"@%@", _challengeVO.challengerName];
			[_rHolderView addSubview:challengerNameLabel];
			
			UIButton *challengerNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
			challengerNameButton.frame = challengerNameLabel.frame;
			[challengerNameButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
			[challengerNameButton addTarget:self action:@selector(_goChallengerTimeline) forControlEvents:UIControlEventTouchUpInside];
			[_rHolderView addSubview:challengerNameButton];
		}
		
		if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != _challengeVO.creatorID) {
			UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
			joinButton.frame = CGRectMake(48.0, 73.0, 114.0, 64.0);
			[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_nonActive"] forState:UIControlStateNormal];
			[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_Active"] forState:UIControlStateHighlighted];
			[joinButton addTarget:self action:@selector(_goCreateChallenge) forControlEvents:UIControlEventTouchUpInside];
			[_rHolderView addSubview:joinButton];
		}
	}
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	_lScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 9.0, 84.0, 24.0)];
	_lScoreLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:20];
	_lScoreLabel.backgroundColor = [UIColor clearColor];
	_lScoreLabel.textColor = [UIColor whiteColor];
	_lScoreLabel.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:_challengeVO.creatorScore]];//[NSString stringWithFormat:@"%d", _challengeVO.creatorScore];
	_lScoreLabel.hidden = YES;//!_hasOponentRetorted;
	[_lHolderView addSubview:_lScoreLabel];
	
	_rScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 9.0, 84.0, 24.0)];
	_rScoreLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:20];
	_rScoreLabel.backgroundColor = [UIColor clearColor];
	_rScoreLabel.textColor = [UIColor whiteColor];
	_rScoreLabel.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:_challengeVO.challengerScore]];//[NSString stringWithFormat:@"%d", _challengeVO.challengerScore];
	_rScoreLabel.hidden = YES;//!_hasOponentRetorted;
	[_rHolderView addSubview:_rScoreLabel];
	
	UIButton *commentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	commentsButton.frame = CGRectMake(16.0, 280.0, 24.0, 24.0);
	[commentsButton setBackgroundImage:[UIImage imageNamed:@"commentBubble"] forState:UIControlStateNormal];
	[commentsButton setBackgroundImage:[UIImage imageNamed:@"commentBubble"] forState:UIControlStateHighlighted];
	[commentsButton addTarget:self action:@selector(_goComments) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:commentsButton];
	
	_commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 281.0, 40.0, 22.0)];
	_commentsLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17];
	_commentsLabel.textColor = [HONAppDelegate honBlueTextColor];
	_commentsLabel.backgroundColor = [UIColor clearColor];
	_commentsLabel.text = (_challengeVO.commentTotal >= 99) ? @"99+" : [NSString stringWithFormat:@"%d", _challengeVO.commentTotal];
	[self addSubview:_commentsLabel];
	
	UIButton *commentsLabelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	commentsLabelButton.frame = _commentsLabel.frame;
	[commentsLabelButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
	[commentsLabelButton addTarget:self action:@selector(_goComments) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:commentsLabelButton];
	
		UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
	moreButton.frame = CGRectMake(264.0, 270.0, 44.0, 44.0);
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive"] forState:UIControlStateNormal];
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_Active"] forState:UIControlStateHighlighted];
	[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:moreButton];
}


#pragma mark - Navigation
- (void)_goSingleTapLeft {
	[[Mixpanel sharedInstance] track:@"Timeline - Single Tap Creator"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	if ([HONAppDelegate hasVoted:_challengeVO.challengeID] == 0) {
		
		if (_hasOponentRetorted)
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
		
		if (_hasOponentRetorted)
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
	[[Mixpanel sharedInstance] track:@"Timeline - Double Tap Creator"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	if (_hasOponentRetorted) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_IN_SESSION_CREATOR_DETAILS" object:_challengeVO];
		
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_NOT_IN_SESSION_DETAILS" object:_challengeVO];
	}
}

- (void)_goDoubleTapRight {
	[[Mixpanel sharedInstance] track:@"Timeline - Double Tap Challenger"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	if (_hasOponentRetorted)
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

- (void)_goNewSubjectChallenge {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_SUBJECT_CHALLENGE" object:_challengeVO];
}

- (void)_goCreateChallenge {
	if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != _challengeVO.creatorID) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_CREATOR_CHALLENGE" object:_challengeVO];
		
	} else
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_SUBJECT_CHALLENGE" object:_challengeVO];
}

- (void)_goComments {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_COMMENTS" object:_challengeVO];
}

- (void)_goScore {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_VOTERS" object:_challengeVO];
}

- (void)_goMore {
	[[Mixpanel sharedInstance] track:@"Timeline - More Shelf"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];

	if (_hasOponentRetorted) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																					delegate:self
																		cancelButtonTitle:@"Cancel"
																 destructiveButtonTitle:@"Report Abuse"
																		otherButtonTitles:@"View Likes", @"Join Volley", nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
		[actionSheet setTag:0];
		[actionSheet showInView:[HONAppDelegate appTabBarController].view];
	
	} else {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																					delegate:self
																		cancelButtonTitle:@"Cancel"
																 destructiveButtonTitle:@"Report Abuse"
																		otherButtonTitles:@"Join Volley", nil];
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
		
		_upvoteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(41.0, 41.0, 128.0, 128.0)];
		_upvoteImageView.image = [UIImage imageNamed:@"alertBackground"];
		[_lHolderView addSubview:_upvoteImageView];
		
		UIImageView *heartImageView = [[UIImageView alloc] initWithFrame:CGRectMake(17.0, 17.0, 94.0, 94.0)];
		heartImageView.image = [UIImage imageNamed:@"largeHeart"];
		[_upvoteImageView addSubview:heartImageView];
		
		[UIView animateWithDuration:0.33 delay:0.125 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_upvoteImageView.alpha = 0.0;
		} completion:^(BOOL finished) {
			[_upvoteImageView removeFromSuperview];
			_upvoteImageView = nil;
		}];
		
		_challengeVO.creatorScore++;
		
		if ([HONAppDelegate hasVoted:_challengeVO.challengeID] == 0) {
			[[Mixpanel sharedInstance] track:@"Timeline - Upvote Creator"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
														 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
			
			_lScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.creatorScore];
			[HONAppDelegate setVote:_challengeVO.challengeID forCreator:YES];
			
			VolleyJSONLog(@"AFNetworking [-] HONTimelineItemViewCell --> (%@/%@)", [HONAppDelegate apiServerPath], kAPIVotes);
			AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
			NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
											[NSString stringWithFormat:@"%d", 6], @"action",
											[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
											[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
											@"Y", @"creator",
											nil];
			
			[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
				NSError *error = nil;
				if (error != nil) {
					VolleyJSONLog(@"AFNetworking [-]  HONTimelineItemViewCell - Failed to parse job list JSON: %@", [error localizedFailureReason]);
					
				} else {
					NSDictionary *voteResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
					VolleyJSONLog(@"AFNetworking [-]  HONTimelineItemViewCell: %@", voteResult);
				}
				
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				VolleyJSONLog(@"AFNetworking [-]  VoteItemViewCell %@", [error localizedDescription]);
			}];
		
		} else
			_lScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.creatorScore];
	}
}

- (void)_upvoteChallenger:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	if ([vo isEqual:_challengeVO]) {
		//[self _playVoteSFX];
		
		_upvoteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(41.0, 41.0, 128.0, 128.0)];
		_upvoteImageView.image = [UIImage imageNamed:@"alertBackground"];
		[_rHolderView addSubview:_upvoteImageView];
		
		UIImageView *heartImageView = [[UIImageView alloc] initWithFrame:CGRectMake(17.0, 17.0, 94.0, 94.0)];
		heartImageView.image = [UIImage imageNamed:@"largeHeart"];
		[_upvoteImageView addSubview:heartImageView];
		
		[UIView animateWithDuration:0.33 delay:0.125 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_upvoteImageView.alpha = 0.0;
		} completion:^(BOOL finished) {
			[_upvoteImageView removeFromSuperview];
			_upvoteImageView = nil;
		}];
		
		_challengeVO.challengerScore++;
		
		if ([HONAppDelegate hasVoted:_challengeVO.challengeID] == 0) {
			[[Mixpanel sharedInstance] track:@"Timeline - Upvote Challenger"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
														 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
			
			_rScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.challengerScore];
			[HONAppDelegate setVote:_challengeVO.challengeID forCreator:NO];
			
			VolleyJSONLog(@"AFNetworking [-] HONTimelineItemViewCell --> (%@/%@)", [HONAppDelegate apiServerPath], kAPIVotes);
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
					VolleyJSONLog(@"AFNetworking [-]  HONTimelineItemViewCell - Failed to parse job list JSON: %@", [error localizedFailureReason]);
					
				} else {
					NSDictionary *voteResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
					VolleyJSONLog(@"AFNetworking [-]  HONTimelineItemViewCell: %@", voteResult);
				}
				
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				VolleyJSONLog(@"AFNetworking [-]  HONTimelineItemViewCell %@", [error localizedDescription]);
			}];
			
		} else
			_rScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.challengerScore];
	}
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
				
				VolleyJSONLog(@"AFNetworking [-] HONTimelineItemViewCell --> (%@/%@)", [HONAppDelegate apiServerPath], kAPIChallenges);
				AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
				NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSString stringWithFormat:@"%d", 11], @"action",
												[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
												[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
												nil];
				
				[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					NSError *error = nil;
					if (error != nil) {
						VolleyJSONLog(@"AFNetworking [-]  HONTimelineItemViewCell - Failed to parse job list JSON: %@", [error localizedFailureReason]);
						
					} else {
						//NSDictionary *flagResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
						//VolleyJSONLog(@"AFNetworking [-]  HONTimelineItemViewCell: %@", flagResult);
						[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_VOTE_TAB" object:nil];
						
					}
					
				} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					VolleyJSONLog(@"AFNetworking [-]  VoteItemViewCell %@", [error localizedDescription]);
				}];
				
			break;}
				
			case 1:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_VOTERS" object:_challengeVO];
				break;
				
			case 2:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_SUBJECT_CHALLENGE" object:_challengeVO];
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
				
				VolleyJSONLog(@"AFNetworking [-] HONTimelineItemViewCell --> (%@/%@)", [HONAppDelegate apiServerPath], kAPIChallenges);
				AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
				NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSString stringWithFormat:@"%d", 11], @"action",
												[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
												[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
												nil];
				
				[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					NSError *error = nil;
					if (error != nil) {
						VolleyJSONLog(@"AFNetworking [-]  HONTimelineItemViewCell - Failed to parse job list JSON: %@", [error localizedFailureReason]);
						
					} else {
						//NSDictionary *flagResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
						//VolleyJSONLog(@"AFNetworking [-]  HONTimelineItemViewCell: %@", flagResult);
						[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_VOTE_TAB" object:nil];
					}
					
				} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					VolleyJSONLog(@"AFNetworking [-]  VoteItemViewCell %@", [error localizedDescription]);
				}];
				
				break;}
				
			case 1:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_SUBJECT_CHALLENGE" object:_challengeVO];
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





//#pragma mark - Touch Interactions
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//	UITouch *touch = [touches anyObject];
//	
//	if (touch.tapCount == 1) {
//		if (CGRectContainsPoint(_lHolderView.frame, [touch locationInView:self])) {
//			_tapOverlayImageView.frame = _lHolderView.frame;
//			
//		} else if (CGRectContainsPoint(_rHolderView.frame, [touch locationInView:self])) {
//			_tapOverlayImageView.frame = _rHolderView.frame;
//		}
//		
//		[self addSubview:_tapOverlayImageView];
//		
//	} else if (touch.tapCount == 2) {
//		[NSObject cancelPreviousPerformRequestsWithTarget:self];
//	}
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//	//UITouch *touch = [touches anyObject];
//	[_tapOverlayImageView removeFromSuperview];
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//	//UITouch *touch = [touches anyObject];
//	[_tapOverlayImageView removeFromSuperview];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//	UITouch *touch = [touches anyObject];
//	[_tapOverlayImageView removeFromSuperview];
//	
//	// this is the single tap action
//	if (touch.tapCount == 1) {
//		if (CGRectContainsPoint(_lHolderView.frame, [touch locationInView:self])) {
//			[self performSelector:@selector(_goSingleTapLeft) withObject:nil afterDelay:0.2];
//			
//		} else if (CGRectContainsPoint(_rHolderView.frame, [touch locationInView:self])) {
//			[self performSelector:@selector(_goSingleTapRight) withObject:nil afterDelay:0.2];
//			
//		} else {
//		}
//		
//		// this is the double tap action
//	} else if (touch.tapCount == 2) {
//		if (CGRectContainsPoint(_lHolderView.frame, [touch locationInView:self])) {
//			[self _goDoubleTapLeft];
//			
//		} else if (CGRectContainsPoint(_rHolderView.frame, [touch locationInView:self])) {
//			[self _goDoubleTapRight];
//			
//		} else {
//		}
//	}
//}
