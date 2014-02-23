//
//  HONAnalyticsParams.h
//  HotOrNot
//
//  Created by Matt Holcombe on 02/22/2014 @ 13:43 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HONAnalyticsParams : NSObject
+ (HONAnalyticsParams *)sharedInstance;

- (NSDictionary *)userProperty;
@end
