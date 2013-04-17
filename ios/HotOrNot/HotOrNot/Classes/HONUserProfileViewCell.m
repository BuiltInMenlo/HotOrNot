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
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 158.0)];
	bgImageView.image = [UIImage imageNamed:@"profileBackground"];
	[self addSubview:bgImageView];
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(13.0, 34.0, 95.0, 90.0)];
	[avatarImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
	[self addSubview:avatarImageView];
	
	UIButton *snapButton = [UIButton buttonWithType:UIButtonTypeCustom];
	snapButton.frame = CGRectMake(200.0, 80.0, 34.0, 34.0);
	[snapButton setBackgroundImage:[UIImage imageNamed:@"snapButton_nonActive"] forState:UIControlStateNormal];
	[snapButton setBackgroundImage:[UIImage imageNamed:@"snapButton_Active"] forState:UIControlStateHighlighted];
	[snapButton addTarget:self action:@selector(_goSnap) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:snapButton];
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	UILabel *snapsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 172.0, 100.0, 18.0)];
	snapsLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:13];
	snapsLabel.textColor = [UIColor whiteColor];
	snapsLabel.backgroundColor = [UIColor clearColor];
	snapsLabel.textAlignment = NSTextAlignmentCenter;
	snapsLabel.text = [NSString stringWithFormat:(_userVO.pics == 1) ? NSLocalizedString(@"profile_snap", nil) : NSLocalizedString(@"profile_snaps", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.pics]]];
	[self addSubview:snapsLabel];
	
	UILabel *votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(110.0, 172.0, 100.0, 18.0)];
	votesLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:13];
	votesLabel.textColor = [UIColor whiteColor];
	votesLabel.backgroundColor = [UIColor clearColor];
	votesLabel.textAlignment = NSTextAlignmentCenter;
	votesLabel.text = [NSString stringWithFormat:(_userVO.votes == 1) ? NSLocalizedString(@"profile_vote", nil) : NSLocalizedString(@"profile_votes", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]]];
	[self addSubview:votesLabel];
	
	UILabel *pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(210.0, 172.0, 100.0, 18.0)];
	pointsLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:13];
	pointsLabel.textColor = [UIColor whiteColor];
	pointsLabel.backgroundColor = [UIColor clearColor];
	pointsLabel.textAlignment = NSTextAlignmentCenter;
	pointsLabel.text = [NSString stringWithFormat:(_userVO.score == 1) ? NSLocalizedString(@"profile_point", nil) : NSLocalizedString(@"profile_points", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.score]]];
	[self addSubview:pointsLabel];
}


#pragma mark - Navigation
- (void)_goSnap {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_USER_CHALLENGE" object:nil];
}


@end
