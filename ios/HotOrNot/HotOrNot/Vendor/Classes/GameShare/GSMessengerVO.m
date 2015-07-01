//
//  GSMessengerVO.m
//  HotOrNot
//
//  Created by BIM  on 6/30/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "GSMessengerVO.h"

@implementation GSMessengerVO
@synthesize dictionary;
@synthesize messengerID;

+ (GSMessengerVO *)messengerWithDictionary:(NSDictionary *)dictionary {
	GSMessengerVO *vo = [[GSMessengerVO alloc] init];
	vo.dictionary = dictionary;
	
	vo.messengerID = [[dictionary objectForKey:@"id"] intValue];
	vo.messengerName = [dictionary objectForKey:@"name"];
	vo.imagePrefix = [dictionary objectForKey:@"image"];
	vo.sortOrder = [[dictionary objectForKey:@"sort"] intValue];
	vo.isEnabled = (BOOL)[[dictionary objectForKey:@"enabled"] intValue];
	
	vo.normalImage = [UIImage imageNamed:[vo.imagePrefix stringByAppendingString:@"_normal"]];
	vo.hilightedImage = [UIImage imageNamed:[vo.imagePrefix stringByAppendingString:@"_highlighted"]];
	vo.selectedImage = [UIImage imageNamed:[vo.imagePrefix stringByAppendingString:@"_selected"]];
	
	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.messengerName = nil;
	self.imagePrefix = nil;
	self.normalImage = nil;
	self.hilightedImage = nil;
	self.selectedImage = nil;
}

@end
