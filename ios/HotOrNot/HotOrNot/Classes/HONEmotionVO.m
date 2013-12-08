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
@synthesize emotionID, emotionName, hastagName, urlPrefix, urlLargeBlue, urlSmallBlue, urlSmallWhite, price, isFree;

+ (HONEmotionVO *)emotionWithDictionary:(NSDictionary *)dictionary {
	HONEmotionVO *vo = [[HONEmotionVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.emotionID = [[dictionary objectForKey:@"id"] intValue];
	vo.emotionName = [dictionary objectForKey:@"name"];
	vo.hastagName = [@"#" stringByAppendingString:vo.emotionName];
	vo.urlPrefix = [dictionary objectForKey:@"img"];
	vo.urlLargeBlue = [vo.urlPrefix stringByAppendingString:@"-lg_blue.png"];
	vo.urlSmallBlue = [vo.urlPrefix stringByAppendingString:@"-sm_blue.png"];
	vo.urlSmallWhite = [vo.urlPrefix stringByAppendingString:@"-sm_white.png"];
	vo.price = [[dictionary objectForKey:@"price"] floatValue];
	vo.isFree = (vo.price == 0.0);
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.emotionName = nil;
	self.hastagName = nil;
	self.urlPrefix = nil;
	self.urlLargeBlue = nil;
	self.urlSmallBlue = nil;
	self.urlSmallWhite = nil;
}

@end
