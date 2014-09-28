//
//  HONAnalyticsParams.h
//  HotOrNot
//
//  Created by Matt Holcombe on 02/22/2014 @ 13:43 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONAnalyticsParams.h"


#if __APPSTORE_BUILD__ == 1
NSString * const kKeenIOEventCollection = @"iOS - Live";
#else
NSString * const kKeenIOEventCollection = @"iOS - DEV";
#endif


@implementation HONAnalyticsParams

static HONAnalyticsParams *sharedInstance = nil;

+ (HONAnalyticsParams *)sharedInstance {
	static HONAnalyticsParams *s_sharedInstance = nil;
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
	
	
	return (@{@"user"			: [[HONAnalyticsParams sharedInstance] userProperties],
			  @"device"			: [[HONAnalyticsParams sharedInstance] deviceProperties],
			  @"session"		: [[HONAnalyticsParams sharedInstance] sessionProperties],
			  @"application"	: [[HONAnalyticsParams sharedInstance] applicationProperties],
			  @"screen-state"	: [[HONAnalyticsParams sharedInstance] screenStateProperties]});
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
			  @"time"			: [[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[NSDate date]],
			  @"tz"				: [[HONDateTimeAlloter sharedInstance] timezoneFromDeviceLocale],
			  @"battery-per"	: [NSString stringWithFormat:@"%.02f%%", ([UIDevice currentDevice].batteryLevel * 100)]});
}

- (NSDictionary *)screenStateProperties {
	return (@{@"current"	: ([[NSUserDefaults standardUserDefaults] objectForKey:@"current_tab"] != nil) ? ([[[NSUserDefaults standardUserDefaults] objectForKey:@"current_tab"] intValue] == 0) ? @"contacts" : ([[[NSUserDefaults standardUserDefaults] objectForKey:@"current_tab"] intValue] == 1) ? @"settings" : @"N/A" : @"N/A",
			  @"previous"	: ([[NSUserDefaults standardUserDefaults] objectForKey:@"prev_tab"] != nil) ? ([[[NSUserDefaults standardUserDefaults] objectForKey:@"prev_tab"] intValue] == 0) ? @"contacts" : ([[[NSUserDefaults standardUserDefaults] objectForKey:@"prev_tab"] intValue] == 1) ? @"settings" : @"N/A" : @"N/A"});
}

