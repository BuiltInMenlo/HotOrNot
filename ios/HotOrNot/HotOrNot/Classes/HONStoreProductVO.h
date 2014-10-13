//
//  HONStoreProductVO.h
//  HotOrNot
//
//  Created by BIM  on 10/7/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

@interface HONStoreProductVO : NSObject
+ (HONStoreProductVO *)productWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSDictionary *dictionary;
@property (nonatomic, retain) NSString *productID;
@property (nonatomic, retain) NSString *productName;
@end
