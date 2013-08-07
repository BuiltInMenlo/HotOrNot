//
//  HONTimelineItemViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"

#import "HONTimelineItemViewCell.h"
#import "HONImageLoadingView.h"
#import "HONVoterVO.h"
#import "HONUserVO.h"
#import "HONOpponentVO.h"


@interface HONTimelineItemViewCell() <UIActionSheetDelegate>
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
@property (nonatomic) BOOL isChallengeCreator;
@property (nonatomic) BOOL isChallengeOpponent;
@property (nonatomic, strong) HONImageLoadingView *lImageLoading;
@property (nonatomic, strong) HONImageLoadingView *rImageLoading;

@end

@implementation HONTimelineItemViewCell
@synthesize delegate = _delegate;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initAsStartedCell:(BOOL)hasStarted {
	if ((self = [super init])) {
		_hasOponentRetorted = hasStarted;
		[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timelineRowBackground"]]];
	}
	
	return (self);
}




#pragma mark - Data Calls
- (void)_upvoteChallengeCreator:(BOOL)isCreator {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 6], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
							(isCreator) ? @"Y" : @"N", @"creator",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSDictionary *voteResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], voteResult);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
	}];
}

- (void)_flagChallenge {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 11], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			//NSDictionary *flagResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], flagResult);
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_VOTE_TAB" object:nil];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
	}];
}


#pragma mark - Public APIs
- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	_isChallengeCreator = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _challengeVO.creatorVO.userID);
	_isChallengeOpponent = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == ((HONOpponentVO *)[_challengeVO.challengers lastObject]).userID);
	
	
	__weak typeof(self) weakSelf = self;
	//NSLog(@"setChallengeVO:%@[%@](%d)", challengeVO.subjectName, challengeVO.status, (int)_hasOponentRetorted);
	
