//
//  HONPopularSubjectVO.h
//  HotOrNot
//
//  Created by Sparkle Mountain iMac on 9/18/12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HONPopularSubjectVO : NSObject

+ (HONPopularSubjectVO *)subjectWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic) int subjectID;
@property (nonatomic) int score;
@property (nonatomic) int actives;
@property (nonatomic, retain) NSString *subjectName;

@end
