//
//  HONHomeFeedToggleView.m
//  HotOrNot
//
//  Created by BIM  on 11/24/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONHomeFeedToggleView.h"

@interface HONHomeFeedToggleView()
@property (nonatomic, retain) NSArray *supportedTypes;
@property (nonatomic, assign) HONHomeFeedType feedType;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *recentButton;
@property (nonatomic, strong) UIButton *topButton;
@property (nonatomic) BOOL isEnabled;
@property (nonatomic) BOOL isAnimating;
@end

@implementation HONHomeFeedToggleView
@synthesize delegate = _delegate;
@synthesize supportedTypes = _supportedTypes;

- (id)initWithTypes:(NSArray *)types {
	if ((self = [super initWithFrame:CGRectMake(100.0, 0.0, 134.0, 44.0)])) {
		
		_supportedTypes = types;
		
		_feedType = (HONHomeFeedType)[_supportedTypes firstObject];
		_isAnimating = NO;
		
		_imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toggleButton_Recent"]];
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
	
	_isAnimating = YES;
	[self _toggleButtonHilite:_recentButton isEnabled:YES];
	if ([self.delegate respondsToSelector:@selector(homeFeedToggleView:didSelectFeedType:)])
		[self.delegate homeFeedToggleView:self didSelectFeedType:_feedType];
}

- (void)_goTop {
	_feedType = HONHomeFeedTypeTop;
	_imageView.image = [UIImage imageNamed:@"toggleButton_Top"];
	
	_isAnimating = YES;
	if ([self.delegate respondsToSelector:@selector(homeFeedToggleView:didSelectFeedType:)])
		[self.delegate homeFeedToggleView:self didSelectFeedType:_feedType];
}

#pragma mark - UI Presentation
- (void)_toggleButtonHilite:(UIButton *)button isEnabled:(BOOL)isHilited {
	NSLog(@":\\|> _toggleButtonHilite:[%@] isEnabled:[%@] <|/:", NSStringFromClass(button.class), NSStringFromBOOL(isHilited));
	
	[[HONViewDispensor sharedInstance] tintView:button withColor:[UIColor colorWithWhite:0.0 alpha:(isHilited) ? 0.5 : 0.0]];
	
	if (_isAnimating) {
		double delayInSeconds = 0.125;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
			_isAnimating = NO;
			[self _toggleButtonHilite:button isEnabled:NO];
		});
	}
}


@end
