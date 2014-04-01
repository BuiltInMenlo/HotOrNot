//
//  HONUserClubInviteViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/01/2014 @ 14:05 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "EGORefreshTableHeaderView.h"

#import "HONUserClubInviteViewController.h"
#import "HONHeaderView.h"

@interface HONUserClubInviteViewController () //<EGORefreshTableHeaderDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) NSMutableArray *inAppContacts;
@property (nonatomic, strong) NSMutableArray *nonAppContacts;
@property (nonatomic) BOOL isModal;
@end


@implementation HONUserClubInviteViewController


- (id)initAsModal:(BOOL)isModal {
	if ((self = [super init])) {
		_isModal = isModal;
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


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_inAppContacts = [NSMutableArray array];
	_nonAppContacts = [NSMutableArray array];
	
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
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Invite Friends"];
	[self.view addSubview:headerView];
	
	if (_isModal) {
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
		[closeButton setBackgroundImage:[UIImage imageNamed:@"xButton_nonActive"] forState:UIControlStateNormal];
		[closeButton setBackgroundImage:[UIImage imageNamed:@"xButton_Active"] forState:UIControlStateHighlighted];
		[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
		[headerView addButton:closeButton];
		
	} else {
		UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		backButton.frame = CGRectMake(0.0, 0.0, 94.0, 44.0);
		[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
		[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
		[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		[headerView addButton:backButton];
	}
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
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
	
	NSLog(@"SELF:[%@]\nSELF.NC:[%@]", self, self.navigationController);
	NSLog(@"[self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]](%d)", [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]]);
	NSLog(@"self.navigationController.presentingViewController.presentedViewController:[%@]", self.navigationController.presentingViewController.presentedViewController);
	NSLog(@"self.presentingViewController.presentedViewController:[%@]", self.presentingViewController.presentedViewController);
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
