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
//	static NSDictionary *properties = nil;
//	static dispatch_once_t onceToken;
//	
//	dispatch_once(&onceToken, ^{
//		properties = @{@"user"		: [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]],
//					   @"device"	: [[HONDeviceIntrinsics sharedInstance] modelName],
//					   @"os"		: [[HONDeviceIntrinsics sharedInstance] osVersion],
//					   @"api_ver"	: [[[HONAppDelegate apiServerPath] componentsSeparatedByString:@"/"] lastObject]};
//	});
	
	
	return (@{@"user"			: [[HONAnalyticsReporter sharedInstance] userProperties],
			  @"device"			: [[HONAnalyticsReporter sharedInstance] deviceProperties],
			  @"session"		: [[HONAnalyticsReporter sharedInstance] sessionProperties],
			  @"application"	: [[HONAnalyticsReporter sharedInstance] applicationProperties],
			  @"screen-state"	: [[HONAnalyticsReporter sharedInstance] screenStateProperties]});
}

- (NSDictionary *)applicationProperties {
	return (@{@"version"		: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
			  @"build"			: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
			  @"service-env"	: ([HONAppDelegate apiServerPath] != nil) ? ([[HONAppDelegate apiServerPath] rangeOfString:@"devint"].location != NSNotFound) ? @"devint" : @"prod" : @"N/A",
			  @"api-release"	: ([HONAppDelegate apiServerPath] != nil) ? [[[HONAppDelegate apiServerPath] componentsSeparatedByString:@"/"] lastObject] : @"N/A"});
}

- (NSDictionary *)deviceProperties {
	return (@{@"os"				: [[HONDeviceIntrinsics sharedInstance] osName],
			  @"os-version"		: [[HONDeviceIntrinsics sharedInstance] osVersion],
			  @"hardware-make"	: [[[HONDeviceIntrinsics sharedInstance] modelName] substringToIndex:[[[HONDeviceIntrinsics sharedInstance] modelName] length] - 3],
			  @"hardware-model"	: [[[HONDeviceIntrinsics sharedInstance] modelName] substringFromIndex:[[[HONDeviceIntrinsics sharedInstance] modelName] length] - 3],
			  @"resolution"		: NSStringFromCGSize([UIScreen mainScreen].bounds.size),
			  @"adid"			: [[HONDeviceIntrinsics sharedInstance] uniqueIdentifierWithoutSeperators:NO],
			  @"push_token"		: [[HONDeviceIntrinsics sharedInstance] pushToken],
			  @"locale"			: [[[HONDeviceIntrinsics sharedInstance] locale] uppercaseString],
			  @"time"			: [[HONDateTimeAlloter sharedInstance] utcNowDateFormattedISO8601],
			  @"tz"				: [[HONDateTimeAlloter sharedInstance] timezoneFromDeviceLocale],
			  @"battery-per"	: [NSString stringWithFormat:@"%.02f%%", ([UIDevice currentDevice].batteryLevel * 100.0)],
			  @"hmac"			: [[HONDeviceIntrinsics sharedInstance] hmacToken]});
}

- (NSDictionary *)screenStateProperties {
	return (@{@"current"	: ([[NSUserDefaults standardUserDefaults] objectForKey:@"current_tab"] != nil) ? ([[[NSUserDefaults standardUserDefaults] objectForKey:@"current_tab"] intValue] == 0) ? @"contacts" : ([[[NSUserDefaults standardUserDefaults] objectForKey:@"current_tab"] intValue] == 1) ? @"settings" : @"N/A" : @"N/A",
			  @"previous"	: ([[NSUserDefaults standardUserDefaults] objectForKey:@"prev_tab"] != nil) ? ([[[NSUserDefaults standardUserDefaults] objectForKey:@"prev_tab"] intValue] == 0) ? @"contacts" : ([[[NSUserDefaults standardUserDefaults] objectForKey:@"prev_tab"] intValue] == 1) ? @"settings" : @"N/A" : @"N/A"});
}

