//
//  HONStatusUpdateVO.h
//  HotOrNot
//
//  Created by BIM  on 12/13/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONBaseVO.h"
#import "HONTopicVO.h"
#import "HONSubjectVO.h"

@interface HONStatusUpdateVO : HONBaseVO
+ (HONStatusUpdateVO *)statusUpdateWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic) int statusUpdateID;
@property (nonatomic) int clubID;
@property (nonatomic) int userID;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *imagePrefix;
@property (nonatomic, retain) NSString *topicName;
@property (nonatomic, retain) NSString *subjectName;
//@property (nonatomic, retain) HONTopicVO *topicVO;
//@property (nonatomic, retain) HONSubjectVO *subjectVO;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic) int score;
@property (nonatomic, retain) NSDate *addedDate;
@property (nonatomic, retain) NSDate *updatedDate;

@end
