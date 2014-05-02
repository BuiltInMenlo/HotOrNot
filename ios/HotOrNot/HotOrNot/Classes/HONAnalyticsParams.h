//
//  HONAnalyticsParams.h
//  HotOrNot
//
//  Created by Matt Holcombe on 02/22/2014 @ 13:43 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Mixpanel.h"

#import "HONActivityItemVO.h"
#import "HONContactUserVO.h"
#import "HONChallengeVO.h"
#import "HONEmotionVO.h"
#import "HONMessageVO.h"
#import "HONOpponentVO.h"
#import "HONTrivialUserVO.h"
#import "HONUserVO.h"
#import "HONUserClubVO.h"

@interface HONAnalyticsParams : NSObject
+ (HONAnalyticsParams *)sharedInstance;

- (NSDictionary *)userProperty;
- (NSDictionary *)propertyForActivityItem:(HONActivityItemVO *)vo;
- (NSDictionary *)propertyForChallenge:(HONChallengeVO *)vo;
- (NSDictionary *)propertyForChallengeCreator:(HONChallengeVO *)vo;
- (NSDictionary *)propertyForChallengeParticipant:(HONOpponentVO *)vo;
- (NSDictionary *)propertyForCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice;
- (NSDictionary *)propertyForCohortUser:(HONUserVO *)vo;
- (NSDictionary *)propertyForContactUser:(HONContactUserVO *)vo;
- (NSDictionary *)propertyForEmotion:(HONEmotionVO *)vo;
- (NSDictionary *)propertyForMessage:(HONMessageVO *)vo;
- (NSDictionary *)propertyForMessage:(HONMessageVO *)messageVO andParticipant:(HONOpponentVO *)participantVO;
- (NSDictionary *)propertyForMessageParticipant:(HONOpponentVO *)vo;
- (NSDictionary *)propertyForTrivialUser:(HONTrivialUserVO *)vo;
- (NSDictionary *)propertyForUserClub:(HONUserClubVO *)vo;

- (void)trackEvent:(NSString *)event;
- (void)trackEvent:(NSString *)event withActivityItem:(HONActivityItemVO *)activityItemVO;
- (void)trackEvent:(NSString *)event withCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice;
- (void)trackEvent:(NSString *)event withChallenge:(HONChallengeVO *)challengeVO;
- (void)trackEvent:(NSString *)event withChallenge:(HONChallengeVO *)challengeVO andParticipant:(HONOpponentVO *)opponentVO;
- (void)trackEvent:(NSString *)event withChallengeCreator:(HONChallengeVO *)challengeVO;
- (void)trackEvent:(NSString *)event withCohortUser:(HONUserVO *)userVO;
- (void)trackEvent:(NSString *)event withContactUser:(HONContactUserVO *)contactUserVO;
- (void)trackEvent:(NSString *)event withEmotion:(HONEmotionVO *)emotionVO;
- (void)trackEvent:(NSString *)event withMessage:(HONMessageVO *)messageVO;
- (void)trackEvent:(NSString *)event withMessage:(HONMessageVO *)messageVO andParticipant:(HONOpponentVO *)opponentVO;
- (void)trackEvent:(NSString *)event withTrivialUser:(HONTrivialUserVO *)trivialUserVO;
- (void)trackEvent:(NSString *)event withUserClub:(HONUserClubVO *)userClubVO;
- (void)trackEvent:(NSString *)event withProperties:(NSDictionary *)properties;

- (void)identifyPersonEntityWithProperties:(NSDictionary *)properties;

@end
