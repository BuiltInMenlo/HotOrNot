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
@synthesize emotionID, contentGroupID, emotionName, imageType, urlPrefix, largeImageURL, smallImageURL, animatedImageView, image, price, isFree, pcContent, picoSticker;

+ (HONEmotionVO *)emotionWithDictionary:(NSDictionary *)dictionary {
	HONEmotionVO *vo = [[HONEmotionVO alloc] init];
	vo.dictionary = dictionary;
	
//	NSString *tmpURL = @"http://i.imgur.com/1lgZ0.gif"; // clapping
//	NSString *tmpURL = @"https://s3.amazonaws.com/hotornot-challenges/BigSmiley11.gif"; // clapping / s3
//	NSString *tmpURL = @"http://25.media.tumblr.com/tumblr_ln48mew7YO1qbhtrto1_500.gif"; // data-visor
//	NSString *tmpURL = @"https://cdn.picocandy.com/1df5644d9e94/t/54331bdfab4b8b0468000167/large.gif"; // 4mb
//	NSURL *url1 = [[NSBundle mainBundle] URLForResource:@"1lgZ0" withExtension:@"gif"];
	
	vo.emotionID = [dictionary objectForKey:@"id"];
	vo.contentGroupID = [dictionary objectForKey:@"cg_id"];
	vo.emotionName = [[[[dictionary objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByReplacingOccurrencesOfString:@".png" withString:@""] stringByReplacingOccurrencesOfString:@".gif" withString:@""];
	vo.imageType = ([[[dictionary objectForKey:@"img"] lowercaseString] rangeOfString:@".png"].location != NSNotFound) ? HONEmotionImageTypePNG : HONEmotionImageTypeGIF;
	vo.urlPrefix = [[[dictionary objectForKey:@"img"] stringByReplacingOccurrencesOfString:@"/large.gif" withString:@"/"] stringByReplacingOccurrencesOfString:@"/large.png" withString:@"/"];
	vo.largeImageURL = [vo.urlPrefix stringByAppendingString:[@"large." stringByAppendingString:(vo.imageType == HONEmotionImageTypePNG) ? @"png" : @"gif"]];
	vo.mediumImageURL = [vo.urlPrefix stringByAppendingString:[@"medium." stringByAppendingString:(vo.imageType == HONEmotionImageTypePNG) ? @"png" : @"gif"]];
	vo.smallImageURL = [vo.urlPrefix stringByAppendingString:[@"small." stringByAppendingString:(vo.imageType == HONEmotionImageTypePNG) ? @"png" : @"gif"]];
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
