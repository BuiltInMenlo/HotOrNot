//
//  HONUserProfileViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 2/27/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

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

- (void)setUserVO:(HONUserVO *)userVO {
	_userVO = userVO;
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 261.0)];
	bgImageView.image = [UIImage imageNamed:@"profileBackground"];
	[self addSubview:bgImageView];
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(110.0, 22.0, 95.0, 95.0)];
	[avatarImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
	avatarImageView.layer.cornerRadius = 4.0;
	avatarImageView.clipsToBounds = YES;
	[self addSubview:avatarImageView];
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 145.0, 320.0, 18.0)];
	nameLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
	nameLabel.textColor = [UIColor blackColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.textAlignment = NSTextAlignmentCenter;
	nameLabel.text = _userVO.username;
	[self addSubview:nameLabel];
	
	UILabel *snapsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 212.0, 100.0, 18.0)];
	snapsLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
	snapsLabel.textColor = [UIColor blackColor];
	snapsLabel.backgroundColor = [UIColor clearColor];
	snapsLabel.textAlignment = NSTextAlignmentCenter;
	snapsLabel.text = [NSString stringWithFormat:@"%@ snaps", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.pics]]];
	[self addSubview:snapsLabel];
	
	UILabel *votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(110.0, 212.0, 100.0, 18.0)];
	votesLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
	votesLabel.textColor = [UIColor blackColor];
	votesLabel.backgroundColor = [UIColor clearColor];
	votesLabel.textAlignment = NSTextAlignmentCenter;
	votesLabel.text = [NSString stringWithFormat:@"%@ votes", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]]];
	[self addSubview:votesLabel];
	
	UILabel *pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(210.0, 212.0, 100.0, 18.0)];
	pointsLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
	pointsLabel.textColor = [UIColor blackColor];
	pointsLabel.backgroundColor = [UIColor clearColor];
	pointsLabel.textAlignment = NSTextAlignmentCenter;
	pointsLabel.text = [NSString stringWithFormat:@"%@ points", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.score]]];
	[self addSubview:pointsLabel];
}


@end
