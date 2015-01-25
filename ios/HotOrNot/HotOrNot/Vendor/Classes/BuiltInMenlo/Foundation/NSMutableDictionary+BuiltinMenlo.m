//
//  NSMutableDictionary+Replacements.h
//  HotOrNot
//
//  Created by BIM  on 10/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

//
//  NSMutableDictionary+Replacements.m
//  HotOrNot
//
//  Created by BIM  on 10/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSMutableDictionary+Replacements.h"

@implementation NSMutableDictionary (Replacements)

- (BOOL)hasObjectForKey:(NSString *)key {
	return ([self objectForKey:key] != nil);
}

- (void)defineObject:(id)object forKey:(NSString *)key {
	if ([self objectForKey:key] == nil)
		[self setObject:object forNonExistingKey:key];
	
	else
		[self replaceObject:object forKey:key];
}

- (void)removeObjectForKey:(NSString *)key {
	if ([self objectForKey:key] != nil) {
		[self removeObjectForKey:key];
	}
}

- (void)replaceObject:(id)object forKey:(NSString *)key {
	if ([self objectForKey:key] != nil)
		[self removeObjectForKey:key];
	
	[self setValue:object forKey:key];
}

- (void)setObject:(id)object forNonExistingKey:(NSString *)key {
	if ([self objectForKey:key] == nil) {
		[self setValue:object forKey:key];
	}
}

- (void)swapObjectForKey:(NSString *)keyA withKey:(NSString *)keyB {
	id obj = [self objectForKey:keyA];
	[self replaceObject:[self objectForKey:keyB] forKey:keyA];
	[self replaceObject:[self objectForKey:obj] forKey:keyB];
	obj = nil;
}

- (void)addObjects:(NSArray *)objects withKeys:(NSArray *)keys {
	[keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[self defineObject:[objects objectAtIndex:idx] forKey:(NSString *)obj];
	}];
}

- (void)purgeObjectsWithKeys:(NSArray *)keys {
	[keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[self removeObjectForKey:(NSString *)obj];
	}];
}

- (void)replaceObjects:(NSArray *)objects withKeys:(NSArray *)keys {
	[keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[self replaceObject:[objects objectAtIndex:idx] forKey:(NSString *)obj];
	}];
}

@end
