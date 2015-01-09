//
//  HONComposeTopicVO.h
//  HotOrNot
//
//  Created by BIM  on 12/12/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONBaseVO.h"

@interface HONTopicVO : HONBaseVO
+ (HONTopicVO *)topicWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic) int topicID;
@property (nonatomic) int parentID;
@property (nonatomic, retain) NSString *topicName;
@property (nonatomic, retain) NSString *iconURL;
@property (nonatomic) int score;
@property (nonatomic, retain) NSDate *addedDate;
@end
