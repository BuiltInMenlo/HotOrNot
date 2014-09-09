//
//  HONAnalyticsParams.h
//  HotOrNot
//
//  Created by Matt Holcombe on 02/22/2014 @ 13:43 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONAnalyticsParams.h"


#if __DEV_BUILD__ == 0 || __APPSTORE_BUILD__ == 1
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


- (NSDictionary *)userProperty {
//	static NSDictionary *properties = nil;
//	static dispatch_once_t onceToken;
//	
//	dispatch_once(&onceToken, ^{
//		properties = @{@"user": [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]]};
//	});
	
	return (@{@"user": [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]]});
}

/*- (NSDictionary *)propertyForActivityItem:(HONActivityItemVO *)vo {
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
}*/

- (NSDictionary *)propertyForClubPhoto:(HONClubPhotoVO *)vo {
//	static NSDictionary *properties = nil;
//	static dispatch_once_t onceToken;
//	
//	dispatch_once(&onceToken, ^{
//		properties = @{@"photo"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]};
//	});
	
	return (@{@"photo"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]});
}

- (NSDictionary *)propertyForCohortUser:(HONUserVO *)vo {
//	static NSDictionary *properties = nil;
//	static dispatch_once_t onceToken;
//	
//	dispatch_once(&onceToken, ^{
//		properties = @{@"cohort"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]};
//	});
	
	return (@{@"cohort"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]});
}

- (NSDictionary *)propertyForContactUser:(HONContactUserVO *)vo {
//	static NSDictionary *properties = nil;
//	static dispatch_once_t onceToken;
//	
//	dispatch_once(&onceToken, ^{
//		properties = @{@"cohort"	: [NSString stringWithFormat:@"%@ - %@", vo.fullName, (vo.isSMSAvailable) ? vo.mobileNumber : vo.email]};
//	});
	
	return ( @{@"cohort"	: [NSString stringWithFormat:@"%@ - %@", vo.fullName, (vo.isSMSAvailable) ? vo.mobileNumber : vo.email]});
}

- (NSDictionary *)propertyForEmotion:(HONEmotionVO *)vo {
	return (@{@"emotion"	: [NSString stringWithFormat:@"%@ - %@", vo.emotionID, vo.emotionName]});
}

/*- (NSDictionary *)propertyForMessage:(HONMessageVO *)vo {
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
}*/

- (NSDictionary *)propertyForTrivialUser:(HONTrivialUserVO *)vo {
//	static NSDictionary *properties = nil;
//	static dispatch_once_t onceToken;
//	
//	dispatch_once(&onceToken, ^{
//		properties = @{@"cohort"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]};
//	});
	
	return (@{@"cohort"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]});
}

- (NSDictionary *)propertyForUserClub:(HONUserClubVO *)vo {
//	static NSDictionary *properties = nil;
//	static dispatch_once_t onceToken;
//	
//	dispatch_once(&onceToken, ^{
//		properties = @{@"club"	: [NSString stringWithFormat:@"%d - %@", vo.clubID, vo.clubName]};
//	});
	
	return (@{@"club"	: [NSString stringWithFormat:@"%d - %@", vo.clubID, vo.clubName]});
}


- (void)trackEvent:(NSString *)eventName {
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:nil];
}


#pragma mark -
- (void)trackEvent:(NSString *)eventName withProperties:(NSDictionary *)properties {
	NSMutableDictionary *event = (properties == nil) ? [[NSMutableDictionary alloc] init] : [properties mutableCopy];
	[event addEntriesFromDictionary:@{@"action"	: [[eventName componentsSeparatedByString:@" - "] lastObject]}];
	
	NSLog(@"TRACK EVENT:[%@] (%@)", [kKeenIOEventCollection stringByAppendingFormat:@" : %@", [[eventName componentsSeparatedByString:@" - "] firstObject]], event);
	
//	NSError *error = nil;
//	[[KeenClient sharedClient] addEvent:event
//					  toEventCollection:[kKeenIOEventCollection stringByAppendingFormat:@" : %@", [[eventName componentsSeparatedByString:@" - "] firstObject]]
//								  error:&error];
//	[[KeenClient sharedClient] uploadWithFinishedBlock:nil];
}
#pragma mark -


/*- (void)trackEvent:(NSString *)eventName withActivityItem:(HONActivityItemVO *)activityItemVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForActivityItem:activityItemVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForCameraDevice:cameraDevice]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withChallenge:(HONChallengeVO *)challengeVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForChallenge:challengeVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withChallenge:(HONChallengeVO *)challengeVO andParticipant:(HONOpponentVO *)opponentVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForChallenge:challengeVO]];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForChallengeParticipant:opponentVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withChallengeCreator:(HONChallengeVO *)challengeVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForChallenge:challengeVO]];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForChallengeCreator:challengeVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}*/

- (void)trackEvent:(NSString *)eventName withClubPhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForClubPhoto:clubPhotoVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withCohortUser:(HONUserVO *)userVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForCohortUser:userVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withContactUser:(HONContactUserVO *)contactUserVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForContactUser:contactUserVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withEmotion:(HONEmotionVO *)emotionVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForEmotion:emotionVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

/*- (void)trackEvent:(NSString *)eventName withMessage:(HONMessageVO *)messageVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForMessage:messageVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withMessage:(HONMessageVO *)messageVO andParticipant:(HONOpponentVO *)opponentVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForMessage:messageVO andParticipant:opponentVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}*/

- (void)trackEvent:(NSString *)eventName withTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForTrivialUser:trivialUserVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)eventName withUserClub:(HONUserClubVO *)userClubVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForUserClub:userClubVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:eventName
									 withProperties:properties];
}


/*- (void)identifyPersonEntityWithProperties:(NSDictionary *)properties {
//	Mixpanel *mixpanel = [Mixpanel sharedInstance];
//	[mixpanel identify:[[HONDeviceIntrinsics sharedInstance] uniqueIdentifierWithoutSeperators:NO]];
//	[mixpanel.people set:properties];
}*/

- (void)forceAnalyticsUpload {
	[[KeenClient sharedClient] uploadWithFinishedBlock:nil];
}

- (void)refreshLocation {
	[[KeenClient sharedClient] refreshCurrentLocation];
}


@end
