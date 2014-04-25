//
//  HONVoterVO.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

@interface HONVoterVO : NSObject
+ (HONVoterVO *)voterWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int userID;
@property (nonatomic) int points;
@property (nonatomic) int votes;
@property (nonatomic) int pokes;
@property (nonatomic) int score;
@property (nonatomic) int challenges;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, retain) NSString *fbID;
@property (nonatomic, retain) NSString *challengerName;
@property (nonatomic, retain) NSDate *addedDate;

@end
