//
//  PCContentGroup.h
//  PCEssentials
//
//  Created by PicoCandy Pte Ltd on 16/11/13.
//  Copyright (c) 2013 PicoCandy. All rights reserved.
//

#import "PCModelObject.h"
#import "PCContentPrice.h"
#import "PCPublisher.h"

typedef enum {
    kPCContentGroupSmallImage = 1,
    kPCContentGroupMediumImage,
    kPCContentGroupLargeImage
} kPCContentGroupImageSize;

extern NSString * const kPCContentGroupPicoCurrencyPurchaseOption;     // Default
extern NSString * const kPCContentGroupInAppPurchaseOption;
extern NSString * const kPCContentGroupAppCurrencyPurchaseOption;

@interface PCContentGroup : PCModelObject

@property (nonatomic, strong) NSString *content_group_id;
@property (nonatomic, strong) NSArray *contents;
@property (nonatomic, strong) NSString *desc;   // NOTE: Server response uses "description" for this field
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSString *purchase_option;
@property (nonatomic, strong) NSString *vendor_id;
@property (nonatomic, assign) BOOL downloaded;

-(NSArray *)tags;
-(NSURL *)urlForPreviewImage:(kPCContentGroupImageSize)size;
-(NSNumber *)priceForInAppPurchase;
-(NSString *)copyrightMessage;

@end
