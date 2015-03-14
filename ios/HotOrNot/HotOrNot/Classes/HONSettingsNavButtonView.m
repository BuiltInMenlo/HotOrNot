//
//  HONSettingsNavButtonView.m
//  HotOrNot
//
//  Created by BIM  on 3/13/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "HONSettingsNavButtonView.h"

@implementation HONSettingsNavButtonView

- (id)initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithTarget:target action:action])) {
		[self setFrame:CGRectOffset(self.frame, 263.0, 3.0)];
		_button.frame = CGRectFromSize(CGSizeMake(55.0, 37.0));
		[_button setBackgroundImage:[UIImage imageNamed:@"settingsButton_nonActive"] forState:UIControlStateNormal];
		[_button setBackgroundImage:[UIImage imageNamed:@"settingsButton_Active"] forState:UIControlStateHighlighted];
	}
	
	return (self);
}

@end
