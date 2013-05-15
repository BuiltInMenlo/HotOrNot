//
//  HONSearchUserViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 3/17/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONSearchUserViewCell.h"
#import "HONAppDelegate.h"

@interface HONSearchUserViewCell()
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@end

@implementation HONSearchUserViewCell
@synthesize userVO = _userVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		UIImageView *selectedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rowGray_nonActive"]];
		selectedImageView.image = [UIImage imageNamed:@"rowGray_nonActive"];
		
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchDiscoverBackground"]];
		
		UIImageView *chevronImageView = [[UIImageView alloc] initWithFrame:CGRectMake(285.0, 20.0, 24.0, 24.0)];
		chevronImageView.image = [UIImage imageNamed:@"chevron"];
		[self addSubview:chevronImageView];
	}
	
	return (self);
}

- (void)setUserVO:(HONUserVO *)userVO {
	_userVO = userVO;
	
	UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0, 13.0, 38.0, 38.0)];
	userImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	[userImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
	[self addSubview:userImageView];
	
	UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(58.0, 24.0, 200.0, 20.0)];
	usernameLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:16];
	usernameLabel.textColor = [HONAppDelegate honGrey635Color];
	usernameLabel.backgroundColor = [UIColor clearColor];
	usernameLabel.text = [NSString stringWithFormat:@"@%@", _userVO.username];
	[self addSubview:usernameLabel];
}

@end
