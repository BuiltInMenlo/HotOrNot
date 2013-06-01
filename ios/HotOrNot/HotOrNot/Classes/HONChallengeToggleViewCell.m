//
//  HONChallengeToggleViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 05.21.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengeToggleViewCell.h"

#import "HONAppDelegate.h"


@interface HONChallengeToggleViewCell()
@property (nonatomic, strong) UIImageView *toggleImageView;
@property (nonatomic) BOOL isPrivate;
@end

@implementation HONChallengeToggleViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		self.backgroundColor = [UIColor whiteColor];
		
		_isPrivate = NO;
		_toggleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0, 9.0, 304.0, 34.0)];
		_toggleImageView.image = [UIImage imageNamed:@"homeToggle_globalActive"];
		[self addSubview:_toggleImageView];
		
		UIButton *publicButton = [UIButton buttonWithType:UIButtonTypeCustom];
		publicButton.frame = CGRectMake(8.0, 9.0, 152.0, 34.0);
		publicButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.33];
		[publicButton addTarget:self action:@selector(_goPublicChallenges) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:publicButton];
		
		UIButton *privateButton = [UIButton buttonWithType:UIButtonTypeCustom];
		privateButton.frame = CGRectMake(160.0, 9.0, 152.0, 34.0);
		privateButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.33];
		[privateButton addTarget:self action:@selector(_goPrivateChallenges) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:privateButton];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goPublicChallenges {
	_isPrivate = NO;
	
	_toggleImageView.image = [UIImage imageNamed:@"homeToggle_globalActive"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_PUBLIC_TIMELINE" object:nil];
}

- (void)_goPrivateChallenges {
	_isPrivate = YES;
	
	_toggleImageView.image = [UIImage imageNamed:@"homeToggle_globalActive"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_PRIVATE_TIMELINE" object:nil];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

@end
