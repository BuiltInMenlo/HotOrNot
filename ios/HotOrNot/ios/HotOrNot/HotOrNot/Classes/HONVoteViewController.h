//
//  HONVoteViewController
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HONChallengeVO.h"

@interface HONVoteViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (id)initWithSubjectID:(int)subjectID;
- (id)initWithSubjectName:(NSString *)subjectName;
- (id)initWithChallenge:(HONChallengeVO *)vo;
- (id)initWithUsername:(NSString *)username;
@end