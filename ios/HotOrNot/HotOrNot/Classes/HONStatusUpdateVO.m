//
//  HONStatusUpdateVO.m
//  HotOrNot
//
//  Created by BIM  on 12/13/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+BuiltinMenlo.h"
#import "NSString+BuiltinMenlo.h"

#import "HONStatusUpdateVO.h"

@implementation HONStatusUpdateVO
@synthesize statusUpdateID, clubID, userID, username, imagePrefix, topicName, subjectName, appStoreURL, comment, score, replies, addedDate, updatedDate;

+ (HONStatusUpdateVO *)statusUpdateWithDictionary:(NSDictionary *)dictionary {
	HONStatusUpdateVO *vo = [[HONStatusUpdateVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.statusUpdateID = [[dictionary objectForKey:@"id"] intValue];
	vo.clubID = [[dictionary objectForKey:@"club_id"] intValue];
	vo.userID = ([dictionary objectForKey:@"owner_member"] != nil) ? [[[dictionary objectForKey:@"owner_member"] objectForKey:@"id"] intValue] : ([dictionary objectForKey:@"creator"] != nil) ? [[[dictionary objectForKey:@"creator"] objectForKey:@"id"] intValue] : [[dictionary objectForKey:@"owner_member_id"] intValue];
	vo.username = ([dictionary objectForKey:@"owner_member"] != nil) ? [[dictionary objectForKey:@"owner_member"] objectForKey:@"name"] : ([dictionary objectForKey:@"creator"] != nil) ? [[dictionary objectForKey:@"creator"] objectForKey:@"username"] : @"OP";
	vo.topicName = ([[dictionary objectForKey:@"emotions"] count] > 0) ? [[dictionary objectForKey:@"emotions"] firstObject] : @"";
	vo.subjectName = [dictionary objectForKey:@"text"];
	vo.appStoreURL = ([dictionary objectForKey:@"app_store"] != nil) ? [dictionary objectForKey:@"app_store"] : @"";//@"https://itunes.apple.com/us/app/crossy-road-endless-arcade/id924373886?mt=8";
	vo.comment = [dictionary objectForKey:@"text"];
	
	vo.username = [[HONUserAssistant sharedInstance] usernameWithDigitsStripped:vo.username];
	
	if ([[dictionary objectForKey:@"text"] isDelimitedByString:@"|"]) {
		vo.topicName = [[[dictionary objectForKey:@"text"] componentsSeparatedByString:@"|"] firstObject];
		vo.subjectName = [[[dictionary objectForKey:@"text"] componentsSeparatedByString:@"|"] lastObject];
		vo.comment = [[[dictionary objectForKey:@"text"] componentsSeparatedByString:@"|"] lastObject];
	}
	
	vo.imagePrefix = [[NSString stringWithFormat:@"https://hotornot-compose.s3.amazonaws.com/%@.png", ([vo.topicName isEqualToString:@"Feeling"]) ? vo.subjectName : [vo.topicName stringByReplacingOccurrencesOfString:@" " withString:@"%20"]] lowercaseString];//2nd-tier vo // [[HONAPICaller sharedInstance] normalizePrefixForImageURL:([dictionary objectForKey:@"img"] != [NSNull null]) ? [dictionary objectForKey:@"img"] : [[HONClubAssistant sharedInstance] defaultStatusUpdatePhotoURL]];
	
	if ([vo.topicName isEqualToString:@"Feeling"]) {
		__block BOOL isFound = NO;
		[[[NSUserDefaults standardUserDefaults] objectForKey:@"compose_topics"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			HONTopicVO *topicVO = [HONTopicVO topicWithDictionary:(NSDictionary *)obj];
			
			if ([topicVO.topicName isEqualToString:vo.subjectName])
				isFound = YES;
			
			*stop = isFound;
		}];
		
		if (!isFound)
			vo.imagePrefix = [NSString stringWithFormat:@"https://hotornot-compose.s3.amazonaws.com/%@.png", [vo.topicName lowercaseString]];
	}
	
	vo.score = ([dictionary objectForKey:@"net_vote_score"] != [NSNull null]) ? [[dictionary objectForKey:@"net_vote_score"] intValue] : 0;
	vo.replies = ([dictionary objectForKey:@"replies"] != nil || [dictionary objectForKey:@"replies"] != [NSNull null]) ? [dictionary objectForKey:@"replies"] : @[];
	vo.addedDate = [NSDate dateFromISO9601FormattedString:[dictionary objectForKey:@"added"]];
	vo.updatedDate = [NSDate dateFromISO9601FormattedString:[dictionary objectForKey:@"updated"]];
	
	vo.formattedProperties = [NSString stringWithFormat:@".statusUpdateID  : [%d]\n", vo.statusUpdateID];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".clubID          : [%d]\n", vo.clubID];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".userID          : [%d]\n", vo.userID];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".imagePrefix     : [%@]\n", vo.imagePrefix];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".topicName     : [%@]\n", vo.topicName];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".subjectName     : [%@]\n", vo.subjectName];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".comment         : [%@]\n", vo.imagePrefix];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".score           : [%d]\n", vo.score];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".addedDate       : [%@]\n", vo.addedDate];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".updatedDate     : [%@]\n", vo.updatedDate];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".replies			: [%@]\n", vo.replies];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".dictionary      : [%@]", vo.dictionary];
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.username = nil;
	self.imagePrefix = nil;
	self.topicName = nil;
	self.subjectName = nil;
	self.comment = nil;
	self.replies = nil;
	self.addedDate = nil;
	self.updatedDate = nil;
}

@end
