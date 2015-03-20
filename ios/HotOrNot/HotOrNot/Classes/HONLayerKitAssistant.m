//
//  HONLayerKitAssistant.m
//  HotOrNot
//
//  Created by BIM  on 1/18/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "LYRConversation+BuiltinMenlo.h"

#import "NSArray+BuiltinMenlo.h"
#import "NSDictionary+BuiltinMenlo.h"
#import "NSString+BuiltinMenlo.h"

#import "HONLayerKitAssistant.h"
#import "HONUserVO.h"

//#if __DEV_BUILD__ == 0 || __APPSTORE_BUILD__ == 1
//NSString * const kAppID = @"dda63b70-9f7c-11e4-b4d9-142b010033d0";
//NSString * const kProviderID = @"f1db7d52-9a9b-11e4-b72d-fcf042002b3c";
//NSString * const kKeyID = @"4a9e5b5c-a803-11e4-baa8-f3a514007a0e";
//NSString * const kPrivateKey = @"-----BEGIN RSA PRIVATE KEY-----\nMIICWwIBAAKBgGor9LKTWmeSZEJYJEka5PJmnklPniuopT4GTzEhEjFiD0Rw/Q1P\n1LOdx+qCHZudjIIdF7/9Cu695M90OAmkiJ/3NH9GBe+UJC3q0Fvppf0ZUJr7H7uR\nBVU7LuymAVKmX9YgCSwGib44ElwhHsEjHsP6F0rr9EuKgoNuhtZ6FBY5AgMBAAEC\ngYAjPmIlIUsCVJMZft7UsavMV4o1tctAnOP1eeyx11ONtwpwYr1tvNFTqo2hZ/3i\nGWN6EaQ/pAUMCVc6Ek9DzC1Z1vez30V+Ly9DlZpjmmproOMlBWO1xK2UszkS90Gh\nvYpCxImXxjA2VuwVfXnLbfmn0L/VG84nDXWasr2uhQEQzTQJBAK6pfJ3PlC7WGa1w\nmvU9CarnVn9qTj4D0eh/3c0JSt8DYvc1tEq/UxzCXc/Feg3VdfcmWw3IUlwsjMdC\nXiQsK9MCQQCbnVKF1d7jeEqeVnqEblcA5QPBljTNAZ1LxGnjWjvP2zZAE9kM0cyR\nqvl1viADHLkDehxZ0LfetIyFoes+3CpDAkEAmwHLmHpKdi6IZ0ZSH2bmF4hrWXTM\nr3jQZ1hjTb37dmQZBm/g651Uc2eDvgrxwSk6IfcmQ9sOTMM0xPn/dnbFBQJACsSl\nLDuzc7wkNba4PafA/3/ZdbDmMHV3JAIQbboVv3lk1KRK9bci18WkA4DHiE+ZgeMW\nSSTHRHLr8mdU9wGXLwJADkWkfTZldqyiBBe+n4z6t7HmmszyKuvhsUK9dA/xuSUy\nhtjuuQh7mhPnmK9RRbHru4b+cNt9NJdTHI1GZSkTEQ==\n-----END RSA PRIVATE KEY-----";
//NSString * const kJWTBaseURL = @"https://layer-identity-provider.herokuapp.com";
//NSString * const kJWTPostPath = @"identity_tokens";
//#else
NSString * const kAppID = @"065f2894-b597-11e4-845c-7dab3d0102b4";//f1dd72a6-9a9b-11e4-8fe1-fcf042002b3c";//dda6367a-9f7c-11e4-9d57-142b010033d0";
NSString * const kProviderID = @"f1db7d52-9a9b-11e4-b72d-fcf042002b3c";//f1db7d52-9a9b-11e4-b72d-fcf042002b3c";
NSString * const kKeyID = @"43e4813c-b597-11e4-af88-7dab3d0102b4";//d75c2e0a-a1f7-11e4-8ec0-142b010033d0";
NSString * const kPrivateKey = @"-----BEGIN RSA PRIVATE KEY-----\nMIICWwIBAAKBgGs8+1t5fc+el5Te3KLcpeo3y0Mu4GR3k3ilIOzQYUHnWlzJYHwH\nmszIsGqIGj94JeR9b8uBxlYO8Q3nd3ojq0UG+NaFzPlzgAnzxeuc9wvVkBc7/Wnj\nIPMj+JJNp05dWY+M/lUo8kRB/BVSuhgotY3Y05fKPm1fSOfDg6QEbOBHAgMBAAEC\ngYAuQUN6FVE6+IERaX9pkBrQh/hYpiOLsjgd1bv56XfJ4WyMkR/Y377ZjcbqbIJF\n1iEiCSjrcrKF9DPtd2WFfVUmBgGz+YB+JsTTTjU8rZEAxH6xMFDTVLFjm43xrfo9\nUBrN4sLQGaMM/xCXb7Up17Bi79SR9IABUB5q5vI5spTnYQJBAKjh46ybt/XRLCvc\nFyWldeQ1GnKT6nkxo8WpHqVaR91Aoyt7uCKfkBHeHFg83mzut8CWABu5lJnf8dXt\nwAEfX4sCQQCijotvH0qgUrpl66//pzxrALyIeqviTZBiGZMQoPbnDAJkLzwCx93v\nliS8NqVQK0zDziYuFagex18A61bD9Vm1AkEAm0Alg60XHRRwjdVjNgl4ahTjPkd6\nOnWGv5OsB4gKHnxoQ/YVHUcgMzzDQ96Y/v0o0RNUACjHUfmMIQTSCHYl5wJAB5KW\nYkXV5yQTdN4G4+T5ho6ROdZlHXS5jihc1oB5IAhKMDqXFBYVe6zF51KwXsy1lcWL\nt8fgfhaRkWxlLVnHpQJAELdITlhoAMVSXKZZJxDhjUgJ1HDl7h7IY4N/yRjwvoz5\ns5wp8JiWoS2tZKJdlq+8BKCPH4QU+OLQoDxL+KABNw==\n-----END RSA PRIVATE KEY-----\n";
NSString * const kJWTBaseURL = @"https://layer-identity-provider.herokuapp.com";
NSString * const kJWTPostPath = @"identity_tokens";
//#endif