//	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 18.0, 200.0, 28.0)];
//	subjectLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:24];
//	subjectLabel.textColor = [HONAppDelegate honBlueTextColor];
//	subjectLabel.backgroundColor = [UIColor clearColor];
//	subjectLabel.text = _challengeVO.subjectName;
//	[self addSubview:subjectLabel];
//	
//	UIButton *subjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	subjectButton.frame = subjectLabel.frame;
//	[subjectButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
//	[subjectButton addTarget:self action:@selector(_goSubjectTimeline) forControlEvents:UIControlEventTouchUpInside];
//	[self addSubview:subjectButton];
//	
//	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(146.0, 20.0, 160.0, 16.0)];
//	timeLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:13];
//	timeLabel.textColor = [HONAppDelegate honGreyTimeColor];
//	timeLabel.backgroundColor = [UIColor clearColor];
//	timeLabel.textAlignment = NSTextAlignmentRight;
//	timeLabel.text = (_challengeVO.expireSeconds > 0) ? [HONAppDelegate formattedExpireTime:_challengeVO.expireSeconds] : [HONAppDelegate timeSinceDate:_challengeVO.updatedDate];
//	[self addSubview:timeLabel];
	
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 55.0, 320.0, kSnapLargeDim)];
	scrollView.contentSize = CGSizeMake((kSnapLargeDim + 10.0 + 54.0) + ((kSnapLargeDim + 20.0) * ((int)_hasOponentRetorted)), kSnapLargeDim);
	scrollView.pagingEnabled = NO;
	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.backgroundColor = [UIColor whiteColor];
	[self addSubview:scrollView];
	
	_lHolderView = [[UIView alloc] initWithFrame:CGRectMake(64.0, 0.0, kSnapLargeDim, kSnapLargeDim)];
	_lHolderView.clipsToBounds = YES;
	[scrollView addSubview:_lHolderView];
	
	_lImageLoading = [[HONImageLoadingView alloc] initAtPos:CGPointMake(73.0, 73.0)];
	[_lHolderView addSubview:_lImageLoading];
	
	_lChallengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapLargeDim, kSnapLargeDim)];
	_lChallengeImageView.userInteractionEnabled = YES;
	_lChallengeImageView.alpha = [_lChallengeImageView isImageCached:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", challengeVO.creatorVO.imagePrefix]]]];
	[_lHolderView addSubview:_lChallengeImageView];
	
	[_lChallengeImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", challengeVO.creatorVO.imagePrefix]]
																  cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
								placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
									weakSelf.lChallengeImageView.image = image;
									[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.lChallengeImageView.alpha = 1.0; } completion:nil];
								} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
	
	
	UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
	leftButton.frame = _lChallengeImageView.frame;
	[leftButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
	[leftButton addTarget:self action:@selector(_goTapCreator) forControlEvents:UIControlEventTouchUpInside];
	[_lHolderView addSubview:leftButton];
	
	UIImageView *creatorAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 162.0, 38.0, 38.0)];
	[creatorAvatarImageView setImageWithURL:[NSURL URLWithString:_challengeVO.creatorVO.avatarURL] placeholderImage:nil];
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
	creatorNameLabel.text = [NSString stringWithFormat:@"@%@", _challengeVO.creatorVO.username];
	[_lHolderView addSubview:creatorNameLabel];
	
	UIButton *creatorNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	creatorNameButton.frame = creatorNameLabel.frame;
	[creatorNameButton addTarget:self action:@selector(_goCreatorTimeline) forControlEvents:UIControlEventTouchUpInside];
	[_lHolderView addSubview:creatorNameButton];
	
	_rHolderView = [[UIView alloc] initWithFrame:CGRectMake(54.0 + 20.0 + kSnapLargeDim, 0.0, kSnapLargeDim, kSnapLargeDim)];//[[UIView alloc] initWithFrame:CGRectMake(225.0, 0.0, 210.0, 210.0)];
	_rHolderView.clipsToBounds = YES;
	[scrollView addSubview:_rHolderView];
	
	_rImageLoading = [[HONImageLoadingView alloc] initAtPos:CGPointMake(93.0, 93.0)];
	[_rHolderView addSubview:_rImageLoading];
	
	if (_hasOponentRetorted) {
		_rChallengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapLargeDim, kSnapLargeDim)];
		_rChallengeImageView.alpha = [_rChallengeImageView isImageCached:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", ((HONOpponentVO *)[_challengeVO.challengers lastObject]).imagePrefix]]]];
		_rChallengeImageView.userInteractionEnabled = YES;
		[_rHolderView addSubview:_rChallengeImageView];
		
		[_rChallengeImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", ((HONOpponentVO *)[_challengeVO.challengers lastObject]).imagePrefix]]
																	  cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
									placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
										weakSelf.rChallengeImageView.image = image;
										[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.rChallengeImageView.alpha = 1.0; } completion:nil];
									} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
		
		
		UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
		rightButton.frame = _rChallengeImageView.frame;
		[rightButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
		[rightButton addTarget:self action:@selector(_goTapOpponent) forControlEvents:UIControlEventTouchUpInside];
		[_rHolderView addSubview:rightButton];
		
		UIImageView *challengerAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 162.0, 38.0, 38.0)];
		[challengerAvatarImageView setImageWithURL:[NSURL URLWithString:((HONOpponentVO *)[_challengeVO.challengers lastObject]).avatarURL] placeholderImage:nil];
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
		challengerNameLabel.text = [NSString stringWithFormat:@"@%@", ((HONOpponentVO *)[_challengeVO.challengers lastObject]).username];
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
		_likesLabel.text = (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score > 99) ? @"99+" : [NSString stringWithFormat:@"%d", (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score)];
		[self addSubview:_likesLabel];
		
		UIButton *likesLabelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		likesLabelButton.frame = _likesLabel.frame;
		[likesLabelButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
		[likesLabelButton addTarget:self action:@selector(_goScore) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:likesLabelButton];
		
		UIView *joinHolderView = [[UIView alloc] initWithFrame:CGRectMake(8.0, 0.0, 44.0, kSnapLargeDim)];
		[scrollView addSubview:joinHolderView];
		
		UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
		joinButton.frame = CGRectMake(0.0, 83.0, 44.0, 44.0);
		[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_nonActive"] forState:UIControlStateNormal];
		[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_Active"] forState:UIControlStateHighlighted];
		[joinButton addTarget:self action:@selector(_goJoinChallenge) forControlEvents:UIControlEventTouchUpInside];
		[joinHolderView addSubview:joinButton];
		
	// no challengers have responded yet
	} else {
		UIView *joinHolderView = [[UIView alloc] initWithFrame:CGRectMake(8.0, 0.0, 44.0, kSnapLargeDim)];
		[scrollView addSubview:joinHolderView];
		
		UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
		joinButton.frame = CGRectMake(0.0, 83.0, 44.0, 44.0);
		[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_nonActive"] forState:UIControlStateNormal];
		[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_Active"] forState:UIControlStateHighlighted];
		[joinHolderView addSubview:joinButton];
		
		// awaiting challenger response
		if (((HONOpponentVO *)[_challengeVO.challengers lastObject]).userID != 0) {
			UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
			rightButton.frame = _rChallengeImageView.frame;
			[rightButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
			[rightButton addTarget:self action:@selector(_goTapOpponent) forControlEvents:UIControlEventTouchUpInside];
			[_rHolderView addSubview:rightButton];
			
			UIImageView *challengerAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 162.0, 38.0, 38.0)];
			[challengerAvatarImageView setImageWithURL:[NSURL URLWithString:((HONOpponentVO *)[_challengeVO.challengers lastObject]).avatarURL] placeholderImage:nil];
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
			challengerNameLabel.text = [NSString stringWithFormat:@"@%@", ((HONOpponentVO *)[_challengeVO.challengers lastObject]).username];
			[_rHolderView addSubview:challengerNameLabel];
			
			UIButton *challengerNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
			challengerNameButton.frame = challengerNameLabel.frame;
			[challengerNameButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
			[challengerNameButton addTarget:self action:@selector(_goChallengerTimeline) forControlEvents:UIControlEventTouchUpInside];
			[_rHolderView addSubview:challengerNameButton];
			
			SEL joinSelector = @selector(_goJoinChallenge);
			
			if (_isChallengeCreator)
				joinSelector = @selector(_goChallengerChallenge);
			
			if (_isChallengeOpponent)
				joinSelector = @selector(_goAcceptChallenge);
			
			
			[joinButton addTarget:self action:joinSelector forControlEvents:UIControlEventTouchUpInside];
		
		// no challengers
		} else {
			//[joinButton addTarget:self action:@selector(_goJoinChallenge) forControlEvents:UIControlEventTouchUpInside];
			[joinButton addTarget:self action:(_isChallengeCreator) ? @selector(_goNewSubjectChallenge) : @selector(_goAcceptChallenge) forControlEvents:UIControlEventTouchUpInside];
		}
	}
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	_lScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 9.0, 84.0, 24.0)];
	_lScoreLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:20];
	_lScoreLabel.backgroundColor = [UIColor clearColor];
	_lScoreLabel.textColor = [UIColor whiteColor];
	_lScoreLabel.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:_challengeVO.creatorVO.score]];
	_lScoreLabel.hidden = YES;//!_hasOponentRetorted;
	[_lHolderView addSubview:_lScoreLabel];
	
	_rScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 9.0, 84.0, 24.0)];
	_rScoreLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:20];
	_rScoreLabel.backgroundColor = [UIColor clearColor];
	_rScoreLabel.textColor = [UIColor whiteColor];
	_rScoreLabel.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:((HONOpponentVO *)[_challengeVO.challengers lastObject]).score]];
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
	moreButton.frame = CGRectMake(244.0, 270.0, 64.0, 44.0);
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive"] forState:UIControlStateNormal];
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_Active"] forState:UIControlStateHighlighted];
	[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:moreButton];
}


