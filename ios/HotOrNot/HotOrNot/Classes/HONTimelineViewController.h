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
	HONTimelineTypePublic		= 4,	/** All public challenges */
	HONTimelineTypeFriends		= 10,	/** Challenges involving all friends */
	HONTimelineTypeSubject		= 8,	/** Challenges using same hashtag */
	HONTimelineTypeSingleUser	= 9,	/** Challenges of a single user */
	HONTimelineTypeOpponents	= 7,	/** Challenges between two users */
} HONTimelineType;


@interface HONTimelineViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (id)initWithPublic;
- (id)initWithFriends;
- (id)initWithSubject:(NSString *)subjectName;
- (id)initWithUsername:(NSString *)username;
- (id)initWithUserID:(int)userID;
- (id)initWithUserID:(int)userID andOpponentID:(int)opponentID asPublic:(BOOL)isPublic;
@end