- (NSDictionary *)sessionProperties {
	NSDate *nowDate = [NSDate date];
	NSDate *durDate = ([[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"] != nil) ? [[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"]] : nowDate;
	NSDate *idlDate = ([[NSUserDefaults standardUserDefaults] objectForKey:@"tracking_interval"] != nil) ? [[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[[NSUserDefaults standardUserDefaults] objectForKey:@"tracking_interval"]] : nowDate;
	
	return (@{@"id"				: @"0",
			  @"id-last"		: @"0",
			  @"session-gap"	: @"0",
			  @"duration"		: [@"" stringFromInt:[nowDate timeIntervalSinceDate:durDate]],
			  @"idle"			: [@"" stringFromInt:[nowDate timeIntervalSinceDate:idlDate]],
			  @"count"			: ([[NSUserDefaults standardUserDefaults] objectForKey:@"tracking_total"] != nil) ? [[NSUserDefaults standardUserDefaults] objectForKey:@"tracking_total"] : @"0",
			  @"entry-point"	: ([[NSUserDefaults standardUserDefaults] objectForKey:@"entry"] != nil) ? [[[NSUserDefaults standardUserDefaults] objectForKey:@"entry"] lowercaseString] : @"N/A"});
}

- (NSDictionary *)userProperties {
//	static NSDictionary *properties = nil;
//	static dispatch_once_t onceToken;
//	
//	dispatch_once(&onceToken, ^{
//		properties = @{@"user": [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]]};
//	});
	
	NSDate *cohortDate = ([[HONAppDelegate infoForUser] objectForKey:@"added"] != nil) ? [[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[[HONAppDelegate infoForUser] objectForKey:@"added"]] : [[HONDateTimeAlloter sharedInstance] utcNowDate];
	return(@{@"id"			: ([[HONAppDelegate infoForUser] objectForKey:@"id"] != nil) ? [[HONAppDelegate infoForUser] objectForKey:@"id"] : @"0",
			 @"name"		: ([[HONAppDelegate infoForUser] objectForKey:@"username"] != nil) ? [[HONAppDelegate infoForUser] objectForKey:@"username"] : @"",
			 @"phone"		: [[HONDeviceIntrinsics sharedInstance] phoneNumber],
			 @"cohort-date"	: [[HONDateTimeAlloter sharedInstance] ISO8601FormattedStringFromDate:cohortDate],
			 @"cohort-week"	: [NSString stringWithFormat:@"%@-%02d", [[[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:cohortDate] substringToIndex:4], [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekOfYear fromDate:cohortDate] weekOfYear]]});
}

- (NSDictionary *)propertyForActivityItem:(HONActivityItemVO *)vo {
//	static NSDictionary *properties = nil;
//	static dispatch_once_t onceToken;
//	
//	dispatch_once(&onceToken, ^{
//		properties = @{@"activity"	: [NSString stringWithFormat:@"%@ - %d", vo.activityID, vo.activityType]};
//	});
	
	return (@{@"activity"	: [NSString stringWithFormat:@"%@ - %d", vo.activityID, vo.activityType]});
}

- (NSDictionary *)propertyForCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice {
//	static NSDictionary *properties = nil;
//	static dispatch_once_t onceToken;
//	
//	dispatch_once(&onceToken, ^{
//		properties = @{@"camera"	: (cameraDevice == UIImagePickerControllerCameraDeviceFront) ? @"front" : @"rear"};
//	});
	
	return (@{@"camera"	: (cameraDevice == UIImagePickerControllerCameraDeviceFront) ? @"front" : @"rear"});
}

- (NSDictionary *)propertyForClubPhoto:(HONClubPhotoVO *)vo {
//	static NSDictionary *properties = nil;
//	static dispatch_once_t onceToken;
//	
//	dispatch_once(&onceToken, ^{
//		properties = @{@"photo"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]};
//	});
	
	return (@{@"photo"	: @{@"id"		: [@"" stringFromInt:vo.challengeID],
							@"club_id"	: [@"" stringFromInt:vo.clubID],
							@"user_id"	: [@"" stringFromInt:vo.userID],
							@"username"	: vo.username,
							@"img"		: vo.imagePrefix}});
}

- (NSDictionary *)propertyForContactUser:(HONContactUserVO *)vo {
//	static NSDictionary *properties = nil;
//	static dispatch_once_t onceToken;
//	
//	dispatch_once(&onceToken, ^{
//		properties = @{@"cohort"	: [NSString stringWithFormat:@"%@ - %@", vo.fullName, (vo.isSMSAvailable) ? vo.mobileNumber : vo.email]};
//	});
	
	return (@{@"contact"	: @{@"name"		: vo.fullName,
								@"is_sms"	: [@"" stringFromBOOL:vo.isSMSAvailable],
								@"phone"	: vo.mobileNumber,
								@"email"	: vo.email}});
	
	//return ( @{@"cohort"	: [NSString stringWithFormat:@"%@ - %@", vo.fullName, (vo.isSMSAvailable) ? vo.mobileNumber : vo.email]});
}

- (NSDictionary *)propertyForEmotion:(HONEmotionVO *)vo {
	return (@{@"emotion"	: @{@"id"		: vo.emotionID,
								@"name"		: vo.emotionName,
								@"cg_id"	: vo.contentGroupID,
								@"url"		: vo.urlPrefix}});
}

- (NSDictionary *)propertyForStoreProduct:(HONStoreProductVO *)vo {
	return (@{@"product"	: @{@"id"		: vo.productID,
								@"name"		: vo.productName,
								@"price"	: [@"" stringFromFloat:vo.price]}});
}

- (NSDictionary *)propertyForTrivialUser:(HONTrivialUserVO *)vo {
//	static NSDictionary *properties = nil;
//	static dispatch_once_t onceToken;
//	
//	dispatch_once(&onceToken, ^{
//		properties = @{@"cohort"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]};
//	});
	
	return (@{@"member"	: @{@"id"		: [@"" stringFromInt:vo.userID],
							@"username"	: vo.username,
							@"avatar"	: vo.avatarPrefix}});
}

- (NSDictionary *)propertyForUserClub:(HONUserClubVO *)vo {
//	static NSDictionary *properties = nil;
//	static dispatch_once_t onceToken;
//	
//	dispatch_once(&onceToken, ^{
//		properties = @{@"club"	: [NSString stringWithFormat:@"%d - %@", vo.clubID, vo.clubName]};
//	});
	
	return (@{@"club"	: @{@"id"		: [@"" stringFromInt:vo.clubID],
							@"name"		: vo.clubName,
							@"owner_id"	: [@"" stringFromInt:vo.ownerID],
							@"created"	: [[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:vo.addedDate]}});
}


- (void)trackEvent:(NSString *)eventName {
	[[HONAnalyticsReporter sharedInstance] trackEvent:eventName
									 withProperties:[[HONAnalyticsReporter sharedInstance] orthodoxProperties]];
}


#pragma mark -
- (void)trackEvent:(NSString *)eventName withProperties:(NSDictionary *)properties {
	
	[HONAppDelegate incTotalForCounter:@"tracking"];
	NSMutableDictionary *event = (properties == nil) ? [[NSMutableDictionary alloc] init] : [properties mutableCopy];
	[event addEntriesFromDictionary:[[HONAnalyticsReporter sharedInstance] orthodoxProperties]];
	[event addEntriesFromDictionary:@{@"action"	: [[eventName componentsSeparatedByString:@" - "] lastObject]}];
	
//	NSLog(@"TRACK EVENT:[%@] (%@)", [kKeenIOEventCollection stringByAppendingFormat:@" : %@", [[eventName componentsSeparatedByString:@" - "] firstObject]], event);
	
	[[NSUserDefaults standardUserDefaults] setValue:[[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[NSDate date]] forKey:@"tracking_interval"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	NSError *error = nil;
	[[KeenClient sharedClient] addEvent:event
					  toEventCollection:[kKeenIOEventCollection stringByAppendingFormat:@" : %@", [[eventName componentsSeparatedByString:@" - "] firstObject]]
								  error:&error];
}
#pragma mark -


- (void)trackEvent:(NSString *)eventName withActivityItem:(HONActivityItemVO *)activityItemVO {
	NSMutableDictionary *properties = [[[HONAnalyticsReporter sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsReporter sharedInstance] propertyForActivityItem:activityItemVO]];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice {
	NSMutableDictionary *properties = [[[HONAnalyticsReporter sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsReporter sharedInstance] propertyForCameraDevice:cameraDevice]];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withClubPhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSMutableDictionary *properties = [[[HONAnalyticsReporter sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsReporter sharedInstance] propertyForClubPhoto:clubPhotoVO]];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withContactUser:(HONContactUserVO *)contactUserVO {
	NSMutableDictionary *properties = [[[HONAnalyticsReporter sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsReporter sharedInstance] propertyForContactUser:contactUserVO]];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withEmotion:(HONEmotionVO *)emotionVO {
	NSMutableDictionary *properties = [[[HONAnalyticsReporter sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsReporter sharedInstance] propertyForEmotion:emotionVO]];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withStoreProduct:(HONStoreProductVO *)storeProductVO {
	NSMutableDictionary *properties = [[[HONAnalyticsReporter sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsReporter sharedInstance] propertyForStoreProduct:storeProductVO]];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:eventName
									   withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	NSMutableDictionary *properties = [[[HONAnalyticsReporter sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsReporter sharedInstance] propertyForTrivialUser:trivialUserVO]];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withUserClub:(HONUserClubVO *)userClubVO {
	NSMutableDictionary *properties = [[[HONAnalyticsReporter sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsReporter sharedInstance] propertyForUserClub:userClubVO]];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:eventName
									 withProperties:properties];
}


- (void)forceAnalyticsUpload {
	[[KeenClient sharedClient] uploadWithFinishedBlock:nil];
}

- (void)refreshLocation {
	[[KeenClient sharedClient] refreshCurrentLocation];
}


@end
