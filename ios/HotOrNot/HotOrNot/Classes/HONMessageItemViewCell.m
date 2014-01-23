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
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setMessageVO:(HONMessageVO *)messageVO {
	_messageVO = messageVO;
	
	NSString *avatarPrefix = ((HONOpponentVO *)[_messageVO.participants lastObject]).avatarPrefix;
	NSString *username = ((HONOpponentVO *)[_messageVO.participants lastObject]).username;
		
	_unviewedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emoticon_blue"]];
	_unviewedImageView.frame = CGRectOffset(_unviewedImageView.frame, 0.0, 12.0);
	_unviewedImageView.hidden = (_messageVO.hasViewed);
	[self.contentView addSubview:_unviewedImageView];
	
	UIView *imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(20.0, 7.0, 34.0, 34.0)];
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
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForURL:avatarPrefix forAvatarBucket:YES completion:nil];
	};
	
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[avatarPrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							placeholderImage:nil
									 success:successBlock
									 failure:failureBlock];
	
	CGSize size = [username boundingRectWithSize:CGSizeMake(200.0, 17.0)
										 options:NSStringDrawingTruncatesLastVisibleLine
									  attributes:@{NSFontAttributeName:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:14]}
										 context:nil].size;
	
	
	if (size.width > 200.0)
		size = CGSizeMake(200.0, size.height);
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(61.0, 14.0, size.width, 17.0)];
	nameLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:14];
	nameLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = username;
	[self.contentView addSubview:nameLabel];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(255.0, 17.0, 50.0, 14.0)];
	timeLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:12];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.text = [HONAppDelegate timeSinceDate:_messageVO.updatedDate];
	[self.contentView addSubview:timeLabel];
	
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

- (void)updateAsSeen {
	_unviewedImageView.hidden = YES;
}


#pragma mark - Navigation
- (void)_goDetails {
	[self.delegate messageItemViewCell:self showMessage:_messageVO];
}

@end
