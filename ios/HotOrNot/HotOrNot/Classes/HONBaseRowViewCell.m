//
//  HONBaseRowViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 3/17/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONBaseRowViewCell.h"


@interface HONBaseRowViewCell()
@property (nonatomic, strong) UIImageView *chevronImageView;
@end

@implementation HONBaseRowViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewCellBG"]];
		
		_chevronImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron"]];
		_chevronImageView.frame = CGRectOffset(_chevronImageView.frame, 285.0, 20.0);
		[self.contentView addSubview:_chevronImageView];
	}
	
	return (self);
}

- (void)hideChevron {
	_chevronImageView.hidden = YES;
}

- (void)didSelect {
	self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewCellSelectedBG"]];
	[self performSelector:@selector(_resetBG) withObject:nil afterDelay:0.33];
}

- (void)_resetBG {
	self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewCellBG"]];
}

@end
