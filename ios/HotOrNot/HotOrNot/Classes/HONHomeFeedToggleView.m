//
//  HONHomeFeedToggleView.m
//  HotOrNot
//
//  Created by BIM  on 11/24/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONHomeFeedToggleView.h"

@interface HONHomeFeedToggleView()
@property (nonatomic, assign) HONHomeFeedType feedType;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *recentButton;
@property (nonatomic, strong) UIButton *topButton;
@property (nonatomic) BOOL isEnabled;
@end

@implementation HONHomeFeedToggleView
@synthesize delegate = _delegate;

- (id)initAsType:(HONHomeFeedType)feedType {
	if ((self = [super initWithFrame:CGRectMake(100.0, 20.0, 134.0, 44.0)])) {
		_feedType = feedType;
		_isEnabled = NO;
		
		_imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(_feedType == HONHomeFeedTypeRecent) ? @"toggleButton_Recent" : @"toggleButton_Top"]];
		_imageView.userInteractionEnabled = _isEnabled;
		[self addSubview:_imageView];
		
		_recentButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_recentButton.frame = CGRectMake(8.0, 8.0, 59.0, 28.0);
		[_recentButton addTarget:self action:@selector(_goRecent) forControlEvents:UIControlEventTouchUpInside];
		[_imageView addSubview:_recentButton];
		
		_topButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_topButton.frame = CGRectMake(67.0, 8.0, 59.0, 28.0);
		[_topButton addTarget:self action:@selector(_goTop) forControlEvents:UIControlEventTouchUpInside];
		[_imageView addSubview:_topButton];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)toggleEnabled:(BOOL)isEnabled {
	_isEnabled = isEnabled;
	_imageView.userInteractionEnabled = _isEnabled;
}


#pragma mark - Navigation
- (void)_goRecent {
	_feedType = HONHomeFeedTypeRecent;
	_imageView.image = [UIImage imageNamed:@"toggleButton_Recent"];
	
	if ([self.delegate respondsToSelector:@selector(homeFeedToggleView:didSelectFeedType:)])
		[self.delegate homeFeedToggleView:self didSelectFeedType:_feedType];
}

- (void)_goTop {
	_feedType = HONHomeFeedTypeTop;
	_imageView.image = [UIImage imageNamed:@"toggleButton_Top"];
	
	if ([self.delegate respondsToSelector:@selector(homeFeedToggleView:didSelectFeedType:)])
		[self.delegate homeFeedToggleView:self didSelectFeedType:_feedType];
}


@end
