//
//  HONUserClubsViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 02/27/2014 @ 10:31 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONViewController.h"

//typedef NS_OPTIONS(NSInteger, HONUserClubsDataSetType) {
//	HONUserClubsDataSetTypeNone				= 0 << 0,
//	HONUserClubsDataSetTypeUserClubs		= 1 << 0,
//	HONUserClubsDataSetTypeSearchResults	= 1 << 1
//};

typedef NS_ENUM(NSUInteger, HONUserClubsViewControllerAppearedType) {
	HONUserClubsViewControllerAppearedTypeClear	= 0,
	HONUserClubsViewControllerAppearedTypeCreateClubCanceled,
	HONUserClubsViewControllerAppearedTypeSelfieCameraCanceled,
	HONUserClubsViewControllerAppearedTypeSelfieCameraCompleted,
	HONUserClubsViewControllerAppearedTypeCreateClubCompleted,
	HONUserClubsViewControllerAppearedTypeInviteFriends
};

typedef NS_ENUM(NSUInteger, HONUserClubsActionSheetType) {
	HONUserClubsActionSheetTypeSuggested = 0,
	HONUserClubsActionSheetTypeOwner,
	HONUserClubsActionSheetTypeMember,
	HONUserClubsActionSheetTypePending
};

typedef NS_ENUM(NSUInteger, HONUserClubsAlertType) {
	HONUserClubsAlertTypeCreateNew = 0,
	HONUserClubsAlertTypeGenerateSuggested,
	HONUserClubsAlertTypeJoin,
	HONUserClubsAlertTypeLeave,
	HONUserClubsAlertTypeSubmitPhoto,
	HONUserClubsAlertTypeInviteContacts
};

@interface HONUserClubsViewController : HONViewController <UIActionSheetDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>
@end