/* -----BEGIN RSA PRIVATE KEY-----
MIICWwIBAAKBgQCGiamrRs2z6y06hP4DJamCXKxWCIz5CTulto7Loh7JQnnHE8eU
0KIE4hOAPZRgbKVv5SpBEQl7SOL4raKltRNLmV1G7YHZy4kgxpx/+1q0rUGP9FJ9
T/ksgFTfhUD5e/RfIzn4iNacVMDLaCGhpbiYe/kwAw3KNSFm7k1DpOTvzwIDAQAB
AoGAEBpB+IIM9M/dJffs/ytu0m+NIO79EIGOZhMnnC/XR3dxY+Z2KNWfzr3QX7T/
IVtfobjoCcmkPOFIaUM/CF5X5LN81iYGWUu3tj0xIVOFxG2JrRRgMRHvirg06jzS
3vwT1dx2tJ4qZFshNNORNmdLNJ1tBO0azE+OKCRCo/YpyeECQQDamY2C1m8QNL6U
CQQFIwWG8aRMisx3xgBsKmRD3JuIPe7n1nuDz5VO1Qs9C8By0prBMoej6uUAzBfd
ZtXgVTirAkEAnY5HGIpHzwJWSdV1SFw9E1B84r7EOfVnF/a0o4a07gHUnKBq+dU1
Dlr6GvY5K4kLrWgySf81zgkUgK/afHFtbQJAe6vFsJDKUrvUWgHjwVg350lML3WT
Cev+DzPId9AWOfT39TeVt1O4X9oNuqKsZQmbPdPtgyIAHvxYQAzO0VTFcwJAWGZy
54b2oWR7S7PzuSTfs82ONJ66dJaHQH/QfIvhSkVGqJatTv3cZfCPsb8C9rVPEv2K
cdA6vR6FHWsNmJL/xQJAeb3xMkGUe1pZms62mja4rVPuy+QKfgARZNtuM96d6NVq
fVCqrXv/Ic7WO+2flwcKsx+aWqvuCEsR+vUcofGhpQ==
-----END RSA PRIVATE KEY-----
*/

@interface HONLayerKitAssistant () <LYRClientDelegate, LYRQueryable, LYRQueryControllerDelegate>
- (LYRClient *)sharedClient;
- (NSMutableDictionary *)mutableLayerDict;
- (LYRMessage *)messageFromRemoteNotification:(NSDictionary *)remoteNotification;
- (void)addItemsToLocalDict:(NSArray *)items withKeys:(NSArray *)keys;
- (void)purgeItemsFromLocalDictWithKeys:(NSArray *)keys;
- (void)replaceLocalDictItems:(NSArray *)items forKeys:(NSArray *)keys;
@end

@implementation HONLayerKitAssistant
static HONLayerKitAssistant *sharedInstance = nil;
static LYRClient *sharedClient = nil;

+ (HONLayerKitAssistant *)sharedInstance {
	static HONLayerKitAssistant *s_sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		s_sharedInstance = [[self alloc] init];
	});
	
	return (s_sharedInstance);
}

- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}

- (LYRClient *)client {
	return ([self sharedClient]);
}


#pragma mark - Push Notifications
- (void)notifyClientWithPushToken:(NSData *)deviceToken {
	NSLog(@"%@ - notifyClientWithPushToken:[%@]", [self description], [[[[deviceToken description] substringFromIndex:1] substringToIndex:[[deviceToken description] length] - 2] stringByReplacingOccurrencesOfString:@" " withString:@""]);
	[[HONLayerKitAssistant sharedInstance] writePushToken:deviceToken];
	
	LYRClient *client = [[HONLayerKitAssistant sharedInstance] client];
	if ([client authenticatedUserID] != nil && ![[self mutableLayerDict] hasObjectForKey:@"push_reg"]) {
		NSError *error;
		BOOL success = [client updateRemoteNotificationDeviceToken:deviceToken error:&error];
		
		if (success) {
			[self addItemsToLocalDict:@[NSStringFromBOOL(YES)] withKeys:@[@"push_reg"]];
			NSLog(@"Client already authed, now registered for remote notifications");
			
		} else {
			NSLog(@"Error updating Layer device token for push:%@", error);
		}
	}
	
	[self addItemsToLocalDict:@[deviceToken] withKeys:@[@"push_token"]];
}

- (void)notifyClientPushTokenNotAvailibleFromError:(NSError *)error {
	NSLog(@"%@ - notifyClientPushTokenNotAvailibleFromError:[%@]", [self description], error.description);
	[self purgeItemsFromLocalDictWithKeys:@[@"push_token", @"push_reg"]];
}

- (void)notifyClientRemotePushWasReceived:(NSDictionary *)userInfo withCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	NSLog(@"%@ - notifyClientRemotePushWasReceived:[%@]", [self description], userInfo);
	
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.33 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
	// Get the message from userInfo
	__block LYRMessage *message = [self messageFromRemoteNotification:userInfo];
	
	
//	LYRMessage *message = conversation.lastMessage;
	
	
	
	LYRClient *client = [[HONLayerKitAssistant sharedInstance] client];
	BOOL success = false;
	success = [client synchronizeWithRemoteNotification:userInfo completion:^(NSArray *changes, NSError *error) {
		
		if (changes) {
			if ([changes count] > 0) {
				NSLog (@"-=- UIBackgroundFetchResultNewData -=-");
				
				// Get the message from userInfo
				message = [self messageFromRemoteNotification:userInfo];
				
				NSString *alertString = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];//  [[NSString alloc] initWithData:[message.parts[0] data] encoding:NSUTF8StringEncoding];
				
				// Show a local notification
				UILocalNotification *localNotification = [UILocalNotification new];
				localNotification.alertBody = alertString;
				localNotification.soundName = UILocalNotificationDefaultSoundName;
				[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
				[[HONAudioMaestro sharedInstance] cafPlaybackWithFilename:@"selfie_notification"];
				
				if (completionHandler)
					completionHandler(UIBackgroundFetchResultNewData);
				
			} else {
				NSLog (@"-=- UIBackgroundFetchResultNoData -=-");
				if (completionHandler)
					completionHandler(UIBackgroundFetchResultNoData);
			}
			
		} else {
			NSLog (@"-=- UIBackgroundFetchResultFailed -=-");
			if (completionHandler)
				completionHandler(UIBackgroundFetchResultFailed);
		}
	}];
	
	if (success) {
		NSLog (@"Application did complete remote notification sync");
		
	} else {
//		NSLog (@"Failed processing push notification with error: %@", error);
		if (completionHandler)
			completionHandler(UIBackgroundFetchResultNoData);
	}
		});
}



