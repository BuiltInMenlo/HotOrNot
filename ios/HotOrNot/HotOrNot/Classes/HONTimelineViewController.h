//
//  HONTimelineViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HONChallengeVO.h"


//typedef enum {
//	HONTimelineTypeSubject		= 8,	/** Challenges using same hashtag */
//	HONTimelineTypeSingleUser	= 9,	/** Challenges of a single user */
//	HONTimelineTypeHome			= 10,	/** Challenges involving user & following */
//} HONTimelineType;


@interface HONTimelineViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
//- (id)initWithSubject:(NSString *)subjectName;
//- (id)initWithUsername:(NSString *)username;
@end
