//
//  HONCameraPreviewSubscriberViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/24/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONCameraPreviewSubscriberViewCell.h"

@implementation HONCameraPreviewSubscriberViewCell

@synthesize userVO = _userVO;
@synthesize delegate = _delegate;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		UIImageView *dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraDivider"]];
		[self addSubview:dividerImageView];
	}
	
	return (self);
}

- (void)setUserVO:(HONUserVO *)userVO {
	_userVO = userVO;
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0, 16.0, 33.0, 33.0)];
	[avatarImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
	[self addSubview:avatarImageView];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(61.0, 25.0, 200.0, 20.0)];
	nameLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:16];
	nameLabel.textColor = [UIColor whiteColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = [NSString stringWithFormat:@"@%@", _userVO.username];
	[self addSubview:nameLabel];
	
	UIButton *removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	removeButton.frame = CGRectMake(274.0, 20.0, 24.0, 24.0);
	[removeButton setBackgroundImage:[UIImage imageNamed:@"subscriberCloseButton"] forState:UIControlStateNormal];
	[removeButton setBackgroundImage:[UIImage imageNamed:@"subscriberCloseButton"] forState:UIControlStateHighlighted];
	[removeButton addTarget:self action:@selector(_goRemove) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:removeButton];
}


#pragma mark - Navigation
- (void)_goRemove {
	[self.delegate subscriberViewCell:self removeOpponent:_userVO];
}

@end
