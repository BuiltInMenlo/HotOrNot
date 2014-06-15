//
//  HONDateTimeAlloter.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/14/2014 @ 21:27 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONDateTimeAlloter.h"

NSString * const kOrthodoxFormatSymbols = @"yyyy-MM-dd HH:mm:ss";

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

- (NSDate *)dateFromOrthodoxFormattedString:(NSString *)stringDate {
	return ([[[HONDateTimeAlloter sharedInstance] orthodoxBaseFormatter] dateFromString:stringDate]);
}

- (NSString *)elapsedTimeSinceDate:(NSDate *)date {
	int secs = [[[NSDate new] dateByAddingTimeInterval:0] timeIntervalSinceDate:date];
	int mins = secs / 60;
	int hours = mins / 60;
	
	secs -= (mins * 60);
	mins -= (hours * 60);
	
	return ([NSString stringWithFormat:@"%02d:%02d:%02d", MAX(0, hours), MAX(0, mins), MAX(0, secs)]);
}

- (NSString *)intervalSinceDate:(NSDate *)date {
	return ([[HONDateTimeAlloter sharedInstance] intervalSinceDate:date minSeconds:0 includeSuffix:@" ago"]);
}

- (NSString *)intervalSinceDate:(NSDate *)date minSeconds:(int)minSeconds includeSuffix:(NSString *)suffix {
	NSString *interval = @"0 secs";
	
	NSDateFormatter *utcFormatter = [[HONDateTimeAlloter sharedInstance] orthodoxUTCDateFormatter];
	NSDateFormatter *dateFormatter = [[HONDateTimeAlloter sharedInstance] orthodoxBaseFormatter];
	NSDate *utcDate = [dateFormatter dateFromString:[utcFormatter stringFromDate:[NSDate new]]];
	
	int secs = MAX(0, [[utcDate dateByAddingTimeInterval:0] timeIntervalSinceDate:date]);
	int mins = secs / 60;
	int hours = mins / 60;
	int days = hours / 24;
	
	//NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
	//NSLog(@"[%d][%d][%d][%d]", days, hours, mins, secs);
	
	if (days > 0)
		interval = [[[@"" stringFromInt:days] stringByAppendingString:@"d"] stringByAppendingString:(days != 1) ? @"" : @""];
	
	else {
		if (hours > 0)
			interval = [[[@"" stringFromInt:hours] stringByAppendingString:@"h"] stringByAppendingString:(hours != 1) ? @"" : @""];
		
		else {
			if (mins > 0)
				interval = [[[@"" stringFromInt:mins] stringByAppendingString:@"m"] stringByAppendingString:(mins != 1) ? @"" : @""];
			
			else
				interval = [[[@"" stringFromInt:secs] stringByAppendingString:@"s"] stringByAppendingString:(secs != 1) ? @"" : @""];
		}
	}
	
	interval = (suffix != nil && [suffix length] > 0) ? [interval stringByAppendingString:suffix] : interval;
	return ((secs <= minSeconds) ? @"just now" : interval);
}

- (NSDateFormatter *)orthodoxBaseFormatter {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:kOrthodoxFormatSymbols];
	
	return (dateFormatter);
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
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:tzAbbreviation]];
	
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

- (int)yearsOldFromDate:(NSDate *)date {
	return ([date timeIntervalSinceNow] / -31536000);
}



@end