//
//  HONBasePopularViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONBasePopularViewCell.h"

@interface HONBasePopularViewCell()
@property (nonatomic, strong) UIImageView *bgImgView;
@end

@implementation HONBasePopularViewCell
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
		_bgImgView.frame = CGRectMake(0.0, 0.0, 320.0, 55.0);
		_bgImgView.image = [UIImage imageNamed:@"headerBackground.png"];
		
		UIButton *randomChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		randomChallengeButton.frame = CGRectMake(50.0, 5.0, 220.0, 50.0);
		[randomChallengeButton addTarget:self action:@selector(_goRandomChallenge) forControlEvents:UIControlEventTouchUpInside];
		//randomChallengeButton.titleLabel.font = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
		[randomChallengeButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1.0] forState:UIControlStateNormal];
		[randomChallengeButton setTitle:@"Random Challenge" forState:UIControlStateNormal];
		[self addSubview:randomChallengeButton];
	}
	
	return (self);
}

- (id)initAsBottomCell {
	if ((self = [self init])) {
		_bgImgView.image = [UIImage imageNamed:@"footerRowBackground.png"];
	}
	
	return (self);
}

- (id)initAsMidCell:(int)index {
	if ((self = [self init])) {
		_bgImgView.image = [UIImage imageNamed:@"genericRowBackgroundnoImage.png"];
		
		UILabel *indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 25.0, 50.0, 16.0)];
		//subjectLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
		//subjectLabel = [SNAppDelegate snLinkColor];
		indexLabel.backgroundColor = [UIColor clearColor];
		indexLabel.text = [NSString stringWithFormat:@"%d.", index];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)_goRandomChallenge {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RANDOM_CHALLENGE" object:nil];
}
@end
