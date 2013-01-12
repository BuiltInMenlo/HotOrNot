//
//  HONVoteDetailsViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.11.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HONChallengeVO.h"

@interface HONVoteDetailsViewController : UIViewController

- (id)initAsNotInSession:(HONChallengeVO *)vo;
- (id)initAsInSessionCreator:(HONChallengeVO *)vo;
- (id)initAsInSessionChallenger:(HONChallengeVO *)vo;

/*
// in session
- (id)initAsCreatorInSession:(HONChallengeVO *)vo;
- (id)initAsChallengerInSession:(HONChallengeVO *)vo;

// not in session as your own
- (id)initAsOwnerCreated:(HONChallengeVO *)vo;
- (id)initAsOwnerWaiting:(HONChallengeVO *)vo;

// not in session as not your own
- (id)initAsNotOwnerCreated:(HONChallengeVO *)vo;
- (id)initAsNotOwnerWaiting:(HONChallengeVO *)vo;
*/

@end
