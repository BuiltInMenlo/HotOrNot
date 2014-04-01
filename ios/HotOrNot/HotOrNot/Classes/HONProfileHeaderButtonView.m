//
//  HONProfileHeaderButtonView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/1/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONProfileHeaderButtonView.h"

@interface HONProfileHeaderButtonView ()
@property (nonatomic, strong) UIButton *profileButton;
@end

@implementation HONProfileHeaderButtonView

- (id)initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithFrame:CGRectMake(8.0, 4.0, 34.0, 34.0)])) {
		//BOOL isVerified = (BOOL)[[[HONAppDelegate infoForUser] objectForKey:@"is_verified"] intValue];
		
		_profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_profileButton.frame = CGRectMake(0.0, 0.0, 34.0, 34.0);
		[_profileButton setBackgroundImage:[UIImage imageNamed:@"headerProfileButton_nonActive"] forState:UIControlStateNormal];
		[_profileButton setBackgroundImage:[UIImage imageNamed:@"headerProfileButton_Active"] forState:UIControlStateHighlighted];
		[_profileButton setBackgroundImage:[UIImage imageNamed:@"headerProfileButton_Active"] forState:UIControlStateSelected];
		[_profileButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_profileButton];
		
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_resetProfileButton:) name:@"RESET_PROFILE_BUTTON" object:nil];
	}
	
	return (self);
}

- (void)toggleSelected:(BOOL)isSelected {
	[_profileButton setSelected:isSelected];
}


#pragma mark - Notifications
- (void)_resetProfileButton:(NSNotification *)notification {
	[_profileButton setSelected:NO];
}

@end
