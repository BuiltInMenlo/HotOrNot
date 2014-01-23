//
//  HONVerifyShoutoutViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONVerifyShoutoutViewCell.h"
#import "HONAPICaller.h"
#import "HONDeviceTraits.h"
#import "HONOpponentVO.h"
#import "HONImageLoadingView.h"
#import "HONVerifyCellHeaderView.h"

@interface HONVerifyShoutoutViewCell() <HONVerifyCellHeaderViewDelegate>
@property (nonatomic, strong) UIView *imageHolderView;
@property (nonatomic, strong) UIImageView *heroImageView;
@property (nonatomic, strong) UIView *tappedOverlayView;
@end

@implementation HONVerifyShoutoutViewCell
@synthesize delegate = _delegate;
@synthesize challengeVO = _challengeVO;
@synthesize indexPath = _indexPath;
@synthesize isInviteCell = _isInviteCell;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initAsInviteCell:(BOOL)isInviteCell {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verifyRowBackground"]];
		_isInviteCell = isInviteCell;
	}
	
	return (self);
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	_imageHolderView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	[self.contentView addSubview:_imageHolderView];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:_imageHolderView asLargeLoader:NO];
	[imageLoadingView startAnimating];
	[_imageHolderView addSubview:imageLoadingView];
	
	_heroImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_heroImageView.userInteractionEnabled = YES;
	[_imageHolderView addSubview:_heroImageView];
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		//_heroImageView.alpha = 1.0 - ((int)[[HONDeviceTraits sharedInstance] isRetina4Inch]);
		_heroImageView.alpha = (int)((request.URL == nil));// || (![[HONDeviceTraits sharedInstance] isRetina4Inch]));
		_heroImageView.image = image;
				
		[UIView animateWithDuration:0.25 animations:^(void) {
			_heroImageView.alpha = 1.0;
		} completion:^(BOOL finished) {
			[imageLoadingView stopAnimating];
			[imageLoadingView removeFromSuperview];
		}];
	};
	
	//NSLog(@"CREATOR IMAGE:[%@]", [challengeVO.creatorVO.imagePrefix stringByAppendingString:kSnapLargeSuffix]);
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForURL:challengeVO.creatorVO.imagePrefix forAvatarBucket:YES completion:nil];
	};
	
	[_heroImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[challengeVO.creatorVO.imagePrefix stringByAppendingString:([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
						  placeholderImage:nil
								   success:successBlock
								   failure:failureBlock];
	
	
	UIButton *previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
	previewButton.frame = _heroImageView.frame;
	[previewButton addTarget:self action:@selector(_goPreview) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:previewButton];
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	lpGestureRecognizer.minimumPressDuration = 0.25;
	[_imageHolderView addGestureRecognizer:lpGestureRecognizer];
	
	
	HONVerifyCellHeaderView *headerView = [[HONVerifyCellHeaderView alloc] initWithOpponent:_challengeVO.creatorVO];
	headerView.frame = CGRectOffset(headerView.frame, 0.0, 64.0);
	headerView.delegate = self;
	[self.contentView addSubview:headerView];
	
	UIView *buttonHolderView = [[UIView alloc] initWithFrame:CGRectMake(239.0, [UIScreen mainScreen].bounds.size.height - 288.0, 64.0, 219.0)];
	[self.contentView addSubview:buttonHolderView];
	
	UIButton *approveButton = [UIButton buttonWithType:UIButtonTypeCustom];
	approveButton.frame = CGRectMake(0.0, 0.0, 64.0, 64.0);
	[approveButton setBackgroundImage:[UIImage imageNamed:@"yayVerifyButton_nonActive"] forState:UIControlStateNormal];
	[approveButton setBackgroundImage:[UIImage imageNamed:@"yayVerifyButton_Active"] forState:UIControlStateHighlighted];
	[approveButton addTarget:self action:@selector(_goApprove) forControlEvents:UIControlEventTouchUpInside];
	[buttonHolderView addSubview:approveButton];
	
	UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
	skipButton.frame = CGRectMake(0.0, 78.0, 64.0, 64.0);
	[skipButton setBackgroundImage:[UIImage imageNamed:@"nayVerifyButton_nonActive"] forState:UIControlStateNormal];
	[skipButton setBackgroundImage:[UIImage imageNamed:@"nayVerifyButton_Active"] forState:UIControlStateHighlighted];
	[skipButton addTarget:self action:@selector(_goSkip) forControlEvents:UIControlEventTouchUpInside];
	[buttonHolderView addSubview:skipButton];
	
	UIButton *shoutoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shoutoutButton.frame = CGRectMake(0.0, 155.0, 64.0, 64.0);
	[shoutoutButton setBackgroundImage:[UIImage imageNamed:@"shoutout_nonActive"] forState:UIControlStateNormal];
	[shoutoutButton setBackgroundImage:[UIImage imageNamed:@"shoutout_Active"] forState:UIControlStateHighlighted];
	[shoutoutButton addTarget:self action:@selector(_goShoutout) forControlEvents:UIControlEventTouchUpInside];
	[buttonHolderView addSubview:shoutoutButton];
	
	UIButton *followButton = [UIButton buttonWithType:UIButtonTypeCustom];
	followButton.frame = CGRectMake(11.0, [UIScreen mainScreen].bounds.size.height - 95.0, 94.0, 44.0);
	[followButton setBackgroundImage:[UIImage imageNamed:@"verifyMoreButton_nonActive"] forState:UIControlStateNormal];
	[followButton setBackgroundImage:[UIImage imageNamed:@"verifyMoreButton_Active"] forState:UIControlStateHighlighted];
	[followButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:followButton];
	
	if (![HONAppDelegate hasTakenSelfie])
		[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"needSelfieHeroBubble"]]];
	
	
	if (_isInviteCell) {
		buttonHolderView.frame = CGRectOffset(buttonHolderView.frame, 0.0, -80.0);
		followButton.frame = CGRectOffset(followButton.frame, 0.0, -80.0);
		
		UIImageView *bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 130.0, 320.0, 80.0)];
		[self.contentView addSubview:bannerImageView];
		
		void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			bannerImageView.image = image;
		};
		
		void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			bannerImageView.image = [UIImage imageNamed:@"banner_activity"];
		};
		
		[bannerImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://s3.amazonaws.com/hotornot-banners/banner_verify.png"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
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
	UIView *tappedOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.frame.size.height)];
	tappedOverlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.85];
	[self.contentView addSubview:tappedOverlayView];
	
	[UIView animateWithDuration:0.25 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		tappedOverlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[tappedOverlayView removeFromSuperview];
	}];
}


