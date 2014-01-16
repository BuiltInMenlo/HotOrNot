//
//  HONAlertItemVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 12/02/2013 @ 20:41 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONAlertItemVO.h"

@implementation HONAlertItemVO
@synthesize dictionary;
@synthesize alertID, triggerType, userID, username, avatarPrefix, message, sentDate;

+ (HONAlertItemVO *)alertWithDictionary:(NSDictionary *)dictionary {
	HONAlertItemVO *vo = [[HONAlertItemVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.alertID = [dictionary objectForKey:@"id"];
	vo.triggerType = [[dictionary objectForKey:@"activity_type"] intValue];
	vo.message = [dictionary objectForKey:@"message"];
	
	vo.userID = [[[dictionary objectForKey:@"user"] objectForKey:@"id"] intValue];
	vo.username = [[dictionary objectForKey:@"user"] objectForKey:@"username"];
	vo.avatarPrefix = [HONAppDelegate cleanImagePrefixURL:[[dictionary objectForKey:@"user"] objectForKey:@"avatar_url"]];
	
	vo.challengeID = [[dictionary objectForKey:@"challengeID"] intValue];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	vo.sentDate = [dateFormat dateFromString:[dictionary objectForKey:@"time"]];
	
	return (vo);
}


- (void)dealloc {
	self.dictionary = nil;
	self.username = nil;
	self.avatarPrefix = nil;
	self.message = nil;
	self.sentDate = nil;
}


@end
