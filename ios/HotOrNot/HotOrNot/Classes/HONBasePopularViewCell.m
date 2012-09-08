//
//  HONBasePopularViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONBasePopularViewCell.h"

@implementation HONBasePopularViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		self.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
		
		UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 56.0, self.frame.size.width, 1.0)];
		lineView.backgroundColor = [UIColor colorWithWhite:0.33 alpha:1.0];
		[self addSubview:lineView];
	}
	
	return (self);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

@end
