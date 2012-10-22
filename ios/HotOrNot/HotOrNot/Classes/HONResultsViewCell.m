//
//  HONResultsViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.21.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONResultsViewCell.h"

#import "HONAppDelegate.h"

@implementation HONResultsViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initAsTopCell {
	if ((self = [super init])) {
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 22.0)];
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
				resultImgViewAsset = @"";
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
		UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -1.0, 320.0, 22.0)];
		bgImgView.image = [[UIImage imageNamed:@"genericTableFooter.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:10.0];
		[self addSubview:bgImgView];
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


@end
