//
//  HONUserVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 9/18/12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

@interface HONUserVO : NSObject
+ (HONUserVO *)userWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int userID;
@property (nonatomic) int points;
@property (nonatomic) int votes;
@property (nonatomic) int score;
@property (nonatomic) int abuseCount;
@property (nonatomic) int totalVolleys;
@property (nonatomic) BOOL isVerified;
@property (nonatomic) BOOL isSuspended;
@property (nonatomic, retain) NSDate *birthday;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *avatarPrefix;
@property (nonatomic, retain) NSMutableArray *friends;

@end
