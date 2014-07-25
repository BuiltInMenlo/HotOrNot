//
//  HONHighSchoolSearchViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 07/22/2014 @ 19:05 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "CKRefreshControl.h"
#import "MBProgressHUD.h"

#import "HONHighSchoolSearchViewController.h"
#import "HONTableView.h"
#import "HONHeaderView.h"
#import "HONSearchBarView.h"


@interface HONHighSchoolSearchViewController () <HONSearchBarViewDelegate>
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *highSchoolClubs;
@end


@implementation HONHighSchoolSearchViewController

- (id)init {
	if ((self = [super init])) {
		
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}

- (BOOL)shouldAutorotate {
	return (NO);
}


#pragma mark - Data Calls


#pragma mark - Data Handling
- (void)_goDataRefresh:(CKRefreshControl *)sender {
}

- (void)_didFinishDataRefresh {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	[_tableView reloadData];
	[_refreshControl endRefreshing];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_highSchoolClubs = [NSMutableArray array];
	
	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, (kNavHeaderHeight + kSearchHeaderHeight), 320.0, self.view.frame.size.height - (kNavHeaderHeight + kSearchHeaderHeight)) style:UITableViewStylePlain];
	[_tableView setContentInset:kOrthodoxTableViewEdgeInsets];
	_tableView.sectionIndexColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	_tableView.sectionIndexBackgroundColor = [UIColor clearColor];
	_tableView.sectionIndexTrackingBackgroundColor = [UIColor colorWithWhite:0.40 alpha:0.33];
	_tableView.sectionIndexMinimumDisplayRowCount = 1;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
	
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
	
	HONSearchBarView *searchBarView = [[HONSearchBarView alloc] initAsHighSchoolWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, kSearchHeaderHeight)];
	searchBarView.delegate = self;
	[self.view addSubview:searchBarView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Find High School"];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 1.0, 93.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:backButton];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, [@"" stringFromBool:animated]);
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBool:animated]);
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillDisappear:%@] [:|:]", self.class, [@"" stringFromBool:animated]);
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidDisappear:%@] [:|:]", self.class, [@"" stringFromBool:animated]);
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload {
	ViewControllerLog(@"[:|:] [%@ viewDidUnload] [:|:]", self.class);
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - SearchBarHeader Delegates
- (void)searchBarViewHasFocus:(HONSearchBarView *)searchBarView {
}

- (void)searchBarViewCancel:(HONSearchBarView *)searchBarView {
}

- (void)searchBarView:(HONSearchBarView *)searchBarView enteredSearch:(NSString *)searchQuery {
}


#pragma mark - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (0);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[UITableViewCell alloc] init];
	
	return (cell);
}



@end
