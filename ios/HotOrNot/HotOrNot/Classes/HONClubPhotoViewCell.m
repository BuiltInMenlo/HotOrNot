//
//  HONClubPhotoViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/14/2014 @ 21:59 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"
#import "UIImageView+AFNetworking.h"
#import "UILabel+BoundingRect.h"
#import "UILabel+FormattedText.h"

#import "PicoSticker.h"

#import "HONClubPhotoViewCell.h"
#import "HONEmotionVO.h"
#import "HONImageLoadingView.h"

@interface HONClubPhotoViewCell ()
@property (nonatomic, strong) HONImageLoadingView *imageLoadingView;
@property (nonatomic, strong) UILabel *scoreLabel;
@end

@implementation HONClubPhotoViewCell
@synthesize indexPath = _indexPath;
@synthesize clubPhotoVO = _clubPhotoVO;
@synthesize clubName = _clubName;


+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		self.contentView.frame = [UIScreen mainScreen].bounds;
		self.backgroundColor = [UIColor blackColor];
	}
	
	return (self);
}

- (void)setClubName:(NSString *)clubName {
	_clubName = clubName;
}

- (void)setClubPhotoVO:(HONClubPhotoVO *)clubPhotoVO {
	_clubPhotoVO = clubPhotoVO;
	
	_imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:self.contentView asLargeLoader:NO];
	[self.contentView addSubview:_imageLoadingView];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
	imageView.alpha = 0.0;
	[self.contentView addSubview:imageView];
	
	UIImageView *gradientImageView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
	gradientImageView.image = [UIImage imageNamed:@"selfieFullSizeGradientOverlay"];
	[self.contentView addSubview:gradientImageView];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		imageView.image = image;
		[UIView animateWithDuration:0.25 animations:^(void) {
			imageView.alpha = 1.0;
		} completion:^(BOOL finished) {
			[_imageLoadingView stopAnimating];
		}];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[[HONAPICaller sharedInstance] normalizePrefixForImageURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeClubs completion:nil];
		
