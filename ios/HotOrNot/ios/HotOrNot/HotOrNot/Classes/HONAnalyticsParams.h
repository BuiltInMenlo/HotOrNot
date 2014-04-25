//
//  HONAnalyticsParams.h
//  HotOrNot
//
//  Created by Matt Holcombe on 02/22/2014 @ 13:43 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "Mixpanel.h"

#import "HONContactUserVO.h"
#import "HONChallengeVO.h"
#import "HONEmotionVO.h"
#import "HONOpponentVO.h"
#import "HONTrivialUserVO.h"
#import "HONUserVO.h"
#import "HONUserClubVO.h"

@interface HONAnalyticsParams : NSObject
+ (HONAnalyticsParams *)sharedInstance;

- (NSDictionary *)userProperty;
- (NSDictionary *)propertyForChallenge:(HONChallengeVO *)vo;
- (NSDictionary *)propertyForChallengeCreator:(HONChallengeVO *)vo;
- (NSDictionary *)propertyForCohortUser:(HONUserVO *)vo;
- (NSDictionary *)propertyForContactUser:(HONContactUserVO *)vo;
- (NSDictionary *)propertyForEmotion:(HONEmotionVO *)vo;
- (NSDictionary *)propertyForParticipant:(HONOpponentVO *)vo;
- (NSDictionary *)propertyForTrivialUser:(HONTrivialUserVO *)vo;
- (NSDictionary *)propertyForUserClub:(HONUserClubVO *)vo;

- (NSDictionary *)prependProperties:(NSDictionary *)dict toChallenge:(HONChallengeVO *)vo;
- (NSDictionary *)prependProperties:(NSDictionary *)dict toChallengeCreator:(HONChallengeVO *)vo;
- (NSDictionary *)prependProperties:(NSDictionary *)dict toCohortUser:(HONUserVO *)vo;
- (NSDictionary *)prependProperties:(NSDictionary *)dict toContactUser:(HONContactUserVO *)vo;
- (NSDictionary *)prependProperties:(NSDictionary *)dict toEmotion:(HONEmotionVO *)vo;
- (NSDictionary *)prependProperties:(NSDictionary *)dict toParticipant:(HONOpponentVO *)vo;
- (NSDictionary *)prependProperties:(NSDictionary *)dict toTrivalUser:(HONTrivialUserVO *)vo;
- (NSDictionary *)prependProperties:(NSDictionary *)dict toUserClub:(HONUserClubVO *)vo;
- (NSDictionary *)prependProperties:(NSDictionary *)dict withAdditionalProperties:(NSDictionary *)addlProps;

- (NSDictionary *)prependUserPropertyToAdditionalProperties:(NSDictionary *)addlProps;
- (NSDictionary *)prependUserPropertyToChallenge:(HONChallengeVO *)vo;
- (NSDictionary *)prependUserPropertyToChallengeCreator:(HONChallengeVO *)vo;
- (NSDictionary *)prependUserPropertyToCohortUser:(HONUserVO *)vo;
- (NSDictionary *)prependUserPropertyToContactUser:(HONContactUserVO *)vo;
- (NSDictionary *)prependUserPropertyToEmotion:(HONEmotionVO *)vo;
- (NSDictionary *)prependUserPropertyToParticipant:(HONOpponentVO *)vo;
- (NSDictionary *)prependUserPropertyToTrivialUser:(HONTrivialUserVO *)vo;
- (NSDictionary *)prependUserPropertyToUserClub:(HONUserClubVO *)vo;

- (void)trackEvent:(NSString *)event withProperties:(NSDictionary *)properties;
- (void)trackEventWithUserProperty:(NSString *)event;
- (void)trackEventWithUserProperty:(NSString *)event includeProperties:(NSDictionary *)dict;

@end
