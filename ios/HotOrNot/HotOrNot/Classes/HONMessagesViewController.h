//
//  HONMessagesViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 01/18/2014 @ 14:09.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	HONMessageRowTypeFindFriends = 0,
	HONMessageRowTypeFindClubs,
	HONMessageRowTypeMatchPhone
} HONMessageRowType;

@interface HONMessagesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@end
