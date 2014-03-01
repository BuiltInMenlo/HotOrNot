//
//  HONCreateClubViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/28/2014 @ 19:51 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONCreateClubViewController.h"
#import "HONAnalyticsParams.h"
#import "HONAPICaller.h"
#import "HONColorAuthority.h"
#import "HONFontAllocator.h"
#import "HONHeaderView.h"
#import "HONUserClubInviteViewController.h"

@interface HONCreateClubViewController ()
@end


@implementation HONCreateClubViewController

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


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initAsModalWithTitle:@"Create Club" hasTranslucency:NO];
	[self.view addSubview:headerView];
	
	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeButton.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
	[closeButton setBackgroundImage:[UIImage imageNamed:@"closeModalButton_nonActive"] forState:UIControlStateNormal];
	[closeButton setBackgroundImage:[UIImage imageNamed:@"closeModalButton_Active"] forState:UIControlStateHighlighted];
	[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:closeButton];
	
	UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
	[nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_nonActive"] forState:UIControlStateNormal];
	[nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_Active"] forState:UIControlStateHighlighted];
	[nextButton addTarget:self action:@selector(_goNext) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:nextButton];
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
- (void)_goClose {
	[[Mixpanel sharedInstance] track:@"Create Club - Close" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goNext {
	[[Mixpanel sharedInstance] track:@"Create Club - Next" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	[self.navigationController pushViewController:[[HONUserClubInviteViewController alloc] init] animated:YES];
}


@end
