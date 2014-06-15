//
//  HONAnalyticsParams.h
//  HotOrNot
//
//  Created by Matt Holcombe on 02/22/2014 @ 13:43 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KeenClient.h"
#import "KeenProperties.h"
#import "Mixpanel.h"

#import "HONActivityItemVO.h"
#import "HONChallengeVO.h"
#import "HONClubPhotoVO.h"
#import "HONContactUserVO.h"
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
- (NSDictionary *)propertyForCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice;
- (NSDictionary *)propertyForChallenge:(HONChallengeVO *)vo;
- (NSDictionary *)propertyForChallengeCreator:(HONChallengeVO *)vo;
- (NSDictionary *)propertyForChallengeParticipant:(HONOpponentVO *)vo;
- (NSDictionary *)propertyForClubPhoto:(HONClubPhotoVO *)vo;
- (NSDictionary *)propertyForCohortUser:(HONUserVO *)vo;
- (NSDictionary *)propertyForContactUser:(HONContactUserVO *)vo;
- (NSDictionary *)propertyForEmotion:(HONEmotionVO *)vo;
- (NSDictionary *)propertyForMessage:(HONMessageVO *)vo;
- (NSDictionary *)propertyForMessage:(HONMessageVO *)messageVO andParticipant:(HONOpponentVO *)participantVO;
- (NSDictionary *)propertyForMessageParticipant:(HONOpponentVO *)vo;
- (NSDictionary *)propertyForTrivialUser:(HONTrivialUserVO *)vo;
- (NSDictionary *)propertyForUserClub:(HONUserClubVO *)vo;

- (void)trackEvent:(NSString *)eventName;
- (void)trackEvent:(NSString *)eventName withActivityItem:(HONActivityItemVO *)activityItemVO;
- (void)trackEvent:(NSString *)eventName withCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice;
- (void)trackEvent:(NSString *)eventName withChallenge:(HONChallengeVO *)challengeVO;
- (void)trackEvent:(NSString *)eventName withChallenge:(HONChallengeVO *)challengeVO andParticipant:(HONOpponentVO *)opponentVO;
- (void)trackEvent:(NSString *)eventName withChallengeCreator:(HONChallengeVO *)challengeVO;
- (void)trackEvent:(NSString *)eventName withClubPhoto:(HONClubPhotoVO *)clubPhotoVO;
- (void)trackEvent:(NSString *)eventName withCohortUser:(HONUserVO *)userVO;
- (void)trackEvent:(NSString *)eventName withContactUser:(HONContactUserVO *)contactUserVO;
- (void)trackEvent:(NSString *)eventName withEmotion:(HONEmotionVO *)emotionVO;
- (void)trackEvent:(NSString *)eventName withMessage:(HONMessageVO *)messageVO;
- (void)trackEvent:(NSString *)eventName withMessage:(HONMessageVO *)messageVO andParticipant:(HONOpponentVO *)opponentVO;
- (void)trackEvent:(NSString *)eventName withTrivialUser:(HONTrivialUserVO *)trivialUserVO;
- (void)trackEvent:(NSString *)eventName withUserClub:(HONUserClubVO *)userClubVO;
- (void)trackEvent:(NSString *)eventName withProperties:(NSDictionary *)properties;

- (void)identifyPersonEntityWithProperties:(NSDictionary *)properties;

- (void)forceAnalyticsUpload;
- (void)refreshLocation;

@end
