//
//  HONUserVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 01/23/2014 @ 09:43 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONActivityItemVO.h"
#import "HONOpponentVO.h"

@class HONContactUserVO;
@interface HONUserVO : NSObject
+ (HONUserVO *)userWithDictionary:(NSDictionary *)dictionary;
+ (HONUserVO *)userFromActivityItemVO:(HONActivityItemVO *)activityItemVO;
+ (HONUserVO *)userFromContactUserVO:(HONContactUserVO *)contactUserVO;
+ (HONUserVO *)userFromOpponentVO:(HONOpponentVO *)opponentVO;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int userID;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *avatarPrefix;
@property (nonatomic, retain) NSString *altID;
@property (nonatomic, retain) NSString *phoneNumber;
@property (nonatomic, retain) NSDate *invitedDate;
@property (nonatomic, retain) NSDate *joinedDate;
@property (nonatomic) int voteScore;
@property (nonatomic) BOOL isVerified;
@end
