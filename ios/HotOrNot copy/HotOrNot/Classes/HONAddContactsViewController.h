//
//  HONAddContactsViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 6/27/13 @ 12:52 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HONAddContactsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
- (id)initAsFirstRun:(BOOL)isFirstRun;
@end
