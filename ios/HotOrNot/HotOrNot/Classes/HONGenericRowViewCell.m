//
//  HONGenericRowViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 3/17/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONGenericRowViewCell.h"


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
		_bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"genericRowBackground_nonActive"]];
		[self addSubview:_bgImageView];
		
		_chevronImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron"]];
		_chevronImageView.frame = CGRectOffset(_chevronImageView.frame, 285.0, 20.0);
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
