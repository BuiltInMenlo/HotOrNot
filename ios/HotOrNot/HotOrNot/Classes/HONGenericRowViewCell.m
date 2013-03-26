//
//  HONGenericRowViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 3/17/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONGenericRowViewCell.h"
#import "HONAppDelegate.h"

@interface HONGenericRowViewCell()
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *chevronImageView;
@end

@implementation HONGenericRowViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		_bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 63.0)];
		_bgImageView.image = [UIImage imageNamed:@"genericRowBackground_nonActive"];
		[self addSubview:_bgImageView];
		
		_chevronImageView = [[UIImageView alloc] initWithFrame:CGRectMake(290.0, 20.0, 24.0, 24.0)];
		_chevronImageView.image = [UIImage imageNamed:@"chevron"];
		[self addSubview:_chevronImageView];
	}
	
	return (self);
}

- (void)hideChevron {
	_chevronImageView.hidden = YES;
}

- (void)didSelect {
	_bgImageView.image = [UIImage imageNamed:@"genericRowBackground_Active"];
	[self performSelector:@selector(_resetBG) withObject:nil afterDelay:0.33];
}

- (void)_resetBG {
	_bgImageView.image = [UIImage imageNamed:@"genericRowBackground_nonActive"];
}

@end
