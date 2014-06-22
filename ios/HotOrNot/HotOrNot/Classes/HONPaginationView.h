//
//  HONPaginationView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/22/2014 @ 16:33 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#define DOT_DIAMETER 6.0f
#define DOT_SPACING 8.0f

#define OFF_DURATION 0.0625f
#define ON_DURATION 0.125f


@interface HONPaginationView : UIView {
	int _currentPage;
	int _totalPages;
}

@property (nonatomic) CGFloat diameter;
@property (nonatomic) CGFloat spacing;

- (id)initAtPosition:(CGPoint)pos withTotalPages:(int)totalPages;
- (void)updateToPage:(int)page;

@end
