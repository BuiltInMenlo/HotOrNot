//
//  HONUserProfileViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 9/7/13 @ 9:46 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONViewController.h"

typedef NS_ENUM(NSUInteger, HONUserProfileType) {
	HONUserProfileTypeUser,
	HONUserProfileTypeOpponent
};

typedef NS_ENUM(NSUInteger, HONUserProfileActionSheetType) {
	HONUserProfileActionSheetTypeVerify,
	HONUserProfileActionSheetTypeSocial
};


typedef NS_ENUM(NSUInteger, HONUserProfileAlertType) {
	HONUserProfileAlertTypeInvite,
	HONUserProfileAlertTypeDeleteChallenge,
	HONUserProfileAlertTypeFollow,
	HONUserProfileAlertTypeFollowClose,
	HONUserProfileAlertTypeUnfollow,
	HONUserProfileAlertTypeFlag,
	HONUserProfileAlertTypeShowProfileBlocked
};


@interface HONUserProfileViewController : HONViewController <UITableViewDataSource, UITableViewDelegate>
- (id)initWithUserID:(int)userID;

@property (nonatomic) int userID;
@end
