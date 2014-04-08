//
//  HONCommentsViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 02.20.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengeVO.h"

@interface HONCommentsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
- (id)initWithChallenge:(HONChallengeVO *)vo;
@end
