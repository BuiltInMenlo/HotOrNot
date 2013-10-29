//
//  NSArray+NullReplacement.m
//  HotOrNot
//
//  Created by Matt Holcombe on 10/28/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "NSArray+NullReplacement.h"
#import "NSDictionary+NullReplacement.h"

@implementation NSArray (NullReplacement)

- (NSArray *)arrayByReplacingNullsWithBlanks {
	NSMutableArray *replaced = [self mutableCopy];
	
	for (int i=0; i<[replaced count]; i++) {
		id obj = [replaced objectAtIndex:i];
		
		if (obj == [NSNull null]) [replaced replaceObjectAtIndex:i withObject:@""];
		else if ([obj isKindOfClass:[NSDictionary class]]) [replaced replaceObjectAtIndex:i withObject:[obj dictionaryByReplacingNullsWithBlanks]];
		else if ([obj isKindOfClass:[NSArray class]]) [replaced replaceObjectAtIndex:i withObject:[obj arrayByReplacingNullsWithBlanks]];
	}
	
	return ([replaced copy]);
}

@end
