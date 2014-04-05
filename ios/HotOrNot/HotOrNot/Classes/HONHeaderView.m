//
//  HONHeaderView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.14.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONHeaderView.h"
#import "HONFontAllocator.h"

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
		[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:(withBG) ? @"navHeaderBackground" : @""]]];
		
		_title = title;
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 40.0, 170.0, 21.0)];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.font = [[[HONFontAllocator sharedInstance] cartoGothicBook] fontWithSize:21];
		_titleLabel.textColor = [UIColor blackColor];
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		_titleLabel.text = _title;
		[self addSubview:_titleLabel];
	}
	
	return (self);
}

- (void)addButton:(UIView *)buttonView {
	buttonView.frame = CGRectOffset(buttonView.frame, 0.0, 26.0);
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
