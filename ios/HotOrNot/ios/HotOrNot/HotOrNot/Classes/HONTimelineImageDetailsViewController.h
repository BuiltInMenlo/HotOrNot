//
//  HONTimelineImageDetailsViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 01.11.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HONChallengeVO.h"

@interface HONTimelineImageDetailsViewController : UIViewController

- (id)initAsNotInSession:(HONChallengeVO *)vo;
- (id)initAsInSessionCreator:(HONChallengeVO *)vo;
- (id)initAsInSessionChallenger:(HONChallengeVO *)vo;

@end
