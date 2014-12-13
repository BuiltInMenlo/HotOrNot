//
//  HONStateMitigator.m
//  HotOrNot
//
//  Created by BIM  on 10/29/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+Operations.h"
#import "NSUserDefaults+Replacements.h"

#import "HONStateMitigator.h"

NSString * const kStateMitigatorKey				= @"";
NSString * const kStateMitigatorUnknown			= @"UNKNOWN";
NSString * const kStateMitigatorNotAvailable	= @"N/A";

NSString * const kStateMitigatorAppEntryKey				= @"app_entry";
NSString * const kStateMitigatorCurrentViewKey			= @"current_view";
NSString * const kStateMitigatorPreviousViewKey			= @"previous_view";
NSString * const kStateMitigatorInstallTimestampKey		= @"install_timestamp";
NSString * const kStateMitigatorEntryTimestampKey		= @"entry_timestamp";
NSString * const kStateMitigatorExitTimestampKey		= @"exit_timestamp";
NSString * const kStateMitigatorTrackingTimestampKey	= @"tracking_timestamp";
NSString * const kStateMitigatorTotalCounterKeySuffix	= @"_total";

NSString * const kStateMitigatorAppEntryName					= @"";
NSString * const kStateMitigatorAppEntryNameUnknown				= @"UNKNOWN";
NSString * const kStateMitigatorAppEntryNameNotAvailable		= @"N/A";
NSString * const kStateMitigatorAppEntryNameBoot				= @"boot";
NSString * const kStateMitigatorAppEntryNameSpringboard			= @"springboard";
NSString * const kStateMitigatorAppEntryNameDeepLink			= @"deep_link";
NSString * const kStateMitigatorAppEntryNameRemoteNotification	= @"remote_notification";
NSString * const kStateMitigatorAppEntryNameLocalNotification	= @"local_notification";

NSString * const kStateMitigatorViewStateName							= @"";
NSString * const kStateMitigatorViewStateNameUnknown					= @"UNKNOWN";
NSString * const kStateMitigatorViewStateNameNotAvailable				= @"N/A";
NSString * const kStateMitigatorViewStateNameRegistration				= @"registration";
NSString * const kStateMitigatorViewStateNameRegistrationCountryCodes	= @"registration_country_codes";
NSString * const kStateMitigatorViewStateNamePINEntry					= @"pin_entry";
NSString * const kStateMitigatorViewStateNameHome						= @"home";
NSString * const kStateMitigatorViewStateNameFriends					= @"friends";
NSString * const kStateMitigatorViewStateNameSettings					= @"settings";
NSString * const kStateMitigatorViewStateNameStatusUpdate				= @"status_update";
NSString * const kStateMitigatorViewStateNameCompose					= @"compose";
NSString * const kStateMitigatorViewStateNameAnimatedBGs				= @"animated_bgs";
NSString * const kStateMitigatorViewStateNameStoreProducts				= @"sticker_store";
NSString * const kStateMitigatorViewStateNameStoreProductDetails		= @"sticker_store_details";
NSString * const kStateMitigatorViewStateNameComposeSubmit				= @"compose_submit";
NSString * const kStateMitigatorViewStateNameActivity					= @"activity";
NSString * const kStateMitigatorViewStateNameSearchUsername				= @"search_username";
NSString * const kStateMitigatorViewStateNameSearchContact				= @"search_contact";
NSString * const kStateMitigatorViewStateNameSearchContactCountryCodes	= @"search_contact_country_codes";
NSString * const kStateMitigatorViewStateNameSupport					= @"support";
NSString * const kStateMitigatorViewStateNameLegal						= @"legal";
NSString * const kStateMitigatorViewStateNameNetworkStatus				= @"network_status";

