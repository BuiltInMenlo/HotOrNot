//
//  HONHeaderView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.14.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONHeaderView.h"

@interface HONHeaderView()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation HONHeaderView
@synthesize title = _title;

- (id)initWithTitle:(NSString *)title {
	if ((self = [self initWithTitle:title hasBackground:([title length] > 0)])) {
	}
	
	return (self);
}

- (id)initWithTitle:(NSString *)title hasBackground:(BOOL)withBG {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, kNavHeaderHeight)])) {
		[self addSubview:[[UIImageView alloc] initWithImage:(withBG) ? [UIImage imageNamed:@"navHeaderBackground"] : [[UIImage alloc] init]]];
		
		_title = title;
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 31.0, 170.0, 19.0)];
		_titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:17];
		_titleLabel.textColor = [UIColor blackColor];
		_titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		_titleLabel.text = _title;
		[self addSubview:_titleLabel];
	}
	
	return (self);
}


- (void)setTitle:(NSString *)title {
	_title = title;
	_titleLabel.text = _title;
}


- (void)addButton:(UIView *)buttonView {
	buttonView.frame = CGRectOffset(buttonView.frame, 0.0, 19.0);
	[self addSubview:buttonView];
}

- (void)leftAlignTitle {
	_titleLabel.textAlignment = NSTextAlignmentLeft;
}

- (void)toggleLightStyle:(BOOL)isLightStyle {
	_titleLabel.textColor = (isLightStyle) ? [UIColor whiteColor] : [UIColor blackColor];
	_titleLabel.shadowColor = (isLightStyle) ? [UIColor colorWithWhite:0.0 alpha:0.75] : [UIColor clearColor];
}


@end
