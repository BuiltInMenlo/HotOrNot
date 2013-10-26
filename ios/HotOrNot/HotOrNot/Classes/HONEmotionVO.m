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
@synthesize emotionID, emotionName, hastagName, imagePrefix, imageLargeURL, imageSmallURL, price, isFree;

+ (HONEmotionVO *)emotionWithDictionary:(NSDictionary *)dictionary {
	HONEmotionVO *vo = [[HONEmotionVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.emotionID = [[dictionary objectForKey:@"id"] intValue];
	vo.emotionName = [dictionary objectForKey:@"name"];
	vo.hastagName = [NSString stringWithFormat:@"#%@", vo.emotionName];
	vo.imagePrefix = [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:@"emoticons"], vo.emotionName];
	vo.imageLargeURL = [NSString stringWithFormat:@"%@_large.png", vo.imagePrefix];
	vo.imageSmallURL = [NSString stringWithFormat:@"%@_small.png", vo.imagePrefix];
	vo.price = [[dictionary objectForKey:@"price"] floatValue];
	vo.isFree = (vo.price == 0.0);
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.emotionName = nil;
	self.hastagName = nil;
	self.imagePrefix = nil;
	self.imageLargeURL = nil;
	self.imageSmallURL = nil;
}

@end
