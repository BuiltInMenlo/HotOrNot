//
//  HONNextNavButtonView.m
//  HotOrNot
//
//  Created by BIM  on 11/3/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONNextNavButtonView.h"

@interface HONNextNavButtonView ()
@end

@implementation HONNextNavButtonView

- (id)initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithTarget:target action:action])) {
		[self setFrame:CGRectOffset(self.frame, 280.0, 0.0)];
		
		_button.frame = CGRectFromSize(CGSizeMake(44.0, 44.0));
		[_button setBackgroundImage:[UIImage imageNamed:@"nextButton_nonActive"] forState:UIControlStateNormal];
		[_button setBackgroundImage:[UIImage imageNamed:@"nextButton_Active"] forState:UIControlStateHighlighted];
	}
	
	return (self);
}

@end
