//
//  HONTableViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 3/17/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONTableViewCell.h"


@interface HONTableViewCell()
@property (nonatomic, strong) UIImageView *chevronImageView;
@end

@implementation HONTableViewCell
@synthesize size = _size;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewCellBG_normal"]];
		
		_chevronImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron"]];
		_chevronImageView.frame = CGRectOffset(_chevronImageView.frame, 268.0, 9.0);
		[self.contentView addSubview:_chevronImageView];
	}
	
	return (self);
}

- (void)setSize:(CGSize)size {
	_size = size;
	_chevronImageView.frame = CGRectMake(_chevronImageView.frame.origin.x, MAX(0, (size.height - _chevronImageView.frame.size.height) * 0.5), _chevronImageView.frame.size.width, _chevronImageView.frame.size.height);
}

- (void)hideChevron {
	_chevronImageView.hidden = YES;
}


@end