#pragma mark - Connection
- (void)connectClientToServiceWithCompletion:(void (^)(BOOL success, NSError * error))completion {
	NSLog(@"%@ - connectClientToServiceWithCompletion:", [self description]);
	
	// Tells LYRClient to establish a connection with the Layer service
	[[[HONLayerKitAssistant sharedInstance] client] connectWithCompletion:^(BOOL success, NSError *error) {
		
		if (!success)
			NSLog(@"Client ain't able to connect!! %@", error.description);
		
		else {
			NSLog(@"Client is Connected! %@", [[HONLayerKitAssistant sharedInstance] client]);
			
			/*
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(_LYRClientDidAuthenticateNotification:)
														 name:LYRClientDidAuthenticateNotification object:nil];
			
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(_LYRClientDidDeauthenticateNotification:)
														 name:LYRClientDidDeauthenticateNotification object:nil];
			
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(_LYRClientWillBeginSynchronizationNotification:)
														 name:LYRClientWillBeginSynchronizationNotification object:nil];
			
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(_LYRClientDidFinishSynchronizationNotification:)
														 name:LYRClientDidFinishSynchronizationNotification object:nil];
			
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(_LYRClientObjectsDidChangeNotification:)
														 name:LYRClientObjectsDidChangeNotification object:nil];
			
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(_LYRClientWillAttemptToConnectNotification:)
														 name:LYRClientWillAttemptToConnectNotification object:nil];
			
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(_LYRClientDidConnectNotification:)
														 name:LYRClientDidConnectNotification object:nil];
			
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(_LYRClientDidLoseConnectionNotification:)
														 name:LYRClientDidLoseConnectionNotification object:nil];
			
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(_LYRClientDidDisconnectNotification:)
														 name:LYRClientDidDisconnectNotification object:nil];
			
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(_LYRConversationDidReceiveTypingIndicatorNotification:)
														 name:LYRConversationDidReceiveTypingIndicatorNotification object:nil];
			 */
		}
		
		if (completion)
			completion(success, error);
	}];
}

- (void)authenticateUserWithUserID:(int)userID withCompletion:(void (^)(BOOL success, NSError * error))completion {
	NSLog(@"%@ - authenticateUserWithUserID:[%d]", [self description], userID);
	
	if ([[[HONLayerKitAssistant sharedInstance] client] authenticatedUserID] != nil) {
		if ([[HONLayerKitAssistant sharedInstance] pushTokenForActiveUser] != nil && ![[self mutableLayerDict] hasObjectForKey:@"push_reg"]) {
			NSError *error;
			BOOL success = [[[HONLayerKitAssistant sharedInstance] client] updateRemoteNotificationDeviceToken:[[HONLayerKitAssistant sharedInstance] pushTokenForActiveUser] error:&error];
			
			if (success) {
				[self addItemsToLocalDict:@[NSStringFromBOOL(YES)] withKeys:@[@"push_reg"]];
				NSLog(@"Client already authed, now registered for remote notifications");
				
			} else {
				NSLog(@"Error updating Layer device token for push:%@", error);
			}
			
		}
		
		if (completion)
			completion(YES, nil);
	
	} else {
		// Authenticate with Layer
		// See "Quick Start - Authenticate" for more details
		// https://developer.layer.com/docs/quick-start/ios#authenticate
		
		// i). Request an authentication nonce from Layer
		[[[HONLayerKitAssistant sharedInstance] client] requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
			if (!nonce) {
				if (completion)
					completion(YES, error);
			
			} else {
				
				// ii). Acquire identity token from Layer identity service
				NSDictionary *params = @{@"app_id"	: [[[HONLayerKitAssistant sharedInstance] client].appID UUIDString],
										 @"user_id"	: NSStringFromInt(userID),
										 @"nonce"	: nonce};
				
				SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", kJWTBaseURL, kJWTPostPath, params);
				[[[HONAPICaller sharedInstance] appendHeaders:@{@"Content-Type"		: kMIMETypeApplicationJSON,
																@"Accept"			: kMIMETypeApplicationJSON}
												 toHTTPCLient:[[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kJWTBaseURL]]] postPath:kJWTPostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					NSError *error = nil;
					NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
					
					if (error != nil) {
						SelfieclubJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
						[[HONAPICaller sharedInstance] showDataErrorHUD];
						
						if (completion)
							completion(NO, error);
						
					} else {
						SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
						[[HONLayerKitAssistant sharedInstance] writeIdentityToken:[result objectForKey:@"identity_token"]];
						
						// iii). Submit identity token to Layer for validation
						[[[HONLayerKitAssistant sharedInstance] client] authenticateWithIdentityToken:[result objectForKey:@"identity_token"] completion:^(NSString *authenticatedUserID, NSError *error) {
							NSLog(@"authenticateWithIdentityToken:[%@] //—> (authenticatedUserID:[%@] error:[%@])", [result objectForKey:@"identity_token"], authenticatedUserID, error);
							
							[[HONLayerKitAssistant sharedInstance] writeIdentityToken:(authenticatedUserID) ? [result objectForKey:@"identity_token"] : nil];
							
							if (error != nil) {
								NSLog(@"Couldn't authenticate identity token!\n%@", error);
								if (completion)
									completion(NO, error);
								
							} else {
								if ([[HONLayerKitAssistant sharedInstance] pushTokenForActiveUser] != nil) {
									NSError *error;
									BOOL success = [[[HONLayerKitAssistant sharedInstance] client] updateRemoteNotificationDeviceToken:[[[HONLayerKitAssistant sharedInstance] mutableLayerDict] objectForKey:@"push_token"] error:&error];
									if (success) {
										NSLog(@"Client now authed & registered for push notifications");
									} else {
										NSLog(@"Error updating Layer device token for push:%@", error);
									}
								}
							}
							
							if (completion)
								completion((error == nil), nil);
						}];
					}
					
				} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@ ) Failed Request - %@", [[self class] description], kJWTBaseURL, kJWTPostPath, [error localizedDescription]);
					[[HONAPICaller sharedInstance] showDataErrorHUD];
					
					[[HONLayerKitAssistant sharedInstance] writeIdentityToken:nil];
					
					if (completion)
						completion(NO, error);
				}];
			}
		}];
	}
}


