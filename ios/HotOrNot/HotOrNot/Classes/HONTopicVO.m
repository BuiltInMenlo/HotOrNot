//
//  HONComposeTopicVO.m
//  HotOrNot
//
//  Created by BIM  on 12/12/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+BuiltinMenlo.h"

#import "HONTopicVO.h"

@implementation HONTopicVO
@synthesize topicID, parentID, topicName, iconURL, appStoreURL, score, addedDate;

+ (HONTopicVO *)topicWithDictionary:(NSDictionary *)dictionary {
	HONTopicVO *vo = [[HONTopicVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.topicID = [[dictionary objectForKey:@"id"] intValue];
	vo.parentID = [[dictionary objectForKey:@"parent_id"] intValue];
	vo.topicName = [dictionary objectForKey:@"name"];
	vo.iconURL = [dictionary objectForKey:@"img"];
	vo.appStoreURL = [dictionary objectForKey:@"url"];
	vo.addedDate = [NSDate dateFromISO9601FormattedString:[dictionary objectForKey:@"added"]];
	
	vo.formattedProperties = [NSString stringWithFormat:@".topicID		: [%d]\n", vo.topicID];
	vo.formattedProperties = [NSString stringWithFormat:@".parentID	: [%d]\n", vo.parentID];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".topicName	: [%@]\n", vo.topicName];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".iconURL		: [%@]\n", vo.iconURL];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".score		: [%d]\n", vo.score];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".addedDate	: [%@]\n", vo.addedDate];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".dictionary	: [%@]", vo.dictionary];
	
	return (vo);
}


- (void)dealloc {
	self.dictionary = nil;
	self.topicName = nil;
	self.iconURL = nil;
	self.appStoreURL = nil;
	self.addedDate = nil;
}

@end
