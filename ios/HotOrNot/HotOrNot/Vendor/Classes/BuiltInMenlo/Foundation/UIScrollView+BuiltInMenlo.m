//
//  UIScrollView+BuiltInMenlo.m
//  HotOrNot
//
//  Created by BIM  on 1/29/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "UIScrollView+BuiltInMenlo.h"

@implementation UIScrollView (BuiltInMenlo)

- (BOOL)isAtContentBottom {
	return ([self scrollPosition] >= self.contentSize.height);
}

- (BOOL)isAtContentLeft {
	return ([self scrollPosition] <= 0.0);
}

- (BOOL)isAtContentRight {
	return ([self scrollPosition] >= self.contentSize.width);
}

- (BOOL)isAtContentTop {
	return ([self scrollPosition] <= 0.0);
}

- (CGFloat)scrollPosition {
	if (self.contentSize.height > self.frame.size.height)
		return ((self.contentOffset.y + self.frame.size.height) - (self.contentInset.top + self.contentInset.bottom));
	
	else if (self.contentSize.width > self.frame.size.width)
		return ((self.contentOffset.x + self.frame.size.width) - (self.contentInset.left + self.contentInset.right));
	
	return ((self.frame.size.width > self.frame.size.height) ? self.frame.size.width : self.frame.size.height);
}

@end