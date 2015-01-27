//
//  NSArray+Additions.h
//  HotOrNot
//
//  Created by BIM  on 1/23/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

@interface NSArray (BuiltInMenlo)
//+ (instancetype)arrayWithIntersectArray:(NSArray *)array;
//+ (instancetype)arrayWithUnionArray:(NSArray *)array;

//- (NSArray *)arrayWithIntersectArray:(NSArray *)otherArray;
//- (NSArray *)arrayWithUnionArray:(NSArray *)otherArray;

- (id)randomElement;
@end

@interface NSMutableArray (BuiltInMenlo)
//+ (instancetype)arrayWithIntersectArray:(NSArray *)array;
//+ (instancetype)arrayWithUnionArray:(NSArray *)array;

//- (void)intersectArray:(NSArray *)otherArray;
//- (void)unionArray:(NSArray *)otherArray;

- (NSArray *)randomize;
- (id)randomElement;
@end
