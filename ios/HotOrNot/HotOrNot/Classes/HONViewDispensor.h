//
//  HONViewDispensor.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 22:48 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


@interface HONViewDispensor : NSObject
+ (HONViewDispensor *)sharedInstance;

- (void)appWindowAdoptsView:(UIView *)view;
- (UIView *)matteViewWithSize:(CGSize)size usingColor:(UIColor *)color;
@end
