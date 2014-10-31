//
//  HONAnalyticsReporter.m
//  HotOrNot
//
//  Created by Matt Holcombe on 02/22/2014 @ 13:43 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONAnalyticsReporter.h"


#if __APPSTORE_BUILD__ == 1
NSString * const kKeenIOEventCollection = @"iOS - Live";
#else
NSString * const kKeenIOEventCollection = @"iOS - DEV";
#endif


@implementation HONAnalyticsReporter
static HONAnalyticsReporter *sharedInstance = nil;

+ (HONAnalyticsReporter *)sharedInstance {
	static HONAnalyticsReporter *s_sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		s_sharedInstance = [[self alloc] init];
	});
	
	return (s_sharedInstance);
}

- (id)init {
	if ((self = [super init])) {
		[KeenClient disableGeoLocation];
	}
	
	return (self);
}


- (NSDictionary *)orthodoxProperties {
	return (@{@"user"			: [[HONAnalyticsReporter sharedInstance] userProperties],
			  @"device"			: [[HONAnalyticsReporter sharedInstance] deviceProperties],
			  @"session"		: [[HONAnalyticsReporter sharedInstance] sessionProperties],
			  @"application"	: [[HONAnalyticsReporter sharedInstance] applicationProperties],
			  @"screen_state"	: [[HONAnalyticsReporter sharedInstance] screenStateProperties]});
}

- (NSDictionary *)applicationProperties {
	return (@{@"version"		: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
			  @"build"			: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
			  @"service_env"	: ([HONAppDelegate apiServerPath] != nil) ? ([[HONAppDelegate apiServerPath] rangeOfString:@"devint"].location != NSNotFound) ? @"devint" : @"prod" : @"N/A",
			  @"api_release"	: ([HONAppDelegate apiServerPath] != nil) ? [[[HONAppDelegate apiServerPath] componentsSeparatedByString:@"/"] lastObject] : @"N/A"});
}

- (NSDictionary *)deviceProperties {
	return (@{@"os"				: [[HONDeviceIntrinsics sharedInstance] osName],
			  @"os_version"		: [[HONDeviceIntrinsics sharedInstance] osVersion],
			  @"hardware_make"	: [[[HONDeviceIntrinsics sharedInstance] modelName] substringToIndex:[[[HONDeviceIntrinsics sharedInstance] modelName] length] - 3],
			  @"hardware_model"	: [[[HONDeviceIntrinsics sharedInstance] modelName] substringFromIndex:[[[HONDeviceIntrinsics sharedInstance] modelName] length] - 3],
			  @"resolution"		: NSStringFromCGSize([UIScreen mainScreen].bounds.size),
			  @"adid"			: [[HONDeviceIntrinsics sharedInstance] uniqueIdentifierWithoutSeperators:NO],
			  @"push_token"		: [[HONDeviceIntrinsics sharedInstance] pushToken],
			  @"locale"			: [[[HONDeviceIntrinsics sharedInstance] locale] uppercaseString],
			  @"time"			: [[HONDateTimeAlloter sharedInstance] utcNowDateFormattedISO8601],
			  @"tz"				: [[HONDateTimeAlloter sharedInstance] utcHourOffsetFromDeviceLocale],
			  @"battery_per"	: [NSString stringWithFormat:@"%.02f%%", ([UIDevice currentDevice].batteryLevel * 100.0)],
			  @"hmac"			: [[HONDeviceIntrinsics sharedInstance] hmacToken]});
}

- (NSDictionary *)screenStateProperties {
	return (@{@"current"	: [[HONStateMitigator sharedInstance] currentViewStateTypeName],
			  @"previous"	: [[HONStateMitigator sharedInstance] previousViewStateTypeName]});
}

