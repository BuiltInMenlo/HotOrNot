//
//  NSDate+Operations.m.h
//  HotOrNot
//
//  Created by BIM  on 11/4/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

@interface NSDateFormatter (Formatting)
+ (NSDateFormatter *)dateFormatterWithTemplate:(NSString *)template;
+ (NSDateFormatter *)dateFormatterISO8601;
+ (NSDateFormatter *)dateFormatterOrthodox:(BOOL)isUTC;
+ (NSDateFormatter *)dateFormatterOrthodoxWithTZ:(NSString *)tzAbbreviation;
@end


@interface NSDate (BuiltInMenlo)

+ (instancetype)blankTimestamp;
+ (instancetype)blankUTCTimestamp;

+ (instancetype)dateFromUnixTimestamp:(CGFloat)timestamp;
+ (instancetype)dateFromISO9601FormattedString:(NSString *)stringDate;
+ (instancetype)dateFromOrthodoxFormattedString:(NSString *)stringDate;
+ (instancetype)dateFromOrthodoxFormattedString:(NSString *)stringDate isUTC:(BOOL)isUTC;
+ (instancetype)dateToUTCDate:(NSDate *)date;
+ (instancetype)utcNowDate;

+ (NSString *)stringFormattedISO8601;
+ (NSString *)utcStringFormattedISO8601;

+ (int)elapsedDaysSinceDate:(NSDate *)date isUTC:(BOOL)isUTC;
+ (int)elapsedHoursSinceDate:(NSDate *)date isUTC:(BOOL)isUTC;
+ (int)elapsedMinutesSinceDate:(NSDate *)date isUTC:(BOOL)isUTC;
+ (int)elapsedSecondsSinceDate:(NSDate *)date isUTC:(BOOL)isUTC;
+ (NSString *)elapsedTimeSinceDate:(NSDate *)date isUTC:(BOOL)isUTC;

+ (int)elapsedUTCSecondsSinceUnixEpoch;

- (BOOL)didDateAlreadyOccur:(NSDate *)date;

- (int)dayOfYear;
- (int)weekOfMonth;
- (int)weekOfYear;
- (int)year;

- (int)unixEpochTimestamp;

- (NSString *)formattedISO8601String;
- (NSString *)formattedISO8601StringUTC;

- (NSString *)utcHourOffsetFromDeviceLocale;
- (NSString *)timezoneFromDeviceLocale;

@end
