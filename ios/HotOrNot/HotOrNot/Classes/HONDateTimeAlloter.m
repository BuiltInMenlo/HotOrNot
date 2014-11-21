//
//  HONDateTimeAlloter.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/14/2014 @ 21:27 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONDateTimeAlloter.h"

NSString * const kISO8601LocaleFormatSymbols = @"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ";
NSString * const kISO8601UTCFormatSymbols = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'-0000'";
NSString * const kOrthodoxFormatSymbols = @"yyyy-MM-dd HH:mm:ss";
NSString * const kISO8601BlankTime = @"0000-00-00 00:00:00-0000";
NSString * const kOrthodoxBlankTime = @"0000-00-00 00:00:00";

@implementation HONDateTimeAlloter
static HONDateTimeAlloter *sharedInstance = nil;

+ (HONDateTimeAlloter *)sharedInstance {
	static HONDateTimeAlloter *s_sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		s_sharedInstance = [[self alloc] init];
	});
	
	return (s_sharedInstance);
}

- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}


- (NSDate *)dateFromUnixTimestamp:(CGFloat)timestamp {
	return ([NSDate dateWithTimeIntervalSince1970:timestamp]);
}

- (NSDate *)dateFromISO9601FormattedString:(NSString *)stringDate {
	return ([[[HONDateTimeAlloter sharedInstance] dateFormatterWithSymbols:kISO8601LocaleFormatSymbols] dateFromString:stringDate]);
}

- (NSDate *)dateFromISO9601UTCFormattedString:(NSString *)stringDate {
	return ([[[HONDateTimeAlloter sharedInstance] dateFormatterWithSymbols:kISO8601UTCFormatSymbols] dateFromString:stringDate]);
}

- (NSDate *)dateFromOrthodoxFormattedString:(NSString *)stringDate {
	return ([[[HONDateTimeAlloter sharedInstance] orthodoxBaseFormatter] dateFromString:stringDate]);
}

- (BOOL)didDate:(NSDate *)firstDate occurBerforeDate:(NSDate *)lastDate {
	return ([lastDate timeIntervalSinceDate:firstDate] > 0);
}

- (NSString *)timezoneHourOffsetFromDate:(NSDate *)date {
	return ([[[HONDateTimeAlloter sharedInstance] dateFormatterWithSymbols:@"Z"] stringFromDate:date]);
}

- (NSString *)elapsedTimeSinceDate:(NSDate *)date {
	int secs = [[[NSDate date] dateByAddingTimeInterval:0] timeIntervalSinceDate:date];
	int mins = secs / 60;
	int hours = mins / 60;
	
	secs -= (mins * 60);
	mins -= (hours * 60);
	
	return ([NSString stringWithFormat:@"%02d:%02d:%02d", MAX(0, hours), MAX(0, mins), MAX(0, secs)]);
}

- (int)elapsedSecondsSinceUnixEpoch {
	return ((int)[[NSDate date] timeIntervalSince1970]);
}

- (NSString *)intervalSinceDate:(NSDate *)date {
	return ([[HONDateTimeAlloter sharedInstance] intervalSinceDate:date minSeconds:0 usingIndicators:@{@"seconds"	: @[@"s", @""],
																									   @"minutes"	: @[@"m", @""],
																									   @"hours"		: @[@"h", @""],
																									   @"days"		: @[@"d", @""]} includeSuffix:@""]);
}

- (NSString *)intervalSinceDate:(NSDate *)date includeSuffix:(NSString *)suffix {
	return ([[HONDateTimeAlloter sharedInstance] intervalSinceDate:date minSeconds:0 usingIndicators:@{@"seconds"	: @[@"s", @""],
																									   @"minutes"	: @[@"m", @""],
																									   @"hours"		: @[@"h", @""],
																									   @"days"		: @[@"d", @""]} includeSuffix:suffix]);
}

- (NSString *)intervalSinceDate:(NSDate *)date minSeconds:(int)minSeconds usingIndicators:(NSDictionary *)indicators includeSuffix:(NSString *)suffix {
	NSString *interval = [[@"0 " stringByAppendingString:[[indicators objectForKey:@"seconds"] objectAtIndex:0]] stringByAppendingString:[[indicators objectForKey:@"seconds"] objectAtIndex:1]];
	
	NSDateFormatter *utcFormatter = [[HONDateTimeAlloter sharedInstance] orthodoxUTCDateFormatter];
	
	int secs = MAX(0, [[[[[HONDateTimeAlloter sharedInstance] orthodoxBaseFormatter] dateFromString:[utcFormatter stringFromDate:[NSDate date]]] dateByAddingTimeInterval:0] timeIntervalSinceDate:date]);
	int mins = secs / 60;
	int hours = mins / 60;
	int days = hours / 24;
	
//	NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear) fromDate:date];
	//NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
	//NSLog(@"[%d][%d][%d][%d]", days, hours, mins, secs);
	
	if (days > 0)
		interval = [[[@"" stringFromInt:days] stringByAppendingString:[[indicators objectForKey:@"days"] objectAtIndex:0]] stringByAppendingString:(days != 1) ? [[indicators objectForKey:@"days"] objectAtIndex:1] : @""];
	
	else {
		if (hours > 0)
			interval = [[[@"" stringFromInt:hours] stringByAppendingString:[[indicators objectForKey:@"hours"] objectAtIndex:0]] stringByAppendingString:(hours != 1) ? [[indicators objectForKey:@"hours"] objectAtIndex:1] : @""];
		
		else {
			if (mins > 0)
				interval = [[[@"" stringFromInt:mins] stringByAppendingString:[[indicators objectForKey:@"minutes"] objectAtIndex:0]] stringByAppendingString:(mins != 1) ? [[indicators objectForKey:@"minutes"] objectAtIndex:1] : @""];
			
			else
				interval = [[[@"" stringFromInt:secs] stringByAppendingString:[[indicators objectForKey:@"seconds"] objectAtIndex:0]] stringByAppendingString:(secs != 1) ? [[indicators objectForKey:@"seconds"] objectAtIndex:1] : @""];
		}
	}
	
	interval = (suffix != nil && [suffix length] > 0) ? [interval stringByAppendingString:suffix] : interval;
	return ((secs <= minSeconds) ? @"1s" : interval);
}

