//
//  HONCloseNavButtonView.m
//  HotOrNot
//
//  Created by BIM  on 11/3/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONCloseNavButtonView.h"


@interface HONCloseNavButtonView ()
@end

@implementation HONCloseNavButtonView

- (id)initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithTarget:target action:action])) {
		[self setFrame:CGRectMake(3.0, 0.0, 64.0, 44.0)];
		
//		_button.frame = CGRectFromSize(CGSizeMake(44.0, 64.0));
		[_button setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
		[_button setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
	}
	
	return (self);
}

@end
