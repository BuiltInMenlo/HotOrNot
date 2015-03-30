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
@synthesize commentID, messageID, clubID, parentID, userID, location, username, avatarPrefix, messageType, commentStatusType, score, textContent, imageContent, addedDate;

+ (HONCommentVO *)commentWithDictionary:(NSDictionary *)dictionary {
	HONCommentVO *vo = [[HONCommentVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.commentID = [[dictionary objectForKey:@"id"] intValue];
	vo.messageID = ([dictionary objectForKey:@"msg_id"] != nil) ? [dictionary objectForKey:@"msg_id"] : [dictionary objectForKey:@"id"];
	vo.clubID = ([dictionary objectForKey:@"club_id"] != nil) ? [[dictionary objectForKey:@"club_id"] intValue] : [[HONClubAssistant sharedInstance] globalClub].clubID;
	vo.parentID = [[dictionary objectForKey:@"parent_id"] intValue];
	vo.userID = ([dictionary objectForKey:@"owner_member"] != nil) ? [[[dictionary objectForKey:@"owner_member"] objectForKey:@"id"] intValue] : [[dictionary objectForKey:@"user_id"] intValue];
	vo.username = ([dictionary objectForKey:@"owner_member"] != nil) ? [[dictionary objectForKey:@"owner_member"] objectForKey:@"name"] : [dictionary objectForKey:@"username"];

	NSLog(@"content_type:[%d] // [%d]", [[dictionary objectForKey:@"content_type"] intValue], (int)vo.messageType);
	vo.avatarPrefix = (vo.userID == [[HONUserAssistant sharedInstance] activeUserID]) ? [[HONUserAssistant sharedInstance] activeUserAvatarURL] : [[HONUserAssistant sharedInstance] rndAvatarURL];
	vo.messageType = ([dictionary objectForKey:@"content_type"] != nil) ? (HONChatMessageType)[[dictionary objectForKey:@"content_type"] intValue] : HONChatMessageTypeUndefined;
	vo.textContent = ([[dictionary objectForKey:@"text"] length] > 0) ? [dictionary objectForKey:@"text"] : @"";
//	vo.imageContent = ([dictionary objectForKey:@"image"] != nil) ? [UIImage imageWithData:[dictionary objectForKey:@"image"]] : [[UIImage alloc] init];
	
	if ([[[dictionary objectForKey:@"image"] firstComponentByDelimeter:@"://"] isEqualToString:@"coords"]) {
		vo.imagePrefix = @"";
		NSString *coordComp = [[[dictionary objectForKey:@"image"] componentsSeparatedByString:@"//"] lastObject];
		vo.location = [[CLLocation alloc] initWithLatitude:[[[coordComp componentsSeparatedByString:@"_"] firstObject] doubleValue] longitude:[[[coordComp componentsSeparatedByString:@"_"] lastObject] doubleValue]];
	
	} else {
		vo.imagePrefix = [dictionary objectForKey:@"image"];
		vo.location = [[HONDeviceIntrinsics sharedInstance] deviceLocation];
		vo.textContent = (vo.messageType == HONChatMessageTypeIMG) ? @"posted a photo!" : @"posted a video!";
	}
	
	vo.score = [[dictionary objectForKey:@"score"] intValue];
	vo.addedDate = [NSDate dateFromISO9601FormattedString:[dictionary objectForKey:@"added"]];
	
//	__block BOOL isFound = NO;
//	NSString *avatarKey = NSStringFromInt(vo.userID);
//	[[[NSUserDefaults standardUserDefaults] objectForKey:@"avatars"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//		if ([(NSString *)key isEqualToString:avatarKey]) {
//			isFound = YES;
//			vo.avatarPrefix = [[[NSUserDefaults standardUserDefaults] objectForKey:@"avatars"] objectForKey:avatarKey];
//		}
//		
//		*stop = isFound;
//	}];
//	
//	
//	if (!isFound) {
//		NSMutableDictionary *avatars = [[[NSUserDefaults standardUserDefaults] objectForKey:@"avatars"] mutableCopy];
//		[avatars setValue:[[HONUserAssistant sharedInstance] rndAvatarURL] forKey:avatarKey];
//		
//		[[NSUserDefaults standardUserDefaults] setObject:[avatars copy] forKey:@"avatars"];
//		[[NSUserDefaults standardUserDefaults] synchronize];
//		
//		vo.avatarPrefix = [[[NSUserDefaults standardUserDefaults] objectForKey:@"avatars"] objectForKey:avatarKey];
//	}
	
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
	
	int srcUserID = [message originUserID];
	HONChatMessageType messageType = [message messageType];
	
	NSMutableDictionary *dict = [@{@"id"				: @(0),
								   @"msg_id"			: @(0),
								   @"content_type"		: @((int)messageType),
								   @"owner_member"		: @{@"id"	: @(srcUserID),
															@"name"	: message.originUsername},
								   
								   @"image"				: (messageType == HONChatMessageTypeIMG || messageType == HONChatMessageTypeVID) ? [message imageURLPrefix] : [message coordsURI],
								   @"text"				: [message contents],
								   
								   @"net_vote_score"	: @(0),
								   @"status"			: @(0),
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
