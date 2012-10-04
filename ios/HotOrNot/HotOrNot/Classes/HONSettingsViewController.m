//
//  HONSettingsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "HONSettingsViewController.h"
#import "HONSettingsViewCell.h"
#import "HONAppDelegate.h"

#import "HONPrivacyViewController.h"
#import "HONLoginViewController.h"

@interface HONSettingsViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, FBLoginViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISwitch *notificationSwitch;
@property (nonatomic, strong) UISwitch *tournamentSwitch;
@property (nonatomic, strong) UISwitch *activatedSwitch;
@property (nonatomic, strong) NSArray *captions;
@end

@implementation HONSettingsViewController

- (id)init {
	if ((self = [super init])) {
		self.tabBarItem.image = [UIImage imageNamed:@"tab05_nonActive"];
		self.view.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
		
		_notificationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
		[_notificationSwitch addTarget:self action:@selector(_goNotificationsSwitch:) forControlEvents:UIControlEventValueChanged];
		_notificationSwitch.on = YES;
		
		_tournamentSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
		[_tournamentSwitch addTarget:self action:@selector(_goTournamentsSwitch:) forControlEvents:UIControlEventValueChanged];
		_tournamentSwitch.on = YES;
		
		_captions = [NSArray arrayWithObjects:@"", @"Notifications", @"Daily Tournaments", @"Logout", @"Privacy Policy", @"", nil];
	}
	
	return (self);
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 45.0)];
	[headerImgView setImage:[UIImage imageNamed:@"headerTitleBackground.png"]];
	[self.view addSubview:headerImgView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 95.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 70.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
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

-(void)_goNotificationsSwitch:(UISwitch *)switchView {
	NSString *msg;
	
	if (switchView.on)
		msg = @"Turn on notifications?";
	
	else
		msg = @"Turn off notifications?";
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notifications"
																	message:msg
																  delegate:self
													  cancelButtonTitle:@"Yes"
													  otherButtonTitles:@"No", nil];
	[alert show];
	_activatedSwitch = switchView;
}

-(void)_goTournamentsSwitch:(UISwitch *)switchView {
	NSString *msg;
	
	if (switchView.on)
		msg = @"Turn on daily tournaments?";
	
	else
		msg = @"Turn off daily tournaments?";
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Daily Tournaments"
																	message:msg
																  delegate:self
													  cancelButtonTitle:@"Yes"
													  otherButtonTitles:@"No", nil];
	[alert show];
	_activatedSwitch = switchView;
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (6);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	HONSettingsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		if (indexPath.row == 0)
			cell = [[HONSettingsViewCell alloc] initAsTopCell:[[[HONAppDelegate infoForUser] objectForKey:@"points"] intValue] withSubject:[HONAppDelegate dailySubjectName]];
		
		else if (indexPath.row == 5)
			cell = [[HONSettingsViewCell alloc] initAsBottomCell];
		
		else
			cell = [[HONSettingsViewCell alloc] initAsMidCell:[_captions objectAtIndex:indexPath.row]];
	}
	
	if (indexPath.row == 1)
		cell.accessoryView = _notificationSwitch;
	
	if (indexPath.row == 2)
		cell.accessoryView = _tournamentSwitch;
		
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0)
		return (55.0);
	
	else
		return (70.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row == 3 || indexPath.row == 4)
		return (indexPath);
	
	else
		return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	[(HONSettingsViewCell *)[tableView cellForRowAtIndexPath:indexPath] didSelect];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[HONLoginViewController alloc] init]];
	switch (indexPath.row) {
		case 3:
			[FBSession.activeSession closeAndClearTokenInformation];
			
			[navController setNavigationBarHidden:YES];
			[self presentViewController:navController animated:YES completion:nil];
			break;
			
		case 4:
			[self.navigationController pushViewController:[[HONPrivacyViewController alloc] init] animated:YES];
			break;
	}
}

#pragma mark - AlerView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch(buttonIndex) {
		case 0:
			break;
			
		case 1:
			_activatedSwitch.on = !_activatedSwitch.on;
			break;
	}
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
