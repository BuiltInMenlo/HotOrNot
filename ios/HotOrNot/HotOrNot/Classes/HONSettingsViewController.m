//
//  HONSettingsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "Facebook.h"
#import "Mixpanel.h"
#import "MBProgressHUD.h"

#import "HONSettingsViewController.h"
#import "HONSettingsViewCell.h"
#import "HONAppDelegate.h"
#import "HONPrivacyViewController.h"
#import "HONSupportViewController.h"
#import "HONLoginViewController.h"
#import "HONHeaderView.h"
#import "HONImagePickerViewController.h"
#import "HONUsernameViewController.h"
#import "HONSearchHeaderView.h"

@interface HONSettingsViewController () <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISwitch *notificationSwitch;
@property (nonatomic, strong) UISwitch *activatedSwitch;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) NSArray *captions;
@property(nonatomic, strong) UIButton *refreshButton;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@end

@implementation HONSettingsViewController

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor whiteColor];
		
		_captions = [NSArray arrayWithObjects:@"",
						 @"NOTIFICATIONS",
						 @"INVITE FRIENDS VIA SMS",
						 @"INVITE FRIENDS VIA EMAIL",
						 (FBSession.activeSession.state == 513) ? @"LOGOUT OF FACEBOOK" : @"LOGIN TO FACEBOOK",
						 @"CHANGE USERNAME",
						 @"SUPPORT",
						 @"PRIVACY POLICY", nil];
		
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
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshSettingsTab:) name:@"REFRESH_SETTINGS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshSettingsTab:) name:@"REFRESH_ALL_TABS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSearchResults:) name:@"SHOW_SEARCH_RESULTS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_hideSearchResults:) name:@"HIDE_SEARCH_RESULTS" object:nil];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (NO);
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h" : @"mainBG"];
	[self.view addSubview:bgImgView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:[[[HONAppDelegate infoForUser] objectForKey:@"name"] uppercaseString]];
	[self.view addSubview:_headerView];
	
	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	activityIndicatorView.frame = CGRectMake(14.0, 10.0, 24.0, 24.0);
	[activityIndicatorView startAnimating];
	[_headerView addSubview:activityIndicatorView];
	
	_refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_refreshButton.frame = CGRectMake(0.0, 0.0, 50.0, 45.0);
	[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_nonActive"] forState:UIControlStateNormal];
	[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_Active"] forState:UIControlStateHighlighted];
	[_refreshButton addTarget:self action:@selector(_goRefresh) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:_refreshButton];
	
	UIButton *createChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	createChallengeButton.frame = CGRectMake(270.0, 0.0, 44.0, 44.0);
	[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"createChallengeButton_nonActive"] forState:UIControlStateNormal];
	[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"createChallengeButton_Active"] forState:UIControlStateHighlighted];
	[createChallengeButton addTarget:self action:@selector(_goCreateChallenge) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:createChallengeButton];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 45.0) style:UITableViewStylePlain];
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
	
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
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

- (void)_goNotificationsSwitch:(UISwitch *)switchView {
	NSString *msg = (switchView.on) ? @"Turn on notifications?" : @"Turn off notifications?";	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notifications"
																	message:msg
																  delegate:self
													  cancelButtonTitle:@"Yes"
													  otherButtonTitles:@"No", nil];
	[alertView setTag:0];
	[alertView show];
	_activatedSwitch = switchView;
}

-(void)_goAudioSwitch:(UISwitch *)switchView {
	NSString *msg = (switchView.on) ? @"Turn on track audio?" : @"Turn off track audio?";	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Audio"
																	message:msg
																  delegate:self
													  cancelButtonTitle:@"Yes"
													  otherButtonTitles:@"No", nil];
	[alertView setTag:1];
	[alertView show];
	_activatedSwitch = switchView;
}

