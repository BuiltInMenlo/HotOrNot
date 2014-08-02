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
@synthesize emotionID, contentGroupID, emotionName, largeImageURL, smallImageURL, image, price, isFree, pcContent, picoSticker;

+ (HONEmotionVO *)emotionWithDictionary:(NSDictionary *)dictionary {
	HONEmotionVO *vo = [[HONEmotionVO alloc] init];
	vo.dictionary = dictionary;
		
	vo.emotionID = [dictionary objectForKey:@"id"];
	vo.contentGroupID = [dictionary objectForKey:@"cg_id"];
	vo.emotionName = [[[dictionary objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByReplacingOccurrencesOfString:@".png" withString:@""];
	vo.largeImageURL = [[dictionary objectForKey:@"img"] stringByAppendingString:@"large.png"];
	vo.mediumImageURL = [[dictionary objectForKey:@"img"] stringByAppendingString:@"medium.png"];
	vo.smallImageURL = [[dictionary objectForKey:@"img"] stringByAppendingString:@"small.png"];
	vo.price = [[dictionary objectForKey:@"price"] floatValue];
	vo.pcContent = (PCContent *)[dictionary objectForKey:@"content"];
	vo.isFree = (vo.price == 0.0);
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.emotionID = nil;
	self.contentGroupID = nil;
	self.emotionName = nil;
	self.largeImageURL = nil;
	self.mediumImageURL = nil;
	self.smallImageURL = nil;
	self.image = nil;
	self.pcContent = nil;
	self.picoSticker = nil;
}

@end
