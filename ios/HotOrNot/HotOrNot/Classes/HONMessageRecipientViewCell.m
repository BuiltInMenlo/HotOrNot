//
//  HONMessageRecipientViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/22/2014 @ 14:49.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONMessageRecipientViewCell.h"
#import "HONAPICaller.h"
#import "HONColorAuthority.h"
#import "HONImagingDepictor.h"


@interface HONMessageRecipientViewCell ()
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UIButton *selectedButton;
@property (nonatomic) BOOL isSelected;
@end

@implementation HONMessageRecipientViewCell
@synthesize messageRecipientVO = _messageRecipientVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		_isSelected = NO;
		
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"genericRowBackground_nonActive"]];
		
		_checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_checkButton.frame = CGRectMake(212.0, 10.0, 104.0, 44.0);
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"checkmarkButton_nonActive"] forState:UIControlStateNormal];
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"checkmarkButton_Active"] forState:UIControlStateHighlighted];
		[_checkButton addTarget:self action:@selector(_goDeselected) forControlEvents:UIControlEventTouchUpInside];
		_checkButton.hidden = YES;
		[self addSubview:_checkButton];
		
		_selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_selectedButton.frame = CGRectMake(212.0, 10.0, 104.0, 44.0);
		[_selectedButton setBackgroundImage:[UIImage imageNamed:@"followButton_nonActive"] forState:UIControlStateNormal];
		[_selectedButton setBackgroundImage:[UIImage imageNamed:@"followButton_Active"] forState:UIControlStateHighlighted];
		[_selectedButton addTarget:self action:@selector(_goSelected) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_selectedButton];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setMessageRecipientVO:(HONMessageRecipientVO *)messageRecipientVO {
	_messageRecipientVO = messageRecipientVO;
	
	//NSLog(@"AVATAR:[%@]", _messageRecipientVO.avatarPrefix);
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 13.0, 38.0, 38.0)];
	avatarImageView.alpha = 0.0;
	[self addSubview:avatarImageView];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		avatarImageView.image = image;
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForURL:_messageRecipientVO.avatarPrefix forAvatarBucket:YES completion:nil];
		
		avatarImageView.image = [HONImagingDepictor defaultAvatarImageAtSize:kSnapTabSize];
		[UIView animateWithDuration:0.25 animations:^(void) {
			avatarImageView.alpha = 1.0;
		} completion:nil];
	};
	
	[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_messageRecipientVO.avatarPrefix stringByAppendingString:kSnapThumbSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
						   placeholderImage:nil
									success:imageSuccessBlock
									failure:imageFailureBlock];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(63.0, 22.0, 130.0, 22.0)];
	nameLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17];
	nameLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _messageRecipientVO.username;
	[self addSubview:nameLabel];
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
	
	[self.delegate messageRecipientViewCell:self toggleSelected:YES forRecipient:_messageRecipientVO];
}

- (void)_goDeselected {
	_isSelected = NO;
	
	_selectedButton.hidden = NO;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_selectedButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		_checkButton.hidden = YES;
	}];
	
	[self.delegate messageRecipientViewCell:self toggleSelected:NO forRecipient:_messageRecipientVO];
}

@end
