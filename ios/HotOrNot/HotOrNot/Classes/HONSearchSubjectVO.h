//
//  HONSubjectVO.h
//  HotOrNot
//
//  Created by Matt Holcombe on 9/18/12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HONSearchSubjectVO : NSObject
+ (HONSearchSubjectVO *)subjectWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int subjectID;
@property (nonatomic) int score;
@property (nonatomic) int actives;
@property (nonatomic, retain) NSString *subjectName;

@end
