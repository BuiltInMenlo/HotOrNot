//
//  HONContactUserVO.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 04.26.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+Formatting.h"

#import "HONContactUserVO.h"

@implementation HONContactUserVO
@synthesize dictionary;
@synthesize contactType, firstName, lastName, fullName, rawNumber, mobileNumber, email, avatarData, avatarImage, isSMSAvailable, userID, username, avatarPrefix;

+ (HONContactUserVO *)contactWithDictionary:(NSDictionary *)dictionary {
	HONContactUserVO *vo = [[HONContactUserVO alloc] init];
	vo.dictionary = dictionary;
	vo.firstName = ([dictionary objectForKey:@"f_name"] != nil) ? [dictionary objectForKey:@"f_name"] : @"";
	vo.lastName = ([dictionary objectForKey:@"l_name"] != nil) ? ([[dictionary objectForKey:@"l_name"] length] > 0) ? [dictionary objectForKey:@"l_name"] : @"" : @"";
	vo.fullName = [NSString stringWithFormat:([vo.lastName length] > 0) ? @"%@ %@" : @"%@%@", vo.firstName, vo.lastName];
	vo.fullName = ([dictionary objectForKey:@"extern_name"] != nil && [[dictionary objectForKey:@"extern_name"] length] > 0) ? [dictionary objectForKey:@"extern_name"] : vo.fullName;
//	vo.fullName = [vo.fullName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	vo.email = ([dictionary objectForKey:@"email"] != nil) ? [dictionary objectForKey:@"email"] : @"";
	vo.rawNumber = ([dictionary objectForKey:@"phone"] != nil) ? [dictionary objectForKey:@"phone"] : @"";
	vo.avatarData = ([dictionary objectForKey:@"image"] != nil) ? [dictionary objectForKey:@"image"] : nil;
	vo.avatarImage = (vo.avatarData != nil) ? [UIImage imageWithData:vo.avatarData] : nil;
	
	if ([vo.rawNumber length] > 0) {
		vo.email = @"";
		vo.mobileNumber = [vo.rawNumber normalizedPhoneNumber];
		
	} else
		vo.mobileNumber = @"";
	
	vo.isSMSAvailable = ([vo.mobileNumber length] > 0);
	
	vo.userID = ([dictionary objectForKey:@"id"] == nil) ? 0 : [[dictionary objectForKey:@"id"] intValue];
	vo.username = ([dictionary objectForKey:@"username"] == nil) ? vo.fullName : [dictionary objectForKey:@"username"];
	vo.avatarPrefix = ([dictionary objectForKey:@"avatar_url"] == nil || [[dictionary objectForKey:@"avatar_url"] length] == 0) ? @"" : [dictionary objectForKey:@"avatar_url"];
	vo.contactType = HONContactTypeUnmatched;
	
	vo.invitedDate = [[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[dictionary objectForKey:@"invited"]];
	
	return (vo);
}


- (void)dealloc {
	self.dictionary = nil;
	self.firstName = nil;
	self.lastName = nil;
	self.fullName = nil;
	self.mobileNumber = nil;
	self.email = nil;
	self.avatarData = nil;
	self.avatarImage = nil;
	
	self.username = nil;
	self.avatarPrefix = nil;
}

@end
