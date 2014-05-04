//
//  HONUserClubsViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 02/27/2014 @ 10:31 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

@interface HONUserClubsViewController : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
- (id)initWithWrapperViewController:(UIViewController *)wrapperViewController;

- (void)refresh;
- (void)tare;
@end
