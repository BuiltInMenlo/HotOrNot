//
//  HONOpponentVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/6/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

@interface HONOpponentVO : NSObject
+ (HONOpponentVO *)opponentWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic) int userID;
@property (nonatomic, retain) NSString *subjectName;
@property (nonatomic, retain) NSArray *subjectNames;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *avatarPrefix;
@property (nonatomic, retain) NSString *imagePrefix;
@property (nonatomic, retain) NSDate *joinedDate;
@property (nonatomic, retain) NSDate *birthday;
@property (nonatomic) int score;
@end