- (void)deauthenticateActiveUserWithCompletion:(void (^)(id result))completion {
	LYRClient *client = [[HONLayerKitAssistant sharedInstance] client];
	
	if ([client authenticatedUserID] == nil) {
		if (completion)
			completion(@"Ain't authed!");
	
	} else {
		[client deauthenticateWithCompletion:^(BOOL success, NSError *error) {
			if (success) {
				if (completion)
					completion(@"DEAUTHED");
			
			} else {
				if (completion)
					completion(error);
			}
		}];
	}
}


#pragma mark - Convos / Messages
- (LYRConversation *)conversationWithParticipants:(NSArray *)participants {
	LYRConversation *conversation = nil;
	
	LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
	
	query.predicate = [LYRPredicate predicateWithProperty:@"participants" operator:LYRPredicateOperatorIsEqualTo value:participants];
	query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
	
	NSError *error;
	NSOrderedSet *conversations = [[[HONLayerKitAssistant sharedInstance] client] executeQuery:query error:&error];
	if (!error) {
		NSLog(@"%tu conversations with participants %@", conversations.count, participants);
	} else {
		NSLog(@"Query failed with error %@", error);
	}
	
	// Retrieve the last conversation
	if (conversations.count) {
		conversation = [conversations lastObject];
		NSLog(@"Get last conversation object: %@", conversation.identifierSuffix);
	}
	
	return (conversation);
}


- (NSArray *)buildConversationParticipantsForClub:(HONUserClubVO *)clubVO {
	__block NSMutableArray *users = [NSMutableArray array];
	
	[[[NSUserDefaults standardUserDefaults] objectForKey:@"user_lookup"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
		NSDictionary *dict = (NSDictionary *)obj;
		
		if ([[dict objectForKey:@"id"] intValue] != 0)
			[users addObject:NSStringFromInt([[dict objectForKey:@"id"] intValue])];
	}];
	
	NSArray *participants = [NSArray arrayRandomizedWithArray:users withCapacity:MIN(25, [users count] - 1)];
//	[[NSArray arrayRandomizedWithArray:clubVO.activeMembers withCapacity:25] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		HONUserVO *userVO = (HONUserVO *)obj;
//		[participants addObject:NSStringFromInt(userVO.userID)];
//	}];
	
	NSLog(@"clubVO.activeMembers:[%d]\nparticipants:[%@]", (int)[[[NSUserDefaults standardUserDefaults] objectForKey:@"user_lookup"] count], participants);
	
	NSMutableSet *set = [NSMutableSet setWithArray:participants];
	[set minusSet:[NSSet setWithObject:NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID])]];
	
	return ([set allObjects]);
}

- (LYRConversation *)generateConversationWithParticipants:(NSArray *)participants withTopicName:(NSString *)topic andSubject:(NSString *)subject {
	NSDictionary *metaData = @{@"creator_id"	: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
							   @"creator_name"	: [[HONUserAssistant sharedInstance] activeUsername],
							   @"topic"			: topic,
							   @"subject"		: subject};
	
	
	NSError *error;
	LYRConversation *conversation = [[[HONLayerKitAssistant sharedInstance] client] newConversationWithParticipants:[NSSet setWithArray:participants]
																											options:metaData
																											  error:&error];
	[conversation setValuesForMetadataKeyPathsWithDictionary:metaData merge:YES];
	NSLog(@"CREATED CONVERSATION: -=-(%@)-=-\n%@", NSStringFromBOOL(error == nil), [conversation toString]);
	
	return (conversation);
}

- (LYRMessage *)generateMessageOfType:(HONMessageType)messageType withContent:(NSData *)dataContent {
	
	NSError *error = nil;
	LYRMessagePart *messagePart = [LYRMessagePart messagePartWithMIMEType:((messageType == HONMessageTypeText) ? kMIMETypeTextPlain : (messageType == HONMessageTypeImage) ? kMIMETypeImagePNG : kMIMETypeTextPlain) data:dataContent];
	LYRMessage *message = [[[HONLayerKitAssistant sharedInstance] client] newMessageWithParts:@[messagePart] options:nil error:&error];
	
	NSLog (@"CREATED MESSAGE: -=-(%@)-=-\n%@", NSStringFromBOOL(error == nil), message.identifierSuffix);
	
//	[message markAsRead:&error];

	return (message);
}

- (BOOL)sendMessage:(LYRMessage *)message toConversation:(LYRConversation *)conversation {
	
	NSError *error = nil;
	BOOL success = [conversation sendMessage:message error:&error];
	NSLog (@"SENT MESSAGE: -=-(%@)-=-\n%@", NSStringFromBOOL(error == nil), message.identifierSuffix);
	
	if (!success) {
		NSLog(@"Create message failed!\n%@", error);
	}
	
	return (success);
}


- (LYRConversation *)createConversationForStatusUpdate:(HONStatusUpdateVO *)statusUpdateVO {
	LYRConversation *conversation = nil;
	NSError *error = nil;
	
	LYRClient *client = [[HONLayerKitAssistant sharedInstance] client];
	
	// Creates and returns a new conversation object with a single participant represented by your backend's user identifier for the participant
	conversation = [client newConversationWithParticipants:[NSSet setWithArray:@[NSStringFromInt(statusUpdateVO.userID)]] options:nil error:&error];
	[conversation setValue:NSStringFromInt(statusUpdateVO.statusUpdateID) forMetadataAtKeyPath:@"status_update.id"];
	[conversation setValue:NSStringFromInt(statusUpdateVO.userID) forMetadataAtKeyPath:@"status_update.owner_id"];
	
	return (conversation);
}

- (LYRMessagePart *)createMessagePartAsMIMEType:(NSString *)mimeType withDataContents:(NSData *)contents {
	return ([LYRMessagePart messagePartWithMIMEType:mimeType data:contents]);
}

