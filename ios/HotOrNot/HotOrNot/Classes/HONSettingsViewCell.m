//
//  HONSettingsViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import "UIImageView+AFNetworking.h"

#import "HONSettingsViewCell.h"


@interface HONSettingsViewCell()
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *ptsLabel;
@property (nonatomic, strong) UILabel *captionLabel;
@end

@implementation HONSettingsViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		_bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 70.0)];
		[self addSubview:_bgImageView];
	}
	
	return (self);
}

- (id)initAsTopCell {
	if ((self = [self init])) {
		_bgImageView.frame = CGRectMake(0.0, 0.0, 320.0, 163.0);
		_bgImageView.image = [UIImage imageNamed:@"profileBackground"];
		
		UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, 11.0, 97.0, 97.0)];
		[avatarImageView setImageWithURL:[NSURL URLWithString:[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"]] placeholderImage:nil];
		[self addSubview:avatarImageView];
		
		UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		inviteButton.frame = CGRectMake(138.0, 30.0, 155.0, 54.0);
		[inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteButton_nonActive"] forState:UIControlStateNormal];
		[inviteButton setBackgroundImage:[UIImage imageNamed:@"inviteButton_Active"] forState:UIControlStateHighlighted];
		[inviteButton addTarget:self action:@selector(_goInviteSMS) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:inviteButton];
				
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		
		UILabel *snapsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 124.0, 107.0, 30.0)];
		snapsLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:13];
		snapsLabel.textColor = [UIColor whiteColor];
		snapsLabel.backgroundColor = [UIColor clearColor];
		snapsLabel.textAlignment = NSTextAlignmentCenter;
		snapsLabel.text = [NSString stringWithFormat:([[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue] == 1) ? NSLocalizedString(@"profile_snap", nil) : NSLocalizedString(@"profile_snaps", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:[[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]]]];
		[self addSubview:snapsLabel];
		
		UILabel *votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(107.0, 124.0, 107.0, 30.0)];
		votesLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:13];
		votesLabel.textColor = [UIColor whiteColor];
		votesLabel.backgroundColor = [UIColor clearColor];
		votesLabel.textAlignment = NSTextAlignmentCenter;
		votesLabel.text = [NSString stringWithFormat:([[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue] == 1) ? NSLocalizedString(@"profile_vote", nil) : NSLocalizedString(@"profile_votes", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:[[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue]]]];
		[self addSubview:votesLabel];
		
		int points = ([[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]) + ([[[HONAppDelegate infoForUser] objectForKey:@"points"] intValue] * [HONAppDelegate createPointMultiplier]) + ([[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue] * [HONAppDelegate votePointMultiplier]) + ([[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue] * [HONAppDelegate pokePointMultiplier]);
		UILabel *pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(213.0, 124.0, 107.0, 30.0)];
		pointsLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:13];
		pointsLabel.textColor = [UIColor whiteColor];
		pointsLabel.backgroundColor = [UIColor clearColor];
		pointsLabel.textAlignment = NSTextAlignmentCenter;
		pointsLabel.text = [NSString stringWithFormat:(points == 1) ? NSLocalizedString(@"profile_point", nil) : NSLocalizedString(@"profile_points", nil), [numberFormatter stringFromNumber:[NSNumber numberWithInt:points]]];
		[self addSubview:pointsLabel];
		
		[self hideChevron];
	}
	
	return (self);
}

- (id)initAsMidCell:(NSString *)caption {
	if ((self = [self init])) {
		_caption = caption;
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 21.0, 200.0, 20.0)];
		_captionLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16];
		_captionLabel.textColor =  [HONAppDelegate honBlueTextColor];
		_captionLabel.backgroundColor = [UIColor clearColor];
		_captionLabel.text = _caption;
		[self addSubview:_captionLabel];
	}
	
	return (self);
}

- (void)updateTopCell {
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	int score = ([[[HONAppDelegate infoForUser] objectForKey:@"points"] intValue] * [HONAppDelegate createPointMultiplier]) + ([[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue] * [HONAppDelegate votePointMultiplier]) + ([[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue] * [HONAppDelegate pokePointMultiplier]);
	NSString *formattedScore = [numberFormatter stringFromNumber:[NSNumber numberWithInt:score]];
	
	CGSize size = [formattedScore sizeWithFont:[[HONAppDelegate helveticaNeueFontBold] fontWithSize:18] constrainedToSize:CGSizeMake(200.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
	_scoreLabel.frame = CGRectMake(78.0, 13.0, size.width, size.height);
	_scoreLabel.text = formattedScore;
	
	_ptsLabel.frame = CGRectMake(76.0 + size.width, 22.0, 50.0, 12.0);
	_ptsLabel.text = (score == 1) ? @"PT" : @"PTS";
}

- (void)updateCaption:(NSString *)caption {
	_caption = caption;
	_captionLabel.text = _caption;
}


#pragma mark - Navigation
- (void)_goSupport {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUPPORT" object:nil];
}

- (void)_goInviteSMS {
	[[Mixpanel sharedInstance] track:@"Profile - Invite via SMS Button"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];

	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"INVITE_SMS" object:nil];
}

@end
