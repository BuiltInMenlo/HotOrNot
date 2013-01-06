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
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation HONHeaderView

@synthesize title = _title;

- (id)initWithTitle:(NSString *)title {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 45.0)])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_toggleFBPosting:) name:@"TOGGLE_FB_POSTING" object:nil];
		_title = title;
		
		UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:self.frame];
		[headerImgView setImage:[UIImage imageNamed:@"header"]];
		[self addSubview:headerImgView];
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 10.0, 320.0, 25.0)];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.font = [[HONAppDelegate freightSansBlack] fontWithSize:20];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		_titleLabel.shadowColor = [HONAppDelegate honGreyTxtColor];
		_titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
		_titleLabel.text = _title;
		[self addSubview:_titleLabel];
	}
	
	return (self);
}

- (void)setTitle:(NSString *)title {
	_title = title;
	_titleLabel.text = _title;
}

@end
