//
//  HONVerifyViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONVerifyViewCell.h"
#import "HONUtilsSuite.h"
#import "HONDeviceIntrinsics.h"
#import "HONFontAllocator.h"
#import "HONOpponentVO.h"
#import "HONEmotionVO.h"
#import "HONImageLoadingView.h"
//#import "HONVerifyCellHeaderView.h"

@interface HONVerifyViewCell() //<HONVerifyCellHeaderViewDelegate>
@property (nonatomic, strong) UIView *imageHolderView;
@property (nonatomic, strong) UIView *tappedOverlayView;
@property (nonatomic) BOOL isBannerCell;
@end

@implementation HONVerifyViewCell
@synthesize delegate = _delegate;
@synthesize challengeVO = _challengeVO;
@synthesize indexPath = _indexPath;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initAsBannerCell:(BOOL)isBannerCell {
	if ((self = [super init])) {
		_isBannerCell = isBannerCell;
		self.backgroundColor = [UIColor blackColor];
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
	
	UIImageView *gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selfieFullSizeGradientOverlay"]];
	gradientImageView.frame = _imageHolderView.frame;
	
	UIImageView *heroImageView = [[UIImageView alloc] initWithFrame:_imageHolderView.frame];
	heroImageView.alpha = 0.0;
	heroImageView.userInteractionEnabled = YES;
	[_imageHolderView addSubview:heroImageView];
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		heroImageView.alpha = 0.0;
		heroImageView.image = image;
		[heroImageView addSubview:gradientImageView];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			heroImageView.alpha = 1.0;
		} completion:^(BOOL finished) {
			[imageLoadingView stopAnimating];
			[imageLoadingView removeFromSuperview];
		}];
	};
	
	//NSLog(@"CREATOR IMAGE:[%@]", [challengeVO.creatorVO.imagePrefix stringByAppendingString:kSnapLargeSuffix]);
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:challengeVO.creatorVO.imagePrefix forBucketType:HONS3BucketTypeSelfies completion:nil];
	};
	
	[heroImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[challengeVO.creatorVO.imagePrefix stringByAppendingString:([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
						 placeholderImage:nil
								  success:successBlock
								  failure:failureBlock];
	
	
	UIButton *previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
	previewButton.frame = heroImageView.frame;
	[previewButton addTarget:self action:@selector(_goPreview) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:previewButton];
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	lpGestureRecognizer.minimumPressDuration = 0.25;
	[_imageHolderView addGestureRecognizer:lpGestureRecognizer];
	
//	HONVerifyCellHeaderView *headerView = [[HONVerifyCellHeaderView alloc] initWithOpponent:_challengeVO.creatorVO];
//	headerView.frame = CGRectOffset(headerView.frame, 0.0, 35.0);
//	headerView.delegate = self;
//	[self.contentView addSubview:headerView];
	
	UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 118.0, 320.0, 69.0)];
	[self.contentView addSubview:footerView];
	
	UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 0.0, 210.0, 24.0)];
	usernameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:18];
	usernameLabel.textColor = [UIColor whiteColor];
	usernameLabel.backgroundColor = [UIColor clearColor];
	usernameLabel.shadowColor = [UIColor blackColor];
	usernameLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	usernameLabel.attributedText = [[NSAttributedString alloc] initWithString:[[HONAppDelegate verifyCopyForKey:@"name_txt"] stringByReplacingOccurrencesOfString:@"_{{USERNAME}}_" withString:_challengeVO.creatorVO.username] attributes:nil];
	[footerView addSubview:usernameLabel];
	
	UILabel *emotionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 26.0, 200.0, 20.0)];
	emotionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:16];
	emotionLabel.textColor = [UIColor whiteColor];
	emotionLabel.backgroundColor = [UIColor clearColor];
	emotionLabel.shadowColor = [UIColor blackColor];
	emotionLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	emotionLabel.text = [HONAppDelegate verifyCopyForKey:@"sub_txt"];
	[footerView addSubview:emotionLabel];
	
//	CGSize size = [[HONAppDelegate verifyCopyForKey:@"sub_txt"] boundingRectWithSize:emotionLabel.frame.size
//																			 options:NSStringDrawingTruncatesLastVisibleLine
//																		  attributes:@{NSFontAttributeName:emotionLabel.font}
//																			 context:nil].size;
	
//	HONEmotionVO *emotionVO = [self _challengeEmotion];
//	if (emotionVO != nil && [_challengeVO.challengers count] > 0) {
//		UIImageView *emoticonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(emotionLabel.frame.origin.x + size.width, 20.0, 30.0, 30.0)];
//		[emoticonImageView setImageWithURL:[NSURL URLWithString:emotionVO.urlLarge] placeholderImage:nil];
//		[footerView addSubview:emoticonImageView];
//	}
	
