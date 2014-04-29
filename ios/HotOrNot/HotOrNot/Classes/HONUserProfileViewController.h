//
//  HONUserProfileViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 9/7/13 @ 9:46 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

typedef NS_ENUM(NSInteger, HONUserProfileType) {
	HONUserProfileTypeUser,
	HONUserProfileTypeOpponent
};

typedef NS_ENUM(NSInteger, HONAlertItemType) {
	HONAlertItemTypeVerify,
	HONAlertItemTypeFollow,
	HONAlertItemTypeLike,
	HONAlertItemTypeShoutout,
	HONAlertItemTypeReply
};

typedef NS_ENUM(NSInteger, HONUserProfileActionSheetType) {
	HONUserProfileActionSheetTypeVerify,
	HONUserProfileActionSheetTypeSocial
};


typedef NS_ENUM(NSInteger, HONUserProfileAlertType) {
	HONUserProfileAlertTypeInvite,
	HONUserProfileAlertTypeDeleteChallenge,
	HONUserProfileAlertTypeFollow,
	HONUserProfileAlertTypeFollowClose,
	HONUserProfileAlertTypeUnfollow,
	HONUserProfileAlertTypeFlag,
	HONUserProfileAlertTypeShowProfileBlocked
};

typedef NS_ENUM(NSInteger, HONActivityAlert) {
	HONActivityAlertTypeVerify,
	HONActivityAlertTypeFollow,
	HONActivityAlertTypeLike,
	HONActivityAlertTypeShoutout,
	HONActivityAlertTypeReply
};



@interface HONUserProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
- (id)initWithUserID:(int)userID;

@property (nonatomic) int userID;
@end
