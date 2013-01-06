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
	if ((self = [self initAsGreyCell:NO])) {
		UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 50.0, 50.0)];
		[avatarImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", [[HONAppDelegate infoForUser] objectForKey:@"fb_id"]]] placeholderImage:nil options:SDWebImageLowPriority];
		[self addSubview:avatarImageView];
		
		UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 10.0, 180.0, 16.0)];
		nameLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
		nameLabel.textColor = [HONAppDelegate honGreyTxtColor];
		nameLabel.backgroundColor = [UIColor clearColor];
//		nameLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
//		nameLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		nameLabel.text = [[HONAppDelegate infoForUser] objectForKey:@"name"];
		[self addSubview:nameLabel];
		
		int score = ([[[HONAppDelegate infoForUser] objectForKey:@"points"] intValue] * [HONAppDelegate createPointMultiplier]) + ([[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue] * [HONAppDelegate votePointMultiplier]) + ([[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue] * [HONAppDelegate pokePointMultiplier]);
		UILabel *ptsLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 30.0, 200.0, 16.0)];
		ptsLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
		ptsLabel.textColor = [HONAppDelegate honGreyTxtColor];
		ptsLabel.backgroundColor = [UIColor clearColor];
//		ptsLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
//		ptsLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		ptsLabel.text = [NSString stringWithFormat:@"%d PTS", score];
		[self addSubview:ptsLabel];
		
		UILabel *rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 50.0, 140.0, 16.0)];
		rankLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
		rankLabel.textColor = [HONAppDelegate honGreyTxtColor];
		rankLabel.backgroundColor = [UIColor clearColor];
//		rankLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
//		rankLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		rankLabel.text = [NSString stringWithFormat:@"RANK: %d", (arc4random() % 100)];
		[self addSubview:rankLabel];
	}
	
	return (self);
}

- (id)initAsMidCell:(NSString *)caption isGrey:(BOOL)grey {
	if ((self = [self initAsGreyCell:grey])) {
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


#pragma mark - Navigation
- (void)_goSupport {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUPPORT" object:nil];
}

@end
