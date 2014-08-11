//
//  HONAlertItemViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 12/02/2013 @ 20:11 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UILabel+BoundingRect.h"
#import "UILabel+FormattedText.h"
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
	
	UIView *imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(17.0, 9.0, 28.0, 28.0)];
	[self.contentView addSubview:imageHolderView];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:imageHolderView asLargeLoader:NO];
	[imageLoadingView startAnimating];
	[imageHolderView addSubview:imageLoadingView];
	
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, imageHolderView.frame.size.width, imageHolderView.frame.size.height)];
	_avatarImageView.userInteractionEnabled = YES;
	[imageHolderView addSubview:_avatarImageView];
	
	[[HONImageBroker sharedInstance] maskView:_avatarImageView withMask:[UIImage imageNamed:@"avatarMask"]];
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_avatarImageView.image = image;
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_avatarImageView.alpha = 1.0;
		} completion:^(BOOL finished) {
			[imageLoadingView stopAnimating];
			[imageLoadingView removeFromSuperview];
		}];
	};
	
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[[HONAPICaller sharedInstance] normalizePrefixForImageURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeAvatars completion:nil];
		_avatarImageView.image = [UIImage imageNamed:@"activityAvatarPlaceholder"];
	};
	
	if ([_activityItemVO.avatarPrefix rangeOfString:@"defaultAvatar"].location != NSNotFound) {
		_avatarImageView.image = [UIImage imageNamed:@"activityAvatarPlaceholder"];
		[imageLoadingView stopAnimating];
		[imageLoadingView removeFromSuperview];
	}
	
	else {
		[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_activityItemVO.avatarPrefix stringByAppendingString:kSnapThumbSuffix]]
																  cachePolicy:kURLRequestCachePolicy
															  timeoutInterval:[HONAppDelegate timeoutInterval]]
								placeholderImage:[UIImage imageNamed:@"activityAvatarPlaceholder"]
										 success:successBlock
										 failure:failureBlock];
	}
	
	
	UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	avatarButton.frame = imageHolderView.frame;
	[avatarButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:avatarButton];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(53.0, 13.0, 200.0, 17.0)];
	titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
	titleLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.attributedText = [[NSAttributedString alloc] initWithString:_activityItemVO.message attributes:@{}];
	[titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:13] range:[_activityItemVO.message rangeOfString:_activityItemVO.username]];
	[titleLabel setTextColor:[UIColor blackColor] range:[_activityItemVO.message rangeOfString:_activityItemVO.username]];
	[titleLabel setTextColor:[UIColor blackColor] range:[_activityItemVO.message rangeOfString:_activityItemVO.clubName]];
	[titleLabel resizeWidthUsingCaption:_activityItemVO.message boundedBySize:titleLabel.frame.size];
	[self.contentView addSubview:titleLabel];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x + titleLabel.frame.size.width + 2.0, titleLabel.frame.origin.y, 50.0, titleLabel.frame.size.height)];
	timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:13];
	timeLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.text = [[HONDateTimeAlloter sharedInstance] intervalSinceDate:_activityItemVO.sentDate minSeconds:0 usingIndicators:@{@"seconds"	: @[@"sec", @"s"],
																																	@"minutes"	: @[@"min", @"s"],
																																	@"hours"	: @[@"hr", @"s"],
																																	@"days"		: @[@"dy", @"s"]} includeSuffix:@""];
	[self.contentView addSubview:timeLabel];
	
	_indicatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(295.0, 16.0, 13.0, 13.0)];
	_indicatorImageView.image = [UIImage imageNamed:@"redDot"];
	_indicatorImageView.hidden = ([[[HONDateTimeAlloter sharedInstance] utcNowDate] timeIntervalSinceDate:_activityItemVO.sentDate] > 1800);
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
	if (_activityItemVO.userID != [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) {
		if ([self.delegate respondsToSelector:@selector(activityItemViewCell:showProfileForUser:)])
			[self.delegate activityItemViewCell:self showProfileForUser:[HONTrivialUserVO userFromActivityItemVO:_activityItemVO]];
	}
}


@end
