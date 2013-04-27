//
//  HONVoteSubjectVO.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.30.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HONVoteSubjectVO : NSObject
+ (HONVoteSubjectVO *)subjectWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int subjectID;
@property (nonatomic, retain) NSString *subjectName;
@property (nonatomic, retain) NSArray *challenges;

@end
