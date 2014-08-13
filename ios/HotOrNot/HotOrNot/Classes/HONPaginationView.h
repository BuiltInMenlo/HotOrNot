//
//  HONPaginationView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/22/2014 @ 16:33 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#define OFF_DURATION 0.0625f
#define ON_DURATION 0.125f

@interface HONPaginationView : UIView {
	int _currentPage;
	int _totalPages;
}

@property (nonatomic) CGFloat diameter;
@property (nonatomic) CGFloat padding;

- (id)initAtPosition:(CGPoint)pos withTotalPages:(int)totalPages usingDiameter:(CGFloat)diameter andPadding:(CGFloat)padding;
- (void)updateToPage:(int)page;
@end
