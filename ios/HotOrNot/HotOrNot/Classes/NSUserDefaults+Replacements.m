//
//  NSUserDefaults+NullReplacement.m
//  HotOrNot
//
//  Created by BIM  on 10/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSUserDefaults+Replacements.h"

@implementation NSUserDefaults (Replacements)

- (void)removeObjectForNonNullKey:(NSString *)key {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:key] != nil) {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void)replaceObject:(id)object forNonNullKey:(NSString *)key {
	[self removeObjectForNonNullKey:key];
	[self setValue:object forKey:key];
}

- (void)setObject:(id)object forNullKey:(NSString *)key {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:key] == nil) {
		[[NSUserDefaults standardUserDefaults] setValue:object forKey:key];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void)swapObjectForKey:(NSString *)keyA withKey:(NSString *)keyB {
	id obj = [self objectForKey:keyA];
	[self replaceObject:[self objectForKey:keyB] forNonNullKey:keyA];
	[self replaceObject:[self objectForKey:obj] forNonNullKey:keyB];
	
	obj = nil;
}

@end
