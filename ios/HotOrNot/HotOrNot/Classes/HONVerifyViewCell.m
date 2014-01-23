//
//  HONVerifyViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 11/1/13 @ 12:52 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONVerifyViewCell.h"
#import "HONAPICaller.h"
#import "HONVerifyCellHeaderView.h"
#import "HONOpponentVO.h"
#import "HONImageLoadingView.h"


@interface HONVerifyViewCell() <HONVerifyCellHeaderViewDelegate>
@property (nonatomic, strong) UIView *imageHolderView;
@property (nonatomic, strong) UIImageView *heroImageView;
@property (nonatomic, strong) UIView *tappedOverlayView;
@end

@implementation HONVerifyViewCell
@synthesize delegate = _delegate;
@synthesize challengeVO = _challengeVO;
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
				
//			if ([HONAppDelegate isRetina4Inch]) {
			[UIView animateWithDuration:0.25 animations:^(void) {
				_heroImageView.alpha = 1.0;
			} completion:^(BOOL finished) {
				[imageLoadingView stopAnimating];
				[imageLoadingView removeFromSuperview];
			}];
		
//			} else
//				gradientImageView.alpha = 1.0;
		};
		
		//NSLog(@"CREATOR IMAGE:[%@]", [challengeVO.creatorVO.imagePrefix stringByAppendingString:kSnapLargeSuffix]);
		void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			[[HONAPICaller sharedInstance] notifyToCreateImageSizesForURL:challengeVO.creatorVO.imagePrefix forAvatarBucket:YES completion:nil];
		};
		
		[_heroImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[challengeVO.creatorVO.imagePrefix stringByAppendingString:([HONAppDelegate isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							  placeholderImage:nil
									   success:successBlock
									   failure:failureBlock];
		
		HONVerifyCellHeaderView *headerView = [[HONVerifyCellHeaderView alloc] initWithOpponent:_challengeVO.creatorVO];
		headerView.frame = CGRectOffset(headerView.frame, 0.0, 64.0);
		headerView.delegate = self;
		[self.contentView addSubview:headerView];
		
		
		UIView *buttonHolderView = [[UIView alloc] initWithFrame:CGRectMake(239.0, [UIScreen mainScreen].bounds.size.height - 210.0, 64.0, 142.0)];
		[self.contentView addSubview:buttonHolderView];
		
		UIButton *approveButton = [UIButton buttonWithType:UIButtonTypeCustom];
		approveButton.frame = CGRectMake(0.0, 0.0, 64.0, 64.0);
		[approveButton setBackgroundImage:[UIImage imageNamed:@"yayButton_nonActive"] forState:UIControlStateNormal];
		[approveButton setBackgroundImage:[UIImage imageNamed:@"yayButton_Active"] forState:UIControlStateHighlighted];
		[approveButton addTarget:self action:@selector(_goApprove) forControlEvents:UIControlEventTouchUpInside];
		[buttonHolderView addSubview:approveButton];
		
		UIButton *dispproveButton = [UIButton buttonWithType:UIButtonTypeCustom];
		dispproveButton.frame = CGRectMake(0.0, 78.0, 64.0, 64.0);
		[dispproveButton setBackgroundImage:[UIImage imageNamed:@"nayButton_nonActive"] forState:UIControlStateNormal];
		[dispproveButton setBackgroundImage:[UIImage imageNamed:@"nayButton_Active"] forState:UIControlStateHighlighted];
		[dispproveButton addTarget:self action:@selector(_goDisprove) forControlEvents:UIControlEventTouchUpInside];
		[buttonHolderView addSubview:dispproveButton];
		
		
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


#pragma mark - Navigation
- (void)_goApprove {
	[self.delegate verifyViewCellApprove:self forChallenge:_challengeVO];
}

- (void)_goDisprove {
	[self.delegate verifyViewCellDisprove:self forChallenge:_challengeVO];
}

- (void)_goUserProfile {
	[self.delegate verifyViewCell:self creatorProfile:_challengeVO];
}


#pragma mark - UI Presentation
-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan)
		[self.delegate verifyViewCell:self creatorProfile:_challengeVO];
	
	else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
	}
}


#pragma mark - VerifyCellHeader Delegates
- (void)cellHeaderView:(HONVerifyCellHeaderView *)cell showProfileForUser:(HONOpponentVO *)opponentVO {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Follow A/B - Header Show Profile%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", opponentVO.userID, opponentVO.username], @"opponent", nil]];
	
	[self.delegate verifyViewCell:self creatorProfile:_challengeVO];
}

@end