- (NSDictionary *)sessionProperties {
	NSDate *nowDate = [NSDate date];
	
	return (@{@"id"				: @"0",
			  @"id_last"		: @"0",
			  @"session_gap"	: [@"" stringFromInt:[[[HONStateMitigator sharedInstance] appEntryTimestamp] timeIntervalSinceDate:[[HONStateMitigator sharedInstance] appExitTimestamp]]],
			  @"duration"		: [@"" stringFromInt:[nowDate timeIntervalSinceDate:[[HONStateMitigator sharedInstance] appEntryTimestamp]]],
			  @"idle"			: [@"" stringFromInt:[nowDate timeIntervalSinceDate:[[HONStateMitigator sharedInstance] lastTrackingCallTimestamp]]],
			  @"count"			: [@"" stringFromInt:[[HONStateMitigator sharedInstance] totalCounterForType:HONStateMitigatorTotalTypeTrackingCalls]],
			  @"entry_point"	: [[HONStateMitigator sharedInstance] appEntryTypeName]});
}

- (NSDictionary *)userProperties {
	NSDate *cohortDate = ([[HONAppDelegate infoForUser] objectForKey:@"added"] != nil) ? [[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[[HONAppDelegate infoForUser] objectForKey:@"added"]] : [[HONDateTimeAlloter sharedInstance] utcNowDate];
	
	return(@{@"id"			: ([[HONAppDelegate infoForUser] objectForKey:@"id"] != nil) ? [[HONAppDelegate infoForUser] objectForKey:@"id"] : @"0",
			 @"name"		: ([[HONAppDelegate infoForUser] objectForKey:@"username"] != nil) ? [[HONAppDelegate infoForUser] objectForKey:@"username"] : @"",
			 @"phone"		: [[HONDeviceIntrinsics sharedInstance] phoneNumber],
			 @"cohort_date"	: [[HONDateTimeAlloter sharedInstance] ISO8601FormattedStringFromUTCDate:cohortDate],
			 @"cohort_week"	: [NSString stringWithFormat:@"%04d-%02d", [[HONDateTimeAlloter sharedInstance] yearFromDate:cohortDate], [[HONDateTimeAlloter sharedInstance] weekOfYearFromDate:cohortDate]]});
}

- (NSDictionary *)propertyForActivityItem:(HONActivityItemVO *)vo {
	return (@{@"activity"	: [NSString stringWithFormat:@"%@ - %d", vo.activityID, vo.activityType]});
}

- (NSDictionary *)propertyForCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice {
	return (@{@"camera"	: (cameraDevice == UIImagePickerControllerCameraDeviceFront) ? @"front" : @"rear"});
}

- (NSDictionary *)propertyForClubPhoto:(HONClubPhotoVO *)vo {
	return (@{@"photo"	: @{@"id"		: [@"" stringFromInt:vo.challengeID],
							@"club_id"	: [@"" stringFromInt:vo.clubID],
							@"user_id"	: [@"" stringFromInt:vo.userID],
							@"username"	: vo.username,
							@"img"		: vo.imagePrefix}});
}

- (NSDictionary *)propertyForContactUser:(HONContactUserVO *)vo {
	return (@{@"contact"	: @{@"name"		: vo.fullName,
								@"is_sms"	: [@"" stringFromBOOL:vo.isSMSAvailable],
								@"phone"	: vo.mobileNumber,
								@"email"	: vo.email}});
}

- (NSDictionary *)propertyForEmotion:(HONEmotionVO *)vo {
	return (@{@"emotion"	: @{@"id"		: (vo.emotionID != nil) ? vo.emotionID : @"",
								@"name"		: (vo.emotionName != nil) ? vo.emotionName : @"",
								@"cg_id"	: (vo.contentGroupID != nil) ? vo.contentGroupID : @"",
								@"url"		: (vo.urlPrefix != nil) ? vo.urlPrefix : @""}});
}

- (NSDictionary *)propertyForStoreProduct:(HONStoreProductVO *)vo {
	return (@{@"product"	: @{@"id"		: vo.productID,
								@"name"		: vo.productName,
								@"price"	: [@"" stringFromFloat:vo.price]}});
}

- (NSDictionary *)propertyForTrivialUser:(HONTrivialUserVO *)vo {
	return (@{@"member"	: @{@"id"		: [@"" stringFromInt:vo.userID],
							@"username"	: vo.username,
							@"avatar"	: vo.avatarPrefix}});
}

- (NSDictionary *)propertyForUserClub:(HONUserClubVO *)vo {
	return (@{@"club"	: @{@"id"		: [@"" stringFromInt:vo.clubID],
							@"name"		: vo.clubName,
							@"owner_id"	: [@"" stringFromInt:vo.ownerID],
							@"created"	: [[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:vo.addedDate]}});
}


- (void)trackEvent:(NSString *)event {
	[[HONAnalyticsReporter sharedInstance] trackEvent:event
									 withProperties:[[HONAnalyticsReporter sharedInstance] orthodoxProperties]];
}


#pragma mark -
- (void)trackEvent:(NSString *)event withProperties:(NSDictionary *)properties {
	[[HONStateMitigator sharedInstance] incrementTotalCounterForType:HONStateMitigatorTotalTypeTrackingCalls];
	
	NSString *eventCollection = [[event componentsSeparatedByString:@" - "] firstObject];
	NSMutableDictionary *eventName = (properties == nil) ? [[NSMutableDictionary alloc] init] : [properties mutableCopy];
	[eventName addEntriesFromDictionary:[[HONAnalyticsReporter sharedInstance] orthodoxProperties]];
	[eventName addEntriesFromDictionary:@{@"action"	: [[event componentsSeparatedByString:@" - "] lastObject]}];
	
	
	NSLog(@"TRACK EVENT:[%@] (%@)", [kKeenIOEventCollection stringByAppendingFormat:@" : %@", eventCollection], eventName);
	
	
	NSError *error = nil;
	[[KeenClient sharedClient] addEvent:eventName
					  toEventCollection:[kKeenIOEventCollection stringByAppendingFormat:@" : %@", eventCollection]
								  error:&error];
	
	[[HONStateMitigator sharedInstance] updateLastTrackingCallTimestamp:[NSDate date]];
}

#pragma mark -


- (void)trackEvent:(NSString *)event withActivityItem:(HONActivityItemVO *)activityItemVO {
	NSMutableDictionary *properties = [[[HONAnalyticsReporter sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsReporter sharedInstance] propertyForActivityItem:activityItemVO]];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:event
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)event withCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice {
	NSMutableDictionary *properties = [[[HONAnalyticsReporter sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsReporter sharedInstance] propertyForCameraDevice:cameraDevice]];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:event
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)event withClubPhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSMutableDictionary *properties = [[[HONAnalyticsReporter sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsReporter sharedInstance] propertyForClubPhoto:clubPhotoVO]];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:event
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)event withContactUser:(HONContactUserVO *)contactUserVO {
	NSMutableDictionary *properties = [[[HONAnalyticsReporter sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsReporter sharedInstance] propertyForContactUser:contactUserVO]];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:event
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)event withEmotion:(HONEmotionVO *)emotionVO {
	NSMutableDictionary *properties = [[[HONAnalyticsReporter sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsReporter sharedInstance] propertyForEmotion:emotionVO]];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:event
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)event withStoreProduct:(HONStoreProductVO *)storeProductVO {
	NSMutableDictionary *properties = [[[HONAnalyticsReporter sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsReporter sharedInstance] propertyForStoreProduct:storeProductVO]];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:event
									   withProperties:properties];
}

- (void)trackEvent:(NSString *)event withTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	NSMutableDictionary *properties = [[[HONAnalyticsReporter sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsReporter sharedInstance] propertyForTrivialUser:trivialUserVO]];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:event
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)event withUserClub:(HONUserClubVO *)userClubVO {
	NSMutableDictionary *properties = [[[HONAnalyticsReporter sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsReporter sharedInstance] propertyForUserClub:userClubVO]];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:event
									 withProperties:properties];
}


- (void)forceAnalyticsUpload {
	[[KeenClient sharedClient] uploadWithFinishedBlock:nil];
}

- (void)refreshLocation {
	[[KeenClient sharedClient] refreshCurrentLocation];
}


@end
