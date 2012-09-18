//
//  HONPopularUserVO.m
//  HotOrNot
//
//  Created by Sparkle Mountain iMac on 9/18/12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONPopularUserVO.h"

@implementation HONPopularUserVO

@synthesize dictionary;
@synthesize userID, username, score, imageURL;

+ (HONPopularUserVO *)userWithDictionary:(NSDictionary *)dictionary {
	HONPopularUserVO *vo = [[HONPopularUserVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.userID = [[dictionary objectForKey:@"id"] intValue];
	vo.score = [[dictionary objectForKey:@"score"] intValue];
	vo.username = [dictionary objectForKey:@"username"];
	vo.imageURL = [dictionary objectForKey:@"img_url"];
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.username = nil;
	self.imageURL = nil;
}

@end
