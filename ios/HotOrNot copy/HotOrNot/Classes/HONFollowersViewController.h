//
//  HONFollowersViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 10/4/13 @ 3:06 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HONFollowersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
- (id)initWithUserID:(int)userID;
@end
