//
//  HONTableViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/16/2014 @ 21:19 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONTableViewController.h"
#import "HONTableHeaderView.h"


@interface HONTableViewController ()
@end

@implementation HONTableViewController
@synthesize tableView = _tableView;

- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
}

- (BOOL)shouldAutorotate {
	return (NO);
}


#pragma mark - Data Calls



#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
	[self.refreshControl performSelector:@selector(_didFinishDataRefresh) withObject:nil afterDelay:0.33];
}

- (void)_didFinishDataRefresh {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	[_tableView reloadData];
	[self.refreshControl endRefreshing];
}




#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@""];
	[self.view addSubview:_headerView];
	
	self.tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - kNavHeaderHeight) style:UITableViewStylePlain];
	[self.tableView setBackgroundColor:[UIColor whiteColor]];
	[self.tableView setContentInset:kOrthodoxTableViewEdgeInsets];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.scrollsToTop = YES;
	self.tableView.showsVerticalScrollIndicator = YES;
	self.tableView.alwaysBounceVertical = YES;
	[self.view addSubview:self.tableView];
	
	_refreshControl = [[HONRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	self.refreshControl = (UIRefreshControl *)_refreshControl;
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



#pragma mark - TableView DataSource Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (0);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONTableViewCell alloc] init];
	
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (0.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (kOrthodoxTableHeaderHeight);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

@end
