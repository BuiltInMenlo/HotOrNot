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
	if ((self = [self initAsGreyCell:NO])) {
		UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14.0, 9.0, 50.0, 50.0)];
		[avatarImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", [[HONAppDelegate infoForUser] objectForKey:@"fb_id"]]] placeholderImage:nil options:SDWebImageLowPriority];
		[self addSubview:avatarImageView];
		
		int score = ([[[HONAppDelegate infoForUser] objectForKey:@"points"] intValue] * [HONAppDelegate createPointMultiplier]) + ([[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue] * [HONAppDelegate votePointMultiplier]) + ([[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue] * [HONAppDelegate pokePointMultiplier]);
		CGSize size = [[NSString stringWithFormat:@"%d", score] sizeWithFont:[[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(200.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
		
		_scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(78.0, 15.0, size.width, size.height)];
		_scoreLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
		_scoreLabel.textColor = [UIColor blackColor];
		_scoreLabel.backgroundColor = [UIColor clearColor];
		_scoreLabel.text = [NSString stringWithFormat:@"%d", score];
		[self addSubview:_scoreLabel];
		
		_ptsLabel = [[UILabel alloc] initWithFrame:CGRectMake(81.0 + size.width, 22.0, 50.0, 12.0)];
		_ptsLabel.font = [[HONAppDelegate freightSansBlack] fontWithSize:10];
		_ptsLabel.textColor = [HONAppDelegate honGreyTxtColor];
		_ptsLabel.backgroundColor = [UIColor clearColor];
		_ptsLabel.text = (score == 1) ? @"PT" : @"PTS";
		[self addSubview:_ptsLabel];
		
		UILabel *rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(79.0, 36.0, 140.0, 16.0)];
		rankLabel.font = [[HONAppDelegate honHelveticaNeueFontBoldItalic] fontWithSize:11];
		rankLabel.textColor = [HONAppDelegate honGreyTxtColor];
		rankLabel.backgroundColor = [UIColor clearColor];
		rankLabel.text = [NSString stringWithFormat:@"ranked #%d", [[[NSUserDefaults standardUserDefaults] objectForKey:@"player_rank"] intValue]];
		[self addSubview:rankLabel];
		
		[self hideChevron];
	}
	
	return (self);
}

- (id)initAsMidCell:(NSString *)caption isGrey:(BOOL)grey {
	if ((self = [self initAsGreyCell:grey])) {
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
	int score = ([[[HONAppDelegate infoForUser] objectForKey:@"points"] intValue] * [HONAppDelegate createPointMultiplier]) + ([[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue] * [HONAppDelegate votePointMultiplier]) + ([[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue] * [HONAppDelegate pokePointMultiplier]);
	CGSize size = [[NSString stringWithFormat:@"%d ", score] sizeWithFont:[[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16] constrainedToSize:CGSizeMake(200.0, CGFLOAT_MAX) lineBreakMode:UILineBreakModeClip];
	
	_scoreLabel.frame = CGRectMake(78.0, 15.0, size.width, size.height);
	_scoreLabel.text = [NSString stringWithFormat:@"%d ", score];
	
	_ptsLabel.frame = CGRectMake(78.0 + size.width, 22.0, 50.0, 12.0);
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
