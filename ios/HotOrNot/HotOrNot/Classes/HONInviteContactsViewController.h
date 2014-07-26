//
//  HONInviteContactsViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/01/2014 @ 14:05 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONContactsViewController.h"

typedef NS_ENUM(NSInteger, HONInviteContactType) {
	HONInviteContactTypeNone		= 0,
	HONInviteContactTypeInApp		= 1 << 0,
	HONInviteContactTypeNonApp		= 1 << 1
};

@interface HONInviteContactsViewController : HONContactsViewController
- (id)initWithClub:(HONUserClubVO *)userClub viewControllerPushed:(BOOL)isPushed;
@end
