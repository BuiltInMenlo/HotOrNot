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
NSString * const kOrthodoxLocaleTemplate	= @"yyyy-MM-dd HH:mm:ssZ";
NSString * const kOrthodoxUTCTemplate		= @"yyyy-MM-dd HH:mm:ss'-0000'";

@implementation NSDateFormatter (Formatting)
static NSDateFormatter *dateFormatterISO8601 = nil;
static NSDateFormatter *orthodoxBaseFormatter = nil;
static NSDateFormatter *dateFormatterOrthodoxTZ = nil;
static NSDateFormatter *dateFormatterOrthodoxUTC = nil;

+ (NSDateFormatter *)dateFormatterISO8601:(BOOL)isUTC {
	static NSDateFormatter *staticInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		staticInstance = [[self alloc] init];
		[staticInstance setDateFormat:(isUTC) ? kISO8601UTCTemplate : kISO860LocaleTemplate];
	});
	
	return (staticInstance);
}

+ (NSDateFormatter *)orthodoxBaseFormatter {
	static NSDateFormatter *staticInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		staticInstance = [[self alloc] init];
		[staticInstance setDateFormat:kOrthodoxTemplate];
	});
	
	return (staticInstance);
}

+ (NSDateFormatter *)orthodoxFormatterWithTZ:(NSString *)tzAbbreviation {
	static NSDateFormatter *staticInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		staticInstance = [NSDateFormatter dateFormatterWithTemplate:([tzAbbreviation isEqualToString:@"UTC"]) ? kOrthodoxUTCTemplate : kOrthodoxTemplate];
		[staticInstance setTimeZone:[NSTimeZone timeZoneWithName:tzAbbreviation]];
	});
	
	return (staticInstance);
}

+ (NSDateFormatter *)orthodoxUTCDateFormatter {
	static NSDateFormatter *staticInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		staticInstance = [NSDateFormatter orthodoxFormatterWithTZ:@"UTC"];
	});
	
	return (staticInstance);
}

+ (NSDateFormatter *)dateFormatterWithTemplate:(NSString *)template {
	static NSDateFormatter *staticInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		staticInstance = [[self alloc] init];
		[staticInstance setDateFormat:template];
	});
	
	return (staticInstance);
}


@end



@implementation NSDate (Operations)

+ (instancetype)blankTimestamp {
	return ([[NSDateFormatter orthodoxUTCDateFormatter] dateFromString:kOrthodoxBlankTimestamp]);
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
	return ([dateFormatterISO8601 dateFromString:stringDate]);
}

+ (instancetype)dateFromOrthodoxFormattedString:(NSString *)stringDate {
	return ([NSDate dateFromOrthodoxFormattedString:stringDate isUTC:YES]);
}

+ (instancetype)dateFromOrthodoxFormattedString:(NSString *)stringDate isUTC:(BOOL)isUTC {
	return ([[NSDateFormatter orthodoxBaseFormatter] dateFromString:stringDate]);
}

+ (instancetype)utcDateFromDate:(NSDate *)date {
	return ([[NSDateFormatter orthodoxFormatterWithTZ:@""] dateFromString:[[NSDateFormatter orthodoxUTCDateFormatter] stringFromDate:date]]);
}

+ (instancetype)utcNowDate {
	return ([NSDate utcDateFromDate:[NSDate date]]);
}

+ (NSString *)stringFormattedISO8601 {
	return ([[NSDate date] formattedISO8601String]);
}

+ (NSString *)utcStringFormattedISO8601 {
	return ([[NSDate utcNowDate] formattedISO8601StringUTC]);
}


+ (int)elapsedSecondsSinceDate:(NSDate *)date {
	return ((int)[[NSDate date] timeIntervalSinceDate:date]);
}

+ (int)elapsedSecondsSinceNow:(BOOL)isUTC {
	return ([NSDate elapsedSecondsSinceDate:(isUTC) ? [NSDate utcNowDate] : [NSDate date]]);
}

+ (int)elapsedSecondsSinceUTCDate:(NSDate *)date {
	return ((int)[[NSDate utcNowDate] timeIntervalSinceDate:date]);
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
