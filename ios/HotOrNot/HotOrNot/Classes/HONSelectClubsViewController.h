//
//  HONSelectClubsViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 06/21/2014 @ 18:38 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "CKRefreshControl.h"
#import "MBProgressHUD.h"

#import "HONTableView.h"
#import "HONHeaderView.h"

@interface HONSelectClubsViewController : UIViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate> {
	NSMutableDictionary *_clubIDs;
	NSMutableArray *_dictClubs;
	NSMutableArray *_allClubs;
	NSMutableArray *_segmentedKeys;
	NSDictionary *_segmentedClubs;
	
	NSMutableArray *_selectedClubs;
	NSMutableArray *_viewCells;
	
	HONTableView *_tableView;
	UIRefreshControl *_refreshControl;
	HONHeaderView *_headerView;
	MBProgressHUD *_progressHUD;
}

- (void)_retrieveClubs;
- (void)_goDataRefresh:(CKRefreshControl *)sender;
- (void)_didFinishDataRefresh;

- (void)_goRefresh;
- (void)_goSubmit;
- (void)_goSelectAllToggle;

- (NSDictionary *)_populateSegmentedDictionary;

@end
