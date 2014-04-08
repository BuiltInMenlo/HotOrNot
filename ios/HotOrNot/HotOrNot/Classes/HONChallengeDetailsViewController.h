//
//  HONChallengeDetailsViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/7/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengeVO.h"

@interface HONChallengeDetailsViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate>
- (id)initWithChallenge:(HONChallengeVO *)vo;
- (id)initWithChallengeID:(int)challengeID;
@end
