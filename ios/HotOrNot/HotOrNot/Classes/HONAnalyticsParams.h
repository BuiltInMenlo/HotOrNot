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
#import "HONOpponentVO.h"
#import "HONTrivialUserVO.h"
#import "HONUserVO.h"
#import "HONUserClubVO.h"

@interface HONAnalyticsParams : NSObject
+ (HONAnalyticsParams *)sharedInstance;

- (NSDictionary *)userProperty;
- (NSDictionary *)prependProperties:(NSDictionary *)dict toChallenge:(HONChallengeVO *)vo;
- (NSDictionary *)prependProperties:(NSDictionary *)dict toChallengeCreator:(HONOpponentVO *)vo;
- (NSDictionary *)prependProperties:(NSDictionary *)dict toCohortUser:(HONUserVO *)vo;
- (NSDictionary *)prependProperties:(NSDictionary *)dict toParticipant:(HONOpponentVO *)vo;
- (NSDictionary *)prependProperties:(NSDictionary *)dict toContactUser:(HONContactUserVO *)vo;
- (NSDictionary *)prependProperties:(NSDictionary *)dict toTrivalUser:(HONTrivialUserVO *)vo;
- (NSDictionary *)prependProperties:(NSDictionary *)dict toUserClub:(HONUserClubVO *)vo;

- (void)trackEvent:(NSString *)event withProperties:(NSDictionary *)properties;
@end
