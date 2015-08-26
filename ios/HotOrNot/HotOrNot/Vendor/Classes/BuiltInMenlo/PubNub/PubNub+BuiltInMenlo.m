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


NSString * const kHONChatMessageFormat			= @"%@;%@|%@|%@:%@";
NSString * const kHONChatMessageCoordsFormat	= @"%.04f_%.04f";


@interface PubNub (BuiltinMeno)
@end

@implementation PubNub (BuiltInMenlo)
@end
