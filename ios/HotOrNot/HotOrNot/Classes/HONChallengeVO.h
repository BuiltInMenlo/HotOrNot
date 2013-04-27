//
//  HONChallengeVO.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HONChallengeVO : NSObject
+ (HONChallengeVO *)challengeWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int challengeID;
@property (nonatomic) int statusID;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *subjectName;
@property (nonatomic) int commentTotal;
@property (nonatomic) BOOL hasViewed;
@property (nonatomic, retain) NSString *rechallengedUsers;
@property (nonatomic, retain) NSDate *addedDate;
@property (nonatomic, retain) NSDate *startedDate;
@property (nonatomic, retain) NSDate *updatedDate;

@property (nonatomic) int creatorID;
@property (nonatomic, retain) NSString *creatorFB;
@property (nonatomic, retain) NSString *creatorName;
@property (nonatomic, retain) NSString *creatorAvatar;
@property (nonatomic, retain) NSString *creatorImgPrefix;
@property (nonatomic) int creatorScore;

@property (nonatomic) int challengerID;
@property (nonatomic, retain) NSString *challengerFB;
@property (nonatomic, retain) NSString *challengerName;
@property (nonatomic, retain) NSString *challengerAvatar;
@property (nonatomic, retain) NSString *challengerImgPrefix;
@property (nonatomic) int challengerScore;

@end