- (void)addParticipants:(NSArray *)participants toConversation:(LYRConversation *)conversation withCompletion:(void (^)(BOOL success, NSError * error))completion {
	
	__block NSMutableArray *uniqueParticipants = [NSMutableArray array];
	[participants enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSString *userID = (NSString *)obj;
		
		if (![uniqueParticipants containsObject:userID] && ![conversation.participants containsObject:userID])
			[uniqueParticipants addObject:userID];
	}];
	
	NSError *error = nil;
	[conversation addParticipants:[NSSet setWithArray:uniqueParticipants] error:&error];
	
	if (completion) {
		completion((error == nil), error);
	}
}

- (void)dropParticipants:(NSArray *)participants fromConversation:(LYRConversation *)conversation excludeActiveUser:(BOOL)excludeUser withCompletion:(void (^)(BOOL success, NSError * error))completion {
	
//	NSMutableSet *set = [NSMutableSet setWithSet:conversation.participants];
//	[set intersectSet:[NSSet setWithArray:participants]];
//	
//	__block NSMutableArray *uniqueParticipants = [NSMutableArray array];
//	[participants enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		NSString *userID = (NSString *)obj;
//		
//		if (excludeUser) {
//			if (![userID isEqualToString:NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID])] && ![uniqueParticipants containsObject:userID] && [conversation.participants containsObject:userID])
//				[uniqueParticipants addObject:userID];
//			
//		} else {
//			if (![uniqueParticipants containsObject:userID] && [conversation.participants containsObject:userID])
//				[uniqueParticipants addObject:userID];
//		}
//	}];
//	
//	NSLog(@"DROPPING PARTICIPANTS FROM:[%@]\n%@", conversation.identifierSuffix, uniqueParticipants);
//	
//	
//	NSError *error = nil;
//	[conversation removeParticipants:[NSSet setWithArray:uniqueParticipants] error:&error];
//	
//	if (completion) {
//		completion((error == nil), error);
//	}
	
	if (completion) {
		completion(YES, nil);
	}
}

- (void)purgeParticipantsFromConversation:(LYRConversation *)conversation includeOwner:(BOOL)isOwner withCompletion:(void (^)(BOOL success, NSError * error))completion {
	NSMutableSet *dropParticipants = [NSMutableSet setWithSet:conversation.participants];
	
	if (!isOwner)
		[dropParticipants removeObject:NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID])];
	
	NSLog(@"DROPPING PARTICIPANTS FROM:[%@]\n%@", conversation.identifierSuffix, dropParticipants);
	
	NSError *error = nil;
	[conversation removeParticipants:dropParticipants error:&error];
	
	if (completion)
		completion((error == nil), error);
}

- (void)addTxtMessage:(NSString *)msg toStatusUpdate:(HONStatusUpdateVO *)statusUpdateVO withCompletion:(void (^)(id))completion {
	LYRClient *client = [[HONLayerKitAssistant sharedInstance] client];
	
	__block NSMutableArray *participants = [NSMutableArray arrayWithObject:NSStringFromInt(statusUpdateVO.userID)];
	[statusUpdateVO.replies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONCommentVO *vo = (HONCommentVO *)obj;
		
		if (![participants containsObject:NSStringFromInt(vo.userID)])
			[participants addObject:NSStringFromInt(vo.userID)];
	}];
	
	LYRConversation *conversation = [[HONLayerKitAssistant sharedInstance] conversationWithParticipants:participants];
	
	
	// Creates a message part with a text/plain MIMEType and returns a new message object with the given conversation and array of message parts - Sends the specified message
	NSError *error = nil;
	LYRMessage *message = [client newMessageWithParts:@[[LYRMessagePart messagePartWithMIMEType:kMIMETypeTextPlain data:[statusUpdateVO.comment dataUsingEncoding:NSUTF8StringEncoding]]] options:@{LYRMessageOptionsPushNotificationAlertKey: [NSString stringWithFormat:@"%@ says “%@”", [[HONUserAssistant sharedInstance] activeUsername], msg]} error:&error];
	NSLog (@"MESSAGE OBJ:[%@]", message.identifier);
	
	BOOL success = [conversation sendMessage:message error:&error];
	NSLog (@"MESSAGE RESULT:- %@", NSStringFromBOOL(success));
	
	if (completion)
		completion(message);
}


#pragma mark - Local Store
- (NSString *)identityTokenForActiveUser {
	return (([[self mutableLayerDict] objectForKey:@"auth_token"] != nil || [[[self mutableLayerDict] objectForKey:@"auth_token"] length] > 0) ? [[self mutableLayerDict] objectForKey:@"auth_token"] : nil);
}

- (void)writeIdentityToken:(NSString *)token {
	if (token == nil)
		[self purgeItemsFromLocalDictWithKeys:@[@"auth_token"]];
	
	else
		[self replaceLocalDictItems:@[token] forKeys:@[@"auth_token"]];
}

- (NSData *)pushTokenForActiveUser {
	return (([[self mutableLayerDict] objectForKey:@"push_token"] != nil || [[[self mutableLayerDict] objectForKey:@"push_token"] length] > 0) ? [[self mutableLayerDict] objectForKey:@"push_token"] : nil);
}

- (void)writePushToken:(NSData *)token {
	
	if (token == nil) {
		[self purgeItemsFromLocalDictWithKeys:@[@"push_token", @"push_reg"]];
		
	} else
		[self replaceLocalDictItems:@[token] forKeys:@[@"push_token"]];
}



- (LYRRecipientStatus)latestRecipientStatusForMessage:(LYRMessage *)message {
	
	NSMutableDictionary *dict = [[message recipientStatusByUserID] mutableCopy];
	if ([message creatorID] == [[HONUserAssistant sharedInstance] activeUserID])
		[dict removeObjectForKey:NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID])];
		
		
	NSArray *recipients = [dict keysSortedByValueUsingComparator:^(id obj1, id obj2) {
		if ([obj1 intValue] > [obj2 intValue])
			return ((NSComparisonResult)NSOrderedDescending);
		
		if ([obj1 intValue] < [obj2 intValue])
			return ((NSComparisonResult)NSOrderedAscending);
		
		return ((NSComparisonResult)NSOrderedSame);
	}];
	
