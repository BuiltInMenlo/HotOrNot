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
@synthesize productID, productName, price;

+ (HONStoreProductVO *)productWithDictionary:(NSDictionary *)dictionary {
	HONStoreProductVO *vo = [[HONStoreProductVO alloc] init];
	
	vo.dictionary = dictionary;

	return (vo);
}

- (void)dealloc {
	self.dictionary = nil;
	self.productID = nil;
	self.productName = nil;
}

@end
