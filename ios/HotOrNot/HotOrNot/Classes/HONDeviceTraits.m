//
//  HONDeviceTraits.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/23/2014 @ 09:08.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <AdSupport/AdSupport.h>
#import <sys/utsname.h>

#import "HONDeviceTraits.h"

@implementation HONDeviceTraits
static HONDeviceTraits *sharedInstance = nil;

+ (HONDeviceTraits *)sharedInstance {
	static HONDeviceTraits *s_sharedInstance = nil;
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


- (NSString *)advertisingIdentifierWithoutSeperators:(BOOL)noDashes {
	return ((noDashes) ? [[[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""]  : [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString]);
}

- (NSString *)identifierForVendorWithoutSeperators:(BOOL)noDashes {
	return ((noDashes) ? [[[UIDevice currentDevice].identifierForVendor UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""] : [[UIDevice currentDevice].identifierForVendor UUIDString]);
}


- (BOOL)isIOS7 {
	return ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] isEqualToString:@"7"]);
}

- (BOOL)isPhoneType5s {
	return ([[[HONDeviceTraits sharedInstance] modelName] rangeOfString:@"iPhone6"].location == 0);
}

- (BOOL)isRetina4Inch {
	return ([UIScreen mainScreen].scale == 2.0f && [UIScreen mainScreen].bounds.size.height == 568.0f);
}

- (NSString *)locale {
	return ([[NSLocale preferredLanguages] objectAtIndex:0]);
}

- (NSString *)modelName {
	struct utsname systemInfo;
	uname(&systemInfo);
	
	return ([NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding]);
}

@end
