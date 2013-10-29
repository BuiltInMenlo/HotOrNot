//
//  HONSettingsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"

#import "HONSettingsViewController.h"
#import "HONSettingsViewCell.h"
#import "HONFAQViewController.h"
#import "HONTermsConditionsViewController.h"
#import "HONHeaderView.h"
#import "HONImagePickerViewController.h"
#import "HONUsernameViewController.h"
#import "HONSearchBarHeaderView.h"
#import "HONTimelineViewController.h"

@interface HONSettingsViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISwitch *notificationSwitch;
@property (nonatomic, strong) UISwitch *activatedSwitch;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) NSArray *captions;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end

@implementation HONSettingsViewController

- (id)init {
	if ((self = [super init])) {
		
		_captions = @[@"Frequently Asked Questions",
					  NSLocalizedString(@"settings_notifications", nil),
					  NSLocalizedString(@"settings_inviteSMS", nil),
					  NSLocalizedString(@"settings_inviteEmail", nil),
					  NSLocalizedString(@"settings_changeUsername", nil),
					  @"Change Email",
					  @"Change Birthday",
					  @"Delete all my Volleys",
					  @"Deactivate Account",
					  @"Report Abuse or Bugs",
					  @"Terms & Conditions"];
		
		_notificationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100.0, 5.0, 100.0, 50.0)];
		[_notificationSwitch addTarget:self action:@selector(_goNotificationsSwitch:) forControlEvents:UIControlEventValueChanged];
		if ([HONAppDelegate infoForUser] != nil)
			_notificationSwitch.on = [[[HONAppDelegate infoForUser] objectForKey:@"notifications"] isEqualToString:@"Y"];
		
		else
			_notificationSwitch.on = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_inviteSMS:) name:@"INVITE_SMS" object:nil];
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
- (void)_deleteUserVolleys {
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIPurgeContent);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIPurgeContent parameters:[NSDictionary dictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
		} else {
			NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_PROFILE" object:nil];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}


- (void)_wipeUser {
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIPurgeUser);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIPurgeUser parameters:[NSDictionary dictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
		} else {
			NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			NSArray *totals = @[@"background_total",
								@"timeline_total",
								@"explore_total",
								@"exploreRefresh_total",
								@"verify_total",
								@"verifyRefresh_total",
								@"popular_total",
								@"verifyAction_total",
								@"preview_total",
								@"details_total",
								@"camera_total",
								@"join_total",
								@"profile_total",
								@"like_total"];
			
			for (NSString *key in totals)
				[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:-1] forKey:key];
			
			[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"passed_registration"];
			[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"skipped_selfie"];
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_info"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_TAB" object:[NSNumber numberWithInt:0]];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_FIRST_RUN" object:nil];
			}];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];

}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
	
	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
	[closeButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[closeButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
	
	_headerView = [[HONHeaderView alloc] initAsModalWithTitle:@"Settings"];
	_headerView.backgroundColor = [UIColor blackColor];
	[_headerView addButton:closeButton];
	[self.view addSubview:_headerView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 64.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.showsVerticalScrollIndicator = YES;
	_tableView.scrollsToTop = NO;
	[self.view addSubview:_tableView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[HONAppDelegate offsetSubviewsForIOS7:self.view];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goClose {
	[[Mixpanel sharedInstance] track:@"Settings - Close"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
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


#pragma mark - Notifications
- (void)_inviteSMS:(NSNotification *)notification {
	if ([MFMessageComposeViewController canSendText]) {
		MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
		messageComposeViewController.messageComposeDelegate = self;
		//messageComposeViewController.recipients = [NSArray arrayWithObject:@"2393709811"];
		messageComposeViewController.body = [NSString stringWithFormat:[HONAppDelegate smsInviteFormat], [[HONAppDelegate infoForUser] objectForKey:@"username"], [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@?mt=8&uo=4", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]];
		
		[self presentViewController:messageComposeViewController animated:YES completion:^(void) {}];
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SMS Error"
																			 message:@"Cannot send SMS from this device!"
																			delegate:nil
																cancelButtonTitle:@"OK"
																otherButtonTitles:nil];
		[alertView show];
	}
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_captions count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONSettingsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONSettingsViewCell alloc] initWithCaption:[_captions objectAtIndex:indexPath.row]];
	
	if (indexPath.row == 1) {
		[cell hideChevron];
		cell.accessoryView = _notificationSwitch;
	}
			
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.row == 1) ? nil : indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	[(HONSettingsViewCell *)[tableView cellForRowAtIndexPath:indexPath] didSelect];
	
	if (indexPath.row == 0) {
		[[Mixpanel sharedInstance] track:@"Settings - Show FAQ"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONFAQViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
	
	} else if (indexPath.row == 2) {
		[[Mixpanel sharedInstance] track:@"Settings - Invite via SMS"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if ([MFMessageComposeViewController canSendText]) {
			MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
			messageComposeViewController.messageComposeDelegate = self;
			//messageComposeViewController.recipients = [NSArray arrayWithObject:@"8882221234"];
			messageComposeViewController.body = [NSString stringWithFormat:[HONAppDelegate smsInviteFormat], [[HONAppDelegate infoForUser] objectForKey:@"username"], [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@?mt=8&uo=4", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]];
			
			[self presentViewController:messageComposeViewController animated:YES completion:^(void) {}];
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"SMS Error"
										message:@"Cannot send SMS from this device!"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
		}
		
	} else if (indexPath.row == 3) {
		[[Mixpanel sharedInstance] track:@"Settings - Invite via Email"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if ([MFMailComposeViewController canSendMail]) {
			MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
			mailComposeViewController.mailComposeDelegate = self;
			//[mailComposeViewController setToRecipients:[NSArray arrayWithObject:@"foo@bar.com"]];
			[mailComposeViewController setSubject:[[HONAppDelegate emailInviteFormat] objectForKey:@"subject"]];
			[mailComposeViewController setMessageBody:[NSString stringWithFormat:[[HONAppDelegate emailInviteFormat] objectForKey:@"body"], [[HONAppDelegate infoForUser] objectForKey:@"username"], [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@?mt=8&uo=4", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]] isHTML:NO];
			[mailComposeViewController.view setTag:0];
			
			[self presentViewController:mailComposeViewController animated:YES completion:^(void) {}];
			
		} else {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Email Error"
																message:@"Cannot send email from this device!"
															   delegate:nil
													  cancelButtonTitle:@"OK"
													  otherButtonTitles:nil];
			[alertView show];
		}
		
	} else if (indexPath.row == 4) {
		[[Mixpanel sharedInstance] track:@"Settings - Change Username"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUsernameViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
	
	} else if (indexPath.row == 5) {
		[[Mixpanel sharedInstance] track:@"Settings - Change Email"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if ([MFMailComposeViewController canSendMail]) {
			MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
			mailComposeViewController.mailComposeDelegate = self;
			[mailComposeViewController setToRecipients:[NSArray arrayWithObject:@"support@letsvolley.com"]];
			[mailComposeViewController setSubject:@"Change My Email Address"];
			[mailComposeViewController setMessageBody:[NSString stringWithFormat:@"%@ - %@\nType your desired email address here.", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]] isHTML:NO];
			[mailComposeViewController.view setTag:1];
			
			[self presentViewController:mailComposeViewController animated:YES completion:^(void) {}];
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"Email Error"
										message:@"Cannot send email from this device!"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
		}
	
	} else if (indexPath.row == 6) {
		[[Mixpanel sharedInstance] track:@"Settings - Change Birthday"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if ([MFMailComposeViewController canSendMail]) {
			MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
			mailComposeViewController.mailComposeDelegate = self;
			[mailComposeViewController.view setTag:3];
			[mailComposeViewController setToRecipients:[NSArray arrayWithObject:@"support@letsvolley.com"]];
			[mailComposeViewController setSubject:@"Change My Birthday"];
			[mailComposeViewController setMessageBody:[NSString stringWithFormat:@"%@ - %@\nType your birthday change here.", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]] isHTML:NO];
			
			[self presentViewController:mailComposeViewController animated:YES completion:^(void) {}];
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"Email Error"
										message:@"Cannot send email from this device!"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
		}
		
	} else if (indexPath.row == 7) {
		[[Mixpanel sharedInstance] track:@"Settings - Delete Volleys"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Remove all your volleys?"
															message:@""
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"Yes", nil];
		[alertView setTag:2];
		[alertView show];
		
	} else if (indexPath.row == 8) {
		[[Mixpanel sharedInstance] track:@"Settings - Deactivate"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Deactivate Account"
															message:@"Are you sure?"
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"Yes", nil];
		[alertView setTag:1];
		[alertView show];
		
	} else if (indexPath.row == 9) {
		[[Mixpanel sharedInstance] track:@"Settings - Report Abuse / Bug"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if ([MFMailComposeViewController canSendMail]) {
			MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
			mailComposeViewController.mailComposeDelegate = self;
			[mailComposeViewController.view setTag:4];
			[mailComposeViewController setToRecipients:[NSArray arrayWithObject:@"support@letsvolley.com"]];
			[mailComposeViewController setSubject:@"Report Abuse / Bug"];
			[mailComposeViewController setMessageBody:@"" isHTML:NO];
			
			[self presentViewController:mailComposeViewController animated:YES completion:^(void) {}];
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"Email Error"
										message:@"Cannot send email from this device!"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
		}
		
	} else if (indexPath.row == 10) {
		[[Mixpanel sharedInstance] track:@"Settings - Show Support"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONTermsConditionsViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
	}
}


#pragma mark - MessageCompose Delegates
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	NSString *mpAction = @"";
	switch (result) {
		case MessageComposeResultCancelled:
			mpAction = @"Canceled";
			break;
			
		case MessageComposeResultSent:
			mpAction = @"Sent";
			break;
			
		case MessageComposeResultFailed:
			mpAction = @"Failed";
			break;
			
		default:
			mpAction = @"Not Sent";
			break;
	}
	
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Settings - Invite via SMS Message %@", mpAction]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - MailCompose Delegates
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	
	NSString *mpEvent = @"";
	if (controller.view.tag == 0) {
		mpEvent = @"Invite via Email";
	
	} else if (controller.view.tag == 1) {
		mpEvent = @"Change Email";
		
	} else if (controller.view.tag == 3) {
		mpEvent = @"Change Birthday";
	
	} else if (controller.view.tag == 4) {
		mpEvent = @"Report Abuse / Bug";
	}
	
	NSString *mpAction = @"";
	switch (result) {
		case MFMailComposeResultCancelled:
			mpAction = @"Canceled";
			break;
			
		case MFMailComposeResultFailed:
			mpAction = @"Failed";
			break;
			
		case MFMailComposeResultSaved:
			mpAction = @"Saved";
			break;
			
		case MFMailComposeResultSent:
			mpAction = @"Sent";
			break;
			
		default:
			mpAction = @"Not Sent";
			break;
	}
	
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Settings - %@ Message %@", mpEvent, mpAction]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - AlertView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		if (buttonIndex == 0) {
				[[Mixpanel sharedInstance] track:@"Settings - Notifications"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d", _notificationSwitch.on], @"switch", nil]];
				
				
				NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSString stringWithFormat:@"%d", 4], @"action",
												[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
												(_notificationSwitch.on) ? @"Y" : @"N", @"isNotifications", nil];
				
				VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
				AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
				[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					NSError *error = nil;
					if (error != nil) {
						VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
						
					} else {
						NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
						//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
						
						if ([userResult objectForKey:@"id"] != [NSNull null])
							[HONAppDelegate writeUserInfo:userResult];
					}
					
					if (_progressHUD != nil) {
						[_progressHUD hide:YES];
						_progressHUD = nil;
					}
					
				} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
					
					_progressHUD.minShowTime = kHUDTime;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
					_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
					[_progressHUD show:NO];
					[_progressHUD hide:YES afterDelay:kHUDErrorTime];
					_progressHUD = nil;
				}];
			
		} else if (buttonIndex == 1)
			_activatedSwitch.on = !_activatedSwitch.on;
	
	} else if (alertView.tag == 1) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Settings - Deactivate %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if (buttonIndex == 1) {
			[self _wipeUser];
		}
	
	} else if (alertView.tag == 2) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Settings - Delete Volleys %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if (buttonIndex == 1) {
			[self _deleteUserVolleys];
		}
	}
}

@end
