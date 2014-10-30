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
#import "HONStoreProductVO.h"
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
- (NSDictionary *)propertyForStoreProduct:(HONStoreProductVO *)vo;

- (void)trackEvent:(NSString *)event;
- (void)trackEvent:(NSString *)event withActivityItem:(HONActivityItemVO *)activityItemVO;
- (void)trackEvent:(NSString *)event withCameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice;
- (void)trackEvent:(NSString *)event withClubPhoto:(HONClubPhotoVO *)clubPhotoVO;
- (void)trackEvent:(NSString *)event withContactUser:(HONContactUserVO *)contactUserVO;
- (void)trackEvent:(NSString *)event withEmotion:(HONEmotionVO *)emotionVO;
- (void)trackEvent:(NSString *)event withStoreProduct:(HONStoreProductVO *)storeProductVO;
- (void)trackEvent:(NSString *)event withTrivialUser:(HONTrivialUserVO *)trivialUserVO;
- (void)trackEvent:(NSString *)event withUserClub:(HONUserClubVO *)userClubVO;
- (void)trackEvent:(NSString *)event withProperties:(NSDictionary *)properties;

- (void)forceAnalyticsUpload;
- (void)refreshLocation;

@end
