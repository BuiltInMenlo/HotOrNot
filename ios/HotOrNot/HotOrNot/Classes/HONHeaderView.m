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
		_title = title;
		
		UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:self.frame];
		[headerImgView setImage:[UIImage imageNamed:@"header"]];
		[self addSubview:headerImgView];
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 12.0, 320.0, 24.0)];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.font = [[HONAppDelegate cartoGothicBold] fontWithSize:18];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		_titleLabel.shadowColor = [UIColor colorWithRed:0.027 green:0.180 blue:0.302 alpha:1.0];
		_titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		_titleLabel.text = _title;
		[self addSubview:_titleLabel];
		
		_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		_activityIndicatorView.frame = CGRectMake(11.0, 11.0, 24.0, 24.0);
		[self addSubview:_activityIndicatorView];
		
		_refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_refreshButton.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
		[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_nonActive"] forState:UIControlStateNormal];
		[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_Active"] forState:UIControlStateHighlighted];
		[self addSubview:_refreshButton];
	}
	
	return (self);
}

- (void)setTitle:(NSString *)title {
	_title = title;
	_titleLabel.text = _title;
}

- (void)toggleRefresh:(BOOL)isRefreshing {
	(isRefreshing) ? [_activityIndicatorView startAnimating] : [_activityIndicatorView stopAnimating];
	_refreshButton.hidden = isRefreshing;
}

- (void)hideRefreshing {
	[_activityIndicatorView removeFromSuperview];
	[_refreshButton removeFromSuperview];
}


@end
