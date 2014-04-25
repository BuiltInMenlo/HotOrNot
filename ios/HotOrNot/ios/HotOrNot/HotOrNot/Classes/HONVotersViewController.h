//
//  HONVotersViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.15.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengeVO.h"

@interface HONVotersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
- (id)initWithChallenge:(HONChallengeVO *)vo;
@end
