//
//  HONClubInviteContactsViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/01/2014 @ 14:05 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONContactsViewController.h"

typedef NS_ENUM(NSInteger, HONClubInviteContactType) {
	HONClubInviteContactTypeNone		= 0,
	HONClubInviteContactTypeInApp		= 1 << 0,
	HONClubInviteContactTypeNonApp		= 1 << 1,
	
};

@interface HONClubInviteContactsViewController : HONContactsViewController
- (id)initWithClub:(HONUserClubVO *)userClub viewControllerPushed:(BOOL)isPushed;
@end
