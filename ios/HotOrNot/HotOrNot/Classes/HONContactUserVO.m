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
@synthesize firstName, lastName, fullName, mobileNumber, email, isSMSAvailable;

+ (HONContactUserVO *)contactWithDictionary:(NSDictionary *)dictionary {
	HONContactUserVO *vo = [[HONContactUserVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.firstName = [dictionary objectForKey:@"f_name"];
	vo.lastName = [dictionary objectForKey:@"l_name"];
	vo.fullName = [NSString stringWithFormat:@"%@ %@", vo.firstName, vo.lastName];
	vo.mobileNumber = [dictionary objectForKey:@"phone"];
	vo.email = [dictionary objectForKey:@"email"];
	
	if ([[dictionary objectForKey:@"phone"] length] > 0) {
		NSString *formattedNumber = [[[dictionary objectForKey:@"phone"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"+().- "]] componentsJoinedByString:@""];
		if (![[formattedNumber substringToIndex:1] isEqualToString:@"1"])
			formattedNumber = [[NSString new] stringByAppendingFormat:@"1%@", formattedNumber];
		
		vo.mobileNumber = [[NSString new] stringByAppendingFormat:@"+%@", formattedNumber];
	}
	
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
}

@end
