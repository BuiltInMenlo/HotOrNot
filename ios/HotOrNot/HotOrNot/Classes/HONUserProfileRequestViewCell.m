//
//  HONUserProfileRequestViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 7/28/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONUserProfileRequestViewCell.h"

#define kStatsColor [UIColor colorWithRed:0.227 green:0.380 blue:0.349 alpha:1.0]


@implementation HONUserProfileRequestViewCell

@synthesize delegate = _delegate;
@synthesize userVO = _userVO;
@synthesize avatarURL = _avatarURL;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		//[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profileBackground"]]];
	}
	
	return (self);
}

- (void)setUserVO:(HONUserVO *)userVO {
	_userVO = userVO;
	
	//[self addSubview:[[HONImageLoadingView alloc] initAtPos:CGPointMake(127.0, 31.0)]];
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(113.0, 17.0, 93.0, 93.0)];
	[avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"]]
															  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
														  timeoutInterval:3] placeholderImage:nil success:nil failure:nil];
	[self addSubview:avatarImageView];
	
	
	UIImageView *avatar2ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(113.0, 217.0, 93.0, 93.0)];
	[avatar2ImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_userVO.imageURL]
															  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
														  timeoutInterval:3] placeholderImage:nil success:nil failure:nil];
	[self addSubview:avatar2ImageView];
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	float yPos = 324.0;
	
	//_votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, yPos, 80.0, 16.0)];
	UILabel *votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(35.0, yPos, 80.0, 16.0)];
	votesLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:13];
	votesLabel.textColor = kStatsColor;
	votesLabel.backgroundColor = [UIColor clearColor];
	votesLabel.textAlignment = NSTextAlignmentCenter;
	votesLabel.text = [NSString stringWithFormat:(_userVO.votes == 1) ? NSLocalizedString(@"profile_vote", nil) : NSLocalizedString(@"profile_votes", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]]];
	[self addSubview:votesLabel];
	
	UILabel *dots1Label = [[UILabel alloc] initWithFrame:CGRectMake(105.0, yPos - 2.0, 20.0, 20.0)];
	dots1Label.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:14];
	dots1Label.textColor = kStatsColor;
	dots1Label.backgroundColor = [UIColor clearColor];
	dots1Label.textAlignment = NSTextAlignmentCenter;
	dots1Label.text = @"•";
	[self addSubview:dots1Label];
	
	UILabel *snapsLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, yPos, 80.0, 16.0)];
	snapsLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:13];
	snapsLabel.textColor = kStatsColor;
	snapsLabel.backgroundColor = [UIColor clearColor];
	snapsLabel.textAlignment = NSTextAlignmentCenter;
	snapsLabel.text = [NSString stringWithFormat:(_userVO.pics == 1) ? NSLocalizedString(@"profile_snap", nil) : NSLocalizedString(@"profile_snaps", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.pics]]];
	[self addSubview:snapsLabel];
	
	UILabel *dots2Label = [[UILabel alloc] initWithFrame:CGRectMake(195.0, yPos - 2.0, 20.0, 20.0)];
	dots2Label.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:14];
	dots2Label.textColor = kStatsColor;
	dots2Label.backgroundColor = [UIColor clearColor];
	dots2Label.textAlignment = NSTextAlignmentCenter;
	dots2Label.text = @"•";
	[self addSubview:dots2Label];
	
	UILabel *ptsLabel = [[UILabel alloc] initWithFrame:CGRectMake(211.0, yPos, 80.0, 16.0)];
	ptsLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:13];
	ptsLabel.textColor = kStatsColor;
	ptsLabel.backgroundColor = [UIColor clearColor];
	ptsLabel.textAlignment = NSTextAlignmentCenter;
	ptsLabel.text = [NSString stringWithFormat:(_userVO.score == 1) ? NSLocalizedString(@"profile_point", nil) : NSLocalizedString(@"profile_points", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.score]]];
	[self addSubview:ptsLabel];
	
	[self performSelector:@selector(_animateUp) withObject:nil afterDelay:3.0];
}


- (void)_animateUp {
	[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void){
		self.frame = CGRectOffset(self.frame, 0.0, -200.0);
	} completion:^(BOOL finished) {}];
}

@end
