//
//  HONDeviceIntrinsics.
//  HotOrNot
//
//  Created by Matt Holcombe on 01/23/2014 @ 09:08.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

@interface HONDeviceIntrinsics : NSObject
+ (HONDeviceIntrinsics *)sharedInstance;

- (NSString *)uniqueIdentifierWithoutSeperators:(BOOL)noDashes;
- (NSString *)advertisingIdentifierWithoutSeperators:(BOOL)noDashes;
- (NSString *)identifierForVendorWithoutSeperators:(BOOL)noDashes;

- (BOOL)isIOS7;
- (BOOL)isIOS8;
- (BOOL)isPhoneType5s;
- (BOOL)isRetina4Inch;

- (NSString *)lanIPAddress;
- (NSString *)locale;
- (NSString *)modelName;
- (NSString *)deviceName;
- (NSString *)osName;
- (NSString *)osNameVersion;
- (NSString *)osVersion;

- (void)writePushToken:(NSString *)pushToken;
- (NSString *)pushToken;

- (CLLocation *)deviceLocation;
- (void)updateDeviceLocation:(CLLocation *)location;

- (NSDictionary *)geoLocale;
- (void)updateGeoLocale:(NSDictionary *)locale;

- (BOOL)hasNetwork;

- (NSMutableString *)hmacToken;

- (void)writePhoneNumber:(NSString *)phoneNumber;
- (NSString *)phoneNumber;
- (NSString *)areaCodeFromPhoneNumber;
@end
