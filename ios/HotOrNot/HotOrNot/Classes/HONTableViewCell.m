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
@synthesize indexPath = _indexPath;

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

- (BOOL)accessoryViewsVisible {
	return (_accessoryViewsVisible);
}

- (void)setSize:(CGSize)size {
	_size = size;
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, _size.width, _size.height);
	self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, _size.width, _size.height);
	
	CGFloat yPos = MAX(0.0, (self.frame.size.height - _chevronImageView.frame.size.height) * 0.5);
	_chevronImageView.frame = CGRectTranslate(_chevronImageView.frame, CGPointMake(self.frame.size.width - (0 + _chevronImageView.frame.size.width), yPos));
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
	_indexPath = indexPath;
}

- (void)hideChevron {
	_chevronImageView.hidden = YES;
}

- (void)accVisible:(BOOL)isVisible {
	_chevronImageView.hidden = !isVisible;
}

- (void)toggleChevron {
	_chevronImageView.hidden = !_chevronImageView.hidden;
}

- (void)removeBackground {
	self.backgroundView = nil;
}


@end
