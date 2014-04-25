//
//  HONAnalyticsParams.h
//  HotOrNot
//
//  Created by Matt Holcombe on 02/22/2014 @ 13:43 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


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

- (NSDictionary *)propertyForParticipant:(HONOpponentVO *)vo {
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


- (NSDictionary *)prependProperties:(NSDictionary *)dict toChallenge:(HONChallengeVO *)vo {
	NSMutableDictionary *properties = [dict mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForChallenge:vo]];
	
	return ([properties copy]);
}

- (NSDictionary *)prependProperties:(NSDictionary *)dict toChallengeCreator:(HONChallengeVO *)vo {
	NSMutableDictionary *properties = [dict mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForChallengeCreator:vo]];
	
	return ([properties copy]);
}

- (NSDictionary *)prependProperties:(NSDictionary *)dict toCohortUser:(HONUserVO *)vo {
	NSMutableDictionary *properties = [dict mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForCohortUser:vo]];
	
	return ([properties copy]);
}

- (NSDictionary *)prependProperties:(NSDictionary *)dict toContactUser:(HONContactUserVO *)vo {
	NSMutableDictionary *properties = [dict mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForContactUser:vo]];
	
	return ([properties copy]);
}

- (NSDictionary *)prependProperties:(NSDictionary *)dict toEmotion:(HONEmotionVO *)vo {
	NSMutableDictionary *properties = [dict mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForEmotion:vo]];
	
	return ([properties copy]);
}

- (NSDictionary *)prependProperties:(NSDictionary *)dict toParticipant:(HONOpponentVO *)vo {
	NSMutableDictionary *properties = [dict mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForParticipant:vo]];
	
	return ([properties copy]);
}

- (NSDictionary *)prependProperties:(NSDictionary *)dict toTrivalUser:(HONTrivialUserVO *)vo {
	NSMutableDictionary *properties = [dict mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForTrivialUser:vo]];
	
	return ([properties copy]);
}

- (NSDictionary *)prependProperties:(NSDictionary *)dict toUserClub:(HONUserClubVO *)vo {
	NSMutableDictionary *properties = [dict mutableCopy];
	[properties addEntriesFromDictionary:[[HONAnalyticsParams sharedInstance] propertyForUserClub:vo]];
	
	return ([properties copy]);
}

- (NSDictionary *)prependProperties:(NSDictionary *)dict withAdditionalProperties:(NSDictionary *)addlProps {
	NSMutableDictionary *properties = [dict mutableCopy];
	[properties addEntriesFromDictionary:addlProps];
		
	return ([properties copy]);
}


- (NSDictionary *)prependUserPropertyToAdditionalProperties:(NSDictionary *)addlProps {
	return ([[HONAnalyticsParams sharedInstance] prependProperties:[[HONAnalyticsParams sharedInstance] userProperty]
										  withAdditionalProperties:addlProps]);
}

- (NSDictionary *)prependUserPropertyToChallenge:(HONChallengeVO *)vo {
	return ([[HONAnalyticsParams sharedInstance] prependProperties:[[HONAnalyticsParams sharedInstance] userProperty]
													   toChallenge:vo]);
}

- (NSDictionary *)prependUserPropertyToChallengeCreator:(HONChallengeVO *)vo {
	return ([[HONAnalyticsParams sharedInstance] prependProperties:[[HONAnalyticsParams sharedInstance] userProperty]
													   toChallenge:vo]);
}

- (NSDictionary *)prependUserPropertyToCohortUser:(HONUserVO *)vo {
	return ([[HONAnalyticsParams sharedInstance] prependProperties:[[HONAnalyticsParams sharedInstance] userProperty]
													  toCohortUser:vo]);
}

- (NSDictionary *)prependUserPropertyToContactUser:(HONContactUserVO *)vo {
	return ([[HONAnalyticsParams sharedInstance] prependProperties:[[HONAnalyticsParams sharedInstance] userProperty]
													 toContactUser:vo]);
}

- (NSDictionary *)prependUserPropertyToEmotion:(HONEmotionVO *)vo {
	return ([[HONAnalyticsParams sharedInstance] prependProperties:[[HONAnalyticsParams sharedInstance] userProperty]
														 toEmotion:vo]);
}

- (NSDictionary *)prependUserPropertyToParticipant:(HONOpponentVO *)vo {
	return ([[HONAnalyticsParams sharedInstance] prependProperties:[[HONAnalyticsParams sharedInstance] userProperty]
													 toParticipant:vo]);
}

- (NSDictionary *)prependUserPropertyToTrivialUser:(HONTrivialUserVO *)vo {
	return ([[HONAnalyticsParams sharedInstance] prependProperties:[[HONAnalyticsParams sharedInstance] userProperty]
													  toTrivalUser:vo]);
}

- (NSDictionary *)prependUserPropertyToUserClub:(HONUserClubVO *)vo {
	return ([[HONAnalyticsParams sharedInstance] prependProperties:[[HONAnalyticsParams sharedInstance] userProperty]
														toUserClub:vo]);
}


- (void)trackEvent:(NSString *)event withProperties:(NSDictionary *)properties {
	[[Mixpanel sharedInstance] track:event
						  properties:properties];
}

- (void)trackEventWithUserProperty:(NSString *)event {
	[[HONAnalyticsParams sharedInstance] trackEvent:event
									 withProperties:[[HONAnalyticsParams sharedInstance] userProperty]];
}

- (void)trackEventWithUserProperty:(NSString *)event includeProperties:(NSDictionary *)dict {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	[properties addEntriesFromDictionary:dict];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:event
									 withProperties:properties];
}


@end