//	NSLog(@"LAST RECIPS:%d", (LYRRecipientStatus)[[[message recipientStatusByUserID] objectForKey:[recipients lastObject]] intValue]);
	return ((LYRRecipientStatus)[[[message recipientStatusByUserID] objectForKey:[recipients lastObject]] intValue]);
}


#pragma mark - Notifications
/*
- (void)_LYRClientDidAuthenticateNotification:(NSNotification *)notification {
	NSLog (@"::|>_LYRClientDidAuthenticateNotification:%@\n[=-=-=-=-=-=-=-=]\n", notification);
}

- (void)_LYRClientDidDeauthenticateNotification:(NSNotification *)notification {
	NSLog (@"::|>> _LYRClientDidDeauthenticateNotification:%@\n[=-=-=-=-=-=-=-=]\n", notification);
}

- (void)_LYRClientWillBeginSynchronizationNotification:(NSNotification *)notification {
	NSLog (@"::|>> _LYRClientWillBeginSynchronizationNotification:%@\n[=-=-=-=-=-=-=-=]\n", notification);
}

- (void)_LYRClientDidFinishSynchronizationNotification:(NSNotification *)notification {
	NSLog (@"::|>> _LYRClientDidFinishSynchronizationNotification:%@\n[=-=-=-=-=-=-=-=]\n", notification);
}

- (void)_LYRClientObjectsDidChangeNotification:(NSNotification *)notification {
	NSLog (@"::|>_LYRClientObjectsDidChangeNotification:%@\n[=-=-=-=-=-=-=-=]\n", notification);
}

- (void)_LYRClientWillAttemptToConnectNotification:(NSNotification *)notification {
	NSLog (@"::|>_LYRClientWillAttemptToConnectNotification:%@\n[=-=-=-=-=-=-=-=]\n", notification);
}

- (void)_LYRClientDidConnectNotification:(NSNotification *)notification {
	NSLog (@"::|>_LYRClientDidConnectNotification:%@\n[=-=-=-=-=-=-=-=]\n", notification);
}

- (void)_LYRClientDidLoseConnectionNotification:(NSNotification *)notification {
	NSLog (@"::|>_LYRClientDidLoseConnectionNotification:%@\n[=-=-=-=-=-=-=-=]\n", notification);
}

- (void)_LYRClientDidDisconnectNotification:(NSNotification *)notification {
	NSLog (@"::|>_LYRClientDidDisconnectNotification:%@\n[=-=-=-=-=-=-=-=]\n", notification);
}

- (void)_LYRConversationDidReceiveTypingIndicatorNotification:(NSNotification *)notification {
	NSLog (@"::|>_LYRConversationDidReceiveTypingIndicatorNotification:%@\n[=-=-=-=-=-=-=-=]\n", notification);
}
*/
	
#pragma mark - LayerClient Delegates
- (void)layerClient:(LYRClient *)client didReceiveAuthenticationChallengeWithNonce:(NSString *)nonce {
	NSLog(@"[*:*] layerClient:didReceiveAuthenticationChallengeWithNonce:[%@])", nonce);
}

- (void)layerClient:(LYRClient *)client willAttemptToConnect:(NSUInteger)attemptNumber afterDelay:(NSTimeInterval)delayInterval maximumNumberOfAttempts:(NSUInteger)attemptLimit {
	NSLog(@"[*:*] layerClient:willAttemptToConnect:afterDelay:[%f]maximumNumberOfAttempts:[%lu]", delayInterval, (unsigned long)attemptLimit);
}

- (void)layerClientDidConnect:(LYRClient *)client {
	NSLog(@"[*:*]layerClientDidConnect:[%@]", client);
}

- (void)layerClient:(LYRClient *)client didLoseConnectionWithError:(NSError *)error {
	NSLog(@"[*:*] layerClient:didLoseConnectionWithError[%@])", error);
}

- (void)layerClientDidDisconnect:(LYRClient *)client {
	NSLog(@"[*:*] layerClientDidDisconnect:[%@])", client);
}

- (void)layerClient:(LYRClient *)client didAuthenticateAsUserID:(NSString *)userID {
	NSLog(@"[*:*] layerClient:didAuthenticateAsUserID[%@])", userID);
}

- (void)layerClientDidDeauthenticate:(LYRClient *)client {
	NSLog(@"[*:*] layerClientDidDeauthenticate:[%@])", client);
}

/**
 @abstract Tells the delegate that a client has finished synchronization and applied a set of changes.
 @param client The client that received the changes.
 @param changes An array of `NSDictionary` objects, each one describing a change.
 */
- (void)layerClient:(LYRClient *)client didFinishSynchronizationWithChanges:(NSArray *)changes  {
//	NSLog(@"[*:*] layerClient:didFinishSynchronizationWithChanges:[%@])", changes);
}

/**
 @abstract Tells the delegate the client encountered an error during synchronization.
 @param client The client that failed synchronization.
 @param error An error describing the nature of the sync failure.
 */
- (void)layerClient:(LYRClient *)client didFailSynchronizationWithError:(NSError *)error  {
//	NSLog(@"[*:*] layerClient:didFailSynchronizationWithError:[%@])", error);
}

/**
 @abstract Tells the delegate that objects associated with the client have changed due to local mutation or synchronization activities.
 @param client The client that received the changes.
 @param changes An array of `NSDictionary` objects, each one describing a change.
 @see LYRConstants.h
 */
- (void)layerClient:(LYRClient *)client objectsDidChange:(NSArray *)changes {
//	NSLog(@"[*:*] layerClient:objectsDidChange:[%@])", changes);
}

/**
 @abstract Tells the delegate that an operation encountered an error during a local mutation or synchronization activity.
 @param client The client that failed the operation.
 @param error An error describing the nature of the operation failure.
 */
- (void)layerClient:(LYRClient *)client didFailOperationWithError:(NSError *)error {
//	NSLog(@"[*:*] layerClient:didFailOperationWithError[%@])", error);
}



//- (LYRMessage *)composeTxtMsgWithContent:(NSString *)txtContent attachingRemotePushUserInfo:(NSDictionary *)userInfo {
//	
//}


