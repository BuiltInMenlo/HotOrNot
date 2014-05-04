//
//  HONScreenManager.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 22:48 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


@interface HONScreenManager : NSObject
+ (HONScreenManager *)sharedInstance;

- (void)appWindowAdoptsView:(UIView *)view;
@end
