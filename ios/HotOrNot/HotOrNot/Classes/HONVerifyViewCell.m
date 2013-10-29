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
	
	CGSize imageSize = ([HONAppDelegate isRetina4Inch]) ? CGSizeMake(426.0, 568.0) : CGSizeMake(360.0, 480.0);
	NSMutableString *imageURL = [_challengeVO.creatorVO.avatarURL mutableCopy];
	[imageURL replaceOccurrencesOfString:@".jpg" withString:@"_o.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imageURL length])];
	CGRect frame = CGRectMake((imageSize.width - 320.0) * -0.5, -185.0, imageSize.width, imageSize.height);
	
//	NSLog(@"VERIFY RELOADING:[%@]", imageURL);
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_challengeImageView.image = image;
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_challengeImageView.alpha = 1.0; } completion:nil];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
	};
	
	_challengeImageView = [[UIImageView alloc] initWithFrame:frame];
	_challengeImageView.userInteractionEnabled = YES;
	_challengeImageView.alpha = 0.0;
	[_imageHolderView addSubview:_challengeImageView];
	
	[_challengeImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
							   placeholderImage:nil
										success:imageSuccessBlock
										failure:imageFailureBlock];
}

- (void)setChallengeVO:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	_imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kHeroVolleyTableCellHeight)];
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
//	NSLog(@"FROM DB:[%@]", challengeVO.creatorVO.imagePrefix);
//	NSLog(@"VERIFY LOADING:[%@]", avatarURL);
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_challengeImageView.image = image;
		[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_challengeImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[self _imageLoadFallback];
	};
	
	[_challengeImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:avatarURL] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
								placeholderImage:nil
										success:successBlock
										failure:failureBlock];
	
	UIImageView *gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timelineImageFade"]];
	gradientImageView.frame = CGRectOffset(gradientImageView.frame, 0.0, kHeroVolleyTableCellHeight - gradientImageView.frame.size.height);
	[self.contentView addSubview:gradientImageView];
	
	UIView *buttonHolderView = [[UIView alloc] initWithFrame:CGRectMake(246.0, 120.0, 74.0, 164.0)];
	[self.contentView addSubview:buttonHolderView];
	
	UIButton *approveButton = [UIButton buttonWithType:UIButtonTypeCustom];
	approveButton.frame = CGRectMake(0.0, 0.0, 74.0, 74.0);
	[approveButton setBackgroundImage:[UIImage imageNamed:@"yayButton_nonActive"] forState:UIControlStateNormal];
	[approveButton setBackgroundImage:[UIImage imageNamed:@"yayButton_Active"] forState:UIControlStateHighlighted];
	[approveButton addTarget:self action:@selector(_goApprove) forControlEvents:UIControlEventTouchUpInside];
	[buttonHolderView addSubview:approveButton];
	
	UIButton *dispproveButton = [UIButton buttonWithType:UIButtonTypeCustom];
	dispproveButton.frame = CGRectMake(0.0, 90.0, 74.0, 74.0);
	[dispproveButton setBackgroundImage:[UIImage imageNamed:@"nayButton_nonActive"] forState:UIControlStateNormal];
	[dispproveButton setBackgroundImage:[UIImage imageNamed:@"nayButton_Active"] forState:UIControlStateHighlighted];
	[dispproveButton addTarget:self action:@selector(_goDisprove) forControlEvents:UIControlEventTouchUpInside];
	[buttonHolderView addSubview:dispproveButton];
	
	
	UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, kHeroVolleyTableCellHeight - 56.0, 320.0, 53.0)];
	[self.contentView addSubview:footerView];
	
	UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, 150.0, 22.0)];
	usernameLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:18];
	usernameLabel.textColor = [UIColor whiteColor];
	usernameLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
	usernameLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	usernameLabel.backgroundColor = [UIColor clearColor];
	usernameLabel.text = _challengeVO.creatorVO.username;
	[footerView addSubview:usernameLabel];
	
	UIButton *usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	usernameButton.frame = CGRectMake(10.0, 0.0, 150.0, 44.0);
	[usernameButton addTarget:self action:@selector(_goUserProfile) forControlEvents:UIControlEventTouchUpInside];
	[usernameButton setTag:_challengeVO.creatorVO.userID];
	[footerView addSubview:usernameButton];
	
	UILabel *ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 26.0, 260.0, 22.0)];
	ageLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:18];
	ageLabel.textColor = [UIColor colorWithWhite:0.898 alpha:1.0];
	ageLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
	ageLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	ageLabel.backgroundColor = [UIColor clearColor];
	ageLabel.text = ([_challengeVO.creatorVO.birthday timeIntervalSince1970] == 0.0) ? @"hasn't set a birthday yet" : [NSString stringWithFormat:@"does this user look %d to %d?", [HONAppDelegate ageRangeAsSeconds:NO].location, [HONAppDelegate ageRangeAsSeconds:NO].length];
	[footerView addSubview:ageLabel];
	
	
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
		[self.delegate verifyViewCellShowPreview:self forChallenge:_challengeVO];
		
	else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized)
		[self.delegate verifyViewCellShowPreviewControls:self];
}


@end
