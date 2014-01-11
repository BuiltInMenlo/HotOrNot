//
//  HONVerifyShoutoutViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONVerifyShoutoutViewCell.h"
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
	
	if (_isInviteCell)
		_imageHolderView.backgroundColor = [UIColor greenColor];
	
	else {
		HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:_imageHolderView asLargeLoader:NO];
		[imageLoadingView startAnimating];
		[_imageHolderView addSubview:imageLoadingView];
		
		_heroImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_heroImageView.userInteractionEnabled = YES;
		[_imageHolderView addSubview:_heroImageView];
		
		void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			//_heroImageView.alpha = 1.0 - ((int)[HONAppDelegate isRetina4Inch]);
			_heroImageView.alpha = (int)((request.URL == nil));// || (![HONAppDelegate isRetina4Inch]));
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
			[[NSNotificationCenter defaultCenter] postNotificationName:@"RECREATE_IMAGE_SIZES" object:challengeVO.creatorVO.imagePrefix];
		};
		
		[_heroImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[challengeVO.creatorVO.imagePrefix stringByAppendingString:([HONAppDelegate isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							  placeholderImage:nil
									   success:successBlock
									   failure:failureBlock];
		
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
		
		UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
		moreButton.frame = CGRectMake(13.0, [UIScreen mainScreen].bounds.size.height - 95.0, 44.0, 44.0);
		[moreButton setBackgroundImage:[UIImage imageNamed:@"verifyMoreButton_nonActive"] forState:UIControlStateNormal];
		[moreButton setBackgroundImage:[UIImage imageNamed:@"verifyMoreButton_Active"] forState:UIControlStateHighlighted];
		[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:moreButton];
		
		if (![HONAppDelegate hasTakenSelfie])
			[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"needSelfieHeroBubble"]]];
		
		
		UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
		lpGestureRecognizer.minimumPressDuration = 0.25;
		[_imageHolderView addGestureRecognizer:lpGestureRecognizer];
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

- (void)tintMe {
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


#pragma mark - UI Presentation
-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan)
		[self.delegate verifyShoutoutViewCell:self creatorProfile:_challengeVO];
		
	else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
	}
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
