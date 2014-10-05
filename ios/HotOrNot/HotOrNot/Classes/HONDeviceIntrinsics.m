//
//  HONDeviceIntrinsics.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/23/2014 @ 09:08.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <AdSupport/AdSupport.h>
#import <CommonCrypto/CommonHMAC.h>

#include <net/if.h>
#include <net/if_dl.h>
#import <sys/utsname.h>
#include <sys/socket.h>
#include <sys/sysctl.h>

#import "KeychainItemWrapper.h"

#import "HONDeviceIntrinsics.h"

// hMAC key
NSString * const kHMACKey = @"YARJSuo6/r47LczzWjUx/T8ioAJpUKdI/ZshlTUP8q4ujEVjC0seEUAAtS6YEE1Veghz+IDbNQ";


@implementation HONDeviceIntrinsics
static HONDeviceIntrinsics *sharedInstance = nil;

+ (HONDeviceIntrinsics *)sharedInstance {
	static HONDeviceIntrinsics *s_sharedInstance = nil;
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

- (NSString *)uniqueIdentifierWithoutSeperators:(BOOL)noDashes {
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
	
	if ([[keychain objectForKey:CFBridgingRelease(kSecValueData)] length] == 0) {
		CFStringRef uuid = CFUUIDCreateString(NULL, CFUUIDCreate(NULL));
		NSString * uuidString = (NSString *)CFBridgingRelease(uuid);
		[keychain setObject:uuidString forKey:CFBridgingRelease(kSecValueData)];
	}
	
	NSString *strApplicationUUID = [keychain objectForKey:CFBridgingRelease(kSecValueData)];
	return ((noDashes) ? [strApplicationUUID stringByReplacingOccurrencesOfString:@"-" withString:@""] : strApplicationUUID);
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

- (BOOL)isIOS8 {
	return ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] isEqualToString:@"8"]);
}

- (BOOL)isPhoneType5s {
	return ([[[HONDeviceIntrinsics sharedInstance] modelName] rangeOfString:@"iPhone6"].location == 0);
}

- (BOOL)isRetina4Inch {
	return ([UIScreen mainScreen].scale == 2.0f && [UIScreen mainScreen].bounds.size.height == 568.0f);
}

- (NSString *)locale {
	return ([[NSLocale preferredLanguages] firstObject]);
}

- (NSString *)deviceName {
	return ([[UIDevice currentDevice] name]);
}

- (NSString *)modelName {
	struct utsname systemInfo;
	uname(&systemInfo);
	
	return ([NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding]);
}

- (NSString *)osName {
	return ([[UIDevice currentDevice] systemName]);
}

- (NSString *)osNameVersion {
	return ([NSString stringWithFormat:@"%@ %@", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]]);
}

- (NSString *)osVersion {
	return ([[UIDevice currentDevice] systemVersion]);
}

- (NSString *)pushToken {
	return (([[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"] != nil) ? [[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"] : @"");
}

- (NSString *)hmacToken {
	NSMutableString *token = [@"unknown" mutableCopy];
	NSMutableString *data = [[[HONDeviceIntrinsics sharedInstance] uniqueIdentifierWithoutSeperators:YES] mutableCopy];
	
	if( data != nil ){
		[data appendString:@"+"];
		[data appendString:[[HONDeviceIntrinsics sharedInstance] uniqueIdentifierWithoutSeperators:NO]];
		
		token = [[[HONAPICaller sharedInstance] hmacForKey:kHMACKey withData:data] mutableCopy];
		[token appendString:@"+"];
		[token appendString:data];
	}
	
	return ([token copy]);
}

- (void)writePhoneNumber:(NSString *)phoneNumber {
	NSLog(@"writePhoneNumber:[%@]", phoneNumber);
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"phone_number"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"phone_number"];
	
	phoneNumber = [[phoneNumber componentsSeparatedByString:@"@"] firstObject];
	[[NSUserDefaults standardUserDefaults] setObject:phoneNumber forKey:@"phone_number"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
	[keychain setObject:phoneNumber forKey:CFBridgingRelease(kSecAttrService)];
}

- (NSString *)phoneNumber {
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
//	NSLog(@"DeviceInstrinsics phoneNumber:[%@][%@]", [[NSUserDefaults standardUserDefaults] objectForKey:@"phone_number"], [keychain objectForKey:CFBridgingRelease(kSecAttrService)]);
	return (([keychain objectForKey:CFBridgingRelease(kSecAttrService)] != nil) ? [keychain objectForKey:CFBridgingRelease(kSecAttrService)] : @"");
}

- (NSString *)areaCodeFromPhoneNumber {
	return (([[[HONDeviceIntrinsics sharedInstance] phoneNumber] length] > 0) ? [[[HONDeviceIntrinsics sharedInstance] phoneNumber] substringWithRange:NSMakeRange(2, 3)] : @"");
}

@end
