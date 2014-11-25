//
//  NSCharacterSet+AdditionalSets.m
//  HotOrNot
//
//  Created by BIM  on 11/24/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSCharacterSet+AdditionalSets.h"

@implementation NSCharacterSet (AdditionalSets)

+ (instancetype) invalidCharacterSet {
	return ([NSCharacterSet characterSetWithCharactersInString:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"invalid_chars"] componentsJoinedByString:@""] stringByAppendingString:@"\\"]]);
}

+ (instancetype) invalidCharacterSetWithLetters {
	NSMutableCharacterSet *charSet = [[NSCharacterSet invalidCharacterSet] mutableCopy];
	[charSet formUnionWithCharacterSet:[NSCharacterSet letterCharacterSet]];
	
	return ([charSet copy]);
}

+ (instancetype) invalidCharacterSetWithNumbers {
	NSMutableCharacterSet *charSet = [[NSCharacterSet invalidCharacterSet] mutableCopy];
	[charSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
	
	return ([charSet copy]);
}

+ (instancetype) invalidCharacterSetWithPunctuation {
	NSMutableCharacterSet *charSet = [[NSCharacterSet invalidCharacterSet] mutableCopy];
	[charSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
	
	return ([charSet copy]);
}


@end
