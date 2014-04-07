//
//  HONUserClubsSearchViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/01/2014 @ 14:49 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "EGORefreshTableHeaderView.h"

#import "HONUserClubsSearchViewController.h"
#import "HONAPICaller.h"
#import "HONHeaderView.h"


@interface HONUserClubsSearchViewController () //<EGORefreshTableHeaderDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) NSMutableArray *userClubs;
@end


@implementation HONUserClubsSearchViewController

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
- (void)_retrieveClubs {
//	for (HONTrivialUserVO *vo in [HONAppDelegate followingListWithRefresh:YES]) {
//		NSLog(@"FOLLOWING:[%@]", vo.dictionary);
//	}
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_userClubs = [NSMutableArray array];
	
//	_tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
//	[_tableView setBackgroundColor:[UIColor clearColor]];
//	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//	_tableView.delegate = self;
//	_tableView.dataSource = self;
//	_tableView.showsHorizontalScrollIndicator = NO;
//	[self.view addSubview:_tableView];
//	
//	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0, -_tableView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height) headerOverlaps:NO];
//	_refreshTableHeaderView.delegate = self;
//	_refreshTableHeaderView.scrollView = _tableView;
//	[_tableView addSubview:_refreshTableHeaderView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Find Selfieclubs"];
	[self.view addSubview:headerView];
	
	NSLog(@"self.navigationController.presentingViewController.presentedViewController:[%@]", self.navigationController.presentingViewController.presentedViewController);
	if ([self.parentViewController.presentedViewController isEqual:self] || self.navigationController.presentingViewController.presentedViewController == self.navigationController || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]]) {
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
		[closeButton setBackgroundImage:[UIImage imageNamed:@"closeModalButton_nonActive"] forState:UIControlStateNormal];
		[closeButton setBackgroundImage:[UIImage imageNamed:@"closeModalButton_Active"] forState:UIControlStateHighlighted];
		[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
		
	} else {
		UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		backButton.frame = CGRectMake(0.0, 0.0, 94.0, 44.0);
		[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
		[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
		[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		[headerView addButton:backButton];
	}
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(222.0, 0.0, 93.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:doneButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
- (void)_goBack {
	[[Mixpanel sharedInstance] track:@"Club Invite - Back" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goClose {
	[[Mixpanel sharedInstance] track:@"Club Invite - Close" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goDone {
	[[Mixpanel sharedInstance] track:@"Club Invite - Done" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


@end
