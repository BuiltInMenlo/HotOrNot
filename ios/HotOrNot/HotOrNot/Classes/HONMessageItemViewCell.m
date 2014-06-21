//
//  HONMessageItemViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/18/2014 @ 20:19 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONMessageItemViewCell.h"
#import "HONImageLoadingView.h"

@interface HONMessageItemViewCell ()
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *unviewedImageView;
@end

@implementation HONMessageItemViewCell
@synthesize delegate = _delegate;
@synthesize messageVO = _messageVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"activityBackground"]];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setMessageVO:(HONMessageVO *)messageVO {
	_messageVO = messageVO;
	
	NSString *avatarPrefix = ((HONOpponentVO *)[_messageVO.participants lastObject]).avatarPrefix;
	NSString *usernames = @"";
	for (NSString *username in _messageVO.participantNames)
		usernames = [[usernames stringByAppendingString:username] stringByAppendingString:@", "];
	usernames = [usernames substringToIndex:[usernames length] - 2];
	
	_unviewedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"msg_greenDot"]];
	_unviewedImageView.frame = CGRectOffset(_unviewedImageView.frame, 263.0, 30.0);
	_unviewedImageView.hidden = (_messageVO.hasViewed);
	[self.contentView addSubview:_unviewedImageView];
	
	UIView *imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 10.0, 54.0, 54.0)];
	[self.contentView addSubview:imageHolderView];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:imageHolderView asLargeLoader:NO];
	[imageLoadingView startAnimating];
	[imageHolderView addSubview:imageLoadingView];
	
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, imageHolderView.frame.size.width, imageHolderView.frame.size.height)];
	_avatarImageView.userInteractionEnabled = YES;
	[imageHolderView addSubview:_avatarImageView];
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_avatarImageView.alpha = (int)((request.URL == nil));
		_avatarImageView.image = image;
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_avatarImageView.alpha = 1.0;
		} completion:^(BOOL finished) {
			[imageLoadingView stopAnimating];
			[imageLoadingView removeFromSuperview];
		}];
	};
	
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[HONAppDelegate cleanImagePrefixURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeAvatars completion:nil];
	};
	
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[avatarPrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							placeholderImage:nil
									 success:successBlock
									 failure:failureBlock];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 19.0, 150.0, 19.0)];
	nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15];
	nameLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = usernames;
	[self.contentView addSubview:nameLabel];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 37.0, 150.0, 17.0)];
	subjectLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
	subjectLabel.textColor = [[HONColorAuthority sharedInstance] honLightGreyTextColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _messageVO.subjectName;
	[self.contentView addSubview:subjectLabel];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(250.0, 29.0, 50.0, 15.0)];
	timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.textColor = [[HONColorAuthority sharedInstance] honLightGreyTextColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.text = [[HONDateTimeAlloter sharedInstance] intervalSinceDate:_messageVO.updatedDate];
	[self.contentView addSubview:timeLabel];
}

- (void)showTapOverlay {
	UIView *tappedOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kOrthodoxTableCellHeight)];
	tappedOverlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.85];
	[self.contentView addSubview:tappedOverlayView];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		tappedOverlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[tappedOverlayView removeFromSuperview];
	}];
}

- (void)updateAsSeen {
	_unviewedImageView.hidden = YES;
}


#pragma mark - Navigation
- (void)_goProfile {
	[self.delegate messageItemViewCell:self showProfileForParticipant:_messageVO.creatorVO forMessage:_messageVO];
}


@end
