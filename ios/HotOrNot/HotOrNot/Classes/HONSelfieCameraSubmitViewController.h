//
//  HONCameraSubmitViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 07:11 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONSelectClubsViewController.h"

#import "HONChallengeVO.h"
#import "HONProtoChallengeVO.h"
#import "HONUserClubVO.h"

@class HONSelfieCameraViewController;
@interface HONSelfieCameraSubmitViewController : HONSelectClubsViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
- (id)initWithClub:(HONUserClubVO *)clubVO;
@end
