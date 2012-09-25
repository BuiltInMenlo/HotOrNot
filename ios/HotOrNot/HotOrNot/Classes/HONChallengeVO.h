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
@property (nonatomic) int creatorID;
@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, retain) NSString *image2URL;
@property (nonatomic) int scoreCreator;
@property (nonatomic) int scoreChallenger;
@property (nonatomic, retain) NSString *subjectName;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *creatorName;
@property (nonatomic, retain) NSDate *startedDate;
@property (nonatomic, retain) NSDate *endDate;

@end
