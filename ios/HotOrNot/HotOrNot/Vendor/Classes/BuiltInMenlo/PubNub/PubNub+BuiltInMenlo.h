//
//  PubNub+BuiltInMenlo.h
//  HotOrNot
//
//  Created by BIM  on 3/18/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import <PubNub/PubNub.h>


typedef NS_ENUM(NSUInteger, HONChatMessageType) {
	HONChatMessageTypeUndetermined = 0,
	HONChatMessageTypeUndefined,
	HONChatMessageTypeSYN,
	HONChatMessageTypeACK,
	HONChatMessageTypeAUT,
	HONChatMessageTypeBOT,
	HONChatMessageTypeTXT,
	HONChatMessageTypeIMG,
	HONChatMessageTypeVID,
	HONChatMessageTypeBYE,
	HONChatMessageTypeFIN,
	HONChatMessageTypeERR,
	HONChatMessageTypeNAE,
	HONChatMessageTypeYAH,
	HONChatMessageTypeQRY,
	HONChatMessageTypeANS,
	HONChatMessageTypeNIX,
	HONChatMessageTypeUnknown
};


extern NSString * const kHONChatMessageTypeKey;
extern NSString * const kHONChatMessageTypeUndeterminedKey;
extern NSString * const kHONChatMessageTypeUndefinedKey;
extern NSString * const kHONHONChatMessageTypeSyncronizeKey;
extern NSString * const kHONChatMessageTypeAcknowledgeKey;
extern NSString * const kHONChatMessageTypeAutomatedKey;
extern NSString * const kHONChatMessageTypeBotKey;
extern NSString * const kHONHONChatMessageTypeTXTKey;
extern NSString * const kHONHONChatMessageTypeIMGKey;
extern NSString * const kHONHONChatMessageTypeVIDKey;
extern NSString * const kHONChatMessageTypeLeaveKey;
extern NSString * const kHONChatMessageTypeCompleteKey;
extern NSString * const kHONChatMessageTypeErrorKey;
extern NSString * const kHONChatMessageTypeNegativeKey;
extern NSString * const kHONChatMessageTypeAffirmativeKey;
extern NSString * const kHONChatMessageTypeQueryKey;
extern NSString * const kHONChatMessageTypeAnswerKey;
extern NSString * const kHONChatMessageTypeDeleteKey;
extern NSString * const kHONChatMessageTypeUnknownKey;

extern NSString * const kHONChatMessageCoordsRoot;
extern NSString * const kHONChatMessageImageRoot;


@interface PubNub (BuiltInMenlo)
@end
