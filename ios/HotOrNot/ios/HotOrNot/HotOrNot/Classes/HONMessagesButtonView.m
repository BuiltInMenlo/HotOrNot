//
//  HONMessagesButtonView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 02/22/2014 @ 13:59 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONMessagesButtonView.h"


@interface HONMessagesButtonView ()
@end

@implementation HONMessagesButtonView

- (id)initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithFrame:CGRectMake(48.0, 4.0, 34.0, 34.0)])) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.frame = CGRectMake(0.0, 0.0, 34.0, 34.0);
		[button setBackgroundImage:[UIImage imageNamed:@"headerDMButton_nonActive"] forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage imageNamed:@"headerDMButton_Active"] forState:UIControlStateHighlighted];
		[button addTarget:target action:action forControlEvents:UIControlEventTouchDown];
		[self addSubview:button];
	}
	
	return (self);
}


#pragma mark - Navigation


@end
