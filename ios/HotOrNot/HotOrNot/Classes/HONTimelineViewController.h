//
//  HONTimelineViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HONChallengeVO.h"

typedef enum {
	HONTimelineAlertTypeInvite = 0,
	HONTimelineAlertTypeInviteConfirm	
} HONTimelineAlertType;


@interface HONTimelineViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@end
