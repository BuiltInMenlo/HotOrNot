//
//  HONDateTimeStipulator.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/06/2014 @ 08:30 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONDateTimeStipulator.h"

NSString * const kOrthodoxFormatSymbols = @"yyyy-MM-ddHH:mm:ss";

@implementation HONDateTimeStipulator

static HONDateTimeStipulator *sharedInstance = nil;

+ (HONDateTimeStipulator *)sharedInstance {
	static HONDateTimeStipulator *s_sharedInstance = nil;
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


- (NSDate *)dateFromOrthodoxFormattedString:(NSString *)stringDate {
	return ([[[HONDateTimeStipulator sharedInstance] orthodoxBaseFormatter] dateFromString:stringDate]);
}

- (NSString *)intervalSinceDate:(NSDate *)date minSeconds:(int)minSeconds includeSuffix:(NSString *)suffix {
	NSString *interval = @"0 secs";
	
	NSDateFormatter *utcFormatter = [[HONDateTimeStipulator sharedInstance] orthodoxUTCDateFormatter];
	NSDateFormatter *dateFormatter = [[HONDateTimeStipulator sharedInstance] orthodoxBaseFormatter];
	NSDate *utcDate = [dateFormatter dateFromString:[utcFormatter stringFromDate:[NSDate new]]];
	
	int secs = [[utcDate dateByAddingTimeInterval:0] timeIntervalSinceDate:date];
	int mins = secs / 60;
	int hours = mins / 60;
	int days = hours / 24;
	
	//NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
	//NSLog(@"[%d][%d][%d][%d]", days, hours, mins, secs);
	
	if (days > 0)
		interval = [[[@"" stringFromInt:days] stringByAppendingString:@" day"] stringByAppendingString:(days != 1) ? @"s" : @""];
		
	else {
		if (hours > 0)
			interval = [[[@"" stringFromInt:hours] stringByAppendingString:@" hr"] stringByAppendingString:(hours != 1) ? @"s" : @""];
		
		else {
			if (mins > 0)
				interval = [[[@"" stringFromInt:mins] stringByAppendingString:@" min"] stringByAppendingString:(mins != 1) ? @"s" : @""];
			
			else
				interval = [[[@"" stringFromInt:secs] stringByAppendingString:@" sec"] stringByAppendingString:(secs != 1) ? @"s" : @""];
		}
	}
	
	interval = (suffix != nil && [suffix length] > 0) ? [interval stringByAppendingString:suffix] : interval;	
	return (([[[interval componentsSeparatedByString:@" "] firstObject] intValue] <= minSeconds) ? @"just now" : interval);
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
	
	NSDateFormatter *dateFormatter = [[HONDateTimeStipulator sharedInstance] orthodoxBaseFormatter];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:tzAbbreviation]];
	
	return (dateFormatter);
}

- (NSDateFormatter *)orthodoxUTCDateFormatter {
	return ([[HONDateTimeStipulator sharedInstance] orthodoxFormatterWithTimezone:@"UTC"]);
}

- (NSString *)orthodoxFormattedStringFromDate:(NSDate *)date; {
	if (date == nil)
		date = [NSDate date];
	
	return ([[[HONDateTimeStipulator sharedInstance] orthodoxBaseFormatter] stringFromDate:date]);
}

- (NSString *)timezoneFromDeviceLocale {
	return ([[NSTimeZone systemTimeZone] abbreviation]);
}


@end
