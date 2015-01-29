//
//  UIView+ReverseSubviews.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/20/2014.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIView+BuiltInMenlo.h"

@implementation UIView (BuiltInMenlo)

- (UIEdgeInsets)frameEdges {
	return (UIEdgeInsetsMake(self.frame.origin.y, self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.origin.x + self.frame.size.width));
}

- (void)reverseSubviews {
	NSMutableArray *views = [NSMutableArray array];
	for (UIView *view in self.subviews)
		[views addObject:view];
	
	for (UIView *view in self.subviews)
		[view removeFromSuperview];
	
	for (UIView *view in [[views reverseObjectEnumerator] allObjects])
		[self addSubview:view];
	
	views = nil;
}

@end
