//
//  HONUserProfileViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 9/7/13 @ 9:46 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONViewController.h"
#import "HONUserVO.h"

typedef NS_ENUM(NSUInteger, HONActivityProfileType) {
	HONActivityProfileTypeUser,
	HONActivityProfileTypeOpponent
};

typedef NS_ENUM(NSUInteger, HONActiityActionSheetType) {
	HONActiityActionSheetTypeVerify,
	HONActiityActionSheetTypeSocial
};


typedef NS_ENUM(NSUInteger, HONActivityAlertType) {
	HONActivityAlertTypeInvite,
	HONActivityAlertTypeDeleteChallenge,
	HONActivityAlertTypeFollow,
	HONActivityAlertTypeFollowClose,
	HONActivityAlertTypeUnfollow,
	HONActivityAlertTypeFlag,
	HONActivityAlertTypeShowProfileBlocked
};


@interface HONActivityViewController : HONViewController <UITableViewDataSource, UITableViewDelegate>
- (id)initWithTrivialUser:(HONUserVO *)trivialUserVO;
@end
