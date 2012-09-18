//
//  HONPopularSubjectVO.m
//  HotOrNot
//
//  Created by Sparkle Mountain iMac on 9/18/12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONPopularSubjectVO.h"

@implementation HONPopularSubjectVO

@synthesize dictionary;
@synthesize subjectID, subjectName, score;

+ (HONPopularSubjectVO *)subjectWithDictionary:(NSDictionary *)dictionary {
	HONPopularSubjectVO *vo = [[HONPopularSubjectVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.subjectID = [[dictionary objectForKey:@"id"] intValue];
	vo.score = [[dictionary objectForKey:@"score"] intValue];
	vo.subjectName = [dictionary objectForKey:@"name"];
	vo.imageURL = [dictionary objectForKey:@"img_url"];
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.subjectName = nil;
	self.imageURL = nil;
}

@end
