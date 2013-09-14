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


@interface HONTimelineItemViewCell()
@property (nonatomic, strong) UIView *creatorHolderView;
@property (nonatomic, strong) UIView *rHolderView;
@property (nonatomic, strong) UIImageView *creatorImageView;
@property (nonatomic, strong) UILabel *commentsLabel;
@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, strong) UIImageView *upvoteImageView;
@property (nonatomic, strong) UIView *tappedOverlayView;
@property (nonatomic, strong) NSMutableArray *voters;
@property (nonatomic) BOOL hasOponentRetorted;
@property (nonatomic) BOOL isChallengeCreator;
@property (nonatomic) BOOL isChallengeOpponent;
@property (nonatomic) int opponentCounter;

@end

@implementation HONTimelineItemViewCell
@synthesize delegate = _delegate;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		_hasOponentRetorted = YES;
		self.backgroundColor = [UIColor clearColor];
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
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_VOTE_TAB" object:nil];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
	}];
}


#pragma mark - Public APIs
- (void)upvoteUser:(int)userID {
	if (_challengeVO.creatorVO.userID == userID)
		_challengeVO.creatorVO.score++;
	
	else {
		int index = -1;
		int counter = 0;
		for (HONOpponentVO *vo in _challengeVO.challengers) {
			if (vo.userID == userID) {
				index = counter;
				break;
			}
			
			counter++;
		}

		((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:index]).score++;
	}
	
	_likesLabel.text = ([self _calcScore] > 99) ? @"99+" : [NSString stringWithFormat:@"%d", [self _calcScore]];
}

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
	
	_opponentCounter = 0;
	for (HONOpponentVO *vo in _challengeVO.challengers) {
		if ([((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:_opponentCounter]).imagePrefix length] > 0)
			_opponentCounter++;
	}
	
	
	__weak typeof(self) weakSelf = self;
	//NSLog(@"setChallengeVO:%@[%@](%d)", challengeVO.subjectName, challengeVO.status, (int)_hasOponentRetorted);
	
//	_creatorHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 198.0)];
	_creatorHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 370.0)];
	_creatorHolderView.clipsToBounds = YES;
	[self addSubview:_creatorHolderView];
	
//	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initAtPos:CGPointMake(73.0, 73.0)];
//	[_creatorHolderView addSubview:imageLoadingView];
	
	_creatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 427.0)];
	_creatorImageView.userInteractionEnabled = YES;
	_creatorImageView.alpha = [_creatorImageView isImageCached:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_o.jpg", challengeVO.creatorVO.imagePrefix]]]];
	[_creatorHolderView addSubview:_creatorImageView];
	[_creatorImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_o.jpg", challengeVO.creatorVO.imagePrefix]]
																  cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
								placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
									weakSelf.creatorImageView.image = image;
									[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.creatorImageView.alpha = 1.0; } completion:nil];
								} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
									[weakSelf _reloadCreatorImage];
								}];
	
	
//	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(9.0, 5.0, 270.0, 28.0)];
//	subjectLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:26];
//	subjectLabel.textColor = [UIColor whiteColor];
//	subjectLabel.backgroundColor = [UIColor clearColor];
//	subjectLabel.text = _challengeVO.subjectName;
//	[self addSubview:subjectLabel];
//	
//	UILabel *creatorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(9.0, 35.0, 150.0, 19.0)];
//	creatorNameLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16];
//	creatorNameLabel.textColor = [UIColor whiteColor];
//	creatorNameLabel.backgroundColor = [UIColor clearColor];
//	creatorNameLabel.text = [NSString stringWithFormat:@"@%@", _challengeVO.creatorVO.username];
//	[self addSubview:creatorNameLabel];

