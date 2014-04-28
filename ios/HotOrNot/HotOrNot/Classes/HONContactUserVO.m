//
//  HONContactUserVO.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 04.26.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONContactUserVO.h"

@implementation HONContactUserVO
@synthesize dictionary;
@synthesize firstName, lastName, fullName, rawNumber, mobileNumber, email, avatarImage, isSMSAvailable;

+ (HONContactUserVO *)contactWithDictionary:(NSDictionary *)dictionary {
	HONContactUserVO *vo = [[HONContactUserVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.firstName = [dictionary objectForKey:@"f_name"];
	vo.lastName = ([[dictionary objectForKey:@"l_name"] length] > 0) ? [dictionary objectForKey:@"l_name"] : @"";
	vo.fullName = [NSString stringWithFormat:([vo.lastName length] > 0) ? @"%@ %@" : @"%@%@", vo.firstName, vo.lastName];
	vo.email = [dictionary objectForKey:@"email"];
	vo.rawNumber = [dictionary objectForKey:@"phone"];
	vo.avatarImage = [UIImage imageWithData:[dictionary objectForKey:@"image"]];
	
	if ([vo.rawNumber length] > 0) {
		NSString *formattedNumber = [[vo.rawNumber componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"+().-  "]] componentsJoinedByString:@""];
		if (![[formattedNumber substringToIndex:1] isEqualToString:@"1"])
			formattedNumber = [[NSString new] stringByAppendingFormat:@"1%@", formattedNumber];
		
		vo.email = @"";
		vo.mobileNumber = [[NSString new] stringByAppendingFormat:@"+%@", formattedNumber];
	} else
		vo.mobileNumber = @"";
	
	vo.isSMSAvailable = ([vo.mobileNumber length] > 0);
	
	return (vo);
}


- (void)dealloc {
	self.dictionary = nil;
	self.firstName = nil;
	self.lastName = nil;
	self.fullName = nil;
	self.mobileNumber = nil;
	self.email = nil;
	self.avatarImage = nil;
}

@end
