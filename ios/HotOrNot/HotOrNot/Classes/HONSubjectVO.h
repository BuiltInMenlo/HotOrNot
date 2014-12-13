//
//  HONSubjectVO.h
//  HotOrNot
//
//  Created by BIM  on 12/13/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONBaseVO.h"

@interface HONSubjectVO : HONBaseVO
+ (HONSubjectVO *)subjectWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic) int subjectID;
@property (nonatomic, retain) NSString *subjectName;
@property (nonatomic) int score;
@property (nonatomic, retain) NSDate *addedDate;

@end