- (void)_goRefresh {
	[[Mixpanel sharedInstance] track:@"Settings - Refresh"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_refreshButton.hidden = YES;
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Refreshing…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 5], @"action",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									nil];
	
	[httpClient postPath:kUsersAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"HONSettingsViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
		} else {
			NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//NSLog(@"HONSettingsViewController AFNetworking: %@", userResult);
			
			if ([userResult objectForKey:@"id"] != [NSNull null])
				[HONAppDelegate writeUserInfo:userResult];
			
			HONSettingsViewCell *cell = (HONSettingsViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
			[cell updateTopCell];
			
			[_headerView setTitle:[[[HONAppDelegate infoForUser] objectForKey:@"name"] uppercaseString]];
		}
		
		_refreshButton.hidden = NO;
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"SettingsViewController AFNetworking %@", [error localizedDescription]);
		
		_refreshButton.hidden = NO;
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"Connection Error!", @"Status message when no network detected");
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}


#pragma mark - Notifications
- (void)_sessionStateChanged:(NSNotification *)notification {
	FBSession *session = (FBSession *)[notification object];
	
	[_headerView setTitle:[[[HONAppDelegate infoForUser] objectForKey:@"name"] uppercaseString]];
	
	HONSettingsViewCell *cell = (HONSettingsViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
	[cell updateCaption:(session.state == 513) ? @"LOGOUT OF FACEBOOK" : @"LOGIN TO FACEBOOK"];
}

- (void)_refreshSettingsTab:(NSNotification *)notification {
	[_tableView setContentOffset:CGPointZero animated:YES];
	_refreshButton.hidden = YES;
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 5], @"action",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									nil];
	
	[httpClient postPath:kUsersAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"HONSettingsViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
		} else {
			NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//NSLog(@"HONSettingsViewController AFNetworking: %@", userResult);
			
			if ([userResult objectForKey:@"id"] != [NSNull null])
				[HONAppDelegate writeUserInfo:userResult];
			
			HONSettingsViewCell *cell = (HONSettingsViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
			[cell updateTopCell];
			
			[_headerView setTitle:[[[HONAppDelegate infoForUser] objectForKey:@"name"] uppercaseString]];
		}
		
		_refreshButton.hidden = NO;
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"SettingsViewController AFNetworking %@", [error localizedDescription]);
		
		_refreshButton.hidden = NO;
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"Connection Error!", @"Status message when no network detected");
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}

- (void)_showSearchResults:(NSNotification *)notification {
	[UIView animateWithDuration:0.25 animations:^(void) {
		self.view.frame = CGRectMake(self.view.frame.origin.x, -44.0, self.view.frame.size.width, self.view.frame.size.height);
	}];
}

- (void)_hideSearchResults:(NSNotification *)notification {
	[UIView animateWithDuration:0.25 animations:^(void) {
		self.view.frame = CGRectMake(self.view.frame.origin.x, 0.0, self.view.frame.size.width, self.view.frame.size.height);
	}];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (8);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	HONSearchHeaderView *headerView = [[HONSearchHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 71.0)];
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
		
	} else if (indexPath.row == 4)
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
	
	if (indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 5 || indexPath.row == 6)
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
		case 2: {
			MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
			messageComposeViewController.messageComposeDelegate = self;
			//messageComposeViewController.recipients = [NSArray arrayWithObject:@"2393709811"];
			messageComposeViewController.body = [NSString stringWithFormat:@"%@ has invited you to PicCallenge!", [[HONAppDelegate infoForUser] objectForKey:@"name"]];
			
			[self presentViewController:messageComposeViewController animated:YES completion:^(void) {}];
			break;}
			
		case 3: {
			if ([MFMailComposeViewController canSendMail]) {
				MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
				mailComposeViewController.mailComposeDelegate = self;
				//[mailComposeViewController setToRecipients:[NSArray arrayWithObject:@"matt.holcombe@gmail.com"]];
				[mailComposeViewController setMessageBody:[NSString stringWithFormat:@"%@ has invited you to PicCallenge!", [[HONAppDelegate infoForUser] objectForKey:@"name"]] isHTML:NO];
				
				[self presentViewController:mailComposeViewController animated:YES completion:^(void) {}];
			
			} else {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Email Error"
																					 message:@"Cannot send email from this device!"
																					delegate:nil
																		cancelButtonTitle:@"OK"
																		otherButtonTitles:nil];
				[alertView show];
			}
			break;}
			
		case 4:
			if (FBSession.activeSession.state == 513) {
				[FBSession.activeSession closeAndClearTokenInformation];
				[cell updateCaption:@"LOGIN TO FACEBOOK"];
			
			} else {
				navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONLoginViewController alloc] init]];
				[navigationController setNavigationBarHidden:YES];
				[self presentViewController:navigationController animated:YES completion:nil];
			}
			break;
			
		case 5:
			navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUsernameViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			break;
			
		case 6:
			navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSupportViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
			break;
			
		case 7:
			navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONPrivacyViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
			break;
	}
}


