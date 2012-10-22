//
//  HONResultsViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.21.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	HONChallengesWinning = 0,
	HONChallengesLosing,
	HONChallengesTie,
} HONChallengeResultsState;

@interface HONResultsViewController : UIViewController {
	HONChallengeResultsState _state;
}

- (id)initWithChallenges:(NSArray *)challengeList;

@end
