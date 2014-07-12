//
//  HONCountryVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 07/09/2014 @ 15:55 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONCountryVO.h"

@implementation HONCountryVO
@synthesize dictionary;
@synthesize countryName, countryCode, callingCode;

+ (HONCountryVO *)countryWithDictionary:(NSDictionary *)dictionary {
	HONCountryVO *vo = [[HONCountryVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.countryName = [dictionary objectForKey:@"name"];
	vo.countryCode = [dictionary objectForKey:@"code"];
	vo.callingCode = [dictionary objectForKey:@"calling"];
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.countryName = nil;
	self.countryCode = nil;
	self.callingCode = nil;
}

@end
