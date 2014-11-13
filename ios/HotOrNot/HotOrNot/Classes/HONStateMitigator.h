//
//  HONStateMitigator.h
//  HotOrNot
//
//  Created by BIM  on 10/29/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONViewController.h"
#import "HONStateMitigatorEnums.h"


extern NSString * const kStateMitigatorKey;
extern NSString * const kStateMitigatorUnknown;
extern NSString * const kStateMitigatorNotAvailable;

extern NSString * const kStateMitigatorAppEntryKey;
extern NSString * const kStateMitigatorCurrentViewKey;
extern NSString * const kStateMitigatorPreviousViewKey;
extern NSString * const kStateMitigatorInstallTimestampKey;
extern NSString * const kStateMitigatorEntryTimestampKey;
extern NSString * const kStateMitigatorExitTimestampKey;
extern NSString * const kStateMitigatorTrackingTimestampKey;
extern NSString * const kStateMitigatorTotalCounterKeySuffix;

extern NSString * const kStateMitigatorAppEntryName;
extern NSString * const kStateMitigatorAppEntryNameUnknown;
extern NSString * const kStateMitigatorAppEntryNameNotAvailable;
extern NSString * const kStateMitigatorAppEntryNameBoot;
extern NSString * const kStateMitigatorAppEntryNameSpringboard;
extern NSString * const kStateMitigatorAppEntryNameDeepLink;
extern NSString * const kStateMitigatorAppEntryNameRemoteNotification;
extern NSString * const kStateMitigatorAppEntryNameLocalNotification;

extern NSString * const kStateMitigatorViewStateName;
extern NSString * const kStateMitigatorViewStateNameUnknown;
extern NSString * const kStateMitigatorViewStateNameNotAvailable;
extern NSString * const kStateMitigatorViewStateNameRegistration;
extern NSString * const kStateMitigatorViewStateNameRegistrationCountryCodes;
extern NSString * const kStateMitigatorViewStateNamePINEntry;
extern NSString * const kStateMitigatorViewStateNameFriends;
extern NSString * const kStateMitigatorViewStateNameSettings;
extern NSString * const kStateMitigatorViewStateNameTimeline;
extern NSString * const kStateMitigatorViewStateNameCompose;
extern NSString * const kStateMitigatorViewStateNameAnimatedBGs;
extern NSString * const kStateMitigatorViewStateNameStoreProducts;
extern NSString * const kStateMitigatorViewStateNameStoreProductDetails;
extern NSString * const kStateMitigatorViewStateNameComposeSubmit;
extern NSString * const kStateMitigatorViewStateNameActivity;
extern NSString * const kStateMitigatorViewStateNameSearchUsername;
extern NSString * const kStateMitigatorViewStateNameSearchContact;
extern NSString * const kStateMitigatorViewStateNameSearchContactCountryCodes;
extern NSString * const kStateMitigatorViewStateNameSupport;
extern NSString * const kStateMitigatorViewStateNameLegal;
extern NSString * const kStateMitigatorViewStateNameNetworkStatus;

extern NSString * const kStateMitigatorTotalCounterName;
extern NSString * const kStateMitigatorTotalCounterNameUnknown;
extern NSString * const kStateMitigatorTotalCounterNameTrackingCalls;
extern NSString * const kStateMitigatorTotalCounterNameBoot;
extern NSString * const kStateMitigatorTotalCounterNameExit;
extern NSString * const kStateMitigatorTotalCounterNameResume;
extern NSString * const kStateMitigatorTotalCounterNameBackground;
extern NSString * const kStateMitigatorTotalCounterNameRegistration;
extern NSString * const kStateMitigatorTotalCounterNameRegistrationCountryCodes;
extern NSString * const kStateMitigatorTotalCounterNamePINEntry;
extern NSString * const kStateMitigatorTotalCounterNameFriendsTab;
extern NSString * const kStateMitigatorTotalCounterNameFriendsTabRefresh;
extern NSString * const kStateMitigatorTotalCounterNameSettingsTab;
extern NSString * const kStateMitigatorTotalCounterNameTimeline;
extern NSString * const kStateMitigatorTotalCounterNameTimelineRefresh;
extern NSString * const kStateMitigatorTotalCounterNameReply;
extern NSString * const kStateMitigatorTotalCounterNameCompose;
extern NSString * const kStateMitigatorTotalCounterNameStoreProducts;
extern NSString * const kStateMitigatorTotalCounterNameStoreProductsRefresh;
extern NSString * const kStateMitigatorTotalCounterNameStoreProductDetails;
extern NSString * const kStateMitigatorTotalCounterNameStoreProductDetailsRefresh;
extern NSString * const kStateMitigatorTotalCounterNameAnimatedBGs;
extern NSString * const kStateMitigatorTotalCounterNameAnimatedBGsRefresh;
extern NSString * const kStateMitigatorTotalCounterNameComposeSubmit;
extern NSString * const kStateMitigatorTotalCounterNameComposeSubmitRefresh;
extern NSString * const kStateMitigatorTotalCounterNameActivity;
extern NSString * const kStateMitigatorTotalCounterNameActivityRefresh;
extern NSString * const kStateMitigatorTotalCounterNameSearchUsername;
extern NSString * const kStateMitigatorTotalCounterNameSearchContacts;
extern NSString * const kStateMitigatorTotalCounterNameSearchContactsCountryCodes;
extern NSString * const kStateMitigatorTotalCounterNameSupport;
extern NSString * const kStateMitigatorTotalCounterNameLegal;
extern NSString * const kStateMitigatorTotalCounterNameNetworkStatus;
extern NSString * const kStateMitigatorTotalCounterNameNetworkStatusRefresh;
extern NSString * const kStateMitigatorTotalCounterNameShare;

@interface HONStateMitigator : NSObject
+ (HONStateMitigator *)sharedInstance;

- (int)incrementTotalCounterForType:(HONStateMitigatorTotalType)totalType;
- (void)resetTotalCounterForType:(HONStateMitigatorTotalType)totalType withValue:(int)value;
- (void)resetAllTotalCounters;
- (void)writeAppInstallTimestamp;
- (void)updateAppEntryTimestamp:(NSDate *)date;
- (void)updateAppExitTimestamp:(NSDate *)date;
- (void)updateLastTrackingCallTimestamp:(NSDate *)date;
- (void)updateAppEntryPoint:(HONStateMitigatorAppEntryType)appEntryType;
- (void)updateCurrentViewState:(HONStateMitigatorViewStateType)viewStateType;

- (HONStateMitigatorAppEntryType)appEntryType;
- (HONStateMitigatorViewStateType)currentViewStateType;
- (HONStateMitigatorViewStateType)previousViewStateType;

- (int)totalCounterForType:(HONStateMitigatorTotalType)totalType;
- (NSString *)appEntryTypeName;
- (NSString *)currentViewStateTypeName;
- (NSString *)previousViewStateTypeName;
- (NSDate *)appInstallTimestamp;
- (NSDate *)appEntryTimestamp;
- (NSDate *)appExitTimestamp;
- (NSDate *)lastTrackingCallTimestamp;

- (NSDictionary *)_totalKeyPrefixesForTypes;
- (NSDictionary *)_appEntryKeyNamesForTypes;
- (NSDictionary *)_viewStateKeyNamesForTypes;
- (NSString *)_keyForTotalType:(HONStateMitigatorTotalType)totalType;
- (HONStateMitigatorTotalType)_totalTypeForKey:(NSString *)key;

@end
