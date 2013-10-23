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
@property (nonatomic, strong) UIView *heroImageHolderView;
@property (nonatomic, strong) UIImageView *heroImageView;
@property (nonatomic, strong) UILabel *commentsLabel;
@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, strong) UIImageView *upvoteImageView;
@property (nonatomic, strong) NSMutableArray *voters;
@property (nonatomic, strong) HONOpponentVO *heroOpponentVO;
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
		self.backgroundColor = [UIColor clearColor];
	}
	
	return (self);
}


#pragma mark - Data Calls


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
	
//	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//	[dateFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
//	NSLog(@"CHALLENGE:[%d]", _challengeVO.challengeID);
//	if (_challengeVO.challengeID == 21567)
//		NSLog(@"DICT:[%@]", _challengeVO.dictionary);
//	NSLog(@"CREATOR:(%@)[%f] CHALLENGER:(%@)[%f]\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n", _challengeVO.creatorVO.dictionary, [_challengeVO.creatorVO.joinedDate timeIntervalSinceNow], ((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0]).dictionary, [((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0]).joinedDate timeIntervalSinceNow]);
	
	_heroOpponentVO = _challengeVO.creatorVO;
	if ([_challengeVO.challengers count] > 0 && ([((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0]).joinedDate timeIntervalSinceNow] > [_heroOpponentVO.joinedDate timeIntervalSinceNow]) && !_challengeVO.isCelebCreated)
		_heroOpponentVO = (HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0];
				
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
	
	_heroImageHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 370.0)];
	_heroImageHolderView.clipsToBounds = YES;
	_heroImageHolderView.backgroundColor = [UIColor blackColor];
	[self.contentView addSubview:_heroImageHolderView];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:_heroImageHolderView];
	[imageLoadingView startAnimating];
	[_heroImageHolderView addSubview:imageLoadingView];
	
	_heroImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 568.0)];
	_heroImageView.userInteractionEnabled = YES;
	_heroImageView.alpha = 0.0;
	[_heroImageHolderView addSubview:_heroImageView];
	[_heroImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@Large_640x1136.jpg", _heroOpponentVO.imagePrefix]]
																  cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
								placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
									weakSelf.heroImageView.image = image;
									[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.heroImageView.alpha = 1.0; } completion:nil];
								} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
									//[weakSelf _reloadHeroImage];
								}];
	
	UIButton *detailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	detailsButton.frame = _heroImageHolderView.frame;
	[detailsButton addTarget:self action:@selector(_goDetails) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:detailsButton];
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	lpGestureRecognizer.minimumPressDuration = 0.25;
	[self addGestureRecognizer:lpGestureRecognizer];
	
	UIImageView *gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timelineImageFade"]];
	gradientImageView.frame = CGRectOffset(gradientImageView.frame, 0.0, 216.0);
	[self.contentView addSubview:gradientImageView];
	
	
	UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
	joinButton.frame = CGRectMake(0.0, 153.0, 64.0, 64.0);
	[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_nonActive"] forState:UIControlStateNormal];
	[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_Active"] forState:UIControlStateHighlighted];
	[joinButton addTarget:self action:@selector(_goJoinChallenge) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:joinButton];
	
	
	NSMutableArray *opponentIDs = [NSMutableArray array];
	for (HONOpponentVO *vo in _challengeVO.challengers) {
		if ([vo.imagePrefix length] > 0) {
			BOOL isFound = NO;
			for (NSNumber *userID in opponentIDs) {
				if ([userID intValue] == vo.userID) {
					isFound = YES;
					break;
				}
			}
			
			if (!isFound)
				[opponentIDs addObject:[NSNumber numberWithInt:vo.userID]];
		}
	}
	
	NSString *participants = _heroOpponentVO.username;
	int uniqueOpponents = ([opponentIDs count] - (int)_isChallengeOpponent) - 1;
	if ((_isChallengeCreator && _isChallengeOpponent) || (!_isChallengeCreator && !_isChallengeOpponent)) {
		if (_challengeVO.creatorVO.userID == _heroOpponentVO.userID)
			participants = (uniqueOpponents > 0) ? [NSString stringWithFormat:@"%@ and %d other%@", _heroOpponentVO.username, uniqueOpponents, (uniqueOpponents == 1) ? @"" : @"s"] : _challengeVO.creatorVO.username;
		
		else
			participants = (uniqueOpponents > 1) ? [NSString stringWithFormat:@"%@, %@ and %d other%@", _heroOpponentVO.username, _challengeVO.creatorVO.username, uniqueOpponents, (uniqueOpponents == 1) ? @"" : @"s"] : _challengeVO.creatorVO.username;
	}
	
	if (!_isChallengeCreator && _isChallengeOpponent)
		participants = (uniqueOpponents > 0) ? [NSString stringWithFormat:@"%@, you and %d other%@", _heroOpponentVO.username, uniqueOpponents, (uniqueOpponents == 1) ? @"" : @"s"] : [NSString stringWithFormat:@"%@ and %@", _heroOpponentVO.username, _challengeVO.creatorVO.username];
	
	if ([_challengeVO.challengers count] == 0)
		participants = _challengeVO.creatorVO.username;
	
	
	UIView *footerHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 320.0, 320.0, 44.0)];
	[self.contentView addSubview:footerHolderView];
	
	UILabel *creatorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(9.0, 3.0, 290.0, 19.0)];
	creatorNameLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:16];
	creatorNameLabel.textColor = [UIColor whiteColor];
	creatorNameLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
	creatorNameLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	creatorNameLabel.backgroundColor = [UIColor clearColor];
	creatorNameLabel.text = participants;
	[footerHolderView addSubview:creatorNameLabel];
	
	UIButton *heroButton = [UIButton buttonWithType:UIButtonTypeCustom];
	heroButton.frame = creatorNameLabel.frame;
	[heroButton addTarget:self action:@selector(_goHeroProfile) forControlEvents:UIControlEventTouchUpInside];
	[footerHolderView addSubview:heroButton];
	
	//CGSize size = [creatorNameLabel.text sizeWithFont:creatorNameLabel.font constrainedToSize:CGSizeMake(150.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 21.0, 270.0, 23.0)];
	subjectLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:17];
	subjectLabel.textColor = [UIColor whiteColor];
	subjectLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
	subjectLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _challengeVO.subjectName;
	[footerHolderView addSubview:subjectLabel];
	
	_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(249.0, 18.0, 40.0, 19.0)];
	_likesLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:16];
	_likesLabel.textColor = [UIColor whiteColor];
	_likesLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
	_likesLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	_likesLabel.backgroundColor = [UIColor clearColor];
	_likesLabel.textAlignment = NSTextAlignmentRight;
	_likesLabel.text = ([self _calcScore] > 99) ? @"99+" : [NSString stringWithFormat:@"%d", [self _calcScore]];
	[footerHolderView addSubview:_likesLabel];
	
	UIButton *likesButton = [UIButton buttonWithType:UIButtonTypeCustom];
	likesButton.frame = CGRectMake(290.0, 16.0, 24.0, 24.0);
	[likesButton setBackgroundImage:[UIImage imageNamed:@"likeIcon"] forState:UIControlStateNormal];
	[likesButton setBackgroundImage:[UIImage imageNamed:@"likeIcon"] forState:UIControlStateHighlighted];
	[footerHolderView addSubview:likesButton];
	
	NSLog(@"TIMELINE:[%d]", [[[NSUserDefaults standardUserDefaults] objectForKey:@"timeline_total"] intValue]);
	
	UIImageView *tapHoldImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tapHoldOverlay_nonActive"]];
	tapHoldImageView.hidden = [[[NSUserDefaults standardUserDefaults] objectForKey:@"timeline_total"] intValue] >= 0;
	[self addSubview:tapHoldImageView];
}


