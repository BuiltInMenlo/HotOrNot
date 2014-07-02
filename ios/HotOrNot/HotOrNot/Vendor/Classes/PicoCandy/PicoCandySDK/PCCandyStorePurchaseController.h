//
//  PCCandyStorePurchaseController.h
//  PicoCandySDK
//
//  Created by PicoCandy Pte Ltd on 6/12/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCContentGroup;

@protocol PCCandyStorePurchaseControllerDelegate <NSObject>

@optional

// Purchase individual stickers
-(void)purchaseController:(id)controller
   purchasedStickerWithId:(NSString *)contentId
                 userInfo:(NSDictionary*)userInfo;

-(void)purchaseController:(id)controller
purchaseStickerWithIdFailed:(NSString *)contentId
                 userInfo:(NSDictionary*)userInfo;
// Download individual stickers
-(void)purchaseController:(id)controller downloadedStickerWithId:(NSString *)contentId;
-(void)purchaseController:(id)controller downloadStickerWithIdFailed:(NSString *)contentId;

// Purchase sticker pack
// Using content group ID, for pico_currency purchases only
-(void)purchaseController:(id)controller purchasedStickerPackWithId:(NSString *)contentGroupId
                 userInfo:(NSDictionary *)userInfo;
-(void)purchaseController:(id)controller purchaseStickerPackWithIdFailed:(NSString *)contentGroupId
                 userInfo:(NSDictionary *)userInfo;
// For in-app purchase methods
-(void)purchaseController:(id)controller purchasedStickerPackWithContentGroup:(PCContentGroup *)contentGroup
                 userInfo:(NSDictionary *)userInfo;
-(void)purchaseController:(id)controller purchaseStickerPackWithContentGroupFailed:(PCContentGroup *)contentGroup
                 userInfo:(NSDictionary *)userInfo;
// Download sticker pack
-(void)purchaseController:(id)controller downloadedStickerPackWithId:(NSString *)contentGroupId;
-(void)purchaseController:(id)controller downloadStickerPackWithIdFailed:(NSString *)contentGroupId;

@end

@interface PCCandyStorePurchaseController : NSObject

@property (nonatomic, strong) id<PCCandyStorePurchaseControllerDelegate> delegate;

-(void)purchaseStickersWithIds:(NSArray *)contentIds;

-(void)purchaseStickerWithId:(NSString *)contentId;

-(void)downloadStickerWithId:(NSString *)contentId;

-(void)purchaseStickerPackWithId:(NSString *)contentGroupId;

-(void)purchaseStickerPackWithContentGroup:(PCContentGroup *)contentGroup;

-(void)downloadStickerPackWithId:(NSString *)contentGroupId;

@end
