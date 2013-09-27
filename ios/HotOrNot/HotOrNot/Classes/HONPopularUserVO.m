//
//  HONPopularUserVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/25/13 @ 6:09 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONPopularUserVO.h"

@implementation HONPopularUserVO

@synthesize dictionary;
@synthesize userID, username, imageURL;

+ (HONPopularUserVO *)userWithDictionary:(NSDictionary *)dictionary {
	HONPopularUserVO *vo = [[HONPopularUserVO alloc] init];
	
	vo.userID = [[dictionary objectForKey:@"id"] intValue];
	vo.username = [dictionary objectForKey:@"username"];
	
	NSMutableString *imageURL = [[dictionary objectForKey:@"img_url"] mutableCopy];
	[imageURL replaceOccurrencesOfString:@".jpg" withString:@"Small_160x160.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imageURL length])];
	vo.imageURL = imageURL;
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.username = nil;
	self.imageURL = nil;
}

@end
