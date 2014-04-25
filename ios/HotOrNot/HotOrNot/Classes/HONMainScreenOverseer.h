//
//  HONMainScreenOverseer.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 22:48 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


@interface HONMainScreenOverseer : NSObject
+ (HONMainScreenOverseer *)sharedInstance;

- (void)appWindowAdoptsView:(UIView *)view;
- (void)promptWithAlertView:(UIAlertView *)alertView;


- (NSShadow *)orthodoxUIShadowAttribute;
@end
