//
//  HONAlertItemViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 12/02/2013 @ 20:11 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONActivityItemViewCell.h"
#import "HONImageLoadingView.h"

@interface HONActivityItemViewCell ()
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *messageLabel;
@property (nonatomic, strong) UIImageView *indicatorImageView;
@property (nonatomic, strong) UIView *tappedOverlayView;
@property (nonatomic, strong) UIImageView *chevronImageView;
@end

@implementation HONActivityItemViewCell
@synthesize delegate = _delegate;
@synthesize activityItemVO = _activityItemVO;

- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"activityRowBG_normal"]];
		[self hideChevron];
	}
	
	return (self);
}

- (void)setActivityItemVO:(HONActivityItemVO *)activityItemVO {
	_activityItemVO = activityItemVO;
	
	if (_activityItemVO.userID == 131795) {
		_activityItemVO.username = @"selfielover";
		_activityItemVO.avatarPrefix = @"https://d3j8du2hyvd35p.cloudfront.net/c6d8484284ea433cb38230b885a88a40_b8d329e3e587426f9dacb5dffdb91e93-1397110043";
	}
	
	UIView *imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(7.0, 9.0, 25.0, 25.0)];
	[self.contentView addSubview:imageHolderView];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:imageHolderView asLargeLoader:NO];
	[imageLoadingView startAnimating];
	[imageHolderView addSubview:imageLoadingView];
	
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, imageHolderView.frame.size.width, imageHolderView.frame.size.height)];
	_avatarImageView.userInteractionEnabled = YES;
	[imageHolderView addSubview:_avatarImageView];
	
	[HONImagingDepictor maskImageView:_avatarImageView withMask:[UIImage imageNamed:@"avatarMask"]];
	
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
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:_activityItemVO.avatarPrefix forBucketType:HONS3BucketTypeAvatars completion:nil];
	};
	
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_activityItemVO.avatarPrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							placeholderImage:nil
									 success:successBlock
									 failure:failureBlock];
	
	
	UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	avatarButton.frame = _avatarImageView.frame;
	[avatarButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:avatarButton];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(41.0, 12.0, 195.0, 17.0)];
	nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
	nameLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = [NSString stringWithFormat:@"%@ %@", _activityItemVO.username, _activityItemVO.message];
	[self.contentView addSubview:nameLabel];
	
	_indicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"activityDot"]];
	_indicatorImageView.frame = CGRectOffset(_indicatorImageView.frame, 298.0, 16.0);
	[self.contentView addSubview:_indicatorImageView];
}

- (void)hideIndicator {
	[UIView animateWithDuration:0.125 animations:^(void) {
		_indicatorImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[_indicatorImageView removeFromSuperview];
		_indicatorImageView = nil;
	}];
}


#pragma mark - Navigation {
- (void)_goProfile {
	if ([self.delegate respondsToSelector:@selector(activityItemViewCell:showProfileForUser:)])
		[self.delegate activityItemViewCell:self showProfileForUser:[HONTrivialUserVO userFromActivityItemVO:_activityItemVO]];
}


@end
