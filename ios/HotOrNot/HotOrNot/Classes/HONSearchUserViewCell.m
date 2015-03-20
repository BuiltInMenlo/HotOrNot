//
//  HONSearchUserViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 7/8/13 @ 5:03 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONSearchUserViewCell.h"

@interface HONSearchUserViewCell()
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UIButton *checkButton;
@end

@implementation HONSearchUserViewCell
@synthesize delegate = _delegate;
@synthesize userVO = _userVO;
@synthesize isSelected = _isSelected;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewCellBG_normal"]];
		
		_checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_checkButton.frame = CGRectMake(257.0, 10.0, 44.0, 44.0);
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"toggledOnButton_nonActive"] forState:UIControlStateNormal];
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"toggledOnButton_nonActive"] forState:UIControlStateHighlighted];
		[_checkButton addTarget:self action:@selector(_goUnfollow) forControlEvents:UIControlEventTouchUpInside];
		_checkButton.hidden = YES;
		[self.contentView addSubview:_checkButton];
		
		_followButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_followButton.frame = _checkButton.frame;
		[_followButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_nonActive"] forState:UIControlStateNormal];
		[_followButton setBackgroundImage:[UIImage imageNamed:@"toggledOffButton_Active"] forState:UIControlStateHighlighted];
		[_followButton addTarget:self action:@selector(_goFollow) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_followButton];
	}
	
	return (self);
}

- (void)setUserVO:(HONUserVO *)userVO {
	_userVO = userVO;
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 13.0, 38.0, 38.0)];
	avatarImageView.alpha = 0.0;
	[self.contentView addSubview:avatarImageView];
	
	[[HONViewDispensor sharedInstance] maskView:avatarImageView withMask:[UIImage imageNamed:@"avatarMask"]];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		avatarImageView.image = image;
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
//		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[[HONAPICaller sharedInstance] normalizePrefixForImageURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeAvatars completion:nil];
		
		avatarImageView.image = [[HONImageBroker sharedInstance] defaultAvatarImageAtSize:kSnapThumbSize];
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_userVO.avatarPrefix stringByAppendingString:kSnapThumbSuffix]]
															 cachePolicy:kOrthodoxURLCachePolicy
														 timeoutInterval:[HONAPICaller timeoutInterval]]
						   placeholderImage:nil
									success:imageSuccessBlock
									failure:imageFailureBlock];
	
//	[avatarImageView setImageWithURL:[NSURL URLWithString:[_userVO.imageURL stringByAppendingString:kSnapThumbSuffix]] placeholderImage:nil];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(59.0, 20.0, 170.0, 20.0)];
	nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
	nameLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _userVO.username;
	[self.contentView addSubview:nameLabel];
}

- (void)toggleSelected:(BOOL)isSelected {
	_followButton.alpha = (int)!isSelected;
	_followButton.hidden = isSelected;
	
	_checkButton.alpha = (int)isSelected;
	_checkButton.hidden = !isSelected;
}


#pragma mark - Navigation
- (void)_goFollow {
	_checkButton.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_followButton.alpha = 0.0;
	} completion:^(BOOL finished) {
		_followButton.hidden = YES;
		[self.delegate searchUserViewCell:self user:_userVO toggleSelected:YES];
	}];
}

- (void)_goUnfollow {
	_followButton.hidden = NO;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_followButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		_checkButton.hidden = YES;
		[self.delegate searchUserViewCell:self user:_userVO toggleSelected:NO];
	}];
}

@end
