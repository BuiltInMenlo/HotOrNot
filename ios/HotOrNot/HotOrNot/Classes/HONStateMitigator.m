//
//  HONStateMitigator.m
//  HotOrNot
//
//  Created by BIM  on 10/29/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

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
NSString * const kStateMitigatorViewStateNameFriends					= @"friends";
NSString * const kStateMitigatorViewStateNameSettings					= @"settings";
NSString * const kStateMitigatorViewStateNameTimeline					= @"timeline";
NSString * const kStateMitigatorViewStateNameCompose					= @"compose";
NSString * const kStateMitigatorViewStateNameAnimatedBGs				= @"animated_bgs";
NSString * const kStateMitigatorViewStateNameStickerStore				= @"sticker_store";
NSString * const kStateMitigatorViewStateNameStickerStoreDetails		= @"sticker_store_details";
NSString * const kStateMitigatorViewStateNameComposeSubmit				= @"compose_submit";
NSString * const kStateMitigatorViewStateNameSearchUsername				= @"search_username";
NSString * const kStateMitigatorViewStateNameSearchContact				= @"search_contact";
NSString * const kStateMitigatorViewStateNameSearchContactCountryCodes	= @"search_contact_country_codes";
NSString * const kStateMitigatorViewStateNameSupport					= @"support";
NSString * const kStateMitigatorViewStateNameLegal						= @"legal";
NSString * const kStateMitigatorViewStateNameNetworkStatus				= @"network_status";

NSString * const kStateMitigatorTotalCounterName							= @"";
NSString * const kStateMitigatorTotalCounterNameUnknown						= @"UNKNOWN";
NSString * const kStateMitigatorTotalCounterNameTrackingCalls				= @"tracking";
NSString * const kStateMitigatorTotalCounterNameBoot						= @"boot";
NSString * const kStateMitigatorTotalCounterNameExit						= @"exit";
NSString * const kStateMitigatorTotalCounterNameResume						= @"resume";
NSString * const kStateMitigatorTotalCounterNameBackground					= @"background";
NSString * const kStateMitigatorTotalCounterNameRegistration				= @"registration";
NSString * const kStateMitigatorTotalCounterNameRegistrationCountryCodes	= @"registrationCountryCodes";
NSString * const kStateMitigatorTotalCounterNamePINEntry					= @"pinEntry";
NSString * const kStateMitigatorTotalCounterNameFriendsTab					= @"friendsTab";
NSString * const kStateMitigatorTotalCounterNameFriendsTabRefresh			= @"friendsTabRefresh";
NSString * const kStateMitigatorTotalCounterNameSettingsTab					= @"settingsTab";
NSString * const kStateMitigatorTotalCounterNameTimeline					= @"timeline";
NSString * const kStateMitigatorTotalCounterNameTimelineRefresh				= @"timelineRefresh";
NSString * const kStateMitigatorTotalCounterNameReply						= @"reply";
NSString * const kStateMitigatorTotalCounterNameCompose						= @"compose";
NSString * const kStateMitigatorTotalCounterNameAnimatedBGs					= @"animatedBGs";
NSString * const kStateMitigatorTotalCounterNameAnimatedBGsRefresh			= @"animatedBGsRefresh";
NSString * const kStateMitigatorTotalCounterNameStickerStore				= @"stickerStore";
NSString * const kStateMitigatorTotalCounterNameStickerStoreRefresh			= @"stickerStoreRefresh";
NSString * const kStateMitigatorTotalCounterNameStickerStoreDetails			= @"stickerStoreDetails";
NSString * const kStateMitigatorTotalCounterNameStickerStoreDetailsRefresh	= @"stickerStoreDetailsRefresh";
NSString * const kStateMitigatorTotalCounterNameComposeSubmit				= @"composeSubmit";
NSString * const kStateMitigatorTotalCounterNameComposeSubmitRefresh		= @"composeSubmitRefresh";
NSString * const kStateMitigatorTotalCounterNameSearchUsername				= @"searchUsername";
NSString * const kStateMitigatorTotalCounterNameSearchContacts				= @"searchContacts";
NSString * const kStateMitigatorTotalCounterNameSearchContactsCountryCodes	= @"searchContactsCountryCodes";
NSString * const kStateMitigatorTotalCounterNameSupport						= @"support";
NSString * const kStateMitigatorTotalCounterNameLegal						= @"legal";
NSString * const kStateMitigatorTotalCounterNameNetworkStatus				= @"networkStatus";
NSString * const kStateMitigatorTotalCounterNameNetworkStatusRefresh		= @"networkStatusRefresh";
NSString * const kStateMitigatorTotalCounterNameShare						= @"share";


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
	//int tot = (int)[[NSUserDefaults standardUserDefaults] objectByReplacingNullKey:[self _keyForTotalType:totalType] withObject:@(0)];
	int tot = [[[NSUserDefaults standardUserDefaults] objectForKey:[self _keyForTotalType:totalType]] intValue];
	[[NSUserDefaults standardUserDefaults] setValue:@(++tot) forKey:[self _keyForTotalType:totalType]];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	return (tot);
}