//		imageView.image = [UIImage imageNamed:@"defaultClubCover"];
		[UIView animateWithDuration:0.25 animations:^(void) {
			imageView.alpha = 1.0;
		} completion:^(BOOL finished) {
			[_imageLoadingView stopAnimating];
		}];
	};
	
	[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_clubPhotoVO.imagePrefix stringByAppendingString:([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]]
													   cachePolicy:kURLRequestCachePolicy
												   timeoutInterval:[HONAppDelegate timeoutInterval]]
					 placeholderImage:nil
							  success:imageSuccessBlock
							  failure:imageFailureBlock];
	
	
	CGSize maxSize = CGSizeMake(296.0, 24.0);
	CGSize size = [_clubPhotoVO.username boundingRectWithSize:maxSize
													  options:(NSStringDrawingTruncatesLastVisibleLine)
												   attributes:@{NSFontAttributeName:[[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:19]}
													  context:nil].size;
	
	UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(11.0, 80.0, MIN(maxSize.width, size.width), 24.0)];
	usernameLabel.backgroundColor = [UIColor clearColor];
	usernameLabel.textColor = [UIColor whiteColor];
	usernameLabel.shadowColor = [UIColor blackColor];
	usernameLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	usernameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:19];
	usernameLabel.text = _clubPhotoVO.username;
	[self.contentView addSubview:usernameLabel];
	
	UIButton *usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	usernameButton.frame = usernameLabel.frame;
	[usernameButton addTarget:self action:@selector(_goUserProfile) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:usernameButton];
			
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 110.0, 200.0, 16.0)];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:12];
	timeLabel.textColor = [[HONColorAuthority sharedInstance] honLightGreyTextColor];
	timeLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.75];
	timeLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	
	NSString *format = ([_clubPhotoVO.subjectNames count] == 1) ? NSLocalizedString(@"ago_emotion", nil) :NSLocalizedString(@"ago_emotions", nil);
	timeLabel.text = [[[HONDateTimeAlloter sharedInstance] intervalSinceDate:_clubPhotoVO.addedDate] stringByAppendingFormat:format, [_clubPhotoVO.subjectNames count]];
	[self.contentView addSubview:timeLabel];
	
	UILabel *feelingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, [UIScreen mainScreen].bounds.size.height - 208.0, 200.0, 26.0)];
	feelingLabel.backgroundColor = [UIColor clearColor];
	feelingLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:19];
	feelingLabel.textColor = [UIColor whiteColor];
	feelingLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.75];
	feelingLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	
	feelingLabel.text = NSLocalizedString(@"is_feeling2", nil);
	[self.contentView addSubview:feelingLabel];
	
	UIScrollView *emoticonsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 168.0, 320.0, 84.0)];
	emoticonsScrollView.contentSize = CGSizeMake([_clubPhotoVO.subjectNames count] * 90.0, emoticonsScrollView.frame.size.height);
	emoticonsScrollView.showsHorizontalScrollIndicator = NO;
	emoticonsScrollView.showsVerticalScrollIndicator = NO;
	emoticonsScrollView.pagingEnabled = NO;
	emoticonsScrollView.contentInset = UIEdgeInsetsMake(0.0, 8.0, 0.0, 0.0);
	emoticonsScrollView.contentOffset = CGPointMake(-8.0, 0.0);
	[self.contentView addSubview:emoticonsScrollView];
	
	NSMutableArray *prev = [NSMutableArray array];
	
	int cnt = 0;
	for (HONEmotionVO *emotionVO in [[HONClubAssistant sharedInstance] emotionsForClubPhoto:_clubPhotoVO]) {
		BOOL isFound = NO;
		for (NSString *name in prev) {
			if ([name isEqualToString:emotionVO.emotionName]) {
				isFound = YES;
				break;
			}
		}
		
		if (!isFound) {
			UIView *emotionView = [self _viewForEmotion:emotionVO atIndex:cnt];
			emotionView.frame = CGRectOffset(emotionView.frame, cnt * 90.0, 0.0);
			[emoticonsScrollView addSubview:emotionView];
			
			[prev addObject:emotionVO.emotionName];
			cnt++;
		}
	}
	
	
	UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	likeButton.frame = CGRectMake(-3.0, [UIScreen mainScreen].bounds.size.height - 74.0, 149, 64.0);
	[likeButton setBackgroundImage:[UIImage imageNamed:@"likeTimelineButton_nonActive"] forState:UIControlStateNormal];
	[likeButton setBackgroundImage:[UIImage imageNamed:@"likeTimelineButton_Active"] forState:UIControlStateHighlighted];
	[likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:likeButton];
	
	UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	replyButton.frame = CGRectMake(174, [UIScreen mainScreen].bounds.size.height - 74.0, 149, 64.0);
	[replyButton setBackgroundImage:[UIImage imageNamed:@"replyTimelineButton_nonActive"] forState:UIControlStateNormal];
	[replyButton setBackgroundImage:[UIImage imageNamed:@"replyTimelineButton_Active"] forState:UIControlStateHighlighted];
	[replyButton addTarget:self action:@selector(_goReply) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:replyButton];
	
	_scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(135.0, [UIScreen mainScreen].bounds.size.height - 50.0, 50.0, 16.0)];
	_scoreLabel.backgroundColor = [UIColor clearColor];
	_scoreLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:14];
	_scoreLabel.textColor = [UIColor whiteColor];
	_scoreLabel.textAlignment = NSTextAlignmentCenter;
	_scoreLabel.text = [@"" stringFromInt:_clubPhotoVO.score];
	[self.contentView addSubview:_scoreLabel];
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
	_indexPath = indexPath;
}


#pragma mark - Navigation
- (void)_goUserProfile {
	if ([self.delegate respondsToSelector:@selector(clubPhotoViewCell:showUserProfileForClubPhoto:)])
		[self.delegate clubPhotoViewCell:self showUserProfileForClubPhoto:_clubPhotoVO];
}

- (void)_goLike {
	_scoreLabel.text = [@"" stringFromInt:++_clubPhotoVO.score];
	
	if ([self.delegate respondsToSelector:@selector(clubPhotoViewCell:upvotePhoto:)])
		[self.delegate clubPhotoViewCell:self upvotePhoto:_clubPhotoVO];
}

- (void)_goReply {
	if ([self.delegate respondsToSelector:@selector(clubPhotoViewCell:replyToPhoto:)])
		[self.delegate clubPhotoViewCell:self replyToPhoto:_clubPhotoVO];
}


#pragma mark - UI Presentation
const CGRect kEmotionStartFrame = {20.0f, 20.0f, 44.0f, 44.0f};
const CGRect kEmotionLoadedFrame = {0.0f, 0.0f, 84.0f, 84.0f};

- (UIView *)_viewForEmotion:(HONEmotionVO *)emotionVO atIndex:(int)index {
	UIView *holderView = [[UIView alloc] initWithFrame:kEmotionLoadedFrame];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:holderView asLargeLoader:NO];
	imageLoadingView.alpha = 0.667;
	[imageLoadingView startAnimating];
	[holderView addSubview:imageLoadingView];
	
