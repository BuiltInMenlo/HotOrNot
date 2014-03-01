//
//  HONTrivialUserVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/23/2014 @ 09:43 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONTrivialUserVO.h"

@implementation HONTrivialUserVO
@synthesize dictionary;
@synthesize userID, username, avatarPrefix;

+ (HONTrivialUserVO *)userWithDictionary:(NSDictionary *)dictionary {
	HONTrivialUserVO *vo = [[HONTrivialUserVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.userID = [[dictionary objectForKey:@"id"] intValue];
	vo.username = [dictionary objectForKey:@"username"];
	vo.avatarPrefix = [HONAppDelegate cleanImagePrefixURL:[dictionary objectForKey:@"img_url"]];
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.username = nil;
	self.avatarPrefix = nil;
}
@end
