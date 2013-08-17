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
@property (nonatomic, strong) NSTimer *tapTimer;
@property (nonatomic) BOOL isDoubleTap;
@property (nonatomic, strong) UITapGestureRecognizer *r1ChallengeGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *r2ChallengeGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *r3ChallengeGestureRecognizer;
@property (nonatomic, strong) UILabel *commentsLabel;
@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, strong) UIImageView *upvoteImageView;
@property (nonatomic, strong) UIView *tappedOverlayView;
@property (nonatomic, strong) NSMutableArray *voters;
@property (nonatomic) BOOL hasOponentRetorted;
@property (nonatomic) BOOL isChallengeCreator;
@property (nonatomic) BOOL isChallengeOpponent;

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
- (void)_upvoteChallenge:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 6], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
							[NSString stringWithFormat:@"%d", userID], @"challengerID",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
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
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
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
	_isChallengeOpponent = NO;
	for (HONOpponentVO *vo in _challengeVO.challengers) {
		if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == vo.userID) {
			_isChallengeOpponent = YES;
			break;
		}
	}
	
	
	__weak typeof(self) weakSelf = self;
	//NSLog(@"setChallengeVO:%@[%@](%d)", challengeVO.subjectName, challengeVO.status, (int)_hasOponentRetorted);
	
	_lHolderView = [[UIView alloc] initWithFrame:CGRectMake(12.0, 0.0, kSnapLargeDim, kSnapLargeDim)];
	_lHolderView.clipsToBounds = YES;
	[self addSubview:_lHolderView];
	
	HONImageLoadingView *lImageLoading = [[HONImageLoadingView alloc] initAtPos:CGPointMake(73.0, 73.0)];
	[_lHolderView addSubview:lImageLoading];
	
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
	
	_rHolderView = [[UIView alloc] initWithFrame:CGRectMake(1.0 + _lHolderView.frame.origin.x + kSnapLargeDim, 0.0, kSnapMediumDim, kSnapLargeDim)];
	_rHolderView.clipsToBounds = YES;
	[self addSubview:_rHolderView];
	
	int opponentCounter = 0;
	for (HONOpponentVO *vo in _challengeVO.challengers) {
		UIView *opponentHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, (kSnapMediumDim + 1.0) * opponentCounter, kSnapMediumDim, kSnapMediumDim)];
		[_rHolderView addSubview:opponentHolderView];
		
		if ([((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:opponentCounter]).imagePrefix length] > 0)
			[opponentHolderView addSubview:[[HONImageLoadingView alloc] initAtPos:CGPointMake(0.0, 0.0)]];
		
		UIImageView *opponentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapMediumDim, kSnapMediumDim)];
		[opponentImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", ((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:opponentCounter]).imagePrefix]] placeholderImage:nil];
		[opponentHolderView addSubview:opponentImageView];
		
//		if (opponentCounter == 0) {
//			_rChallenge1ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapMediumDim, kSnapMediumDim)];
//			_rChallenge1ImageView.alpha = [_rChallenge1ImageView isImageCached:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", ((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:opponentCounter]).imagePrefix]]]];
//			_rChallenge1ImageView.userInteractionEnabled = YES;
//			[opponentHolderView addSubview:_rChallenge1ImageView];
//			
//			[_rChallenge1ImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", ((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:opponentCounter]).imagePrefix]]
//																		   cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
//										 placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//											 weakSelf.rChallenge1ImageView.image = image;
//											 [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.rChallenge1ImageView.alpha = 1.0; } completion:nil];
//										 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
//			
//		} else if (opponentCounter == 1) {
//			_rChallenge2ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapMediumDim, kSnapMediumDim)];
//			_rChallenge2ImageView.alpha = [_rChallenge2ImageView isImageCached:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", ((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:opponentCounter]).imagePrefix]]]];
//			_rChallenge2ImageView.userInteractionEnabled = YES;
//			[opponentHolderView addSubview:_rChallenge1ImageView];
//			
//			[_rChallenge2ImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", ((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:opponentCounter]).imagePrefix]]
//																		   cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
//										 placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//											 weakSelf.rChallenge2ImageView.image = image;
//											 [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.rChallenge2ImageView.alpha = 1.0; } completion:nil];
//										 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
//						
//		} else if (opponentCounter == 2) {
//			_rChallenge3ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapMediumDim, kSnapMediumDim)];
//			_rChallenge3ImageView.alpha = [_rChallenge3ImageView isImageCached:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", ((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:opponentCounter]).imagePrefix]]]];
//			_rChallenge3ImageView.userInteractionEnabled = YES;
//			[opponentHolderView addSubview:_rChallenge1ImageView];
//			
//			[_rChallenge3ImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", ((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:opponentCounter]).imagePrefix]]
//																		   cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
//										 placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//											 weakSelf.rChallenge3ImageView.image = image;
//											 [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.rChallenge3ImageView.alpha = 1.0; } completion:nil];
//										 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
//			
//		}
		
		UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
		rightButton.frame = opponentImageView.frame;
		[rightButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
		[rightButton addTarget:self action:@selector(_goTapOpponent:) forControlEvents:UIControlEventTouchUpInside];
		[rightButton setTag:opponentCounter];
		[opponentHolderView addSubview:rightButton];
		
		UIImageView *strokeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, kSnapMediumDim - 30.0, 30.0, 30.0)];
		strokeImageView.image = [UIImage imageNamed:@"avatarStroke"];
		//[opponentHolderView addSubview:strokeImageView];
		
		UIImageView *challengerAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, kSnapMediumDim - 28.0, 28.0, 28.0)];
		[challengerAvatarImageView setImageWithURL:[NSURL URLWithString:((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:opponentCounter]).avatarURL] placeholderImage:nil];
		challengerAvatarImageView.userInteractionEnabled = YES;
		challengerAvatarImageView.clipsToBounds = YES;
		//[opponentHolderView addSubview:challengerAvatarImageView];
		
		UIButton *challengerAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		challengerAvatarButton.frame = challengerAvatarImageView.frame;
		[challengerAvatarButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
		[challengerAvatarButton addTarget:self action:@selector(_goChallengerTimeline:) forControlEvents:UIControlEventTouchUpInside];
		[challengerAvatarButton setTag:opponentCounter];
		//[opponentHolderView addSubview:challengerAvatarButton];
 		
		opponentCounter++;
	}
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	[self addGestureRecognizer:lpGestureRecognizer];
	
	
	UIView *footerHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 231.0, 320.0, 44.0)];
	[self addSubview:footerHolderView];
	
	UIButton *commentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	commentsButton.frame = CGRectMake(8.0, 6.0, 24.0, 24.0);
	[commentsButton setBackgroundImage:[UIImage imageNamed:@"commentBubble"] forState:UIControlStateNormal];
	[commentsButton setBackgroundImage:[UIImage imageNamed:@"commentBubble"] forState:UIControlStateHighlighted];
	[commentsButton addTarget:self action:@selector(_goComments) forControlEvents:UIControlEventTouchUpInside];
	[footerHolderView addSubview:commentsButton];
	
	_commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(37.0, 7.0, 40.0, 22.0)];
	_commentsLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17];
	_commentsLabel.textColor = [HONAppDelegate honBlueTextColor];
	_commentsLabel.backgroundColor = [UIColor clearColor];
	_commentsLabel.text = (_challengeVO.commentTotal >= 99) ? @"99+" : [NSString stringWithFormat:@"%d", _challengeVO.commentTotal];
	[footerHolderView addSubview:_commentsLabel];
	
	UIButton *commentsLabelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	commentsLabelButton.frame = _commentsLabel.frame;
	[commentsLabelButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
	[commentsLabelButton addTarget:self action:@selector(_goComments) forControlEvents:UIControlEventTouchUpInside];
	[footerHolderView addSubview:commentsLabelButton];
	
	
	UIButton *likesButton = [UIButton buttonWithType:UIButtonTypeCustom];
	likesButton.frame = CGRectMake(71.0, 6.0, 24.0, 24.0);
	[likesButton setBackgroundImage:[UIImage imageNamed:@"heartIcon"] forState:UIControlStateNormal];
	[likesButton setBackgroundImage:[UIImage imageNamed:@"heartIcon"] forState:UIControlStateHighlighted];
	[likesButton addTarget:self action:@selector(_goScore) forControlEvents:UIControlEventTouchUpInside];
	[footerHolderView addSubview:likesButton];
	
	_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 7.0, 40.0, 22.0)];
	_likesLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17];
	_likesLabel.textColor = [HONAppDelegate honBlueTextColor];
	_likesLabel.backgroundColor = [UIColor clearColor];
	_likesLabel.text = (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score > 99) ? @"99+" : [NSString stringWithFormat:@"%d", (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score)];
	[footerHolderView addSubview:_likesLabel];
	
	UIButton *likesLabelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	likesLabelButton.frame = _likesLabel.frame;
	[likesLabelButton setBackgroundImage:[UIImage imageNamed:@"whiteOverlay_50"] forState:UIControlStateHighlighted];
	[likesLabelButton addTarget:self action:@selector(_goScore) forControlEvents:UIControlEventTouchUpInside];
	[footerHolderView addSubview:likesLabelButton];
	
	UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
	joinButton.frame = CGRectMake(244.0, 0.0, 64.0, 39.0);
	[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_nonActive"] forState:UIControlStateNormal];
	[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_Active"] forState:UIControlStateHighlighted];
	[joinButton addTarget:self action:@selector(_goJoinChallenge) forControlEvents:UIControlEventTouchUpInside];
	[footerHolderView addSubview:joinButton];
	
//	UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	moreButton.frame = CGRectMake(254.0, 0.0, 64.0, 44.0);
//	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive"] forState:UIControlStateNormal];
//	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_Active"] forState:UIControlStateHighlighted];
//	[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
//	[footerHolderView addSubview:moreButton];
	
	UIImageView *dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider"]];
	dividerImageView.frame = CGRectOffset(dividerImageView.frame, 5.0, 282.0);
	[self addSubview:dividerImageView];
}


#pragma mark - Navigation
- (void)_tapTimeout {
	_isDoubleTap = NO;
	[self _goChallengeDetails];
}

- (void)_goTapCreator {
	[self _goChallengeDetails];
//	
//	if (!_isDoubleTap) {
//		_isDoubleTap = YES;
//		_tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(_tapTimeout) userInfo:nil repeats:NO];
//	
//	} else {
//		if (_tapTimer != nil) {
//			[_tapTimer invalidate];
//			_tapTimer = nil;
//		}
//		
//		_isDoubleTap = NO;
//		[self _goUpvoteCreator];
//	}
}

- (void)_goTapOpponent:(id)sender {
	[self _goChallengeDetails];
	
//	if (!_isDoubleTap) {
//		_isDoubleTap = YES;
//		_tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(_tapTimeout) userInfo:nil repeats:NO];
//		
//	} else {
//		if (_tapTimer != nil) {
//			[_tapTimer invalidate];
//			_tapTimer = nil;
//		}
//		
//		_isDoubleTap = NO;
//		[self _goUpvoteChallenger:[(UIButton *)sender tag]];
//	}
}


- (void)_goChallengeDetails {
	[self.delegate timelineItemViewCell:self showChallenge:_challengeVO];
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

- (void)_goChallengerTimeline:(id)sender {
	[[Mixpanel sharedInstance] track:@"Timeline - Show Challenger Timeline"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", ((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:[(UIButton *)sender tag]]).userID, ((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:[(UIButton *)sender tag]]).username], @"challenger", nil]];
	
	[self.delegate timelineItemViewCell:self showUserChallenges:((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:[(UIButton *)sender tag]]).username];
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
		[self _upvoteChallenge:_challengeVO.creatorVO.userID];
	}
	
	_likesLabel.text = (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score > 99) ? @"99+" : [NSString stringWithFormat:@"%d", (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score)];
}

- (void)_goUpvoteChallenger:(int)index {
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
		[self _upvoteChallenge:((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:index]).userID];
	}
	
	_likesLabel.text = (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score > 99) ? @"99+" : [NSString stringWithFormat:@"%d", (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score)];

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
														otherButtonTitles:@"Join Volley", nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
		[actionSheet setTag:1];
		[actionSheet showInView:[HONAppDelegate appTabBarController].view];
}


#pragma mark - UI Presentation
-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint touchPoint = [lpGestureRecognizer locationInView:self];
		NSLog(@"TOUCH:%@", NSStringFromCGPoint(touchPoint));
		NSLog(@"L-FRAME:%@", NSStringFromCGRect(_lHolderView.frame));
		NSLog(@"R-FRAME:%@", NSStringFromCGRect(_rHolderView.frame));
		
		CGRect creatorFrame = CGRectMake(_lHolderView.frame.origin.x, _lHolderView.frame.origin.y, _lHolderView.frame.size.width, _lHolderView.frame.size.height);
		if (CGRectContainsPoint(creatorFrame, touchPoint))
			[self.delegate timelineItemViewCell:self showPreview:_challengeVO.creatorVO forChallenge:_challengeVO];
		
		if (CGRectContainsPoint(_rHolderView.frame, touchPoint)) {
			int index = touchPoint.y / (kSnapMediumDim + 1.0);
			[self.delegate timelineItemViewCell:self showPreview:(HONOpponentVO *)[_challengeVO.challengers objectAtIndex:index] forChallenge:_challengeVO];
		}
		
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
		[self.delegate timelineItemViewCellHidePreview:self];
	}
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
//				if (_isChallengeOpponent)
//					[self  _goAcceptChallenge];
//				
//				else
					[self _goJoinChallenge];
				
				break;
		}
//	}
}


@end

