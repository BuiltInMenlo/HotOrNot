//
//  HONPhysicsGovernor.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 03:50 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONPhysicsGovernor.h"


#define ORTHODOX_SPRING_DAMPENING	0.875f
#define ORTHODOX_SPRING_DELAY		0.000f
#define ORTHODOX_SPRING_DURATION	0.333f
#define ORTHODOX_SPRING_INIT_VEL	0.500f


@implementation HONPhysicsGovernor
static HONPhysicsGovernor *sharedInstance = nil;

+ (HONPhysicsGovernor *)sharedInstance {
	static HONPhysicsGovernor *s_sharedInstance = nil;
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


- (CGFloat)springOrthodoxDampening {
	return (ORTHODOX_SPRING_DAMPENING);
}

- (CGFloat)springOrthodoxDelay {
	return (ORTHODOX_SPRING_DELAY);
}

- (CGFloat)springOrthodoxDuration {
	return (ORTHODOX_SPRING_DURATION);
}

- (CGFloat)springOrthodoxInitVelocity {
	return (ORTHODOX_SPRING_INIT_VEL);
}


@end
