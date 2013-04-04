//
//  HONSearchUserViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 3/17/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

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

- (void)setUserVO:(HONUserVO *)userVO {
	_userVO = userVO;
	
	UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14.0, 12.0, 38.0, 38.0)];
	userImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	[userImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
	userImageView.layer.cornerRadius = 4.0;
	userImageView.clipsToBounds = YES;
	[self addSubview:userImageView];
	
	UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(62.0, 22.0, 200.0, 18.0)];
	usernameLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:14];
	usernameLabel.textColor = [HONAppDelegate honBlueTxtColor];
	usernameLabel.backgroundColor = [UIColor clearColor];
	usernameLabel.text = [NSString stringWithFormat:@"@%@", _userVO.username];
	[self addSubview:usernameLabel];
	
	if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID)
		[self hideChevron];
}

@end
