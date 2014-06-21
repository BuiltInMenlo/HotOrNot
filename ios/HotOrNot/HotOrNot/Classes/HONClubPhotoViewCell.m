//
//  HONClubPhotoViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/14/2014 @ 21:59 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "UILabel+BoundingRect.h"
#import "UILabel+FormattedText.h"

#import "HONClubPhotoViewCell.h"
#import "HONEmotionVO.h"

@interface HONClubPhotoViewCell ()
@end

@implementation HONClubPhotoViewCell
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
	
	NSString *emotions = @"";
	for (NSString *subject in clubPhotoVO.subjectNames)
		emotions = [emotions stringByAppendingFormat:@"%@, ", subject];
		
	if ([emotions length] > 0)
		emotions = [emotions substringToIndex:[emotions length] - 2];
	
	
	NSString *titleCaption = [NSString stringWithFormat:@"%@ is feeling %@", _clubPhotoVO.username, emotions];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	imageView.alpha = 0.0;
	[self.contentView addSubview:imageView];
	
	void (^avatarImageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		imageView.image = image;
		[UIView animateWithDuration:0.25 animations:^(void) {
			imageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^avatarImageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[HONAppDelegate cleanImagePrefixURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeClubs completion:nil];
		
		imageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapThumbSize];
		[UIView animateWithDuration:0.25 animations:^(void) {
			imageView.alpha = 1.0;
		} completion:nil];
	};
	
	[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_clubPhotoVO.imagePrefix stringByAppendingString:([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? kSnapLargeSuffix : kSnapTabSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
					 placeholderImage:nil
							  success:avatarImageSuccessBlock
							  failure:avatarImageFailureBlock];
	
	
	UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	avatarButton.frame = imageView.frame;
	[avatarButton addTarget:self action:@selector(_goUserProfile) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:avatarButton];
	
	
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.minimumLineHeight = 31.0;
	paragraphStyle.maximumLineHeight = paragraphStyle.minimumLineHeight;
	
	CGSize maxSize = CGSizeMake(300.0, 38.0);
	CGSize size = [titleCaption boundingRectWithSize:maxSize
											 options:NSStringDrawingTruncatesLastVisibleLine
										  attributes:@{NSFontAttributeName:[[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:17], NSParagraphStyleAttributeName:paragraphStyle}
											 context:nil].size;
	
	UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - (220.0 + ((int)(size.width > maxSize.width) * 34.0)), 320.0, 220.0 + ((int)(size.width > maxSize.width) * 34.0))];
	[self.contentView addSubview:footerView];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 0.0, maxSize.width, 30.0 + ((int)(size.width > maxSize.width) * 34.0))];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:17];
	titleLabel.numberOfLines = 1 + (int)(size.width > maxSize.width);
	[footerView addSubview:titleLabel];
	
	titleLabel.text = @"";
	titleLabel.attributedText = [[NSAttributedString alloc] initWithString:titleCaption attributes:@{NSParagraphStyleAttributeName	: paragraphStyle}];
	
	[titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:17] range:[titleCaption rangeOfString:_clubPhotoVO.username]];
	[titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:17] range:[titleCaption rangeOfString:emotions]];
	
	
	UIButton *usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	usernameButton.frame = [titleLabel boundingRectForCharacterRange:[titleCaption rangeOfString:_clubPhotoVO.username]];
	[usernameButton addTarget:self action:@selector(_goUserProfile) forControlEvents:UIControlEventTouchUpInside];
	[footerView addSubview:usernameButton];
	
	
	NSString *timeCaption = [NSString stringWithFormat:@"%@ in %@", [[HONDateTimeAlloter sharedInstance] intervalSinceDate:_clubPhotoVO.addedDate], _clubName];
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 11.0 + titleLabel.frame.origin.y + titleLabel.frame.size.height, 300.0, 16.0)];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:12];
	timeLabel.textColor = [[HONColorAuthority sharedInstance] honLightGreyTextColor];
	timeLabel.text = timeCaption;
	[timeLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:12] range:[timeCaption rangeOfString:_clubName]];
	[footerView addSubview:timeLabel];
	
	UIView *emoticonsView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 10.0 + timeLabel.frame.origin.y + timeLabel.frame.size.height, 300.0, 48.0)];
	[footerView addSubview:emoticonsView];
	
	int tot = 0;
	for (HONEmotionVO *emotionVO in [[HONClubAssistant sharedInstance] emotionsForClubPhoto:_clubPhotoVO]) {
		UIImageView *emotionImageView = [self _imageViewForEmotion:emotionVO];
		emotionImageView.frame = CGRectOffset(emotionImageView.frame, tot * 63, 0.0);
		[emoticonsView addSubview:emotionImageView];
		tot++;
	}
	
	UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	likeButton.frame = CGRectMake(5.0, footerView.frame.size.height - 114.0, 134.0, 64.0);
	[likeButton setBackgroundImage:[UIImage imageNamed:@"likeTimelineButton_nonActive"] forState:UIControlStateNormal];
	[likeButton setBackgroundImage:[UIImage imageNamed:@"likeTimelineButton_Active"] forState:UIControlStateHighlighted];
	[likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	[footerView addSubview:likeButton];
	
	UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	replyButton.frame = CGRectMake(181.0, footerView.frame.size.height - 114.0, 134.0, 64.0);
	[replyButton setBackgroundImage:[UIImage imageNamed:@"replyTimelineButton_nonActive"] forState:UIControlStateNormal];
	[replyButton setBackgroundImage:[UIImage imageNamed:@"replyTimelineButton_Active"] forState:UIControlStateHighlighted];
	[replyButton addTarget:self action:@selector(_goReply) forControlEvents:UIControlEventTouchUpInside];
	[footerView addSubview:replyButton];
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
- (UIImageView *)_imageViewForEmotion:(HONEmotionVO *)emotionVO {
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 48.0, 48.0)];
	[imageView setTag:emotionVO.emotionID];
	imageView.alpha = 0.0;
	
	[HONImagingDepictor maskImageView:imageView withMask:[UIImage imageNamed:@"emoticonMask"]];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		imageView.image = image;
		
		[UIView animateWithDuration:0.33 delay:0.0
			 usingSpringWithDamping:0.875 initialSpringVelocity:0.5
							options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent
		 
						 animations:^(void) {
							 imageView.alpha = 1.0;
						 } completion:^(BOOL finished) {
						 }];
	};
	
	[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:emotionVO.imageURL] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
					 placeholderImage:nil
							  success:imageSuccessBlock
							  failure:nil];
	
	return (imageView);
}


@end
