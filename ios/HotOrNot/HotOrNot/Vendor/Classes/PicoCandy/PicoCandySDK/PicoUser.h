//
//  PicoUser.h
//  PicoCandySDK
//
//  Created by PicoCandy on 8/11/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  The callback definition when a PicoUser refresh operation succeeds
 *
 *  @param user the updated user
 */
typedef void (^PicoUserFetchInfoSuccessBlock)(id user);

/**
 *  Definition for the callback block when a PicoUser refresh fails
 */
typedef void (^PicoUserFetchInfoFailureBlock)(void);

/**
 *  PicoUser represents an user of a CandyStore, this user is unique to your store and has properties for 
 *  such as virtual currency balance that is used to purchase content from CandyStore
 */
@interface PicoUser : NSObject
@property (nonatomic, readonly) NSString *accessToken;
@property (nonatomic, readonly) BOOL busy;                      // If YES means PicoUser is busy with account creation or fetching info
@property (nonatomic, readonly) BOOL requireAccountCreation;    // If YES means need to send request to server for account creation
@property (nonatomic, readonly) BOOL needLatestInfoFromServer;   // If YES means need to fetch account's latest info from server
@property (nonatomic, readonly) BOOL connected;
@property (nonatomic, readonly) BOOL newAccount;
/**
 *  An unique id of the current store user
 */
@property (nonatomic, readonly) NSString *storeUserId;

/**
 *  Virtual Currency balance of the current user
 */
@property (nonatomic, readonly) NSNumber *accountBalance;

/**
 * Retrieves current active user. If no active user found, this method will automatically create a new user for account creation.
 * @return Returns current active user
 */
+(PicoUser *)currentUser;

/**
 *  Refreshes the user information from CandyStore API
 *
 *  @param success callback block when refresh succeeds
 *  @param fail    callback block when refresh fails
 */
-(void)fetchInfoFromServer:(PicoUserFetchInfoSuccessBlock)success fail:(PicoUserFetchInfoFailureBlock)fail;

@end

