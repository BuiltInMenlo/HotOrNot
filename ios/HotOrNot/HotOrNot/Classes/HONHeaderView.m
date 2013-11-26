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

- (id)initWithBranding {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, kNavBarHeaderHeight)])) {
		[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header"]]];
		
		UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate switchEnabledForKey:@"volley_brand"]) ? @"headerLogo_volley" : @"headerLogo_selfieclub"]];
		logoImageView.frame = CGRectOffset(logoImageView.frame, 88.0, 20.0);
		[self addSubview:logoImageView];
	}
	
	return (self);
}

- (id)initWithTitle:(NSString *)title {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, kNavBarHeaderHeight)])) {
		[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header"]]];
		
		_title = title;
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 28.0, 200.0, 24.0)];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:19];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		_titleLabel.text = _title;
		[self addSubview:_titleLabel];
	}
	
	return (self);
}

- (id)initAsModalWithTitle:(NSString *)title {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 64.0)])) {
		[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header_modal"]]];
		
		_title = title;
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 28.0, 200.0, 24.0)];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:19];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		_titleLabel.text = _title;
		[self addSubview:_titleLabel];
	}
	
	return (self);
}

- (void)addButton:(UIView *)buttonView {
	buttonView.frame = CGRectOffset(buttonView.frame, 0.0, 20.0);
	[self addSubview:buttonView];
}

- (void)setTitle:(NSString *)title {
	_title = title;
	_titleLabel.text = _title;
}

- (void)leftAlignTitle {
	_titleLabel.textAlignment = NSTextAlignmentLeft;
}


@end
