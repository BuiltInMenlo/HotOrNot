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
	
	UIView *imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(17.0, 9.0, 28.0, 28.0)];
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
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[HONAppDelegate cleanImagePrefixURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeAvatars completion:nil];
	};
	
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_activityItemVO.avatarPrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							placeholderImage:nil
									 success:successBlock
									 failure:failureBlock];
	
	
	UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	avatarButton.frame = _avatarImageView.frame;
	[avatarButton addTarget:self action:@selector(_goProfile) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:avatarButton];
	
	
	NSString *caption = [NSString stringWithFormat:@"%@", _activityItemVO.username];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(53.0, 13.0, 180.0, 17.0)];
	nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:13];
	nameLabel.textColor = [UIColor blackColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _activityItemVO.username;
	[self.contentView addSubview:nameLabel];
	
	
	CGSize maxSize = CGSizeMake(nameLabel.frame.size.width, nameLabel.frame.size.height);
	CGSize size = [caption boundingRectWithSize:maxSize
											 options:NSStringDrawingTruncatesLastVisibleLine
										  attributes:@{NSFontAttributeName:nameLabel.font}
											 context:nil].size;
	nameLabel.frame = CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.origin.y, MIN(maxSize.width, size.width), nameLabel.frame.size.height);
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x + nameLabel.frame.size.width + 4.0, nameLabel.frame.origin.y, 50.0, nameLabel.frame.size.height)];
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
