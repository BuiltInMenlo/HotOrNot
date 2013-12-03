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
	const NSMutableDictionary *replaced = [self mutableCopy];
	
	for (NSString *key in self) {
		id obj = [self objectForKey:key];
		
		if (obj == [NSNull null]) [replaced setObject:@"" forKey:key];
		else if ([obj isKindOfClass:[NSDictionary class]]) [replaced setObject:[obj dictionaryByReplacingNullsWithBlanks] forKey:key];
		else if ([obj isKindOfClass:[NSArray class]]) [replaced setObject:[obj arrayByReplacingNullsWithBlanks] forKey:key];
	}
	
	return ([NSDictionary dictionaryWithDictionary:[replaced copy]]);
}

@end
