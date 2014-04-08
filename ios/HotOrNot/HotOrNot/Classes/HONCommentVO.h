//
//  HONCommentVO.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 02.20.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

@interface HONCommentVO : NSObject
+ (HONCommentVO *)commentWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic) int commentID;
@property (nonatomic) int challengeID;
@property (nonatomic) int userID;
@property (nonatomic, retain) NSString *fbID;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *avatarPrefix;
@property (nonatomic) int userScore;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSDate *addedDate;
@end
