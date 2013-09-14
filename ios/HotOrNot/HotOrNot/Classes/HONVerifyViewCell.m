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

@interface HONVerifyViewCell()
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

- (id)initAsEvenRow:(BOOL)isEven {
	if ((self = [super init])) {
		self.backgroundColor = (isEven) ? [UIColor whiteColor] : [UIColor colorWithWhite:0.9 alpha:1.0];
	}
	
	return (self);
}

- (void)_imageLoadFallback {
	[_challengeImageView removeFromSuperview];
	_challengeImageView = nil;
	
	__weak typeof(self) weakSelf = self;
	_challengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - kSnapLargeDim) * 0.5, ([UIScreen mainScreen].bounds.size.width - kSnapLargeDim) * 0.5, kSnapLargeDim, kSnapLargeDim)];
	_challengeImageView.userInteractionEnabled = YES;
	_challengeImageView.alpha = [_challengeImageView isImageCached:[NSURLRequest requestWithURL:[NSURL URLWithString:_challengeVO.creatorVO.avatarURL]]];
	[_imageHolderView addSubview:_challengeImageView];
	
	[_challengeImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_challengeVO.creatorVO.avatarURL] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
							   placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
								   weakSelf.challengeImageView.image = image;
								   [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.challengeImageView.alpha = 1.0; } completion:nil];
							   } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
							   }];
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	__weak typeof(self) weakSelf = self;
	
	_imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 247.0, 198.0)];
	_imageHolderView.clipsToBounds = YES;
	[self addSubview:_imageHolderView];
	
	HONImageLoadingView *lImageLoading = [[HONImageLoadingView alloc] initAtPos:CGPointMake(73.0, 73.0)];
	[_imageHolderView addSubview:lImageLoading];
	
	
	_challengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 247.0, 247.0 * (1.0 + (1/3)))];//CGRectMake(0.0, (size.height - size.width) * -0.5, size.width, size.height)];
	_challengeImageView.userInteractionEnabled = YES;
	_challengeImageView.alpha = [_challengeImageView isImageCached:[NSURLRequest requestWithURL:[NSURL URLWithString:_challengeVO.creatorVO.avatarURL]]];
	[_imageHolderView addSubview:_challengeImageView];
	
	[_challengeImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:challengeVO.creatorVO.avatarURL] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
								placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
									weakSelf.challengeImageView.image = image;
									[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.challengeImageView.alpha = 1.0; } completion:nil];
								} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
									[weakSelf _imageLoadFallback];
								}];
	
	UIButton *tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
	tapButton.frame = _challengeImageView.frame;
	[tapButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
	//[tapButton addTarget:self action:@selector(_goTapCreator) forControlEvents:UIControlEventTouchUpInside];
	[_imageHolderView addSubview:tapButton];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(134.0, 13.0, 90.0, 16.0)];
	timeLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:13];
	timeLabel.textColor = [UIColor whiteColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = (_challengeVO.expireSeconds > 0) ? [HONAppDelegate formattedExpireTime:_challengeVO.expireSeconds] : [HONAppDelegate timeSinceDate:_challengeVO.updatedDate];
	[self addSubview:timeLabel];
	
	UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0, 150, 150.0, 22.0)];
	usernameLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18];
	usernameLabel.textColor = [UIColor whiteColor];
	usernameLabel.backgroundColor = [UIColor clearColor];
	usernameLabel.text = [NSString stringWithFormat:@"@%@", _challengeVO.creatorVO.username];
	[self addSubview:usernameLabel];
	
	UIButton *usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	usernameButton.frame = usernameLabel.frame;
	[usernameButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
	[usernameButton addTarget:self action:@selector(_goUserProfile) forControlEvents:UIControlEventTouchUpInside];
	[usernameButton setTag:_challengeVO.creatorVO.userID];
	[self addSubview:usernameButton];
	
	UILabel *ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0, 171.0, 260.0, 22.0)];
	ageLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18];
	ageLabel.textColor = [UIColor whiteColor];
	ageLabel.backgroundColor = [UIColor clearColor];
	ageLabel.text = ([_challengeVO.creatorVO.birthday timeIntervalSince1970] == 0.0) ? @"hasn't set a birthday yet" : @"does this user look 13 to 19?";
	[self addSubview:ageLabel];
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	lpGestureRecognizer.minimumPressDuration = 0.25;
	[_imageHolderView addGestureRecognizer:lpGestureRecognizer];
	
	UIButton *yayButton = [UIButton buttonWithType:UIButtonTypeCustom];
	yayButton.frame = CGRectMake(262.0, 47.0, 44.0, 44.0);
	[yayButton setBackgroundImage:[UIImage imageNamed:@"verifyYayButton_nonActive"] forState:UIControlStateNormal];
	[yayButton setBackgroundImage:[UIImage imageNamed:@"verifyYayButton_Active"] forState:UIControlStateHighlighted];
	[yayButton addTarget:self action:@selector(_goYay) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:yayButton];
	
	UIButton *nayButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nayButton.frame = CGRectMake(262.0, 108.0, 44.0, 44.0);
	[nayButton setBackgroundImage:[UIImage imageNamed:@"verifyNayButton_nonActive"] forState:UIControlStateNormal];
	[nayButton setBackgroundImage:[UIImage imageNamed:@"verifyNayButton_Active"] forState:UIControlStateHighlighted];
	[nayButton addTarget:self action:@selector(_goNay) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:nayButton];
}

- (void)showTapOverlay {
	_tappedOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.frame.size.height)];
	_tappedOverlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.67];
	[self addSubview:_tappedOverlayView];
	
	NSLog(@"OVERLAY:[%@]", NSStringFromCGRect(_tappedOverlayView.frame));
	[UIView animateWithDuration:0.33 delay:0.125 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		_tappedOverlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[_tappedOverlayView removeFromSuperview];
		_tappedOverlayView = nil;
	}];
}


#pragma mark - Navigation
- (void)_goYay {
	[self.delegate challengeViewCell:self approveUser:YES forChallenge:_challengeVO];
}

- (void)_goNay {
	[self.delegate challengeViewCell:self approveUser:NO forChallenge:_challengeVO];
}

- (void)_goUserProfile {
	[self.delegate challengeViewCell:self creatorProfile:_challengeVO];
}


#pragma mark - UI Presentation
-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan)
		[self.delegate challengeViewCellShowPreview:self forChallenge:_challengeVO];
		
	else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized)
		[self.delegate challengeViewCellHidePreview:self];
}


@end
