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
#define kResetDuration 1.333f


@interface EGORefreshTableHeaderView ()
@property (nonatomic) EGOPullRefreshState state;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic) CGFloat tareOffset;
@property (nonatomic) CGFloat loadingThreshold;
@property (nonatomic) BOOL isLoading;
@end

@implementation EGORefreshTableHeaderView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = self.superview.backgroundColor;
		
		_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_activityIndicatorView.frame = CGRectOffset(_activityIndicatorView.frame, (frame.size.width - _activityIndicatorView.frame.size.width) * 0.5, frame.size.height - (_activityIndicatorView.frame.size.height + ((kLoadingTheshold - _activityIndicatorView.frame.size.height) * 0.5)));
		[self addSubview:_activityIndicatorView];
		
		_isLoading = NO;
		[self setState:EGOOPullRefreshNormal];
	}
	
	return (self);
}

- (id)initWithFrame:(CGRect)frame usingTareOffset:(CGFloat)tareOffset {
	if (self = [self initWithFrame:frame]) {
		_tareOffset = tareOffset;
		_loadingThreshold = _tareOffset + kLoadingTheshold;
	}
	
	return (self);
}

- (id)initWithFrame:(CGRect)frame headerOverlaps:(BOOL)isOverlapping {
	if (self = [self initWithFrame:frame usingTareOffset:((int)!isOverlapping) * kHeaderOffset]) {
		//_loadingThreshold += ((int)isOverlapping) * kHeaderOffset;
	}
	
	return (self);
}


#pragma mark - Public API
- (void)setState:(EGOPullRefreshState)aState {
	switch (aState) {
		case EGOOPullRefreshNormal:
			break;
			
		case EGOOPullRefreshPulling:
			break;
						
		case EGOOPullRefreshLoading:
			break;
			
		default:
			break;
	}
	
	_state = aState;
	if (_state == EGOOPullRefreshNormal) {
		if (_activityIndicatorView.alpha > 0.0) {
			[UIView animateWithDuration:0.25 animations:^(void) {
				_activityIndicatorView.alpha = 0.0;
			} completion:^(BOOL finished) {
				if ([_activityIndicatorView isAnimating])
					[_activityIndicatorView stopAnimating];
			}];
		}
	
	} else {
		if (![_activityIndicatorView isAnimating])
			[_activityIndicatorView startAnimating];
		
		if (_activityIndicatorView.alpha < 1.0) {
			[UIView animateWithDuration:0.25 animations:^(void) {
				_activityIndicatorView.alpha = 1.0;
			} completion:^(BOOL finished) {}];
		}
	}
}


#pragma mark - ScrollView Methods
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
	NSLog(@"\n\n—|PRE]-/> svDidScroll STATE:[%@] offset:[%.02f] inset:[%@] TH:[%.01f] D:[%@] L:[%@]", [self _nameForState], scrollView.contentOffset.y, NSStringFromUIEdgeInsets(scrollView.contentInset), _loadingThreshold, (scrollView.isDragging) ? @"Y" : @"N", (_isLoading) ? @"Y" : @"N");
	
	if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) && scrollView.contentSize.height > scrollView.frame.size.height)
		return;
	
	if (_state == EGOOPullRefreshNormal) {
		[scrollView setContentInset:UIEdgeInsetsMake(_tareOffset, 0.0, scrollView.contentInset.bottom, 0.0)];
	
	} else if (_state == EGOOPullRefreshLoading) {
		[scrollView setContentInset:UIEdgeInsetsMake(MIN(MAX(-scrollView.contentOffset.y, 1.0), _loadingThreshold), 0.0, scrollView.contentInset.bottom, 0.0)];
	
	} else if (_state == EGOOPullRefreshReseting) {
		if (scrollView.contentOffset.y > _tareOffset)
			[scrollView setContentOffset:CGPointMake(0.0, _tareOffset) animated:YES];
	}
	
	if (scrollView.isDragging) {
		if (!_isLoading) {
			if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -_loadingThreshold && scrollView.contentOffset.y < _tareOffset) // resetting
				[self setState:EGOOPullRefreshNormal];
				
			else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -_loadingThreshold) // passed threshold
				[self setState:EGOOPullRefreshPulling];
		}
		
		if (scrollView.contentInset.top != _tareOffset)  
			[scrollView setContentInset:UIEdgeInsetsMake(_tareOffset, 0.0, scrollView.contentInset.bottom, 0.0)];
	
	} else {
		if ((scrollView.contentOffset.y > _tareOffset && scrollView.contentOffset.y < _loadingThreshold) && !scrollView.pagingEnabled)
			[scrollView setContentOffset:CGPointMake(0.0, _tareOffset) animated:YES];
	}
	
	NSLog(@"—|POST]-/> svDidScroll STATE:[%@] offset:[%.02f] TARE/THRESH:[%.02f/%.02f] DRAG:[%@] LOAD:[%@] PG:[%@]", [self _nameForState], scrollView.contentOffset.y, _tareOffset, _loadingThreshold, (scrollView.isDragging) ? @"Y" : @"N", (_isLoading) ? @"Y" : @"N", (scrollView.pagingEnabled) ? @"Y" : @"N");
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
//	NSLog(@"\n\n—|PRE]-/> svDidEndDragging STATE:[%@] offset:[%.02f] inset:[%@] TH:[%.01f] D:[%@] L:[%@]", [self _nameForState], scrollView.contentOffset.y, NSStringFromUIEdgeInsets(scrollView.contentInset), _loadingThreshold, (scrollView.isDragging) ? @"Y" : @"N", (_isLoading) ? @"Y" : @"N");
	
	if (scrollView.contentOffset.y <= -_loadingThreshold && !_isLoading) { // now loading
		if ([self.delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)])
			[self.delegate egoRefreshTableHeaderDidTriggerRefresh:self];
		
		_isLoading = YES;
		[self setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.25];
		[scrollView setContentInset:UIEdgeInsetsMake(_loadingThreshold, 0.0, scrollView.contentInset.bottom, 0.0)];
		[UIView commitAnimations];
		
	} else
		[self setState:EGOOPullRefreshNormal];
