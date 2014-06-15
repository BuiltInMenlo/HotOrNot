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
- (NSString *)elapsedTimeSinceDate:(NSDate *)date;
- (NSString *)intervalSinceDate:(NSDate *)date;
- (NSString *)intervalSinceDate:(NSDate *)date minSeconds:(int)minSeconds includeSuffix:(NSString *)suffix;
- (NSDateFormatter *)orthodoxBaseFormatter;
- (NSString *)orthodoxFormattedStringFromDate:(NSDate *)date;
- (NSDateFormatter *)orthodoxFormatterWithTimezone:(NSString *)timezone;
- (NSString *)timezoneFromDeviceLocale;
- (int)yearsOldFromDate:(NSDate *)date;
@end
