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
#import "HONTimelineCreatorHeaderView.h"
#import "HONTimelineItemFooterView.h"
#import "HONVoterVO.h"
#import "HONUserVO.h"
#import "HONOpponentVO.h"


@interface HONTimelineItemViewCell() <HONTimelineHeaderCreatorViewDelegate, HONTimelineItemFooterViewDelegate>
@property (nonatomic, strong) UIView *heroHolderView;
@property (nonatomic, strong) UIImageView *heroImageView;
@property (nonatomic, strong) UILabel *commentsLabel;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) NSMutableArray *voters;
@property (nonatomic, strong) HONTimelineItemFooterView *timelineItemFooterView;
@property (nonatomic, strong) HONOpponentVO *heroOpponentVO;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@end

@implementation HONTimelineItemViewCell
@synthesize delegate = _delegate;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		self.backgroundColor = [UIColor whiteColor];
		[self.contentView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timelineBackground"]]];
	}
	
	return (self);
}


#pragma mark - Data Calls


#pragma mark - Public APIs
- (void)upvoteUser:(int)userID onChallenge:(HONChallengeVO *)challengeVO {
	[_timelineItemFooterView upvoteUser:userID onChallenge:challengeVO];
}

- (void)removeTutorialBubble {
	if (_tutorialImageView != nil) {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_tutorialImageView.alpha = 0.0;
		} completion:^(BOOL finished) {
			[_tutorialImageView removeFromSuperview];
			_tutorialImageView = nil;
		}];
	}
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
	
	_heroOpponentVO = _challengeVO.creatorVO;
//	int heroTime = [_heroOpponentVO.joinedDate timeIntervalSinceNow];
//	int participant0Time = -1;
//	
//	if ([_challengeVO.challengers count] > 0) {
//		participant0Time = [((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0]).joinedDate timeIntervalSinceNow];
//		
//		if (participant0Time > heroTime && !_challengeVO.isCelebCreated && !_challengeVO.isExploreChallenge)
//			_heroOpponentVO = (HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0];
//	}
	
	_heroHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapLargeSize.width, kSnapLargeSize.height)];
//	_heroHolderView.clipsToBounds = YES;
	_heroHolderView.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:_heroHolderView];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:_heroHolderView asLargeLoader:NO];
	[imageLoadingView startAnimating];
	[_heroHolderView addSubview:imageLoadingView];
	
//	NSLog(@"\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\nCHALLENGE DICT:[%@]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n", _challengeVO.dictionary);
//	NSLog(@"HERO DICT:[%@]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n\n", _heroOpponentVO.dictionary);
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_heroImageView.image = image;
		
		UIImageView *gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"homeOverlay"]];
		gradientImageView.alpha = 0.0;
//		[_heroHolderView addSubview:gradientImageView];
		
		if ([HONAppDelegate isRetina4Inch]) {
			[UIView animateWithDuration:0.5 animations:^(void) {
				_heroImageView.alpha = 1.0;
				gradientImageView.alpha = 1.0;
			} completion:^(BOOL finished) {
			}];
		}
	};
	
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RECREATE_IMAGE_SIZES" object:[NSString stringWithFormat:@"%@%@", _heroOpponentVO.imagePrefix, kSnapLargeSuffix]];
		_heroImageView.frame = CGRectMake(_heroImageView.frame.origin.x, _heroImageView.frame.origin.y, kSnapLargeSize.width, kSnapLargeSize.height);
		[_heroImageView setImageWithURL:[NSURL URLWithString:[_heroOpponentVO.imagePrefix stringByAppendingString:kSnapLargeSuffix]] placeholderImage:nil];
	};
	
	_heroImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_heroImageView.userInteractionEnabled = YES;
	_heroImageView.alpha = 1.0 - ((int)[HONAppDelegate isRetina4Inch]);
	[_heroHolderView addSubview:_heroImageView];
	[_heroImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_heroOpponentVO.imagePrefix stringByAppendingString:([HONAppDelegate isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
								placeholderImage:nil
								   success:successBlock
								   failure:failureBlock];
	
	UIButton *detailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	detailsButton.frame = _heroHolderView.frame;
	[detailsButton addTarget:self action:@selector(_goDetails) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:detailsButton];
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	lpGestureRecognizer.minimumPressDuration = 0.25;
	[self addGestureRecognizer:lpGestureRecognizer];
	
	HONTimelineCreatorHeaderView *creatorHeaderView = [[HONTimelineCreatorHeaderView alloc] initWithChallenge:_challengeVO];
	creatorHeaderView.frame = CGRectOffset(creatorHeaderView.frame, 0.0, 64.0);
	creatorHeaderView.delegate = self;
	[self.contentView addSubview:creatorHeaderView];
	
	_timelineItemFooterView = [[HONTimelineItemFooterView alloc] initAtPosY:[UIScreen mainScreen].bounds.size.height - 90.0 withChallenge:_challengeVO];
	_timelineItemFooterView.delegate = self;
	[self.contentView addSubview:_timelineItemFooterView];
	
	UIView *buttonHolderView = [[UIView alloc] initWithFrame:CGRectMake(244.0, [UIScreen mainScreen].bounds.size.height - 199.0, 64.0, 149.0)];
	[self.contentView addSubview:buttonHolderView];
	
	UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
	joinButton.frame = CGRectMake(0.0, 0.0, 64.0, 64.0);
	[joinButton setBackgroundImage:[UIImage imageNamed:@"replyButton_nonActive"] forState:UIControlStateNormal];
	[joinButton setBackgroundImage:[UIImage imageNamed:@"replyButton_Active"] forState:UIControlStateHighlighted];
	[joinButton addTarget:self action:@selector(_goJoinChallenge) forControlEvents:UIControlEventTouchUpInside];
	[buttonHolderView addSubview:joinButton];
	
	_likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_likeButton.frame = CGRectMake(0.0, 68.0, 64.0, 64.0);
	[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive"] forState:UIControlStateNormal];
	[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active"] forState:UIControlStateHighlighted];
	[_likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Tapped"] forState:UIControlStateSelected];
	[_likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	[buttonHolderView addSubview:_likeButton];
	
	if ([HONAppDelegate totalForCounter:@"timeline"] == 0) {
		_tutorialImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_home"]];
		_tutorialImageView.frame = CGRectOffset(_tutorialImageView.frame, 0.0, [UIScreen mainScreen].bounds.size.height - 143.0);
//		[self.contentView addSubview:_tutorialImageView];
	}
}


#pragma mark - Navigation
- (void)_goDetails {
	UIView *tappedOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, _heroHolderView.frame.size.height)];
	tappedOverlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.85];
	[self.contentView addSubview:tappedOverlayView];
	
	[self.delegate timelineItemViewCell:self showChallenge:_challengeVO];
	
	[UIView animateWithDuration:0.125 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		tappedOverlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[tappedOverlayView removeFromSuperview];
	}];
}

- (void)_goJoinChallenge {
	UIView *tappedOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, _heroHolderView.frame.size.height)];
	tappedOverlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.85];
	[self.contentView addSubview:tappedOverlayView];
	
	[self.delegate timelineItemViewCell:self joinChallenge:_challengeVO];
	
	[UIView animateWithDuration:0.125 animations:^(void) {
		tappedOverlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[tappedOverlayView removeFromSuperview];
	}];
}

