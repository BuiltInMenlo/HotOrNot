//
//  HONChallengeVO.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONOpponentVO.h"

typedef NS_ENUM(NSInteger, HONPhotoSubmitType) {
	HONPhotoSubmitTypeCreateChallenge = 0,
	HONPhotoSubmitTypeReplyChallenge,
	
	HONPhotoSubmitTypeCreateClub,
	HONPhotoSubmitTypeReplyClub,
	
	HONPhotoSubmitTypeCreateVerify,
	HONPhotoSubmitTypeReplyVerify,
	
	HONPhotoSubmitTypeCreateShoutout,
	HONPhotoSubmitTypeReplyShoutout,
	
	HONPhotoSubmitTypeCreateMessage,
	HONPhotoSubmitTypeReplyMessage
};


typedef NS_ENUM(NSInteger, HONSelfieCameraSubmitType) {
	HONSelfieCameraSubmitTypeCreateChallenge = 0,
	HONSelfieCameraSubmitTypeReplyChallenge,
	
	HONSelfieCameraSubmitTypeCreateClub,
	HONSelfieCameraSubmitTypeReplyClub,
	
	HONSelfieCameraSubmitTypeCreateVerify,
	HONSelfieCameraSubmitTypeReplyVerify,
	
	HONSelfieCameraSubmitTypeCreateShoutout,
	HONSelfieCameraSubmitTypeReplyShoutout,
	
	HONSelfieCameraSubmitTypeCreateMessage,
	HONSelfieCameraSubmitTypeReplyMessage
};


@interface HONChallengeVO : NSObject
+ (HONChallengeVO *)challengeWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int challengeID;
@property (nonatomic) int clubID;
@property (nonatomic) int statusID;
@property (nonatomic, assign) HONPhotoSubmitType photoSubmitType;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSArray *subjectNames;
@property (nonatomic) int likedByTotal;
@property (nonatomic) int totalLikes;
@property (nonatomic) BOOL hasViewed;
@property (nonatomic, retain) NSDate *addedDate;
@property (nonatomic, retain) NSDate *startedDate;
@property (nonatomic, retain) NSDate *updatedDate;

@property (nonatomic, retain) NSString *recentLikes;
@property (nonatomic, retain) HONOpponentVO *creatorVO;
@property (nonatomic, retain) NSMutableArray *challengers;


@end
