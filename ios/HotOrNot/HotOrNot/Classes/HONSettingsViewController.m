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
#import "MBProgressHUD.h"

#import "HONSettingsViewController.h"
#import "HONSettingsViewCell.h"
#import "HONFAQViewController.h"
#import "HONSupportViewController.h"
#import "HONHeaderView.h"
#import "HONImagePickerViewController.h"
#import "HONUsernameViewController.h"
#import "HONSearchBarHeaderView.h"
#import "HONTimelineViewController.h"

@interface HONSettingsViewController () <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISwitch *notificationSwitch;
@property (nonatomic, strong) UISwitch *activatedSwitch;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) NSArray *captions;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@end

@implementation HONSettingsViewController

- (id)init {
	if ((self = [super init])) {
		
		_captions = @[NSLocalizedString(@"settings_notifications", nil),
					  NSLocalizedString(@"settings_inviteSMS", nil),
					  NSLocalizedString(@"settings_inviteEmail", nil),
					  NSLocalizedString(@"settings_changeUsername", nil),
					  @"Change email",
					  NSLocalizedString(@"settings_support", nil),
					  @"FAQ"];
		
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


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
	
	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeButton.frame = CGRectMake(252.0, 13.0, 64.0, 44.0);
	[closeButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[closeButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
	
	_headerView = [[HONHeaderView alloc] initAsModalWithTitle:@""];
	_headerView.frame = CGRectOffset(_headerView.frame, 0.0, -13.0);
	_headerView.backgroundColor = [UIColor blackColor];
	[_headerView hideRefreshing];
	[_headerView addButton:closeButton];
	[self.view addSubview:_headerView];
	
	UILabel *headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 41.0, 200.0, 24.0)];
	headerTitleLabel.backgroundColor = [UIColor clearColor];
	headerTitleLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:19];
	headerTitleLabel.textColor = [UIColor whiteColor];
	headerTitleLabel.textAlignment = NSTextAlignmentCenter;
	headerTitleLabel.text = @"Settings";
	[_headerView addSubview:headerTitleLabel];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kNavBarHeaderHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - kNavBarHeaderHeight) style:UITableViewStylePlain];
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
		messageComposeViewController.body = [NSString stringWithFormat:[HONAppDelegate smsInviteFormat], [[HONAppDelegate infoForUser] objectForKey:@"name"]];
		
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
		cell = [[HONSettingsViewCell alloc] initAsMidCell:[_captions objectAtIndex:indexPath.row]];
	
	if (indexPath.row == 0) {
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
	if (indexPath.row == 0)
		return (nil);
	
	else
		return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	//[(HONSettingsViewCell *)[tableView cellForRowAtIndexPath:indexPath] didSelect];
	
	UINavigationController *navigationController;
	//HONSettingsViewCell *cell = (HONSettingsViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	
	switch (indexPath.row) {
		case 1:{
			[[Mixpanel sharedInstance] track:@"Settings - Invite via SMS"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			if ([MFMessageComposeViewController canSendText]) {
				MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
				messageComposeViewController.messageComposeDelegate = self;
				//messageComposeViewController.recipients = [NSArray arrayWithObject:@"2393709811"];
				messageComposeViewController.body = [NSString stringWithFormat:[HONAppDelegate smsInviteFormat], [[HONAppDelegate infoForUser] objectForKey:@"name"]];
				
				[self presentViewController:messageComposeViewController animated:YES completion:^(void) {}];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"SMS Error"
											message:@"Cannot send SMS from this device!"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
			break;}
			
		case 2: {
			[[Mixpanel sharedInstance] track:@"Settings - Invite via Email"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			if ([MFMailComposeViewController canSendMail]) {
				MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
				mailComposeViewController.mailComposeDelegate = self;
				//[mailComposeViewController setToRecipients:[NSArray arrayWithObject:@"matt.holcombe@gmail.com"]];
				[mailComposeViewController setMessageBody:[NSString stringWithFormat:[HONAppDelegate emailInviteFormat], [[HONAppDelegate infoForUser] objectForKey:@"name"]] isHTML:NO];
				
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
			
		case 3:
			[[Mixpanel sharedInstance] track:@"Settings - Change Username"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUsernameViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			break;
			
		case 4:{
			[[Mixpanel sharedInstance] track:@"Settings - Change Email"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			if ([MFMailComposeViewController canSendMail]) {
				MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
				mailComposeViewController.mailComposeDelegate = self;
				[mailComposeViewController setToRecipients:[NSArray arrayWithObject:@"support@letsvolley.com"]];
				[mailComposeViewController setSubject:@"Change My Email Address"];
				[mailComposeViewController setMessageBody:[NSString stringWithFormat:@"%@ - %@\nType your desired email address here.", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]] isHTML:NO];
				
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

		case 5:
			[[Mixpanel sharedInstance] track:@"Settings - Show Support"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSupportViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			break;
			
		case 6:
			[[Mixpanel sharedInstance] track:@"Settings - Show FAQ"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONFAQViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
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
				[[Mixpanel sharedInstance] track:@"Settings - Notifications"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d", _notificationSwitch.on], @"switch", nil]];
				
				
				NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSString stringWithFormat:@"%d", 4], @"action",
												[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
												(_notificationSwitch.on) ? @"Y" : @"N", @"isNotifications",
												nil];
				
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
						
						HONSettingsViewCell *cell = (HONSettingsViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
						[cell updateTopCell];
						
						[_headerView setTitle:[NSString stringWithFormat:@"@%@", [[HONAppDelegate infoForUser] objectForKey:@"name"]]];
					}
					
					[_headerView toggleRefresh:NO];
					if (_progressHUD != nil) {
						[_progressHUD hide:YES];
						_progressHUD = nil;
					}
					
				} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
					
					[_headerView toggleRefresh:NO];
					_progressHUD.minShowTime = kHUDTime;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
					_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
					[_progressHUD show:NO];
					[_progressHUD hide:YES afterDelay:kHUDErrorTime];
					_progressHUD = nil;
				}];
				break;}
				
			case 1:
				_activatedSwitch.on = !_activatedSwitch.on;
				break;
		}
	
	}
}

@end
