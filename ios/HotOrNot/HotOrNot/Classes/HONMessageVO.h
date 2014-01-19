//
//  HONMessageVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 01/18/2014 @ 20:40 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HONOpponentVO.h"

@interface HONMessageVO : NSObject
+ (HONMessageVO *)messageWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int messageID;
@property (nonatomic) int statusID;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *subjectName;
@property (nonatomic, retain) NSString *hashtagName;
@property (nonatomic) BOOL hasViewed;
@property (nonatomic, retain) NSDate *addedDate;
@property (nonatomic, retain) NSDate *startedDate;
@property (nonatomic, retain) NSDate *updatedDate;

@property (nonatomic, retain) HONOpponentVO *creatorVO;
@property (nonatomic, retain) NSMutableArray *challengers;
@end
