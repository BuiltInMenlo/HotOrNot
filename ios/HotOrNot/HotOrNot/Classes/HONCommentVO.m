//
//  HONCommentVO.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 02.20.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+Operations.h"

#import "HONCommentVO.h"


@implementation HONCommentVO

@synthesize dictionary;
@synthesize commentID, parentID, userID, username, score, textContent, addedDate;

+ (HONCommentVO *)commentWithDictionary:(NSDictionary *)dictionary {
	HONCommentVO *vo = [[HONCommentVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.commentID = [[dictionary objectForKey:@"id"] intValue];
	vo.parentID = [[dictionary objectForKey:@"parent_id"] intValue];
	vo.userID = [[dictionary objectForKey:@"user_id"] intValue];
	vo.username = [dictionary objectForKey:@"username"];
	vo.textContent = [dictionary objectForKey:@"text"];
	vo.score = [[dictionary objectForKey:@"score"] intValue];
	vo.addedDate = [NSDate dateFromISO9601FormattedString:[dictionary objectForKey:@"added"]];
	
	return (vo);
}

+ (HONCommentVO *)commentWithClubPhoto:(HONClubPhotoVO *)clubPhotoVO {
	NSDictionary *dict = @{@"id"		: @(clubPhotoVO.challengeID),
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
	self.textContent = nil;
	self.addedDate = nil;
}

@end
