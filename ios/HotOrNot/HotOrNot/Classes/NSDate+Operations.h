//
//  NSDate+Operations.m.h
//  HotOrNot
//
//  Created by BIM  on 11/4/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDateFormatter (Formatting)
+ (NSDateFormatter *)dateFormatterISO8601:(BOOL)isUTC;
+ (NSDateFormatter *)dateFormatterWithTemplate:(NSString *)template;
+ (NSDateFormatter *)orthodoxBaseFormatter;
+ (NSDateFormatter *)orthodoxFormatterWithTZ:(NSString *)tzAbbreviation;
+ (NSDateFormatter *)orthodoxUTCDateFormatter;

@end



@interface NSDate (Operations)

+ (instancetype)blankTimestamp;
+ (instancetype)blankUTCTimestamp;

+ (instancetype)dateFromUnixTimestamp:(CGFloat)timestamp;
+ (instancetype)dateFromISO9601FormattedString:(NSString *)stringDate;
+ (instancetype)dateFromISO9601FormattedString:(NSString *)stringDate isUTC:(BOOL)isUTC;
+ (instancetype)dateFromOrthodoxFormattedString:(NSString *)stringDate;
+ (instancetype)dateFromOrthodoxFormattedString:(NSString *)stringDate isUTC:(BOOL)isUTC;
+ (instancetype)utcDateFromDate:(NSDate *)date;
+ (instancetype)utcNowDate;

+ (NSString *)stringFormattedISO8601;
+ (NSString *)utcStringFormattedISO8601;


+ (int)elapsedSecondsSinceDate:(NSDate *)date;
+ (int)elapsedSecondsSinceNow:(BOOL)isUTC;
+ (int)elapsedSecondsSinceUTCDate:(NSDate *)date;
+ (int)elapsedUTCSecondsSinceUnixEpoch;

- (BOOL)didDateAlreadyOccur:(NSDate *)date;

- (int)dayOfYear;
- (int)weekOfMonth;
- (int)weekOfYear;
- (int)year;

- (NSString *)formattedISO8601String;
- (NSString *)formattedISO8601StringUTC;

- (NSString *)utcHourOffsetFromDeviceLocale;
- (NSString *)timezoneFromDeviceLocale;

@end



