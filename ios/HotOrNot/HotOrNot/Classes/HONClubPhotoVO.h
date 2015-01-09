//
//  HONClubSubmissionVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 06/11/2014 @ 09:21 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONTopicVO.h"

typedef NS_ENUM(NSUInteger, HONClubPhotoSubmissionType) {
	HONClubPhotoSubmissionTypePhoto = 0,
	HONClubPhotoSubmissionTypeComment
};


@interface HONClubPhotoVO : NSObject
+ (HONClubPhotoVO *)clubPhotoWithDictionary:(NSDictionary *)dictionary;
@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int userID;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *avatarPrefix;

@property (nonatomic) int challengeID;
@property (nonatomic) int parentID;
@property (nonatomic) int clubID;
@property (nonatomic) int clubOwnerID;
@property (nonatomic, retain) NSString *imagePrefix;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic, retain) NSArray *subjectNames;
@property (nonatomic, retain) HONTopicVO *topicVO;
@property (nonatomic, retain) NSDate *addedDate;
@property (nonatomic) int score;
@property (nonatomic, assign) HONClubPhotoSubmissionType submissionType;
@end

