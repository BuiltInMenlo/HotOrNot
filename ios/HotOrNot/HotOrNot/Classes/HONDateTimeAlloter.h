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
- (BOOL)didDate:(NSDate *)firstDate occurBerforeDate:(NSDate *)lastDate;
- (int)elapsedSecondsSinceUnixEpoch;
- (NSString *)elapsedTimeSinceDate:(NSDate *)date;
- (NSString *)intervalSinceDate:(NSDate *)date;
- (NSString *)intervalSinceDate:(NSDate *)date includeSuffix:(NSString *)suffix;
- (NSString *)intervalSinceDate:(NSDate *)date minSeconds:(int)minSeconds usingIndicators:(NSDictionary *)indicators includeSuffix:(NSString *)suffix;
- (BOOL)isPastDate:(NSDate *)date;
- (NSString *)orthodoxBlankTimestampFormattedString;
- (NSDateFormatter *)orthodoxBaseFormatter;
- (NSString *)orthodoxFormattedStringFromDate:(NSDate *)date;
- (NSDateFormatter *)orthodoxFormatterWithTimezone:(NSString *)timezone;
- (NSString *)timezoneFromDeviceLocale;
- (NSDate *)utcDateFromDate:(NSDate *)date;
- (NSDate *)utcNowDate;
- (int)yearsOldFromDate:(NSDate *)date;
@end
