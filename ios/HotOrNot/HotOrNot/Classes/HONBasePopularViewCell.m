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
		_bgImgView.frame = CGRectMake(0.0, 0.0, 320.0, 24.0);
		_bgImgView.image = [UIImage imageNamed:@"leaderTableHeader.png"];
	}
	
	return (self);
}

- (id)initAsBottomCell {
	if ((self = [self init])) {
		_bgImgView.image = [UIImage imageNamed:@"footerTableRow_nonActive.png"];
		
		UIButton *randomChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		randomChallengeButton.frame = CGRectMake(18.0, 6.0, 284.0, 39.0);
		[randomChallengeButton addTarget:self action:@selector(_goRandomChallenge) forControlEvents:UIControlEventTouchUpInside];
		[randomChallengeButton setBackgroundImage:[UIImage imageNamed:@"randomChallengeButton_nonActive.png"] forState:UIControlStateNormal];
		[randomChallengeButton setBackgroundImage:[UIImage imageNamed:@"randomChallengeButton_Active.png"] forState:UIControlStateHighlighted];
		[self addSubview:randomChallengeButton];
	}
	
	return (self);
}

- (id)initAsMidCell:(int)index {
	if ((self = [self init])) {
		_bgImgView.image = [UIImage imageNamed:@"leaderTableRow_nonActive.png"];
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