#pragma mark - private helpers
- (LYRClient *)sharedClient {
	static LYRClient *s_sharedClient = nil;
	static dispatch_once_t onceToken2;
	
	dispatch_once(&onceToken2, ^{
		s_sharedClient = [LYRClient clientWithAppID:[[NSUUID alloc] initWithUUIDString:kAppID]];
		s_sharedClient.delegate = self;
	});
	
	return (s_sharedClient);
}

- (NSMutableDictionary *)mutableLayerDict {
	return (([[NSUserDefaults standardUserDefaults] objectForKey:@"layer"] == nil) ? [@{} mutableCopy] : [[[NSUserDefaults standardUserDefaults] objectForKey:@"layer"] mutableCopy]);
}

- (LYRMessage *)messageFromRemoteNotification:(NSDictionary *)remoteNotification {
	// Fetch message object from LayerKit
	//NSURL *identifier = [NSURL URLWithString:[remoteNotification valueForKeyPath:@"layer.message_identifier"]];
	
	
	LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
	query.predicate = [LYRPredicate predicateWithProperty:@"identifier" operator:LYRPredicateOperatorIsEqualTo value:[[remoteNotification objectForKey:@"layer"] objectForKey:@"message_identifier"]];
	
	NSError *error;
	NSOrderedSet *messages = [[[HONLayerKitAssistant sharedInstance] client] executeQuery:query error:&error];
	
	if (!error) {
//		[[HONLayerKitAssistant sharedInstance] authenticateUserWithUserID:[[HONUserAssistant sharedInstance] activeUserID] withCompletion:^(BOOL success, NSError *error) {
//			NSLog(@"AUTH RESULT:%@ -=- %@", NSStringFromBOOL(success), error);
		
			if ([messages count] > 0) {
				if ([[remoteNotification valueForKeyPath:@"aps.content-available"] integerValue] != 0) {
					NSInteger badgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];
					[[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber + 1];
				}
				
				NSLog(@"Query contains %lu messages", (unsigned long)messages.count);
				LYRMessage *message = messages.firstObject;
				NSLog(@"Message sent by %@", message.sentByUserID);
				LYRMessagePart *messagePart = [message.parts firstObject];
				NSLog(@"Pushed Message Contents: %@", [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding]);
				messagePart = [message.parts lastObject];
				NSLog(@"Pushed Message Contents: %@", [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding]);
				
				//LYRMessagePart *messagePart = [message.parts lastObject];
				
				
				NSError *error = nil;
				NSString *requestedConversationID = messagePart.textContent;
				NSLog(@"%@ -=- REQUESTED CONVO-ID:[%@]", error, requestedConversationID);
				LYRQuery *convoRequestQuery = [LYRQuery queryWithClass:[LYRConversation class]];
				convoRequestQuery.predicate = [LYRPredicate predicateWithProperty:@"identifier" operator:LYRPredicateOperatorIsEqualTo value:requestedConversationID];
				LYRConversation *conversationRequest = [[[[HONLayerKitAssistant sharedInstance] client] executeQuery:convoRequestQuery error:&error] firstObject];
				
//				LYRQuery *convoDMQuery = [LYRQuery queryWithClass:[LYRConversation class]];
//				convoDMQuery.predicate = [LYRPredicate predicateWithProperty:@"identifier" operator:LYRPredicateOperatorIsEqualTo value:[[remoteNotification objectForKey:@"layer"] objectForKey:@"conversation_identifier"]];////@"layer:///conversations/84b4e146-b051-4aeb-a84f-cb2cd4aa2f41"];
//				LYRConversation *conversationDM = [[[[HONLayerKitAssistant sharedInstance] client] executeQuery:convoDMQuery error:&error] firstObject];
				
				
				NSArray *participants = [conversationRequest.participants allObjects];
				NSMutableArray *uniqueParticipants = [NSMutableArray array];
				while ([uniqueParticipants count] < 25 - [conversationRequest.participants count]) {
					[uniqueParticipants addObject:[participants randomElement]];
				}
				
				[conversationRequest removeParticipants:[NSSet setWithArray:uniqueParticipants] error:&error];
				
				
				
				NSLog(@"%@ -=- REQUESTED CONVO:[%@]", error, conversationRequest);
//				[conversationRequest addParticipants:conversationDM.participants error:&error];
				[conversationRequest addParticipants:[NSSet setWithArray:@[message.sentByUserID]] error:&error];
				NSLog(@"%@ -=- REQUESTED CONVO RESULT:(%@)[%@]", error, [conversationRequest.participants allObjects], [conversationRequest toString]);
			}
			
			
//		[conversation delete:LYRDeletionModeAllParticipants error:nil];
			
//		}];
		
	} else {
		NSLog(@"Query failed with error %@", error);
	}
	
	return ([messages firstObject]);
}



