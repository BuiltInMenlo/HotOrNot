//
//  NSArray+Additions.m
//  HotOrNot
//
//  Created by BIM  on 1/23/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "NSArray+Additions.h"

@implementation NSArray (Additions)
//+ (instancetype)arrayWithIntersectArray:(NSArray *)array {
//	NSMutableArray *intersectArray = [[NSMutableArray arrayWithArray:self];
//	return ([intersectArray intersectArray:array]);
//}
//
//+ (instancetype)arrayWithUnionArray:(NSArray *)array {
//	return ([[NSArray alloc] initWithArray:[self arrayWithUnionArray:array]]);
//}


- (NSArray *)arrayWithIntersectArray:(NSArray *)otherArray {
	NSMutableSet *orgSet = [[NSMutableSet alloc] initWithArray:self];
	NSSet *otherSet = [[NSSet alloc] initWithArray:otherArray];
	
	[orgSet intersectSet:otherSet];
	
	for (id symbol in orgSet) {
		NSLog(@"%@", symbol);
	}
	
	return ([orgSet allObjects]);
}

- (NSArray *)arrayWithUnionArray:(NSArray *)otherArray {
	NSMutableSet *orgSet = [[NSMutableSet alloc] initWithArray:self];
	NSSet *otherSet = [[NSSet alloc] initWithArray:otherArray];
	
	[orgSet unionSet:otherSet];
	
	for (id symbol in orgSet) {
		NSLog(@"%@",symbol);
	}
	
	return ([orgSet allObjects]);
}

@end



@implementation NSMutableArray (Additions)
//+ (instancetype)arrayWithIntersectArray:(NSArray *)array {
//	
//}
//
//+ (instancetype)arrayWithUnionArray:(NSArray *)array {
//	
//}


//- (instancetype)initWithIntersectArray:(NSArray *)array {
//	
//}
//
//- (instancetype)initWithUnionArray:(NSArray *)array {
//	
//}


- (void)intersectArray:(NSArray *)otherArray {
	[[self arrayWithIntersectArray:otherArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if (![self containsObject:obj])
			[self removeObject:obj];
	}];
}

- (void)unionArray:(NSArray *)otherArray {
	[self addObjectsFromArray:[self arrayWithUnionArray:otherArray]];
}

@end