//
//  HONUserProfileViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 9/7/13 @ 9:46 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	HONUserProfileTypeUser	= 0,
	HONUserProfileTypeOpponent
	
} HONUserProfileType;


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
@property (nonatomic) int userID;
@end
