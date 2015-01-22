//
//  NSDictionary+Replacements.m
//  HotOrNot
//
//  Created by BIM  on 10/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDictionary+Replacements.h"

@implementation NSMutableDictionary (Replacements)
- (void)defineObject:(id)object forUnknownKey:(NSString *)key {
	if ([self hasObjectForKey:key])
		[self replaceObject:object forKey:key];
	
	else
		[self setObject:object forKey:key];
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

@end
