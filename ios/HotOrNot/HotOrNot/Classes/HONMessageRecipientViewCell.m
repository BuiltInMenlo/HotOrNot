//
//  HONMessageRecipientViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/22/2014 @ 14:49.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONMessageRecipientViewCell.h"


@interface HONMessageRecipientViewCell ()
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UIButton *selectedButton;
@property (nonatomic) BOOL isSelected;
@end

@implementation HONMessageRecipientViewCell
@synthesize userVO = _userVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		_isSelected = NO;
		
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"activityBackground"]];
		
		_checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_checkButton.frame = CGRectMake(272.0, 3.0, 44.0, 44.0);
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"greenDot"] forState:UIControlStateNormal];
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"greenDot"] forState:UIControlStateHighlighted];
		[_checkButton addTarget:self action:@selector(_goDeselected) forControlEvents:UIControlEventTouchUpInside];
		_checkButton.hidden = YES;
		[self addSubview:_checkButton];
		
		_selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_selectedButton.frame = CGRectMake(272.0, 3.0, 44.0, 44.0);
		[_selectedButton setBackgroundImage:[UIImage imageNamed:@"greyDot"] forState:UIControlStateNormal];
		[_selectedButton setBackgroundImage:[UIImage imageNamed:@"greyDot"] forState:UIControlStateHighlighted];
		[_selectedButton addTarget:self action:@selector(_goSelected) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_selectedButton];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setUserVO:(HONTrivialUserVO *)userVO {
	_userVO = userVO;
	
	//NSLog(@"AVATAR:[%@]", _messageRecipientVO.avatarPrefix);
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, 7.0, 34.0, 34.0)];
	avatarImageView.alpha = 0.0;
	[self addSubview:avatarImageView];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		avatarImageView.image = image;
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[HONAppDelegate cleanImagePrefixURL:request.URL.absoluteString] forBucketType:HONS3BucketTypeAvatars completion:nil];
		
		avatarImageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapTabSize];
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_userVO.avatarPrefix stringByAppendingString:kSnapThumbSuffix]]
															 cachePolicy:kURLRequestCachePolicy
														 timeoutInterval:[HONAppDelegate timeoutInterval]]
						   placeholderImage:nil
									success:imageSuccessBlock
									failure:imageFailureBlock];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(51.0, 14.0, 130.0, 18.0)];
	nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
	nameLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _userVO.username;
	[self addSubview:nameLabel];
}

- (void)toggleSelected {
	if (_isSelected)
		[self _goDeselected];
		
	else
		[self _goSelected];
}


#pragma mark - Navigation
- (void)_goSelected {
	_isSelected = YES;
	
	_checkButton.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_selectedButton.alpha = 0.0;
	} completion:^(BOOL finished) {
		_selectedButton.hidden = YES;
	}];
	
	[self.delegate messageRecipientViewCell:self toggleSelected:YES forRecipient:_userVO];
}

- (void)_goDeselected {
	_isSelected = NO;
	
	_selectedButton.hidden = NO;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_selectedButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		_checkButton.hidden = YES;
	}];
	
	[self.delegate messageRecipientViewCell:self toggleSelected:NO forRecipient:_userVO];
}

@end
