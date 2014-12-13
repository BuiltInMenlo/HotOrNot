//
//  HONComposeImageVO.m
//  HotOrNot
//
//  Created by BIM  on 12/12/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+Operations.h"

#import "HONComposeImageVO.h"

@implementation HONComposeImageVO
@synthesize composeImageID, composeImageName, imageType, urlPrefix, image, animatedImage, score, addedDate;

+ (HONComposeImageVO *)composeImageWithDictionary:(NSDictionary *)dictionary {
	HONComposeImageVO *vo = [[HONComposeImageVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.composeImageID = [[dictionary objectForKey:@"id"] intValue];
	vo.composeImageName = [dictionary objectForKey:@"name"];
	vo.imageType = ([[[dictionary objectForKey:@"type"] uppercaseString] isEqualToString:@"GIF"]) ? HONComposeImageTypeTypeAnimated : HONComposeImageTypeTypeStatic;
	vo.urlPrefix = [[dictionary objectForKey:@"url"] stringByReplacingOccurrencesOfString:[@"." stringByAppendingString:[[[dictionary objectForKey:@"url"] componentsSeparatedByString:@"."] lastObject]] withString:@""];
	vo.score = [[dictionary objectForKey:@"score"] intValue];
	vo.addedDate = [NSDate dateFromISO9601FormattedString:[dictionary objectForKey:@"added"]];
	
	vo.formattedProperties = [NSString stringWithFormat:@".composeImageID	: [%d]\n", vo.composeImageID];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".composeImageName	: [%@]\n", vo.composeImageName];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".imageType		: [%d]\n", vo.imageType];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".urlPrefix		: [%@]\n", vo.urlPrefix];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".score			: [%d]\n", vo.score];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".addedDate		: [%@]\n", vo.addedDate];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".dictionary		: [%@]", vo.dictionary];
	
	return (vo);
}


- (void)dealloc {
	self.dictionary = nil;
	self.composeImageName = nil;
	self.urlPrefix = nil;
	self.image = nil;
	self.animatedImage = nil;
	self.addedDate = nil;
}

@end
