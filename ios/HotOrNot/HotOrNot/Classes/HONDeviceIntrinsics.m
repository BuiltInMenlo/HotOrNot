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
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/CaptiveNetwork.h>

#include <arpa/inet.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <sys/utsname.h>
#include <sys/socket.h>
#include <sys/sysctl.h>

#import "NSDictionary+BuiltinMenlo.h"

#import "KeychainItemWrapper.h"
#import "Reachability.h"

#import "HONDeviceIntrinsics.h"


const CGSize kScreenMult = {0.853333333, 0.851574213f};



// Stores reference on WiFi/LAN interface name
static NSString * const kPNNetworkWirelessCableInterfaceName = @"en";

// Store reference on 3G/EDGE interface name
static NSString * const kPNNetworkCellularInterfaceName = @"pdp_ip";

// Stores reference on default IP address which means that interface is not really connected
static char * const kPNNetworkDefaultAddress = "0.0.0.0";

// WiFi service types
static NSString * kPNWLANBasicServiceSetIdentifierKey = @"BSSID";
static NSString * kPNWLANServiceSetIdentifierKey = @"SSID";




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


- (NSString *)lanIPAddress {
	NSString *address = nil;
	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *interface = NULL;
	
	// Retrieving list of interfaces
	if (getifaddrs(&interfaces) == 0) {
		
		interface = interfaces;
		while (interface != NULL) {
			
			// Checking whether found network interface or not
			sa_family_t family = interface->ifa_addr->sa_family;
			if (family == AF_INET || family == AF_INET6) {
				
				char *interfaceName = interface->ifa_name;
				char *interfaceAddress = inet_ntoa(((struct sockaddr_in*)interface->ifa_addr)->sin_addr);
				unsigned int interfaceStateFlags = interface->ifa_flags;
				BOOL isActive = !(interfaceStateFlags & IFF_LOOPBACK);
				
				if (isActive) {
					
					NSString *interfaceNameString = [NSString stringWithUTF8String:interfaceName];
					
					if ([interfaceNameString hasPrefix:kPNNetworkWirelessCableInterfaceName] ||
						[interfaceNameString hasPrefix:kPNNetworkCellularInterfaceName]) {
						
						// Check on whether interface has assigned address or not
						if (strcmp(interfaceAddress, kPNNetworkDefaultAddress) != 0) {
							
							address = [NSString stringWithUTF8String:interfaceAddress];
							
							break;
						}
						
					}
				}
			}
			
			interface = interface->ifa_next;
		}
	}
	
	freeifaddrs(interfaces);
	
	
	return address;
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

- (BOOL)isPhoneType6 {
	return ([UIScreen mainScreen].scale == 2.0f && [UIScreen mainScreen].bounds.size.height == 667.0f);
}

- (BOOL)isPhoneType6Plus {
	return ([UIScreen mainScreen].scale == 3.0f && [UIScreen mainScreen].bounds.size.height == 736.0f);
}

- (BOOL)isRetina4Inch {
	return ([UIScreen mainScreen].scale == 2.0f && [UIScreen mainScreen].bounds.size.height == 568.0f);
}

- (CGFloat)scaledScreenHeight {
	return (CGSizeMult([UIScreen mainScreen].bounds.size, [UIScreen mainScreen].scale).height);
}

- (CGSize)scaledScreenSize {
	return (CGSizeMult([UIScreen mainScreen].bounds.size, [UIScreen mainScreen].scale));
}

- (CGFloat)scaledScreenWidth {
	return (CGSizeMult([UIScreen mainScreen].bounds.size, [UIScreen mainScreen].scale).width);
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

- (void)writePushToken:(NSString *)pushToken {
	[[NSUserDefaults standardUserDefaults] replaceObject:pushToken forKey:@"device_token"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)pushToken {
	return (([[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"] != nil) ? [[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"] : @"");
}

- (void)writeDataPushToken:(NSData *)pushToken {
	[[NSUserDefaults standardUserDefaults] replaceObject:pushToken forKey:@"device_token-data"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSData *)dataPushToken {
	return (([[NSUserDefaults standardUserDefaults] objectForKey:@"device_token-data"] != nil) ? [[NSUserDefaults standardUserDefaults] objectForKey:@"device_token-data"] : [NSData data]);
}


- (CLLocation *)deviceLocation {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"coords"] == nil)
		[[HONDeviceIntrinsics sharedInstance] updateDeviceLocation:[[CLLocation alloc] initWithLatitude:CGFLOAT_MAX longitude:CGFLOAT_MAX]];
	
	return ([[CLLocation alloc] initWithLatitude:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"coords"] objectForKey:@"lat"] doubleValue] longitude:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"coords"] objectForKey:@"lon"] doubleValue]]);
}

- (void)updateDeviceLocation:(CLLocation *)location {
	NSLog(@"DEVICE LOCATION UPDATE:[%@]", NSStringFromCLLocation(location));
//	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"coords"];
//	[[NSUserDefaults standardUserDefaults] synchronize];
//	
	[[NSUserDefaults standardUserDefaults] replaceObject:@{@"lat"	:[NSNumber numberWithDouble:location.coordinate.latitude],
														   @"lon"	:[NSNumber numberWithDouble:location.coordinate.longitude]} forKey:@"coords"];
	
//	[[NSUserDefaults standardUserDefaults] setValue:@{@"lat"	:[NSNumber numberWithDouble:location.coordinate.latitude],
//													  @"lon"	:[NSNumber numberWithDouble:location.coordinate.longitude]} forKey:@"coords"];
//	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)geoLocale {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"device_locale"]);
}

- (void)updateGeoLocale:(NSDictionary *)locale {
	[[NSUserDefaults standardUserDefaults] replaceObject:locale forKey:@"device_locale"];
//	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)hasNetwork {
	Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
	NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
	return (networkStatus != NotReachable);
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
