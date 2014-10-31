//
//  HONSelectClubsViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 06/21/2014 @ 18:38 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONRefreshControl.h"
#import "MBProgressHUD.h"

#import "HONViewController.h"
#import "HONTableView.h"
#import "HONHeaderView.h"
#import "HONClubToggleViewCell.h"

@interface HONSelectClubsViewController : HONViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate> {
	NSMutableDictionary *_clubIDs;
	NSMutableArray *_dictClubs;
	NSMutableArray *_allClubs;
	NSMutableArray *_segmentedKeys;
	NSDictionary *_segmentedClubs;
	
	NSMutableArray *_selectedClubs;
	NSMutableArray *_viewCells;
	int _clubID;
	
	HONTableView *_tableView;
	UIRefreshControl *_refreshControl;
	HONHeaderView *_headerView;
	MBProgressHUD *_progressHUD;
}

- (void)_retrieveClubs;
- (void)_goDataRefresh:(HONRefreshControl *)sender;
- (void)_didFinishDataRefresh;

- (void)_goRefresh;
- (void)_goSubmit;
- (void)_goSelectAllToggle;

- (void)clubToggleViewCell:(HONClubToggleViewCell *)viewCell deselectedClub:(HONUserClubVO *)userClubVO;
- (void)clubToggleViewCell:(HONClubToggleViewCell *)viewCell selectedClub:(HONUserClubVO *)userClubVO;
- (void)clubToggleViewCell:(HONClubToggleViewCell *)viewCell selectAllToggled:(BOOL)isSelected;

- (NSDictionary *)_populateSegmentedDictionary;

@end