NSString * const kStateMitigatorTotalCounter							= @"";
NSString * const kStateMitigatorTotalCounterUnknown						= @"UNKNOWN";
NSString * const kStateMitigatorTotalCounterTrackingCalls				= @"tracking";
NSString * const kStateMitigatorTotalCounterBoot						= @"boot";
NSString * const kStateMitigatorTotalCounterExit						= @"exit";
NSString * const kStateMitigatorTotalCounterResume						= @"resume";
NSString * const kStateMitigatorTotalCounterBackground					= @"background";
NSString * const kStateMitigatorTotalCounterRegistration				= @"registration";
NSString * const kStateMitigatorTotalCounterRegistrationCountryCodes	= @"registrationCountryCodes";
NSString * const kStateMitigatorTotalCounterPINEntry					= @"pinEntry";
NSString * const kStateMitigatorTotalCounterHomeTab						= @"homeTab";
NSString * const kStateMitigatorTotalCounterHomeTabRefresh				= @"homeTabRefresh";
NSString * const kStateMitigatorTotalCounterFriendsTab					= @"friendsTab";
NSString * const kStateMitigatorTotalCounterFriendsTabRefresh			= @"friendsTabRefresh";
NSString * const kStateMitigatorTotalCounterSettingsTab					= @"settingsTab";
NSString * const kStateMitigatorTotalCounterStatusUpdate				= @"statusUpdate";
NSString * const kStateMitigatorTotalCounterStatusUpdateRefresh			= @"statusUpdateRefresh";
NSString * const kStateMitigatorTotalCounterReply						= @"reply";
NSString * const kStateMitigatorTotalCounterCompose						= @"compose";
NSString * const kStateMitigatorTotalCounterComposeRefresh				= @"composeRefresh";
NSString * const kStateMitigatorTotalCounterAnimatedBGs					= @"animatedBGs";
NSString * const kStateMitigatorTotalCounterAnimatedBGsRefresh			= @"animatedBGsRefresh";
NSString * const kStateMitigatorTotalCounterStoreProducts				= @"storeProducts";
NSString * const kStateMitigatorTotalCounterStoreProductsRefresh		= @"storeProductsRefresh";
NSString * const kStateMitigatorTotalCounterStoreProductDetails			= @"storeProductDetails";
NSString * const kStateMitigatorTotalCounterStoreProductDetailsRefresh	= @"storeProductDetailsRefresh";
NSString * const kStateMitigatorTotalCounterComposeSubmit				= @"composeSubmit";
NSString * const kStateMitigatorTotalCounterComposeSubmitRefresh		= @"composeSubmitRefresh";
NSString * const kStateMitigatorTotalCounterActivity					= @"activity";
NSString * const kStateMitigatorTotalCounterActivityRefresh				= @"activityRefresh";
NSString * const kStateMitigatorTotalCounterSearchUsername				= @"searchUsername";
NSString * const kStateMitigatorTotalCounterSearchContacts				= @"searchContacts";
NSString * const kStateMitigatorTotalCounterSearchContactsCountryCodes	= @"searchContactsCountryCodes";
NSString * const kStateMitigatorTotalCounterSupport						= @"support";
NSString * const kStateMitigatorTotalCounterLegal						= @"legal";
NSString * const kStateMitigatorTotalCounterNetworkStatus				= @"networkStatus";
NSString * const kStateMitigatorTotalCounterNetworkStatusRefresh		= @"networkStatusRefresh";
NSString * const kStateMitigatorTotalCounterShare						= @"share";


@interface HONStateMitigator ()
@end

@implementation HONStateMitigator
static HONStateMitigator *sharedInstance = nil;

+ (HONStateMitigator *)sharedInstance {
	static HONStateMitigator *s_sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		s_sharedInstance = [[self alloc] init];
	});
	
	return (s_sharedInstance);
}


- (int)incrementTotalCounterForType:(HONStateMitigatorTotalType)totalType {
	int tot = [[[NSUserDefaults standardUserDefaults] objectForKey:[self _keyForTotalType:totalType]] intValue];
	[[NSUserDefaults standardUserDefaults] setValue:@(++tot) forKey:[self _keyForTotalType:totalType]];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	return (tot);
}

