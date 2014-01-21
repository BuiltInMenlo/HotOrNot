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

@interface HONMessageReplyViewCell ()
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *challengeImageView;
@property (nonatomic, strong) UIImageView *replyImageView;
@end

@implementation HONMessageReplyViewCell
@synthesize delegate = _delegate;
@synthesize messageReplyVO = _messageReplyVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setMessageReplyVO:(HONOpponentVO *)messageReplyVO {
	_messageReplyVO = messageReplyVO;
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
	
	UIView *avatarHolderView = [[UIView alloc] initWithFrame:CGRectMake(7.0, 7.0, 34.0, 34.0)];
	[self.contentView addSubview:avatarHolderView];
	
	UIView *challengeHolderView = [[UIView alloc] initWithFrame:CGRectMake(55.0, 7.0, kSnapThumbSize.width, kSnapThumbSize.height)];
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
	
	void (^challengeSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_challengeImageView.image = image;
		[imageLoadingView stopAnimating];
		[imageLoadingView removeFromSuperview];
	};
	
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToProcessImageSizesForURL:_messageReplyVO.avatarURL completion:nil];
	};
	
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_messageReplyVO.avatarURL stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							placeholderImage:nil
									 success:avatarSuccessBlock
									 failure:failureBlock];
	
	[_challengeImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_messageReplyVO.imagePrefix stringByAppendingString:kSnapMediumSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							   placeholderImage:nil
										success:challengeSuccessBlock
										failure:failureBlock];
}

@end
