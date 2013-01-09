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
#import "HONImagePickerViewController.h"
#import "HONUsernameViewController.h"
#import "HONChallengeTableHeaderView.h"

@interface HONSettingsViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, ASIHTTPRequestDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISwitch *notificationSwitch;
@property (nonatomic, strong) UISwitch *activatedSwitch;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) NSArray *captions;
@end

@implementation HONSettingsViewController

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor whiteColor];
		
		_captions = [NSArray arrayWithObjects:@"", @"NOTIFICATIONS", (FBSession.activeSession.state == 513) ? @"LOGOUT OF FACEBOOK" : @"LOGIN TO FACEBOOK", @"CHANGE USERNAME", @"SUPPORT", @"PRIVACY POLICY", nil];
		
		_notificationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100.0, 5.0, 100.0, 50.0)];
		[_notificationSwitch addTarget:self action:@selector(_goNotificationsSwitch:) forControlEvents:UIControlEventValueChanged];
		if ([HONAppDelegate infoForUser] != nil)
			_notificationSwitch.on = [[[HONAppDelegate infoForUser] objectForKey:@"notifications"] isEqualToString:@"Y"];
		
		else
			_notificationSwitch.on = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(_sessionStateChanged:)
																	name:HONSessionStateChangedNotification
																 object:nil];
	}
	
	return (self);
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h" : @"mainBG"];
	[self.view addSubview:bgImgView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:[[[HONAppDelegate infoForUser] objectForKey:@"name"] uppercaseString]];
	[self.view addSubview:_headerView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 113.0) style:UITableViewStylePlain];
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
- (void)_goDailyChallenge {
	[[Mixpanel sharedInstance] track:@"Daily Challenge - Vote Wall"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithSubject:[HONAppDelegate dailySubjectName]]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:@"Create Challenge Button - Settings"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
//	if (FBSession.activeSession.state == 513) {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
	
//	} else
//		[self _goLogin];
}

- (void)_goInviteFriends {
	[[Mixpanel sharedInstance] track:@"Invite Friends - Settings"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"INVITE_FRIENDS" object:nil];
}

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
- (void)_sessionStateChanged:(NSNotification *)notification {
	FBSession *session = (FBSession *)[notification object];
	
	[_headerView setTitle:[[HONAppDelegate infoForUser] objectForKey:@"name"]];
	
	HONSettingsViewCell *cell = (HONSettingsViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
	[cell updateCaption:(session.state == 513) ? @"LOGOUT OF FACEBOOK" : @"LOGIN TO FACEBOOK"];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (6);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	HONChallengeTableHeaderView *headerView = [[HONChallengeTableHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 71.0)];
	[headerView.inviteFriendsButton addTarget:self action:@selector(_goInviteFriends) forControlEvents:UIControlEventTouchUpInside];
	[headerView.dailyChallengeButton addTarget:self action:@selector(_goDailyChallenge) forControlEvents:UIControlEventTouchUpInside];
	
	return (headerView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONSettingsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		if (indexPath.row == 0) {
			cell = [[HONSettingsViewCell alloc] initAsTopCell];
		
		} else
			cell = [[HONSettingsViewCell alloc] initAsMidCell:[_captions objectAtIndex:indexPath.row] isGrey:(indexPath.row % 2 == 1)];
	}
	
	if (indexPath.row == 1) {
		[cell hideChevron];
		cell.accessoryView = _notificationSwitch;
	}
	else if (indexPath.row == 2)
		[cell updateCaption:(FBSession.activeSession.state == 513) ? @"LOGOUT OF FACEBOOK" : @"LOGIN TO FACEBOOK"];
			
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (70.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (71.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 5)
		return (indexPath);
	
	else
		return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	//[(HONSettingsViewCell *)[tableView cellForRowAtIndexPath:indexPath] didSelect];
	
	UINavigationController *navigationController;
	HONSettingsViewCell *cell = (HONSettingsViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	
	switch (indexPath.row) {
		case 2:
			if (FBSession.activeSession.state == 513) {
				[FBSession.activeSession closeAndClearTokenInformation];
				[cell updateCaption:@"LOGIN TO FACEBOOK"];
			
			} else {
				navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONLoginViewController alloc] init]];
				[navigationController setNavigationBarHidden:YES];
				[self presentViewController:navigationController animated:YES completion:nil];
				//[cell updateCaption:@"Logout of Facebook"];
			}
			
			[HONAppDelegate setAllowsFBPosting:(FBSession.activeSession.state == 513)];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_FB_POSTING" object:nil];
			break;
			
		case 3:
			[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"Y"];
			navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUsernameViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			break;
			
		case 5:
			[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"Y"];
			navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONPrivacyViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
			break;
			
		case 4:
			[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"Y"];
			navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSupportViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
			break;
	}
}


#pragma mark - AlertView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	ASIFormDataRequest *toggleRequest;
	
	switch(buttonIndex) {
		case 0:
				//NSLog(@"-----loginViewShowingLoggedInUser-----");
				[[Mixpanel sharedInstance] track:@"Notifications"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d", _notificationSwitch.on], @"switch", nil]];
				
				toggleRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kUsersAPI]]];
				[toggleRequest setDelegate:self];
				[toggleRequest setPostValue:[NSString stringWithFormat:@"%d", 4] forKey:@"action"];
				[toggleRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
				[toggleRequest setPostValue:(_notificationSwitch.on) ? @"Y" : @"N" forKey:@"isNotifications"];
				[toggleRequest startAsynchronous];
			break;
			
		case 1:
			_activatedSwitch.on = !_activatedSwitch.on;
			break;
	}
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
