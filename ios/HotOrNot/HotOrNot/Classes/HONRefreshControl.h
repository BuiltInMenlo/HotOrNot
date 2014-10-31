//
//  HONRefreshControl.h
//  HotOrNot
//
//  Created by Matt Holcombe on 06/16/2014 @ 22:08 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "CKRefreshControl.h"

@interface HONRefreshControl : CKRefreshControl
@end

@class UIRefreshControl;
@interface UITableViewController (HONRefreshControlAdditions)
// This will be added to the class at runtime if not already available
@property (nonatomic,retain) UIRefreshControl *refreshControl;
@end


//@class UIRefreshControl;
//@interface UITableViewController (CKRefreshControlAdditions)
//@property (nonatomic, retain) UIRefreshControl *refreshControl;
//@end