//
//  HONAlertItemViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 12/02/2013 @ 20:11 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+BuiltinMenlo.h"
#import "UIImageView+AFNetworking.h"
#import "UILabel+BuiltinMenlo.h"

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
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"activityRowBG"]];
		[self hideChevron];
	}
	
	return (self);
}

- (void)setActivityItemVO:(HONActivityItemVO *)activityItemVO {
	_activityItemVO = activityItemVO;
	
//	UIView *imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 9.0, 45.0, 45.0)];
//	[self.contentView addSubview:imageHolderView];
//	
//	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:imageHolderView asLargeLoader:NO];
//	[imageLoadingView startAnimating];
//	[imageHolderView addSubview:imageLoadingView];
//	
//	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectFromSize(imageHolderView.frame.size)];
//	_avatarImageView.userInteractionEnabled = YES;
//	[imageHolderView addSubview:_avatarImageView];
//	
//	[[HONViewDispensor sharedInstance] maskView:_avatarImageView withMask:[UIImage imageNamed:@"avatarMask"]];
//	
//	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//		_avatarImageView.image = image;
//		
//		[UIView animateWithDuration:0.25 animations:^(void) {
//			_avatarImageView.alpha = 1.0;
//		} completion:^(BOOL finished) {
//			[imageLoadingView stopAnimating];
//			[imageLoadingView removeFromSuperview];
//		}];
//	};
//	
//	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
//		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[[HONAPICaller sharedInstance] normalizePrefixForImageURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeAvatars completion:nil];
//		_avatarImageView.image = [UIImage imageNamed:@"activityAvatarBG"];
//	};
//	
//	if ([_activityItemVO.originAvatarPrefix rangeOfString:@"defaultAvatar"].location != NSNotFound) {
//		_avatarImageView.image = [UIImage imageNamed:@"activityAvatarBG"];
//		[imageLoadingView stopAnimating];
//		[imageLoadingView removeFromSuperview];
//	
//	} else {
//		[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_activityItemVO.originAvatarPrefix stringByAppendingString:kSnapThumbSuffix]]
//																  cachePolicy:kOrthodoxURLCachePolicy
//															  timeoutInterval:[HONAppDelegate timeoutInterval]]
//								placeholderImage:[UIImage imageNamed:@"activityAvatarBG"]
//										 success:successBlock
//										 failure:failureBlock];
//	}
//	
//	
//	UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	avatarButton.frame = imageHolderView.frame;
//	avatarButton.backgroundColor = [[HONColorAuthority sharedInstance] honDebugDefaultColor];
//	[avatarButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
//	[self.contentView addSubview:avatarButton];
//
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(9.0, 7.0, 252.0, 28.0)];
	titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
	titleLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.text = [NSLocalizedString(@"act_upvote", @"Up vote from") stringByAppendingString:_activityItemVO.originUsername]; // 투표하기 James
	[self.contentView addSubview:titleLabel];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(270.0, titleLabel.frame.origin.y, 40.0, titleLabel.frame.size.height)];
	timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
	timeLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.text = [[HONDateTimeAlloter sharedInstance] intervalSinceDate:_activityItemVO.sentDate includeSuffix:@""];
	[self.contentView addSubview:timeLabel];
	
//	UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y + 22.0, 202.0, 20.0)];
//	subtitleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
//	subtitleLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
//	subtitleLabel.backgroundColor = [UIColor clearColor];
//	subtitleLabel.text = @"Seoul, Korea";
//	[self.contentView addSubview:subtitleLabel];
	
//	_indicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kakaoBG"]];
//	_indicatorImageView.frame = CGRectOffset(_indicatorImageView.frame, 256.0, 0.0);
//	[self.contentView addSubview:_indicatorImageView];
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
	if (_activityItemVO.originUserID != [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) {
		if ([self.delegate respondsToSelector:@selector(activityItemViewCell:showProfileForUser:)])
			[self.delegate activityItemViewCell:self showProfileForUser:[HONTrivialUserVO userFromActivityItemVO:_activityItemVO]];
	}
}


@end
