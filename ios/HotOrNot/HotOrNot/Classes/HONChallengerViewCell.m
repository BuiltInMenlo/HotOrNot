//
//  HONChallengerViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 04.23.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONChallengerViewCell.h"
#import "HONAppDelegate.h"


@interface HONChallengerViewCell()
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic) BOOL isRandom;
@end

@implementation HONChallengerViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initAsRandomUser:(BOOL)isAnonymous {
	if ((self = [super init])) {
		_isRandom = isAnonymous;
		
		_bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 63.0)];
		_bgImageView.image = [UIImage imageNamed:@"searchRow_nonActive"];
		[self addSubview:_bgImageView];
		
//		self.backgroundView = _bgImageView;
//		self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchRow_Active"]];
	}
	
	return (self);
}

- (void)didSelect {
	_bgImageView.image = [UIImage imageNamed:@"searchRow_Active"];
	[self performSelector:@selector(_resetBG) withObject:nil afterDelay:0.33];
}

- (void)_resetBG {
	_bgImageView.image = [UIImage imageNamed:@"searchRow_nonActive"];
}

- (void)setUserVO:(HONUserVO *)userVO {
	_userVO = userVO;
	
	UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14.0, 12.0, 38.0, 38.0)];
	userImageView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	[userImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
	[self addSubview:userImageView];
	
	UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(62.0, 22.0, 200.0, 18.0)];
	usernameLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:14];
	usernameLabel.textColor = [HONAppDelegate honGreyTxtColor];
	usernameLabel.backgroundColor = [UIColor clearColor];
	usernameLabel.text = [NSString stringWithFormat:@"@%@", _userVO.username];
	[self addSubview:usernameLabel];
}

- (void)setSelectedBackgroundView:(UIView *)selectedBackgroundView {
	
}

@end
