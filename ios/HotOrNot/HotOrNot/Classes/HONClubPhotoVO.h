//
//  HONClubSubmissionVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 06/11/2014 @ 09:21 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


typedef NS_ENUM(NSUInteger, HONClubPhotoType) {
	HONClubPhotoTypePNG = 0,
	HONClubPhotoTypeJPG,
	HONClubPhotoTypeGIF
};


@interface HONClubPhotoVO : NSObject
+ (HONClubPhotoVO *)clubPhotoWithDictionary:(NSDictionary *)dictionary;
@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int userID;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *avatarPrefix;

@property (nonatomic) int challengeID;
@property (nonatomic) int clubID;
@property (nonatomic, retain) NSString *imagePrefix;
@property (nonatomic, retain) NSArray *subjectNames;
@property (nonatomic, retain) NSDate *addedDate;
@property (nonatomic) int score;
@property (nonatomic) HONClubPhotoType photoType;
@end

