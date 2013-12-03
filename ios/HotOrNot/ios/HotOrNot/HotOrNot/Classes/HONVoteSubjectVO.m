//
//  HONVoteSubjectVO.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.30.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONVoteSubjectVO.h"

@implementation HONVoteSubjectVO

@synthesize dictionary;
@synthesize subjectID, subjectName, challenges;

+ (HONVoteSubjectVO *)subjectWithDictionary:(NSDictionary *)dictionary {
	HONVoteSubjectVO *vo = [[HONVoteSubjectVO alloc] init];
	vo.dictionary = dictionary;
	
//	vo.subjectID = [[dictionary objectForKey:@"id"] intValue];
//	vo.subjectName = [dictionary objectForKey:@"title"];
//	vo.challenges = [dictionary objectForKey:@"challenges"];
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.subjectName = nil;
	self.challenges = nil;
}

@end
