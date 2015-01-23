//
//  NSArray+Additions.h
//  HotOrNot
//
//  Created by BIM  on 1/23/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

@interface NSArray (Additions)
//+ (instancetype)arrayWithIntersectArray:(NSArray *)array;
//+ (instancetype)arrayWithUnionArray:(NSArray *)array;

- (NSArray *)arrayWithIntersectArray:(NSArray *)otherArray;
- (NSArray *)arrayWithUnionArray:(NSArray *)otherArray;
@end

@interface NSMutableArray (Additions)
//+ (instancetype)arrayWithIntersectArray:(NSArray *)array;
//+ (instancetype)arrayWithUnionArray:(NSArray *)array;

- (void)intersectArray:(NSArray *)otherArray;
- (void)unionArray:(NSArray *)otherArray;
@end
