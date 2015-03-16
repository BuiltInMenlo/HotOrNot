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

- (int)elapsedDaysSincenDate:(NSDate *)date;
+ (int)elapsedDaysFromSeconds:(int)seconds;
- (int)elapsedHoursSinceDate:(NSDate *)date;
+ (int)elapsedHoursFromSeconds:(int)seconds;
- (int)elapsedMinutesSinceDate:(NSDate *)date;
+ (int)elapsedMinutesFromSeconds:(int)seconds;
- (int)elapsedSecondsSinceDate:(NSDate *)date;
- (NSString *)elapsedTimeSinceDate:(NSDate *)date;


- (int)unixEpochTimestamp;

- (NSString *)formattedISO8601String;

- (NSString *)utcHourOffsetFromDeviceLocale;
- (NSString *)timezoneFromDeviceLocale;

@end
