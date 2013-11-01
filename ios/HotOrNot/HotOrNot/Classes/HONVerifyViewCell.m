//
//  HONVerifyViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONVerifyViewCell.h"
#import "HONOpponentVO.h"
#import "HONImageLoadingView.h"
#import "HONVerifyCellHeaderView.h"

@interface HONVerifyViewCell() <HONVerifyCellHeaderViewDelegate>
@property (nonatomic, strong) UIView *imageHolderView;
@property (nonatomic, strong) UIImageView *challengeImageView;
@property (nonatomic, strong) UIView *tappedOverlayView;
@property (nonatomic) BOOL isEven;
@end

@implementation HONVerifyViewCell
@synthesize delegate = _delegate;
@synthesize challengeVO = _challengeVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		self.backgroundColor = [UIColor blackColor];
	}
	
	return (self);
}

- (id)initAsEvenRow:(BOOL)isEven {
	if ((self = [super init])) {
		self.backgroundColor = [UIColor blackColor]; //(isEven) ? [UIColor whiteColor] : [UIColor colorWithWhite:0.9 alpha:1.0];
	}
	
	return (self);
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	_imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kVerifyTableCellHeight)];
	_imageHolderView.clipsToBounds = YES;
	_imageHolderView.backgroundColor = [UIColor blackColor];
	[self.contentView addSubview:_imageHolderView];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:_imageHolderView];
	[imageLoadingView startAnimating];
	[_imageHolderView addSubview:imageLoadingView];
	
	_challengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -100.0, 320.0, 568.0)];
	_challengeImageView.userInteractionEnabled = YES;
	_challengeImageView.alpha = 0.0;
	[_imageHolderView addSubview:_challengeImageView];
	
	NSMutableString *avatarURL = [challengeVO.creatorVO.imagePrefix mutableCopy];
	[avatarURL replaceOccurrencesOfString:@"_o" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [avatarURL length])];
	[avatarURL replaceOccurrencesOfString:@".jpg" withString:@"Large_640x1136.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [avatarURL length])];
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_challengeImageView.image = image;
		[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_challengeImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RECREATE_IMAGE_SIZES" object:[NSString stringWithFormat:@"%@Large_640x1136.jpg", avatarURL]];
	};
	
	[_challengeImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:avatarURL] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
								placeholderImage:nil
										success:successBlock
										failure:failureBlock];
	
	[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topFade"]]];
	
	UIImageView *gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timelineImageFade"]];
	gradientImageView.frame = CGRectOffset(gradientImageView.frame, 0.0, kVerifyTableCellHeight - gradientImageView.frame.size.height);
	[self.contentView addSubview:gradientImageView];
	
	HONVerifyCellHeaderView *headerView = [[HONVerifyCellHeaderView alloc] initWithOpponent:_challengeVO.creatorVO];
	headerView.delegate = self;
	[self addSubview:headerView];
		
	UIView *buttonHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, kVerifyTableCellHeight - 84.0, 320, 74.0)];
	[self.contentView addSubview:buttonHolderView];
	
	UIButton *approveButton = [UIButton buttonWithType:UIButtonTypeCustom];
	approveButton.frame = CGRectMake(29.0, 0.0, 133.0, 74.0);
	[approveButton setBackgroundImage:[UIImage imageNamed:@"okButton_nonActive"] forState:UIControlStateNormal];
	[approveButton setBackgroundImage:[UIImage imageNamed:@"okButton_Active"] forState:UIControlStateHighlighted];
	[approveButton addTarget:self action:@selector(_goApprove) forControlEvents:UIControlEventTouchUpInside];
	[buttonHolderView addSubview:approveButton];
	
	UIButton *dispproveButton = [UIButton buttonWithType:UIButtonTypeCustom];
	dispproveButton.frame = CGRectMake(157.0, 0.0, 133.0, 74.0);
	[dispproveButton setBackgroundImage:[UIImage imageNamed:@"noButton_nonActive"] forState:UIControlStateNormal];
	[dispproveButton setBackgroundImage:[UIImage imageNamed:@"noButton_Active"] forState:UIControlStateHighlighted];
	[dispproveButton addTarget:self action:@selector(_goDisprove) forControlEvents:UIControlEventTouchUpInside];
	[buttonHolderView addSubview:dispproveButton];
	
	
	if (![HONAppDelegate hasTakenSelfie])
		[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"needSelfieHeroBubble"]]];
	
	
//	UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, kVerifyTableCellHeight - 56.0, 320.0, 53.0)];
//	[self.contentView addSubview:footerView];
//	
//	UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, 150.0, 22.0)];
//	usernameLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:18];
//	usernameLabel.textColor = [UIColor whiteColor];
//	usernameLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
//	usernameLabel.shadowOffset = CGSizeMake(1.0, 1.0);
//	usernameLabel.backgroundColor = [UIColor clearColor];
//	usernameLabel.text = _challengeVO.creatorVO.username;
//	[footerView addSubview:usernameLabel];
//	
//	UIButton *usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	usernameButton.frame = CGRectMake(10.0, 0.0, 150.0, 44.0);
//	[usernameButton addTarget:self action:@selector(_goUserProfile) forControlEvents:UIControlEventTouchUpInside];
//	[usernameButton setTag:_challengeVO.creatorVO.userID];
//	[footerView addSubview:usernameButton];
//	
//	UILabel *ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 26.0, 260.0, 22.0)];
//	ageLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:18];
//	ageLabel.textColor = [UIColor colorWithWhite:0.898 alpha:1.0];
//	ageLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
//	ageLabel.shadowOffset = CGSizeMake(1.0, 1.0);
//	ageLabel.backgroundColor = [UIColor clearColor];
//	ageLabel.text = ([_challengeVO.creatorVO.birthday timeIntervalSince1970] == 0.0) ? @"hasn't set a birthday yet" : [NSString stringWithFormat:@"does this user look %d to %d?", [HONAppDelegate ageRangeAsSeconds:NO].location, [HONAppDelegate ageRangeAsSeconds:NO].length];
//	[footerView addSubview:ageLabel];
	
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	lpGestureRecognizer.minimumPressDuration = 0.25;
	[_imageHolderView addGestureRecognizer:lpGestureRecognizer];
}

- (void)showTapOverlay {
	UIView *tappedOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.frame.size.height)];
	tappedOverlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.85];
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
//		[self.delegate verifyViewCellShowPreviewControls:self];
	}
}


#pragma mark - VerifyCellHeader Delegates
- (void)cellHeaderView:(HONVerifyCellHeaderView *)cell showProfileForUser:(HONOpponentVO *)opponentVO {
	[self.delegate verifyViewCell:self creatorProfile:_challengeVO];
}

@end
