//
//  HONUserClubInviteViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/01/2014 @ 14:05 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONUserClubVO.h"

typedef enum {
	HONUserClubInviteTypeNone = 0,
	HONUserClubInviteTypeInApp = 1 << 0,
	HONUserClubInviteTypeNonApp = 1 << 1,
	
} HONUserClubInviteType;

@interface HONUserClubInviteViewController : UIViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
- (id)initWithClub:(HONUserClubVO *)userClub;
@end
