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


@interface HONTimelineViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (id)initWithSubjectID:(int)subjectID;
- (id)initWithSubjectName:(NSString *)subjectName;
- (id)initWithChallenge:(HONChallengeVO *)vo;
- (id)initWithUsername:(NSString *)username;
- (id)initWithUserID:(int)userID challengerID:(int)challengerID;
@end
