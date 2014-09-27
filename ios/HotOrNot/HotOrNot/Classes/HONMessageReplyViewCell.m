//
//  HONMessageReplyViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/19/2014 @ 16:07.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+AFNetworking.h"

#import "HONMessageReplyViewCell.h"
#import "HONImageLoadingView.h"

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
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"messageItemBG"]];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setMessageReplyVO:(HONOpponentVO *)messageReplyVO {
	_messageReplyVO = messageReplyVO;
	
	UIView *avatarHolderView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 10.0, 34.0, 34.0)];
	[self.contentView addSubview:avatarHolderView];
	
	UIView *challengeHolderView = [[UIView alloc] initWithFrame:CGRectMake(54.0, 54.0, 240.0, 246.0)];
	challengeHolderView.clipsToBounds = YES;
	[self.contentView addSubview:challengeHolderView];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:challengeHolderView asLargeLoader:NO];
	[imageLoadingView startAnimating];
	[challengeHolderView addSubview:imageLoadingView];
	
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 34.0, 34.0)];
	_avatarImageView.userInteractionEnabled = YES;
	[avatarHolderView addSubview:_avatarImageView];
	
	_challengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, ((kSnapTabSize.height * 0.75) - challengeHolderView.frame.size.height) * -0.5, kSnapTabSize.width * 0.75, kSnapTabSize.height * 0.75)];
	_challengeImageView.userInteractionEnabled = YES;
	[challengeHolderView addSubview:_challengeImageView];
	
	[challengeHolderView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"messageOverlay"]]];
	
	void (^avatarSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_avatarImageView.image = image;
	};
	
	void (^avatarFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[[HONAPICaller sharedInstance] normalizePrefixForImageURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeAvatars completion:nil];
	};
	
	void (^challengeSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_challengeImageView.image = image;
		[imageLoadingView stopAnimating];
		[imageLoadingView removeFromSuperview];
	};
	
	void (^challengeFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[[HONAPICaller sharedInstance] normalizePrefixForImageURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeSelfies completion:nil];
	};
	
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_messageReplyVO.avatarPrefix stringByAppendingString:kSnapThumbSuffix]]
															  cachePolicy:kOrthodoxURLCachePolicy
														  timeoutInterval:[HONAppDelegate timeoutInterval]]
							placeholderImage:nil
									 success:avatarSuccessBlock
									 failure:avatarFailureBlock];
	
	[_challengeImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_messageReplyVO.imagePrefix stringByAppendingString:kSnapTabSuffix]]
																 cachePolicy:kOrthodoxURLCachePolicy
															 timeoutInterval:[HONAppDelegate timeoutInterval]]
							   placeholderImage:nil
										success:challengeSuccessBlock
										failure:challengeFailureBlock];
	
	CGSize size;
	CGFloat maxNameWidth = 110.0;
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.0, 15.0, maxNameWidth, 19.0)];
	nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15];
	nameLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	[self.contentView addSubview:nameLabel];
	
	size = [[_messageReplyVO.username stringByAppendingString:@"…"] boundingRectWithSize:CGSizeMake(maxNameWidth, nameLabel.frame.size.height)
																				 options:NSStringDrawingTruncatesLastVisibleLine
																			  attributes:@{NSFontAttributeName:nameLabel.font}
																				 context:nil].size;
	
	nameLabel.text = (size.width >= maxNameWidth) ? _messageReplyVO.username : [_messageReplyVO.username stringByAppendingString:@"…"];
	nameLabel.frame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y, MIN(maxNameWidth, size.width), nameLabel.frame.size.height);
	
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x + (nameLabel.frame.size.width + 3.0), nameLabel.frame.origin.y, 290.0 - (nameLabel.frame.origin.x + nameLabel.frame.size.width + 3.0), nameLabel.frame.size.height)];
	subjectLabel.font = nameLabel.font;
	subjectLabel.textColor = [[HONColorAuthority sharedInstance] honLightGreyTextColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _messageReplyVO.subjectName;
	[self.contentView addSubview:subjectLabel];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(255.0, 13.0, 50.0, 15.0)];
	timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.textColor = [[HONColorAuthority sharedInstance] honLightGreyTextColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.text = [[HONDateTimeAlloter sharedInstance] intervalSinceDate:_messageReplyVO.joinedDate];
	[self.contentView addSubview:timeLabel];
	
	if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _messageReplyVO.userID) {
		avatarHolderView.frame = CGRectOffset(avatarHolderView.frame, 266.0, 0.0);
		challengeHolderView.frame = CGRectOffset(challengeHolderView.frame, -28.0, 0.0);
		
		timeLabel.frame = CGRectOffset(timeLabel.frame, -246.0, 0.0);
		timeLabel.textAlignment = NSTextAlignmentLeft;
		
		nameLabel.frame = CGRectMake((avatarHolderView.frame.origin.x - 10.0) - nameLabel.frame.size.width, nameLabel.frame.origin.y, nameLabel.frame.size.width, nameLabel.frame.size.height);
		nameLabel.textAlignment = NSTextAlignmentRight;
		nameLabel.text = (size.width >= maxNameWidth) ? _messageReplyVO.username : [@"…" stringByAppendingString:_messageReplyVO.username];
		
		subjectLabel.frame = CGRectMake((nameLabel.frame.origin.x - 3.0) - subjectLabel.frame.size.width, subjectLabel.frame.origin.y, subjectLabel.frame.size.width, nameLabel.frame.size.height);
		subjectLabel.textAlignment = NSTextAlignmentRight;
	}
}

@end
