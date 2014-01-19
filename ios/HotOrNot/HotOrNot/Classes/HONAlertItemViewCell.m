//
//  HONAlertItemViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 12/02/2013 @ 20:11 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONAlertItemViewCell.h"
#import "HONAPICaller.h"
#import "HONColorAuthority.h"
#import "HONAlertItemVO.h"
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

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		_chevronImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"activityChevron"]];
		_chevronImageView.frame = CGRectOffset(_chevronImageView.frame, 279.0, 2.0);
		_chevronImageView.hidden = YES;
		[self.contentView addSubview:_chevronImageView];
	}
	
	return (self);
}

- (id)initWithBackground:(BOOL)hasBackground {
	if ((self = [self init])) {
		if (hasBackground)
			self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"activityBackground"]];
	}
	
	return (self);
}


- (void)removeChevron {
	[_chevronImageView removeFromSuperview];
	_chevronImageView = nil;
}


- (void)setAlertItemVO:(HONAlertItemVO *)alertItemVO {
	_alertItemVO = alertItemVO;
	
	UIView *imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(7.0, 7.0, 34.0, 34.0)];
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
		[[HONAPICaller sharedInstance] notifyToProcessImageSizesForURL:_alertItemVO.avatarPrefix completion:nil];
	};
	
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_alertItemVO.avatarPrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							placeholderImage:nil
									 success:successBlock
									 failure:failureBlock];
	
	CGSize size = [_alertItemVO.username boundingRectWithSize:CGSizeMake(90.0, 22.0)
													  options:NSStringDrawingTruncatesLastVisibleLine
												   attributes:@{NSFontAttributeName:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:14]}
													  context:nil].size;
	
	
	if (size.width > 90.0)
		size = CGSizeMake(90.0, size.height);
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(51.0, 14.0, size.width, 17.0)];
	nameLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:14];
	nameLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _alertItemVO.username;
	[self.contentView addSubview:nameLabel];
	
	UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake((nameLabel.frame.origin.x + nameLabel.frame.size.width) + 4.0, nameLabel.frame.origin.y, 225.0 - nameLabel.frame.size.width, nameLabel.frame.size.height)];
	messageLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:14];
	messageLabel.textColor = [[HONColorAuthority sharedInstance] honLightGreyTextColor];
	messageLabel.backgroundColor = [UIColor clearColor];
	messageLabel.text = _alertItemVO.message;
	[self.contentView addSubview:messageLabel];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(255.0, 14.0, 50.0, 17.0)];
	timeLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:14];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.text = [HONAppDelegate timeSinceDate:_alertItemVO.sentDate];
	[self addSubview:timeLabel];
	
	UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
	selectButton.frame = CGRectMake(0.0, 0.0, 320.0, 49.0);
	[selectButton setBackgroundImage:[UIImage imageNamed:@"discoveryOverlay"] forState:UIControlStateHighlighted];
	[selectButton addTarget:self action:@selector(_goSelect) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:selectButton];
}


#pragma mark - Navigation {
- (void)_goSelect {
	[self.delegate alertItemViewCell:self alertItem:_alertItemVO];
}


@end
