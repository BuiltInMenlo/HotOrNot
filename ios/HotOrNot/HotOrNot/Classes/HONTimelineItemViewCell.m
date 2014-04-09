//
//  HONTimelineItemViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import "UIImageView+AFNetworking.h"

#import "HONTimelineItemViewCell.h"
#import "HONAPICaller.h"
#import "HONDeviceTraits.h"
#import "HONImageLoadingView.h"
#import "HONTimelineCellHeaderView.h"
#import "HONTimelineCellSubjectView.h"
#import "HONVoterVO.h"
#import "HONUserVO.h"
#import "HONOpponentVO.h"


@interface HONTimelineItemViewCell() <HONTimelineCellHeaderViewDelegate, HONTimelineCellSubjectViewDelegate>
@property (nonatomic, strong) UIView *heroHolderView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIImageView *heroImageView;
@property (nonatomic, strong) UILabel *commentsLabel;
@property (nonatomic, strong) NSMutableArray *voters;
@property (nonatomic, strong) HONOpponentVO *heroOpponentVO;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic) BOOL isBanner;
@end

@implementation HONTimelineItemViewCell
@synthesize delegate = _delegate;
@synthesize challengeVO = _challengeVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initAsBannerCell:(BOOL)isBanner {
	if ((self = [super init])) {
		_isBanner = isBanner;
		self.backgroundColor = [UIColor whiteColor];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)updateChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
	
	_heroOpponentVO = _challengeVO.creatorVO;
	_heroHolderView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_heroHolderView.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:_heroHolderView];
	
	UIImageView *gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selfieFullSizeGradientOverlay"]];
	gradientImageView.frame = _heroHolderView.frame;
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:_heroHolderView asLargeLoader:NO];
	imageLoadingView.frame = CGRectOffset(imageLoadingView.frame, 0.0, 40.0);
	[imageLoadingView startAnimating];
	[_heroHolderView addSubview:imageLoadingView];
	