//	PicoSticker *picoSticker = [[PicoSticker alloc] initWithPCContent:emotionVO.pcContent];
//	[holderView addSubview:picoSticker];
	
//	PicoSticker *picoSticker = [[HONStickerAssistant sharedInstance] stickerFromCandyBoxWithContentID:emotionVO.emotionID];
//	[holderView addSubview:picoSticker];
	
	CGSize scaleSize = CGSizeMake(kEmotionStartFrame.size.width / kEmotionLoadedFrame.size.width, kEmotionStartFrame.size.height / kEmotionLoadedFrame.size.height);
	CGPoint offsetPt = CGPointMake(CGRectGetMidX(kEmotionStartFrame) - CGRectGetMidX(kEmotionLoadedFrame), CGRectGetMidY(kEmotionStartFrame) - CGRectGetMidY(kEmotionLoadedFrame));
	CGAffineTransform transform = CGAffineTransformMake(scaleSize.width, 0.0, 0.0, scaleSize.height, offsetPt.x, offsetPt.y);
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:kEmotionLoadedFrame];
	[imageView setTintColor:[UIColor whiteColor]];
	[imageView setTag:[emotionVO.emotionID intValue]];
	imageView.alpha = 0.0;
	imageView.transform = transform;
	[holderView addSubview:imageView];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		imageView.image = image;
		
		[UIView beginAnimations:@"fade" context:nil];
		[UIView setAnimationDuration:0.250];
		[UIView setAnimationDelay:0.125];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[imageView setTintColor:[UIColor clearColor]];
		[UIView commitAnimations];
		
		[UIView animateWithDuration:0.250 delay:0.50 + (0.125 * index)
			 usingSpringWithDamping:0.750 initialSpringVelocity:0.250
							options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationCurveEaseInOut)
		 
						 animations:^(void) {
							 imageView.alpha = 1.0;
							 imageView.transform = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
						 } completion:^(BOOL finished) {
							 [imageLoadingView stopAnimating];
							 [imageLoadingView removeFromSuperview];
						 }];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[imageLoadingView stopAnimating];
		[imageLoadingView removeFromSuperview];
	};
	
	[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:emotionVO.smallImageURL]
													   cachePolicy:NSURLRequestReturnCacheDataElseLoad
												   timeoutInterval:[HONAppDelegate timeoutInterval]]
					 placeholderImage:nil
							  success:imageSuccessBlock
							  failure:imageFailureBlock];
	
	
//	[self performSelector:@selector(_delayedImageLoad:) withObject:@{@"loading_view"	: imageLoadingView,
//																	 @"image_view"		: imageView,
//																	 @"emotion"			: emotionVO} afterDelay:0.1 * index];
//	
	return (holderView);
}

- (void)_delayedImageLoad:(NSDictionary *)dict {
	HONImageLoadingView *imageLoadingView = (HONImageLoadingView *)[dict objectForKey:@"loading_view"];
	UIImageView *imageView = (UIImageView *)[dict objectForKey:@"image_view"];
	HONEmotionVO *emotionVO = (HONEmotionVO *)[dict objectForKey:@"emotion"];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		imageView.image = image;
		
		[UIView beginAnimations:@"fade" context:nil];
		[UIView setAnimationDuration:0.250];
		[UIView setAnimationDelay:0.125];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[imageView setTintColor:[UIColor clearColor]];
		[UIView commitAnimations];
		
		[UIView animateWithDuration:0.250 delay:0.125
			 usingSpringWithDamping:0.667 initialSpringVelocity:0.125
							options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent)
		 
						 animations:^(void) {
							 imageView.alpha = 1.0;
							 imageView.transform = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
						 } completion:^(BOOL finished) {
							 [imageLoadingView stopAnimating];
							 [imageLoadingView removeFromSuperview];
						 }];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[imageLoadingView stopAnimating];
		[imageLoadingView removeFromSuperview];
	};
	
	[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:emotionVO.smallImageURL]
													   cachePolicy:NSURLRequestReturnCacheDataElseLoad
												   timeoutInterval:[HONAppDelegate timeoutInterval]]
					 placeholderImage:nil
							  success:imageSuccessBlock
							  failure:imageFailureBlock];
}


- (void)_nextPhoto {
	if ([self.delegate respondsToSelector:@selector(clubPhotoViewCell:advancePhoto:)])
		[self.delegate clubPhotoViewCell:self advancePhoto:_clubPhotoVO];
}


@end
