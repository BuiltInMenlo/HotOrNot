//
//  NSUserDefaults+NullReplacement.m
//  HotOrNot
//
//  Created by BIM  on 10/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSUserDefaults+Replacements.h"

@implementation NSUserDefaults (Replacements)

- (void)defineObject:(id)object UnknownKey:(NSString *)key {
	if ([self objectForKey:key] == nil)
		[self setObject:object forNonExistingKey:key];

	else
		[self replaceObject:object forExistingKey:key];
}

- (void)removeObjectForExistingKey:(NSString *)key {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:key] != nil) {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void)replaceObject:(id)object forExistingKey:(NSString *)key {
	[self removeObjectForExistingKey:key];
	[self setValue:object forKey:key];
}

- (void)setObject:(id)object forNonExistingKey:(NSString *)key {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:key] == nil) {
		[[NSUserDefaults standardUserDefaults] setValue:object forKey:key];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void)swapObjectForKey:(NSString *)keyA withKey:(NSString *)keyB {
	id obj = [self objectForKey:keyA];
	[self replaceObject:[self objectForKey:keyB] forExistingKey:keyA];
	[self replaceObject:[self objectForKey:obj] forExistingKey:keyB];
	
	obj = nil;
}

@end
