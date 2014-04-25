//
//  HONPhysicsGovernor.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 03:50 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

@interface HONPhysicsGovernor : NSObject
+ (HONPhysicsGovernor *)sharedInstance;

- (CGFloat)springOrthodoxDampening;
- (CGFloat)springOrthodoxDelay;
- (CGFloat)springOrthodoxDuration;
- (CGFloat)springOrthodoxInitVelocity;
@end
