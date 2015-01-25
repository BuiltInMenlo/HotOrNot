//
//  Base64.h
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
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//


@interface NSString (Base64)
+ (NSString *)stringWithBase64EncodedString:(NSString *)string;
- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)base64EncodedString;
- (NSString *)base64DecodedString;
- (NSData *)base64DecodedData;
@end
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

#import "NSString+Base64.h"


#pragma GCC diagnostic ignored "-Wselector"


#import <Availability.h>
#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif


@implementation NSData (Base64)

+ (NSData *)dataWithBase64EncodedString:(NSString *)string
{
	if (![string length]) return nil;
	
	NSData *decoded = nil;
	
#if __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_9 || __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
	
	if (![NSData instancesRespondToSelector:@selector(initWithBase64EncodedString:options:)])
	{
		decoded = [[self alloc] initWithBase64Encoding:[string stringByReplacingOccurrencesOfString:@"[^A-Za-z0-9+/=]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [string length])]];
	}
	else
	
#endif
		
	{
		decoded = [[self alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
	}
	
	return [decoded length]? decoded: nil;
}

- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth
{
	if (![self length]) return nil;
	
	NSString *encoded = nil;
	
//#if __MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_9 || __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
//	
//	if (![NSData instancesRespondToSelector:@selector(base64EncodedStringWithOptions:)])
//	{
//		encoded = [self base64Encoding];
//	}
//	else
//	
//#endif
	
	{
		switch (wrapWidth)
		{
			case 64:
			{
				return [self base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
			}
			case 76:
			{
				return [self base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength];
			}
			default:
			{
				encoded = [self base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
			}
		}
	}
	
	if (!wrapWidth || wrapWidth >= [encoded length])
	{
		return encoded;
	}
	
	wrapWidth = (wrapWidth / 4) * 4;
	NSMutableString *result = [NSMutableString string];
	for (NSUInteger i = 0; i < [encoded length]; i+= wrapWidth)
	{
		if (i + wrapWidth >= [encoded length])
		{
			[result appendString:[encoded substringFromIndex:i]];
			break;
		}
		[result appendString:[encoded substringWithRange:NSMakeRange(i, wrapWidth)]];
		[result appendString:@"\r\n"];
	}
	
	return result;
}

- (NSString *)base64EncodedString
{
	return [self base64EncodedStringWithWrapWidth:0];
}

@end


@implementation NSString (Base64)

+ (NSString *)stringWithBase64EncodedString:(NSString *)string
{
	NSData *data = [NSData dataWithBase64EncodedString:string];
	if (data)
	{
		return [[self alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
	return nil;
}

- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth
{
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	return [data base64EncodedStringWithWrapWidth:wrapWidth];
}

- (NSString *)base64EncodedString
{
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	return [data base64EncodedString];
}

- (NSString *)base64DecodedString
{
	return [NSString stringWithBase64EncodedString:self];
}

- (NSData *)base64DecodedData
{
	return [NSData dataWithBase64EncodedString:self];
}

@end
//
//  NSString+Formatting.h
//  HotOrNot
//
//  Created by BIM  on 10/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

@interface NSString (Formatting)
- (BOOL)isValidEmailAddress;
- (NSString *)stringByTrimmingFinalSubstring:(NSString *)substring;
- (void)trimFinalSubstring:(NSString *)substring;
- (NSString *)normalizedPhoneNumber;
- (NSDictionary *)parseAsQueryString;
- (BOOL)isDelimitedByString:(NSString *)delimiter;
- (NSString *)stringFromAPNSToken:(NSData *)remoteToken;
@end
//
//  NSString+Formatting.m
//  HotOrNot
//
//  Created by BIM  on 10/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+Formatting.h"

@implementation NSString (Formatting)

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
//
//  NSString+Random.h
//  HotOrNot
//
//  Created by BIM  on 8/14/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

@interface NSString (Random)
@end
//
//  NSString+Random.m
//  HotOrNot
//
//  Created by BIM  on 8/14/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+Random.h"

@implementation NSString (Random)
@end
