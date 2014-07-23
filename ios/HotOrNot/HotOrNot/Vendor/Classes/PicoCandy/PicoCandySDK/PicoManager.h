//
//  PicoManager.h
//  PicoCandySDK
//
//  Created by PicoCandy Pte Ltd on 3/12/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CandyBox.h"
#import "CandyStore.h"

typedef void (^PicoManagerConnectSuccessBlock)(void);
typedef void (^PicoManagerConnectFailureBlock)(void);

/**
 * Main manager class for managing majority of requests related to PicoCandySDK.
 * Properties referencing to singleton instances of CandyBox and CandyStore classes are also provided.
 * PicoManager should be accessed via its PicoManager#sharedManager static method.
 * 
 * @see PicoManager#sharedManager
 * @see PicoManager#candyBox
 * @see PicoManager#candyStore
 */
@interface PicoManager : NSObject

/**
 * Use this property to check if PicoCandy servers are currently down for maintenance.
 * You can use NSKeyValueObserving protocol to monitor changes in maintenance mode.
 */
@property (nonatomic, readonly) BOOL maintenanceMode;

/**
 * Use this property to check if PicoManager is connected PicoCandy servers.
 * You can implement KVO methods to observe changes being made to this property.
 */
@property (nonatomic, readonly) BOOL connected;

/**
 * Use this property to access CandyBox singleton instance.
 * @see CandyBox#shared
 */
@property (nonatomic, readonly) CandyBox *candyBox;

/**
 * Use this property to access CandyStore singleton instance.
 * @see CandyStore#shared
 */
@property (nonatomic, readonly) CandyStore *candyStore;

/**
 * Singleton instance of PicoManager. All operations involving PicoCandy contents should go through this instance.
 * @return Singleton instance of PicoManager class
 */
+(PicoManager *)sharedManager;

/**
 * Current API platform version
 */
+(NSString *)apiVersion;

/**
 * Name of current API platform
 */
+(NSString *)apiPlatform;

/**
 * Call this method to register store for current app
 * @param appId App ID for current app
 * @param apiKey API Key given for current app
 */
-(void)registerStoreWithAppId:(NSString *)appId apiKey:(NSString *)apiKey;

/**
 *  Link the store user to an unique user id
 *
 *  @param clientAppUserId
 * 
 *  @return BOOL YES if successful
 */

-(BOOL)linkCurrentStoreUserWithClientAppId:(NSString *)clientAppUserId;

/**
 *  Link the store user with a Facebook user id
 *
 *  @param fbUid
 *
 *  @return BOOL YES if successful
 */
-(BOOL)linkCurrentStoreUserWithFacebookUid:(NSString *)fbUid;

/**
 *  Link the store user with a Twitter user id
 *
 *  @param twitterId The user id ( not twitter handler )
 *
 *  @return BOOL YES if successful
 */
-(BOOL)linkCurrentStoreUserWithTwitterId:(NSString *)twitterId;

/**
 *  Link the store user with an Email address
 *
 *  @param emailAddress
 *
 *  @return BOOL YES if successful
 */
-(BOOL)linkCurrentStoreUserWithEmailAddress:(NSString *)emailAddress;

/**
 *  Link the store user with a Phone number
 *
 *  @param phoneNumber Phone number must be valid E.164 format.
 *                     Example +14155992671 for a US phone number
 *
 *  @return BOOL YES if successful
 */
-(BOOL)linkCurrentStoreUserWithPhoneNumber:(NSString *)phoneNumber;

#ifndef __PC_BUILD_FOR_CORE_SDK__
/**
 * Call this method to launch Candy Store
 */
-(void)launchCandyStore;

/**
 * Call this method to launch Candy Box input panel
 */
-(void)launchCandyBoxInputPanel;
#endif

/**
 * When application is launched due to another app opening an URL resource that is linked to application (via URL types) and URL resource is related to PicoCandy,
 * pass URL to this method to let PicoCandy SDK perform the neccessary tasks if applicable.
 * @param url URL resource that is used to launch application
 */
-(void)processURL:(NSURL *)url;

/**
 * Use this method to check all required components of PicoManager have connected successfully to PicoCandy servers
 * @return YES if all components are connected
 */
-(BOOL)allConnected;

/**
 *  Enable Push Notification for CandyStore for the CandyStore user by registering the push notification device token. To retrieve the device token,
 *  you can register for push notification service by using -[UIApplication registerForRemoteNotificationTypes:] 
 *
 *  @param deviceToken The device token that when application:didRegisterForRemoteNotificationWithDeviceToken: is called
 *
 */
-(void)registerPushDeviceToken:(NSData *)deviceToken;


/**
 * Notification name sent out when PicoCandy store and box services are up and running.
 * Subscribe to this notification through the default NSNotificationCenter
 */
extern NSString * const PicoManagerDidConnectWithSuccess;

@end
