//
//  HONCommentVO.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 02.20.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+Operations.h"
#import "NSUserDefaults+Replacements.h"

#import "HONCommentVO.h"


@implementation HONCommentVO

@synthesize dictionary;
@synthesize commentID, clubID, parentID, userID, username, avatarPrefix, score, textContent, addedDate;

+ (HONCommentVO *)commentWithDictionary:(NSDictionary *)dictionary {
	HONCommentVO *vo = [[HONCommentVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.commentID = [[dictionary objectForKey:@"id"] intValue];
	vo.clubID = [[dictionary objectForKey:@"club_id"] intValue];
	vo.parentID = [[dictionary objectForKey:@"parent_id"] intValue];
	vo.userID = ([dictionary objectForKey:@"owner_member"] != nil) ? [[[dictionary objectForKey:@"owner_member"] objectForKey:@"id"] intValue] : [[dictionary objectForKey:@"user_id"] intValue];
	vo.username = ([dictionary objectForKey:@"owner_member"] != nil) ? [[dictionary objectForKey:@"owner_member"] objectForKey:@"name"] : [dictionary objectForKey:@"username"];
	vo.avatarPrefix = (vo.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"] : [[HONUserAssistant sharedInstance] rndAvatarURL];
	vo.textContent = ([[dictionary objectForKey:@"text"] length] > 0) ? [dictionary objectForKey:@"text"] : @"N/A";
	vo.score = [[dictionary objectForKey:@"score"] intValue];
	vo.addedDate = [NSDate dateFromISO9601FormattedString:[dictionary objectForKey:@"added"]];
	
	__block BOOL isFound = NO;
	NSString *avatarKey = NSStringFromInt(vo.userID);
	[[[NSUserDefaults standardUserDefaults] objectForKey:@"avatars"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if ([(NSString *)key isEqualToString:avatarKey]) {
			isFound = YES;
			vo.avatarPrefix = [[[NSUserDefaults standardUserDefaults] objectForKey:@"avatars"] objectForKey:avatarKey];
		}
		
		*stop = isFound;
	}];
	
	
	if (!isFound) {
		NSMutableDictionary *avatars = [[[NSUserDefaults standardUserDefaults] objectForKey:@"avatars"] mutableCopy];
		[avatars setValue:[[HONUserAssistant sharedInstance] rndAvatarURL] forKey:avatarKey];
		
		[[NSUserDefaults standardUserDefaults] setObject:[avatars copy] forKey:@"avatars"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		vo.avatarPrefix = [[[NSUserDefaults standardUserDefaults] objectForKey:@"avatars"] objectForKey:avatarKey];
		
//		vo.avatarPrefix = [[[NSUserDefaults standardUserDefaults] objectForKey:@"avatars"] objectForKey:[@"a_" stringByAppendingString:[dictionary objectForKey:@"id"]]];
//
//	} else {
//		NSMutableDictionary *avatars = [[[NSUserDefaults standardUserDefaults] objectForKey:@"avatars"] mutableCopy];
//		[avatars setValue:[[HONUserAssistant sharedInstance] rndAvatarURL] forKey:[@"a_" stringByAppendingString:[dictionary objectForKey:@"id"]]];
//		[[NSUserDefaults standardUserDefaults] setObject:[avatars copy] forKey:@"avatars"];
//		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	return (vo);
}

+ (HONCommentVO *)commentWithClubPhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSDictionary *dict = @{@"id"		: @(clubPhotoVO.challengeID),
						   @"club_id"	: @(clubPhotoVO.clubID),
						   @"parent_id"	: @(clubPhotoVO.parentID),
						   @"user_id"	: @(clubPhotoVO.userID),
						   @"username"	: clubPhotoVO.username,
						   @"text"		: clubPhotoVO.comment,
						   @"score"		: @(clubPhotoVO.score),
						   @"added"		: [clubPhotoVO.addedDate formattedISO8601StringUTC]};
	
	return ([HONCommentVO commentWithDictionary:dict]);
}

- (void)dealloc {
	self.dictionary = nil;
	self.username = nil;
	self.avatarPrefix = nil;
	self.textContent = nil;
	self.addedDate = nil;
}

@end