//	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(148.0, 68.0, 160.0, 16.0)];
//	timeLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:14];
//	timeLabel.textColor = [UIColor whiteColor];
//	timeLabel.backgroundColor = [UIColor clearColor];
//	timeLabel.textAlignment = NSTextAlignmentRight;
//	timeLabel.text = (_challengeVO.expireSeconds > 0) ? [HONAppDelegate formattedExpireTime:_challengeVO.expireSeconds] : [HONAppDelegate timeSinceDate:_challengeVO.updatedDate];
//	[self addSubview:timeLabel];
	
	/*
	_rHolderView = [[UIView alloc] initWithFrame:CGRectMake(1.0 + _lHolderView.frame.origin.x + kSnapLargeDim, 0.0, kSnapMediumDim, kSnapLargeDim)];
	_rHolderView.clipsToBounds = YES;
	[self addSubview:_rHolderView];
	
	_opponentCounter = 0;
	for (HONOpponentVO *vo in _challengeVO.challengers) {
		UIView *opponentHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, (kSnapMediumDim + 1.0) * _opponentCounter, kSnapMediumDim, kSnapMediumDim)];
		[_rHolderView addSubview:opponentHolderView];
		
		if ([((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:_opponentCounter]).imagePrefix length] > 0) {
			[opponentHolderView addSubview:[[HONImageLoadingView alloc] initAtPos:CGPointMake(0.0, 0.0)]];
		
			UIImageView *opponentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapMediumDim, kSnapMediumDim)];
			[opponentImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", ((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:_opponentCounter]).imagePrefix]] placeholderImage:nil];
			[opponentHolderView addSubview:opponentImageView];
		
			UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
			rightButton.frame = opponentImageView.frame;
			[rightButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
			[rightButton addTarget:self action:@selector(_goTapOpponent:) forControlEvents:UIControlEventTouchUpInside];
			[rightButton setTag:_opponentCounter];
			[opponentHolderView addSubview:rightButton];
			
			_opponentCounter++;
		}
		
		if (_opponentCounter == 3)
			break;
	}
	*/
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	lpGestureRecognizer.minimumPressDuration = 0.25;
	[self addGestureRecognizer:lpGestureRecognizer];
	
	UIImageView *gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timelineImageFade"]];
	gradientImageView.frame = CGRectOffset(gradientImageView.frame, 0.0, 216.0);
	[self addSubview:gradientImageView];
	
	
	UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
	joinButton.frame = CGRectMake(234.0, 145.0, 78.0, 78.0);
	[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_nonActive"] forState:UIControlStateNormal];
	[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_Active"] forState:UIControlStateHighlighted];
	[joinButton addTarget:self action:@selector(_goJoinChallenge) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:joinButton];
	
	
	UIView *footerHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 322.0, 320.0, 44.0)];
	[self addSubview:footerHolderView];
	
	UILabel *creatorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(9.0, 0.0, 150.0, 19.0)];
	creatorNameLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:16];
	creatorNameLabel.textColor = [UIColor whiteColor];
	creatorNameLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
	creatorNameLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	creatorNameLabel.backgroundColor = [UIColor clearColor];
	creatorNameLabel.text = _challengeVO.creatorVO.username;
	[footerHolderView addSubview:creatorNameLabel];
	
	UIButton *creatorButton = [UIButton buttonWithType:UIButtonTypeCustom];
	creatorButton.frame = creatorNameLabel.frame;
	[creatorButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
	[creatorButton addTarget:self action:@selector(_goCreatorProfile) forControlEvents:UIControlEventTouchUpInside];
	[footerHolderView addSubview:creatorButton];
	
	//CGSize size = [creatorNameLabel.text sizeWithFont:creatorNameLabel.font constrainedToSize:CGSizeMake(150.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(9.0, 21.0, 270.0, 19.0)];
	subjectLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16];
	subjectLabel.textColor = [UIColor whiteColor];
	subjectLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
	subjectLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _challengeVO.subjectName;
	[footerHolderView addSubview:subjectLabel];
	
	UIButton *likesButton = [UIButton buttonWithType:UIButtonTypeCustom];
	likesButton.frame = CGRectMake(215.0, 20.0, 24.0, 24.0);
	[likesButton setBackgroundImage:[UIImage imageNamed:@"likeIcon"] forState:UIControlStateNormal];
	[likesButton setBackgroundImage:[UIImage imageNamed:@"likeIcon"] forState:UIControlStateHighlighted];
	[footerHolderView addSubview:likesButton];
	
	_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(232.0, 21.0, 40.0, 19.0)];
	_likesLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:16];
	_likesLabel.textColor = [UIColor whiteColor];
	_likesLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
	_likesLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	_likesLabel.backgroundColor = [UIColor clearColor];
	_likesLabel.textAlignment = NSTextAlignmentCenter;
	_likesLabel.text = ([self _calcScore] > 99) ? @"99+" : [NSString stringWithFormat:@"%d", [self _calcScore]];
	[footerHolderView addSubview:_likesLabel];
	
	UIButton *challengersButton = [UIButton buttonWithType:UIButtonTypeCustom];
	challengersButton.frame = CGRectMake(266.0, 19.0, 24.0, 24.0);
	[challengersButton setBackgroundImage:[UIImage imageNamed:@"smallPersonIcon"] forState:UIControlStateNormal];
	[challengersButton setBackgroundImage:[UIImage imageNamed:@"smallPersonIcon"] forState:UIControlStateHighlighted];
	[footerHolderView addSubview:challengersButton];
	
	UILabel *challengersLabel = [[UILabel alloc] initWithFrame:CGRectMake(282.0, 20.0, 40.0, 22.0)];
	challengersLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:16];
	challengersLabel.textColor = [UIColor whiteColor];
	challengersLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
	challengersLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	challengersLabel.backgroundColor = [UIColor clearColor];
	challengersLabel.textAlignment = NSTextAlignmentCenter;
	challengersLabel.text = (_opponentCounter > 99) ? @"99+" : [NSString stringWithFormat:@"%d", _opponentCounter];
	[footerHolderView addSubview:challengersLabel];
	
