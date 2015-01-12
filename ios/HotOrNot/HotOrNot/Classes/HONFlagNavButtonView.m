//
//  HONFlagNavButtonView.m
//  HotOrNot
//
//  Created by BIM  on 1/11/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "HONFlagNavButtonView.h"

@implementation HONFlagNavButtonView

- (id)initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithTarget:target action:action])) {
		[self setFrame:CGRectOffset(self.frame, 280.0, 0.0)];
		
		_button.frame = CGRectFromSize(CGSizeMake(44.0, 44.0));
		[_button setBackgroundImage:[UIImage imageNamed:@"flagButton_nonActive"] forState:UIControlStateNormal];
		[_button setBackgroundImage:[UIImage imageNamed:@"flagButton_Active"] forState:UIControlStateHighlighted];
	}
	
	return (self);
}
@end
