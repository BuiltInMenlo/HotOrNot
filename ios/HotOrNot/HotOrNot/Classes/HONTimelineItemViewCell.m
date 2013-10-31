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
#import "HONHeroFooterView.h"
#import "HONVoterVO.h"
#import "HONUserVO.h"
#import "HONOpponentVO.h"


@interface HONTimelineItemViewCell() <HONHeroFooterViewDelegate>
@property (nonatomic, strong) UIView *heroHolderView;
@property (nonatomic, strong) UIImageView *heroImageView;
@property (nonatomic, strong) UILabel *commentsLabel;
@property (nonatomic, strong) UIImageView *upvoteImageView;
@property (nonatomic, strong) NSMutableArray *voters;
@property (nonatomic, strong) HONHeroFooterView *heroFooterView;
@property (nonatomic, strong) HONOpponentVO *heroOpponentVO;

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
	
	[_heroFooterView updateLikesCaption:(_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score > 99) ? @"99+" : [NSString stringWithFormat:@"%d", (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score)]];
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
	
	_heroOpponentVO = _challengeVO.creatorVO;
	int heroTime = [_heroOpponentVO.joinedDate timeIntervalSinceNow];
	int participant0Time = -1;
	
	if ([_challengeVO.challengers count] > 0) {
		participant0Time = [((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0]).joinedDate timeIntervalSinceNow];
		
		if (participant0Time > heroTime && !_challengeVO.isCelebCreated && !_challengeVO.isExploreChallenge)
			_heroOpponentVO = (HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0];
	}
	
//	NSLog(@"HERO:[%d][%@]", heroTime, [dateFormat stringFromDate:_heroOpponentVO.joinedDate]);
//	NSLog(@"OPP1:[%d][%@]", participant0Time, [dateFormat stringFromDate:((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0]).joinedDate]);
	_heroHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kHeroVolleyTableCellHeight)];
	_heroHolderView.clipsToBounds = YES;
	_heroHolderView.backgroundColor = [UIColor blackColor];
	[self.contentView addSubview:_heroHolderView];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:_heroHolderView];
	[imageLoadingView startAnimating];
	[_heroHolderView addSubview:imageLoadingView];
	
//	NSLog(@"\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\nCHALLENGE DICT:[%@]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n", _challengeVO.dictionary);
//	NSLog(@"HERO DICT:[%@]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n\n", _heroOpponentVO.dictionary);
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_heroImageView.image = image;
		[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_heroImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RECREATE_IMAGE_SIZES" object:[NSString stringWithFormat:@"%@Large_640x1136.jpg", _heroOpponentVO.imagePrefix]];
	};
	
	_heroImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 568.0)];
	_heroImageView.userInteractionEnabled = YES;
	_heroImageView.alpha = 0.0;
	[_heroHolderView addSubview:_heroImageView];
	[_heroImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@Large_640x1136.jpg", _heroOpponentVO.imagePrefix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
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
	
	UIImageView *gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timelineImageFade"]];
	gradientImageView.frame = CGRectOffset(gradientImageView.frame, 0.0, kHeroVolleyTableCellHeight - gradientImageView.frame.size.height);
	[self.contentView addSubview:gradientImageView];
	
	_heroFooterView = [[HONHeroFooterView alloc] initAtYPos:kHeroVolleyTableCellHeight - 94.0 withChallenge:_challengeVO andHeroOpponent:_heroOpponentVO];
	_heroFooterView.delegate = self;
	[self.contentView addSubview:_heroFooterView];
	
	UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
	joinButton.frame = CGRectMake(246.0, kHeroVolleyTableCellHeight - 114.0, 74.0, 74.0);
	[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_nonActive"] forState:UIControlStateNormal];
	[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_Active"] forState:UIControlStateHighlighted];
	[joinButton addTarget:self action:@selector(_goJoinChallenge) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:joinButton];
	
	UIImageView *heroBubbleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[HONAppDelegate hasTakenSelfie] ? @"tapHoldOverlay_nonActive" : @"needSelfieHeroBubble"]];
	heroBubbleImageView.hidden = ([HONAppDelegate hasTakenSelfie] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"timeline_total"] intValue] >= 0);
	[self addSubview:heroBubbleImageView];
}


#pragma mark - Navigation
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
-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint touchPoint = [lpGestureRecognizer locationInView:self];
		NSLog(@"TOUCH:%@", NSStringFromCGPoint(touchPoint));
		
		CGRect creatorFrame = CGRectMake(_heroHolderView.frame.origin.x, _heroHolderView.frame.origin.y, _heroHolderView.frame.size.width, _heroHolderView.frame.size.height);
		if (CGRectContainsPoint(creatorFrame, touchPoint))
			[self.delegate timelineItemViewCell:self showPreview:_heroOpponentVO forChallenge:_challengeVO];
		
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
//		[self.delegate timelineItemViewCellShowPreviewControls:self];
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


#pragma mark - HeroFooterView Delegates
- (void)heroFooterView:(HONHeroFooterView *)heroFooterView showProfile:(HONOpponentVO *)heroOpponentVO {
	NSLog(@"heroFooterView:showProfile");
	
	[self.delegate timelineItemViewCell:self showProfileForUserID:heroOpponentVO.userID forChallenge:_challengeVO];
}


@end

