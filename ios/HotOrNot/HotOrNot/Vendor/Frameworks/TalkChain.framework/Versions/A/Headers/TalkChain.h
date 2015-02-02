//
//  TalkChain.h
//  TalkChain
//
//  Created by Charles Chase on 8/30/14.
//  Copyright (c) 2014 AFTY, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TalkChainCredentials.h"

@protocol TalkChainDelegate <NSObject>

@optional

- (void)talkChainIsReady;
- (void)talkChainSessionStarted;
- (void)talkChainError:(NSString*)error;
- (void)talkChainViewStateChanged:(BOOL)visible;
- (void)talkChainReceivedNotification:(NSInteger)badge;
- (void)talkChainCredentialsUpdated:(TalkChainCredentials*)credentials;

@end

@interface TalkChain : NSObject

@property (nonatomic, strong) id<TalkChainDelegate> delegate;

/*  Singleton */

+ (id)sharedManager;

/*
    Initialize TalkChain
 
    @param key - API key provided by Affinity Networks
    @param token - Optional APNS token - See Push Notifications in wiki
    @param credentials - Optional credentials to use when creating a new User account
    @param delegate - Optional delegate
*/

+ (void)initWithAPIKey:(NSString*)key
                 token:(NSString*)token
           credentials:(TalkChainCredentials*)credentials
              delegate:(id<TalkChainDelegate>)delegate;

/*  Start a TalkChain session, create a user account (for first-time users) and listen for notifications. */

- (void)startSession;

/*  Open the TalkChain UI */

- (void)presentUI;

/*
    Stop TalkChain and close the UI
 
    We recommend calling this only on memory warnings. Otherwise, allow the
    user to close the UI using normal navigation.
*/

- (void)stop;

/*
    Customize App Colors

    @param primary - Launch screen background and assorted controls
    @param secondary - Used throughout as a bold text color
    @param highlight - UITableViewCell selected color
    @param accent - Assorted accents, Karma score background and UISwitch tint color
    @param header - Navigation header color
*/

+ (void)configureColorsWithPrimary:(UIColor*)primary
              secondary:(UIColor*)secondary
              highlight:(UIColor*)highlight
                 accent:(UIColor*)accent
                 header:(UIColor*)header;

@end