#pragma mark - Navigation
- (void)_goMore {
	
}

- (void)_goDetails {
	UIView *tappedOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.frame.size.height)];
	tappedOverlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.85];
	[self.contentView addSubview:tappedOverlayView];
	
	[self.delegate timelineItemViewCell:self showChallenge:_challengeVO];
	
	[UIView animateWithDuration:0.125 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		tappedOverlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[tappedOverlayView removeFromSuperview];
	}];
}

- (void)_goHeroProfile {
	[self.delegate timelineItemViewCell:self showProfileForUserID:_heroOpponentVO.userID forChallenge:_challengeVO];
}

- (void)_goJoinChallenge {
	UIView *tappedOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.frame.size.height)];
	tappedOverlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.85];
	[self.contentView addSubview:tappedOverlayView];
	
	[self.delegate timelineItemViewCell:self joinChallenge:_challengeVO];
	
	[UIView animateWithDuration:0.125 animations:^(void) {
		tappedOverlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[tappedOverlayView removeFromSuperview];
	}];
}

- (void)_goComments {
	[self.delegate timelineItemViewCell:self showComments:_challengeVO];
}

- (void)_goScore {
	[self.delegate timelineItemViewCell:self showVoters:_challengeVO];
}

#pragma mark - UI Presentation
- (void)_reloadHeroImage {
	__weak typeof(self) weakSelf = self;
	
	//HONOpponentVO *vo = (_opponentCounter == 0) ? _challengeVO.creatorVO : (HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0];
	
	_heroImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-25.0, 0.0, 370.0, 370.0)];
	_heroImageView.alpha = 0.0;
	[_heroImageHolderView addSubview:_heroImageView];
	[_heroImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", _heroOpponentVO.imagePrefix]]
																		cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
									  placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
										  weakSelf.heroImageView.image = image;
										  [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.heroImageView.alpha = 1.0; } completion:nil];
									  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
										  NSLog(@"%@_l.jpg", weakSelf.challengeVO.creatorVO.imagePrefix);
									  }];
}

-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint touchPoint = [lpGestureRecognizer locationInView:self];
		NSLog(@"TOUCH:%@", NSStringFromCGPoint(touchPoint));
		
		CGRect creatorFrame = CGRectMake(_heroImageHolderView.frame.origin.x, _heroImageHolderView.frame.origin.y, _heroImageHolderView.frame.size.width, _heroImageHolderView.frame.size.height);
		if (CGRectContainsPoint(creatorFrame, touchPoint))
			[self.delegate timelineItemViewCell:self showPreview:_heroOpponentVO forChallenge:_challengeVO];
		
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
		[self.delegate timelineItemViewCellHidePreview:self];
	}
}

- (void)showTapOverlay {
	UIView *tappedOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.frame.size.height)];
	tappedOverlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.85];
	[self.contentView addSubview:tappedOverlayView];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		tappedOverlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[tappedOverlayView removeFromSuperview];
	}];
}

- (int)_calcScore {
	int score = _challengeVO.creatorVO.score;
	for (HONOpponentVO *vo in _challengeVO.challengers)
		score += vo.score;
	
	return (score);
}


@end

