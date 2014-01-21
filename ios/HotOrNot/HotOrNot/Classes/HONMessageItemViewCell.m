//
//  HONMessageItemViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/18/2014 @ 20:19 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONMessageItemViewCell.h"
#import "HONAPICaller.h"
#import "HONColorAuthority.h"
#import "HONImageLoadingView.h"

@interface HONMessageItemViewCell ()
@property (nonatomic, strong) UIImageView *avatarImageView;
@end

@implementation HONMessageItemViewCell
@synthesize delegate = _delegate;
@synthesize messageVO = _messageVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setMessageVO:(HONMessageVO *)messageVO {
	_messageVO = messageVO;
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
	
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
		[[HONAPICaller sharedInstance] notifyToProcessImageSizesForURL:_messageVO.creatorVO.avatarURL completion:nil];
	};
	
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_messageVO.creatorVO.avatarURL stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							placeholderImage:nil
									 success:successBlock
									 failure:failureBlock];
	
	CGSize size = [_messageVO.creatorVO.username boundingRectWithSize:CGSizeMake(90.0, 22.0)
															  options:NSStringDrawingTruncatesLastVisibleLine
														   attributes:@{NSFontAttributeName:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:14]}
															  context:nil].size;
	
	
	if (size.width > 90.0)
		size = CGSizeMake(90.0, size.height);
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(51.0, 14.0, size.width, 17.0)];
	nameLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:14];
	nameLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _messageVO.creatorVO.username;
	[self.contentView addSubview:nameLabel];
	
	UIButton *detailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	detailsButton.frame = CGRectMake(0.0, 0.0, 320.0, kOrthodoxTableCellHeight);
	[detailsButton addTarget:self action:@selector(_goDetails) forControlEvents:UIControlEventTouchDown];
	[self.contentView addSubview:detailsButton];
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


#pragma mark - Navigation
- (void)_goDetails {
	[self.delegate messageItemViewCell:self showMessage:_messageVO];
}

@end
