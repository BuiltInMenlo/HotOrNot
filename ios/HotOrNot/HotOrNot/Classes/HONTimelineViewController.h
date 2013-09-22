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
	HONTimelineTypeSubject		= 8,	/** Challenges using same hashtag */
	HONTimelineTypeSingleUser	= 9,	/** Challenges of a single user */
	HONTimelineTypeFriends		= 10,	/** Challenges involving all friends */
} HONTimelineType;


@interface HONTimelineViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

- (id)initWithFriends;
- (id)initWithSubject:(NSString *)subjectName;
- (id)initWithUsername:(NSString *)username;
- (id)initWithUserID:(int)userID;
@end
