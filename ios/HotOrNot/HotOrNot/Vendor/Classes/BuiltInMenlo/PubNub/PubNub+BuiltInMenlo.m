//
//  PubNub+BuiltInMenlo.m
//  HotOrNot
//
//  Created by BIM  on 3/18/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+BuiltInMenlo.h"

#import "PubNub+BuiltInMenlo.h"


NSString * const kHONChatMessageTypeKey					= @"____";		// BLANK
NSString * const kHONChatMessageTypeUndeterminedKey		= @"__UDT__";	// UnDeTermined
NSString * const kHONChatMessageTypeSyncronizeKey		= @"__SYN__";	// SYNcronize
NSString * const kHONChatMessageTypeAcknowledgeKey		= @"__ACK__";	// ACKnowledge
NSString * const kHONChatMessageTypeAutomatedKey		= @"__AUT__";	// AUTomated
NSString * const kHONChatMessageTypeBotKey				= @"__BOT__";	// roBOT
NSString * const kHONChatMessageTypeTXTKey				= @"__TXT__";	// TeXT
NSString * const kHONChatMessageTypeIMGKey				= @"__IMG__";   // IMaGe
NSString * const kHONChatMessageTypeVIDKey				= @"__VID__";   // VIDeo
NSString * const kHONChatMessageTypeLeaveKey			= @"__BYE__";	// BYE-bye
NSString * const kHONChatMessageTypeCompleteKey			= @"__FIN__";	// FINished
NSString * const kHONChatMessageTypeErrorKey			= @"__ERR__";	// ERRor
NSString * const kHONChatMessageTypeNegativeKey			= @"__NAE__";	// Negative
NSString * const kHONChatMessageTypeAffirmativeKey		= @"__YAH__";	// Affirmative
NSString * const kHONChatMessageTypeQueryKey			= @"__QRY__";	// QueRY
NSString * const kHONChatMessageTypeAnswerKey			= @"__ANS__";	// ANSwer
NSString * const kHONChatMessageTypeDeleteKey			= @"__NIX__";	// Remove
NSString * const kHONChatMessageTypeUndefinedKey		= @"__UDF__";	// UnDeFined
NSString * const kHONChatMessageTypeUnknownKey			= @"__UNK__";	// UNKnown

NSString * const kHONChatMessageCoordsRoot		= @"coords://";
NSString * const kHONChatMessageImageRoot		= @"https://";


NSString * const kHONChatMessageFormat			= @"%d;%@|%@|%@:%@";
NSString * const kHONChatMessageCoordsFormat	= @"%.04f_%.04f";


@interface PubNub (BuiltinMeno)
@end

@implementation PubNub (BuiltInMenlo)
@end


@interface PNChannel (BuiltinMeno)
@end

@implementation PNChannel (BuiltInMenlo);
@end


@interface PNMessage (BuiltinMeno)
//- (HONChatMessageType)_messageTypeForKey:(NSString *)keyName;
+ (NSDictionary *)_messageTypeKeyNamePairs;
@end

@implementation PNMessage (BuiltInMenlo)

+ (NSString *)formattedCoordsForDeviceLocation {
	return ([PNMessage formattedCoordsForLocation:[[HONDeviceIntrinsics sharedInstance] deviceLocation]]);
}

+ (NSString *)formattedCoordsForLocation:(CLLocation *)location {
	return ([NSString stringWithFormat:kHONChatMessageCoordsFormat, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude]);
}

+ (NSString *)keyForMessageType:(HONChatMessageType)messageType {
	__block NSString *name = kHONChatMessageTypeUndeterminedKey;
	[[self _messageTypeKeyNamePairs] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if ((HONChatMessageType)[obj intValue] == messageType) {
			name = (NSString *)key;
			*stop = YES;
		}
	}];
	
	return (name);
}


+ (PNMessage *)publishSynchronizeMessageOnChannel:(PNChannel *)channel withCompletion:(PNClientMessageProcessingBlock)success {
//	[PubNub sendMessage:[NSString stringWithFormat:@"%d|:||%@|__SYN__:", [[HONUserAssistant sharedInstance] activeUserID], [PNMessage formattedCoordsForDeviceLocation]] toChannel:channel
//		 storeInHistory:NO withCompletionBlock:^(PNMessageState messageState, id data) {
//		NSLog(@"\nSEND MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
//	}];			@"%d|%@|%@:%@";
//	return [self sendMessage:message toChannel:channel storeInHistory:YES withCompletionBlock:success];
	
	NSString *contents = [NSString stringWithFormat:kHONChatMessageFormat, [[HONUserAssistant sharedInstance] activeUserID], [[HONUserAssistant sharedInstance] activeUsername], [PNMessage formattedCoordsForDeviceLocation], [PNMessage keyForMessageType:HONChatMessageTypeSYN], @""];
	
	return ([PubNub sendMessage:contents
					  toChannel:channel
					 compressed:YES
				 storeInHistory:NO
			withCompletionBlock:success]);
}


