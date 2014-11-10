//
//  HONNavButtonView.m
//  HotOrNot
//
//  Created by BIM  on 10/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"
#import "HONNavButtonView.h"

@interface HONNavButtonView ()
@end

@implementation HONNavButtonView

- (id)initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithFrame:CGRectFromSize(CGSizeMake(44.0, 44.0))])) {
		_button = [UIButton buttonWithType:UIButtonTypeCustom];
		[_button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_button];
	}
	
	return (self);
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	
	_size = CGSizeMake(frame.size.width, frame.size.height);
	_button.frame = CGRectMake(_button.frame.origin.x, _button.frame.origin.y, _size.width, _size.height);
}


@end
