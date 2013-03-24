//
//  HONSettingsViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "Mixpanel.h"
#import "UIImageView+AFNetworking.h"

#import "HONSettingsViewCell.h"
#import "HONAppDelegate.h"

@interface HONSettingsViewCell()
@property (nonatomic, strong) UIImageView *bgImgView;
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
		_bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 70.0)];
		[self addSubview:_bgImgView];
	}
	
	return (self);
}

- (id)initAsTopCell {
	if ((self = [self init])) {
		_bgImgView.frame = CGRectMake(0.0, 0.0, 320.0, 226.0);
		_bgImgView.image = [UIImage imageNamed:@"profileBackground"];
		
		UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(110.0, 22.0, 95.0, 95.0)];
		[avatarImageView setImageWithURL:[NSURL URLWithString:[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"]] placeholderImage:nil];
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
		nameLabel.text = [[HONAppDelegate infoForUser] objectForKey:@"username"];
		[self addSubview:nameLabel];
		
		UILabel *snapsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 212.0, 100.0, 18.0)];
		snapsLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
		snapsLabel.textColor = [UIColor blackColor];
		snapsLabel.backgroundColor = [UIColor clearColor];
		snapsLabel.textAlignment = NSTextAlignmentCenter;
		snapsLabel.text = [NSString stringWithFormat:([[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue] == 1) ? @"%@ snap" : @"%@ snaps", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]]]];
		[self addSubview:snapsLabel];
		
		UILabel *votesLabel = [[UILabel alloc] initWithFrame:CGRectMake(110.0, 212.0, 100.0, 18.0)];
		votesLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
		votesLabel.textColor = [UIColor blackColor];
		votesLabel.backgroundColor = [UIColor clearColor];
		votesLabel.textAlignment = NSTextAlignmentCenter;
		votesLabel.text = [NSString stringWithFormat:([[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue] == 1) ? @"%@ vote" : @"%@ votes", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue]]]];
		[self addSubview:votesLabel];
		
		int points = ([[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]) + ([[[HONAppDelegate infoForUser] objectForKey:@"points"] intValue] * [HONAppDelegate createPointMultiplier]) + ([[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue] * [HONAppDelegate votePointMultiplier]) + ([[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue] * [HONAppDelegate pokePointMultiplier]);
		UILabel *pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(210.0, 212.0, 100.0, 18.0)];
		pointsLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
		pointsLabel.textColor = [UIColor blackColor];
		pointsLabel.backgroundColor = [UIColor clearColor];
		pointsLabel.textAlignment = NSTextAlignmentCenter;
		pointsLabel.text = [NSString stringWithFormat:(points == 1) ? @"%@ point" : @"%@ points", [numberFormatter stringFromNumber:[NSNumber numberWithInt:points]]];
		[self addSubview:pointsLabel];
		
		[self hideChevron];
	}
	
	return (self);
}

- (id)initAsMidCell:(NSString *)caption {
	if ((self = [self init])) {
		_caption = caption;
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(26.0, 29.0, 250.0, 16.0)];
		_captionLabel.font = [[HONAppDelegate freightSansBlack] fontWithSize:14];
		_captionLabel.textColor = [HONAppDelegate honBlueTxtColor];
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
	
	CGSize size = [formattedScore sizeWithFont:[[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:18] constrainedToSize:CGSizeMake(200.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
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

@end