//		[self setState:EGOOPullRefreshReseting];
	
//	NSLog(@"\n—|POST]-/> svDidEndDragging STATE:[%@] offset:[%.02f] inset:[%@] TH:[%.01f] D:[%@] L:[%@]", [self _nameForState], scrollView.contentOffset.y, NSStringFromUIEdgeInsets(scrollView.contentInset), _loadingThreshold, (scrollView.isDragging) ? @"Y" : @"N", (_isLoading) ? @"Y" : @"N");
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
	NSLog(@"\n\n—|PRE]-/> svDataSourceDidFinishedLoading STATE:[%@] offset:[%.02f] inset:[%@] TH:[%.01f]", [self _nameForState], scrollView.contentOffset.y, NSStringFromUIEdgeInsets(scrollView.contentInset), _loadingThreshold);
	
//	_isLoading = NO;
//	[UIView beginAnimations:nil context:NULL];
//	[UIView setAnimationDuration:0.125];
//	[scrollView setContentInset:UIEdgeInsetsMake(_tareOffset, 0.0, 0.0, 0.0)];
//	[UIView commitAnimations];
	
	[UIView animateWithDuration:kResetDuration animations:^(void) {
		//[scrollView setContentInset:UIEdgeInsetsMake(_tareOffset, 0.0, scrollView.contentInset.bottom, 0.0)];
		[scrollView setContentOffset:CGPointMake(0.0, _tareOffset) animated:YES];//UIEdgeInsetsMake(_tareOffset, 0.0, scrollView.contentInset.bottom, 0.0)];
	} completion:^(BOOL finished) {
		_isLoading = NO;
		[self setState:EGOOPullRefreshNormal];
		
		if ([self.delegate respondsToSelector:@selector(egoRefreshTableHeaderDidFinishTareAnimation:)])
			[self.delegate egoRefreshTableHeaderDidFinishTareAnimation:self];
	}];
	
//	[self setState:EGOOPullRefreshReseting];
//	[self setState:EGOOPullRefreshNormal];
	
	NSLog(@"—|POST]-/> svDataSourceDidFinishedLoading STATE:[%@] offset:[%.02f] inset:[%@] TH:[%.01f]", [self _nameForState], scrollView.contentOffset.y, NSStringFromUIEdgeInsets(scrollView.contentInset), _loadingThreshold);
}


#pragma mark - Dealloc
- (void)dealloc {
	self.delegate = nil;
	
	[super dealloc];
}



- (NSString *)_nameForState {
	return ([(_state == EGOOPullRefreshNormal) ? @"Normal" : (_state == EGOOPullRefreshPulling) ? @"Pulling" : @"Loading" uppercaseString]);
}

@end
