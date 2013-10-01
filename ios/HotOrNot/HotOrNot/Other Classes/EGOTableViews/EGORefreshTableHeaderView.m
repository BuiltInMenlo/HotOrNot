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

#import "EGORefreshTableHeaderView.h"
#import "HONAppDelegate.h"

#define TEXT_COLOR	 [UIColor blackColor]
#define FLIP_ANIMATION_DURATION 0.18f


@interface EGORefreshTableHeaderView (Private)
- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation EGORefreshTableHeaderView

@synthesize delegate = _delegate;


- (id)initWithFrame:(CGRect)frame withHeaderOffset:(BOOL)isOffset {
	if (self = [super initWithFrame:frame]) {
		_headerOffset = isOffset * 64.0;
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		_activityIndicatorView.frame = CGRectMake(148.0, frame.size.height - 30.0, 24.0, 24.0);
		[self addSubview:_activityIndicatorView];
		
		[self setState:EGOOPullRefreshNormal];
	}
	
	return (self);
}


#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate {
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
		
		NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setAMSymbol:@"am"];
		[formatter setPMSymbol:@"pm"];
		[formatter setDateFormat:@"MM/dd/yyyy @ hh:mma"];
		_statusLabel.text = [NSString stringWithFormat:@"Last loaded %@", [formatter stringFromDate:date]];
		[[NSUserDefaults standardUserDefaults] setObject:_statusLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	} else {
		
		_statusLabel.text = nil;
		
	}
}

- (void)setState:(EGOPullRefreshState)aState{
	switch (aState) {
		case EGOOPullRefreshPulling:
			_statusLabel.text = NSLocalizedString(@"Release to refresh…", @"Release to refresh status");
			
			[_activityIndicatorView startAnimating];
			_activityIndicatorView.hidden = NO;
			break;
			
		case EGOOPullRefreshNormal:
			if (_state == EGOOPullRefreshPulling) {
			}
			
			[_activityIndicatorView stopAnimating];
			_activityIndicatorView.hidden = YES;
			
			_statusLabel.text = NSLocalizedString(@"Pull down to refresh…", @"Pull down to refresh status");
			[self refreshLastUpdatedDate];			
			break;
			
		case EGOOPullRefreshLoading:
			_statusLabel.text = NSLocalizedString(@"Refreshing…", @"Loading Status");
			
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
	
	if (_state == EGOOPullRefreshLoading) {
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, _headerOffset);
		offset = MIN(offset, 44.0 + _headerOffset);
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
		
	} else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
			_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		}
		
		if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -40.0f - _headerOffset && scrollView.contentOffset.y < 0.0f + _headerOffset && !_loading) {
			[self setState:EGOOPullRefreshNormal];
			
		} else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -40.0f - _headerOffset && !_loading) {
			[self setState:EGOOPullRefreshPulling];
		}
		
		if (scrollView.contentInset.top != _headerOffset) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
	}
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y <= -40.0f - _headerOffset && !_loading) {
		
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
			[_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
		}
		
		[self setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(44.0f + _headerOffset, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
	}
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f + _headerOffset, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[self setState:EGOOPullRefreshNormal];
	
}


//- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
//	if (_state == EGOOPullRefreshLoading) {
//		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 64);
//		offset = MIN(offset, 108);
//		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
//		
//	} else if (scrollView.isDragging) {
//		
//		BOOL _loading = NO;
//		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
//			_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
//		}
//		
//		if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -100.0f && scrollView.contentOffset.y < 64.0f && !_loading) {
//			[self setState:EGOOPullRefreshNormal];
//		
//		} else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -100.0f && !_loading) {
//			[self setState:EGOOPullRefreshPulling];
//		}
//		
//		if (scrollView.contentInset.top != 64) {
//			scrollView.contentInset = UIEdgeInsetsMake(64.0, 0.0f, 0.0f, 0.0f);
//		}
//	}
//}
//
//- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
//	//NSLog(@"egoRefreshScrollViewDidEndDragging");
//	
//	BOOL _loading = NO;
//	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
//		_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
//	}
//	
//	if (scrollView.contentOffset.y <= -100.0f && !_loading) {
//		NSLog(@"%f %d",scrollView.contentOffset.y, !_loading);
//		
//		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
//			[_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
//		}
//		
//		
//		[self setState:EGOOPullRefreshLoading];
//		[UIView beginAnimations:nil context:NULL];
//		[UIView setAnimationDuration:0.2];
//		scrollView.contentInset = UIEdgeInsetsMake(108.0f, 0.0f, 0.0f, 0.0f);
//		[UIView commitAnimations];
//	}
//}
//
//- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {	
//	//NSLog(@"egoRefreshScrollViewDataSourceDidFinishedLoading");
//	
//	[UIView beginAnimations:nil context:NULL];
//	[UIView setAnimationDuration:0.3];
//	[scrollView setContentInset:UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 0.0f)];
//	[UIView commitAnimations];
//	
//	[self setState:EGOOPullRefreshNormal];
//	
//}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	
	_delegate=nil;
	_statusLabel = nil;
	
	[super dealloc];
}

@end
