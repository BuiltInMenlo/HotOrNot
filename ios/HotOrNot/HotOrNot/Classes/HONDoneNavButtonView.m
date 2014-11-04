//
//  HONDoneNavButtonView.m
//  HotOrNot
//
//  Created by BIM  on 11/4/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONDoneNavButtonView.h"

@interface HONDoneNavButtonView()
@end

@implementation HONDoneNavButtonView

- (id)initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithTarget:target action:action])) {
		[self setFrame:CGRectOffset(self.frame, 228.0, 0.0)];
		
		_button.frame = CGRectMakeFromSize(CGSizeMake(93.0, 44.0));
		[_button setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
		[_button setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	}
	
	return (self);
}

@end