- (NSString *)contents {
	return ([[self.message lastComponentByDelimeter:@"|"] lastComponentByDelimeter:@":"]);
	//return (([self messageType] == HONChatMessageTypeTXT) ? [[self.message lastComponentByDelimeter:@"|"] lastComponentByDelimeter:@":"] : @"");
}

- (NSString *)coordsURI {
	return ([kHONChatMessageCoordsRoot stringByAppendingString:[[self.message componentsSeparatedByString:@"|"] objectAtIndex:1]]);
}

- (NSString *)imageURLPrefix {
	return ((self.messageType == HONChatMessageTypeIMG || self.messageType == HONChatMessageTypeVID) ? [NSString stringWithFormat:@"%@/%@", [HONAPICaller s3BucketForType:HONAmazonS3BucketTypeClubsCloudFront], [[self.message lastComponentByDelimeter:@"|"] lastComponentByDelimeter:@":"]] : @"");
}

- (CLLocation *)location {
	NSString *coords = [[self.message componentsSeparatedByString:@"|"] objectAtIndex:1];
	return ([[CLLocation alloc] initWithLatitude:[[coords firstComponentByDelimeter:@"_"] doubleValue] longitude:[[coords lastComponentByDelimeter:@"_"] doubleValue]]);
}

- (HONChatMessageType)messageType {
	// @"193020:|gullinbursti|37.3860_-122.0838|__IMG__:1426830141_ca4e199457f255a04ef17d674791d803"
	
	__block HONChatMessageType msgType = HONChatMessageTypeUndetermined;
	__block NSString *typeFlag = [[self.message lastComponentByDelimeter:@"|"] firstComponentByDelimeter:@":"];
	
	//NSLog(@"MSG FLG:[%@]", typeFlag);
	
	if ([typeFlag length] == 0)
		return (HONChatMessageTypeUndefined);
	
	[[self _messageTypeKeyNamePairs] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		//NSLog(@"flag[%@] = %@", (NSString *)key, obj);
		if ([typeFlag isEqualToString:(NSString *)key]) {
			msgType = (HONChatMessageType)[(NSNumber *)obj intValue];
			*stop = YES;
		}
	}];
	NSLog(@"msgType:[%d]", (int)msgType);
	return ((msgType == HONChatMessageTypeUndetermined) ? HONChatMessageTypeUnknown : msgType);
}


- (int)originUserID {
	return ([[[self.message firstComponentByDelimeter:@"|"] firstComponentByDelimeter:@";"] intValue]);
}

- (NSString *)originUsername {
	return ([[self.message firstComponentByDelimeter:@"|"] lastComponentByDelimeter:@";"]);
	
	NSString *username = [NSString stringWithFormat:@"anon%d", (rand() % 10) + 1];
	return ((self.originUserID == [[HONUserAssistant sharedInstance] activeUserID]) ? @"You" : (self.messageType == HONChatMessageTypeBOT || self.messageType == HONChatMessageTypeAUT) ? [[self.message firstComponentByDelimeter:@"|"] lastComponentByDelimeter:@";"] : username);
}


- (NSDictionary *)_messageTypeKeyNamePairs {
	return (@{kHONChatMessageTypeUndeterminedKey	: @(HONChatMessageTypeUndetermined),
			  kHONChatMessageTypeUndefinedKey		: @(HONChatMessageTypeUndefined),
			  kHONChatMessageTypeSyncronizeKey		: @(HONChatMessageTypeSYN),
			  kHONChatMessageTypeAcknowledgeKey		: @(HONChatMessageTypeACK),
			  kHONChatMessageTypeAutomatedKey		: @(HONChatMessageTypeAUT),
			  kHONChatMessageTypeBotKey				: @(HONChatMessageTypeBOT),
			  kHONChatMessageTypeTXTKey				: @(HONChatMessageTypeTXT),
			  kHONChatMessageTypeIMGKey				: @(HONChatMessageTypeIMG),
			  kHONChatMessageTypeVIDKey				: @(HONChatMessageTypeVID),
			  kHONChatMessageTypeLeaveKey			: @(HONChatMessageTypeBYE),
			  kHONChatMessageTypeCompleteKey		: @(HONChatMessageTypeFIN),
			  kHONChatMessageTypeErrorKey			: @(HONChatMessageTypeERR),
			  kHONChatMessageTypeNegativeKey		: @(HONChatMessageTypeNAE),
			  kHONChatMessageTypeAffirmativeKey		: @(HONChatMessageTypeYAH),
			  kHONChatMessageTypeQueryKey			: @(HONChatMessageTypeQRY),
			  kHONChatMessageTypeAnswerKey			: @(HONChatMessageTypeANS),
			  kHONChatMessageTypeDeleteKey			: @(HONChatMessageTypeNIX),
			  kHONChatMessageTypeUnknownKey			: @(HONChatMessageTypeUnknown)});
}

@end
