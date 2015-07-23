//
//  HONPubNubOverseer.m
//  HotOrNot
//
//  Created by BIM  on 3/18/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+BuiltInMenlo.h"

#import "HONPubNubOverseer.h"

NSString * const kPubNubConfigDomain = @"pubsub.pubnub.com";
NSString * const kPubNubPublishKey = @"pub-c-a4abb7b2-2e28-43c4-b8f1-b2de162a79c3";
NSString * const kPubNubSubscribeKey = @"sub-c-ed10ba66-c9b8-11e4-bf07-0619f8945a4f";
NSString * const kPubNubSecretKey = @"sec-c-OTI3ZWQ4NWYtZDRkNi00OGFjLTgxMjctZDkwYzRlN2NkNDgy";


@implementation HONPubNubOverseer
static HONPubNubOverseer *sharedInstance = nil;

+ (HONPubNubOverseer *)sharedInstance {
	static HONPubNubOverseer *s_sharedInstance = nil;
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

- (void)activateService {
	[PubNub setConfiguration:[PNConfiguration configurationForOrigin:kPubNubConfigDomain
														  publishKey:kPubNubPublishKey //@"demo"//
														subscribeKey:kPubNubSubscribeKey //@"demo"//
														   secretKey:kPubNubSecretKey]]; //nil]];//
	
	[PubNub connectWithSuccessBlock:^(NSString *origin) {
		PNLog(PNLogGeneralLevel, self, @"{BLOCK} PubNub client connected to: %@", origin);
		NSLog(@"PubNub CONNECT:[%@]", origin);
		[[HONUserAssistant sharedInstance] writeUserID:[PubNub sharedInstance].clientIdentifier];
		
	} errorBlock:^(PNError *connectionError) {
		NSLog(@"PubNub CONNECT ERROR:[%@]", connectionError);
		
		if (connectionError.code == kPNClientConnectionFailedOnInternetFailureError) {
			
			// wait 1 second
			int64_t delayInSeconds = 1.0;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				PNLog(PNLogGeneralLevel, self, @"Connection will be established as soon as internet connection will be restored");
			});
		}
		
//		[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@(%@)", [connectionError localizedDescription], NSStringFromClass([self class])]
//									message:[NSString stringWithFormat:@"Reason:\n%@\n\nSuggestion:\n%@", [connectionError localizedFailureReason], [connectionError localizedRecoverySuggestion]]
//								   delegate:nil
//						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
//						  otherButtonTitles:nil] show];
	}];
}

- (PNChannel *)channelForStatusUpdate:(HONStatusUpdateVO *)statusUpdateVO {
	return ([PNChannel channelWithName:[NSString stringWithFormat:@"%d_%d", statusUpdateVO.userID, statusUpdateVO.statusUpdateID] shouldObservePresence:YES]);
}

- (void)statusUpdateForChannel:(PNChannel *)channel withCompletion:(void (^)(id))completion {
	[[HONAPICaller sharedInstance] retrieveChallengeForChallengeID:[[channel.name lastComponentByDelimeter:@"_"] intValue] completion:^(NSDictionary *result) {
		if (completion)
			completion([HONStatusUpdateVO statusUpdateWithDictionary:result]);
	}];
}

@end
