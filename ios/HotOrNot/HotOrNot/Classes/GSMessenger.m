//
//  GSMessenger.h
//  HotOrNot
//
//  Created by BIM  on 6/30/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "GSMessenger.h"


@implementation GSMessenger

static GSMessenger *sharedInstance = nil;
+ (GSMessenger *)sharedInstance {
	static GSMessenger *s_sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		s_sharedInstance = [[self alloc] init];
	});
	
	return (s_sharedInstance);
}

- (id)init {
	if((self = [super init]) != nil) {
		_selectedTypes = [NSMutableArray array];
		_supportedTypes = [NSArray arrayWithObjects:@(GSMessengerTypeFBMessenger), @(GSMessengerTypeKakaoTalk), @(GSMessengerTypeKik), @(GSMessengerTypeLine), @(GSMessengerTypeSMS), @(GSMessengerTypeWhatsApp), @(GSMessengerTypeWeChat), @(GSMessengerTypeHike), @(GSMessengerTypeOTHER), nil];
	}
	
	return (self);
}

- (void)addMessengerType:(GSMessengerType)messengerType {
	[_selectedTypes addObject:@(messengerType)];
}


- (NSArray *)selectedTypes {
	return (_selectedTypes);
}

- (NSArray *)supportedTypes {
	return (_supportedTypes);
}


@end
