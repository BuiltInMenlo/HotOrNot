//
//  NSArray+Randomize.m
//  HotOrNot
//
//  Created by BIM  on 8/13/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSArray+Randomize.h"

@implementation NSArray (Randomize)

- (NSArray *)scrambleElements {
	
	int tot = [self count];
	id tmpElement;
	
	NSMutableArray *rndArray = [self mutableCopy];
	
	for (int i=tot-1; i>=0; i--) {
		int rndIndex = arc4random() % tot;
		tmpElement = [rndArray objectAtIndex:i];
		
		[rndArray insertObject:[rndArray objectAtIndex:rndIndex] atIndex:i];
		
		 
	}
}

@end
