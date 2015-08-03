//
//  HONAnalyticsReporter.m
//  HotOrNot
//
//  Created by Matt Holcombe on 02/22/2014 @ 13:43 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

#import "NSDate+BuiltinMenlo.h"

#import "HONAnalyticsReporter.h"

//NSString * const kAnalyticsCohort = @"0714Cohort";
//NSString * const kAnalyticsCohort = @"Popup Enterprise";
NSString * const kAnalyticsCohort = @"DEV";

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
			  @"device"			: [[HONAnalyticsReporter sharedInstance] deviceProperties]});
//			  @"location"		: [[HONAnalyticsReporter sharedInstance] locationProperties],
//			  @"session"		: [[HONAnalyticsReporter sharedInstance] sessionProperties],
//			  @"application"	: [[HONAnalyticsReporter sharedInstance] applicationProperties]});//,
//			  @"screen_state"	: [[HONAnalyticsReporter sharedInstance] screenStateProperties]});
}

- (NSDictionary *)applicationProperties {
	return (@{});
//	return (@{@"sku"			: [[NSBundle mainBundle] bundleIdentifier]});//,
//			  @"version"		: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
//			  @"build"			: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
//			  @"service_env"	: ([HONAppDelegate apiServerPath] != nil) ? ([[HONAppDelegate apiServerPath] rangeOfString:@"devint"].location != NSNotFound) ? @"devint" : @"prod" : @"N/A",
//			  @"api_release"	: ([HONAppDelegate apiServerPath] != nil) ? [[[HONAppDelegate apiServerPath] componentsSeparatedByString:@"/"] lastObject] : @"N/A"});
}

- (NSDictionary *)deviceProperties {
	return (@{@"platform"			: [[HONDeviceIntrinsics sharedInstance] osName],
			  @"platform_version"	: [[HONDeviceIntrinsics sharedInstance] osVersion],
			  @"hardware_make"		: [[[HONDeviceIntrinsics sharedInstance] modelName] substringToIndex:[[[HONDeviceIntrinsics sharedInstance] modelName] length] - 3],
			  @"hardware_model"		: [[[HONDeviceIntrinsics sharedInstance] modelName] substringFromIndex:[[[HONDeviceIntrinsics sharedInstance] modelName] length] - 3],
			  @"sku"				: [[[[NSBundle mainBundle] bundleIdentifier] componentsSeparatedByString:@"."] lastObject]});
//			  @"resolution"		: NSStringFromCGSize([UIScreen mainScreen].bounds.size),
//			  @"os"				: [[HONDeviceIntrinsics sharedInstance] osName],
//			  @"os_version"		: [[HONDeviceIntrinsics sharedInstance] osVersion],
//			  @"adid"			: [[HONDeviceIntrinsics sharedInstance] uniqueIdentifierWithoutSeperators:NO],
//			  @"push_token"		: [[HONDeviceIntrinsics sharedInstance] pushToken],
//			  @"locale"			: [[[HONDeviceIntrinsics sharedInstance] locale] uppercaseString],
//			  @"time"			: [[NSDate utcNowDate] formattedISO8601String],
//			  @"tz"				: [[NSDate date] utcHourOffsetFromDeviceLocale],
//			  @"latitude"		: [NSString stringWithFormat:@"%.04f", [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude],
//			  @"longitude"		: [NSString stringWithFormat:@"%.04f", [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude],
//			  @"battery_per"	: [NSString stringWithFormat:@"%.02f", ([UIDevice currentDevice].batteryLevel * 100.0)],
//			  @"hmac"			: [[HONDeviceIntrinsics sharedInstance] hmacToken]});
}


- (NSDictionary *)locationProperties {
	CLLocation *location = [[HONDeviceIntrinsics sharedInstance] deviceLocation];
	return (@{@"latitude"	: @(location.coordinate.latitude),
			  @"longitude"	: @(location.coordinate.longitude)});
}

- (NSDictionary *)screenStateProperties {
	return (@{@"current"	: [[HONStateMitigator sharedInstance] currentViewStateTypeName],
			  @"previous"	: [[HONStateMitigator sharedInstance] previousViewStateTypeName]});
}

