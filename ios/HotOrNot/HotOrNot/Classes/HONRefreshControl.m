//
//  HONRefreshControl.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/16/2014 @ 22:08 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONRefreshControl.h"


@interface HONRefreshControl ()
@end

@implementation HONRefreshControl {
	 CGFloat originalTopContentInset;
}

- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
	}
	
	return (self);
}

static void *contentOffsetObservingKey = &contentOffsetObservingKey;

- (void)didMoveToSuperview {
	UIView *superview = self.superview;
	
	// Reposition ourself in the scrollview
	if ([superview isKindOfClass:[UIScrollView class]]) {
		[self repositionAboveContent];
		
		[superview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld context:contentOffsetObservingKey];
		originalTopContentInset = [(UIScrollView *)superview contentInset].top - [(UIScrollView *)superview contentInset].bottom;
	}

	// Set the 'UITableViewController.refreshControl' property, if applicable
	if ([superview isKindOfClass:[UITableView class]]) {
		UITableViewController *tableViewController = (UITableViewController *)superview.nextResponder;
		if ([tableViewController isKindOfClass:[UITableViewController class]]) {
			if (tableViewController.refreshControl != (id)self)
				tableViewController.refreshControl = (id)self;
		}
	}
}

- (void)repositionAboveContent {
	CGRect scrollBounds = self.superview.bounds;
	CGFloat height = self.bounds.size.height;
	CGRect newFrame = (CGRect) {
		.origin.x = 0,
		.origin.y = -height,
		.size.width = scrollBounds.size.width,
		.size.height = height
	};
	self.frame = newFrame;
}



#pragma mark - Navigation


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	// Drawing code
}
*/

@end
