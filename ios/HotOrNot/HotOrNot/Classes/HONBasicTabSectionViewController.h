//
//  HONBasicTabSectionViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/27/2014 @ 06:32 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"

#import "HONTutorialView.h"


@class HONBasicTabSectionViewController;
@interface HONBasicTabSectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	HONTutorialView *_tutorialView;
	
	UITableView *_tableView;
	NSMutableArray *_dataItems;
	NSMutableArray *_headers;
	NSMutableArray *_cells;
	UIImageView *_emptySetImageView;
	NSString *_tabNameIdentifier;
	NSArray *_totalsKeyNames;
	BOOL _isScrollingIgnored;
	
	EGORefreshTableHeaderView *_refreshTableHeaderView;
	MBProgressHUD *_progressHUD;
}

- (void)retreiveDataSet;
- (void)selectedTab;
- (void)reloadDataSet;
- (void)tareTableView;

@property (nonatomic, strong) HONTutorialView *tutorialView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataItems;
@property (nonatomic, strong) NSMutableArray *headers;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) UIImageView *emptySetImageView;
@property (nonatomic, strong) NSString *tabNameIdentifier;
@property (nonatomic, strong) NSArray *totalsKeyNames;
@property (nonatomic) BOOL isScrollingIgnored;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end
