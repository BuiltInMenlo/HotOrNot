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

- (NSDictionary *)prependProperties:(NSDictionary *)dict toChallenge:(HONChallengeVO *)vo {
	NSMutableDictionary *properties = [dict mutableCopy];
	properties[@"challenge"] = [NSString stringWithFormat:@"%d - %@", vo.challengeID, vo.subjectName];
	
	return ([properties copy]);
}

- (NSDictionary *)prependProperties:(NSDictionary *)dict toChallengeCreator:(HONOpponentVO *)vo {
	NSMutableDictionary *properties = [dict mutableCopy];
	properties[@"creator"] = [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username];
	
	return ([properties copy]);
}

- (NSDictionary *)prependProperties:(NSDictionary *)dict toParticipant:(HONOpponentVO *)vo {
	NSMutableDictionary *properties = [dict mutableCopy];
	properties[@"participant"] = [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username];
	
	return ([properties copy]);
}

- (NSDictionary *)prependProperties:(NSDictionary *)dict toCohortUser:(HONUserVO *)vo {
	NSMutableDictionary *properties = [dict mutableCopy];
	properties[@"cohort"] = [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username];
	
	return ([properties copy]);
}

- (NSDictionary *)prependProperties:(NSDictionary *)dict toContactUser:(HONContactUserVO *)vo {
	NSMutableDictionary *properties = [dict mutableCopy];
	properties[@"cohort"] = [NSString stringWithFormat:@"%@ - %@", vo.fullName, (vo.isSMSAvailable) ? vo.mobileNumber : vo.email];
	
	return ([properties copy]);
}

- (NSDictionary *)prependProperties:(NSDictionary *)dict toTrivalUser:(HONTrivialUserVO *)vo {
	NSMutableDictionary *properties = [dict mutableCopy];
	properties[@"cohort"] = [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username];
	
	return ([properties copy]);
}

- (NSDictionary *)prependProperties:(NSDictionary *)dict toUserClub:(HONUserClubVO *)vo {
	NSMutableDictionary *properties = [dict mutableCopy];
	properties[@"club"] = [NSString stringWithFormat:@"%d - %@", vo.clubID, vo.clubName];
	
	return ([properties copy]);
}



- (void)trackEvent:(NSString *)event withProperties:(NSDictionary *)properties {
	[[Mixpanel sharedInstance] track:event
						  properties:properties];
}

@end
