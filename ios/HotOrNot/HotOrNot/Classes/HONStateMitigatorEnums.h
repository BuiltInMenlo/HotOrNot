//
//  HONStateMitigatorEnums.h
//  HotOrNot
//
//  Created by BIM  on 10/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

//#ifndef HotOrNot_HONStateMitigatorEnums_h
//#define HotOrNot_HONStateMitigatorEnums_h
//#endif


typedef NS_ENUM(NSUInteger, HONStateMitigatorAppEntryType) {
	HONStateMitigatorAppEntryTypeUnknown = 0,
	HONStateMitigatorAppEntryTypeNotAvailable,
	HONStateMitigatorAppEntryTypeBoot,
	HONStateMitigatorAppEntryTypeSpringboard,
	HONStateMitigatorAppEntryTypeDeepLink,
	HONStateMitigatorAppEntryTypeRemoteNotification,
	HONStateMitigatorAppEntryTypeLocalNotification
};

typedef NS_ENUM(NSUInteger, HONStateMitigatorViewStateType) {
	HONStateMitigatorViewStateTypeUnknown = 0,
	HONStateMitigatorViewStateTypeNotAvailable,
	HONStateMitigatorViewStateTypeRegistration,
	HONStateMitigatorViewStateTypeRegistrationCountryCodes,
	HONStateMitigatorViewStateTypePINEntry,
	HONStateMitigatorViewStateTypeFriends,
	HONStateMitigatorViewStateTypeSettings,
	HONStateMitigatorViewStateTypeTimeline,
	HONStateMitigatorViewStateTypeCompose,
	HONStateMitigatorViewStateTypeAnimatedBGs,
	HONStateMitigatorViewStateTypeStickerStore,
	HONStateMitigatorViewStateTypeComposeSubmit,
	HONStateMitigatorViewStateTypeSearchUsername,
	HONStateMitigatorViewStateTypeSearchContact,
	HONStateMitigatorViewStateTypeSearchContactCountryCodes,
	HONStateMitigatorViewStateTypeSupport,
	HONStateMitigatorViewStateTypeLegal,
	HONStateMitigatorViewStateTypeNetworkStatus
};

typedef NS_ENUM(NSUInteger, HONStateMitigatorTotalType) {
	HONStateMitigatorTotalTypeUnknown = 0,
	HONStateMitigatorTotalTypeTrackingCalls,
	HONStateMitigatorTotalTypeBoot,
	HONStateMitigatorTotalTypeExit,
	HONStateMitigatorTotalTypeResume,
	HONStateMitigatorTotalTypeBackground,
	HONStateMitigatorTotalTypeRegistration,
	HONStateMitigatorTotalTypeRegistrationCountryCodes,
	HONStateMitigatorTotalTypePINEntry,
	HONStateMitigatorTotalTypeFriendsTab,
	HONStateMitigatorTotalTypeFriendsTabRefresh,
	HONStateMitigatorTotalTypeSettingsTab,
	HONStateMitigatorTotalTypeTimeline,
	HONStateMitigatorTotalTypeTimelineRefresh,
	HONStateMitigatorTotalTypeReply,
	HONStateMitigatorTotalTypeCompose,
	HONStateMitigatorTotalTypeAnimatedBGs,
	HONStateMitigatorTotalTypeAnimatedBGsRefresh,
	HONStateMitigatorTotalTypeStickerStore,
	HONStateMitigatorTotalTypeStickerStoreRefresh,
	HONStateMitigatorTotalTypeComposeSubmit,
	HONStateMitigatorTotalTypeComposeSubmitRefresh,
	HONStateMitigatorTotalTypeSearchUsername,
	HONStateMitigatorTotalTypeSearchContacts,
	HONStateMitigatorTotalTypeSearchContactsCountryCodes,
	HONStateMitigatorTotalTypeSupport,
	HONStateMitigatorTotalTypeLegal,
	HONStateMitigatorTotalTypeNetworkStatus,
	HONStateMitigatorTotalTypeNetworkStatusRefresh,
	HONStateMitigatorTotalTypeShare
};


@interface HONStateMitigatorEnums : NSObject
@end