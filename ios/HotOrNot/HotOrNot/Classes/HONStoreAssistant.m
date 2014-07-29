//
//  HONStoreAssistant.m
//  HotOrNot
//
//  Created by Matt Holcombe on 07/26/2014 @ 13:44 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONStoreAssistant.h"

@implementation HONStoreAssistant
static HONStoreAssistant *sharedInstance = nil;

+ (HONStoreAssistant *)sharedInstance {
	static HONStoreAssistant *s_sharedInstance = nil;
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


@end
