//
//  HONLayerKitAssistant.h
//  HotOrNot
//
//  Created by BIM  on 1/18/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import <LayerKit/LayerKit.h>

#import "LYRConversation+Additions.h"

#import "HONStatusUpdateVO.h"


@interface HONLayerKitAssistant : NSObject
+ (HONLayerKitAssistant *)sharedInstance;

- (LYRClient *)client;
- (void)connectClientToServiceWithCompletion:(void (^)(BOOL success, NSError * error))completion;
- (void)authenticateUserWithUserID:(int)userID withCompletion:(void (^)(BOOL success, NSError * error))completion;
- (void)deauthenticateActiveUserWithCompletion:(void (^)(id result))completion;

- (void)notifyClientWithPushToken:(NSData *)deviceToken;
- (void)notifyClientPushTokenNotAvailibleFromError:(NSError *)error;
- (void)notifyClientRemotePushWasReceived:(NSDictionary *)userInfo withCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;


- (NSString *)identityTokenForActiveUser;
- (void)writeIdentityToken:(NSString *)token;

- (NSData *)pushTokenForActiveUser;
- (void)writePushToken:(NSData *)token;

- (LYRConversation *)createConversationForStatusUpdate:(HONStatusUpdateVO *)statusUpdateVO;
- (void)addTxtMessage:(NSString *)msg toStatusUpdate:(HONStatusUpdateVO *)statusUpdateVO withCompletion:(void (^)(id))completion;
- (LYRConversation *)conversationWithParticipants:(NSArray *)participants;
- (LYRMessagePart *)createMessagePartAsMIMEType:(NSString *)mimeType withDataContents:(NSData *)contents;
- (void)addParticipants:(NSArray *)participants toConversation:(LYRConversation *)conversation withCompletion:(void (^)(BOOL success, NSError * error))completion;
- (void)dropParticipants:(NSArray *)participants fromConversation:(LYRConversation *)conversation excludeActiveUser:(BOOL)excludeUser withCompletion:(void (^)(BOOL success, NSError * error))completion;

//- (LYRMessage *)composeTxtMsgWithContent:(NSString *)txtContent attachingRemotePushUserInfo:(NSDictionary *)userInfo;
//- (LYRMessage *)composeMessageWithParts:(NSArray *)parts andDeliveringPushWithInfo:(NSDictionary *)userInfo;
@end
