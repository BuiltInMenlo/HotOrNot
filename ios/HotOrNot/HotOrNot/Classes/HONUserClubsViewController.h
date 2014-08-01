//
//  HONUserClubsViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 02/27/2014 @ 10:31 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONViewController.h"

typedef NS_ENUM(NSInteger, HONUserClubsViewControllerAppearedType) {
	HONUserClubsViewControllerAppearedTypeClear	= 0,
	HONUserClubsViewControllerAppearedTypeCreateClubCanceled,
	HONUserClubsViewControllerAppearedTypeSelfieCameraCanceled,
	HONUserClubsViewControllerAppearedTypeSelfieCameraCompleted,
	HONUserClubsViewControllerAppearedTypeCreateClubCompleted
};

typedef NS_ENUM(NSInteger, HONUserClubsActionSheetType) {
	HONUserClubsActionSheetTypeSuggested = 0,
	HONUserClubsActionSheetTypeOwner,
	HONUserClubsActionSheetTypeMember,
	HONUserClubsActionSheetTypePending
};

typedef NS_ENUM(NSInteger, HONUserClubsAlertType) {
	HONUserClubsAlertTypeCreateNew = 0,
	HONUserClubsAlertTypeGenerateSuggested,
	HONUserClubsAlertTypeJoin,
	HONUserClubsAlertTypeLeave,
	HONUserClubsAlertTypeSubmitPhoto,
	HONUserClubsAlertTypeInviteContacts
};

@interface HONUserClubsViewController : HONViewController <UIActionSheetDelegate, UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>
@end
