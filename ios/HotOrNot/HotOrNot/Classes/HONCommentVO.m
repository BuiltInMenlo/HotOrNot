//
//  HONCommentVO.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 02.20.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+BuiltinMenlo.h"
#import "NSDictionary+BuiltinMenlo.h"
#import "NSString+BuiltinMenlo.h"

#import "PubNub+BuiltInMenlo.h"

#import "HONCommentVO.h"


@implementation HONCommentVO

@synthesize dictionary;
@synthesize commentID, messageID, clubID, parentID, userID, location, username, avatarPrefix, commentStatusType, score, textContent, imageContent, addedDate;

+ (HONCommentVO *)commentWithDictionary:(NSDictionary *)dictionary {
	HONCommentVO *vo = [[HONCommentVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.commentID = [[dictionary objectForKey:@"id"] intValue];
	vo.messageID = ([dictionary objectForKey:@"msg_id"] != nil) ? [dictionary objectForKey:@"msg_id"] : [dictionary objectForKey:@"id"];
	vo.clubID = ([dictionary objectForKey:@"club_id"] != nil) ? [[dictionary objectForKey:@"club_id"] intValue] : [[HONClubAssistant sharedInstance] globalClub].clubID;
	vo.parentID = [[dictionary objectForKey:@"parent_id"] intValue];
	vo.userID = ([dictionary objectForKey:@"owner_member"] != nil) ? [[[dictionary objectForKey:@"owner_member"] objectForKey:@"id"] intValue] : [[dictionary objectForKey:@"user_id"] intValue];
	
	vo.commentStatusType = HONCommentStatusTypeUnknown;
	vo.username = ([dictionary objectForKey:@"owner_member"] != nil) ? [[dictionary objectForKey:@"owner_member"] objectForKey:@"name"] : [dictionary objectForKey:@"username"];
	vo.avatarPrefix = (vo.userID == [[HONUserAssistant sharedInstance] activeUserID]) ? [[HONUserAssistant sharedInstance] activeUserAvatarURL] : [[HONUserAssistant sharedInstance] rndAvatarURL];
	vo.textContent = ([[dictionary objectForKey:@"text"] length] > 0) ? [dictionary objectForKey:@"text"] : @"";
//	vo.imageContent = ([dictionary objectForKey:@"image"] != nil) ? [UIImage imageWithData:[dictionary objectForKey:@"image"]] : [[UIImage alloc] init];
	vo.imageContent = [[UIImage alloc] init];
	
	NSString *coordComp = [[[dictionary objectForKey:@"image"] componentsSeparatedByString:@"//"] lastObject];
	NSLog(@"COORDS:[%@]", coordComp);
	vo.location = [[CLLocation alloc] initWithLatitude:[[[coordComp componentsSeparatedByString:@"_"] firstObject] doubleValue] longitude:[[[coordComp componentsSeparatedByString:@"_"] lastObject] doubleValue]];
	
	vo.score = [[dictionary objectForKey:@"score"] intValue];
	vo.addedDate = [NSDate dateFromISO9601FormattedString:[dictionary objectForKey:@"added"]];
	vo.commentContentType = ([dictionary objectForKey:@"content_type"] != nil) ? (HONCommentContentType)[[dictionary objectForKey:@"content_type"] intValue] : HONCommentContentTypeUnknown;
	
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
						   @"added"		: [clubPhotoVO.addedDate formattedISO8601String]};
	
	return ([HONCommentVO commentWithDictionary:dict]);
}

+ (HONCommentVO *)commentWithMessage:(PNMessage *)message {
	NSLog(@"commentWithMessage:%@", message.message);
	
	NSMutableDictionary *dict = [@{@"id"				: @"0",
								   @"msg_id"			: @"0",
								   @"content_type"		: ([[message.message lastComponentByDelimeter:@"|"] isEqualToString:@"__SYN__"]) ? @((int)HONCommentContentTypeSYN) : ([[message.message lastComponentByDelimeter:@"|"] isEqualToString:@"__BYE__"]) ? @((int)HONCommentContentTypeBYE) : ([[[message.message lastComponentByDelimeter:@"|"] stringByReplacingOccurrencesOfString:@"__ACK__" withString:@""] isNumeric]) ? @((int)HONCommentContentTypeACK) : @((int)HONCommentContentTypeText),
								   
								   @"owner_member"		: @{@"id"	: @([[message.message firstComponentByDelimeter:@"|"] intValue]),
															@"name"	: ([[message.message firstComponentByDelimeter:@"|"] intValue] == [[HONUserAssistant sharedInstance] activeUserID]) ? @"You" : ([[message.message firstComponentByDelimeter:@"|"] isNumeric]) ? @"anon" : [message.message firstComponentByDelimeter:@"|"]},
								   
								   @"image"				: [@"coords://" stringByAppendingFormat:@"%.04f_%.04f", [[[[[message.message componentsSeparatedByString:@"|"] objectAtIndex:1] componentsSeparatedByString:@"_"] firstObject] floatValue], [[[[[message.message componentsSeparatedByString:@"|"] objectAtIndex:1] componentsSeparatedByString:@"_"] lastObject] floatValue]],
								   @"text"				: [[message.message lastComponentByDelimeter:@"|"] stringByReplacingOccurrencesOfString:@"__ACK__" withString:@""],
								   
								   @"net_vote_score"	: @(0),
								   @"status"			: NSStringFromInt(0),
								   @"added"				: (message.date != nil) ? [message.date.date formattedISO8601String] : [NSDate stringFormattedISO8601],
								   @"updated"			: (message.date != nil) ? [message.date.date formattedISO8601String] : [NSDate stringFormattedISO8601]} mutableCopy];
	
	NSLog(@"MESSAGE -> COMMENT:[%@]", dict);
	
	return ([HONCommentVO commentWithDictionary:dict]);
}

- (void)dealloc {
	self.dictionary = nil;
	self.messageID = nil;
	self.location = nil;
	self.username = nil;
	self.avatarPrefix = nil;
	self.textContent = nil;
	self.imageContent = nil;
	self.addedDate = nil;
}

@end
