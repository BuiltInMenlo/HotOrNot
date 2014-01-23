//
//  HONMessageReplyViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/19/2014 @ 16:07.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONMessageReplyViewCell.h"
#import "HONImageLoadingView.h"
#import "HONAPICaller.h"
#import "HONColorAuthority.h"

@interface HONMessageReplyViewCell ()
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *challengeImageView;
@property (nonatomic, strong) UIImageView *replyImageView;
@property (nonatomic) BOOL isAuthor;
@end

@implementation HONMessageReplyViewCell
@synthesize delegate = _delegate;
@synthesize messageReplyVO = _messageReplyVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)initAsAuthor:(BOOL)isAuthor {
	if ((self = [super init])) {
		_isAuthor = isAuthor;
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setMessageReplyVO:(HONOpponentVO *)messageReplyVO {
	_messageReplyVO = messageReplyVO;
	
	UIView *avatarHolderView = [[UIView alloc] initWithFrame:CGRectMake((_isAuthor) ? 275.0 : 7.0, 7.0, 34.0, 34.0)];
	[self.contentView addSubview:avatarHolderView];
	
	UIView *challengeHolderView = [[UIView alloc] initWithFrame:CGRectMake((_isAuthor) ? 250.0 - kSnapThumbSize.width : 55.0, 7.0, kSnapThumbSize.width, kSnapThumbSize.height)];
	[self.contentView addSubview:challengeHolderView];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:challengeHolderView asLargeLoader:NO];
	[imageLoadingView startAnimating];
	[challengeHolderView addSubview:imageLoadingView];
	
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, avatarHolderView.frame.size.width, avatarHolderView.frame.size.height)];
	_avatarImageView.userInteractionEnabled = YES;
	[avatarHolderView addSubview:_avatarImageView];
	
	_challengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapThumbSize.width, kSnapThumbSize.height)];
	_challengeImageView.userInteractionEnabled = YES;
	[challengeHolderView addSubview:_challengeImageView];
	
	void (^avatarSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_avatarImageView.image = image;
	};
	
	void (^avatarFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForURL:_messageReplyVO.avatarPrefix forAvatarBucket:YES completion:nil];
	};
	
	void (^challengeSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_challengeImageView.image = image;
		[imageLoadingView stopAnimating];
		[imageLoadingView removeFromSuperview];
	};
	
	void (^challengeFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForURL:_messageReplyVO.avatarPrefix forAvatarBucket:NO completion:nil];
	};
	
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_messageReplyVO.avatarPrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							placeholderImage:nil
									 success:avatarSuccessBlock
									 failure:avatarFailureBlock];
	
	[_challengeImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_messageReplyVO.imagePrefix stringByAppendingString:kSnapMediumSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							   placeholderImage:nil
										success:challengeSuccessBlock
										failure:challengeFailureBlock];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake((_isAuthor) ? 7.0 : 255.0, 17.0, 50.0, 14.0)];
	timeLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:12];
	timeLabel.textAlignment = (_isAuthor) ? NSTextAlignmentLeft : NSTextAlignmentRight;
	timeLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.text = [HONAppDelegate timeSinceDate:_messageReplyVO.joinedDate];
	[self.contentView addSubview:timeLabel];
}

@end
