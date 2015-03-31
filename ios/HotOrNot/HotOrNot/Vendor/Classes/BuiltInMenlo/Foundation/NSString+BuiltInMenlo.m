//
//  NSString+BuiltInMenlo.m
//
//  Version 1.2
//
//  Created by Nick Lockwood on 12/01/2012.
//  Copyright (C) 2012 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  http://github.com/nicklockwood/Base64
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an aacknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//


#import "NSArray+BuiltinMenlo.h"
#import "NSCharacterSet+BuiltinMenlo.h"
#import "NSData+BuiltInMenlo.h"
#import "NSDate+BuiltinMenlo.h"
#import "NSString+BuiltinMenlo.h"


#pragma GCC diagnostic ignored "-Wselector"


#import <Availability.h>
#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif



@implementation NSString (BuiltInMenlo)

+ (NSString *)stringWithBase64EncodedString:(NSString *)string
{
	NSData *data = [NSData dataWithData:nil];
	if (data)
	{
		return [[self alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
	return nil;
}

- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth
{
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	return [data base64EncodedStringWithSeparateLines:NO];
}

- (NSString *)base64EncodedString
{
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	return [data base64EncodedStringWithOptions:NSUTF8StringEncoding];
}

- (NSString *)base64DecodedString
{
	return [NSString stringWithBase64EncodedString:self];
}

- (NSData *)base64DecodedData
{
	return [NSData dataFromBase64String:self];
}


- (NSString *)stringWithInt:(int)integer {
	return ([NSString stringWithFormat:@"%d", integer]);
}

+ (id)initWithInteger:(int)integer {
	return ([NSString stringWithFormat:@"%d", integer]);
}



+ (instancetype)stringWithRandomizedCharactersLength:(NSUInteger)length {
	NSMutableCharacterSet *characterSet = [NSMutableCharacterSet uppercaseLetterCharacterSet];
	[characterSet formUnionWithCharacterSet:[NSCharacterSet lowercaseLetterCharacterSet]];
	[characterSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
	
	NSArray *chars = [@"AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz" componentsSeparatedByString:@""];
	NSString *rnd = @"";
	
	for (NSInteger i=0; i<length; i++) {
		NSString *rndChar = [chars randomElement];
		NSLog(@"CHAR:[%@] (%@)\n", rndChar, rnd);
		rnd = [rnd stringByAppendingString:rndChar];
	}
	
	return (rnd);
}


- (NSString *)firstComponentByDelimeter:(NSString *)delimiter {
	return (([self isDelimitedByString:delimiter]) ? [[self componentsSeparatedByString:delimiter] firstObject] : self);
}

- (NSInteger)indexOfFirstOccurrenceOfSubstring:(NSString *)substring {
	NSAssert(substring != nil || self != nil, @"Seems you are trying to pass nil as a parameter");
	NSAssert(![substring isEqualToString:@""], @"Needle should be valid");
	NSAssert(![self isEqualToString:@""], @"Haystack should be valid");
	NSAssert([substring length] <= [self length], @"Needle should be less or equal in compare with haystack");
	
	NSInteger ind = -1;
	NSInteger j = 0;
	
	for (NSInteger i=0; i<[self length]; i++) {
		if ([self characterAtIndex:i] == [substring characterAtIndex:j]) {
			if (j == 0)
				ind = i;
			
			if (j == [substring length] - 1)
				return ind;
			
			j++;
		
		} else if ([self characterAtIndex:i] != [substring characterAtIndex:j] && j > 0) {
			i--;
			j = 0;
			ind = -1;
		}
	}
	
	return (ind);
}

- (NSInteger)indexOfLastOccurrenceOfSubstring:(NSString *)substring {
	NSInteger firstIndex = [[self reversedString] indexOfFirstOccurrenceOfSubstring:[substring reversedString]];
	NSInteger ind = 0;
	
	if (firstIndex >= 0)
		ind = [self length] - [substring length] - firstIndex;
		
	else
		ind = -1;
	
	
	return (ind);
}

- (BOOL)isCircumfixedByString:(NSString *)affix {
	return ([[self stringByAppendingString:self] containsString:affix]);
}

- (BOOL)isNumeric {
	NSString *normalized = self;//[self stringByReplacingOccurrencesOfString:@"." withString:@""];
	return (([normalized integerValue] > 0 || [normalized isEqualToString:@"0"]));
}
- (BOOL)isPrefixedByString:(NSString *)affix {
	//NSLog(@"PREFIX:[%@]", [self substringToIndex:[affix length]]);
	return (([self length] >= [affix length]) ? [[self substringToIndex:[affix length]] isEqualToString:affix] : NO);
}

- (BOOL)isPrefixedOrSuffixedByString:(NSString *)affix {
	return ([self isPrefixedByString:affix] || [self isSuffixedByString:affix]);
}

- (BOOL)isSuffixedByString:(NSString *)affix {
	//NSLog(@"SUFFIX:[%@]", [self substringFromIndex:([self length] - [affix length])]);
	return (([self length] >= [affix length]) ? [[self substringFromIndex:([self length] - [affix length])] isEqualToString:affix] : NO);
}

- (BOOL)isValidEmailAddress {
	BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
	
	return ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", (stricterFilter) ? @"^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,4})$" : @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*"]
			 evaluateWithObject:self]);
}

