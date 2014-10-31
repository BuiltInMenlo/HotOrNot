//
//  HONDateTimeAlloter.h
//  HotOrNot
//
//  Created by Matt Holcombe on 06/14/2014 @ 21:27 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


@interface HONDateTimeAlloter : NSObject
+ (HONDateTimeAlloter *)sharedInstance;

- (NSDate *)dateFromUnixTimestamp:(CGFloat)timestamp;
- (NSDate *)dateFromOrthodoxFormattedString:(NSString *)stringDate;
- (NSDate *)dateFromISO9601FormattedString:(NSString *)stringDate;
- (NSDate *)dateFromISO9601UTCFormattedString:(NSString *)stringDate;
- (BOOL)didDate:(NSDate *)firstDate occurBerforeDate:(NSDate *)lastDate;
- (int)elapsedSecondsSinceUnixEpoch;
- (NSString *)timezoneHourOffsetFromDate:(NSDate *)date;
- (NSString *)elapsedTimeSinceDate:(NSDate *)date;
- (NSString *)intervalSinceDate:(NSDate *)date;
- (NSString *)intervalSinceDate:(NSDate *)date includeSuffix:(NSString *)suffix;
- (NSString *)intervalSinceDate:(NSDate *)date minSeconds:(int)minSeconds usingIndicators:(NSDictionary *)indicators includeSuffix:(NSString *)suffix;
- (BOOL)isPastDate:(NSDate *)date;
- (NSString *)orthodoxBlankTimestampFormattedString;
- (NSDateFormatter *)dateFormatterWithSymbols:(NSString *)symbols;
- (NSDateFormatter *)orthodoxBaseFormatter;
- (NSString *)orthodoxFormattedStringFromDate:(NSDate *)date;
- (NSString *)ISO8601FormattedStringFromDate:(NSDate *)date;
- (NSDateFormatter *)orthodoxFormatterWithTimezone:(NSString *)timezone;
- (NSString *)timezoneFromDeviceLocale;
- (NSString *)ISO8601FormattedStringFromNowDate;
- (NSString *)ISO8601FormattedStringFromUTCDate:(NSDate *)date;
- (NSDate *)utcDateFromDate:(NSDate *)date;
- (NSDate *)utcNowDate;
- (NSString *)utcNowDateFormattedISO8601;
- (NSString *)utcHourOffsetFromDeviceLocale;
- (int)dayOfYearFromDate:(NSDate *)date;
- (int)weekOfYearFromDate:(NSDate *)date;
- (int)yearFromDate:(NSDate *)date;
- (int)yearsOldFromDate:(NSDate *)date;
@end
