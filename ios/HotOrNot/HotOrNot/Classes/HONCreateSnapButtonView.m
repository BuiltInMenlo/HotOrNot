//
//  HONCreateSnapButtonView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/11/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONCreateSnapButtonView.h"

@interface HONCreateSnapButtonView()
@end

@implementation HONCreateSnapButtonView

- (id)initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithFrame:CGRectMake(279.0, 2.0, 44.0, 44.0)])) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
		[button setBackgroundImage:[UIImage imageNamed:@"headerCameraButton_nonActive"] forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage imageNamed:@"headerCameraButton_Active"] forState:UIControlStateHighlighted];
		[button addTarget:target action:action forControlEvents:UIControlEventTouchDown];
		[self addSubview:button];
	}
	
	return (self);
}


#pragma mark - Navigation

@end
