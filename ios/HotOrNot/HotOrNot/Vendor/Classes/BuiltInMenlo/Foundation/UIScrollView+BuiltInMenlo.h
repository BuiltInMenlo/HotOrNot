//
//  UIScrollView+BuiltInMenlo.h
//  HotOrNot
//
//  Created by BIM  on 1/29/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//


@interface UIScrollView (BuiltInMenlo)
- (BOOL)isAtContentBottom;
- (BOOL)isAtContentLeft;
- (BOOL)isAtContentRight;
- (BOOL)isAtContentTop;
- (CGFloat)scrollPosition;
@end
