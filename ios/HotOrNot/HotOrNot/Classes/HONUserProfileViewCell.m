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
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14.0, 9.0, 50.0, 50.0)];
	[avatarImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
	[self addSubview:avatarImageView];
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(78.0, 13.0, 100.0, 18.0)];
	nameLabel.font = [[HONAppDelegate qualcommBold] fontWithSize:18];
	nameLabel.textColor = [UIColor blackColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = _userVO.username;
	[self addSubview:nameLabel];
	
	UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(78.0, 25.0, 100.0, 18.0)];
	scoreLabel.font = [[HONAppDelegate qualcommBold] fontWithSize:18];
	scoreLabel.textColor = [UIColor blackColor];
	scoreLabel.backgroundColor = [UIColor clearColor];
	scoreLabel.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.points]];
	[self addSubview:scoreLabel];
}


@end
