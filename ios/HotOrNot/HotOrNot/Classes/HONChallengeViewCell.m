//
//  HONChallengeViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONChallengeViewCell.h"
#import "HONOpponentVO.h"
#import "HONImageLoadingView.h"

@interface HONChallengeViewCell()
@property (nonatomic, strong) UIView *imageHolderView;
@property (nonatomic, strong) UIImageView *challengeImageView;
@end

@implementation HONChallengeViewCell
@synthesize delegate = _delegate;
@synthesize challengeVO = _challengeVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		self.backgroundColor = [UIColor whiteColor];
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
	
	_imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(12.0, 0.0, kSnapLargeDim, kSnapLargeDim)];
	_imageHolderView.clipsToBounds = YES;
	[self addSubview:_imageHolderView];
	
	HONImageLoadingView *lImageLoading = [[HONImageLoadingView alloc] initAtPos:CGPointMake(73.0, 73.0)];
	[_imageHolderView addSubview:lImageLoading];
	
	
	CGSize size = CGSizeMake(kSnapLargeDim, kSnapLargeDim * (1 + (1/3)));
	_challengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapLargeDim, kSnapLargeDim)];//CGRectMake(0.0, (size.height - size.width) * -0.5, size.width, size.height)];
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
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	[_imageHolderView addGestureRecognizer:lpGestureRecognizer];
	
	UIButton *yayButton = [UIButton buttonWithType:UIButtonTypeCustom];
	yayButton.frame = CGRectMake(256.0, 46.0, 44.0, 44.0);
	[yayButton setBackgroundImage:[UIImage imageNamed:@"verifyYayButton_nonActive"] forState:UIControlStateNormal];
	[yayButton setBackgroundImage:[UIImage imageNamed:@"verifyYayButton_Active"] forState:UIControlStateHighlighted];
	[yayButton addTarget:self action:@selector(_goYay) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:yayButton];
	
	UIButton *nayButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nayButton.frame = CGRectMake(256.0, 126.0, 44.0, 44.0);
	[nayButton setBackgroundImage:[UIImage imageNamed:@"verifyNayButton_nonActive"] forState:UIControlStateNormal];
	[nayButton setBackgroundImage:[UIImage imageNamed:@"verifyNayButton_Active"] forState:UIControlStateHighlighted];
	[nayButton addTarget:self action:@selector(_goNay) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:nayButton];
	
	UIImageView *dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider"]];
	dividerImageView.frame = CGRectOffset(dividerImageView.frame, 0.0, 233.0);
	[self addSubview:dividerImageView];
}


#pragma mark - Navigation
- (void)_goYay {
	[self.delegate challengeViewCell:self approveUser:YES forChallenge:_challengeVO];
}

- (void)_goNay {
	[self.delegate challengeViewCell:self approveUser:NO forChallenge:_challengeVO];
}


#pragma mark - UI Presentation
-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan)
		[self.delegate challengeViewCellShowPreview:self forChallenge:_challengeVO];
		
	else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized)
		[self.delegate challengeViewCellHidePreview:self];
}


@end
