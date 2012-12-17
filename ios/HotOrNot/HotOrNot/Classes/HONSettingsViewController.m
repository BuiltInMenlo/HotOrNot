//
//  HONSettingsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

//#import <FacebookSDK/FacebookSDK.h>
#import "Facebook.h"
#import "ASIFormDataRequest.h"
#import "Mixpanel.h"

#import "HONSettingsViewController.h"
#import "HONSettingsViewCell.h"
#import "HONAppDelegate.h"

#import "HONPrivacyViewController.h"
#import "HONSupportViewController.h"
#import "HONLoginViewController.h"
#import "HONHeaderView.h"

@interface HONSettingsViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, ASIHTTPRequestDelegate, FBLoginViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISwitch *notificationSwitch;
@property (nonatomic, strong) UISwitch *fbSwitch;
@property (nonatomic, strong) UISwitch *activatedSwitch;
@property (nonatomic, strong) NSArray *captions;
@end

@implementation HONSettingsViewController

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor whiteColor];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSupport:) name:@"SHOW_SUPPORT" object:nil];
		
		_captions = [NSArray arrayWithObjects:@"", @"Notifications", @"Facebook Posting", (FBSession.activeSession.state == 513) ? @"Logout" : @"Login", @"Privacy Policy", @"", nil];
		
		_notificationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100.0, 5.0, 100.0, 50.0)];
		[_notificationSwitch addTarget:self action:@selector(_goNotificationsSwitch:) forControlEvents:UIControlEventValueChanged];
		if ([HONAppDelegate infoForUser] != nil)
			_notificationSwitch.on = [[[HONAppDelegate infoForUser] objectForKey:@"notifications"] isEqualToString:@"Y"];
		
		else
			_notificationSwitch.on = YES;
		
		_fbSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
		[_fbSwitch addTarget:self action:@selector(_goFBSwitch:) forControlEvents:UIControlEventValueChanged];
		_fbSwitch.on = [HONAppDelegate allowsFBPosting];
	}
	
	return (self);
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h.png" : @"mainBG.png"];
	[self.view addSubview:bgImgView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Settings" hasFBSwitch:NO];
	[self.view addSubview:headerView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 69.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 70.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	//NSLog(@"[FBSession.activeSession] (%d)", FBSession.activeSession.state);
	
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

-(void)_goFBSwitch:(UISwitch *)switchView {
	NSString *msg;
	
	[HONAppDelegate setAllowsFBPosting:switchView.on];
	
	if (switchView.on)
		msg = @"Turn on Facebook posting?";
	
	else
		msg = @"Turn off facebook posting?";
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Posting"
																	message:msg
																  delegate:self
													  cancelButtonTitle:@"Yes"
													  otherButtonTitles:@"No", nil];
	[alert show];
	_activatedSwitch = switchView;
}


#pragma mark - Notifications
- (void)_showSupport:(NSNotification *)notification {
	[self.navigationController pushViewController:[[HONSupportViewController alloc] init] animated:YES];
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
		cell.accessoryView = _fbSwitch;
		
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0)
		return (20.0);
	
//	else if (indexPath.row == 5)
//		return (24.0);
	
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
			if (FBSession.activeSession.state == 513)
				[FBSession.activeSession closeAndClearTokenInformation];
			
			[navController setNavigationBarHidden:YES];
			[self presentViewController:navController animated:YES completion:nil];
			break;
			
		case 4:
			[self.navigationController pushViewController:[[HONPrivacyViewController alloc] init] animated:YES];
			break;
	}
}


#pragma mark - AlertView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch(buttonIndex) {
		case 0:
			if (_activatedSwitch == _fbSwitch) {
				[[Mixpanel sharedInstance] track:@"Facebook Posting"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d", _fbSwitch.on], @"switch", nil]];
				
				[HONAppDelegate setAllowsFBPosting:_fbSwitch.on];
				//[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_FB_POSTING" object:nil];
			
			} else {
				//NSLog(@"-----loginViewShowingLoggedInUser-----");
				[[Mixpanel sharedInstance] track:@"Notifications"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d", _fbSwitch.on], @"switch", nil]];
				
				ASIFormDataRequest *toggleRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kUsersAPI]]];
				[toggleRequest setDelegate:self];
				[toggleRequest setPostValue:[NSString stringWithFormat:@"%d", 4] forKey:@"action"];
				[toggleRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
				[toggleRequest setPostValue:(_notificationSwitch.on) ? @"Y" : @"N" forKey:@"isNotifications"];
				[toggleRequest startAsynchronous];
			}
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


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request {
	//NSLog(@"HONSettingsViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			[HONAppDelegate writeUserInfo:userResult];
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}
@end
