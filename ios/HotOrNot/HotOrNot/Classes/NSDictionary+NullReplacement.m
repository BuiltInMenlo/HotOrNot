//
//  NSDictionary+NullReplacement.m
//  HotOrNot
//
//  Created by Matt Holcombe on 10/28/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "NSDictionary+NullReplacement.h"
#import "NSArray+NullReplacement.h"

@implementation NSDictionary (NullReplacement)

- (NSDictionary *)dictionaryByReplacingNullsWithBlanks {
	const NSMutableDictionary *replaced = [NSMutableDictionary dictionaryWithDictionary: self];
	const id nul = [NSNull null];
	const NSString *blank = @"";
	
	for (NSString *key in self) {
		const id object = [self objectForKey:key];
		
		if (object == nul) {
			[replaced setObject: blank forKey:key];
		}
		
		else if ([object isKindOfClass:[NSDictionary class]]) {
			[replaced setObject:[(NSDictionary *) object dictionaryByReplacingNullsWithBlanks] forKey:key];
		}
	}
	
	return [NSDictionary dictionaryWithDictionary:[replaced copy]];
}

@end
