//
//  HONInviteNavButtonView.m
//  HotOrNot
//
//  Created by BIM  on 4/1/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "HONInviteNavButtonView.h"

@implementation HONInviteNavButtonView

- (id)initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithTarget:target action:action])) {
		[self setFrame:CGRectOffset(self.frame, 280.0, 0.0)];
		
		_button.frame = CGRectFromSize(CGSizeMake(82.0, 39.0));
		[_button setBackgroundImage:[UIImage imageNamed:@"inviteButton_nonActive"] forState:UIControlStateNormal];
		[_button setBackgroundImage:[UIImage imageNamed:@"inviteButton_Active"] forState:UIControlStateHighlighted];
	}
	
	return (self);
}

@end