//	UIImageView *emoticonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fpo_emotionIcon-LG"]];
//	emoticonImageView.frame = CGRectMake((emotionLabel.frame.origin.x + size.width) + 9.0, 24.0, 45.0, 45.0);
//	[footerView addSubview:emoticonImageView];
	
	UIView *buttonHolderView = [[UIView alloc] initWithFrame:CGRectMake(244.0, [UIScreen mainScreen].bounds.size.height - 316.0, 64.0, 245.0)];
	[self.contentView addSubview:buttonHolderView];
	
	UIButton *approveButton = [UIButton buttonWithType:UIButtonTypeCustom];
	approveButton.frame = CGRectMake(0.0, 0.0, 64.0, 64.0);
	[approveButton setBackgroundImage:[UIImage imageNamed:@"yayButton_nonActive"] forState:UIControlStateNormal];
	[approveButton setBackgroundImage:[UIImage imageNamed:@"yayButton_Active"] forState:UIControlStateHighlighted];
	[approveButton addTarget:self action:@selector(_goApprove) forControlEvents:UIControlEventTouchUpInside];
	[buttonHolderView addSubview:approveButton];
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 72.0, 64.0, 14.0)];
	scoreLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
	scoreLabel.textColor = [UIColor whiteColor];
	scoreLabel.backgroundColor = [UIColor clearColor];
	scoreLabel.shadowColor = [UIColor blackColor];
	scoreLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	scoreLabel.textAlignment = NSTextAlignmentCenter;
	scoreLabel.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:((arc4random() % 100) + 5)]];
	[buttonHolderView addSubview:scoreLabel];
	
	UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
	skipButton.frame = CGRectMake(0.0, 97.0, 64.0, 64.0);
	[skipButton setBackgroundImage:[UIImage imageNamed:@"nayButton_nonActive"] forState:UIControlStateNormal];
	[skipButton setBackgroundImage:[UIImage imageNamed:@"nayButton_Active"] forState:UIControlStateHighlighted];
	[skipButton addTarget:self action:@selector(_goSkip) forControlEvents:UIControlEventTouchUpInside];
	[buttonHolderView addSubview:skipButton];
	
	UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	inviteButton.frame = CGRectMake(0.0, 181.0, 64.0, 64.0);
	[inviteButton setBackgroundImage:[UIImage imageNamed:@"verifyInviteButton_nonActive"] forState:UIControlStateNormal];
	[inviteButton setBackgroundImage:[UIImage imageNamed:@"verifyInviteButton_Active"] forState:UIControlStateHighlighted];
	[inviteButton addTarget:self action:@selector(_goInvite) forControlEvents:UIControlEventTouchUpInside];
	[buttonHolderView addSubview:inviteButton];
	
	if (_isBannerCell) {
		buttonHolderView.frame = CGRectOffset(buttonHolderView.frame, 0.0, -80.0);
		footerView.frame = CGRectOffset(footerView.frame, 0.0, -80.0);
		
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
	[self.delegate verifyViewCell:self approveChallenge:_challengeVO];
}

- (void)_goDisprove {
	[self.delegate verifyViewCell:self disapproveChallenge:_challengeVO];
}

- (void)_goSkip {
	[self.delegate verifyViewCell:self skipChallenge:_challengeVO];
}

- (void)_goMore {
	[self.delegate verifyViewCell:self moreActionsForChallenge:_challengeVO];
}

- (void)_goInvite {
	NSLog(@"=-=-=-=-=-=-=-= ¡¡WTF MOFO!! =-=-=-=-=-=-=-=-=-=");
	[self.delegate verifyViewCell:self inviteChallenge:_challengeVO];
}

- (void)_goShoutout {
	[self.delegate verifyViewCell:self shoutoutChallenge:_challengeVO];
}

- (void)_goUserProfile {
	[self.delegate verifyViewCell:self creatorProfile:_challengeVO];
}

- (void)_goPreview {
	[self.delegate verifyViewCell:self fullSizeDisplayForChallenge:_challengeVO];
}

- (void)_goBanner {
	[self.delegate verifyViewCell:self bannerTappedForChallenge:_challengeVO];
}


#pragma mark - UI Presentation
-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan)
		[self.delegate verifyViewCell:self creatorProfile:_challengeVO];
		
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
//- (void)cellHeaderView:(HONVerifyCellHeaderView *)cell showProfileForUser:(HONOpponentVO *)opponentVO {
//	[[Mixpanel sharedInstance] track:@"Verify - Header Show Profile"
//						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
//									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
//									  [NSString stringWithFormat:@"%d - %@", opponentVO.userID, opponentVO.username], @"opponent", nil]];
//	
//	[self.delegate verifyViewCell:self creatorProfile:_challengeVO];
//}

@end
