//
//  HONChallengeVO.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HONOpponentVO.h"

@interface HONChallengeVO : NSObject
+ (HONChallengeVO *)challengeWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int challengeID;
@property (nonatomic) int statusID;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *subjectName;
@property (nonatomic, retain) NSString *hashtagName;
@property (nonatomic) int commentTotal;
@property (nonatomic) int likersTotal;
@property (nonatomic) int likesTotal;
@property (nonatomic) BOOL hasViewed;
@property (nonatomic) BOOL isCelebCreated;
@property (nonatomic) BOOL isExploreChallenge;
@property (nonatomic, retain) NSDate *addedDate;
@property (nonatomic, retain) NSDate *startedDate;
@property (nonatomic, retain) NSDate *updatedDate;

@property (nonatomic, retain) NSString *recentLikes;
@property (nonatomic, retain) HONOpponentVO *creatorVO;
@property (nonatomic, retain) NSMutableArray *challengers;


@end
