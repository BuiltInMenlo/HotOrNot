//
//  HONClubSubmissionVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/11/2014 @ 09:21 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONClubPhotoVO.h"

@implementation HONClubPhotoVO
@synthesize dictionary, userID, username, avatarPrefix, challengeID, clubID, imagePrefix, subjectNames, addedDate, score;

+ (HONClubPhotoVO *)clubPhotoWithDictionary:(NSDictionary *)dictionary {
	HONClubPhotoVO *vo = [[HONClubPhotoVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.userID = [[dictionary objectForKey:@"id"] intValue];
	vo.username = [dictionary objectForKey:@"username"];
	vo.avatarPrefix = [HONAppDelegate cleanImagePrefixURL:([dictionary objectForKey:@"avatar"] != [NSNull null]) ? [dictionary objectForKey:@"avatar"] : vo.imagePrefix];
	
	vo.imagePrefix = [HONAppDelegate cleanImagePrefixURL:([dictionary objectForKey:@"img"] != [NSNull null]) ? [dictionary objectForKey:@"img"] : @""];
	vo.subjectNames = [dictionary objectForKey:@"subjects"];
	vo.score = [[dictionary objectForKey:@"score"] intValue];
	vo.addedDate = [[HONDateTimeStipulator sharedInstance] dateFromOrthodoxFormattedString:[dictionary objectForKey:@"added"]];
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.username = nil;
	self.avatarPrefix = nil;
	self.imagePrefix = nil;
	self.subjectNames = nil;
	self.addedDate = nil;
}

@end