- (NSString *)lastComponentByDelimeter:(NSString *)delimiter {
	return (([self isDelimitedByString:delimiter]) ? [[self componentsSeparatedByString:delimiter] lastObject] : self);
}

- (NSString *)randomizedString {
	return ([[NSArray arrayRandomizedWithArray:[self componentsSeparatedByString:@""]] componentsJoinedByString:@""]);
}

- (NSString *)stringByTrimmingFinalSubstring:(NSString *)substring {
	return (([self rangeOfString:substring].location != NSNotFound) ? [self substringToIndex:[self length] - [substring length]] : self);
}

- (void)trimFinalSubstring:(NSString *)substring; {
//	NSMutableString *string = [[self stringByTrimmingFinalSubstring:substring] mutableCopy];
//	
//	
//	if (range.location != NSNotFound)
//		[string deleteCharactersInRange:range];
//
//	
//	self = [self init];//[@"" stringByTrimmingFinalSubstring:@", "];
}

- (NSString *)normalizedISO8601Timestamp {
	return ([[NSDate dateFromOrthodoxFormattedString:self] formattedISO8601String]);
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

- (NSUInteger)numberOfWordsInString {
	const char *str = [self UTF8String];
	BOOL state = NO;
	NSUInteger cnt = 0;
	
	while (*str) {
		if (*str == ' ' || *str == '\n' || *str == '\t')
			state = NO;
			
		else if (state == NO) {
			state = YES;
			++cnt;
		}
		
		++str;
	}
	
	return (cnt);
}

- (NSUInteger)occurancesOfSubstring:(NSString *)substring {
	NSUInteger cnt = 0;
	NSUInteger len = [self length];
	NSRange range = NSMakeRange(0, len);
	
	while (range.location != NSNotFound) {
		range = [self rangeOfString:substring options:0 range:range];
		if (range.location != NSNotFound) {
			range = NSMakeRange(range.location + range.length, len - (range.location + range.length));
			cnt++;
		}
	}
	
	return (cnt);
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

- (NSString *)reversedString {
	NSMutableString *result = [[NSMutableString alloc] init];
	for (NSInteger i=[self length]-1; i>=0; i--)
		[result appendString:[NSString stringWithFormat:@"%C", [self characterAtIndex:i]]];
	
	return ([result copy]);
}


- (BOOL)isDelimitedByString:(NSString *)delimiter {
	return ([[self componentsSeparatedByString:delimiter] count] > 0);
}

- (NSString *)stringFromAPNSToken:(NSData *)remoteToken {
	NSString *pushToken = [[remoteToken description] substringFromIndex:1];
	pushToken = [pushToken substringToIndex:[pushToken length] - 1];
	pushToken = [pushToken stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	return (pushToken);
}


@end
