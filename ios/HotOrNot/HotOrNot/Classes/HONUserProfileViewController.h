//
//  HONUserProfileViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 9/7/13 @ 9:46 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

typedef enum {
	HONUserProfileTypeUser	= 0,
	HONUserProfileTypeOpponent
} HONUserProfileType;

typedef enum {
	HONAlertItemTypeVerify = 1,
	HONAlertItemTypeFollow,
	HONAlertItemTypeLike,
	HONAlertItemTypeShoutout,
	HONAlertItemTypeReply
} HONAlertItemType;

typedef enum {
	HONUserProfileActionSheetTypeVerify = 0,
	HONUserProfileActionSheetTypeSocial
} HONUserProfileActionSheetType;


typedef enum {
	HONUserProfileAlertTypeInvite = 0,
	HONUserProfileAlertTypeDeleteChallenge,
	HONUserProfileAlertTypeFollow,
	HONUserProfileAlertTypeFollowClose,
	HONUserProfileAlertTypeUnfollow,
	HONUserProfileAlertTypeFlag,
	HONUserProfileAlertTypeShowProfileBlocked
} HONUserProfileAlertType;


@interface HONUserProfileViewController : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
- (id)initWithUserID:(int)userID;

@property (nonatomic) int userID;
@end
