//
//  HONInviteClubsViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 07:11 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONSelectClubsViewController.h"

#import "HONChallengeVO.h"
#import "HONProtoChallengeVO.h"
#import "HONContactUserVO.h"
#import "HONTrivialUserVO.h"

@class HONInviteClubsViewController;
@interface HONInviteClubsViewController : HONSelectClubsViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
- (id)initWithContactUser:(HONContactUserVO *)contactUserVO;
- (id)initWithTrivialUser:(HONTrivialUserVO *)trivialUserVO;
@end
