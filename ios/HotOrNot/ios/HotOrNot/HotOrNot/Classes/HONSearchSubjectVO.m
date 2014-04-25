//
//  HONSubjectVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/18/12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONSearchSubjectVO.h"

@implementation HONSearchSubjectVO

@synthesize dictionary;
@synthesize subjectID, subjectName, score, actives;

+ (HONSearchSubjectVO *)subjectWithDictionary:(NSDictionary *)dictionary {
	HONSearchSubjectVO *vo = [[HONSearchSubjectVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.subjectID = [[dictionary objectForKey:@"id"] intValue];
	vo.score = [[dictionary objectForKey:@"score"] intValue];
	vo.actives = [[dictionary objectForKey:@"active"] intValue];
	vo.subjectName = [dictionary objectForKey:@"name"];
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.subjectName = nil;
}

@end
