//
//  HONScrollView.m
//  HotOrNot
//
//  Created by BIM  on 11/25/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONScrollView.h"

@implementation HONScrollView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.contentSize = self.frame.size;
		self.contentOffset = CGPointZero;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
	}
	
	return (self);
}

#pragma mark - Overrides
- (void)setContentInset:(UIEdgeInsets)contentInset {
	if (self.tracking) {
		CGPoint translation = [self.panGestureRecognizer translationInView:self];
		translation.y -= ((contentInset.top - self.contentInset.top) * 1.5);
		[self.panGestureRecognizer setTranslation:translation inView:self];
	}
	
	[super setContentInset:contentInset];
}

@end
