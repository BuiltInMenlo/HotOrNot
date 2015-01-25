//
//  NSDictionary+Replacements.h
//  HotOrNot
//
//  Created by BIM  on 10/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

@interface NSDictionary (KeyPath)
- (id)objectForKeyPathArray:(NSArray *)keyPathArray;
- (id)objectForKeyPath:(NSString *)keyPath;
@end

@interface NSDictionary (Replacements)
- (id)defaultValue:(id)object forKey:(NSString *)key;
- (BOOL)hasObjectForKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;
- (void)replaceObject:(id)object forKey:(NSString *)key;
- (void)swapObjectForKey:(NSString *)keyA withKey:(NSString *)keyB;
@end



@interface NSMutableDictionary (KeyPath)
- (void)setObject:(id)value forKeyPath:(NSString *)keyPath;
- (void)setObject:(id)value forKeyPathArray:(NSArray *)keyPathArray;
@end

@interface NSMutableDictionary (BuiltInMenlo)
- (id)defaultValue:(id)object forKey:(NSString *)key;
- (BOOL)hasObjectForKey:(NSString *)key;
- (id)objectForKeyPath:(NSString *)keyPath;
- (id)objectForKeyPathArray:(NSArray *)keyPathArray;
- (void)removeObjectForKey:(NSString *)key;
- (void)replaceObject:(id)object forKey:(NSString *)key;
- (void)swapObjectForKey:(NSString *)keyA withObjectForKey:(NSString *)keyB;
- (void)addObjects:(NSArray *)objects withKeys:(NSArray *)keys;
- (void)purgeObjectsWithKeys:(NSArray *)keys;
- (void)replaceObjects:(NSArray *)objects withKeys:(NSArray *)keys;
@end


@interface NSUserDefaults (KeyPath)
- (void)setObject:(id)value forKeyPath:(NSString *)keyPath;
- (void)setObject:(id)value forKeyPathArray:(NSArray *)keyPathArray;
@end

@interface NSUserDefaults (BuiltInMenlo)
- (id)defaultValue:(id)object forKey:(NSString *)key;
- (BOOL)hasObjectForKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;
- (void)replaceObject:(id)object forKey:(NSString *)key;
- (void)swapObjectForKey:(NSString *)keyA withObjectForKey:(NSString *)keyB;
- (void)addObjects:(NSArray *)objects withKeys:(NSArray *)keys;
- (void)purgeObjectsWithKeys:(NSArray *)keys;
- (void)replaceObjects:(NSArray *)objects withKeys:(NSArray *)keys;
@end

//
//  NSDictionary+Replacements.m
//  HotOrNot
//
//  Created by BIM  on 10/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDictionary+Replacements.h"

@implementation NSDictionary (KeyPath)
@end

@implementation NSDictionary (Replacements)

- (id)defaultValue:(id)object forKey:(NSString *)key {
	if (![self hasObjectForKey:key])
		[self setValue:object forKey:key];
	
	return ([self objectForKey:key]);
}

- (BOOL)hasObjectForKey:(NSString *)key {
	return ([self objectForKey:key] != nil);
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

- (void)swapObjectForKey:(NSString *)keyA withKey:(NSString *)keyB {
	id obj = [self objectForKey:keyA];
	[self replaceObject:[self objectForKey:keyB] forKey:keyA];
	[self replaceObject:[self objectForKey:obj] forKey:keyB];
	
	obj = nil;
}

- (id)objectForKeyPathArray:(NSArray *)keyPathArray {
	NSUInteger i, j, n = [keyPathArray count], m;
	
	id currentContainer = self;
	
	for (i=0; i<n; i++) {
		NSString *currentPathItem = [keyPathArray objectAtIndex:i];
		NSArray *indices = [currentPathItem componentsSeparatedByString:@"["];
		m = [indices count];
		
		if (m == 1) // no [ -> object is a dict or a leave
			currentContainer = [currentContainer objectForKey:currentPathItem];
		
		else {
			// Indices is an array of string "arrayKeyName" "i1]" "i2]" "i3]" // arrayKeyName equals to curPathItem
			if (![currentContainer isKindOfClass:[NSDictionary class]])
				return (nil);
			
			currentPathItem = [currentPathItem substringToIndex:[currentPathItem rangeOfString:@"["].location];
			currentContainer = [currentContainer objectForKey:currentPathItem];
			
			for(j=1; j<m; j++) {
				int index = [[indices objectAtIndex:j] intValue];
				if (![currentContainer isKindOfClass:[NSArray class]])
					return (nil);
				
				if (index >= [currentContainer count])
					return (nil);
				
				currentContainer = [currentContainer objectAtIndex:index];
			}
		}
	}
	
	return (currentContainer);
}

@end



@implementation NSMutableDictionary (KeyPath)
@end

@implementation NSMutableDictionary (BuiltinMenlo)

- (BOOL)hasObjectForKey:(NSString *)key {
	return ([self objectForKey:key] != nil);
}

- (id)defaultValue:(id)object forKey:(NSString *)key {
	if (![self hasObjectForKey:key])
		[self setObject:object forKey:key];
	
	return ([self objectForKey:key]);
}

- (void)removeObjectForKey:(NSString *)key {
	if ([self hasObjectForKey:key]) {
		[self removeObjectForKey:key];
	}
}

- (void)replaceObject:(id)object forKey:(NSString *)key {
	if ([self hasObjectForKey:key])
		[self removeObjectForKey:key];
	
	[self setValue:object forKey:key];
}

- (void)swapObjectForKey:(NSString *)keyA withObjectForKey:(NSString *)keyB {
	id obj = [self objectForKey:keyA];
	[self replaceObject:[self objectForKey:keyB] forKey:keyA];
	[self replaceObject:[self objectForKey:obj] forKey:keyB];
	obj = nil;
}

- (void)addObjects:(NSArray *)objects withKeys:(NSArray *)keys {
	[keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[self setObject:[objects objectAtIndex:idx] forKey:(NSString *)obj];
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


@implementation NSUserDefaults (KeyPath)
@end

@implementation NSUserDefaults (Replacements)
- (BOOL)hasObjectForKeyPath:(NSString *)keyPath {
	NSArray *keyPaths = [keyPath componentsSeparatedByString:@"."];
	NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectDictionary];
	
	return ([dict objectForKeyPathArray:keyPaths]);
}

- (id)defaultValue:(id)object forKey:(NSString *)key {
	if ([self objectForKey:key] == nil)
		[self setObject:object forKey:key];
	
	return ([self objectForKey:key]);
}

- (void)removeObjectForKey:(NSString *)key {
	if ([self objectForKey:key] != nil) {
		[self removeObjectForKey:key];
	}
}

- (void)replaceObject:(id)object forKey:(NSString *)key {
	if ([self hasObjectForKey:key])
		[self removeObjectForKey:key];
	
	[self setValue:object forKey:key];
}

- (void)swapObjectForKey:(NSString *)keyA withObjectForKey:(NSString *)keyB {
	id obj = [self objectForKey:keyA];
	[self replaceObject:[self objectForKey:keyB] forKey:keyA];
	[self replaceObject:[self objectForKey:obj] forKey:keyB];
	obj = nil;
}

- (void)addObjects:(NSArray *)objects withKeys:(NSArray *)keys {
	[keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[self setObject:[objects objectAtIndex:idx] forKey:(NSString *)obj];
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