#pragma mark - Navigation
- (void)_goTapCreator {
	[[Mixpanel sharedInstance] track:@"Timeline - Tap Creator"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	if (_hasOponentRetorted)
		[self _goUpvoteCreator];
	
	else {
		if (!_isChallengeCreator) {
			if (_isChallengeOpponent)
				[self _goAcceptChallenge];
			
			else
				[self _goCreatorChallenge];
		}
			
	}
}

- (void)_goTapOpponent {
	[[Mixpanel sharedInstance] track:@"Timeline - Tap Challenger"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	if (_hasOponentRetorted)
		[self _goUpvoteChallenger];
	
	else {		
		if (_isChallengeOpponent)
			[self  _goAcceptChallenge];
		
		else
			[self _goJoinChallenge];
	}
}


- (void)_goNewSubjectChallenge {
	[self.delegate timelineItemViewCell:self snapWithSubject:_challengeVO.subjectName];
}

- (void)_goCreatorChallenge {
	[self.delegate timelineItemViewCell:self snapAtCreator:_challengeVO];
}

- (void)_goChallengerChallenge {
	[self.delegate timelineItemViewCell:self snapAtChallenger:_challengeVO];
}

- (void)_goAcceptChallenge {
	[self.delegate timelineItemViewCell:self acceptChallenge:_challengeVO];
}

- (void)_goJoinChallenge {
	[self.delegate timelineItemViewCell:self joinChallenge:_challengeVO];
}

- (void)_goComments {
	[self.delegate timelineItemViewCell:self showComments:_challengeVO];
}

- (void)_goScore {
	[self.delegate timelineItemViewCell:self showVoters:_challengeVO];
}

- (void)_goSubjectTimeline {
	[self.delegate timelineItemViewCell:self showSubjectChallenges:_challengeVO.subjectName];
}

- (void)_goCreatorTimeline {
	[[Mixpanel sharedInstance] track:@"Timeline - Show Creator Timeline"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"creator", nil]];
	
	[self.delegate timelineItemViewCell:self showUserChallenges:_challengeVO.creatorVO.username];
}

- (void)_goChallengerTimeline {
	[[Mixpanel sharedInstance] track:@"Timeline - Show Challenger Timeline"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", ((HONOpponentVO *)[_challengeVO.challengers lastObject]).userID, ((HONOpponentVO *)[_challengeVO.challengers lastObject]).username], @"challenger", nil]];
	
	[self.delegate timelineItemViewCell:self showUserChallenges:((HONOpponentVO *)[_challengeVO.challengers lastObject]).username];
}

- (void)_goUpvoteCreator {
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
	
	_challengeVO.creatorVO.score++;
	
	if ([HONAppDelegate hasVoted:_challengeVO.challengeID] == 0) {
		[[Mixpanel sharedInstance] track:@"Timeline - Upvote Creator"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
		
		[HONAppDelegate setVote:_challengeVO.challengeID forCreator:YES];
		[self _upvoteChallengeCreator:YES];
	}
	
	_likesLabel.text = (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score > 99) ? @"99+" : [NSString stringWithFormat:@"%d", (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score)];
	_lScoreLabel.text = [NSString stringWithFormat:@"%d", _challengeVO.creatorVO.score];
}

- (void)_goUpvoteChallenger {
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
	
	((HONOpponentVO *)[_challengeVO.challengers lastObject]).score++;
	
	if ([HONAppDelegate hasVoted:_challengeVO.challengeID] == 0) {
		[[Mixpanel sharedInstance] track:@"Timeline - Upvote Challenger"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
		
		[HONAppDelegate setVote:_challengeVO.challengeID forCreator:NO];
		[self _upvoteChallengeCreator:NO];
	}
	
	_likesLabel.text = (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score > 99) ? @"99+" : [NSString stringWithFormat:@"%d", (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score)];
	_rScoreLabel.text = [NSString stringWithFormat:@"%d", ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score];

}

- (void)_goMore {
	[[Mixpanel sharedInstance] track:@"Timeline - More Shelf"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
//	if (_hasOponentRetorted) {
//		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
//																 delegate:self
//														cancelButtonTitle:@"Cancel"
//												   destructiveButtonTitle:@"Report Abuse"
//														otherButtonTitles:@"View Likes", @"Join Volley", nil];
//		actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
//		[actionSheet setTag:0];
//		[actionSheet showInView:[HONAppDelegate appTabBarController].view];
//
//	} else {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																 delegate:self
														cancelButtonTitle:@"Cancel"
												   destructiveButtonTitle:@"Report Abuse"
														otherButtonTitles:@"Join Volley", nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
		[actionSheet setTag:1];
		[actionSheet showInView:[HONAppDelegate appTabBarController].view];
//	}
}


#pragma mark - ActionSheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//	if (actionSheet.tag == 0) {
//		switch (buttonIndex) {
//			case 0: {
//				[[Mixpanel sharedInstance] track:@"Timeline - Flag"
//											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
//															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
//															 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
//				
//				[self _flagChallenge];
//				
//			break;}
//				
//			case 1:
//				[self.delegate timelineItemViewCell:self showVoters:_challengeVO];
//				break;
//				
//			case 2:
//				[self.delegate timelineItemViewCell:self snapWithSubject:_challengeVO.subjectName];
//				break;
//		}
//	}
//	
//	else if (actionSheet.tag == 1) {
		switch (buttonIndex) {
			case 0: {
				[[Mixpanel sharedInstance] track:@"Timeline - Flag"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
				
				[self _flagChallenge];
				break;}
				
			case 1:
				if (_isChallengeOpponent)
					[self  _goAcceptChallenge];
				
				else
					[self _goJoinChallenge];
				
				break;
		}
//	}
}


@end

