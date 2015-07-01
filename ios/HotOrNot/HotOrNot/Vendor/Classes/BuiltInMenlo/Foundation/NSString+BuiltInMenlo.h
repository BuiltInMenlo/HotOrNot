//
//  NSString+BuiltInMenlo.h
//  HotOrNot
//
//  Created by BIM  on 11/4/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.


#import "RegExCategories.h"

@interface NSString (BuiltInMenlo)
+ (NSString *)stringWithBase64EncodedString:(NSString *)string;
- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)base64EncodedString;
- (NSString *)base64DecodedString;
- (NSString *)jsonEncodedString:(NSDictionary *)dictionary;
- (NSData *)base64DecodedData;

- (NSString *)stringWithInt:(int)integer;
+ (id)initWithInteger:(int)integer;
+ (instancetype)stringWithRandomizedCharactersLength:(NSUInteger)length;

- (NSString *)firstComponentByDelimeter:(NSString *)delimiter;
- (NSInteger)indexOfFirstOccurrenceOfSubstring:(NSString *)substring;
- (NSInteger)indexOfLastOccurrenceOfSubstring:(NSString *)substring;
- (BOOL)isCircumfixedByString:(NSString *)affix;
- (BOOL)isPrefixedByString:(NSString *)affix;
- (BOOL)isPrefixedOrSuffixedByString:(NSString *)affix;
- (BOOL)isSuffixedByString:(NSString *)affix;

- (BOOL)isDelimitedByString:(NSString *)delimiter;
- (BOOL)isNumeric;
- (BOOL)isValidEmailAddress;
- (NSString *)lastComponentByDelimeter:(NSString *)delimiter;
- (NSString *)normalizedPhoneNumber;
- (NSString *)normalizedISO8601Timestamp;
- (NSUInteger)numberOfWordsInString;
- (NSUInteger)occurancesOfSubstring:(NSString *)substring;
- (NSDictionary *)parseAsQueryString;
- (NSString *)randomizedString;
- (NSString *)reversedString;
- (NSString *)stringByTrimmingFinalSubstring:(NSString *)substring;
- (NSString *)stringFromAPNSToken:(NSData *)remoteToken;
- (void)trimFinalSubstring:(NSString *)substring;
@end
