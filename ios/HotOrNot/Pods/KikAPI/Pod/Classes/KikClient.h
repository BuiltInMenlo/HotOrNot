//
//  KikClient.h
//  Pods
//
//  Created by Anthony Wong on 2014-08-06.
//  Copyright (c) 2014 Kik Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#import "KikMessage.h"

@interface KikClient : NSObject

/**
 *  KikClient Singleton
 *
 *  @return Returns the singleton instance of the KikClient object
 */
+ (KikClient *)sharedInstance;

/**
 *  Kik API call to return back to / or launch Kik
 */
- (void)backToKik;

/**
 *  Kik API call to open a specified users profile
 *
 *  @param username - the Kik username of the profile you wish to open
 */
- (void)openProfileForKikUsername:(NSString *)username;

/**
 *  Kik API call to send a constructed KikMessage
 *
 *  @param message - the constructed KikMessage you wish to send through Kik
 */
- (void)sendKikMessage:(KikMessage *)message;

/**
 *  If Kik isn't installed on the client devices and an API call is made, the library will present a modal
 *  view controller of Kik on the AppStore to allow for easy downloading. By default this modal view controller will
 *  be presented on the windows root view controller. You can change that through this property.
 */
@property (nonatomic, strong) UIViewController *rootController;

@end
