//
//  HONDateTimeAlloter.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/14/2014 @ 21:27 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+Operations.h"
#import "NSString+DataTypes.h"

#import "HONDateTimeAlloter.h"

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
	
	int secs = MAX(0, [NSDate elapsedSecondsSinceDate:date isUTC:YES]);
	int mins = MAX(0, [NSDate elapsedMinutesSinceDate:date isUTC:YES]);
	int hours = MAX(0, [NSDate elapsedHoursSinceDate:date isUTC:YES]);
	int days = MAX(0, [NSDate elapsedDaysSinceDate:date isUTC:YES]);
	
//	NSLog(@"UTC_NOW:[%@] DATE:[%@] -=- SECS:[%d]", [NSDate utcNowDate], date, secs);
	
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

@end
