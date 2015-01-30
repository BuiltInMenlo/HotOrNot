//
//  NSArray+Additions.m
//  HotOrNot
//
//  Created by BIM  on 1/23/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "NSArray+BuiltinMenlo.h"

@implementation NSArray (BuiltInMenlo)


//+ (instancetype)arrayWithIntersectArray:(NSArray *)array {
//	NSMutableArray *intersectArray = [[NSMutableArray arrayWithArray:self];
//	return ([intersectArray intersectArray:array]);
//}
//
//+ (instancetype)arrayWithUnionArray:(NSArray *)array {
//	return ([[NSArray alloc] initWithArray:[self arrayWithUnionArray:array]]);
//}


//- (NSArray *)arrayWithIntersectArray:(NSArray *)otherArray {
//	NSMutableSet *orgSet = [[NSMutableSet alloc] initWithArray:self];
//	NSSet *otherSet = [[NSSet alloc] initWithArray:otherArray];
//	
//	[orgSet intersectSet:otherSet];
//	
//	for (id symbol in orgSet) {
//		NSLog(@"%@", symbol);
//	}
//	
//	return ([orgSet allObjects]);
//}
//
//- (NSArray *)arrayWithUnionArray:(NSArray *)otherArray {
//	NSMutableSet *orgSet = [[NSMutableSet alloc] initWithArray:self];
//	NSSet *otherSet = [[NSSet alloc] initWithArray:otherArray];
//	
//	[orgSet unionSet:otherSet];
//	
//	for (id symbol in orgSet) {
//		NSLog(@"%@",symbol);
//	}
//	
//	return ([orgSet allObjects]);
//}

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

+ (instancetype)arrayRandomizedWithArray:(NSArray *)array {
	return ([NSArray arrayWithArray:[NSMutableArray arrayRandomizedWithArray:array]]);
}

+ (instancetype)arrayRandomizedWithArray:(NSArray *)array withCapacity:(NSUInteger)numItems {
	numItems = MIN(MAX(0, numItems), [array count]);
	return ([[NSArray arrayRandomizedWithArray:array] objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, numItems)]]);
}

- (NSArray *)arrayByRandomizingArray:(NSArray *)array {
	return ([NSArray arrayRandomizedWithArray:array]);
}

- (NSArray *)arrayByRandomizingArray:(NSArray *)array withCapacity:(NSUInteger)numItems {
	return ([NSArray arrayRandomizedWithArray:array withCapacity:numItems]);
}

- (id)randomElement {
	//return ([self objectAtIndex:(arc4random() % [self count])]);
	return ([self objectAtIndex:[[NSNumber numberWithInt:arc4random_uniform((int)[self count])] integerValue]]);
}

- (NSInteger)randomIndex {
	return ([[NSNumber numberWithInt:arc4random_uniform((int)[self count])] integerValue]);
}

@end




@implementation NSMutableArray (BuiltInMenlo)
+ (instancetype)arrayRandomizedWithArray:(NSArray *)array {
	NSMutableArray *rnd = [NSMutableArray arrayWithArray:array];
	[rnd randomize];
	
	return (rnd);
}

+ (instancetype)arrayRandomizedWithArray:(NSArray *)array withCapacity:(NSUInteger)numItems {
	return ([NSMutableArray arrayWithArray:[NSArray arrayRandomizedWithArray:array withCapacity:numItems]]);
}


//- (void)intersectArray:(NSArray *)otherArray {
//	[[self arrayWithIntersectArray:otherArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		if (![self containsObject:obj])
//			[self removeObject:obj];
//	}];
//}
//
//- (void)unionArray:(NSArray *)otherArray {
//	[self addObjectsFromArray:[self arrayWithUnionArray:otherArray]];
//}

- (NSMutableArray *)arrayByRandomizingArray:(NSArray *)array {
	return ([NSMutableArray arrayWithArray:[NSArray arrayRandomizedWithArray:array]]);
}

- (NSMutableArray *)arrayByRandomizingArray:(NSArray *)array withCapacity:(NSUInteger)numItems {
	return ([NSMutableArray arrayWithArray:[NSArray arrayRandomizedWithArray:array withCapacity:numItems]]);
}


- (void)randomize {
	[self enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSInteger rndIndex = [self randomIndex];
		id swap = [self objectAtIndex:rndIndex];
		
		[self replaceObjectAtIndex:rndIndex withObject:[self objectAtIndex:idx]];
		[self replaceObjectAtIndex:idx withObject:swap];
	}];
}

- (id)randomElement {
	return ([self objectAtIndex:[self randomIndex]]);
}

- (NSInteger)randomIndex {
	return ([[NSNumber numberWithInt:arc4random_uniform((int)[self count])] integerValue]);
}

@end
