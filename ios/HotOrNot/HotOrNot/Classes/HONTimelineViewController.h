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
	HONChallengeEngageTypeAnonymous,     /** Challenge is submitted for a match */
	HONChallengeEngageTypeSubject,       /** New challenge is created w/ a subject */
	HONChallengeEngageTypeUser,          /** New challenge is created against a user */
	HONChallengeEngageTypeCreator,       /** New challenge is created against a challenge's creator */
	HONChallengeEngageTypeChallenger,    /** New challenge is created against a challenge's opponent */
	HONChallengeEngageTypeJoin,          /** New challenges are created against a challenge's creator & opponent */
} HONChallengeEngageType;

typedef enum {
	HONTimelineSubmitTypePublic			= 4,	/** All public challenges */
	HONTimelineSubmitTypeFriends		= 10,	/** Challenges involving all friends */
	HONTimelineSubmitTypeSubject		= 8,	/** Challenges using same hashtag */
	HONTimelineSubmitTypeSingleUser		= 9,	/** Challenges of a single user */
	HONTimelineSubmitTypeOpponents		= 7,	/** Challenges between two users */
} HONTimelineSubmitType;


@interface HONTimelineViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (id)initWithPublic;
- (id)initWithSubject:(NSString *)subjectName;
- (id)initWithUsername:(NSString *)username;
- (id)initWithUserID:(int)userID andOpponentID:(int)opponentID;
@end