- (NSDictionary *)sessionProperties {
	NSDate *nowDate = [NSDate date];
	
	return (@{@"id"				: @"0",
			  @"id_last"		: @"0",
			  @"session_gap"	: @([[[HONStateMitigator sharedInstance] appEntryTimestamp] timeIntervalSinceDate:[[HONStateMitigator sharedInstance] appExitTimestamp]]),
			  @"duration"		: @([nowDate timeIntervalSinceDate:[[HONStateMitigator sharedInstance] appEntryTimestamp]]),
			  @"idle"			: @([nowDate timeIntervalSinceDate:[[HONStateMitigator sharedInstance] lastTrackingCallTimestamp]]),
			  @"count"			: @([[HONStateMitigator sharedInstance] totalCounterForType:HONStateMitigatorTotalTypeTrackingCalls]),
			  @"entry_point"	: [[HONStateMitigator sharedInstance] appEntryTypeName]});
}

- (NSDictionary *)userProperties {
	NSDate *cohortDate = [[HONUserAssistant sharedInstance] activeUserSignupDate];
	
	return(@{@"identifier"	: ([[HONUserAssistant sharedInstance] activeUserID] != nil) ? [[HONUserAssistant sharedInstance] activeUserID] : @"0",
//			 @"name"		: ([[HONUserAssistant sharedInstance] activeUsername] != nil) ? [[HONUserAssistant sharedInstance] activeUsername] : @"",
//			 @"phone"		: [[HONDeviceIntrinsics sharedInstance] phoneNumber],
			 @"time"		: [[NSDate utcNowDate] formattedISO8601String],
			 @"time_zone"	: [[NSDate date] utcHourOffsetFromDeviceLocale],
			 @"cohort_date"	: [[[cohortDate formattedISO8601String] componentsSeparatedByString:@"T"] firstObject],
			 @"cohort_week"	: [NSString stringWithFormat:@"%04d-W%02d", [cohortDate year], [cohortDate weekOfYear]]});
}

- (NSDictionary *)propertyForActivityItem:(HONActivityItemVO *)vo {
	return (@{@"activity"	: [NSString stringWithFormat:@"%@ - %d", vo.activityID, (int)vo.activityType]});
}

- (NSDictionary *)propertyForCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice {
	return (@{@"camera"	: (cameraDevice == UIImagePickerControllerCameraDeviceFront) ? @"front" : @"rear"});
}

- (NSDictionary *)propertyForClubPhoto:(HONClubPhotoVO *)vo {
	return (@{@"photo"	: @{@"id"		: @(vo.challengeID),
							@"club_id"	: @(vo.clubID),
							@"user_id"	: @(vo.userID),
							@"username"	: vo.username,
							@"img"		: vo.imagePrefix}});
}

- (NSDictionary *)propertyForContactUser:(HONContactUserVO *)vo {
	return (@{@"contact"	: @{@"name"		: vo.fullName,
								@"is_sms"	: NSStringFromBOOL(vo.isSMSAvailable),
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
	return (@{@"product"	: @{@"id"			: vo.productID,
								@"name"			: vo.productName,
								@"price"		: @(vo.price),
								@"purchased"	: NSStringFromBOOL(vo.isPurchased)}});
}

- (NSDictionary *)propertyForUser:(HONUserVO *)vo {
	return (@{@"member"	: @{@"id"		: @(vo.userID),
							@"username"	: vo.username,
							@"avatar"	: vo.avatarPrefix}});
}

- (NSDictionary *)propertyForUserClub:(HONUserClubVO *)vo {
	return (@{@"club"	: @{@"id"		: @(vo.clubID),
							@"name"		: vo.clubName,
							@"owner_id"	: @(vo.ownerID),
							@"created"	: [vo.addedDate formattedISO8601String]}});
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
	
	
	//NSLog(@"TRACK EVENT:[%@] (%@)", eventCollection, eventName);
	id tracker = [[GAI sharedInstance] defaultTracker];
	[tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsCohort
														  action:[[event componentsSeparatedByString:@" - "] lastObject]
														   label:@"Event"
														   value:@1] build]];

	
	
	NSError *error = nil;
	[[KeenClient sharedClient] addEvent:eventName
					  toEventCollection:eventCollection
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

- (void)trackEvent:(NSString *)event withUser:(HONUserVO *)userVO {
	NSMutableDictionary *properties = [[[HONAnalyticsReporter sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsReporter sharedInstance] propertyForUser:userVO]];
	
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
