//
//  HONAlertItemViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 12/02/2013 @ 20:11 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONAlertItemViewCell.h"
#import "HONUtilsSuite.h"
#import "HONColorAuthority.h"
#import "HONFontAllocator.h"
#import "HONAlertItemVO.h"
#import "HONImagingDepictor.h"
#import "HONImageLoadingView.h"

@interface HONAlertItemViewCell ()
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *messageLabel;
@property (nonatomic, strong) UIView *tappedOverlayView;
@property (nonatomic, strong) UIImageView *chevronImageView;
@end

@implementation HONAlertItemViewCell
@synthesize delegate = _delegate;
@synthesize alertItemVO = _alertItemVO;

- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"activityRowBackground"]];
		[self hideChevron];
		
		UIImageView *chevronImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron"]];
		chevronImageView.frame = CGRectOffset(chevronImageView.frame, 294.0, 9.0);
		[self.contentView addSubview:chevronImageView];
	}
	
	return (self);
}

- (void)setAlertItemVO:(HONAlertItemVO *)alertItemVO {
	_alertItemVO = alertItemVO;
	
	if (_alertItemVO.userID == 131795) {
		_alertItemVO.username = @"selfielover";
		_alertItemVO.avatarPrefix = @"https://d3j8du2hyvd35p.cloudfront.net/c6d8484284ea433cb38230b885a88a40_b8d329e3e587426f9dacb5dffdb91e93-1397110043";
	}
	
//	UIView *imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(7.0, 8.0, 48.0, 48.0)];
	UIView *imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(7.0, 9.0, 25.0, 25.0)];
	[self.contentView addSubview:imageHolderView];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:imageHolderView asLargeLoader:NO];
	[imageLoadingView startAnimating];
	[imageHolderView addSubview:imageLoadingView];
	
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, imageHolderView.frame.size.width, imageHolderView.frame.size.height)];
	_avatarImageView.userInteractionEnabled = YES;
	[imageHolderView addSubview:_avatarImageView];
	
	[HONImagingDepictor maskImageView:_avatarImageView withMask:[UIImage imageNamed:@"maskAvatarBlack.png"]];
	
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
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:_alertItemVO.avatarPrefix forBucketType:HONS3BucketTypeAvatars completion:nil];
	};
	
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_alertItemVO.avatarPrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							placeholderImage:nil
									 success:successBlock
									 failure:failureBlock];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(41.0, 12.0, 195.0, 17.0)];
	nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
	nameLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = [NSString stringWithFormat:@"%@ %@", _alertItemVO.username, _alertItemVO.message];
	[self.contentView addSubview:nameLabel];
	
//	UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake((nameLabel.frame.origin.x + nameLabel.frame.size.width) + 4.0, nameLabel.frame.origin.y, 225.0 - nameLabel.frame.size.width, nameLabel.frame.size.height)];
//	messageLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
//	messageLabel.textColor = [[HONColorAuthority sharedInstance] honLightGreyTextColor];
//	messageLabel.backgroundColor = [UIColor clearColor];
//	messageLabel.text = _alertItemVO.message;
//	[self.contentView addSubview:messageLabel];
	
//	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(255.0, 14.0, 50.0, 17.0)];
//	timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:14];
//	timeLabel.textAlignment = NSTextAlignmentRight;
//	timeLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
//	timeLabel.backgroundColor = [UIColor clearColor];
//	timeLabel.text = [HONAppDelegate timeSinceDate:_alertItemVO.sentDate];
//	[self addSubview:timeLabel];
	
	UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
	selectButton.frame = CGRectMake(0.0, 0.0, 320.0, kOrthodoxTableCellHeight);
	[selectButton setBackgroundImage:[UIImage imageNamed:@"discoveryOverlay"] forState:UIControlStateHighlighted];
	[selectButton addTarget:self action:@selector(_goSelect) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:selectButton];
}


#pragma mark - Navigation {
- (void)_goSelect {
	[self.delegate alertItemViewCell:self alertItem:_alertItemVO];
}


@end
