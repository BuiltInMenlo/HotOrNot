//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

//
//  HONAppDelegate.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "EGORefreshTableHeaderView.h"

#define kHeaderOffset 64.0f
#define kLoadingTheshold 40.0f


@interface EGORefreshTableHeaderView ()
@property (nonatomic) EGOPullRefreshState state;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic) CGFloat headerOffset;
@property (nonatomic) BOOL isLoading;
@end

@implementation EGORefreshTableHeaderView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame withHeaderOffset:(BOOL)isOffset {
	if (self = [super initWithFrame:frame]) {
		_headerOffset = isOffset * kHeaderOffset;
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor whiteColor];
		
		_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_activityIndicatorView.frame = CGRectMake(148.0, frame.size.height - kLoadingTheshold, 24.0, 24.0);
		[self addSubview:_activityIndicatorView];
		
		[self setState:EGOOPullRefreshNormal];
	}
	
	return (self);
}


#pragma mark - Public API
- (void)setState:(EGOPullRefreshState)aState {
	switch (aState) {
		case EGOOPullRefreshPulling:
			[_activityIndicatorView startAnimating];
			_activityIndicatorView.hidden = NO;
			
			if (_activityIndicatorView.alpha < 1.0) {
				[UIView animateWithDuration:0.25 animations:^(void) {
					_activityIndicatorView.alpha = 1.0;
				}];
			}
			break;
			
		case EGOOPullRefreshNormal:
			if (_state == EGOOPullRefreshPulling) {
			}
			
			if (_activityIndicatorView.alpha > 0.0) {
				[UIView animateWithDuration:0.25 animations:^(void) {
					_activityIndicatorView.alpha = 0.0;
				} completion:^(BOOL finished) {
					[_activityIndicatorView stopAnimating];
					_activityIndicatorView.hidden = YES;
				}];
			}
			
			break;
			
		case EGOOPullRefreshLoading:
			[_activityIndicatorView startAnimating];
			_activityIndicatorView.hidden = NO;
			break;
			
		default:
			break;
	}
	
	_state = aState;
}


#pragma mark - ScrollView Methods
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
//	NSLog(@"egoRefreshScrollViewDidScroll OFFSET:[%f] INSET:[%@]", -scrollView.contentOffset.y, NSStringFromUIEdgeInsets(scrollView.contentInset));
	
	if (_state == EGOOPullRefreshLoading) {
		scrollView.contentInset = UIEdgeInsetsMake(MIN(MAX(-scrollView.contentOffset.y, _headerOffset), kLoadingTheshold + _headerOffset), 0.0f, 0.0f, 0.0f);
		
	} else if (scrollView.isDragging) {
		_isLoading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		
		if (!_isLoading) {
			if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -kLoadingTheshold - _headerOffset && scrollView.contentOffset.y < _headerOffset) {
				[self setState:EGOOPullRefreshNormal];
				
			} else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -kLoadingTheshold - _headerOffset) {
				[self setState:EGOOPullRefreshPulling];
			}
		}
		
		if (scrollView.contentInset.top != _headerOffset)
			scrollView.contentInset = UIEdgeInsetsMake(_headerOffset, 0.0f, 0.0f, 0.0f);
	}
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
//	NSLog(@"egoRefreshScrollViewDidEndDragging INSET:[%@]", NSStringFromUIEdgeInsets(scrollView.contentInset));
	
	if (scrollView.contentOffset.y <= -kLoadingTheshold - _headerOffset && !_isLoading) {
		[self.delegate egoRefreshTableHeaderDidTriggerRefresh:self];
		
		[self setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(kLoadingTheshold + _headerOffset, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
	}
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
//	NSLog(@"egoRefreshScrollViewDataSourceDidFinishedLoading INSET:[%@]", NSStringFromUIEdgeInsets(scrollView.contentInset));
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	scrollView.contentInset = UIEdgeInsetsMake(_headerOffset, 0.0f, 0.0f, 0.0f);
//	scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
	[UIView commitAnimations];
	
	[self setState:EGOOPullRefreshNormal];
}


#pragma mark - Dealloc
- (void)dealloc {
	self.delegate = nil;
	
	[super dealloc];
}

@end
