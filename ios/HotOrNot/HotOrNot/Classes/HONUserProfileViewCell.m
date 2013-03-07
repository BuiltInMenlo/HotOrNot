//
//  HONUserProfileViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 2/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONUserProfileViewCell.h"
#import "HONAppDelegate.h"

@implementation HONUserProfileViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		
	}
	return (self);
}

- (void)setUserVO:(HONPopularUserVO *)userVO {
	_userVO = userVO;
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14.0, 10.0, 50.0, 50.0)];
	[avatarImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
	[self addSubview:avatarImageView];
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(78.0, 10.0, 250.0, 18.0)];
	nameLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
	nameLabel.textColor = [UIColor blackColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _userVO.username;
	[self addSubview:nameLabel];
	
	UILabel *picsLabel = [[UILabel alloc] initWithFrame:CGRectMake(78.0, 25.0, 100.0, 18.0)];
	picsLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
	picsLabel.textColor = [UIColor blackColor];
	picsLabel.backgroundColor = [UIColor clearColor];
	picsLabel.text = [NSString stringWithFormat:@"%@ PICS", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.pics]]];
	[self addSubview:picsLabel];
	
	UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(78.0, 40.0, 100.0, 18.0)];
	scoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
	scoreLabel.textColor = [UIColor blackColor];
	scoreLabel.backgroundColor = [UIColor clearColor];
	scoreLabel.text = [NSString stringWithFormat:@"%@ PTS", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.points]]];
	[self addSubview:scoreLabel];
}


@end
