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
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 64.0, 44.0)])) {
		_profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_profileButton.frame = CGRectMake(-5.0, 0.0, 64.0, 44.0);
		[_profileButton setBackgroundImage:[UIImage imageNamed:@"profileHeaderButton_nonActive"] forState:UIControlStateNormal];
		[_profileButton setBackgroundImage:[UIImage imageNamed:@"profileHeaderButton_Active"] forState:UIControlStateHighlighted];
		[_profileButton setBackgroundImage:[UIImage imageNamed:@"profileHeaderButton_Tapped"] forState:UIControlStateSelected];
		[_profileButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_profileButton];
	}
	
	return (self);
}

- (void)toggleSelected:(BOOL)isSelected {
	[_profileButton setSelected:isSelected];
}

@end
