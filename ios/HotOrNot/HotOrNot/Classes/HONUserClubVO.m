//
//  HONUserClubVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 02/24/2014 @ 14:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONUserClubVO.h"
#import "HONClubPhotoVO.h"

@implementation HONUserClubVO
@synthesize dictionary;
@synthesize clubID, clubType, totalPendingMembers, totalActiveMembers, totalBannedMembers, clubName, coverImagePrefix, blurb, addedDate, updatedDate, ownerID, ownerName, ownerImagePrefix, submissions, totalSubmissions;

+ (HONUserClubVO *)clubWithDictionary:(NSDictionary *)dictionary {
	HONUserClubVO *vo = [[HONUserClubVO alloc] init];
	vo.dictionary = dictionary;
	
//	NSLog(@"DICTIONARY:[%@]\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n", dictionary);
	
//	for (NSString *param in dictionary)
//		NSLog(@"NAME:[%@]", param);
	
//	NSLog(@"NAME:[%@]", [dictionary objectForKey:@"name"]);
//	NSLog(@"DICTIONARY[%@]\nOWNER:[%@]\nMEMBERS:[%@]:\n%@\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n", dictionary, [dictionary objectForKey:@"owner"], [dictionary objectForKey:@"members"], [dictionary objectForKey:@"added"]);
	
	vo.clubID = [[dictionary objectForKey:@"id"] intValue];
	vo.clubName = [dictionary objectForKey:@"name"];
	vo.blurb = [dictionary objectForKey:@"description"];
	vo.coverImagePrefix = ([dictionary objectForKey:@"img"] != nil && [[dictionary objectForKey:@"img"] length] > 0) ? [HONAppDelegate cleanImagePrefixURL:[dictionary objectForKey:@"img"]] : [[HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsCloudFront] stringByAppendingString:@"/defaultClubCover"];
	vo.addedDate = [[HONDateTimeStipulator sharedInstance] dateFromOrthodoxFormattedString:[dictionary objectForKey:@"added"]];
	vo.updatedDate = [[HONDateTimeStipulator sharedInstance] dateFromOrthodoxFormattedString:[dictionary objectForKey:@"updated"]];
		
	vo.totalPendingMembers = [[dictionary objectForKey:@"pending"] count];
	vo.totalBannedMembers = [[dictionary objectForKey:@"blocked"] count];
	vo.totalActiveMembers = [[dictionary objectForKey:@"members"] count];
	
	vo.ownerID = [[[dictionary objectForKey:@"owner"] objectForKey:@"id"] intValue];
	vo.ownerName = [[dictionary objectForKey:@"owner"] objectForKey:@"username"];
	vo.ownerImagePrefix = [HONAppDelegate cleanImagePrefixURL:([[dictionary objectForKey:@"owner"] objectForKey:@"avatar"] != nil) ? [[dictionary objectForKey:@"owner"] objectForKey:@"avatar"] : [[HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsCloudFront] stringByAppendingString:@"/defaultAvatar"]];
	
	NSMutableArray *submissions = [NSMutableArray array];
	for (NSDictionary *dict in [dictionary objectForKey:@"submissions"])
		[submissions addObject:[HONClubPhotoVO clubPhotoWithDictionary:dict]];
	vo.submissions = [submissions copy];
	
	return (vo);
}


- (void)dealloc {
	self.dictionary = nil;
	self.clubName = nil;
	self.blurb = nil;
	self.coverImagePrefix = nil;
	self.addedDate = nil;
	self.updatedDate = nil;
	self.ownerName = nil;
	self.ownerImagePrefix = nil;
	self.submissions = nil;
}

@end
