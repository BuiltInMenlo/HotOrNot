//
//  HONDateTimeAlloter.h
//  HotOrNot
//
//  Created by Matt Holcombe on 06/14/2014 @ 21:27 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


@interface HONDateTimeAlloter : NSObject
+ (HONDateTimeAlloter *)sharedInstance;

- (NSString *)intervalSinceDate:(NSDate *)date;
- (NSString *)intervalSinceDate:(NSDate *)date includeSuffix:(NSString *)suffix;
- (NSString *)intervalSinceDate:(NSDate *)date minSeconds:(int)minSeconds usingIndicators:(NSDictionary *)indicators includeSuffix:(NSString *)suffix;
@end