#pragma mark - ScrollView Delegates
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
}


#pragma mark - MessageCompose Delegates
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	
	switch (result) {
		case MessageComposeResultCancelled:
			NSLog(@"SMS: canceled");
			break;
			
		case MessageComposeResultSent:
			NSLog(@"SMS: sent");
			break;
			
		case MessageComposeResultFailed:
			NSLog(@"SMS: failed");
			break;
			
		default:
			NSLog(@"SMS: not sent");
			break;
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - MessageCompose Delegates
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	switch (result) {
		case MFMailComposeResultCancelled:
			NSLog(@"EMAIL: canceled");
			break;
			
		case MFMailComposeResultFailed:
			NSLog(@"EMAIL: failed");
			break;
			
		case MFMailComposeResultSaved:
			NSLog(@"EMAIL: saved");
			break;
			
		case MFMailComposeResultSent:
			NSLog(@"EMAIL: sent");
			break;
			
		default:
			NSLog(@"EMAIL: not sent");
			break;
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AlertView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (alertView.tag == 0) {
		switch(buttonIndex) {
			case 0: {
				//NSLog(@"-----loginViewShowingLoggedInUser-----");
				[[Mixpanel sharedInstance] track:@"Settings - Notifications"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d", _notificationSwitch.on], @"switch", nil]];
				
			
				AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
				NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSString stringWithFormat:@"%d", 4], @"action",
												[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
												(_notificationSwitch.on) ? @"Y" : @"N", @"isNotifications",
												nil];
				
				[httpClient postPath:kUsersAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					NSError *error = nil;
					if (error != nil) {
						NSLog(@"HONSettingsViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
						
					} else {
						NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
						//NSLog(@"HONSettingsViewController AFNetworking: %@", userResult);
						
						if ([userResult objectForKey:@"id"] != [NSNull null])
							[HONAppDelegate writeUserInfo:userResult];
						
						HONSettingsViewCell *cell = (HONSettingsViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
						[cell updateTopCell];
						
						[_headerView setTitle:[[[HONAppDelegate infoForUser] objectForKey:@"name"] uppercaseString]];
					}
					
					_refreshButton.hidden = NO;
					if (_progressHUD != nil) {
						[_progressHUD hide:YES];
						_progressHUD = nil;
					}
					
				} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					NSLog(@"SettingsViewController AFNetworking %@", [error localizedDescription]);
					
					_refreshButton.hidden = NO;
					_progressHUD.minShowTime = kHUDTime;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
					_progressHUD.labelText = NSLocalizedString(@"Connection Error!", @"Status message when no network detected");
					[_progressHUD show:NO];
					[_progressHUD hide:YES afterDelay:1.5];
					_progressHUD = nil;
				}];
				break;}
				
			case 1:
				_activatedSwitch.on = !_activatedSwitch.on;
				break;
		}
	
	} else if (alertView.tag == 1) {
	}
}

@end