- (void)resetTotalCounterForType:(HONStateMitigatorTotalType)totalType withValue:(int)value {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:[self _keyForTotalType:totalType]];
	
	[[NSUserDefaults standardUserDefaults] setValue:@(value) forKey:[self _keyForTotalType:totalType]];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)resetAllTotalCounters {
	[[self _totalKeyPrefixesForTypes] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:[key stringByAppendingString:kStateMitigatorTotalCounterKeySuffix]];
		[[NSUserDefaults standardUserDefaults] setValue:@(-1) forKey:[key stringByAppendingString:kStateMitigatorTotalCounterKeySuffix]];
	}];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)writeAppInstallTimestamp {
	[[NSUserDefaults standardUserDefaults] replaceObject:[[NSDate date] formattedISO8601StringUTC] forKey:kStateMitigatorInstallTimestampKey];
}

- (void)updateLastTrackingCallTimestamp:(NSDate *)date {
//	[[NSUserDefaults standardUserDefaults] setValue:date] forKey:kStateMitigatorTrackingTimestampKey];
	[[NSUserDefaults standardUserDefaults] setValue:[date formattedISO8601StringUTC] forKey:kStateMitigatorTrackingTimestampKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateAppEntryTimestamp:(NSDate *)date {
	[[NSUserDefaults standardUserDefaults] setValue:[date formattedISO8601StringUTC] forKey:kStateMitigatorEntryTimestampKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateAppExitTimestamp:(NSDate *)date {
	[[NSUserDefaults standardUserDefaults] setValue:[date formattedISO8601StringUTC] forKey:kStateMitigatorExitTimestampKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateAppEntryPoint:(HONStateMitigatorAppEntryType)appEntryType {
	[[NSUserDefaults standardUserDefaults] setValue:@((int)appEntryType) forKey:kStateMitigatorAppEntryKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateCurrentViewState:(HONStateMitigatorViewStateType)viewStateType {
	HONStateMitigatorViewStateType currentViewStateType = [[HONStateMitigator sharedInstance] currentViewStateType];
	if (currentViewStateType != [[HONStateMitigator sharedInstance] previousViewStateType]) {
		[[NSUserDefaults standardUserDefaults] setValue:@((int)currentViewStateType) forKey:kStateMitigatorPreviousViewKey];
		[[NSUserDefaults standardUserDefaults] setValue:@((int)viewStateType) forKey:kStateMitigatorCurrentViewKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}


- (HONStateMitigatorAppEntryType)appEntryType {
//	[[NSUserDefaults standardUserDefaults] setObject:@((int)HONStateMitigatorAppEntryTypeUnknown) forKey:kStateMitigatorAppEntryKey];
//	if ([[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorAppEntryKey] == nil)
//		[[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:kStateMitigatorAppEntryKey];
	
	return ((HONStateMitigatorAppEntryType)[[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorAppEntryKey]);
//	return ((HONStateMitigatorAppEntryType)[[NSUserDefaults standardUserDefaults] objectByReplacingNullKey:kStateMitigatorAppEntryKey withObject:@((int)HONStateMitigatorAppEntryTypeUnknown)]);
}

- (HONStateMitigatorViewStateType)currentViewStateType {
//	[[NSUserDefaults standardUserDefaults] setObject:@((int)HONStateMitigatorViewStateTypeUnknown) forKey:kStateMitigatorCurrentViewKey];
//	if ([[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorCurrentViewKey] == nil)
//		[[NSUserDefaults standardUserDefaults] setValue:@((int)HONStateMitigatorViewStateTypeUnknown) forKey:kStateMitigatorCurrentViewKey];
	
	return ((HONStateMitigatorViewStateType)[[[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorCurrentViewKey] intValue]);
//	return ((HONStateMitigatorViewStateType)[[NSUserDefaults standardUserDefaults] objectByReplacingNullKey:kStateMitigatorCurrentViewKey withObject:@((int)HONStateMitigatorViewStateTypeUnknown)]);
}

- (HONStateMitigatorViewStateType)previousViewStateType {
//	[[NSUserDefaults standardUserDefaults] setObject:@((int)HONStateMitigatorViewStateTypeUnknown) forKey:kStateMitigatorPreviousViewKey];
//	if ([[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorPreviousViewKey] == nil)
//		[[NSUserDefaults standardUserDefaults] setValue:@((int)HONStateMitigatorViewStateTypeUnknown) forKey:kStateMitigatorPreviousViewKey];
	
	return ((HONStateMitigatorViewStateType)[[[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorPreviousViewKey] intValue]);
//	return ((HONStateMitigatorViewStateType)[[NSUserDefaults standardUserDefaults] objectByReplacingNullKey:kStateMitigatorPreviousViewKey withObject:@((int)HONStateMitigatorViewStateTypeUnknown)]);
}


- (NSString *)appEntryTypeName {
	for (NSString *key in [[self _appEntryKeyNamesForTypes] keyEnumerator]) {
		if ((HONStateMitigatorAppEntryType)[[[self _appEntryKeyNamesForTypes] objectForKey:key] intValue] == (HONStateMitigatorAppEntryType)[[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorAppEntryKey]) {
			return (key);
			break;
		}
	}
	
	return (kStateMitigatorAppEntryNameUnknown);
}

- (NSString *)currentViewStateTypeName {
	for (NSString *key in [[self _viewStateKeyNamesForTypes] keyEnumerator]) {
		if ((HONStateMitigatorViewStateType)[[[self _viewStateKeyNamesForTypes] objectForKey:key] intValue] == [[HONStateMitigator sharedInstance] currentViewStateType]) {
			return (key);
			break;
		}
	}
	
	return (kStateMitigatorViewStateNameUnknown);
}

- (NSString *)previousViewStateTypeName {
	for (NSString *key in [[self _viewStateKeyNamesForTypes] keyEnumerator]) {
		if ((HONStateMitigatorViewStateType)[[[self _viewStateKeyNamesForTypes] objectForKey:key] intValue] == [[HONStateMitigator sharedInstance] previousViewStateType]) {
			return (key);
			break;
		}
	}
	
	return (kStateMitigatorViewStateNameUnknown);
}

- (NSDate *)appInstallTimestamp {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorInstallTimestampKey] == nil)
		[[HONStateMitigator sharedInstance] writeAppInstallTimestamp];
	
	return ([NSDate dateFromOrthodoxFormattedString:[[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorInstallTimestampKey]]);
}

- (NSDate *)appEntryTimestamp {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorEntryTimestampKey] == nil)
		[[HONStateMitigator sharedInstance] updateAppEntryTimestamp:[NSDate date]];
	
	return ([NSDate dateFromOrthodoxFormattedString:[[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorEntryTimestampKey]]);
}

- (NSDate *)appExitTimestamp {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorExitTimestampKey] == nil)
		[[HONStateMitigator sharedInstance] updateAppExitTimestamp:[NSDate date]];
	
	return ([NSDate dateFromOrthodoxFormattedString:[[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorExitTimestampKey]]);
}

- (NSDate *)lastTrackingCallTimestamp {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorTrackingTimestampKey] == nil)
		[[HONStateMitigator sharedInstance] updateLastTrackingCallTimestamp:[NSDate date]];
	
	return ([NSDate dateFromOrthodoxFormattedString:[[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorTrackingTimestampKey]]);
}

- (int)totalCounterForType:(HONStateMitigatorTotalType)totalType {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:[self _keyForTotalType:totalType]] intValue]);
}

- (NSDictionary *)_appEntryKeyNamesForTypes {
	return (@{kStateMitigatorAppEntryNameUnknown				: @(HONStateMitigatorAppEntryTypeUnknown),
			  kStateMitigatorAppEntryNameNotAvailable			: @(HONStateMitigatorAppEntryTypeNotAvailable),
			  kStateMitigatorAppEntryNameBoot					: @(HONStateMitigatorAppEntryTypeBoot),
			  kStateMitigatorAppEntryNameSpringboard			: @(HONStateMitigatorAppEntryTypeSpringboard),
			  kStateMitigatorAppEntryNameDeepLink				: @(HONStateMitigatorAppEntryTypeDeepLink),
			  kStateMitigatorAppEntryNameRemoteNotification		: @(HONStateMitigatorAppEntryTypeRemoteNotification),
			  kStateMitigatorAppEntryNameLocalNotification		: @(HONStateMitigatorAppEntryTypeLocalNotification)});
}

- (NSDictionary *)_viewStateKeyNamesForTypes {
	return (@{kStateMitigatorViewStateNameUnknown					: @(HONStateMitigatorViewStateTypeUnknown),
			  kStateMitigatorViewStateNameNotAvailable				: @(HONStateMitigatorViewStateTypeNotAvailable),
			  kStateMitigatorViewStateNameRegistration				: @(HONStateMitigatorViewStateTypeRegistration),
			  kStateMitigatorViewStateNameRegistrationCountryCodes	: @(HONStateMitigatorViewStateTypeRegistrationCountryCodes),
			  kStateMitigatorViewStateNamePINEntry					: @(HONStateMitigatorViewStateTypePINEntry),
			  kStateMitigatorViewStateNameHome						: @(HONStateMitigatorViewStateTypeHome),
			  kStateMitigatorViewStateNameFriends					: @(HONStateMitigatorViewStateTypeFriends),
			  kStateMitigatorViewStateNameStatusUpdate				: @(HONStateMitigatorViewStateTypeStatusUpdate),
			  kStateMitigatorViewStateNameSettings					: @(HONStateMitigatorViewStateTypeSettings),
			  kStateMitigatorViewStateNameCompose					: @(HONStateMitigatorViewStateTypeCompose),
			  kStateMitigatorViewStateNameAnimatedBGs				: @(HONStateMitigatorViewStateTypeAnimatedBGs),
			  kStateMitigatorViewStateNameStoreProducts				: @(HONStateMitigatorViewStateTypeStoreProducts),
			  kStateMitigatorViewStateNameStoreProductDetails		: @(HONStateMitigatorViewStateTypeStoreProductDetails),
			  kStateMitigatorViewStateNameComposeSubmit				: @(HONStateMitigatorViewStateTypeComposeSubmit),
			  kStateMitigatorViewStateNameActivity					: @(HONStateMitigatorViewStateTypeActivity),
			  kStateMitigatorViewStateNameSearchUsername			: @(HONStateMitigatorViewStateTypeSearchUsername),
			  kStateMitigatorViewStateNameSearchContact				: @(HONStateMitigatorViewStateTypeSearchContact),
			  kStateMitigatorViewStateNameSearchContactCountryCodes	: @(HONStateMitigatorViewStateTypeSearchContactCountryCodes),
			  kStateMitigatorViewStateNameSupport					: @(HONStateMitigatorViewStateTypeSupport),
			  kStateMitigatorViewStateNameLegal						: @(HONStateMitigatorViewStateTypeLegal),
			  kStateMitigatorViewStateNameNetworkStatus				: @(HONStateMitigatorViewStateTypeNetworkStatus)});
}

- (NSDictionary *)_totalKeyPrefixesForTypes {
	return (@{kStateMitigatorTotalCounterUnknown					: @(HONStateMitigatorTotalTypeUnknown),
			  kStateMitigatorTotalCounterBoot						: @(HONStateMitigatorTotalTypeBoot),
			  kStateMitigatorTotalCounterExit						: @(HONStateMitigatorTotalTypeExit),
			  kStateMitigatorTotalCounterResume						: @(HONStateMitigatorTotalTypeResume),
			  kStateMitigatorTotalCounterBackground					: @(HONStateMitigatorTotalTypeBackground),
			  kStateMitigatorTotalCounterRegistration				: @(HONStateMitigatorTotalTypeRegistration),
			  kStateMitigatorTotalCounterPINEntry					: @(HONStateMitigatorTotalTypePINEntry),
			  kStateMitigatorTotalCounterHomeTab					: @(HONStateMitigatorTotalTypeHomeTab),
			  kStateMitigatorTotalCounterHomeTabRefresh				: @(HONStateMitigatorTotalTypeHomeTabRefresh),
			  kStateMitigatorTotalCounterFriendsTab					: @(HONStateMitigatorTotalTypeFriendsTab),
			  kStateMitigatorTotalCounterFriendsTabRefresh			: @(HONStateMitigatorTotalTypeFriendsTabRefresh),
			  kStateMitigatorTotalCounterSettingsTab				: @(HONStateMitigatorTotalTypeSettingsTab),
			  kStateMitigatorTotalCounterStatusUpdate				: @(HONStateMitigatorTotalTypeStatusUpdate),
			  kStateMitigatorTotalCounterStatusUpdateRefresh		: @(HONStateMitigatorTotalTypeStatusUpdateRefresh),
			  kStateMitigatorTotalCounterReply						: @(HONStateMitigatorTotalTypeReply),
			  kStateMitigatorTotalCounterCompose					: @(HONStateMitigatorTotalTypeCompose),
			  kStateMitigatorTotalCounterComposeRefresh				: @(HONStateMitigatorTotalTypeComposeRefresh),
			  kStateMitigatorTotalCounterAnimatedBGs				: @(HONStateMitigatorTotalTypeAnimatedBGs),
			  kStateMitigatorTotalCounterAnimatedBGsRefresh			: @(HONStateMitigatorTotalTypeAnimatedBGsRefresh),
			  kStateMitigatorTotalCounterStoreProducts				: @(HONStateMitigatorTotalTypeStoreProducts),
			  kStateMitigatorTotalCounterStoreProductsRefresh		: @(HONStateMitigatorTotalTypeStoreProductsRefresh),
			  kStateMitigatorTotalCounterStoreProductDetails		: @(HONStateMitigatorTotalTypeStoreProductDetails),
			  kStateMitigatorTotalCounterStoreProductDetailsRefresh	: @(HONStateMitigatorTotalTypeStoreProductDetailsRefresh),
			  kStateMitigatorTotalCounterComposeSubmit				: @(HONStateMitigatorTotalTypeComposeSubmit),
			  kStateMitigatorTotalCounterComposeSubmitRefresh		: @(HONStateMitigatorTotalTypeComposeSubmitRefresh),
			  kStateMitigatorTotalCounterActivity					: @(HONStateMitigatorTotalTypeActivity),
			  kStateMitigatorTotalCounterActivityRefresh			: @(HONStateMitigatorTotalTypeActivityRefresh),
			  kStateMitigatorTotalCounterSearchUsername				: @(HONStateMitigatorTotalTypeSearchUsername),
			  kStateMitigatorTotalCounterSearchContacts				: @(HONStateMitigatorTotalTypeSearchContacts),
			  kStateMitigatorTotalCounterSupport					: @(HONStateMitigatorTotalTypeSupport),
			  kStateMitigatorTotalCounterLegal						: @(HONStateMitigatorTotalTypeLegal),
			  kStateMitigatorTotalCounterNetworkStatus				: @(HONStateMitigatorTotalTypeNetworkStatus),
			  kStateMitigatorTotalCounterNetworkStatusRefresh		: @(HONStateMitigatorTotalTypeNetworkStatusRefresh),
			  kStateMitigatorTotalCounterShare						: @(HONStateMitigatorTotalTypeShare),
			  kStateMitigatorTotalCounterTrackingCalls				: @(HONStateMitigatorTotalTypeTrackingCalls)});
}


- (HONStateMitigatorTotalType)_totalTypeForKey:(NSString *)key {
	__block HONStateMitigatorTotalType totalType = HONStateMitigatorTotalTypeUnknown;
	
	[[self _totalKeyPrefixesForTypes] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if ([key isEqualToString:(NSString *)key]) {
			totalType = (HONStateMitigatorTotalType)obj;
			*stop = YES;
		}
	}];
	
	return (totalType);
}

- (NSString *)_keyForTotalType:(HONStateMitigatorTotalType)totalType {
	__block NSString *keyName = kStateMitigatorTotalCounterUnknown;
	[[self _totalKeyPrefixesForTypes] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if ((HONStateMitigatorTotalType)[obj intValue] == totalType) {
			keyName = [(NSString *)key stringByAppendingString:kStateMitigatorTotalCounterKeySuffix];
			*stop = YES;
		}
	}];
	
	return (keyName);
}


@end
