//
//  NSArray+Random.m
//  HotOrNot
//
//  Created by BIM  on 9/12/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSArray+Random.h"

@implementation NSArray (Random)

- (NSArray *)randomize {
	NSMutableArray *rnd = [NSMutableArray arrayWithCapacity:[self count]];
	
	for (int i=(int)[self count]-1; i>=0; i--) {
		[rnd addObject:[self objectAtIndex:arc4random_uniform(i)]];
	}
	
	return ([[[rnd copy] reverseObjectEnumerator] allObjects]);
}


@end
