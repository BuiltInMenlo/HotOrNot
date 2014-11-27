//
//  NSDate+Operations.m
//  HotOrNot
//
//  Created by BIM  on 11/4/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+Operations.h"

NSString * const kISO8601BlankTimestamp		= @"0000-00-00T00:00:00-0000";
NSString * const kOrthodoxBlankTimestamp	= @"0000-00-00 00:00:00";

NSString * const kISO860LocaleTemplate		= @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'";
NSString * const kISO8601UTCTemplate		= @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'-0000'";
NSString * const kOrthodoxTemplate			= @"yyyy-MM-dd HH:mm:ss";

@implementation NSDateFormatter (Formatting)

+ (NSDateFormatter *)dateFormatterISO8601:(BOOL)isUTC {
	NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatterWithTemplate:(isUTC) ? kISO8601UTCTemplate : kISO860LocaleTemplate];
	
	if (isUTC)
		[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	
	return (dateFormatter);
}

+ (NSDateFormatter *)dateFormatterOrthodox:(BOOL)isUTC {
	return ([NSDateFormatter dateFormatterOrthodoxWithTZ:(isUTC) ? @"UTC" : @""]);
}

+ (NSDateFormatter *)dateFormatterOrthodoxWithTZ:(NSString *)tzAbbreviation {
	NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatterWithTemplate:kOrthodoxTemplate];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:tzAbbreviation]];
	
	return (dateFormatter);
}

+ (NSDateFormatter *)dateFormatterWithTemplate:(NSString *)template {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:template];
	
	return (dateFormatter);
}


@end



@implementation NSDate (Operations)

+ (instancetype)blankTimestamp {
	return ([[NSDateFormatter dateFormatterOrthodox:NO] dateFromString:kOrthodoxBlankTimestamp]);
}

+ (instancetype)blankUTCTimestamp {
	return ([[NSDateFormatter dateFormatterISO8601:YES] dateFromString:kISO8601BlankTimestamp]);
}

+ (instancetype)dateFromUnixTimestamp:(CGFloat)timestamp {
	return ([NSDate dateWithTimeIntervalSince1970:timestamp]);
}

+ (instancetype)dateFromISO9601FormattedString:(NSString *)stringDate {
	return ([NSDate dateFromISO9601FormattedString:stringDate isUTC:YES]);
}

+ (instancetype)dateFromISO9601FormattedString:(NSString *)stringDate isUTC:(BOOL)isUTC {
	return ([[NSDateFormatter dateFormatterISO8601:isUTC] dateFromString:stringDate]);
}

+ (instancetype)dateFromOrthodoxFormattedString:(NSString *)stringDate {
	return ([NSDate dateFromOrthodoxFormattedString:stringDate isUTC:YES]);
}

+ (instancetype)dateFromOrthodoxFormattedString:(NSString *)stringDate isUTC:(BOOL)isUTC {
	return ([[NSDateFormatter dateFormatterOrthodox:isUTC] dateFromString:stringDate]);
}

+ (instancetype)dateToUTCDate:(NSDate *)date {
	return ([[NSDateFormatter dateFormatterOrthodoxWithTZ:@""] dateFromString:[[NSDateFormatter dateFormatterOrthodox:NO] stringFromDate:date]]);
}

+ (instancetype)utcNowDate {
	return ([NSDate dateToUTCDate:[NSDate date]]);
}

+ (NSString *)stringFormattedISO8601 {
	return ([[NSDate date] formattedISO8601String]);
}

+ (NSString *)utcStringFormattedISO8601 {
	return ([[NSDate utcNowDate] formattedISO8601StringUTC]);
}

+ (int)elapsedDaysSinceDate:(NSDate *)date isUTC:(BOOL)isUTC {
	return ([NSDate elapsedSecondsSinceDate:date isUTC:isUTC] / 86400);
}

+ (int)elapsedHoursSinceDate:(NSDate *)date isUTC:(BOOL)isUTC {
	return ([NSDate elapsedSecondsSinceDate:date isUTC:isUTC] / 3600);
}

+ (int)elapsedMinutesSinceDate:(NSDate *)date isUTC:(BOOL)isUTC {
	return ([NSDate elapsedSecondsSinceDate:date isUTC:isUTC] / 60);
}

+ (int)elapsedSecondsSinceDate:(NSDate *)date isUTC:(BOOL)isUTC {
	NSDate *nowDate = (isUTC) ? [NSDate utcNowDate] : [NSDate date];
	return ((int)[nowDate timeIntervalSinceDate:date]);
}

+ (NSString *)elapsedTimeSinceDate:(NSDate *)date isUTC:(BOOL)isUTC {
	return ([NSString stringWithFormat:@"%02d:%02d:%02d", [NSDate elapsedHoursSinceDate:date isUTC:isUTC], [NSDate elapsedMinutesSinceDate:date isUTC:isUTC], [NSDate elapsedSecondsSinceDate:date isUTC:isUTC]]);
}

+ (int)elapsedUTCSecondsSinceUnixEpoch {
	return ((int)[[NSDate date] timeIntervalSince1970]);
}

- (BOOL)didDateAlreadyOccur:(NSDate *)date {
	return ([date timeIntervalSinceDate:self] > 0);
}


- (int)dayOfYear {
	return ((int)[[[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:self] day]);
}

- (int)weekOfMonth {
	return ((int)[[[NSCalendar currentCalendar] components:NSCalendarUnitWeekOfMonth fromDate:self] weekOfMonth]);
}

- (int)weekOfYear {
	return ((int)[[[NSCalendar currentCalendar] components:NSCalendarUnitWeekOfYear fromDate:self] weekOfYear]);
}

- (int)year {
	return ((int)[[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self] year]);
}

- (int)unixEpochTimestamp {
	return ([self timeIntervalSince1970]);
}


- (NSString *)formattedISO8601String {
	return ([[NSDateFormatter dateFormatterISO8601:NO] stringFromDate:self]);
}

- (NSString *)formattedISO8601StringUTC {
	return ([[NSDateFormatter dateFormatterISO8601:YES] stringFromDate:self]);
}

- (NSString *)utcHourOffsetFromDeviceLocale {
	return ([[NSDateFormatter dateFormatterWithTemplate:@"Z"] stringFromDate:self]);
}

- (NSString *)timezoneFromDeviceLocale {
	return ([[NSTimeZone systemTimeZone] abbreviation]);
}


@end
