//
//  HONResultsViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.21.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONResultsViewCell.h"

#import "HONAppDelegate.h"

@interface HONResultsViewCell()
@end

@implementation HONResultsViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initAsTopCell {
	if ((self = [super init])) {
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 24.0)];
		bgImgView.image = [UIImage imageNamed:@"leaderTableHeader.png"];
		[self addSubview:bgImgView];
	}
	
	return (self);
}

- (id)initAsResultCell:(HONChallengeResultsState)state {
	if ((self = [super init])) {
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 150.0)];
		bgImgView.image = [[UIImage imageNamed:@"blankRowBackground_nonActive"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:10.0];
		[self addSubview:bgImgView];
		
		NSString *resultImgViewAsset;
		
		switch (state) {
			case HONChallengesWinning:
				resultImgViewAsset = @"greatJob.png";
				break;
				
			case HONChallengesLosing:
				resultImgViewAsset = @"tryAgain.png";
				break;
				
			case HONChallengesTie:
				resultImgViewAsset = @"notBad.png";
				break;
				
		}
		
		UIImageView *resultImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 5.0, 320.0, 134.0)];
		resultImgView.image = [UIImage imageNamed:resultImgViewAsset];
		[self addSubview:resultImgView];
	}
	
	return (self);
}

- (id)initAsBottomCell {
	if ((self = [self init])) {
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 70.0)];
		bgImgView.image = [UIImage imageNamed:@"footerTableRow_nonActive.png"];
		[self addSubview:bgImgView];
		
		UIButton *dailyChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		dailyChallengeButton.frame = CGRectMake(18.0, 8.0, 284.0, 39.0);
		[dailyChallengeButton addTarget:self action:@selector(_goDailyChallenge) forControlEvents:UIControlEventTouchUpInside];
		[dailyChallengeButton setBackgroundImage:[UIImage imageNamed:@"needHelp_nonActive.png"] forState:UIControlStateNormal];
		[dailyChallengeButton setBackgroundImage:[UIImage imageNamed:@"needHelp_Active.png"] forState:UIControlStateHighlighted];
		[self addSubview:dailyChallengeButton];
	}
	
	return (self);
}

- (id)initAsStatCell:(NSString *)caption {
	if ((self = [super init])) {
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 70.0)];
		bgImgView.image = [UIImage imageNamed:@"blankRowBackground_nonActive.png"];
		[self addSubview:bgImgView];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25.0, 27.0, 200.0, 16.0)];
		label.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:14];
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [HONAppDelegate honBlueTxtColor];
		label.text = caption;
		[self addSubview:label];
	}
	
	return (self);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}


- (void)_goDailyChallenge {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_DAILY_CHALLENGE" object:nil];
}

@end
