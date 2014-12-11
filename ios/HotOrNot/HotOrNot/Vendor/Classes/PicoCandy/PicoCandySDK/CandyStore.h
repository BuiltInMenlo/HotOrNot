//
//  CandyStore.h
//  PicoCandySDK
//
//  Created by PicoCandy Pte Ltd on 8/11/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PCStore, PicoUser;

/**
 * Main class for managing tasks related to CandyStore, which is the main place to go to for purchasing and downloading stickers.
 * Sticker store information can also be retrieved via the CandyStore#currentStore method.
 */
@interface CandyStore : NSObject
{
}

/**
 * This property will return as YES if CandyStore is in midst of retrieving/refreshing the current store info
 */
@property (nonatomic, readonly) BOOL refreshingStoreInfo;
/**
 * Use this property to check if CandyStore is connected to PicoCandy servers.
 */
@property (nonatomic, readonly) BOOL connected;

#ifndef __PC_BUILD_FOR_CORE_SDK__
/**
 * Use this property to check if CandyStore store front is displayed.
 */
@property (nonatomic, readonly) BOOL storeFrontDisplayed;
#endif

@property (nonatomic, readonly) PCStore *storeInfo;

/**
 * Singleton instance of CandyStore. All operations involving CandyStore should go through this instance.
 * @return Singleton instance of CandyStore class
 */
+(CandyStore *)shared;

/**
 * Returns object containing information on current sticker store
 * @return Object containing information on current sticker store
 */
+(PCStore *)currentStore;

/**
 * Use this method to retrieve latest sticker store information from PicoCandy servers
 */
-(void)refreshStoreInfo;

#ifndef __PC_BUILD_FOR_CORE_SDK__
/**
 * Present store front view with a parent view controller.
 * @param viewController Parent view controller used to launch store front view modally.
 * If nil is provided, the root view controller of current key window will be used instead.
 */
-(void)presentStoreFrontWithParentViewController:(UIViewController *)viewController;

/**
 * Dismisses store front view
 */
-(void)dismissStoreFront;
#endif

-(void)processURL:(NSURL *)url withRequiredAction:(NSString *)action param:(NSString *)param query:(NSDictionary *)query;

/**
 * CandyStore provides a number of NSNotifications when information about the store is updated.
 * To subscribe to these notfications, you have to add observers to the candystore notification center
 * @return CandyStore notification center
 * @see http://developer.apple.com/library/ios/documentation/cocoa/reference/foundation/Classes/NSNotificationCenter_Class/Reference/Reference.html
 */
+(NSNotificationCenter *)notificationCenter;

/**
 * Notification name sent out the store info is updated either from initialization refresh or 
 * refresh request from classes to keep store information up to date
 * @see CandyStore#notificationCenter
 */
extern NSString * const CandyStoreInformationRefreshNotification;

/**
 * Notification name sent out when store user is updated either from initialization refresh or
 * refresh request from classes to keep store information up to date, as part of the NSNotification
 * an instance of PCStore with the latest store information
 * @see CandyStore#notificationCenter
 */
extern NSString * const CandyStoreUserRefreshNotification;

@end

