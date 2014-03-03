//
//  HONAllowContactViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 02/28/2014 @ 17:26 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONAllowContactViewCell.h"
#import "HONAPICaller.h"
#import "HONColorAuthority.h"
#import "HONFontAllocator.h"
#import "HONImagingDepictor.h"

@interface HONAllowContactViewCell ()
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIButton *blockButton;
@end

@implementation HONAllowContactViewCell
@synthesize delegate = _delegate;
@synthesize userVO = _userVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rowBackground"]];
		
		_addButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_addButton.frame = CGRectMake(190.0, 0.0, 64.0, 64.0);
		[_addButton setBackgroundImage:[UIImage imageNamed:@"addButton_nonActive"] forState:UIControlStateNormal];
		[_addButton setBackgroundImage:[UIImage imageNamed:@"addButton_Active"] forState:UIControlStateHighlighted];
		[_addButton addTarget:self action:@selector(_goAdd) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_addButton];
		
		_blockButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_blockButton.frame = CGRectMake(251.0, 0.0, 64.0, 64.0);
		[_blockButton setBackgroundImage:[UIImage imageNamed:@"blockButton_nonActive"] forState:UIControlStateNormal];
		[_blockButton setBackgroundImage:[UIImage imageNamed:@"blockButton_Active"] forState:UIControlStateHighlighted];
		[_blockButton addTarget:self action:@selector(_goBlock) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_blockButton];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setUserVO:(HONTrivialUserVO *)userVO {
	_userVO = userVO;
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0, 8.0, kTableCellAvatarSize.width * 0.5, kTableCellAvatarSize.height * 0.5)];
	avatarImageView.alpha = 0.0;
	[self addSubview:avatarImageView];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		avatarImageView.image = image;
		
		[HONImagingDepictor maskImageView:avatarImageView withMask:[UIImage imageNamed:@"maskAvatar.png"]];
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForURL:_userVO.avatarPrefix forAvatarBucket:YES completion:nil];
		
		avatarImageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapTabSize];
		[HONImagingDepictor maskImageView:avatarImageView withMask:[UIImage imageNamed:@"maskAvatar.png"]];
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_userVO.avatarPrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
						   placeholderImage:nil
									success:imageSuccessBlock
									failure:imageFailureBlock];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(63.0, 21.0, 130.0, 22.0)];
	nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:17];
	nameLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _userVO.username;
	[self addSubview:nameLabel];
	
}


#pragma mark - Navigation
- (void)_goAdd {
	[_addButton setBackgroundImage:[UIImage imageNamed:@"checkButton_nonActive"] forState:UIControlStateNormal];
	[_addButton setBackgroundImage:[UIImage imageNamed:@"checkButton_Active"] forState:UIControlStateHighlighted];
	
	[_blockButton setBackgroundImage:[UIImage imageNamed:@"blockButton_nonActive"] forState:UIControlStateNormal];
	[_blockButton setBackgroundImage:[UIImage imageNamed:@"blockButton_Active"] forState:UIControlStateHighlighted];
	
	[self.delegate contactViewCell:self user:_userVO toggleSelected:YES];
}

- (void)_goBlock {
	[_addButton setBackgroundImage:[UIImage imageNamed:@"addButton_nonActive"] forState:UIControlStateNormal];
	[_addButton setBackgroundImage:[UIImage imageNamed:@"addButton_Active"] forState:UIControlStateHighlighted];
	
	[_blockButton setBackgroundImage:[UIImage imageNamed:@"xButton_nonActive"] forState:UIControlStateNormal];
	[_blockButton setBackgroundImage:[UIImage imageNamed:@"xButton_Active"] forState:UIControlStateHighlighted];
	
	[self.delegate contactViewCell:self user:_userVO toggleSelected:NO];
}



@end
