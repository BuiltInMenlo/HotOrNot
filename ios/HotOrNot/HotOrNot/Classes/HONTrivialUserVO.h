//
//  HONTrivialUserVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 01/23/2014 @ 09:43 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONActivityItemVO.h"
#import "HONOpponentVO.h"
#import "HONUserVO.h"

@interface HONTrivialUserVO : NSObject
+ (HONTrivialUserVO *)userWithDictionary:(NSDictionary *)dictionary;
+ (HONTrivialUserVO *)userFromActivityItemVO:(HONActivityItemVO *)activityItemVO;
+ (HONTrivialUserVO *)userFromOpponentVO:(HONOpponentVO *)opponentVO;
+ (HONTrivialUserVO *)userFromUserVO:(HONUserVO *)userVO;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int userID;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *avatarPrefix;
@property (nonatomic, retain) NSString *altID;
@property (nonatomic, retain) NSString *phoneNumber;
@property (nonatomic) BOOL isVerified;
@property (nonatomic) int abuseCount;
@end