- (NSDictionary *)sessionProperties {
	return (@{@"id"				: @"",
			  @"id-last"		: @"",
			  @"session-gap"	: [[HONDateTimeAlloter sharedInstance] orthodoxBlankTimestampFormattedString],
			  @"duration"		: ([[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"] != nil) ? [[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"] : [[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[NSDate date]],
			  @"idle"			: ([[NSUserDefaults standardUserDefaults] objectForKey:@"tracking_interval"] != nil) ? [[NSUserDefaults standardUserDefaults] objectForKey:@"tracking_interval"] : [[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[NSDate date]],
			  @"count"			: ([[NSUserDefaults standardUserDefaults] objectForKey:@"tracking_total"] != nil) ? [[NSUserDefaults standardUserDefaults] objectForKey:@"tracking_total"] : @"0",
			  @"entry-point"	: ([[NSUserDefaults standardUserDefaults] objectForKey:@"entry"] != nil) ? [[[NSUserDefaults standardUserDefaults] objectForKey:@"entry"] lowercaseString] : @"launch"});
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
			 @"cohort-date"	: [[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:cohortDate],
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

- (NSDictionary *)propertyForChallenge:(HONChallengeVO *)vo {
//	static NSDictionary *properties = nil;
//	static dispatch_once_t onceToken;
//	
//	dispatch_once(&onceToken, ^{
//		properties = @{@"challenge"	: [NSString stringWithFormat:@"%d - %@", vo.challengeID, vo.subjectNames]};
//	});
	
	return (@{@"challenge"	: [NSString stringWithFormat:@"%d - %@", vo.challengeID, vo.subjectNames]});
}

- (NSDictionary *)propertyForChallengeCreator:(HONChallengeVO *)vo {
//	static NSDictionary *properties = nil;
//	static dispatch_once_t onceToken;
//	
//	dispatch_once(&onceToken, ^{
//		properties = @{@"creator"	: [NSString stringWithFormat:@"%d - %@", vo.creatorVO.userID, vo.creatorVO.username]};
//	});
	
	return (@{@"creator"	: [NSString stringWithFormat:@"%d - %@", vo.creatorVO.userID, vo.creatorVO.username]});
}

- (NSDictionary *)propertyForChallengeParticipant:(HONOpponentVO *)vo; {
//	static NSDictionary *properties = nil;
//	static dispatch_once_t onceToken;
//	
//	dispatch_once(&onceToken, ^{
//		properties = @{@"participant"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]};
//	});
	
	return (@{@"participant"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]});
}

- (NSDictionary *)propertyForClubPhoto:(HONClubPhotoVO *)vo {
//	static NSDictionary *properties = nil;
//	static dispatch_once_t onceToken;
//	
//	dispatch_once(&onceToken, ^{
//		properties = @{@"photo"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]};
//	});
	
	return (@{@"photo"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]});
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
	return (@{@"emotion"	: [NSString stringWithFormat:@"%@ - %@", vo.emotionID, vo.emotionName]});
}

- (NSDictionary *)propertyForMessage:(HONMessageVO *)vo {
//	static NSDictionary *properties = nil;
//	static dispatch_once_t onceToken;
//	
//	dispatch_once(&onceToken, ^{
//		properties = @{@"message"	: [@"" stringFromInt:vo.messageID]};
//	});
	
	return (@{@"message"	: [@"" stringFromInt:vo.messageID]});
}

- (NSDictionary *)propertyForMessage:(HONMessageVO *)messageVO andParticipant:(HONOpponentVO *)participantVO {
//	static NSDictionary *properties = nil;
//	static dispatch_once_t onceToken;
//	
//	dispatch_once(&onceToken, ^{
//		properties = @{@"message"		: [@"" stringFromInt:messageVO.messageID],
//					   @"participant"	: [NSString stringWithFormat:@"%d - %@", participantVO.userID, participantVO.username]};
//	});
	
	return (@{@"message"		: [@"" stringFromInt:messageVO.messageID],
			  @"participant"	: [NSString stringWithFormat:@"%d - %@", participantVO.userID, participantVO.username]});
}

- (NSDictionary *)propertyForMessageParticipant:(HONOpponentVO *)vo {
//	static NSDictionary *properties = nil;
//	static dispatch_once_t onceToken;
//	
//	dispatch_once(&onceToken, ^{
//		properties = @{@"participant"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]};
//	});
	
	return (@{@"participant"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]});
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
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:[[HONAnalyticsParams sharedInstance] orthodoxProperties]];
}


#pragma mark -
- (void)trackEvent:(NSString *)eventName withProperties:(NSDictionary *)properties {
	
	[HONAppDelegate incTotalForCounter:@"tracking"];
	NSMutableDictionary *event = (properties == nil) ? [[NSMutableDictionary alloc] init] : [properties mutableCopy];
	[event addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] orthodoxProperties]];
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
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForActivityItem:activityItemVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForCameraDevice:cameraDevice]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withChallenge:(HONChallengeVO *)challengeVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForChallenge:challengeVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withChallenge:(HONChallengeVO *)challengeVO andParticipant:(HONOpponentVO *)opponentVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForChallenge:challengeVO]];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForChallengeParticipant:opponentVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withChallengeCreator:(HONChallengeVO *)challengeVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForChallenge:challengeVO]];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForChallengeCreator:challengeVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withClubPhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForClubPhoto:clubPhotoVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withContactUser:(HONContactUserVO *)contactUserVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForContactUser:contactUserVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withEmotion:(HONEmotionVO *)emotionVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForEmotion:emotionVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withMessage:(HONMessageVO *)messageVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForMessage:messageVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withMessage:(HONMessageVO *)messageVO andParticipant:(HONOpponentVO *)opponentVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForMessage:messageVO andParticipant:opponentVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForTrivialUser:trivialUserVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withUserClub:(HONUserClubVO *)userClubVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] orthodoxProperties] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForUserClub:userClubVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}


- (void)forceAnalyticsUpload {
	[[KeenClient sharedClient] uploadWithFinishedBlock:nil];
}

- (void)refreshLocation {
	[[KeenClient sharedClient] refreshCurrentLocation];
}


@end
