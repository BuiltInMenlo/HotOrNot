//
//  HONMessageRecipientVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/22/2014 @ 14:53.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONMessageRecipientVO.h"

@implementation HONMessageRecipientVO
@synthesize dictionary;
@synthesize userID, username, avatarPrefix;

+ (HONMessageRecipientVO *)recipientWithDictionary:(NSDictionary *)dictionary {
	HONMessageRecipientVO *vo = [[HONMessageRecipientVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.userID = [[dictionary objectForKey:@"id"] intValue];
	vo.username = [dictionary objectForKey:@"username"];
	vo.avatarPrefix = [dictionary objectForKey:@"avatar"];
	
	return (vo);
}


- (void)dealloc {
	self.username = nil;
	self.avatarPrefix = nil;
}

@end
