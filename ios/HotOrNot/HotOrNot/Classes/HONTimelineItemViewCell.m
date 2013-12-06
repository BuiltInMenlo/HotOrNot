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


#pragma mark - Public APIs
- (void)updateChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[_timelineItemFooterView updateChallenge:_challengeVO];
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
	_heroHolderView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_heroHolderView.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:_heroHolderView];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:_heroHolderView asLargeLoader:NO];
	imageLoadingView.frame = CGRectOffset(imageLoadingView.frame, 0.0, 40.0);
	[imageLoadingView startAnimating];
	[_heroHolderView addSubview:imageLoadingView];
	
//	NSLog(@"\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\nCHALLENGE DICT:[%@]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n", _challengeVO.dictionary);
//	NSLog(@"HERO DICT:[%@]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n\n", _heroOpponentVO.dictionary);
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		//_heroImageView.alpha = 1.0 - ((int)[HONAppDelegate isRetina4Inch]);
		_heroImageView.alpha = (int)((request.URL == nil));// || (![HONAppDelegate isRetina4Inch]));
		_heroImageView.image = image;
		
//		if ([HONAppDelegate isRetina4Inch]) {
			[UIView animateWithDuration:0.25 animations:^(void) {
				_heroImageView.alpha = 1.0;
			} completion:^(BOOL finished) {
				[imageLoadingView stopAnimating];
				[imageLoadingView removeFromSuperview];
			}];
//		}
	};
	
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RECREATE_IMAGE_SIZES" object:[NSString stringWithFormat:@"%@%@", _heroOpponentVO.imagePrefix, kSnapLargeSuffix]];
		_heroImageView.frame = CGRectMake(_heroImageView.frame.origin.x, _heroImageView.frame.origin.y, kSnapLargeSize.width, kSnapLargeSize.height);
		[_heroImageView setImageWithURL:[NSURL URLWithString:[_heroOpponentVO.imagePrefix stringByAppendingString:kSnapLargeSuffix]] placeholderImage:nil];
	};
	
	_heroImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_heroImageView.userInteractionEnabled = YES;
//	_heroImageView.alpha = 1.0 - ((int)[HONAppDelegate isRetina4Inch]);
	[_heroHolderView addSubview:_heroImageView];
	[_heroImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_heroOpponentVO.imagePrefix stringByAppendingString:([HONAppDelegate isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
								placeholderImage:nil
								   success:successBlock
								   failure:failureBlock];
	
	UIButton *detailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	detailsButton.frame = _heroHolderView.frame;
	[detailsButton addTarget:self action:@selector(_goDetails) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:detailsButton];
	
	UIImageView *subjectBGImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"captionBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 24.0, 0.0, 24.0)]];
	[self.contentView addSubview:subjectBGImageView];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 280.0, subjectBGImageView.frame.size.height)];
	subjectLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:22];
	subjectLabel.textColor = [UIColor whiteColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.textAlignment = NSTextAlignmentCenter;
	subjectLabel.text = _challengeVO.subjectName;
	[subjectBGImageView addSubview:subjectLabel];
	
	float maxWidth = 280.0;
	CGSize size = [[NSString stringWithFormat:@"  %@  ", subjectLabel.text] boundingRectWithSize:CGSizeMake(maxWidth, 44.0)
																						 options:NSStringDrawingTruncatesLastVisibleLine
																					  attributes:@{NSFontAttributeName:subjectLabel.font}
																						 context:nil].size;
	if (size.width > maxWidth)
		size = CGSizeMake(maxWidth + 15.0, size.height);
	
	subjectLabel.frame = CGRectMake(subjectLabel.frame.origin.x, subjectLabel.frame.origin.y - 2.0, size.width, subjectLabel.frame.size.height);
	subjectBGImageView.frame = CGRectMake(160.0 - (size.width * 0.5), (5.0 + ([UIScreen mainScreen].bounds.size.height - 44.0) * 0.5), size.width, 44.0);
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	lpGestureRecognizer.minimumPressDuration = 0.25;
	[self addGestureRecognizer:lpGestureRecognizer];
	
	
	HONTimelineCreatorHeaderView *creatorHeaderView = [[HONTimelineCreatorHeaderView alloc] initWithChallenge:_challengeVO];
	creatorHeaderView.frame = CGRectOffset(creatorHeaderView.frame, 0.0, 64.0);
	creatorHeaderView.delegate = self;
	[self.contentView addSubview:creatorHeaderView];
	
	_timelineItemFooterView = [[HONTimelineItemFooterView alloc] initAtPosY:[UIScreen mainScreen].bounds.size.height - 106.0 withChallenge:_challengeVO];
	_timelineItemFooterView.delegate = self;
	[self.contentView addSubview:_timelineItemFooterView];
	
	NSDictionary *sticker = [HONAppDelegate stickerForSubject:_challengeVO.subjectName];
	if (sticker != nil) {
//		UIImageView *stickerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 183.0, 94.0, 94.0)];
//		[stickerImageView setImageWithURL:[NSURL URLWithString:[[sticker objectForKey:@"img"] stringByAppendingString:@"_188x188.png"]] placeholderImage:nil];
		
		UIImageView *stickerImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		[stickerImageView setImageWithURL:[NSURL URLWithString:[[[sticker objectForKey:@"img"] stringByAppendingString:([HONAppDelegate isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix] stringByReplacingOccurrencesOfString:@".jpg" withString:@".png"]] placeholderImage:nil];
		[self.contentView addSubview:stickerImageView];
		
//		UIButton *stickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		stickerButton.frame = stickerImageView.frame;
//		[stickerButton setTag:[[sticker objectForKey:@"user_id"] intValue]];
//		[stickerButton addTarget:self action:@selector(_goStickerProfile:) forControlEvents:UIControlEventTouchUpInside];
//		[self.contentView addSubview:stickerButton];
	}
}


#pragma mark - Navigation
- (void)_goDetails {
	UIView *tappedOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, _heroHolderView.frame.size.height)];
	tappedOverlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	[self.contentView addSubview:tappedOverlayView];
	
	[UIView animateWithDuration:0.125 delay:0.125 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		tappedOverlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[tappedOverlayView removeFromSuperview];
	}];
	
	[self.delegate timelineItemViewCell:self showChallenge:_challengeVO];
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
	[self.delegate timelineItemViewCell:self upvoteCreatorForChallenge:_challengeVO];
}

- (void)_goComments {
	[self.delegate timelineItemViewCell:self showComments:_challengeVO];
}

- (void)_goScore {
	[self.delegate timelineItemViewCell:self showVoters:_challengeVO];
}

- (void)_goStickerProfile:(id)sender {
	UIButton *button = (UIButton *)sender;
	[self.delegate timelineItemViewCell:self showProfileForUserID:button.tag forChallenge:_challengeVO];
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

- (void)footerView:(HONTimelineItemFooterView *)cell likeChallenge:(HONChallengeVO *)challengeVO {
	[self _goLike];
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

