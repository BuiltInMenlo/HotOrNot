//
//  HONSettingsViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "Mixpanel.h"
#import "UIImageView+WebCache.h"

#import "HONSettingsViewCell.h"
#import "HONAppDelegate.h"

@interface HONSettingsViewCell()
@property (nonatomic, strong) UIImageView *bgImgView;
@property (nonatomic, strong) NSString *caption;
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
		_bgImgView.frame = CGRectMake(0.0, 0.0, 320.0, 140.0);
		_bgImgView.image = [UIImage imageNamed:@"settingsRowZeroBackground"];
		
		UIView *imgHolderView = [[UIView alloc] initWithFrame:CGRectMake(30.0, 30.0, 100.0, 100.0)];
		imgHolderView.clipsToBounds = YES;
		[self addSubview:imgHolderView];
		
		UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)];
		[avatarImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", [[HONAppDelegate infoForUser] objectForKey:@"fb_id"]]] placeholderImage:nil options:SDWebImageLowPriority];
		[imgHolderView addSubview:avatarImageView];
		
		UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(160.0, 25.0, 180.0, 16.0)];
		nameLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
		nameLabel.textColor = [UIColor whiteColor];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
		nameLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		nameLabel.text = [[HONAppDelegate infoForUser] objectForKey:@"name"];
		[self addSubview:nameLabel];
		
		int score = ([[[HONAppDelegate infoForUser] objectForKey:@"points"] intValue] * [HONAppDelegate createPointMultiplier]) + ([[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue] * [HONAppDelegate votePointMultiplier]) + ([[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue] * [HONAppDelegate pokePointMultiplier]);
		UILabel *ptsLabel = [[UILabel alloc] initWithFrame:CGRectMake(160.0, 50.0, 200.0, 16.0)];
		ptsLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
		ptsLabel.textColor = [UIColor whiteColor];
		ptsLabel.backgroundColor = [UIColor clearColor];
		ptsLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
		ptsLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		ptsLabel.text = [NSString stringWithFormat:@"%d PTS", score];
		[self addSubview:ptsLabel];
		
		UILabel *rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(160.0, 75.0, 140.0, 16.0)];
		rankLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
		rankLabel.textColor = [UIColor whiteColor];
		rankLabel.backgroundColor = [UIColor clearColor];
		rankLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
		rankLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		rankLabel.text = [NSString stringWithFormat:@"RANK: %d", (arc4random() % 100)];
		[self addSubview:rankLabel];
	}
	
	return (self);
}

- (id)initAsMidCell:(NSString *)caption {
	if ((self = [self init])) {
		_bgImgView.image = [UIImage imageNamed:@"rowGray_nonActive"];
		_caption = caption;
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(26.0, 26.0, 250.0, 16.0)];
		_captionLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:15];
		_captionLabel.textColor = [HONAppDelegate honBlueTxtColor];
		_captionLabel.backgroundColor = [UIColor clearColor];
		_captionLabel.text = _caption;
		[self addSubview:_captionLabel];
	}
	
	return (self);
}

- (void)updateCaption:(NSString *)caption {
	_caption = caption;
	_captionLabel.text = _caption;
}

- (void)didSelect {
	_bgImgView.image = [UIImage imageNamed:@"rowGray_Active"];
	[self performSelector:@selector(_resetBG) withObject:nil afterDelay:0.33];
}

- (void)_resetBG {
	_bgImgView.image = [UIImage imageNamed:@"rowGray_nonActive"];
}

- (void)_goSupport {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUPPORT" object:nil];
}

- (void)_goDailyChallenge {
	[[Mixpanel sharedInstance] track:@"Daily Challenge - Settings"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DAILY_CHALLENGE" object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

@end
