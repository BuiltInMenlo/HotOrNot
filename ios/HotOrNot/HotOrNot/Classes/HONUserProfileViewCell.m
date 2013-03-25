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
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 226.0)];
	bgImageView.image = [UIImage imageNamed:@"profileBackground"];
	[self addSubview:bgImageView];
	
	UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareButton.frame = CGRectMake(275.0, 5.0, 44.0, 44.0);
	[shareButton setBackgroundImage:[UIImage imageNamed:@"profileShareButton_nonActive"] forState:UIControlStateNormal];
	[shareButton setBackgroundImage:[UIImage imageNamed:@"profileShareButton_Active"] forState:UIControlStateHighlighted];
	[shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:shareButton];
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(110.0, 22.0, 95.0, 95.0)];
	[avatarImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
	avatarImageView.layer.cornerRadius = 4.0;
	avatarImageView.clipsToBounds = YES;
	[self addSubview:avatarImageView];
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 138.0, 320.0, 18.0)];
	nameLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
	nameLabel.textColor = [UIColor whiteColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.textAlignment = NSTextAlignmentCenter;
	nameLabel.text = [NSString stringWithFormat:@"Snap@%@", _userVO.username];
	[self addSubview:nameLabel];
	
	UILabel *snapsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 183.0, 100.0, 18.0)];
	snapsLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:13];
	snapsLabel.textColor = [UIColor whiteColor];
	snapsLabel.backgroundColor = [UIColor clearColor];
	snapsLabel.textAlignment = NSTextAlignmentCenter;
	snapsLabel.text = [NSString stringWithFormat:(_userVO.pics == 1) ? @"%@ snap" : @"%@ snaps", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.pics]]];
	[self addSubview:snapsLabel];
	
	UILabel *votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(110.0, 183.0, 100.0, 18.0)];
	votesLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:13];
	votesLabel.textColor = [UIColor whiteColor];
	votesLabel.backgroundColor = [UIColor clearColor];
	votesLabel.textAlignment = NSTextAlignmentCenter;
	votesLabel.text = [NSString stringWithFormat:(_userVO.votes == 1) ? @"%@ vote" : @"%@ votes", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]]];
	[self addSubview:votesLabel];
	
	UILabel *pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(210.0, 183.0, 100.0, 18.0)];
	pointsLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:13];
	pointsLabel.textColor = [UIColor whiteColor];
	pointsLabel.backgroundColor = [UIColor clearColor];
	pointsLabel.textAlignment = NSTextAlignmentCenter;
	pointsLabel.text = [NSString stringWithFormat:(_userVO.score == 1) ? @"%@ point" : @"%@ points", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.score]]];
	[self addSubview:pointsLabel];
}


#pragma mark - Navigation
- (void)_goShare {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE" object:nil];
}


@end
