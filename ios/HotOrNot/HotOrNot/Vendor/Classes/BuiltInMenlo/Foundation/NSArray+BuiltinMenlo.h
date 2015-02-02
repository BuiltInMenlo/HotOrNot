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

- (NSArray *)arrayWithIntersectArray:(NSArray *)otherArray;
- (NSArray *)arrayCombinedWithArray:(NSArray *)otherArray;
- (NSArray *)arrayWithUnionArray:(NSArray *)otherArray;

+ (instancetype)arrayRandomizedWithArray:(NSArray *)array;
+ (instancetype)arrayRandomizedWithArray:(NSArray *)array withCapacity:(NSUInteger)numItems;

- (NSArray *)arrayByRandomizingArray:(NSArray *)array;
- (NSArray *)arrayByRandomizingArray:(NSArray *)array withCapacity:(NSUInteger)numItems;

- (BOOL)containsDuplicates;
- (id)randomElement;
- (NSInteger)randomIndex;
@end

@interface NSMutableArray (BuiltInMenlo)
+ (instancetype)arrayRandomizedWithArray:(NSArray *)array;
+ (instancetype)arrayRandomizedWithArray:(NSArray *)array withCapacity:(NSUInteger)numItems;
//+ (instancetype)arrayWithIntersectArray:(NSArray *)array;
//+ (instancetype)arrayWithUnionArray:(NSArray *)array;

- (NSMutableArray *)arrayWithIntersectArray:(NSArray *)otherArray;

//- (void)intersectArray:(NSArray *)otherArray;
//- (void)unionArray:(NSArray *)otherArray;


- (NSMutableArray *)arrayByRandomizingArray:(NSArray *)array;
- (NSMutableArray *)arrayByRandomizingArray:(NSArray *)array withCapacity:(NSUInteger)numItems;

- (id)randomElement;
- (NSInteger)randomIndex;
- (void)randomize;
@end
