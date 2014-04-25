//
//  HONBaseTabSectionViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/27/2014 @ 06:32 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "NSString+DataTypes.h"

#import "HONBaseTabSectionViewController.h"

#import "HONHeaderView.h"
#import "HONCreateSnapButtonView.h"
#import "HONMessagesButtonView.h"
#import "HONProfileHeaderButtonView.h"

#import "HONChangeAvatarViewController.h"
#import "HONImagePickerViewController.h"
#import "HONMessagesViewController.h"
#import "HONUserProfileViewController.h"


@interface HONBaseTabSectionViewController () <EGORefreshTableHeaderDelegate, HONTutorialViewDelegate>
@end


@implementation HONBaseTabSectionViewController
@synthesize tutorialView = _tutorialView;
@synthesize tableView = _tableView, dataItems = _dataItems, headers = _headers, cells = _cells, emptySetImageView = _emptySetImageView, tabNameIdentifier = _tabNameIdentifier, totalsKeyNames = _totalsKeyNames;
@synthesize isScrollingIgnored = _isScrollingIgnored;
@synthesize refreshTableHeaderView = _refreshTableHeaderView, progressHUD = _progressHUD;

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshAllTabs:) name:@"REFRESH_ALL_TABS" object:nil];
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
- (void)retreiveDataSet {
	
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Friends"];
	[self.view addSubview:headerView];
	
	[headerView addButton:[[HONProfileHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)]];
//	[headerView addButton:[[HONMessagesButtonView alloc] initWithTarget:self action:@selector(_goMessages)]];
	[headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goSelfieCamera) asLightStyle:NO]];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 76.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 76.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillDisappear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidDisappear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload {
	ViewControllerLog(@"[:|:] [%@ viewDidUnload] [:|:]", self.class);
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goRefresh {
	
}

- (void)_goProfile {
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]] animated:YES];
}

- (void)_goMessages {
	[self.navigationController pushViewController:[[HONMessagesViewController alloc] init] animated:YES];
}

- (void)_goSelfieCamera {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initAsNewChallenge]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}


#pragma mark - Notifications
- (void)_refreshAllTabs:(NSNotification *)notification {
	NSLog(@"::|> [%@ _refreshAllTabs] <|::", self.class);
	
	[self retreiveDataSet];
}


#pragma mark - UI Presentation
- (void)selectedTab {
	if ([HONAppDelegate incTotalForCounter:[_totalsKeyNames objectAtIndex:0]] == 0) {
		_tutorialView = [[HONTutorialView alloc] initWithBGImage:[UIImage imageNamed:[@"tutorial_" stringByAppendingString:[_tabNameIdentifier lowercaseString]]]];
		_tutorialView.delegate = self;

		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_tutorialView];
		[_tutorialView introWithCompletion:nil];
	}
}

- (void)reloadDataSet {
	[self retreiveDataSet];
}

- (void)tareTableView {
	if (_tableView.contentOffset.y > 0) {
		_tableView.pagingEnabled = NO;
		[_tableView setContentOffset:CGPointZero animated:YES];
	}
	
//	[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//	[_tableView setContentOffset:CGPointMake(0.0, [UIScreen mainScreen].bounds.size.height) animated:NO];
}


#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	_tableView.pagingEnabled = NO;
	[self _goRefresh];
}

- (void)egoRefreshTableHeaderDidFinishTareAnimation:(EGORefreshTableHeaderView *)view {
	_tableView.pagingEnabled = YES;
}


#pragma mark - TutorialView Delegates
- (void)tutorialViewClose:(HONTutorialView *)tutorialView {
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
	}];
}

- (void)tutorialViewTakeAvatar:(HONTutorialView *)tutorialView {
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:nil];
	}];
}


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	NSLog(@"**_[scrollViewDidScroll(%d)]_**", !_isScrollingIgnored);
	
	if (!_isScrollingIgnored)
		[_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//	NSLog(@"**_[scrollViewDidEndDragging]_**");
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//	NSLog(@"**_[scrollViewDidEndScrollingAnimation]_**");
	scrollView.pagingEnabled = YES;
	[_tableView setContentOffset:CGPointMake(0.0, [UIScreen mainScreen].bounds.size.height) animated:NO];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ([_dataItems count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[UITableViewCell alloc] init];
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	[_cells addObject:cell];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}


@end
