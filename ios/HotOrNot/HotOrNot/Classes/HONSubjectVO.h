//
//  HONSubjectVO.h
//  HotOrNot
//
//  Created by BIM  on 12/13/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONBaseVO.h"

typedef NS_ENUM(NSUInteger, HONSubjectUseType) {
	HONSubjectUseTypeUnassigned	= 0,
	HONSubjectUseTypeDisabled,
	HONSubjectUseTypeCompose,
	HONSubjectUseTypeReply,
	HONSubjectUseTypeSpecial
};

@interface HONSubjectVO : HONBaseVO
+ (HONSubjectVO *)subjectWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic) int subjectID;
@property (nonatomic, retain) NSString *subjectName;
@property (nonatomic) int score;
@property (nonatomic, assign) HONSubjectUseType useType;
@property (nonatomic, retain) NSDate *addedDate;

@end
