//
//  HONProfileHeaderButtonView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/1/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONProfileHeaderButtonView.h"

@interface HONProfileHeaderButtonView ()
@property (nonatomic, strong) UIButton *button;
@end

@implementation HONProfileHeaderButtonView

- (id)initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 93.0, 44.0)])) {
		//BOOL isVerified = (BOOL)[[[HONAppDelegate infoForUser] objectForKey:@"is_verified"] intValue];
		
		_button = [UIButton buttonWithType:UIButtonTypeCustom];
		_button.frame = CGRectMake(0.0, 0.0, 93.0, 44.0);
		[_button setBackgroundImage:[UIImage imageNamed:@"profileButton_nonActive"] forState:UIControlStateNormal];
		[_button setBackgroundImage:[UIImage imageNamed:@"profileButton_Active"] forState:UIControlStateHighlighted];
		[_button setBackgroundImage:[UIImage imageNamed:@"profileButton_Active"] forState:UIControlStateSelected];
		[_button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_button];
		
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_resetProfileButton:) name:@"RESET_PROFILE_BUTTON" object:nil];
	}
	
	return (self);
}

- (void)toggleSelected:(BOOL)isSelected {
	[_button setSelected:isSelected];
}


#pragma mark - Navigation


#pragma mark - Notifications
- (void)_resetProfileButton:(NSNotification *)notification {
	[_button setSelected:NO];
}

@end
