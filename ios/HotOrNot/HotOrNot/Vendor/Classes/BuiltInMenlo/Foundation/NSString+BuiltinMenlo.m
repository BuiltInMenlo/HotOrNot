//
//  Base64.m
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


#import "NSData+BuiltInMenlo.h"
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

- (BOOL)isValidEmailAddress {
	BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
	
	return ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", (stricterFilter) ? @"^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,4})$" : @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*"]
			 evaluateWithObject:self]);
}

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
