//
//  HONTrivialUserVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/23/2014 @ 09:43 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDictionary+NullReplacement.h"

#import "HONTrivialUserVO.h"

@implementation HONTrivialUserVO
@synthesize dictionary;
@synthesize userID, username, avatarPrefix, altID;

+ (HONTrivialUserVO *)userWithDictionary:(NSDictionary *)dictionary {
	HONTrivialUserVO *vo = [[HONTrivialUserVO alloc] init];
	
//	NSDictionary *nullFix = [dictionary dictionaryByReplacingNullsWithBlanks];
//	vo.dictionary = [dictionary dictionaryByReplacingNullsWithBlanks];
//	
//	NSLog(@"([nullFix objectForKey:@\"username\"]) : (%@)\n", ([nullFix objectForKey:@"username"]));
//	NSLog(@"\n([[nullFix objectForKey:@\"username\"] isKindOfClass:[NSNull class]]) : (%d)", ([[nullFix objectForKey:@"username"] isKindOfClass:[NSNull class]]));
//	NSLog(@"([[nullFix objectForKey:@\"username\"] isEqual:[NSNull null]]) : (%d)", ([[nullFix objectForKey:@"username"] isEqual:[NSNull null]]));
//	NSLog(@"([nullFix objectForKey:@\"username\"] == [NSNull null]) : (%d)", ([nullFix objectForKey:@"username"] == [NSNull null]));
//	NSLog(@"([nullFix objectForKey:@\"username\"] != [NSNull null]) : (%d)", ([nullFix objectForKey:@"username"] != [NSNull null]));
//	NSLog(@"([nullFix objectForKey:@\"username\"] != nil) : (%d)", ([nullFix objectForKey:@"username"] != nil));
//	
	
//	NSString *username = @"";
//	if ([dictionary objectForKey:@"username"] != [NSNull null]) {
//		username = [dictionary objectForKey:@"username"];
//	
//	} else {
//		username = ([dictionary objectForKey:@"f_name"] != [NSNull null]) ? [dictionary objectForKey:@"f_name"] : @"";
//		username = ([dictionary objectForKey:@"l_name"] != [NSNull null]) ? [username stringByAppendingFormat:@" %@", [dictionary objectForKey:@"l_name"]] : username;
//	}
	
	vo.dictionary = dictionary;
	vo.userID = [[dictionary objectForKey:@"id"] intValue];//([dictionary objectForKey:@"id"] != [NSNull null]) ? [[dictionary objectForKey:@"id"] intValue] : 0;
	vo.username = [dictionary objectForKey:@"username"];
	vo.avatarPrefix = [HONAppDelegate cleanImagePrefixURL:[dictionary objectForKey:@"img_url"]];//([dictionary objectForKey:@"img_url"] != [NSNull null]) ? [HONAppDelegate cleanImagePrefixURL:[dictionary objectForKey:@"img_url"]] : [@"%@/defaultAvatar" stringByAppendingString:[HONAppDelegate s3BucketForType:@"avatars"]];
	vo.altID = ([dictionary objectForKey:@"alt_id"] != [NSNull null]) ? [dictionary objectForKey:@"alt_id"] : @"";
	
	return (vo);
}

+ (HONTrivialUserVO *)userFromOpponentVO:(HONOpponentVO *)opponentVO {
	return([HONTrivialUserVO userWithDictionary:@{@"id"			: [opponentVO.dictionary objectForKey:@"id"],
												  @"username"	: [opponentVO.dictionary objectForKey:@"username"],
												  @"img_url"	: [opponentVO.dictionary objectForKey:@"avatar"],
												  @"alt_id"		: [[[HONAppDelegate cleanImagePrefixURL:[opponentVO.dictionary objectForKey:@"avatar"]] componentsSeparatedByString:@"/"] lastObject]}]);
}

+ (HONTrivialUserVO *)userFromUserVO:(HONUserVO *)userVO {
	return([HONTrivialUserVO userWithDictionary:@{@"id"			: [userVO.dictionary objectForKey:@"id"],
												  @"username"	: [userVO.dictionary objectForKey:@"username"],
												  @"img_url"	: [userVO.dictionary objectForKey:@"avatar_url"],
												  @"alt_id"		: [userVO.dictionary objectForKey:@"device_token"]}]);
}


- (void)dealloc {
	self.dictionary = nil;
	self.username = nil;
	self.avatarPrefix = nil;
	self.altID = nil;
}
@end