//	NSLog(@"\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\nCHALLENGE DICT:[%@]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n", _challengeVO.dictionary);
//	NSLog(@"HERO DICT:[%@]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n\n", _heroOpponentVO.dictionary);
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_heroImageView.image = image;
		[_heroImageView addSubview:gradientImageView];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
		} completion:^(BOOL finished) {
			[imageLoadingView stopAnimating];
			[imageLoadingView removeFromSuperview];
		}];
	};
	
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:_heroOpponentVO.imagePrefix forBucketType:HONS3BucketTypeSelfies completion:nil];
		_heroImageView.frame = CGRectMake(_heroImageView.frame.origin.x, _heroImageView.frame.origin.y, kSnapLargeSize.width, kSnapLargeSize.height);
		[_heroImageView setImageWithURL:[NSURL URLWithString:[_heroOpponentVO.imagePrefix stringByAppendingString:kSnapLargeSuffix]] placeholderImage:nil];
		[_heroImageView addSubview:gradientImageView];
	};
	
	_heroImageView = [[UIImageView alloc] initWithFrame:_heroHolderView.frame];
	_heroImageView.userInteractionEnabled = YES;
	[_heroHolderView addSubview:_heroImageView];
	[_heroImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_heroOpponentVO.imagePrefix stringByAppendingString:([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
								placeholderImage:nil
								   success:successBlock
								   failure:failureBlock];
	
	HONTimelineCellSubjectView *timelineCellSubjectView = [[HONTimelineCellSubjectView alloc] initAtOffsetY:([UIScreen mainScreen].bounds.size.height - 169.0) withSubjectName:_challengeVO.subjectName withUsername:_challengeVO.creatorVO.username];
	timelineCellSubjectView.delegate = self;
	[self.contentView addSubview:timelineCellSubjectView];
	
	
	UIButton *detailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	detailsButton.frame = _heroHolderView.frame;
	[detailsButton addTarget:self action:@selector(_goDetails) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:detailsButton];
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	lpGestureRecognizer.minimumPressDuration = 0.25;
	[self addGestureRecognizer:lpGestureRecognizer];
	
	
	HONTimelineCellHeaderView *creatorHeaderView = [[HONTimelineCellHeaderView alloc] initWithChallenge:_challengeVO];
	creatorHeaderView.frame = CGRectOffset(creatorHeaderView.frame, 0.0, 35.0);
	creatorHeaderView.delegate = self;
	[self.contentView addSubview:creatorHeaderView];
	
	
	_footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 103.0, 320.0, 44.0)];
	[self.contentView addSubview:_footerView];
	
	UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareButton.frame = CGRectMake(2.0, 0.0, 94.0, 44.0);
	[shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_nonActive"] forState:UIControlStateNormal];
	[shareButton setBackgroundImage:[UIImage imageNamed:@"shareButton_Active"] forState:UIControlStateHighlighted];
	[shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	[_footerView addSubview:shareButton];
	
	
	NSDictionary *sticker = [HONAppDelegate stickerForSubject:_challengeVO.subjectName];
	
	if (sticker != nil) {
//		NSLog(@"STICKER:[%@]", [[[sticker objectForKey:@"img"] stringByAppendingString:([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix] stringByReplacingOccurrencesOfString:@".jpg" withString:@".png"]);
		UIImageView *stickerImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		[stickerImageView setImageWithURL:[NSURL URLWithString:[[[sticker objectForKey:@"img"] stringByAppendingString:([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix] stringByReplacingOccurrencesOfString:@".jpg" withString:@".png"]] placeholderImage:nil];
		[self.contentView addSubview:stickerImageView];
		
		if ([[sticker objectForKey:@"user_id"] intValue] != 0) {
			UIButton *stickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
			stickerButton.frame = stickerImageView.frame;
			[stickerButton setTag:[[sticker objectForKey:@"user_id"] intValue]];
			[stickerButton addTarget:self action:@selector(_goStickerProfile:) forControlEvents:UIControlEventTouchUpInside];
			[self.contentView addSubview:stickerButton];
		}
	}
	
	if (_isBanner) {
		_footerView.frame = CGRectOffset(_footerView.frame, 0.0, -80.0);
		
		UIImageView *bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 130.0, 320.0, 80.0)];
		[self.contentView addSubview:bannerImageView];
		
		void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			bannerImageView.image = image;
		};
		
		void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			bannerImageView.image = [UIImage imageNamed:@"banner_activity"];
		};
		
		[bannerImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://s3.amazonaws.com/hotornot-banners/banner_timeline.png"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							   placeholderImage:nil
										success:successBlock
										failure:failureBlock];
		
		UIButton *bannerButton = [UIButton buttonWithType:UIButtonTypeCustom];
		bannerButton.frame = bannerImageView.frame;
		[bannerButton addTarget:self action:@selector(_goBanner) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:bannerButton];
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


#pragma mark - Navigation
- (void)_goDetails {
//	UIView *tappedOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, _heroHolderView.frame.size.height)];
//	tappedOverlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
//	[self.contentView addSubview:tappedOverlayView];
//	
//	[UIView animateWithDuration:0.125 delay:0.125 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
//		tappedOverlayView.alpha = 0.0;
//	} completion:^(BOOL finished) {
//		[tappedOverlayView removeFromSuperview];
//	}];
	
	[self.delegate timelineItemViewCell:self showChallenge:_challengeVO];
}

- (void)_goShare {
	[self.delegate timelineItemViewCell:self shareChallenge:_challengeVO];
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

- (void)_goCreatorProfile {
	[self.delegate timelineItemViewCell:self showProfileForUserID:_challengeVO.creatorVO.userID forChallenge:_challengeVO];
}

- (void)_goBanner {
	[self.delegate timelineItemViewCell:self showBannerForChallenge:_challengeVO];
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


#pragma mark - TimelineCellHeaderCreator Delegates
- (void)timelineCellHeaderView:(HONTimelineCellHeaderView *)cell showProfile:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Timeline Header - Show Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", opponentVO.userID, opponentVO.username], @"participant", nil]];
	
	[self.delegate timelineItemViewCell:self showProfileForUserID:opponentVO.userID forChallenge:challengeVO];
}


#pragma mark - TimelineSubject Deletegates
- (void)timelineCellSubjectViewShowProfile:(HONTimelineCellSubjectView *)subjectView {
	[self _goCreatorProfile];
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

