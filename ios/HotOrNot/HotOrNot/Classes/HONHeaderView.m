//
//  HONHeaderView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.14.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONHeaderView.h"

@implementation HONHeaderView

- (id)initWithTitle:(NSString *)title {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 45.0)])) {
		UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:self.frame];
		[headerImgView setImage:[UIImage imageNamed:@"header.png"]];
		[self addSubview:headerImgView];
		
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 10.0, 320.0, 25.0)];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.text = title;
		[self addSubview:titleLabel];
	}
	
	return (self);
}

@end
