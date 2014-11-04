//
//  HONStoreProductVO.m
//  HotOrNot
//
//  Created by BIM  on 10/7/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDictionary+NullReplacement.h"
#import "NSString+DataTypes.h"

#import "HONStoreProductVO.h"

@implementation HONStoreProductVO
@synthesize dictionary;
@synthesize productID, contentGroupID, productName, imageURL, price, displayIndex, imageType, purchased;

+ (HONStoreProductVO *)productWithDictionary:(NSDictionary *)dictionary {
	HONStoreProductVO *vo = [[HONStoreProductVO alloc] init];
	
	vo.dictionary = dictionary;
	vo.productID = [dictionary objectForKey:@"product_id"];
	vo.contentGroupID = [dictionary objectForKey:@"cg_id"];
	vo.productName = [dictionary objectForKey:@"name"];
	vo.imageURL = [dictionary objectForKey:@"img_url"];
	vo.price = [[dictionary objectForKey:@"price"] floatValue];
	vo.displayIndex = [[dictionary objectForKey:@"index"] intValue];
	vo.imageType = ([[[dictionary objectForKey:@"img_url"] lowercaseString] rangeOfString:@".png"].location != NSNotFound) ? HONStoreProuctImageTypePNG : HONStoreProuctImageTypeGIF;
	vo.purchased = [[HONStickerAssistant sharedInstance] isStickerPakPurchasedWithContentGroupID:vo.contentGroupID];

	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.productID = nil;
	self.contentGroupID = nil;
	self.productName = nil;
	self.imageURL = nil;
}

@end
