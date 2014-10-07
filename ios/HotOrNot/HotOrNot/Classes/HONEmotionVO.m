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
@synthesize emotionID, contentGroupID, emotionName, imageType, urlPrefix, largeImageURL, smallImageURL, image, price, isFree, pcContent, picoSticker;

+ (HONEmotionVO *)emotionWithDictionary:(NSDictionary *)dictionary {
	HONEmotionVO *vo = [[HONEmotionVO alloc] init];
	vo.dictionary = dictionary;
		
	vo.emotionID = [dictionary objectForKey:@"id"];
	vo.contentGroupID = [dictionary objectForKey:@"cg_id"];
	vo.emotionName = [[[dictionary objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByReplacingOccurrencesOfString:@".png" withString:@""];
	vo.imageType = ([[[dictionary objectForKey:@"img"] lowercaseString] rangeOfString:@".png"].location != NSNotFound) ? HONEMotionImageTypePNG : HONEMotionImageTypeGIF;
	vo.urlPrefix = [[[dictionary objectForKey:@"img"] stringByReplacingOccurrencesOfString:@"/large.gif" withString:@"/"] stringByReplacingOccurrencesOfString:@"/large.png" withString:@"/"];
	vo.largeImageURL = [vo.urlPrefix stringByAppendingString:[@"large." stringByAppendingString:(vo.imageType == HONEMotionImageTypePNG) ? @"png" : @"gif"]];
	vo.mediumImageURL = [vo.urlPrefix stringByAppendingString:[@"medium." stringByAppendingString:(vo.imageType == HONEMotionImageTypePNG) ? @"png" : @"gif"]];
	vo.smallImageURL = [vo.urlPrefix stringByAppendingString:[@"small." stringByAppendingString:(vo.imageType == HONEMotionImageTypePNG) ? @"png" : @"gif"]];
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
	self.urlPrefix = nil;
	self.largeImageURL = nil;
	self.mediumImageURL = nil;
	self.smallImageURL = nil;
	self.image = nil;
	self.pcContent = nil;
	self.picoSticker = nil;
}

@end
