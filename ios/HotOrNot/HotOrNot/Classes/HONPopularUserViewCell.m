//
//  HONPopularUserViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONPopularUserViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "HONAppDelegate.h"

@interface HONPopularUserViewCell()
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@end

@implementation HONPopularUserViewCell

@synthesize userVO = _userVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (void)setUserVO:(HONPopularUserVO *)userVO {
	_userVO = userVO;
	NSString *imgURL = ([_userVO.fbID isEqualToString:@""]) ? @"https://s3.amazonaws.com/picchallenge/default_user.jpg" : _userVO.imageURL;
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(14.0, 9.0, 50.0, 50.0)];
	[imageView setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:nil];
	[self addSubview:imageView];
	
	UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(74.0, 18.0, 200.0, 16.0)];
	usernameLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
	usernameLabel.textColor = [HONAppDelegate honGreyTxtColor];
	usernameLabel.backgroundColor = [UIColor clearColor];
	usernameLabel.text = _userVO.username;
	[self addSubview:usernameLabel];
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 35.0, 200.0, 16.0)];
	scoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
	scoreLabel.textColor = [UIColor blackColor];
	scoreLabel.backgroundColor = [UIColor clearColor];
	scoreLabel.text = [NSString stringWithFormat:@"%@ PTS", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.score]]];
	[self addSubview:scoreLabel];
	
	if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID)
		[self hideChevron];
}

- (void)_goChallenge {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"POPULAR_USER_CHALLENGE" object:_userVO];
}

@end
