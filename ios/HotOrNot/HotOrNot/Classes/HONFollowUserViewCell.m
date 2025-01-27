//
//  HONFollowUserViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 10/4/13 @ 6:55 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONFollowUserViewCell.h"

@interface HONFollowUserViewCell ()
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UIButton *followButton;

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *gradientImageView;

@end

@implementation HONFollowUserViewCell
@synthesize delegate = _delegate;
@synthesize userVO = _userVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewCellBG_normal"]];
		
		_checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_checkButton.frame = CGRectMake(257.0, 10.0, 44.0, 44.0);
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"toggledOnButton_nonActive"] forState:UIControlStateNormal];
		[_checkButton setBackgroundImage:[UIImage imageNamed:@"toggledOnButton_Active"] forState:UIControlStateHighlighted];
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

- (void)setUserVO:(HONTrivialUserVO *)userVO {
	_userVO = userVO;
	
	//NSLog(@"AVATAR:[%@]", _userVO.avatarURL);
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 13.0, 38.0, 38.0)];
	avatarImageView.alpha = 0.0;
	[self.contentView addSubview:avatarImageView];
	
	UIImageView *gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[@"selfieGradient" stringByAppendingString:([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? @"-568h@2x" : @"@2x"]]];
	gradientImageView.hidden = YES;
	
	__weak HONFollowUserViewCell *weakSelf = self;
	[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_userVO.avatarPrefix stringByAppendingString:kSnapThumbSuffix]]
															 cachePolicy:kOrthodoxURLCachePolicy
														 timeoutInterval:[HONAppDelegate timeoutInterval]]
						   placeholderImage:nil
									success:^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
										weakSelf.avatarImageView.image = image;
										[UIView animateWithDuration:0.25 animations:^(void) {
											weakSelf.avatarImageView.alpha = 1.0;
										} completion:^(BOOL finished) {
											weakSelf.gradientImageView.hidden = NO;
										}];
									}
	 
									failure:^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
										[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:_userVO.avatarPrefix
																						   forBucketType:HONS3BucketTypeAvatars
																							  completion:nil];
										
										weakSelf.avatarImageView.image = [[HONImageBroker sharedInstance] defaultAvatarImageAtSize:kSnapTabSize];
										[UIView animateWithDuration:0.25 animations:^(void) {
											weakSelf.avatarImageView.alpha = 1.0;
										} completion:nil];
									}];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(63.0, 22.0, 130.0, 22.0)];
	nameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:17];
	nameLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _userVO.username;
	[self.contentView addSubview:nameLabel];
}

- (void)toggleSelected:(BOOL)isSelected {
	_followButton.alpha = (int)!isSelected;
	_followButton.hidden = isSelected;
	
	_checkButton.hidden = !isSelected;
}


#pragma mark - Navigation
- (void)_goFollow {
	_checkButton.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_followButton.alpha = 0.0;
	} completion:^(BOOL finished) {
		_followButton.hidden = YES;
	}];
	
	[self.delegate followViewCell:self user:_userVO toggleSelected:YES];
}

- (void)_goUnfollow {
	_followButton.hidden = NO;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_followButton.alpha = 1.0;
	} completion:^(BOOL finished) {
		_checkButton.hidden = YES;
	}];
	
	[self.delegate followViewCell:self user:_userVO toggleSelected:NO];
}


@end
