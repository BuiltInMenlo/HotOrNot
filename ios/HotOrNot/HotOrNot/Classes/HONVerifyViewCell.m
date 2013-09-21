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

- (void)_imageLoadFallback {
	[_challengeImageView removeFromSuperview];
	_challengeImageView = nil;
	
	__weak typeof(self) weakSelf = self;
	_challengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 320.0)];
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
	
	_imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 198.0)];
	_imageHolderView.clipsToBounds = YES;
	_imageHolderView.backgroundColor = [UIColor blackColor];
	[self.contentView addSubview:_imageHolderView];
	
//	[_imageHolderView addSubview:[[HONImageLoadingView alloc] initAtPos:CGPointMake(73.0, 73.0)]];
	
	_challengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -14.0, 320.0, 427.0)];//CGRectMake(0.0, (size.height - size.width) * -0.5, size.width, size.height)];
	_challengeImageView.userInteractionEnabled = YES;
	_challengeImageView.alpha = 0.0;
	[_imageHolderView addSubview:_challengeImageView];
	
	NSMutableString *avatarURL = [challengeVO.creatorVO.avatarURL mutableCopy];
	[avatarURL replaceOccurrencesOfString:@".jpg" withString:@"_o.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [avatarURL length])];
	[avatarURL replaceOccurrencesOfString:@".png" withString:@"_o.png" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [avatarURL length])];
	
	[_challengeImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:avatarURL] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
								placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
									weakSelf.challengeImageView.image = image;
									[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.challengeImageView.alpha = 1.0; } completion:nil];
								} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
									[weakSelf _imageLoadFallback];
								}];
	
	UIImageView *gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timelineImageFade"]];
	gradientImageView.frame = CGRectOffset(gradientImageView.frame, 0.0, 44.0);
	[self.contentView addSubview:gradientImageView];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(134.0, 13.0, 90.0, 16.0)];
	timeLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:13];
	timeLabel.textColor = [UIColor whiteColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = (_challengeVO.expireSeconds > 0) ? [HONAppDelegate formattedExpireTime:_challengeVO.expireSeconds] : [HONAppDelegate timeSinceDate:_challengeVO.updatedDate];
	[self.contentView addSubview:timeLabel];
	
	UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 144.0, 150.0, 22.0)];
	usernameLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:18];
	usernameLabel.textColor = [UIColor whiteColor];
	usernameLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
	usernameLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	usernameLabel.backgroundColor = [UIColor clearColor];
	usernameLabel.text = _challengeVO.creatorVO.username;
	[self.contentView addSubview:usernameLabel];
	
	UIButton *usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	usernameButton.frame = CGRectMake(10.0, 144.0, 150.0, 44.0);
	[usernameButton addTarget:self action:@selector(_goUserProfile) forControlEvents:UIControlEventTouchUpInside];
	[usernameButton setTag:_challengeVO.creatorVO.userID];
	[self.contentView addSubview:usernameButton];
	
	UILabel *ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 165.0, 260.0, 22.0)];
	ageLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:18];
	ageLabel.textColor = [UIColor colorWithWhite:0.898 alpha:1.0];
	ageLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
	ageLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	ageLabel.backgroundColor = [UIColor clearColor];
	ageLabel.text = ([_challengeVO.creatorVO.birthday timeIntervalSince1970] == 0.0) ? @"hasn't set a birthday yet" : @"does this user look 13 to 19?";
	[self.contentView addSubview:ageLabel];
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	lpGestureRecognizer.minimumPressDuration = 0.25;
	[_imageHolderView addGestureRecognizer:lpGestureRecognizer];
	
//	UIView *buttonBGView = [[UIView alloc] initWithFrame:CGRectMake(247.0, 0.0, 73.0, 198.0)];
//	buttonBGView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.67];
//	[self.contentView addSubview:buttonBGView];
	
	UIButton *yayButton = [UIButton buttonWithType:UIButtonTypeCustom];
	yayButton.frame = CGRectMake(262.0, 77.0, 44.0, 44.0);
	[yayButton setBackgroundImage:[UIImage imageNamed:@"verifyYayButton_nonActive"] forState:UIControlStateNormal];
	[yayButton setBackgroundImage:[UIImage imageNamed:@"verifyYayButton_Active"] forState:UIControlStateHighlighted];
	[yayButton addTarget:self action:@selector(_goVerify) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:yayButton];
	
//	UIButton *nayButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	nayButton.frame = CGRectMake(262.0, 106.0, 44.0, 44.0);
//	[nayButton setBackgroundImage:[UIImage imageNamed:@"verifyNayButton_nonActive"] forState:UIControlStateNormal];
//	[nayButton setBackgroundImage:[UIImage imageNamed:@"verifyNayButton_Active"] forState:UIControlStateHighlighted];
//	[nayButton addTarget:self action:@selector(_goNay) forControlEvents:UIControlEventTouchUpInside];
//	[self.contentView addSubview:nayButton];
}

- (void)showTapOverlay {
	UIView *tappedOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.frame.size.height)];
	tappedOverlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.85];
	[self.contentView addSubview:tappedOverlayView];
	
//	NSLog(@"OVERLAY:[%@]", NSStringFromCGRect(_tappedOverlayView.frame));
	[UIView animateWithDuration:0.25 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		tappedOverlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[tappedOverlayView removeFromSuperview];
	}];
}


#pragma mark - Navigation
- (void)_goVerify {
	[self.delegate verifyViewCellTakeAction:self forChallenge:_challengeVO];
}

- (void)_goYay {
	[self.delegate verifyViewCell:self approveUser:YES forChallenge:_challengeVO];
}

- (void)_goNay {
	[self.delegate verifyViewCell:self approveUser:NO forChallenge:_challengeVO];
}

- (void)_goUserProfile {
	[self.delegate verifyViewCell:self creatorProfile:_challengeVO];
}


#pragma mark - UI Presentation
-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan)
		[self.delegate verifyViewCellShowPreview:self forChallenge:_challengeVO];
		
	else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized)
		[self.delegate verifyViewCellHidePreview:self];
}


@end
