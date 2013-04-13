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
#import "Mixpanel.h"
#import "UIImageView+AFNetworking.h"

#import "HONTimelineItemViewCell.h"
#import "HONAppDelegate.h"
#import "HONVoterVO.h"


@interface HONTimelineItemViewCell() <AVAudioPlayerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) UIView *lHolderView;
@property (nonatomic, strong) UIView *rHolderView;
@property (nonatomic, strong) UILabel *lScoreLabel;
@property (nonatomic, strong) UILabel *rScoreLabel;
@property (nonatomic, strong) UIImageView *heartImageView;
@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, strong) UILabel *commentsLabel;
@property (nonatomic, strong) UIView *tappedOverlayView;
@property (nonatomic, strong) UIView *loserOverlayView;
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
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 410.0)];
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
		
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 307.0)];
		bgImgView.image = [UIImage imageNamed:@"acceptedRowBackground"];
		[self addSubview:bgImgView];
	}
	
	return (self);
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	_tapOverlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blackOverlay_50"]];
	_tapOverlayImageView.layer.cornerRadius = 2.0;
	_tapOverlayImageView.clipsToBounds = YES;
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 17.0, 200.0, 18.0)];
	subjectLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:15];
	subjectLabel.textColor = [HONAppDelegate honBlueTxtColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _challengeVO.subjectName;
	[self addSubview:subjectLabel];
	
	UIButton *subjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
	subjectButton.frame = subjectLabel.frame;
	[subjectButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
	[subjectButton addTarget:self action:@selector(_goSubjectTimeline) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:subjectButton];
	
	if ([_challengeVO.rechallengedUsers length] > 0) {
//		UIImageView *rechallengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(203.0, 11.0, 24.0, 24.0)];
//		rechallengeImageView.image = [UIImage imageNamed:@"reSnappedIcon"];
//		[self addSubview:rechallengeImageView];
//		
//		NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@","];
//		NSRange range = [_challengeVO.rechallengedUsers rangeOfCharacterFromSet:charSet];
//		
//		UILabel *rechallengeLabel = [[UILabel alloc] initWithFrame:CGRectMake(225.0, 16.0, 120.0, 14.0)];
//		rechallengeLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:9];
//		rechallengeLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
//		rechallengeLabel.backgroundColor = [UIColor clearColor];
//		rechallengeLabel.text = [NSString stringWithFormat:@"Resnapped by %@", [_challengeVO.rechallengedUsers substringToIndex:range.location]];
//		[self addSubview:rechallengeLabel];
		
		UIImageView *rechallengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(203.0, 11.0, 24.0, 24.0)];
		rechallengeImageView.image = [UIImage imageNamed:@"reSnappedIcon"];
		[self addSubview:rechallengeImageView];
		
		UILabel *rechallengeLabel = [[UILabel alloc] initWithFrame:CGRectMake(215.0, 16.0, 60.0, 14.0)];
		rechallengeLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:9];
		rechallengeLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
		rechallengeLabel.backgroundColor = [UIColor clearColor];
		rechallengeLabel.textAlignment = NSTextAlignmentRight;
		rechallengeLabel.text = @"Resnapped";
		[self addSubview:rechallengeLabel];
	}
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(240.0, 15.0, 60.0, 16.0)];
	timeLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:11];
	timeLabel.textColor = [HONAppDelegate honGreyTxtColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = [HONAppDelegate timeSinceDate:_challengeVO.startedDate];
	[self addSubview:timeLabel];
	
	UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
	moreButton.frame = CGRectMake(270.0, 253.0, 34.0, 34.0);
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive"] forState:UIControlStateNormal];
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_Active"] forState:UIControlStateHighlighted];
	[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:moreButton];
	
	if (_hasChallenger) {
		CALayer *lHolderMask = [CALayer layer];
		lHolderMask.contents = (id)[[UIImage imageNamed:@"imageLargeThumbMask"] CGImage];
		lHolderMask.frame = CGRectMake(0.0, 0.0, 151.0, 153.0);
		
		_lHolderView = [[UIView alloc] initWithFrame:CGRectMake(7.0, 46.0, 151.0, 153.0)];
		_lHolderView.layer.mask = lHolderMask;
		_lHolderView.layer.masksToBounds = YES;
		[self addSubview:_lHolderView];
		
		UIImageView *lImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -25.0, kMediumW, kMediumH)];
		lImgView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		[lImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", challengeVO.creatorImgPrefix]] placeholderImage:nil];
		lImgView.userInteractionEnabled = YES;
		[_lHolderView addSubview:lImgView];
		
		UIImageView *lScoreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 123.0, 153.0, 30.0)];
		lScoreImageView.image = [UIImage imageNamed:@"challengeWallScore_Overlay"];
		lScoreImageView.hidden = ([HONAppDelegate hasVoted:_challengeVO.challengeID] == 0);
		[_lHolderView addSubview:lScoreImageView];
		
		_lScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 7.0, 144.0, 18.0)];
		_lScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
		_lScoreLabel.backgroundColor = [UIColor clearColor];
		_lScoreLabel.textColor = [UIColor whiteColor];
		_lScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.creatorScore];
		[lScoreImageView addSubview:_lScoreLabel];
		
		CALayer *creatorAvatarMask = [CALayer layer];
		creatorAvatarMask.contents = (id)[[UIImage imageNamed:@"smallAvatarMask"] CGImage];
		creatorAvatarMask.frame = CGRectMake(0.0, 0.0, 38.0, 38.0);
		
		UIImageView *creatorAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 209.0, 38.0, 38.0)];
		creatorAvatarImageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		[creatorAvatarImageView setImageWithURL:[NSURL URLWithString:_challengeVO.creatorAvatar] placeholderImage:nil];
		creatorAvatarImageView.userInteractionEnabled = YES;
		creatorAvatarImageView.layer.mask = creatorAvatarMask;
		creatorAvatarImageView.layer.masksToBounds = YES;
		[self addSubview:creatorAvatarImageView];
		
				
		UIButton *creatorAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		creatorAvatarButton.frame = creatorAvatarImageView.frame;
		[creatorAvatarButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
		[creatorAvatarButton addTarget:self action:@selector(_goCreatorTimeline) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:creatorAvatarButton];
		
		UILabel *creatorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 218.0, 100.0, 20.0)];
		creatorNameLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:12];
		creatorNameLabel.textColor = [HONAppDelegate honGreyTxtColor];
		creatorNameLabel.backgroundColor = [UIColor clearColor];
		creatorNameLabel.text = [NSString stringWithFormat:@"@%@", _challengeVO.creatorName];
		[self addSubview:creatorNameLabel];
				
		UIButton *creatorNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
		creatorNameButton.frame = creatorNameLabel.frame;
		[creatorNameButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
		[creatorNameButton addTarget:self action:@selector(_goCreatorTimeline) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:creatorNameButton];
		
		
		CALayer *rHolderMask = [CALayer layer];
		rHolderMask.contents = (id)[[UIImage imageNamed:@"imageLargeThumbMask"] CGImage];
		rHolderMask.frame = CGRectMake(0.0, 0.0, 151.0, 153.0);
		
		_rHolderView = [[UIView alloc] initWithFrame:CGRectMake(162.0, 46.0, 151.0, 153.0)];
		_rHolderView.layer.mask = rHolderMask;
		_rHolderView.layer.masksToBounds = YES;
		[self addSubview:_rHolderView];
		
		UIImageView *rImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -25.0, kMediumW, kMediumH)];
		rImgView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		[rImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", challengeVO.challengerImgPrefix]] placeholderImage:nil];
		rImgView.userInteractionEnabled = YES;
		[_rHolderView addSubview:rImgView];
		
		CALayer *challengerAvatarMask = [CALayer layer];
		challengerAvatarMask.contents = (id)[[UIImage imageNamed:@"smallAvatarMask"] CGImage];
		challengerAvatarMask.frame = CGRectMake(0.0, 0.0, 38.0, 38.0);
		
		UIImageView *challengerAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(162.0, 209.0, 38.0, 38.0)];
		challengerAvatarImageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		[challengerAvatarImageView setImageWithURL:[NSURL URLWithString:_challengeVO.challengerAvatar] placeholderImage:nil];
		challengerAvatarImageView.userInteractionEnabled = YES;
		challengerAvatarImageView.layer.mask = challengerAvatarMask;
		challengerAvatarImageView.layer.masksToBounds = YES;
		[self addSubview:challengerAvatarImageView];
		
		UIButton *challengerAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		challengerAvatarButton.frame = challengerAvatarImageView.frame;
		[challengerAvatarButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
		[challengerAvatarButton addTarget:self action:@selector(_goChallengerTimeline) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:challengerAvatarButton];
		
		UILabel *challengerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(209.0, 218.0, 100.0, 20.0)];
		challengerNameLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:12];
		challengerNameLabel.textColor = [HONAppDelegate honGreyTxtColor];
		challengerNameLabel.backgroundColor = [UIColor clearColor];
		challengerNameLabel.text = [NSString stringWithFormat:@"@%@", _challengeVO.challengerName];
		[self addSubview:challengerNameLabel];
		
		UIButton *challengerNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
		challengerNameButton.frame = challengerNameLabel.frame;
		[challengerNameButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
		[challengerNameButton addTarget:self action:@selector(_goChallengerTimeline) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:challengerNameButton];
		
		UIImageView *rScoreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 123.0, 153.0, 30.0)];
		rScoreImageView.image = [UIImage imageNamed:@"challengeWallScore_Overlay"];
		rScoreImageView.hidden = ([HONAppDelegate hasVoted:_challengeVO.challengeID] == 0);
		[_rHolderView addSubview:rScoreImageView];
		
		_rScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 7.0, 140.0, 18.0)];
		_rScoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
		_rScoreLabel.backgroundColor = [UIColor clearColor];
		_rScoreLabel.textColor = [UIColor whiteColor];
		_rScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.challengerScore];
		[rScoreImageView addSubview:_rScoreLabel];
		
		_loserOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 46.0, 153.0, 153.0)];
		_loserOverlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.67];
		_loserOverlayView.hidden = YES;
		//[self addSubview:_loserOverlayView];
		
		
		UIImageView *likeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(13.0, 256.0, 24.0, 24.0)];
		likeImageView.image = [UIImage imageNamed:@"heartIcon_nonActive"];
		[self addSubview:likeImageView];
		
		_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 256.0, 150.0, 24.0)];
		_likesLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
		_likesLabel.textColor = [HONAppDelegate honGreyTxtColor];
		_likesLabel.backgroundColor = [UIColor clearColor];
		_likesLabel.text = [NSString stringWithFormat:(_challengeVO.creatorScore + _challengeVO.challengerScore == 1) ? @"%d Like" : @"%d Likes", (_challengeVO.creatorScore + _challengeVO.challengerScore)];
		[self addSubview:_likesLabel];
		
		UIButton *likesButton = [UIButton buttonWithType:UIButtonTypeCustom];
		likesButton.frame = CGRectMake(13.0, 256.0, 190.0, 24.0);
		[likesButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
		[likesButton addTarget:self action:@selector(_goScore) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:likesButton];
		
		UIImageView *commentsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(13.0, 277.0, 24.0, 24.0)];
		commentsImageView.image = [UIImage imageNamed:@"commentIcon_nonActive"];
		[self addSubview:commentsImageView];
		
		_commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 277.0, 150.0, 24.0)];
		_commentsLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
		_commentsLabel.textColor = [HONAppDelegate honGreyTxtColor];
		_commentsLabel.backgroundColor = [UIColor clearColor];
		_commentsLabel.text = (_challengeVO.commentTotal > 99) ? @"99+ Comments" : [NSString stringWithFormat:(_challengeVO.commentTotal == 1) ? @"%d Comment" : @"%d Comments", _challengeVO.commentTotal];;
		[self addSubview:_commentsLabel];
		
		UIButton *commentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		commentsButton.frame = CGRectMake(13.0, 277.0, 190.0, 24.0);
		[commentsButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
		[commentsButton addTarget:self action:@selector(_goComments) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:commentsButton];
		
//		NSString *caption = (_challengeVO.creatorScore + _challengeVO.challengerScore == 0) ? @"" : [NSString stringWithFormat:(_challengeVO.creatorScore + _challengeVO.challengerScore == 1) ? @"%d Like" : @"%d Likes", (_challengeVO.creatorScore + _challengeVO.challengerScore)];
//		_votesButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		_votesButton.frame = CGRectMake(6.0, 253.0, width, 34.0);
//		[_votesButton setBackgroundImage:[[UIImage imageNamed:(_challengeVO.creatorScore + _challengeVO.challengerScore == 0) ? @"timelineNoLike_nonActive" : @"timelineLike_nonActive"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:0.0] forState:UIControlStateNormal];
//		[_votesButton setBackgroundImage:[[UIImage imageNamed:(_challengeVO.creatorScore + _challengeVO.challengerScore == 0) ? @"timelineNoLike_Active" : @"timelineLike_Active"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
//		_votesButton.titleLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
//		[_votesButton setTitleColor:[UIColor colorWithWhite:0.455 alpha:1.0] forState:UIControlStateNormal];
//		_votesButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, -5.0);
//		[_votesButton setTitle:caption forState:UIControlStateNormal];
//		[_votesButton addTarget:self action:@selector(_goScore) forControlEvents:UIControlEventTouchUpInside];
//		[self addSubview:_votesButton];
//		
//		UIButton *commentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		commentsButton.frame = CGRectMake(_votesButton.frame.origin.x + _votesButton.frame.size.width + 2.0, 253.0, (_challengeVO.commentTotal == 0) ? 94.0 : 124, 34.0);
//		[commentsButton setBackgroundImage:[UIImage imageNamed:(_challengeVO.commentTotal == 0) ? @"timelineNoComments_nonActive" : @"timelineComments_nonActive"] forState:UIControlStateNormal];
//		[commentsButton setBackgroundImage:[UIImage imageNamed:(_challengeVO.commentTotal == 0) ? @"timelineNoComments_Active" : @"timelineComments_Active"] forState:UIControlStateHighlighted];
//		commentsButton.titleLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
//		[commentsButton setTitleColor:[UIColor colorWithWhite:0.455 alpha:1.0] forState:UIControlStateNormal];
//		commentsButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, -5.0);
//		[commentsButton addTarget:self action:@selector(_goComments) forControlEvents:UIControlEventTouchUpInside];
//		caption = (_challengeVO.commentTotal == 0) ? @"" : (_challengeVO.commentTotal > 99) ? @"99+ Comments" : [NSString stringWithFormat:(_challengeVO.commentTotal == 1) ? @"%d Comment" : @"%d Comments", _challengeVO.commentTotal];
//		[commentsButton setTitle:caption forState:UIControlStateNormal];
//		[self addSubview:commentsButton];
		
	} else {
		CALayer *lHolderMask = [CALayer layer];
		lHolderMask.contents = (id)[[UIImage imageNamed:@"imageLargeMask"] CGImage];
		lHolderMask.frame = CGRectMake(0.0, 0.0, 306.0, 306.0);
		
		_lHolderView = [[UIView alloc] initWithFrame:CGRectMake(7.0, 48.0, 306.0, 306.0)];
		_lHolderView.layer.mask = lHolderMask;
		_lHolderView.layer.masksToBounds = YES;
		[self addSubview:_lHolderView];
		
		UIImageView *lImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW * 0.5, kLargeW * 0.5)]; //x408
		[lImgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", challengeVO.creatorImgPrefix]] placeholderImage:nil];
		lImgView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		lImgView.userInteractionEnabled = YES;
		[_lHolderView addSubview:lImgView];
		
		CALayer *creatorAvatarMask = [CALayer layer];
		creatorAvatarMask.contents = (id)[[UIImage imageNamed:@"smallAvatarMask.png"] CGImage];
		creatorAvatarMask.frame = CGRectMake(0.0, 0.0, 38.0, 38.0);
		
		UIImageView *creatorAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 362.0, 38.0, 38.0)];
		creatorAvatarImageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		[creatorAvatarImageView setImageWithURL:[NSURL URLWithString:_challengeVO.creatorAvatar] placeholderImage:nil];
		creatorAvatarImageView.userInteractionEnabled = YES;
		creatorAvatarImageView.layer.mask = creatorAvatarMask;
		creatorAvatarImageView.layer.masksToBounds = YES;
		[self addSubview:creatorAvatarImageView];
		
		UIButton *creatorAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		creatorAvatarButton.frame = creatorAvatarImageView.frame;
		[creatorAvatarButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
		[creatorAvatarButton addTarget:self action:@selector(_goCreatorTimeline) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:creatorAvatarButton];
		
		CGSize size = [[NSString stringWithFormat:@"@%@", _challengeVO.creatorName] sizeWithFont:[[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12] constrainedToSize:CGSizeMake(210.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
		UILabel *creatorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(58.0, 371.0, size.width, 20.0)];
		creatorNameLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
		creatorNameLabel.textColor = [HONAppDelegate honBlueTxtColor];
		creatorNameLabel.backgroundColor = [UIColor clearColor];
		creatorNameLabel.text = [NSString stringWithFormat:@"@%@", _challengeVO.creatorName];
		[self addSubview:creatorNameLabel];
		
		UIButton *creatorNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
		creatorNameButton.frame = creatorNameLabel.frame;
		[creatorNameButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
		[creatorNameButton addTarget:self action:@selector(_goCreatorTimeline) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:creatorNameButton];
		
		size = [@"is waiting for a snap…" sizeWithFont:[[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12] constrainedToSize:CGSizeMake(210.0 - creatorNameLabel.frame.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
		UILabel *waitingLabel = [[UILabel alloc] initWithFrame:CGRectMake(creatorNameLabel.frame.origin.x + creatorNameLabel.frame.size.width + 6.0, 371.0, size.width, 20.0)];
		waitingLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
		waitingLabel.textColor = [HONAppDelegate honGreyTxtColor];
		waitingLabel.backgroundColor = [UIColor clearColor];
		waitingLabel.text = @"is waiting for a snap…";
		[self addSubview:waitingLabel];
		
		if ([_challengeVO.challengerName length] > 0) {
			creatorNameLabel.frame = CGRectOffset(creatorNameLabel.frame, 0.0, -7.0);
			creatorNameButton.frame = creatorNameLabel.frame;
			waitingLabel.frame = CGRectOffset(waitingLabel.frame, 0.0, -7.0);
			
			UILabel *challengerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(58.0, 379.0, 250.0, 20.0)];
			challengerNameLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
			challengerNameLabel.textColor = [HONAppDelegate honBlueTxtColor];
			challengerNameLabel.backgroundColor = [UIColor clearColor];
			challengerNameLabel.text = [NSString stringWithFormat:@"@%@", _challengeVO.challengerName];
			[self addSubview:challengerNameLabel];
			
			UIButton *challenngerNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
			challenngerNameButton.frame = challengerNameLabel.frame;
			[challenngerNameButton addTarget:self action:@selector(_goChallengerTimeline) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:challenngerNameButton];
		}
		
//		CGSize size = [[NSString stringWithFormat:@"   @%@ is waiting for a snap   ", _challengeVO.creatorName] sizeWithFont:[[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12] constrainedToSize:CGSizeMake(210.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
//		NSLog(@"SIZE:[%f]", size.width);
//		
//		if (size.width >= 198.0)
//			size.width = 220.0;
//		
//		_votesButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		_votesButton.frame = CGRectMake(57.0, 364.0, size.width, 34.0);
//		[_votesButton setBackgroundImage:[[UIImage imageNamed:@"timelineNoMatch_nonActive"] stretchableImageWithLeftCapWidth:24.0 topCapHeight:0.0] forState:UIControlStateNormal];
//		[_votesButton setBackgroundImage:[[UIImage imageNamed:@"timelineNoMatch_Active"] stretchableImageWithLeftCapWidth:24.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
//		[_votesButton addTarget:self action:@selector(_goCreateChallenge) forControlEvents:UIControlEventTouchUpInside];
//		_votesButton.titleLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
//		[_votesButton setTitleColor:[UIColor colorWithWhite:0.455 alpha:1.0] forState:UIControlStateNormal];
//		[_votesButton setTitle:[NSString stringWithFormat:@" @%@ is waiting for a snap ", _challengeVO.creatorName] forState:UIControlStateNormal];
//		[self addSubview:_votesButton];
		
		moreButton.frame = CGRectOffset(moreButton.frame, 0.0, 111.0);
	}
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
	[self _showTapOverlayOnView:_lHolderView];
	
	[[Mixpanel sharedInstance] track:@"Timeline - Single Tap Creator"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	if (_hasChallenger) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_IN_SESSION_CREATOR_DETAILS" object:_challengeVO];
	
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_NOT_IN_SESSION_DETAILS" object:_challengeVO];
	}
}

- (void)_goSingleTapRight {
	[self _showTapOverlayOnView:_rHolderView];
	
	[[Mixpanel sharedInstance] track:@"Timeline - Single Tap Challenger"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_IN_SESSION_CHALLENGER_DETAILS" object:_challengeVO];
}

- (void)_goDoubleTapLeft {
	[self _showTapOverlayOnView:_lHolderView];
	
	[[Mixpanel sharedInstance] track:@"Timeline - Double Tap Creator"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	if (_hasChallenger)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"UPVOTE_CREATOR" object:_challengeVO];
		
	else {
		if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != _challengeVO.creatorID) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_CREATOR_CHALLENGE" object:_challengeVO];
			
		} else
			[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_SUBJECT_CHALLENGE" object:_challengeVO];
	}
}

- (void)_goDoubleTapRight {
	[self _showTapOverlayOnView:_rHolderView];
	
	[[Mixpanel sharedInstance] track:@"Timeline - Double Tap Challenger"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UPVOTE_CHALLENGER" object:_challengeVO];
}

- (void)_goCreateChallenge {
	if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != _challengeVO.creatorID) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_CREATOR_CHALLENGE" object:_challengeVO];
		
	} else
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_SUBJECT_CHALLENGE" object:_challengeVO];
}

- (void)_goScore {
	
//	if (_challengeVO.creatorScore + _challengeVO.challengerScore == 0) {
//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Like Snap"
//																			 message:@"Do you want to be the first user to like this?"
//																			delegate:self
//																cancelButtonTitle:@"Cancel"
//																otherButtonTitles:@"OK", nil];
//		[alertView setTag:0];
//		[alertView show];
//	
//	} else
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
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																				delegate:self
																	cancelButtonTitle:@"Cancel"
															 destructiveButtonTitle:@"Report Abuse"
																	otherButtonTitles:(_hasChallenger) ? [NSString stringWithFormat:@"Snap this %@", _challengeVO.subjectName] : @"Snap@Me", @"Share", nil];
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
		
		_heartImageView = [[UIImageView alloc] initWithFrame:CGRectMake(33.0, 33.0, 84.0, 84.0)];
		_heartImageView.image = [UIImage imageNamed:@"largeHeart_nonActive"];
		[_lHolderView addSubview:_heartImageView];
		
		[UIView animateWithDuration:0.33 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^(void){
			_heartImageView.alpha = 0.0;
		} completion:^(BOOL finished){
			[_heartImageView removeFromSuperview];
			_heartImageView = nil;
		}];
		
		NSString *caption;
		if ([HONAppDelegate hasVoted:_challengeVO.challengeID] != 0) {
			_challengeVO.creatorScore++;
			_lScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.creatorScore];
			
			[self _clearResults];
			_loserOverlayView.frame = CGRectOffset(_loserOverlayView.frame, (_challengeVO.creatorScore > _challengeVO.challengerScore) ? 7.0 : 160.0, 0.0);
			_loserOverlayView.hidden = (_challengeVO.creatorScore == _challengeVO.challengerScore);
			
			caption = [NSString stringWithFormat:(_challengeVO.creatorScore + _challengeVO.challengerScore == 1) ? @"%d Like" : @"%d Likes", (_challengeVO.creatorScore + _challengeVO.challengerScore)];
		
		} else {
			[[Mixpanel sharedInstance] track:@"Timeline - Upvote Creator"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
														 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
			
			_lScoreLabel.text = [NSString stringWithFormat:@"%d", (_challengeVO.creatorScore + 1)];
			
			[self _clearResults];
			_loserOverlayView.frame = CGRectOffset(_loserOverlayView.frame, (_challengeVO.creatorScore > (_challengeVO.challengerScore + 1)) ? 7.0 : 160.0, 0.0);
			_loserOverlayView.hidden = ((_challengeVO.creatorScore + 1) == _challengeVO.challengerScore);
			
			caption = [NSString stringWithFormat:(1 + (_challengeVO.creatorScore + _challengeVO.challengerScore) == 1) ? @"%d Like" : @"%d Likes", 1 + (_challengeVO.creatorScore + _challengeVO.challengerScore)];
			
			[HONAppDelegate setVote:_challengeVO.challengeID forCreator:YES];
			
			AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
			NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
											[NSString stringWithFormat:@"%d", 6], @"action",
											[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
											[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
											@"Y", @"creator",
											nil];
			
			[httpClient postPath:kVotesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
		
//		CGSize size = [caption sizeWithFont:[[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:12] constrainedToSize:CGSizeMake(150.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
//		_votesButton.frame = CGRectMake(6.0, 253.0, 34.0 + size.width, 34.0);
//		[_votesButton setTitle:caption forState:UIControlStateNormal];
		
		_likesLabel.text = caption;
	}
}

- (void)_upvoteChallenger:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	if ([vo isEqual:_challengeVO]) {
		//[self _playVoteSFX];
		
		_heartImageView = [[UIImageView alloc] initWithFrame:CGRectMake(33.0, 33.0, 84.0, 84.0)];
		_heartImageView.image = [UIImage imageNamed:@"largeHeart_nonActive"];
		[_rHolderView addSubview:_heartImageView];
		
		[UIView animateWithDuration:0.33 delay:0.125 options:UIViewAnimationOptionCurveEaseOut animations:^(void){
			_heartImageView.alpha = 0.0;
		} completion:^(BOOL finished){
			[_heartImageView removeFromSuperview];
			_heartImageView = nil;
		}];
		
		NSString *caption;
		if ([HONAppDelegate hasVoted:_challengeVO.challengeID] != 0) {
			_challengeVO.challengerScore++;
			
			_rScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.challengerScore];
			
			[self _clearResults];
			_loserOverlayView.frame = CGRectOffset(_loserOverlayView.frame, (_challengeVO.creatorScore > _challengeVO.challengerScore) ? 160.0 : 7.0, 0.0);
			_loserOverlayView.hidden = (_challengeVO.creatorScore == _challengeVO.challengerScore);
			
			caption = [NSString stringWithFormat:(_challengeVO.creatorScore + _challengeVO.challengerScore == 1) ? @"%d Like" : @"%d Likes", (_challengeVO.creatorScore + _challengeVO.challengerScore)];
			
		} else {
			[[Mixpanel sharedInstance] track:@"Timeline - Upvote Challenger"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
														 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
			
			_rScoreLabel.text = [NSString stringWithFormat:@"%d", (_challengeVO.challengerScore + 1)];
			
			[self _clearResults];
			_loserOverlayView.frame = CGRectOffset(_loserOverlayView.frame, (_challengeVO.creatorScore > (_challengeVO.challengerScore + 1)) ? 160.0 : 7.0, 0.0);
			_loserOverlayView.hidden = (_challengeVO.creatorScore == (_challengeVO.challengerScore + 1));
			
			caption = [NSString stringWithFormat:(1 + (_challengeVO.creatorScore + _challengeVO.challengerScore) == 1) ? @"%d Like" : @"%d Likes", 1 + (_challengeVO.creatorScore + _challengeVO.challengerScore)];
			[HONAppDelegate setVote:_challengeVO.challengeID forCreator:NO];
			
			AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
			NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
											[NSString stringWithFormat:@"%d", 6], @"action",
											[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
											[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
											@"N", @"creator",
											nil];
			
			[httpClient postPath:kVotesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
		
//		CGSize size = [caption sizeWithFont:[[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:12] constrainedToSize:CGSizeMake(150.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
//		_votesButton.frame = CGRectMake(6.0, 253.0, 34.0 + size.width, 34.0);
//		[_votesButton setTitle:caption forState:UIControlStateNormal];
		
		_likesLabel.text = _likesLabel.text = caption;
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
				[[NSNotificationCenter defaultCenter] postNotificationName:(_hasChallenger) ? @"NEW_SUBJECT_CHALLENGE" : @"NEW_CREATOR_CHALLENGE" object:_challengeVO];
				break;
				
			case 2:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHARE_CHALLENGE" object:_challengeVO];
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


