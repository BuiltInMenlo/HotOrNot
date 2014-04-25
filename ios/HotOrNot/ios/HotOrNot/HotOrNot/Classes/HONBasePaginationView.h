//
//  HONBasePaginationView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/22/2014 @ 16:33 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#define DOT_DIAMETER 7.0f
#define DOT_SPACING 8.0f

#define OFF_DURATION 0.0625f
#define ON_DURATION 0.125f


@interface HONBasePaginationView : UIView {
	int _currentPage;
	int _totalPages;
}

- (id)initAtPosition:(CGPoint)pos withTotalPages:(int)totalPages;
- (void)updateToPage:(int)page;

@end
