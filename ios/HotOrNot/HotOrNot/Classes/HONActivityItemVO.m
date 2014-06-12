//
//  HONActivityItemVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 12/02/2013 @ 20:41 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONActivityItemVO.m"

@implementation HONActivityItemVO
@synthesize dictionary;
@synthesize activityID, activityType, userID, username, avatarPrefix, message, sentDate;

+ (HONActivityItemVO *)activityWithDictionary:(NSDictionary *)dictionary {
	HONActivityItemVO *vo = [[HONActivityItemVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.activityID = [dictionary objectForKey:@"id"];
	vo.activityType = [[dictionary objectForKey:@"activity_type"] intValue];
	vo.message = [dictionary objectForKey:@"message"];
	
	vo.userID = [[[dictionary objectForKey:@"user"] objectForKey:@"id"] intValue];
	vo.username = [[dictionary objectForKey:@"user"] objectForKey:@"username"];
	vo.avatarPrefix = [HONAppDelegate cleanImagePrefixURL:[[dictionary objectForKey:@"user"] objectForKey:@"avatar_url"]];
	
	vo.challengeID = ([dictionary objectForKey:@"challengeID"] != [NSNull null]) ? [[dictionary objectForKey:@"challengeID"] intValue] : -1;
	vo.sentDate = [[HONDateTimeStipulator sharedInstance] dateFromOrthodoxFormattedString:[dictionary objectForKey:@"time"]];
	
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
