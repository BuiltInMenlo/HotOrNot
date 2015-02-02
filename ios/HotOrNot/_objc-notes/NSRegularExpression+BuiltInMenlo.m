//
//  NSRegularExpression+BuiltInMenlo.m
//  HotOrNot
//
//  Created by BIM  on 1/29/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "NSRegularExpression+BuiltInMenlo.h"

@implementation RxMatch
@synthesize value, range, groups, original;
@end

@implementation RxMatchGroup
@synthesize value, range;
@end



@implementation NSRegularExpression (BuiltInMenlo)

+ (instancetype)rx:(NSString *)pattern {
	return ([[self alloc] initWithPattern:pattern]);
}

+ (instancetype)rx:(NSString *)pattern ignoreCase:(BOOL)ignoreCase {
	return ([[self alloc] initWithPattern:pattern options:ignoreCase?NSRegularExpressionCaseInsensitive:0 error:nil]);
}

+ (instancetype)rx:(NSString *)pattern options:(NSRegularExpressionOptions)options {
	return ([[self alloc] initWithPattern:pattern options:options error:nil]);
}

- (id)initWithPattern:(NSString *)pattern {
	return ([self initWithPattern:pattern options:0 error:nil]);
}

- (NSString *)firstMatch:(NSString *)str {
	
}

- (RxMatch *)firstMatchWithDetails:(NSString *)str {
	
}

- (int)indexOf:(NSString *)str {
	NSRange range = [self rangeOfFirstMatchInString:matchee options:0 range:NSMakeRange(0, str.length)];
	return (range.location == NSNotFound ? -1 : (int)range.location);
}

- (BOOL)isMatch:(NSString *)matchee {
	return ([self numberOfMatchesInString:matchee options:0 range:NSMakeRange(0, matchee.length)] > 0);
}

- (NSArray *)matches:(NSString *)str {
	
}

- (NSArray *)matchesWithDetails:(NSString *)str {
	
}

- (NSString *)replace:(NSString *)string with:(NSString *)replacement {
	return ([self stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:replacement]);
}

- (NSString *)replace:(NSString *)string withBlock:(NSString *(^)(NSString *match))replacer {
	//no replacer? just return
	if (!replacer)
		return string;
	
	//copy the string so we can replace subsections
	NSMutableString *result = [string mutableCopy];
	
	//get matches
	NSArray *matches = [self matchesInString:string options:0 range:NSMakeRange(0, string.length)];
	
	//replace each match (right to left so indexing doesn't get messed up)
	for (int i=(int)matches.count-1; i>=0; i--) {
		NSTextCheckingResult *match = matches[i];
		NSString *matchStr = [string substringWithRange:match.range];
		NSString *replacement = replacer(matchStr);
		[result replaceCharactersInRange:match.range withString:replacement];
	}
	
	return (result);
}

- (NSString *)replace:(NSString *)string withDetailsBlock:(NSString *(^)(RxMatch *match))replacer {
	//no replacer? just return
	if (!replacer) return string;
	
	//copy the string so we can replace subsections
	NSMutableString *replaced = [string mutableCopy];
	
	//get matches
	NSArray *matches = [self matchesInString:string options:0 range:NSMakeRange(0, string.length)];
	
	//replace each match (right to left so indexing doesn't get messed up)
	for (int i=(int)matches.count-1; i>=0; i--) {
		NSTextCheckingResult *result = matches[i];
		RxMatch *match = [self resultToMatch:result original:string];
		NSString *replacement = replacer(match);
		[replaced replaceCharactersInRange:result.range withString:replacement];
	}
	
	return replaced;
}

- (RxMatch *)resultToMatch:(NSTextCheckingResult*)result original:(NSString*)original {
	RxMatch *match = [[RxMatch alloc] init];
	match.original = original;
	match.range = result.range;
	match.value = result.range.length ? [original substringWithRange:result.range] : nil;
	
	//groups
	NSMutableArray *groups = [NSMutableArray array];
	match.groups = groups;
	
	for (int i=0; i<result.numberOfRanges; i++){
		RxMatchGroup *group = [[RxMatchGroup alloc] init];
		group.range = [result rangeAtIndex:i];
		group.value = group.range.length ? [original substringWithRange:group.range] : nil;
		[groups addObject:group];
	}
	
	return (match);
}

- (NSArray *)split:(NSString *)str {
	NSRange range = NSMakeRange(0, str.length);
	
	//get locations of matches
	NSMutableArray *matchingRanges = [NSMutableArray array];
	NSArray *matches = [self matchesInString:str options:0 range:range];
	for (NSTextCheckingResult *match in matches)
		[matchingRanges addObject:[NSValue valueWithRange:match.range]];
	
	//invert ranges - get ranges of non-matched pieces
	NSMutableArray* pieceRanges = [NSMutableArray array];
	
	//add first range
	[pieceRanges addObject:[NSValue valueWithRange:NSMakeRange(0, (matchingRanges.count == 0 ? str.length : [matchingRanges[0] rangeValue].location))]];
	
	//add between splits ranges and last range
	for (int i=0; i<matchingRanges.count; i++){
		BOOL isLast = i+1 == matchingRanges.count;
		unsigned long startLoc = [matchingRanges[i] rangeValue].location + [matchingRanges[i] rangeValue].length;
		unsigned long endLoc = isLast ? str.length : [matchingRanges[i+1] rangeValue].location;
		[pieceRanges addObject:[NSValue valueWithRange:NSMakeRange(startLoc, endLoc-startLoc)]];
	}
	
	//use split ranges to select pieces
	NSMutableArray *pieces = [NSMutableArray array];
	for(NSValue *val in pieceRanges) {
		NSRange range = [val rangeValue];
		NSString *piece = [str substringWithRange:range];
		[pieces addObject:piece];
	}
	
	return (pieces);
}

@end