//	UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	moreButton.frame = CGRectMake(275.0, 0.0, 44.0, 44.0);
//	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_nonActive"] forState:UIControlStateNormal];
//	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreIcon_Active"] forState:UIControlStateHighlighted];
//	[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
//	[footerHolderView addSubview:moreButton];
}


#pragma mark - Navigation
- (void)_goMore {
	
}

- (void)_goCreatorProfile {
	[self.delegate timelineItemViewCell:self showProfileForUserID:_challengeVO.creatorVO.userID forChallenge:_challengeVO];
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

#pragma mark - UI Presentation
- (void)_reloadCreatorImage {
	__weak typeof(self) weakSelf = self;
	
	_creatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-25.0, 0.0, 370.0, 370.0)];
	_creatorImageView.alpha = [_creatorImageView isImageCached:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", _challengeVO.creatorVO.imagePrefix]]]];
	[_creatorHolderView addSubview:_creatorImageView];
	[_creatorImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", _challengeVO.creatorVO.imagePrefix]]
																		cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
									  placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
										  weakSelf.creatorImageView.image = image;
										  [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.creatorImageView.alpha = 1.0; } completion:nil];
									  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
										  NSLog(@"%@_l.jpg", weakSelf.challengeVO.creatorVO.imagePrefix);
									  }];
}

-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint touchPoint = [lpGestureRecognizer locationInView:self];
		NSLog(@"TOUCH:%@", NSStringFromCGPoint(touchPoint));
		
		CGRect creatorFrame = CGRectMake(_creatorHolderView.frame.origin.x, _creatorHolderView.frame.origin.y, _creatorHolderView.frame.size.width, _creatorHolderView.frame.size.height);
		if (CGRectContainsPoint(creatorFrame, touchPoint))
			[self.delegate timelineItemViewCell:self showPreview:_challengeVO.creatorVO forChallenge:_challengeVO];
		
		if (CGRectContainsPoint(_rHolderView.frame, touchPoint) && _opponentCounter > 0) {
			int index = touchPoint.y / (kSnapMediumDim + 1.0);
			
			if (index < _opponentCounter)
				[self.delegate timelineItemViewCell:self showPreview:(HONOpponentVO *)[_challengeVO.challengers objectAtIndex:index] forChallenge:_challengeVO];
		}
		
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
		[self.delegate timelineItemViewCellHidePreview:self];
	}
}

- (void)showTapOverlay {
	_tappedOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.frame.size.height)];
	_tappedOverlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.67];
	[self addSubview:_tappedOverlayView];
	
	NSLog(@"OVERLAY:[%@]", NSStringFromCGRect(_tappedOverlayView.frame));
	[UIView animateWithDuration:0.33 delay:0.125 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		_tappedOverlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[_tappedOverlayView removeFromSuperview];
		_tappedOverlayView = nil;
	}];
}

- (int)_calcScore {
	int score = _challengeVO.creatorVO.score;
	for (HONOpponentVO *vo in _challengeVO.challengers)
		score += vo.score;
	
	return (score);
}


@end

