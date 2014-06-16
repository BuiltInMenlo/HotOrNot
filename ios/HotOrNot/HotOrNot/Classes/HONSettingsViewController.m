//
//  HONSettingsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "MBProgressHUD.h"

#import "HONSettingsViewController.h"
#import "HONSettingsViewCell.h"
#import "HONFAQViewController.h"
#import "HONTermsConditionsViewController.h"
#import "HONHeaderView.h"
#import "HONUsernameViewController.h"

@interface HONSettingsViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISwitch *notificationSwitch;
@property (nonatomic, strong) NSArray *captions;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end

@implementation HONSettingsViewController

- (id)init {
	if ((self = [super init])) {
		_captions = @[@"Notifications",
					  @"Terms of service",
					  @"Privacy policy",
					  @"Support",
					  @"Rate this app",
					  @"Network status"];
		
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


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Settings"];
	[self.view addSubview:headerView];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(228.0, 1.0, 93.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:doneButton];
	
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
}

- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goClose {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Settings - Close"];
	[self dismissViewControllerAnimated:YES completion:^(void) {}];
}

- (void)_goNotificationsSwitch:(UISwitch *)switchView {
	[[HONAnalyticsParams sharedInstance] trackEvent:[@"Settings - Notifications Toggle " stringByAppendingString:(switchView.on) ? @"On" : @"Off"]
									 withProperties:@{@"enabled"	: [@"" stringFromBOOL:switchView.on]}];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notifications"
																	message:[NSString stringWithFormat:@"Turn %@ notifications?", (switchView.on) ? @"ON" : @"OFF"]
																  delegate:self
													  cancelButtonTitle:@"Cancel"
													  otherButtonTitles:@"OK", nil];
	[alertView setTag:HONSettingsAlertTypeNotifications];
	[alertView show];
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
		[[[UIAlertView alloc] initWithTitle:@"SMS Error"
									message:@"Cannot send SMS from this device!"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
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
	
	if (indexPath.row == HONSettingsCellTypeNotifications) {
		[cell hideChevron];
		cell.accessoryView = _notificationSwitch;
	}
			
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return (40.0);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, 320.0, 20.0)];
	label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:12];
	label.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.text = @"Version1.1";
	[footerView addSubview:label];
	
	return (footerView);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.row == HONSettingsCellTypeNotifications) ? nil : indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	if (indexPath.row == HONSettingsCellTypeTermsOfService) {
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Settings - Terms of Service"];
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONTermsConditionsViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
		
	} else if (indexPath.row == HONSettingsCellTypePrivacyPolicy) {
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Settings - Privacy Policy"];
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONFAQViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
		
	} else if (indexPath.row == HONSettingsCellTypeSupport) {
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Settings - Support"];
		
		if ([MFMailComposeViewController canSendMail]) {
			MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
			mailComposeViewController.mailComposeDelegate = self;
			[mailComposeViewController.view setTag:HONSettingsMailComposerTypeReportAbuse];
			[mailComposeViewController setToRecipients:[NSArray arrayWithObject:@"support@selfieclubapp.com"]];
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
		
	} else if (indexPath.row == HONSettingsCellTypeRateThisApp) {
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Settings - Rate App"];
		
	} else if (indexPath.row == HONSettingsCellTypeNetworkStatus) {
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Settings - Netwrok Status"];
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
	
	[[HONAnalyticsParams sharedInstance] trackEvent:[@"Settings - " stringByAppendingString:mpAction]];
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - MailCompose Delegates
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	
	NSString *mpEvent = @"";
	if (controller.view.tag == HONSettingsMailComposerTypeChangeEmail) {
		mpEvent = @"Change Email";
		
	} else if (controller.view.tag == HONSettingsMailComposerTypeReportAbuse) {
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
	
	[[HONAnalyticsParams sharedInstance] trackEvent:[[NSString stringWithFormat:@"Settings - %@ - Message ", mpEvent] stringByAppendingString:mpAction]];
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - AlertView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == HONSettingsAlertTypeNotifications) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Settings - Notifications Toggle " stringByAppendingString:(_notificationSwitch.on) ? @"On" : @"Off"]
										 withProperties:@{@"enabled"	: [@"" stringFromBOOL:_notificationSwitch.on]}];
		
		if (buttonIndex == 0)
			_notificationSwitch.on = !_notificationSwitch.on;
		
		else {
			[[HONAPICaller sharedInstance] togglePushNotificationsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] areEnabled:_notificationSwitch.on completion:^(NSDictionary *result) {
				if ([result objectForKey:@"id"] != [NSNull null])
					[HONAppDelegate writeUserInfo:result];
			}];
		}
		
	} else if (alertView.tag == HONSettingsAlertTypeDeactivate) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Settings - Deactivate " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]];
		
		if (buttonIndex == 1) {
			Mixpanel *mixpanel = [Mixpanel sharedInstance];
			[mixpanel identify:[[HONDeviceIntrinsics sharedInstance] advertisingIdentifierWithoutSeperators:NO]];
			[mixpanel.people set:@{@"$email"		: [[HONAppDelegate infoForUser] objectForKey:@"email"],
								   @"$created"		: [[HONAppDelegate infoForUser] objectForKey:@"added"],
								   @"id"			: [[HONAppDelegate infoForUser] objectForKey:@"id"],
								   @"username"		: [[HONAppDelegate infoForUser] objectForKey:@"username"],
								   @"deactivated"	: @"YES"}];
			
			[[HONAPICaller sharedInstance] deactivateUserWithCompletion:^(NSObject *result) {
				[HONAppDelegate resetTotals];
				
				[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"is_deactivated"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
				[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"passed_registration"];
				[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_info"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
					[[[UIApplication sharedApplication] delegate] performSelector:@selector(changeTabToIndex:) withObject:@0];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_FIRST_RUN" object:nil];
				}];
			}];
		}
	
	} else if (alertView.tag == HONSettingsAlertTypeDeleteChallenges) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Settings - " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]];
		
		if (buttonIndex == 1) {
			[[HONAPICaller sharedInstance] removeAllChallengesForUserWithCompletion:^(NSObject *result){
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_PROFILE" object:nil];
			}];
		}
	}
}

@end
