//
//  HONSettingsViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONSettingsViewCell.h"
#import "HONAppDelegate.h"

@interface HONSettingsViewCell()
@property (nonatomic, strong) UIImageView *bgImgView;
@end

@implementation HONSettingsViewCell

@synthesize bgImgView = _bgImgView;

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

- (id)initAsTopCell:(int)points withSubject:(NSString *)subject {
	if ((self = [self init])) {
		UIButton *dailyButton = [UIButton buttonWithType:UIButtonTypeCustom];
		dailyButton.frame = CGRectMake(0.0, 0.0, 320.0, 55.0);
		[dailyButton setBackgroundImage:[UIImage imageNamed:@"headerTableRow_nonActive.png"] forState:UIControlStateNormal];
		[dailyButton setBackgroundImage:[UIImage imageNamed:@"headerTableRow_Active.png"] forState:UIControlStateHighlighted];
		[dailyButton addTarget:self action:@selector(_goDailyChallenge) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:dailyButton];
		
		UILabel *ptsLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 25.0, 50.0, 16.0)];
		ptsLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
		ptsLabel.textColor = [UIColor whiteColor];
		ptsLabel.backgroundColor = [UIColor clearColor];
		ptsLabel.textAlignment = NSTextAlignmentCenter;
		ptsLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
		ptsLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		ptsLabel.text = [NSString stringWithFormat:@"%d", points];
		[self addSubview:ptsLabel];
		
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 25.0, 140.0, 16.0)];
		subjectLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
		subjectLabel.textColor = [UIColor whiteColor];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.textAlignment = NSTextAlignmentCenter;
		subjectLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
		subjectLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		subjectLabel.text = [NSString stringWithFormat:@"#%@", subject];
		[self addSubview:subjectLabel];
	}
	
	return (self);
}

- (id)initAsBottomCell {
	if ((self = [self init])) {
		_bgImgView.image = [UIImage imageNamed:@"footerTableRow_nonActive.png"];
		
		UIButton *supportButton = [UIButton buttonWithType:UIButtonTypeCustom];
		supportButton.frame = CGRectMake(18.0, 8.0, 284.0, 39.0);
		[supportButton addTarget:self action:@selector(_goSupport) forControlEvents:UIControlEventTouchUpInside];
		[supportButton setBackgroundImage:[UIImage imageNamed:@"needHelp_nonActive.png"] forState:UIControlStateNormal];
		[supportButton setBackgroundImage:[UIImage imageNamed:@"needHelp_Active.png"] forState:UIControlStateHighlighted];
		[self addSubview:supportButton];
	}
	
	return (self);
}

- (id)initAsMidCell:(NSString *)caption {
	if ((self = [self init])) {
		_bgImgView.image = [UIImage imageNamed:@"genericRowBackgroundnoImage.png"];
		
		UILabel *indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(26.0, 26.0, 250.0, 16.0)];
		indexLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:15];
		indexLabel.textColor = [HONAppDelegate honBlueTxtColor];
		indexLabel.backgroundColor = [UIColor clearColor];
		indexLabel.text = caption;
		[self addSubview:indexLabel];
	}
	
	return (self);
}

- (void)didSelect {
	_bgImgView.image = [UIImage imageNamed:@"genericRowBackgroundnoImage_active.png"];
	[self performSelector:@selector(_resetBG) withObject:nil afterDelay:0.33];
}

- (void)_resetBG {
	_bgImgView.image = [UIImage imageNamed:@"genericRowBackgroundnoImage.png"];
}

- (void)_goSupport {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUPPORT" object:nil];
}

- (void)_goDailyChallenge {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DAILY_CHALLENGE" object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

@end
