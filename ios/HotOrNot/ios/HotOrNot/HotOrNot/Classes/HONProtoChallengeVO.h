//
//  HONProtoChallengeVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 07:14 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


@interface HONProtoChallengeVO : NSObject
+ (HONProtoChallengeVO *)protoChallengeWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic) int userID;
@property (nonatomic) int challengeID;
@property (nonatomic) int clubID;
@property (nonatomic, retain) NSString *imgPrefix;
@property (nonatomic, retain) NSString *emotionNames;
@property (nonatomic, retain) NSString *recipients;
@end
