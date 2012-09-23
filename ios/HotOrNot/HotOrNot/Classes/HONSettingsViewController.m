//
//  HONSettingsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "HONSettingsViewController.h"

@interface HONSettingsViewController () <FBLoginViewDelegate>

@end

@implementation HONSettingsViewController

- (id)init {
	if ((self = [super init])) {
		self.title = NSLocalizedString(@"Settings", @"Settings");
		self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
	}
	
	return (self);
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	FBLoginView *loginview = [[FBLoginView alloc] initWithPermissions:[NSArray arrayWithObject:@"status_update"]];
	loginview.frame = CGRectOffset(loginview.frame, 5, 5);
	loginview.delegate = self;
	[self.view addSubview:loginview];
	[loginview sizeToFit];
	
}
- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_goDone)];
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
- (void)_goDone {
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Login Delegates
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
	NSLog(@"-----loginViewShowingLoggedInUser-----");
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
	NSLog(@"-----loginViewFetchedUserInfo\n%@", user);
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
	NSLog(@"-----loginViewShowingLoggedOutUser-----");
}
@end
