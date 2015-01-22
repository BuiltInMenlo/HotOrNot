//
//  HONLayerKitAssistant.h
//  HotOrNot
//
//  Created by BIM  on 1/18/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import <LayerKit/LayerKit.h>

#import "HONStatusUpdateVO.h"


@interface HONLayerKitAssistant : NSObject
+ (HONLayerKitAssistant *)sharedInstance;

- (LYRClient *)client;
- (void)connectClientToServiceWithCompletion:(void (^)(BOOL success, NSError * error))completion;
- (void)authenticateUserWithUserID:(int)userID withCompletion:(void (^)(id result))completion;
- (void)deauthenticateActiveUserWithCompletion:(void (^)(id result))completion;

- (void)notifyClientWithPushToken:(NSData *)deviceToken;
- (void)notifyClientPushTokenNotAvailibleFromError:(NSError *)error;
- (void)notifyClientRemotePushWasReceived:(NSDictionary *)userInfo;
- (void)notifyClientRemotePushWasReceived:(NSDictionary *)userInfo withCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandle;

- (void)sendTxtMessageToStatusUpdate:(HONStatusUpdateVO *)statusUpdateVO withCompletion:(void (^)(id))completion;


- (NSString *)identityTokenForActiveUser;
- (void)writeIdentityToken:(NSString *)token;

- (NSData *)pushTokenForActiveUser;
- (void)writePushToken:(NSData *)token;

- (LYRConversation *)conversationWithParticipants:(NSArray *)participants;

//- (LYRMessage *)composeTxtMsgWithContent:(NSString *)txtContent attachingRemotePushUserInfo:(NSDictionary *)userInfo;
//- (LYRMessage *)composeMessageWithParts:(NSArray *)parts andDeliveringPushWithInfo:(NSDictionary *)userInfo;
@end
