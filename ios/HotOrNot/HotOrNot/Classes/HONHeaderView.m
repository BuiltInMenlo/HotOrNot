//
//  HONHeaderView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.14.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONHeaderView.h"
#import "HONAppDelegate.h"

@interface HONHeaderView()
@property (nonatomic, strong) UIButton *fbButton;

@end

@implementation HONHeaderView

@synthesize fbButton = _fbButton;

- (id)initWithTitle:(NSString *)title {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 45.0)])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_toggleFBPosting:) name:@"TOGGLE_FB_POSTING" object:nil];
		
		UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:self.frame];
		[headerImgView setImage:[UIImage imageNamed:@"header.png"]];
		[self addSubview:headerImgView];
		
		_fbButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_fbButton.frame = CGRectMake(5.0, 5.0, 59.0, 34.0);
		[_fbButton setBackgroundImage:[UIImage imageNamed:@"facebookToggle_off"] forState:UIControlStateNormal];
		[_fbButton setBackgroundImage:[UIImage imageNamed:@"facebookToggle_on"] forState:UIControlStateSelected];
		[_fbButton addTarget:self action:@selector(_goFBToggle) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_fbButton];
		
		[_fbButton setSelected:[HONAppDelegate allowsFBPosting]];
		
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 10.0, 320.0, 25.0)];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.font = [HONAppDelegate honHelveticaNeueFontBold];
		titleLabel.textColor = [UIColor colorWithRed:0.12549019607843 green:0.31764705882353 blue:0.44705882352941 alpha:1.0];
		titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.33];
		titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		titleLabel.text = title;
		[self addSubview:titleLabel];
	}
	
	return (self);
}

- (void)_goFBToggle {
	[HONAppDelegate setAllowsFBPosting:![HONAppDelegate allowsFBPosting]];
	[_fbButton setSelected:[HONAppDelegate allowsFBPosting]];//[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_FB_POSTING" object:nil];
}

- (void)_toggleFBPosting:(NSNotification *)notification {
	[_fbButton setSelected:[HONAppDelegate allowsFBPosting]];
}

@end
