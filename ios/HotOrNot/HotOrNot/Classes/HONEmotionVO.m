//
//  HONEmotionVO.m
//  HotOrNot
//
//  Created by Matt Holcombe on 10/26/13 @ 4:53 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONEmotionVO.h"

@implementation HONEmotionVO

@synthesize dictionary;
@synthesize emotionID, emotionName, largeImageURL, smallImageURL, price, isFree;

+ (HONEmotionVO *)emotionWithDictionary:(NSDictionary *)dictionary {
	HONEmotionVO *vo = [[HONEmotionVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.emotionID = [[dictionary objectForKey:@"id"] intValue];
	vo.emotionName = [dictionary objectForKey:@"name"];
	vo.largeImageURL = [[dictionary objectForKey:@"img"] stringByAppendingString:@"_88x88.png"];
	vo.smallImageURL = [[dictionary objectForKey:@"img"] stringByAppendingString:@"_288x288.png"];
	vo.price = [[dictionary objectForKey:@"price"] floatValue];
	vo.isFree = (vo.price == 0.0);
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.emotionName = nil;
	self.largeImageURL = nil;
	self.smallImageURL = nil;
}

@end
