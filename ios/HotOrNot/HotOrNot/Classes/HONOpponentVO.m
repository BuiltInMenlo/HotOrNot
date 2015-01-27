//
//  HONOpponentVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/6/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+BuiltinMenlo.h"

#import "HONOpponentVO.h"

@implementation HONOpponentVO

@synthesize dictionary;
@synthesize userID, subjectName, username, avatarPrefix, imagePrefix, joinedDate, score;

+ (HONOpponentVO *)opponentWithDictionary:(NSDictionary *)dictionary {
	HONOpponentVO *vo = [[HONOpponentVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.userID = [[dictionary objectForKey:@"id"] intValue];
	vo.subjectNames = [dictionary objectForKey:@"subjects"];
	vo.subjectName = [[vo.subjectNames firstObject] stringByReplacingOccurrencesOfString:@"#" withString:@""];
	vo.username = [dictionary objectForKey:@"username"];
	
	vo.imagePrefix = [[HONAPICaller sharedInstance] normalizePrefixForImageURL:([dictionary objectForKey:@"img"] != [NSNull null]) ? [dictionary objectForKey:@"img"] : @""];
	vo.avatarPrefix = [[HONAPICaller sharedInstance] normalizePrefixForImageURL:([dictionary objectForKey:@"avatar"] != [NSNull null]) ? [dictionary objectForKey:@"avatar"] : vo.imagePrefix];
	vo.score = [[dictionary objectForKey:@"score"] intValue];
	
	vo.joinedDate = [NSDate dateFromOrthodoxFormattedString:[dictionary objectForKey:@"joined"]];
		
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.subjectName = nil;
	self.subjectNames = nil;
	self.username = nil;
	self.avatarPrefix = nil;
	self.imagePrefix = nil;
	self.joinedDate = nil;
}

@end