- (void)resetTotalCounterForType:(HONStateMitigatorTotalType)totalType withValue:(int)value {
//	if ([[NSUserDefaults standardUserDefaults] objectForKey:[self _keyForTotalType:totalType]] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForExistingKey:[self _keyForTotalType:totalType]];
	
	[[NSUserDefaults standardUserDefaults] setValue:@(value) forKey:[self _keyForTotalType:totalType]];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)resetAllTotalCounters {
	[[self _totalKeyPrefixesForTypes] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//		if ([[NSUserDefaults standardUserDefaults] objectForKey:[key stringByAppendingString:kStateMitigatorTotalCounterKeySuffix]] != nil) {
			[[NSUserDefaults standardUserDefaults] removeObjectForExistingKey:[key stringByAppendingString:kStateMitigatorTotalCounterKeySuffix]];
//			[[NSUserDefaults standardUserDefaults] synchronize];
//		}
		
		[[NSUserDefaults standardUserDefaults] setValue:@(-1) forKey:[key stringByAppendingString:kStateMitigatorTotalCounterKeySuffix]];
	}];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)writeAppInstallTimestamp {
//	[[NSUserDefaults standardUserDefaults] setValue:[[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[NSDate date]] forKey:kStateMitigatorInstallTimestampKey];
//	[[NSUserDefaults standardUserDefaults] synchronize];
	[[NSUserDefaults standardUserDefaults] replaceObject:[[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[NSDate date]] forExistingKey:kStateMitigatorInstallTimestampKey];
}

- (void)updateLastTrackingCallTimestamp:(NSDate *)date {
	[[NSUserDefaults standardUserDefaults] setValue:[[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:date] forKey:kStateMitigatorTrackingTimestampKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateAppEntryTimestamp:(NSDate *)date {
	[[NSUserDefaults standardUserDefaults] setValue:[[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:date] forKey:kStateMitigatorEntryTimestampKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateAppExitTimestamp:(NSDate *)date {
	[[NSUserDefaults standardUserDefaults] setValue:[[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:date] forKey:kStateMitigatorExitTimestampKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateAppEntryPoint:(HONStateMitigatorAppEntryType)appEntryType {
	[[NSUserDefaults standardUserDefaults] setValue:@((int)appEntryType) forKey:kStateMitigatorAppEntryKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateCurrentViewState:(HONStateMitigatorViewStateType)viewStateType {
	HONStateMitigatorViewStateType currentViewStateType = [[HONStateMitigator sharedInstance] currentViewStateType];
	
	[[NSUserDefaults standardUserDefaults] setValue:@((int)currentViewStateType) forKey:kStateMitigatorPreviousViewKey];
	[[NSUserDefaults standardUserDefaults] setValue:@((int)viewStateType) forKey:kStateMitigatorCurrentViewKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


- (HONStateMitigatorAppEntryType)appEntryType {
	[[NSUserDefaults standardUserDefaults] setObject:@((int)HONStateMitigatorAppEntryTypeUnknown) forNonExistingKey:kStateMitigatorAppEntryKey];
//	if ([[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorAppEntryKey] == nil)
//		[[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:kStateMitigatorAppEntryKey];
	
	return ((HONStateMitigatorAppEntryType)[[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorAppEntryKey]);
//	return ((HONStateMitigatorAppEntryType)[[NSUserDefaults standardUserDefaults] objectByReplacingNullKey:kStateMitigatorAppEntryKey withObject:@((int)HONStateMitigatorAppEntryTypeUnknown)]);
}

- (HONStateMitigatorViewStateType)currentViewStateType {
	[[NSUserDefaults standardUserDefaults] setObject:@((int)HONStateMitigatorViewStateTypeUnknown) forNonExistingKey:kStateMitigatorCurrentViewKey];
//	if ([[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorCurrentViewKey] == nil)
//		[[NSUserDefaults standardUserDefaults] setValue:@((int)HONStateMitigatorViewStateTypeUnknown) forKey:kStateMitigatorCurrentViewKey];
	
	return ((HONStateMitigatorViewStateType)[[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorCurrentViewKey]);
//	return ((HONStateMitigatorViewStateType)[[NSUserDefaults standardUserDefaults] objectByReplacingNullKey:kStateMitigatorCurrentViewKey withObject:@((int)HONStateMitigatorViewStateTypeUnknown)]);
}

- (HONStateMitigatorViewStateType)previousViewStateType {
	[[NSUserDefaults standardUserDefaults] setObject:@((int)HONStateMitigatorViewStateTypeUnknown) forNonExistingKey:kStateMitigatorPreviousViewKey];
//	if ([[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorPreviousViewKey] == nil)
//		[[NSUserDefaults standardUserDefaults] setValue:@((int)HONStateMitigatorViewStateTypeUnknown) forKey:kStateMitigatorPreviousViewKey];
	
	return ((HONStateMitigatorViewStateType)[[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorPreviousViewKey]);
//	return ((HONStateMitigatorViewStateType)[[NSUserDefaults standardUserDefaults] objectByReplacingNullKey:kStateMitigatorPreviousViewKey withObject:@((int)HONStateMitigatorViewStateTypeUnknown)]);
}


- (NSString *)appEntryTypeName {
	for (NSString *key in [[self _appEntryKeyNamesForTypes] keyEnumerator]) {
//		if ((HONStateMitigatorAppEntryType)[[self _appEntryKeyNamesForTypes] objectForKey:key] == (HONStateMitigatorAppEntryType)[[NSUserDefaults standardUserDefaults] objectByReplacingNullKey:kStateMitigatorAppEntryKey withObject:@((int)HONStateMitigatorAppEntryTypeUnknown)]) {
		if ((HONStateMitigatorAppEntryType)[[self _appEntryKeyNamesForTypes] objectForKey:key] == (HONStateMitigatorAppEntryType)[[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorAppEntryKey]) {
			return (key);
			break;
		}
	}
	
	return (kStateMitigatorAppEntryNameUnknown);
}

- (NSString *)currentViewStateTypeName {
	for (NSString *key in [[self _viewStateKeyNamesForTypes] keyEnumerator]) {
		if ((HONStateMitigatorViewStateType)[[self _viewStateKeyNamesForTypes] objectForKey:key] == [[HONStateMitigator sharedInstance] currentViewStateType]) {
			return (key);
			break;
		}
	}
	
	return (kStateMitigatorViewStateNameUnknown);
}

- (NSString *)previousViewStateTypeName {
	for (NSString *key in [[self _viewStateKeyNamesForTypes] keyEnumerator]) {
		if ((HONStateMitigatorViewStateType)[[self _viewStateKeyNamesForTypes] objectForKey:key] == [[HONStateMitigator sharedInstance] previousViewStateType]) {
			return (key);
			break;
		}
	}
	
	return (kStateMitigatorViewStateNameUnknown);
}

- (NSDate *)appInstallTimestamp {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorInstallTimestampKey] == nil)
		[[HONStateMitigator sharedInstance] writeAppInstallTimestamp];
	
	return ([[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorInstallTimestampKey]]);
//	return ([[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[[NSUserDefaults standardUserDefaults] objectByReplacingNullKey:kStateMitigatorInstallTimestampKey withObject:[[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[NSDate date]]]]);
}

- (NSDate *)appEntryTimestamp {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorEntryTimestampKey] == nil)
		[[HONStateMitigator sharedInstance] updateAppEntryTimestamp:[NSDate date]];
	
	return ([[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorEntryTimestampKey]]);
//	return ([[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[[NSUserDefaults standardUserDefaults] objectByReplacingNullKey:kStateMitigatorEntryTimestampKey withObject:[[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[NSDate date]]]]);
}

- (NSDate *)appExitTimestamp {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorExitTimestampKey] == nil)
		[[HONStateMitigator sharedInstance] updateAppExitTimestamp:[NSDate date]];
	
//	return ([[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[[NSUserDefaults standardUserDefaults] objectByReplacingNullKey:kStateMitigatorExitTimestampKey withObject:[[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[NSDate date]]]]);
	return ([[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorExitTimestampKey]]);
}

- (NSDate *)lastTrackingCallTimestamp {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorTrackingTimestampKey] == nil)
		[[HONStateMitigator sharedInstance] updateLastTrackingCallTimestamp:[NSDate date]];
	
//	return ([[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[[NSUserDefaults standardUserDefaults] objectByReplacingNullKey:kStateMitigatorTrackingTimestampKey withObject:[[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[NSDate date]]]]);
	return ([[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[[NSUserDefaults standardUserDefaults] objectForKey:kStateMitigatorTrackingTimestampKey]]);
}

- (int)totalCounterForType:(HONStateMitigatorTotalType)totalType {
//	return ((int)[[NSUserDefaults standardUserDefaults] objectByReplacingNullKey:[self _keyForTotalType:totalType] withObject:@(0)]);
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
			  kStateMitigatorViewStateNameFriends					: @(HONStateMitigatorViewStateTypeFriends),
			  kStateMitigatorViewStateNameTimeline					: @(HONStateMitigatorViewStateTypeTimeline),
			  kStateMitigatorViewStateNameSettings					: @(HONStateMitigatorViewStateTypeSettings),
			  kStateMitigatorViewStateNameCompose					: @(HONStateMitigatorViewStateTypeCompose),
			  kStateMitigatorViewStateNameAnimatedBGs				: @(HONStateMitigatorViewStateTypeAnimatedBGs),
			  kStateMitigatorViewStateNameStickerStore				: @(HONStateMitigatorViewStateTypeStickerStore),
			  kStateMitigatorViewStateNameStickerStoreDetails		: @(HONStateMitigatorViewStateTypeStickerStoreDetails),
			  kStateMitigatorViewStateNameComposeSubmit				: @(HONStateMitigatorViewStateTypeComposeSubmit),
			  kStateMitigatorViewStateNameSearchUsername			: @(HONStateMitigatorViewStateTypeSearchUsername),
			  kStateMitigatorViewStateNameSearchContact				: @(HONStateMitigatorViewStateTypeSearchContact),
			  kStateMitigatorViewStateNameSearchContactCountryCodes	: @(HONStateMitigatorViewStateTypeSearchContactCountryCodes),
			  kStateMitigatorViewStateNameSupport					: @(HONStateMitigatorViewStateTypeSupport),
			  kStateMitigatorViewStateNameLegal						: @(HONStateMitigatorViewStateTypeLegal),
			  kStateMitigatorViewStateNameNetworkStatus				: @(HONStateMitigatorViewStateTypeNetworkStatus)});
}

- (NSDictionary *)_totalKeyPrefixesForTypes {
	return (@{kStateMitigatorTotalCounterNameUnknown				: @(HONStateMitigatorTotalTypeUnknown),
			  kStateMitigatorTotalCounterNameBoot					: @(HONStateMitigatorTotalTypeBoot),
			  kStateMitigatorTotalCounterNameExit					: @(HONStateMitigatorTotalTypeExit),
			  kStateMitigatorTotalCounterNameResume					: @(HONStateMitigatorTotalTypeResume),
			  kStateMitigatorTotalCounterNameBackground				: @(HONStateMitigatorTotalTypeBackground),
			  kStateMitigatorTotalCounterNameRegistration			: @(HONStateMitigatorTotalTypeRegistration),
			  kStateMitigatorTotalCounterNamePINEntry				: @(HONStateMitigatorTotalTypePINEntry),
			  kStateMitigatorTotalCounterNameFriendsTab				: @(HONStateMitigatorTotalTypeFriendsTab),
			  kStateMitigatorTotalCounterNameFriendsTabRefresh		: @(HONStateMitigatorTotalTypeFriendsTabRefresh),
			  kStateMitigatorTotalCounterNameSettingsTab			: @(HONStateMitigatorTotalTypeSettingsTab),
			  kStateMitigatorTotalCounterNameTimeline				: @(HONStateMitigatorTotalTypeTimeline),
			  kStateMitigatorTotalCounterNameTimelineRefresh		: @(HONStateMitigatorTotalTypeTimelineRefresh),
			  kStateMitigatorTotalCounterNameReply					: @(HONStateMitigatorTotalTypeReply),
			  kStateMitigatorTotalCounterNameCompose				: @(HONStateMitigatorTotalTypeCompose),
			  kStateMitigatorTotalCounterNameAnimatedBGs			: @(HONStateMitigatorTotalTypeAnimatedBGs),
			  kStateMitigatorTotalCounterNameAnimatedBGsRefresh		: @(HONStateMitigatorTotalTypeAnimatedBGsRefresh),
			  kStateMitigatorTotalCounterNameStickerStore			: @(HONStateMitigatorTotalTypeStickerStore),
			  kStateMitigatorTotalCounterNameStickerStoreRefresh	: @(HONStateMitigatorTotalTypeStickerStoreRefresh),
			  kStateMitigatorTotalCounterNameStickerStoreDetails	: @(HONStateMitigatorTotalTypeStickerStoreDetails),
			  kStateMitigatorTotalCounterNameStickerStoreDetailsRefresh	: @(HONStateMitigatorTotalTypeStickerStoreDetailsRefresh),
			  kStateMitigatorTotalCounterNameComposeSubmit			: @(HONStateMitigatorTotalTypeComposeSubmit),
			  kStateMitigatorTotalCounterNameComposeSubmitRefresh	: @(HONStateMitigatorTotalTypeComposeSubmitRefresh),
			  kStateMitigatorTotalCounterNameSearchUsername			: @(HONStateMitigatorTotalTypeSearchUsername),
			  kStateMitigatorTotalCounterNameSearchContacts			: @(HONStateMitigatorTotalTypeSearchContacts),
			  kStateMitigatorTotalCounterNameSupport				: @(HONStateMitigatorTotalTypeSupport),
			  kStateMitigatorTotalCounterNameLegal					: @(HONStateMitigatorTotalTypeLegal),
			  kStateMitigatorTotalCounterNameNetworkStatus			: @(HONStateMitigatorTotalTypeNetworkStatus),
			  kStateMitigatorTotalCounterNameNetworkStatusRefresh	: @(HONStateMitigatorTotalTypeNetworkStatusRefresh),
			  kStateMitigatorTotalCounterNameShare					: @(HONStateMitigatorTotalTypeShare),
			  kStateMitigatorTotalCounterNameTrackingCalls			: @(HONStateMitigatorTotalTypeTrackingCalls)});
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
	__block NSString *keyName = kStateMitigatorTotalCounterNameUnknown;
	[[self _totalKeyPrefixesForTypes] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if ((HONStateMitigatorTotalType)key == totalType) {
			keyName = [(NSString *)key stringByAppendingString:kStateMitigatorTotalCounterKeySuffix];
			*stop = YES;
		}
	}];
	
	return (keyName);
}


@end
