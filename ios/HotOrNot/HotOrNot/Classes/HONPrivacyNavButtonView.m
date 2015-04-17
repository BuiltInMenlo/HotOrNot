//
//  HONPrivacyNavButtonView.m
//  HotOrNot
//
//  Created by BIM  on 3/13/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "HONPrivacyNavButtonView.h"

@implementation HONPrivacyNavButtonView

- (id)initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithTarget:target action:action])) {
		[_button setBackgroundImage:[UIImage imageNamed:@"privacyButton_nonActive"] forState:UIControlStateNormal];
		[_button setBackgroundImage:[UIImage imageNamed:@"privacyButton_Active"] forState:UIControlStateHighlighted];
		//[self setFrame:CGRectOffsetX(self.frame, [UIScreen mainScreen].bounds.size.width - self.frame.size.width)];
	}
	
	return (self);
}

@end
