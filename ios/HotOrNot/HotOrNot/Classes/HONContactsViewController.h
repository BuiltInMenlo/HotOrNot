//
//  HONContactsViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 18:21 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

typedef NS_ENUM(NSInteger, HONContactsTableViewDataSource) {
	HONContactsTableViewDataSourceAddressBook,
	HONContactsTableViewDataSourceSearchResults
};

@interface HONContactsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@end
