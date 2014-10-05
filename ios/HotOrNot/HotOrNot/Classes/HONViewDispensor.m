//
//  HONViewDispensor.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 22:48 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONViewDispensor.h"

@implementation HONViewDispensor
static HONViewDispensor *sharedInstance = nil;

+ (HONViewDispensor *)sharedInstance {
	static HONViewDispensor *s_sharedInstance = nil;
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

- (void)appWindowAdoptsView:(UIView *)view {
	[[[UIApplication sharedApplication] delegate].window addSubview:view];
}

- (UIView *)matteViewWithSize:(CGSize)size usingColor:(UIColor *)color {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
	view.backgroundColor = color;
	
	return (view);
}

@end
