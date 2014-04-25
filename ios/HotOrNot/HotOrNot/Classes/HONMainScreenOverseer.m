//
//  HONMainScreenOverseer.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 22:48 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONMainScreenOverseer.h"

@implementation HONMainScreenOverseer
static HONMainScreenOverseer *sharedInstance = nil;

+ (HONMainScreenOverseer *)sharedInstance {
	static HONMainScreenOverseer *s_sharedInstance = nil;
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

- (void)promptWithAlertView:(UIAlertView *)alertView {
	[alertView show];
}

- (NSShadow *)orthodoxUIShadowAttribute {
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.875]];
	[shadow setShadowOffset:CGSizeMake(0.0, 1.0)];
	[shadow setShadowBlurRadius:0.5];
	
	return (shadow);
}


@end