#pragma mark - Navigation
- (void)_goApprove {
	[self.delegate verifyShoutoutViewCellApprove:self forChallenge:_challengeVO];
}

- (void)_goSkip {
	[self.delegate verifyShoutoutViewCellSkip:self forChallenge:_challengeVO];
}

- (void)_goMore {
	[self.delegate verifyShoutoutViewCellMore:self forChallenge:_challengeVO];
}

- (void)_goShoutout {
	[self.delegate verifyShoutoutViewCellShoutout:self forChallenge:_challengeVO];
}

- (void)_goUserProfile {
	[self.delegate verifyShoutoutViewCell:self creatorProfile:_challengeVO];
}

- (void)_goPreview {
	[self.delegate verifyShoutoutViewCellShowPreview:self forChallenge:_challengeVO];
}

- (void)_goBanner {
	[self.delegate verifyShoutoutViewCellBanner:self forChallenge:_challengeVO];
}


#pragma mark - UI Presentation
-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan)
		[self.delegate verifyShoutoutViewCell:self creatorProfile:_challengeVO];
		
	else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
	}
}

- (void)_goTint {
	UIView *tintView = [[UIView alloc] initWithFrame:self.contentView.frame];
	[self.contentView addSubview:tintView];
	
	CGFloat hue = (((float)(arc4random() % RAND_MAX)) / RAND_MAX);
	CGFloat sat = MAX((((float)(arc4random() % RAND_MAX)) / RAND_MAX), (1/2));
	CGFloat bri = MAX((((float)(arc4random() % RAND_MAX)) / RAND_MAX), (2/3));
	UIColor *color = [UIColor colorWithHue:hue saturation:sat brightness:bri alpha:(2/3)];
	
	[UIView beginAnimations:@"fade" context:nil];
	[UIView setAnimationDuration:0.33];
	[self.contentView setBackgroundColor:color];
	[UIView commitAnimations];
}


#pragma mark - VerifyCellHeader Delegates
- (void)cellHeaderView:(HONVerifyCellHeaderView *)cell showProfileForUser:(HONOpponentVO *)opponentVO {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Follow A/B - Header Show Profile%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", opponentVO.userID, opponentVO.username], @"opponent", nil]];
	
	[self.delegate verifyShoutoutViewCell:self creatorProfile:_challengeVO];
}

@end
