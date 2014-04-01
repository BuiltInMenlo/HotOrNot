//
//  HONCreateSnapButtonView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/11/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONCreateSnapButtonView.h"

@interface HONCreateSnapButtonView()
@property (nonatomic, strong) UIButton *createSnapButton;
@end

@implementation HONCreateSnapButtonView

- (id)initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithFrame:CGRectMake(269.0, 0.0, 44.0, 44.0)])) {
		_createSnapButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_createSnapButton.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
		[_createSnapButton setBackgroundImage:[UIImage imageNamed:@"headerCameraButton_nonActive"] forState:UIControlStateNormal];
		[_createSnapButton setBackgroundImage:[UIImage imageNamed:@"headerCameraButton_Active"] forState:UIControlStateHighlighted];
		[_createSnapButton addTarget:target action:action forControlEvents:UIControlEventTouchDown];
		[self addSubview:_createSnapButton];
	}
	
	return (self);
}

@end
