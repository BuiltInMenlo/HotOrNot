//
//  NSString+Formatting.m
//  HotOrNot
//
//  Created by BIM  on 10/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+Formatting.h"

@implementation NSString (Formatting)

- (NSString *)stringByTrimmingFinalSubstring:(NSString *)substring {
//	NSRange range = NSMakeRange([string length] - [substring length], [substring length]);
	return (([self rangeOfString:substring].location != NSNotFound) ? [self substringToIndex:[self length] - [substring length]] : self);
}

- (void)trimFinalSubstring:(NSString *)substring; {
//	NSMutableString *string = [[self stringByTrimmingFinalSubstring:substring] mutableCopy];
//	
//	
//	if (range.location != NSNotFound)
//		[string deleteCharactersInRange:range];
//	
//	NSString *news = [super init];
//	
//	self = [self init];//[@"" stringByTrimmingFinalSubstring:@", "];
}

- (NSString *)normalizedPhoneNumber {
	if ([self length] > 0) {
		NSString *phoneNumber = [[self componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"+().-  "]] componentsJoinedByString:@""];
		if (![[phoneNumber substringToIndex:1] isEqualToString:@"1"])
			phoneNumber = [@"1" stringByAppendingString:phoneNumber];
		
		if (![[phoneNumber substringToIndex:1] isEqualToString:@"+"])
			phoneNumber = [@"+" stringByAppendingString:phoneNumber];
		
		return (phoneNumber);
	}
	
	return ([[self componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"+().-  "]] componentsJoinedByString:@""]);
}

- (NSDictionary *)parseAsQueryString {
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	for (NSString *pair in [self componentsSeparatedByString:@"&"]) {
		NSArray *kv = [pair componentsSeparatedByString:@"="];
		NSString *val = [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		params[kv[0]] = val;
	}
	
	return (params);
}


@end
