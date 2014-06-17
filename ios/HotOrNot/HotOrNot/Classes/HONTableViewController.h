//
//  HONTableViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 06/16/2014 @ 21:19 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "MBProgressHUD.h"

#import "HONTableViewCell.h"
#import "HONHeaderView.h"
#import "HONTableView.h"
#import "HONRefreshControl.h"


@interface HONTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
	MBProgressHUD *_progressHUD;
	
	HONHeaderView *_headerView;
	HONRefreshControl *_refreshControl;
}

- (void)_goDataRefresh:(HONRefreshControl *)sender;
- (void)_didFinishDataRefresh;



@property (nonatomic, retain) HONTableView *tableView;
//@property (nonatomic, retain) HONRefreshControl *refreshControl;

@end
