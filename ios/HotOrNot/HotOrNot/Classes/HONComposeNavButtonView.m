//
//  HONComposeNavButtonView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/11/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONComposeNavButtonView.h"

@interface HONComposeNavButtonView()
@end

@implementation HONComposeNavButtonView

- (id)initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithTarget:target action:action])) {
		[self setFrame:CGRectMake(261.0, 0.0, 54.0, 44.0)];
		
		_button.frame = CGRectFromSize(CGSizeMake(54.0, 44.0));
		[_button setBackgroundImage:[UIImage imageNamed:@"headerCameraButton_nonActive"] forState:UIControlStateNormal];
		[_button setBackgroundImage:[UIImage imageNamed:@"headerCameraButton_Active"] forState:UIControlStateHighlighted];
	}
	
	return (self);
}

@end
