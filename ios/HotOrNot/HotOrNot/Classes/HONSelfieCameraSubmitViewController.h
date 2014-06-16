//
//  HONCameraSubmitViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 07:11 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengeVO.h"
#import "HONProtoChallengeVO.h"
#import "HONUserClubVO.h"

@class HONSelfieCameraViewController;
@interface HONSelfieCameraSubmitViewController : UIViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
- (id)initWithClub:(HONUserClubVO *)clubVO;
@end
