//
//  AppDelegate.h
//  FriendPickerPrototype
//
//  Created by Andrew Vergara on 12/25/12.
//  Copyright (c) 2012 Super. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FBSessionTokenCachingStrategy.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

extern NSString *const FBSessionStateChangedNotification;

@property (strong, nonatomic) UIWindow *window;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void)closeSession;

@end