- (void)_goLike {
	[_likeButton removeTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	[_likeButton setSelected:YES];
	
	[self.delegate timelineItemViewCell:self upvoteCreatorForChallenge:_challengeVO];
}

- (void)_goComments {
	[self.delegate timelineItemViewCell:self showComments:_challengeVO];
}

- (void)_goScore {
	[self.delegate timelineItemViewCell:self showVoters:_challengeVO];
}

#pragma mark - UI Presentation
-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint touchPoint = [lpGestureRecognizer locationInView:self];
		NSLog(@"TOUCH:%@", NSStringFromCGPoint(touchPoint));
		
		CGRect creatorFrame = CGRectMake(_heroHolderView.frame.origin.x, _heroHolderView.frame.origin.y, _heroHolderView.frame.size.width, _heroHolderView.frame.size.height);
		if (CGRectContainsPoint(creatorFrame, touchPoint))
			[self.delegate timelineItemViewCell:self showPreview:_heroOpponentVO forChallenge:_challengeVO];
		
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
	}
}

- (void)showTapOverlay {
	UIView *tappedOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, _heroHolderView.frame.size.height)];
	tappedOverlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.85];
	[self.contentView addSubview:tappedOverlayView];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		tappedOverlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[tappedOverlayView removeFromSuperview];
	}];
}


#pragma mark - TimelineHeaderCreator Delegates
- (void)timelineHeaderView:(HONTimelineCreatorHeaderView *)cell showProfile:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline Header - Show Profile%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", opponentVO.userID, opponentVO.username], @"participant", nil]];
	
	[self.delegate timelineItemViewCell:self showProfileForUserID:opponentVO.userID forChallenge:challengeVO];
}


#pragma mark - TimelineItemFooter Delegates
- (void)footerView:(HONTimelineItemFooterView *)cell joinChallenge:(HONChallengeVO *)challengeVO {
	[self _goJoinChallenge];
}

- (void)footerView:(HONTimelineItemFooterView *)cell showDetailsForChallenge:(HONChallengeVO *)challengeVO {
	[self _goDetails];
}

- (void)footerView:(HONTimelineItemFooterView *)cell showProfileForParticipant:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	[self.delegate timelineItemViewCell:self showProfileForUserID:opponentVO.userID forChallenge:_challengeVO];
}


#pragma mark - Data Tally
- (int)_calcScore {
	int score = _challengeVO.creatorVO.score;
	for (HONOpponentVO *vo in _challengeVO.challengers)
		score += vo.score;
	
	return (score);
}

- (NSString *)_captionForScore {
	int score = _challengeVO.creatorVO.score;
	for (HONOpponentVO *vo in _challengeVO.challengers)
		score += vo.score;
	
	
	if (score == 0)
		return (@"Be the first to like");
	
	else if (score > 99)
		return (@"99+");
	
	else
		return ([NSString stringWithFormat:@"%d", score]);
}


@end

