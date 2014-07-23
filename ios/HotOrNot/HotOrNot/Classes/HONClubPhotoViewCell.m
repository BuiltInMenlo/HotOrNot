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

#import "HONClubPhotoViewCell.h"
#import "HONEmotionVO.h"
#import "HONImageLoadingView.h"

@interface HONClubPhotoViewCell ()
@property (nonatomic, strong) HONImageLoadingView *imageLoadingView;
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
	_imageLoadingView.frame = CGRectOffset(_imageLoadingView.frame, 0.0, ([UIScreen mainScreen].bounds.size.height - 44.0) * 0.5);
	[self.contentView addSubview:_imageLoadingView];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	imageView.alpha = 0.0;
	[self.contentView addSubview:imageView];
	
	UIImageView *gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selfieFullSizeGradientOverlay"]];
	gradientImageView.frame = [UIScreen mainScreen].bounds;
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
		NSLog(@"ERROR:[%@]", error.description);
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[HONAppDelegate cleanImagePrefixURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeClubs completion:nil];
		
		imageView.image = [HONImagingDepictor defaultAvatarImageAtSize:([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? kSnapLargeSize : kSnapTabSize];
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
	
	UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 78.0, MIN(maxSize.width, size.width), 24.0)];
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
			
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 109.0, 200.0, 16.0)];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:12];
	timeLabel.textColor = [[HONColorAuthority sharedInstance] honLightGreyTextColor];
	timeLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.75];
	timeLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	timeLabel.text = [[[HONDateTimeAlloter sharedInstance] intervalSinceDate:_clubPhotoVO.addedDate] stringByAppendingFormat:@" ago with %d emotion%@", [_clubPhotoVO.subjectNames count], ([_clubPhotoVO.subjectNames count] != 1) ? @"s" : @""];
	[self.contentView addSubview:timeLabel];
	
	UIScrollView *emoticonsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(8.0, [UIScreen mainScreen].bounds.size.height - 160.0, 312.0, 84.0)];
	emoticonsScrollView.contentSize = CGSizeMake([_clubPhotoVO.subjectNames count] * 90.0, emoticonsScrollView.frame.size.height);
	emoticonsScrollView.showsHorizontalScrollIndicator = NO;
	emoticonsScrollView.showsVerticalScrollIndicator = NO;
	emoticonsScrollView.pagingEnabled = NO;
	[self.contentView addSubview:emoticonsScrollView];
	
	int cnt = 0;
	for (HONEmotionVO *emotionVO in [[HONClubAssistant sharedInstance] emotionsForClubPhoto:_clubPhotoVO]) {
		UIView *emotionView = [self _viewForEmotion:emotionVO];
		emotionView.frame = CGRectOffset(emotionView.frame, cnt * 90.0, 0.0);
		[emoticonsScrollView addSubview:emotionView];
		cnt++;
	}
	
	UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	likeButton.frame = CGRectMake(5.0, [UIScreen mainScreen].bounds.size.height - 74.0, 134.0, 64.0);
	[likeButton setBackgroundImage:[UIImage imageNamed:@"likeTimelineButton_nonActive"] forState:UIControlStateNormal];
	[likeButton setBackgroundImage:[UIImage imageNamed:@"likeTimelineButton_Active"] forState:UIControlStateHighlighted];
	[likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:likeButton];
	
	UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	replyButton.frame = CGRectMake(181.0, [UIScreen mainScreen].bounds.size.height - 74.0, 134.0, 64.0);
	[replyButton setBackgroundImage:[UIImage imageNamed:@"replyTimelineButton_nonActive"] forState:UIControlStateNormal];
	[replyButton setBackgroundImage:[UIImage imageNamed:@"replyTimelineButton_Active"] forState:UIControlStateHighlighted];
	[replyButton addTarget:self action:@selector(_goReply) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:replyButton];
	
	UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(135.0, [UIScreen mainScreen].bounds.size.height - 51.0, 50.0, 16.0)];
	scoreLabel.backgroundColor = [UIColor clearColor];
	scoreLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:14];
	scoreLabel.textColor = [UIColor whiteColor];
	scoreLabel.textAlignment = NSTextAlignmentCenter;
	scoreLabel.text = [@"" stringFromInt:_clubPhotoVO.score];
	[self.contentView addSubview:scoreLabel];
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
	if ([self.delegate respondsToSelector:@selector(clubPhotoViewCell:upvotePhoto:)])
		[self.delegate clubPhotoViewCell:self upvotePhoto:_clubPhotoVO];
}

- (void)_goReply {
	if ([self.delegate respondsToSelector:@selector(clubPhotoViewCell:replyToPhoto:)])
		[self.delegate clubPhotoViewCell:self replyToPhoto:_clubPhotoVO];
}


#pragma mark - UI Presentation
- (UIView *)_viewForEmotion:(HONEmotionVO *)emotionVO {
	UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 84.0, 84.0)];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:holderView asLargeLoader:NO];
	imageLoadingView.alpha = 0.667;
	[imageLoadingView startAnimating];
	[holderView addSubview:imageLoadingView];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:holderView.frame];
	[imageView setTag:emotionVO.emotionID];
	imageView.alpha = 0.0;
	[holderView addSubview:imageView];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		imageView.image = image;
		[imageLoadingView stopAnimating];
		
		[UIView animateWithDuration:0.33 delay:0.0
			 usingSpringWithDamping:0.875 initialSpringVelocity:0.5
							options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent
		 
						 animations:^(void) {
							 imageView.alpha = 1.0;
						 } completion:^(BOOL finished) {
						 }];
	};
	
	[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:emotionVO.mediumImageURL]
													   cachePolicy:NSURLRequestReturnCacheDataElseLoad
												   timeoutInterval:[HONAppDelegate timeoutInterval]]
					 placeholderImage:nil
							  success:imageSuccessBlock
							  failure:nil];
	
	return (holderView);
}

- (void)_nextPhoto {
	if ([self.delegate respondsToSelector:@selector(clubPhotoViewCell:advancePhoto:)])
		[self.delegate clubPhotoViewCell:self advancePhoto:_clubPhotoVO];
}


@end
