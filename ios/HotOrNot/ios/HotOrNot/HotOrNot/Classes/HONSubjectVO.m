//
//  HONSubjectVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/18/12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONSubjectVO.h"

@implementation HONSubjectVO

@synthesize dictionary;
@synthesize subjectID, subjectName, score, actives;

+ (HONSubjectVO *)subjectWithDictionary:(NSDictionary *)dictionary {
	HONSubjectVO *vo = [[HONSubjectVO alloc] init];
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
