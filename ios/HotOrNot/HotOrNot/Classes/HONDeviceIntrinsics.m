//
//  HONDeviceIntrinsics.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/23/2014 @ 09:08.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <AdSupport/AdSupport.h>

#include <net/if.h>
#include <net/if_dl.h>
#import <sys/utsname.h>
#include <sys/socket.h>
#include <sys/sysctl.h>

#import "KeychainItemWrapper.h"

#import "HONDeviceIntrinsics.h"

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
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"com.builtinmenlo.selfieclub" accessGroup:nil];
//	NSLog(@"//////////KEYCHAIN:[%@]", [keychain objectForKey:CFBridgingRelease(kSecValueData)]);	
//	[[[UIAlertView alloc] initWithTitle:@"VENDOR ID"
//								message:[keychain objectForKey:CFBridgingRelease(kSecValueData)]
//							   delegate:nil
//					  cancelButtonTitle:@"OK"
//					  otherButtonTitles:nil] show];

	
	if ([[keychain objectForKey:CFBridgingRelease(kSecValueData)] length] == 0) {
		CFStringRef uuid = CFUUIDCreateString(NULL, CFUUIDCreate(NULL));
		NSString * uuidString = (NSString *)CFBridgingRelease(uuid);
		[keychain setObject:uuidString forKey:CFBridgingRelease(kSecValueData)];
	}
	
	NSString *strApplicationUUID = [keychain objectForKey:CFBridgingRelease(kSecValueData)];
	
//	Keychain *keychain = [[Keychain alloc] initWithService:[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey] withGroup:nil];
//	NSData *data = [keychain find:@"uuid"];
//    
//	NSString *strApplicationUUID;
//    if (data) {
//		strApplicationUUID = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    
//	} else {
//        strApplicationUUID = [[UIDevice currentDevice].identifierForVendor UUIDString];
//		if ([keychain insert:@"uuid" :[strApplicationUUID dataUsingEncoding:NSUTF8StringEncoding]]) {
//			NSLog(@"Successfully added UUID");
//		
//		} else
//			NSLog(@"Failed to add UUID");
//    }
	
	return ((noDashes) ? [strApplicationUUID stringByReplacingOccurrencesOfString:@"-" withString:@""] : strApplicationUUID);
	
	
//	CFStringRef uuid = CFUUIDCreateString(NULL, CFUUIDCreate(NULL));
//	NSString * uuidString = (NSString *)CFBridgingRelease(uuid);
//	[SSKeychain setPassword:uuidString forService:@"com.builtinmenlo.selfieclub" account:@"user"];
//	
//	return ((noDashes) ? [((NSString *)CFBridgingRelease(uuid)) stringByReplacingOccurrencesOfString:@"-" withString:@""] : (NSString *)CFBridgingRelease(uuid));
	
	
//	return ((noDashes) ? [[[UIDevice currentDevice].identifierForVendor UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""] : [[UIDevice currentDevice].identifierForVendor UUIDString]);
}

- (NSString *)advertisingIdentifierWithoutSeperators:(BOOL)noDashes {
	return ((noDashes) ? [[[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""]  : [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString]);
}

- (NSString *)identifierForVendorWithoutSeperators:(BOOL)noDashes {
	return ((noDashes) ? [[[UIDevice currentDevice].identifierForVendor UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""] : [[UIDevice currentDevice].identifierForVendor UUIDString]);
}

- (NSString *)macAddressWithoutSeperators:(BOOL)noSeperators {
	static NSString *macAddress = nil;
	if (macAddress == nil) {
		int mib[] = {
			CTL_NET,
			AF_ROUTE,
			0,
			AF_LINK,
			NET_RT_IFLIST,
			if_nametoindex("en0")
		};
		
		//get message size
		size_t length = 0;
		if (mib[5] == 0 || sysctl(mib, 6, NULL, &length, NULL, 0) < 0 || length == 0) {
			return (nil);
		}
		
		//get message
		NSMutableData *data = [NSMutableData dataWithLength:length];
		if (sysctl(mib, 6, [data mutableBytes], &length, NULL, 0) < 0) {
			return (nil);
		}
		
		//get socket address
		struct sockaddr_dl *socketAddress = ([data mutableBytes] + sizeof(struct if_msghdr));
		unsigned char *coreAddress = (unsigned char *)LLADDR(socketAddress);
		macAddress = [[NSString alloc] initWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
					  coreAddress[0], coreAddress[1], coreAddress[2],
					  coreAddress[3], coreAddress[4], coreAddress[5]];
	}
	
	return ((noSeperators) ? [macAddress stringByReplacingOccurrencesOfString:@":" withString:@""] : macAddress);
}

- (BOOL)isIOS7 {
	return ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] isEqualToString:@"7"]);
}

- (BOOL)isPhoneType5s {
	return ([[[HONDeviceIntrinsics sharedInstance] modelName] rangeOfString:@"iPhone6"].location == 0);
}

- (BOOL)isRetina4Inch {
	return ([UIScreen mainScreen].scale == 2.0f && [UIScreen mainScreen].bounds.size.height == 568.0f);
}

- (NSString *)locale {
	return ([[NSLocale preferredLanguages] objectAtIndex:0]);
}

- (NSString *)deviceName {
	return ([[UIDevice currentDevice] name]);
}

- (NSString *)modelName {
	struct utsname systemInfo;
	uname(&systemInfo);
	
	return ([NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding]);
}


- (BOOL)hasAdressBookPermission {
	return (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized);
}


@end
