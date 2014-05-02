//
//  HONAnalyticsParams.h
//  HotOrNot
//
//  Created by Matt Holcombe on 02/22/2014 @ 13:43 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONAnalyticsParams.h"

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
	}
	
	return (self);
}


- (NSDictionary *)userProperty {
	static NSDictionary *properties = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		properties = @{@"user": [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]]};
	});
	
	return (properties);
}

- (NSDictionary *)propertyForActivityItem:(HONActivityItemVO *)vo {
	static NSDictionary *properties = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		properties = @{@"activity"	: [NSString stringWithFormat:@"%@ - %d", vo.activityID, vo.activityType]};
	});
	
	return (properties);
}

- (NSDictionary *)propertyForCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice {
	static NSDictionary *properties = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		properties = @{@"camera"	: (cameraDevice == UIImagePickerControllerCameraDeviceFront) ? @"front" : @"rear"};
	});
	
	return (properties);
}

- (NSDictionary *)propertyForChallenge:(HONChallengeVO *)vo {
	static NSDictionary *properties = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		properties = @{@"challenge"	: [NSString stringWithFormat:@"%d - %@", vo.challengeID, vo.subjectName]};
	});
	
	return (properties);
}

- (NSDictionary *)propertyForChallengeCreator:(HONChallengeVO *)vo {
	static NSDictionary *properties = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		properties = @{@"creator"	: [NSString stringWithFormat:@"%d - %@", vo.creatorVO.userID, vo.creatorVO.username]};
	});
	
	return (properties);
}

- (NSDictionary *)propertyForChallengeParticipant:(HONOpponentVO *)vo; {
	static NSDictionary *properties = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		properties = @{@"participant"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]};
	});
	
	return (properties);
}

- (NSDictionary *)propertyForCohortUser:(HONUserVO *)vo {
	static NSDictionary *properties = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		properties = @{@"cohort"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]};
	});
	
	return (properties);
}

- (NSDictionary *)propertyForContactUser:(HONContactUserVO *)vo {
	static NSDictionary *properties = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		properties = @{@"cohort"	: [NSString stringWithFormat:@"%@ - %@", vo.fullName, (vo.isSMSAvailable) ? vo.mobileNumber : vo.email]};
	});
	
	return (properties);
}

- (NSDictionary *)propertyForEmotion:(HONEmotionVO *)vo {
	static NSDictionary *properties = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		properties = @{@"emotion"	: [NSString stringWithFormat:@"%d - %@", vo.emotionID, vo.emotionName]};
	});
	
	return (properties);
}

- (NSDictionary *)propertyForMessage:(HONMessageVO *)vo {
	static NSDictionary *properties = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		properties = @{@"message"	: [@"" stringFromInt:vo.messageID]};
	});
	
	return (properties);
}

- (NSDictionary *)propertyForMessage:(HONMessageVO *)messageVO andParticipant:(HONOpponentVO *)participantVO {
	static NSDictionary *properties = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		properties = @{@"message"		: [@"" stringFromInt:messageVO.messageID],
					   @"participant"	: [NSString stringWithFormat:@"%d - %@", participantVO.userID, participantVO.username]};
	});
	
	return (properties);
}

- (NSDictionary *)propertyForMessageParticipant:(HONOpponentVO *)vo {
	static NSDictionary *properties = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		properties = @{@"participant"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]};
	});
	
	return (properties);
}

- (NSDictionary *)propertyForTrivialUser:(HONTrivialUserVO *)vo {
	static NSDictionary *properties = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		properties = @{@"cohort"	: [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username]};
	});
	
	return (properties);
}

- (NSDictionary *)propertyForUserClub:(HONUserClubVO *)vo {
	static NSDictionary *properties = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		properties = @{@"club"	: [NSString stringWithFormat:@"%d - %@", vo.clubID, vo.clubName]};
	});
	
	return (properties);
}


- (void)trackEvent:(NSString *)event {
	[[Mixpanel sharedInstance] track:event
						  properties:[[HONAnalyticsParams sharedInstance] userProperty]];
}

- (void)trackEvent:(NSString *)event withProperties:(NSDictionary *)properties {
	[[Mixpanel sharedInstance] track:event
						  properties:properties];
}


- (void)trackEvent:(NSString *)event withActivityItem:(HONActivityItemVO *)activityItemVO {
	
}

- (void)trackEvent:(NSString *)event withCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForCameraDevice:cameraDevice]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:event
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)event withChallenge:(HONChallengeVO *)challengeVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForChallenge:challengeVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:event
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)event withChallenge:(HONChallengeVO *)challengeVO andParticipant:(HONOpponentVO *)opponentVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForChallenge:challengeVO]];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForChallengeParticipant:opponentVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:event
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)event withChallengeCreator:(HONChallengeVO *)challengeVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForChallenge:challengeVO]];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForChallengeCreator:challengeVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:event
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)event withCohortUser:(HONUserVO *)userVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForCohortUser:userVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:event
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)event withContactUser:(HONContactUserVO *)contactUserVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForContactUser:contactUserVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:event
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)event withEmotion:(HONEmotionVO *)emotionVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForEmotion:emotionVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:event
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)event withMessage:(HONMessageVO *)messageVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForMessage:messageVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:event
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)event withMessage:(HONMessageVO *)messageVO andParticipant:(HONOpponentVO *)opponentVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForMessage:messageVO andParticipant:opponentVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:event
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)event withTrivialUser:(HONTrivialUserVO *)trivialUserVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForTrivialUser:trivialUserVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:event
									 withProperties:properties];
}

- (void)trackEvent:(NSString *)event withUserClub:(HONUserClubVO *)userClubVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForUserClub:userClubVO]];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:event
									 withProperties:properties];
}


- (void)identifyPersonEntityWithProperties:(NSDictionary *)properties {
	Mixpanel *mixpanel = [Mixpanel sharedInstance];
	[mixpanel identify:[[HONDeviceIntrinsics sharedInstance] advertisingIdentifierWithoutSeperators:NO]];
	[mixpanel.people set:properties];
}

@end
