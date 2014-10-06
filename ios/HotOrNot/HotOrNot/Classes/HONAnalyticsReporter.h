//
//  HONAnalyticsReporter.h
//  HotOrNot
//
//  Created by Matt Holcombe on 02/22/2014 @ 13:43 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KeenClient.h"
#import "KeenProperties.h"

#import "HONActivityItemVO.h"
#import "HONChallengeVO.h"
#import "HONClubPhotoVO.h"
#import "HONContactUserVO.h"
#import "HONEmotionVO.h"
#import "HONOpponentVO.h"
#import "HONTrivialUserVO.h"
#import "HONUserVO.h"
#import "HONUserClubVO.h"

@interface HONAnalyticsReporter : NSObject
+ (HONAnalyticsReporter *)sharedInstance;

- (NSDictionary *)orthodoxProperties;
- (NSDictionary *)applicationProperties;
- (NSDictionary *)deviceProperties;
- (NSDictionary *)screenStateProperties;
- (NSDictionary *)sessionProperties;
- (NSDictionary *)userProperties;

- (NSDictionary *)propertyForActivityItem:(HONActivityItemVO *)vo;
- (NSDictionary *)propertyForCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice;
- (NSDictionary *)propertyForClubPhoto:(HONClubPhotoVO *)vo;
- (NSDictionary *)propertyForContactUser:(HONContactUserVO *)vo;
- (NSDictionary *)propertyForEmotion:(HONEmotionVO *)vo;
- (NSDictionary *)propertyForTrivialUser:(HONTrivialUserVO *)vo;
- (NSDictionary *)propertyForUserClub:(HONUserClubVO *)vo;

- (void)trackEvent:(NSString *)eventName;
- (void)trackEvent:(NSString *)eventName withActivityItem:(HONActivityItemVO *)activityItemVO;
- (void)trackEvent:(NSString *)eventName withCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice;
- (void)trackEvent:(NSString *)eventName withClubPhoto:(HONClubPhotoVO *)clubPhotoVO;
- (void)trackEvent:(NSString *)eventName withContactUser:(HONContactUserVO *)contactUserVO;
- (void)trackEvent:(NSString *)eventName withEmotion:(HONEmotionVO *)emotionVO;
- (void)trackEvent:(NSString *)eventName withTrivialUser:(HONTrivialUserVO *)trivialUserVO;
- (void)trackEvent:(NSString *)eventName withUserClub:(HONUserClubVO *)userClubVO;
- (void)trackEvent:(NSString *)eventName withProperties:(NSDictionary *)properties;

- (void)forceAnalyticsUpload;
- (void)refreshLocation;

@end