- (NSString *)orthodoxBlankTimestampFormattedString {
	return (kOrthodoxBlankTime);
}

- (NSDateFormatter *)dateFormatterWithSymbols:(NSString *)symbols {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:symbols];
	
	return (dateFormatter);
}

- (NSDateFormatter *)orthodoxBaseFormatter {
	return ([[HONDateTimeAlloter sharedInstance] dateFormatterWithSymbols:kOrthodoxFormatSymbols]);
}

- (NSDateFormatter *)orthodoxFormatterWithTimezone:(NSString *)timezone {
	NSString *tzAbbreviation = (timezone == nil) ? [[NSTimeZone localTimeZone] abbreviation] : @"UTC";
	
	BOOL isValid = NO;
	for (NSString *tzKey in [NSTimeZone abbreviationDictionary]) {
		if ([tzKey isEqualToString:[timezone uppercaseString]]) {
			tzAbbreviation = tzKey;
			isValid = YES;
			break;
		}
		
		if ([[[NSTimeZone abbreviationDictionary] objectForKey:tzKey] isEqualToString:timezone]) {
			isValid = YES;
			tzAbbreviation = tzKey;
			break;
		}
	}
	
	NSDateFormatter *dateFormatter = [[HONDateTimeAlloter sharedInstance] orthodoxBaseFormatter];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:(isValid) ? tzAbbreviation : @"UTC"]];
	return (dateFormatter);
}

- (NSDateFormatter *)orthodoxUTCDateFormatter {
	return ([[HONDateTimeAlloter sharedInstance] orthodoxFormatterWithTimezone:@"UTC"]);
}

- (NSString *)orthodoxFormattedStringFromDate:(NSDate *)date; {
	if (date == nil)
		date = [NSDate date];
	
	return ([[[HONDateTimeAlloter sharedInstance] orthodoxBaseFormatter] stringFromDate:date]);
}

- (NSString *)timezoneFromDeviceLocale {
	return ([[NSTimeZone systemTimeZone] abbreviation]);
}

- (NSString *)ISO8601FormattedStringFromNowDate {
	return ([[HONDateTimeAlloter sharedInstance] ISO8601FormattedStringFromDate:[NSDate date]]);
}

- (NSString *)ISO8601FormattedStringFromUTCDate:(NSDate *)date {
	return ([[[HONDateTimeAlloter sharedInstance] dateFormatterWithSymbols:kISO8601UTCFormatSymbols] stringFromDate:date]);
}

- (NSDate *)utcDateFromDate:(NSDate *)date {
	return ([[[HONDateTimeAlloter sharedInstance] orthodoxBaseFormatter] dateFromString:[[[HONDateTimeAlloter sharedInstance] orthodoxUTCDateFormatter] stringFromDate:date]]);
}

- (NSDate *)utcNowDate {
	return ([[HONDateTimeAlloter sharedInstance] utcDateFromDate:[NSDate date]]);
}

- (NSString *)utcNowDateFormattedISO8601 {
	return ([[[HONDateTimeAlloter sharedInstance] dateFormatterWithSymbols:kISO8601UTCFormatSymbols] stringFromDate:[[HONDateTimeAlloter sharedInstance] utcNowDate]]);
}

- (NSString *)ISO8601FormattedStringFromDate:(NSDate *)date {
	return ([[[HONDateTimeAlloter sharedInstance] dateFormatterWithSymbols:kISO8601LocaleFormatSymbols] stringFromDate:date]);
}

- (NSString *)utcHourOffsetFromDeviceLocale {
	return ([[HONDateTimeAlloter sharedInstance] timezoneHourOffsetFromDate:[NSDate date]]);
}

- (int)dayOfYearFromDate:(NSDate *)date {
	return ((int)[[[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:date] day]);
}

- (int)yearFromDate:(NSDate *)date {
	return ((int)[[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:date] year]);
}

- (int)weekOfYearFromDate:(NSDate *)date {
	return ((int)[[[NSCalendar currentCalendar] components:NSCalendarUnitWeekOfYear fromDate:date] weekOfYear]);
}

- (int)yearsOldFromDate:(NSDate *)date {
	return ([date timeIntervalSinceNow] / 31536000);
}

@end
