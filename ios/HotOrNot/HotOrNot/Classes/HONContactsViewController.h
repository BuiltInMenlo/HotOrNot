//
//  HONContactsViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 18:21 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

typedef enum {
	HONContactsTableViewDataSourceNone = 0,
	HONContactsTableViewDataSourceAddressBook,
	HONContactsTableViewDataSourceSearchResults
} HONContactsTableViewDataSource;


@interface HONContactsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@end
