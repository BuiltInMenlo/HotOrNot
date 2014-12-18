//
//  HONStatusUpdateVO.m
//  HotOrNot
//
//  Created by BIM  on 12/13/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+Operations.h"

#import "HONStatusUpdateVO.h"

@implementation HONStatusUpdateVO
@synthesize statusUpdateID, clubID, userID, imagePrefix, composeImageVO, comment, score, addedDate, updatedDate;

+ (HONStatusUpdateVO *)statusUpdateWithDictionary:(NSDictionary *)dictionary {
	HONStatusUpdateVO *vo = [[HONStatusUpdateVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.statusUpdateID = [[dictionary objectForKey:@"id"] intValue];
	vo.clubID = [[dictionary objectForKey:@"club_id"] intValue];
	vo.userID = [[dictionary objectForKey:@"owner_member_id"] intValue];
	vo.imagePrefix = [[HONAPICaller sharedInstance] normalizePrefixForImageURL:([dictionary objectForKey:@"img"] != [NSNull null]) ? [dictionary objectForKey:@"img"] : [[HONClubAssistant sharedInstance] defaultStatusUpdatePhotoURL]];
	vo.composeImageVO = [[HONClubAssistant sharedInstance] composeImageForStatusUpdate:vo];
	vo.comment = [dictionary objectForKey:@"text"];
	vo.score = ([dictionary objectForKey:@"net_vote_score"] != [NSNull null]) ? [[dictionary objectForKey:@"net_vote_score"] intValue] : 0;
	vo.addedDate = [NSDate dateFromISO9601FormattedString:[dictionary objectForKey:@"added"]];
	vo.updatedDate = [NSDate dateFromISO9601FormattedString:[dictionary objectForKey:@"updated"]];
	
	vo.formattedProperties = [NSString stringWithFormat:@".statusUpdateID  : [%d]\n", vo.statusUpdateID];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".clubID          : [%d]\n", vo.clubID];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".userID          : [%d]\n", vo.userID];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".imagePrefix     : [%@]\n", vo.imagePrefix];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".composeImageVO  : [%@]\n", vo.composeImageVO];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".comment         : [%@]\n", vo.imagePrefix];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".score           : [%d]\n", vo.score];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".addedDate       : [%@]\n", vo.addedDate];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".updatedDate     : [%@]\n", vo.updatedDate];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".dictionary      : [%@]", vo.dictionary];
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.imagePrefix = nil;
	self.composeImageVO = nil;
	self.comment = nil;
	self.addedDate = nil;
	self.updatedDate = nil;
}

@end
