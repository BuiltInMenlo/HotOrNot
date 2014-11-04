//
//  HONStoreProductVO.h
//  HotOrNot
//
//  Created by BIM  on 10/7/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

typedef NS_ENUM(NSUInteger, HONStoreProuctImageType) {
	HONStoreProuctImageTypePNG = 0,
	HONStoreProuctImageTypeGIF = 1
};

@interface HONStoreProductVO : NSObject
+ (HONStoreProductVO *)productWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic, retain) NSString *productID;
@property (nonatomic, retain) NSString *contentGroupID;
@property (nonatomic, retain) NSString *productName;
@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic) CGFloat price;
@property (nonatomic) int displayIndex;
@property (nonatomic) HONStoreProuctImageType imageType;
@property (nonatomic, getter=isPurchased) BOOL purchased;
@end
