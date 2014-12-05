//
//  HONRefreshingLabel.m
//  HotOrNot
//
//  Created by BIM  on 12/4/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONRefreshingLabel.h"

@interface HONRefreshingLabel ()
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic) BOOL isLoading;
@end

@implementation HONRefreshingLabel

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_isLoading = NO;
		_caption = @"";
		
		_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_activityIndicatorView.frame = CGRectTranslate(_activityIndicatorView.frame, CGPointMake((frame.size.width - _activityIndicatorView.frame.size.width) * 0.5, (frame.size.height - _activityIndicatorView.frame.size.height * 0.5)));
//		_activityIndicatorView.transform = [[HONViewDispensor sharedInstance] affineTransformView:_activityIndicatorView toSize:CGSizeMake(20.0, 20.0)];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setText:(NSString *)text {
	[super setText:text];
	_caption = text;
}

- (void)toggleLoading:(BOOL)isLoading {
	_isLoading = isLoading;
	
	if (_isLoading) {
		self.text = @"";
		
		if (self.textAlignment == NSTextAlignmentLeft) {
			_activityIndicatorView.frame = CGRectTranslate(_activityIndicatorView.frame, CGPointMake(0.0, (self.frame.size.height - _activityIndicatorView.frame.size.height) * 0.5));
			
		} else if (self.textAlignment == NSTextAlignmentCenter) {
			_activityIndicatorView.frame = CGRectTranslate(_activityIndicatorView.frame, CGPointMake((self.frame.size.width - _activityIndicatorView.frame.size.width) * 0.5, (self.frame.size.height - _activityIndicatorView.frame.size.height) * 0.5));
			
		} else if (self.textAlignment == NSTextAlignmentRight) {
			_activityIndicatorView.frame = CGRectTranslate(_activityIndicatorView.frame, CGPointMake(self.frame.size.width - _activityIndicatorView.frame.size.width, (self.frame.size.height - _activityIndicatorView.frame.size.height) * 0.5));
		
		} else {
			_activityIndicatorView.frame = CGRectTranslate(_activityIndicatorView.frame, CGPointMake((self.frame.size.width - _activityIndicatorView.frame.size.width) * 0.5, (self.frame.size.height - _activityIndicatorView.frame.size.height) * 0.5));
		}
		
		[self addSubview:_activityIndicatorView];
		[_activityIndicatorView startAnimating];
	
	} else {
		[_activityIndicatorView stopAnimating];
		[_activityIndicatorView removeFromSuperview];
		self.text = _caption;
	}
}


@end
