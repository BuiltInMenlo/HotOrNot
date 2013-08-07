//
//  HONRefreshButtonView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/5/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONRefreshButtonView.h"

@interface HONRefreshButtonView()
@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation HONRefreshButtonView

- (id)initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 50.0, 44.0)])) {
		_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		_activityIndicatorView.frame = CGRectMake(6.0, 10.0, 24.0, 24.0);
		[self addSubview:_activityIndicatorView];
		
		_refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_refreshButton.frame = CGRectMake(-5.0, -1.0, 50.0, 44.0);
		[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_nonActive"] forState:UIControlStateNormal];
		[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_Active"] forState:UIControlStateHighlighted];
		[_refreshButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_refreshButton];
	}
	
	return (self);
}

- (void)toggleRefresh:(BOOL)isRefreshing {
	(isRefreshing) ? [_activityIndicatorView startAnimating] : [_activityIndicatorView stopAnimating];
	_refreshButton.hidden = isRefreshing;
}


@end
