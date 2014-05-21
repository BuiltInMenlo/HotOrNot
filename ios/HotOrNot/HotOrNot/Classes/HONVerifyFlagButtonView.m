//
//  HONVerifyFlagButtonView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/07/2014 @ 14:40 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONVerifyFlagButtonView.h"


@interface HONVerifyFlagButtonView ()
@end

@implementation HONVerifyFlagButtonView


- (id)initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithFrame:CGRectMake(0.0, 4.0, 93.0, 44.0)])) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.frame = CGRectMake(0.0, 0.0, 93.0, 44.0);
		[button setBackgroundImage:[UIImage imageNamed:@"flagButton_nonActive"] forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage imageNamed:@"flagButton_Active"] forState:UIControlStateHighlighted];
		[button addTarget:target action:action forControlEvents:UIControlEventTouchDown];
		[self addSubview:button];
	}
	
	return (self);
}


#pragma mark - Navigation


@end
