//
//  HONHeaderView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.14.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONHeaderView.h"

@interface HONHeaderView()
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation HONHeaderView
@synthesize title = _title;


- (id)init {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, kNavHeaderHeight)])) {
		_bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navHeaderBackground"]];
		[self addSubview:_bgImageView];
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 32.0, 170.0, 19.0)];
		_titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:17];
		_titleLabel.textColor = [UIColor blackColor];
		_titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_titleLabel];
	}
	
	return (self);
}

- (id)initWithTitle:(NSString *)title {
	if ((self = [self init])) {
		_title = title;
		_titleLabel.text = _title;
	}
	
	return (self);
}

- (id)initWithTitleImage:(UIImage *)image {
	if ((self = [self init])) {
		_title = @"";
		
		[self addTitleImage:image];
	}
	
	return (self);
}


- (void)setTitle:(NSString *)title {
	_title = title;
	_titleLabel.text = _title;
}

- (void)addTitleImage:(UIImage *)image {
	_title = @"";
	
	UIImageView *titleImageView = [[UIImageView alloc] initWithImage:image];
	titleImageView.frame = CGRectOffset(titleImageView.frame, 62.0, 20.0);
	[self addSubview:titleImageView];
}

- (void)addButton:(UIView *)buttonView {
	buttonView.frame = CGRectOffset(buttonView.frame, 0.0, 19.0);
	[self addSubview:buttonView];
}

- (void)leftAlignTitle {
	_titleLabel.textAlignment = NSTextAlignmentLeft;
}

- (void)toggleLightStyle:(BOOL)isLightStyle {
	_bgImageView.image = (isLightStyle) ? [UIImage imageNamed:@"navHeaderBackgroundLight"] : [UIImage imageNamed:@"navHeaderBackground"];
	
	_titleLabel.textColor = (isLightStyle) ? [UIColor whiteColor] : [UIColor blackColor];
	_titleLabel.shadowColor = (isLightStyle) ? [UIColor colorWithWhite:0.0 alpha:0.75] : [UIColor clearColor];
	
	if (_titleLabel == nil)
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.frame.origin.x, (isLightStyle) ? 32.0 : 31.0, _titleLabel.frame.size.width, _titleLabel.frame.size.height)];
	_titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, (isLightStyle) ? 32.0 : 31.0, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
}


@end
