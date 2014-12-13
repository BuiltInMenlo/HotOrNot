//
//  HONComposeImageVO.m
//  HotOrNot
//
//  Created by BIM  on 12/12/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+Operations.h"

#import "HONComposeImageVO.h"

NSString * const kComposeImageURLSuffix160 = @"_160";
NSString * const kComposeImageURLSuffix214 = @"_214";
NSString * const kComposeImageURLSuffix320 = @"_320";
NSString * const kComposeImageURLSuffix640 = @"_640";

NSString * const kComposeImageAnimatedFileExtension = @".gif";
NSString * const kComposeImageStaticFileExtension = @".png";


@implementation HONComposeImageVO
@synthesize composeImageID, composeImageName, imageType, urlPrefix, image, animatedImage, score, addedDate;

+ (HONComposeImageVO *)composeImageWithDictionary:(NSDictionary *)dictionary {
	HONComposeImageVO *vo = [[HONComposeImageVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.composeImageID = [[dictionary objectForKey:@"id"] intValue];
	vo.composeImageName = [dictionary objectForKey:@"name"];
	vo.imageType = ([[[dictionary objectForKey:@"type"] uppercaseString] isEqualToString:@"GIF"]) ? HONComposeImageTypeTypeAnimated : HONComposeImageTypeTypeStatic;
	vo.urlPrefix = [dictionary objectForKey:@"url"];
	vo.score = [[dictionary objectForKey:@"score"] intValue];
	vo.addedDate = [NSDate dateFromISO9601FormattedString:[dictionary objectForKey:@"added"]];
	
	vo.formattedProperties = [NSString stringWithFormat:@".composeImageID		: [%d]\n", vo.composeImageID];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".composeImageName	: [%@]\n", vo.composeImageName];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".imageType			: [%d]\n", vo.imageType];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".urlPrefix			: [%@]\n", vo.urlPrefix];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".score			: [%d]\n", vo.score];
	vo.formattedProperties = [vo.formattedProperties stringByAppendingFormat:@".addedDate			: [%@]\n", vo.addedDate];
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