- (void)addItemsToLocalDict:(NSArray *)items withKeys:(NSArray *)keys {
	NSMutableDictionary *dict = [[HONLayerKitAssistant sharedInstance] mutableLayerDict];
	[dict addObjects:items withKeys:keys];
	
	[[NSUserDefaults standardUserDefaults] replaceObject:[dict copy] forKey:@"layer"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)purgeItemsFromLocalDictWithKeys:(NSArray *)keys {
	NSMutableDictionary *dict = [[HONLayerKitAssistant sharedInstance] mutableLayerDict];
	[dict purgeObjectsWithKeys:keys];
	
	[[NSUserDefaults standardUserDefaults] replaceObject:[dict copy] forKey:@"layer"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)replaceLocalDictItems:(NSArray *)items forKeys:(NSArray *)keys {
	NSMutableDictionary *dict = [[HONLayerKitAssistant sharedInstance] mutableLayerDict];
	[dict replaceObjects:items withKeys:keys];
	
	[[NSUserDefaults standardUserDefaults] replaceObject:[dict copy] forKey:@"layer"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end



/** Matty's DEV Key -[df22dcdc-9fa0-11e4-bf50-142b010033d0]- **//**
 * -----BEGIN RSA PRIVATE KEY-----
 * MIICWgIBAAKBgGpiZnuhL3uTH5wp9FNkNj1kUKM/CN1ebkn8yX6zEVd7qb6QBj0a
 * izA6cw6NQ3tjsaUKLE33BUgOUU91ADJFdssNy5vGwM3yhqWt8I8YzawCz3/CnCoR
 * pE4ZQ2dJF4cpznyo3S+SNQisrWw3GJ1jYL9aIsKxwHvfO7Do+bptfUNDAgMBAAEC
 * gYBHLjO4AK9OlbAOwxuROHn6Ncamk6SQyYAtzQ/c0F+IE1wN/zvNYpdC27jkQayn
 * QJs5/EaMm/1SqxHIglZxTH0gnVVZNuUSWOlqg5O0tIGPp4Yu6744WJKC9DZdyacS
 * 7yb3fKbSD59aC0kdTvO30dTManVGa7im4wKcndnFT4320QJBALowAbJh/bjnbPUj
 * t//cT7Rs5htcA3TMbdEb+ph4flsS/2/DCupYVaABIgOu0D5ZNM0iXDLiONvFDL7w
 * eIuptp0CQQCSRicIaYxXBiCC6dGevQzm43etFP7E2jzJtH78guQzkX93lFp977jK
 * W3bEtJ4jlvVJd+mZ+VjQnd0bLotURMtfAkBRsFJuQ5Qgllk1zPAj8DOAQ+9Jvbs+
 * eZsNDiuKzgMSTmmITZjybMNUqmqUFxUC5fzGq/ar1JmBwxjuhW8+R735AkBtNMT1
 * id/GJQPm2WywB9L3GoKCDXe8Pnc93G0mVw7K1WkGPRNmjLA5HBpK99JNHepZhJY6
 * Z6gAcKvgHFrXelkfAkAjJmUAZmFV/P36y26sbsfBjBYa5cqR8QqeHmUZm7uL52FM
 * BpEb6aMnpTdgMLRgSx5IGBC20sBd/BG35UJVLZbv
 * -----END RSA PRIVATE KEY-----
 **/

/** devint Key -[f936b7c4-9fa0-11e4-8aee-142b010033d0]- **//**
 * -----BEGIN RSA PRIVATE KEY-----
 * MIICWwIBAAKBgGs8+1t5fc+el5Te3KLcpeo3y0Mu4GR3k3ilIOzQYUHnWlzJYHwH
 * mszIsGqIGj94JeR9b8uBxlYO8Q3nd3ojq0UG+NaFzPlzgAnzxeuc9wvVkBc7/Wnj
 * IPMj+JJNp05dWY+M/lUo8kRB/BVSuhgotY3Y05fKPm1fSOfDg6QEbOBHAgMBAAEC
 * gYAuQUN6FVE6+IERaX9pkBrQh/hYpiOLsjgd1bv56XfJ4WyMkR/Y377ZjcbqbIJF
 * 1iEiCSjrcrKF9DPtd2WFfVUmBgGz+YB+JsTTTjU8rZEAxH6xMFDTVLFjm43xrfo9
 * UBrN4sLQGaMM/xCXb7Up17Bi79SR9IABUB5q5vI5spTnYQJBAKjh46ybt/XRLCvc
 * FyWldeQ1GnKT6nkxo8WpHqVaR91Aoyt7uCKfkBHeHFg83mzut8CWABu5lJnf8dXt
 * wAEfX4sCQQCijotvH0qgUrpl66//pzxrALyIeqviTZBiGZMQoPbnDAJkLzwCx93v
 * liS8NqVQK0zDziYuFagex18A61bD9Vm1AkEAm0Alg60XHRRwjdVjNgl4ahTjPkd6
 * OnWGv5OsB4gKHnxoQ/YVHUcgMzzDQ96Y/v0o0RNUACjHUfmMIQTSCHYl5wJAB5KW
 * YkXV5yQTdN4G4+T5ho6ROdZlHXS5jihc1oB5IAhKMDqXFBYVe6zF51KwXsy1lcWL
 * t8fgfhaRkWxlLVnHpQJAELdITlhoAMVSXKZZJxDhjUgJ1HDl7h7IY4N/yRjwvoz5
 * s5wp8JiWoS2tZKJdlq+8BKCPH4QU+OLQoDxL+KABNw==
 * -----END RSA PRIVATE KEY-----
**/

/** prod key -[]- **//**
 * -----BEGIN RSA PRIVATE KEY-----
 * MIICWwIBAAKBgGor9LKTWmeSZEJYJEka5PJmnklPniuopT4GTzEhEjFiD0Rw/Q1P
 * 1LOdx+qCHZudjIIdF7/9Cu695M90OAmkiJ/3NH9GBe+UJC3q0Fvppf0ZUJr7H7uR
 * BVU7LuymAVKmX9YgCSwGib44ElwhHsEjHsP6F0rr9EuKgoNuhtZ6FBY5AgMBAAEC
 * gYAjPmIlIUsCVJMZft7UsavMV4o1tctAnOP1eeyx11ONtwpwYr1tvNFTqo2hZ/3i
 * GWN6EaQ/pAUMCVc6Ek9DzC1Z1vez30V+Ly9DlZpjmmproOMlBWO1xK2UszkS90Gh
 * vYpCxImXxjA2VuwVfXnLbfmn0L/VG84nDXWasr2uhQEQzTQJBAK6pfJ3PlC7WGa1w
 * mvU9CarnVn9qTj4D0eh/3c0JSt8DYvc1tEq/UxzCXc/Feg3VdfcmWw3IUlwsjMdC
 * XiQsK9MCQQCbnVKF1d7jeEqeVnqEblcA5QPBljTNAZ1LxGnjWjvP2zZAE9kM0cyR
 * qvl1viADHLkDehxZ0LfetIyFoes+3CpDAkEAmwHLmHpKdi6IZ0ZSH2bmF4hrWXTM
 * r3jQZ1hjTb37dmQZBm/g651Uc2eDvgrxwSk6IfcmQ9sOTMM0xPn/dnbFBQJACsSl
 * LDuzc7wkNba4PafA/3/ZdbDmMHV3JAIQbboVv3lk1KRK9bci18WkA4DHiE+ZgeMW
 * SSTHRHLr8mdU9wGXLwJADkWkfTZldqyiBBe+n4z6t7HmmszyKuvhsUK9dA/xuSUy
 * htjuuQh7mhPnmK9RRbHru4b+cNt9NJdTHI1GZSkTEQ==
 * -----END RSA PRIVATE KEY-----
**/