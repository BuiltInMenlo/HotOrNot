//
//  HONSettingsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONRefreshControl.h"
#import "KeychainItemWrapper.h"

#import "HONSettingsViewController.h"
#import "HONActivityNavButtonView.h"
#import "HONComposeNavButtonView.h"
#import "HONTableView.h"
#import "HONSearchBarView.h"
#import "HONSettingsViewCell.h"
#import "HONPrivacyPolicyViewController.h"
#import "HONTermsViewController.h"
#import "HONActivityViewController.h"
#import "HONUsernameViewController.h"
#import "HONNetworkStatusViewController.h"
#import "HONComposeViewController.h"
#import "HONContactsSearchViewController.h"
#import "HONUsernameSearchViewController.h"

@interface HONSettingsViewController ()
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, strong) HONActivityNavButtonView *activityHeaderView;
@property (nonatomic, strong) UISwitch *notificationSwitch;
@property (nonatomic, strong) NSArray *captions;
@property (nonatomic, strong) NSArray *schoolClubs;
@end

@implementation HONSettingsViewController

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeSettingsTab;
		_viewStateType = HONStateMitigatorViewStateTypeSettings;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedSettingsTab:) name:@"SELECTED_SETTINGS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tareSettingsTab:) name:@"TARE_SETTINGS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshSettingsTab:) name:@"REFRESH_SETTINGS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshSettingsTab:) name:@"REFRESH_ALL_TABS" object:nil];
		
		_schoolClubs = [[NSUserDefaults standardUserDefaults] objectForKey:@"school_clubs"];
		_captions = @[NSLocalizedString(@"settings_search", @"Search"),
					  NSLocalizedString(@"settings_support", @"Support"),
					  NSLocalizedString(@"settings_notification", @"Notifications"),
					  NSLocalizedString(@"settings_legal", @"Legal"),
					  @"Share",
					  @" "];
		
		
		_notificationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100.0, 5.0, 100.0, 50.0)];
		[_notificationSwitch addTarget:self action:@selector(_goNotificationsSwitch:) forControlEvents:UIControlEventValueChanged];
		if ([HONAppDelegate infoForUser] != nil)
			_notificationSwitch.on = [[[HONAppDelegate infoForUser] objectForKey:@"notifications"] isEqualToString:@"Y"];
		
		else
			_notificationSwitch.on = YES;
	}
	
	
	return (self);
}

- (void)dealloc {
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
	
	[super destroy];
}

#pragma mark - Data Calls
#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
	[self performSelector:@selector(_didFinishDataRefresh) withObject:nil afterDelay:0.33];
}

- (void)_didFinishDataRefresh {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	[_tableView reloadData];
	[_refreshControl endRefreshing];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.957];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"More"];//NSLocalizedString(@"header_settings", @"Settings")];
	[_headerView addCloseButtonWithTarget:self action:@selector(_goClose)];
	[self.view addSubview:_headerView];
	
	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - kNavHeaderHeight) style:UITableViewStyleGrouped];
	[_tableView setContentInset:kOrthodoxTableViewEdgeInsets];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.alwaysBounceVertical = YES;
	_tableView.showsVerticalScrollIndicator = YES;
	_tableView.scrollsToTop = NO;
	[self.view addSubview:_tableView];
	
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
	[[HONStateMitigator sharedInstance] resetTotalCounterForType:_totalType withValue:([[HONStateMitigator sharedInstance] totalCounterForType:_totalType] - 1)];
	NSLog(@"[:|:] [%@]:[%@]-=(%d)=-", self.class, [[HONStateMitigator sharedInstance] _keyForTotalType:_totalType], [[HONStateMitigator sharedInstance] totalCounterForType:_totalType]);
}


#pragma mark - Navigation
- (void)_goProfile {
//	[[HONAnalyticsParams sharedInstance] trackEvent:@"Settings Tab - Activity"];
//	[self.navigationController pushViewController:[[HONActivityViewController alloc] initWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]] animated:YES];
}

- (void)_goClose {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Settings Tab - Create Status Update"];
	
	[self dismissViewControllerAnimated:NO completion:nil];
}

- (void)_goNotificationsSwitch:(UISwitch *)switchView {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:[@"Settings Tab - Toggle Notifications " stringByAppendingString:(switchView.on) ? @"On" : @"Off"]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notifications"
																	message:[NSString stringWithFormat:@"Turn %@ notifications?", (switchView.on) ? @"ON" : @"OFF"]
																  delegate:self
													  cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
													  otherButtonTitles:NSLocalizedString(@"alert_ok", nil), nil];
	
	[alertView setTag:HONSettingsAlertTypeNotifications];
	[alertView show];
}


#pragma mark - Notifications
- (void)_selectedSettingsTab:(NSNotification *)notification {
	NSLog(@"::|> _selectedSettingsTab <|::");
	
	[[HONStateMitigator sharedInstance] incrementTotalCounterForType:_totalType];
	NSLog(@"[:|:] [%@]:[%@]-=(%d)=-", self.class, [[HONStateMitigator sharedInstance] _keyForTotalType:_totalType], [[HONStateMitigator sharedInstance] totalCounterForType:_totalType]);
}

- (void)_tareSettingsTab:(NSNotification *)notification {
	NSLog(@"::|> _tarSettingsTab <|::");
}

- (void)_refreshSettingsTab:(NSNotification *)notification {
	NSLog(@"::|> _refreshSettingsTab <|::");
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((section == 0) ? [_schoolClubs count] : [_captions count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (2);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONSettingsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];

	if (indexPath.section == 0) {
		if (cell == nil)
			cell = [[HONSettingsViewCell alloc] initWithCaption:[[_schoolClubs objectAtIndex:indexPath.row] objectForKey:@"name"]];

	} else {
		if (cell == nil)
			cell = [[HONSettingsViewCell alloc] initWithCaption:[_captions objectAtIndex:indexPath.row]];
		
		if (indexPath.row == HONSettingsCellTypeNotifications) {
			[cell hideChevron];
			cell.accessoryView = _notificationSwitch;
			
		} else if (indexPath.row == HONSettingsCellTypeVersion) {
			[cell hideChevron];
			cell.backgroundView = nil;
			
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 3.0, 320.0, 12.0)];
			label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:12];
			label.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
			label.backgroundColor = [UIColor clearColor];
			label.textAlignment = NSTextAlignmentCenter;
			label.text = [@"Version " stringByAppendingString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
			[cell.contentView addSubview:label];
			
#if __APPSTORE_BUILD__ != 1
			label.text = [label.text stringByAppendingFormat:@" (b%d)", [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] intValue]];
#endif
		}
	}
	
	[cell setSize:[tableView rectForRowAtIndexPath:indexPath].size];
	[cell setIndexPath:indexPath];
	[cell setSelectionStyle:(indexPath.section == 1 && (indexPath.row == HONSettingsCellTypeShareClub || indexPath.row == HONSettingsCellTypeNotifications || indexPath.row == HONSettingsCellTypeVersion)) ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleGray];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.section == 1 && indexPath.row == HONSettingsCellTypeVersion) ? 20.0 : 44.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.section == 1 && (indexPath.row == HONSettingsCellTypeNotifications || indexPath.row == HONSettingsCellTypeVersion)) ? nil : indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
//	HONSettingsViewCell *cell = (HONSettingsViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	
	if (indexPath.section == 0) {
		[[[UIAlertView alloc] initWithTitle:nil
									message:@"Location switching not allowed during beta."
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
	
	} else {
		if (indexPath.row == HONSettingsCellTypeSearch) {
			//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Settings Tab - User Search"];
			
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																	 delegate:self
															cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
													   destructiveButtonTitle:nil
															otherButtonTitles:@"By Phone Number", @"By Username", nil];
			[actionSheet setTag:0];
			[actionSheet showInView:self.view];
		
		} else if (indexPath.row == HONSettingsCellTypeSupport) {
			//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Settings Tab - Support"];
			
			if ([MFMailComposeViewController canSendMail]) {
				MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
				mailComposeViewController.mailComposeDelegate = self;
				[mailComposeViewController.view setTag:HONSettingsMailComposerTypeReportAbuse];
				[mailComposeViewController setToRecipients:[NSArray arrayWithObject:@"support@getselfieclub.com"]];
				[mailComposeViewController setSubject: NSLocalizedString(@"report_abuse", @"Report Abuse / Bug")];
				[mailComposeViewController setMessageBody:@"" isHTML:NO];
				
				[self presentViewController:mailComposeViewController animated:YES completion:^(void) {}];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"email_error", @"Email Error")
											message:NSLocalizedString(@"email_errormsg", @"Cannot send email from this device!")
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
			}
			
		} else if (indexPath.row == HONSettingsCellTypeTermsOfService) {
			//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Settings Tab - Terms of Service"];
			
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONTermsViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			
		} else if (indexPath.row == HONSettingsCellTypeShareClub) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"captions"			: @{@"instagram"	: [NSString stringWithFormat:[HONAppDelegate instagramShareMessage], [[HONAppDelegate infoForUser] objectForKey:@"username"]],
																															@"twitter"		: [NSString stringWithFormat:[HONAppDelegate twitterShareComment], [[HONAppDelegate infoForUser] objectForKey:@"username"]],
																															@"sms"			: [NSString stringWithFormat:[HONAppDelegate smsShareComment], [[HONAppDelegate infoForUser] objectForKey:@"username"]],
																															@"email"		: @[[[HONAppDelegate emailShareComment] objectForKey:@"subject"], [NSString stringWithFormat:[[HONAppDelegate emailShareComment] objectForKey:@"body"], [[HONAppDelegate infoForUser] objectForKey:@"username"]]],//  [[[[HONAppDelegate emailShareComment] objectForKey:@"subject"] stringByAppendingString:@"|"] stringByAppendingString:[NSString stringWithFormat:[[HONAppDelegate emailShareComment] objectForKey:@"body"], [[HONAppDelegate infoForUser] objectForKey:@"username"]]],
																															@"clipboard"	: [NSString stringWithFormat:[HONAppDelegate smsShareComment], [[HONAppDelegate infoForUser] objectForKey:@"username"]]},
																									@"image"			: ([[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"] rangeOfString:@"defaultAvatar"].location == NSNotFound) ? [HONAppDelegate avatarImage] : [[HONImageBroker sharedInstance] shareTemplateImageForType:HONImageBrokerShareTemplateTypeDefault],
																									@"url"				: [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"],
																									@"club"				: [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:nil],
																									@"mp_event"			: @"User Profile - Share",
																									@"view_controller"	: self}];
		}
		
		
	//	[NSString stringWithFormat:@"https://itunes.apple.com/app/id%@?mt=8&uo=4", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]

	//	} else if (indexPath.row == HONSettingsCellTypePrivacyPolicy) {
	//		[[HONAnalyticsParams sharedInstance] trackEvent:@"Settings Tab - Privacy Policy"];
	//		
	//		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONPrivacyPolicyViewController alloc] init]];
	//		[navigationController setNavigationBarHidden:YES];
	//		[self presentViewController:navigationController animated:YES completion:nil];
			
	//	} else if (indexPath.row == HONSettingsCellTypeRateThisApp) {
	//		[[HONAnalyticsParams sharedInstance] trackEvent:@"Settings Tab - Rate App"];
	//		
	//		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms://itunes.apple.com/app/id%@?mt=8&uo=4", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]]];
	//		
	//	} else if (indexPath.row == HONSettingsCellTypeNetworkStatus) {
	//		[[HONAnalyticsParams sharedInstance] trackEvent:@"Settings Tab - Network Status"];
	//		
	//		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONNetworkStatusViewController alloc] init]];
	//		[navigationController setNavigationBarHidden:YES];
	//		[self presentViewController:navigationController animated:YES completion:nil];
	//		
	//	} else if (indexPath.row == HONSettingsCellTypeLogout) {
	//		[[HONAnalyticsParams sharedInstance] trackEvent:@"Settings Tab - Logout"];
	//		
	//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"are_you_sure", @"Are you sure?")
	//															message:@""
	//														   delegate:self
	//												  cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
	//												  otherButtonTitles:NSLocalizedString(@"settings_logout", nil), nil];
	//		[alertView setTag:HONSettingsAlertTypeLogout];
	//		[alertView show];
	//	}
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.alpha = 1.0;
//	cell.alpha = 0.0;
//	[UIView animateKeyframesWithDuration:0.125 delay:0.050 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
//		cell.alpha = 1.0;
//	} completion:^(BOOL finished) {
//	}];
}


#pragma mark - MessageCompose Delegates
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
//	NSString *mpAction = @"";
//	switch (result) {
//		case MessageComposeResultCancelled:
//			mpAction = @"Canceled";
//			break;
//			
//		case MessageComposeResultSent:
//			mpAction = @"Sent";
//			break;
//			
//		case MessageComposeResultFailed:
//			mpAction = @"Failed";
//			break;
//			
//		default:
//			mpAction = @"Not Sent";
//			break;
//	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - MailCompose Delegates
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {

//	NSString *mpEvent = @"";
//	if (controller.view.tag == HONSettingsMailComposerTypeChangeEmail) {
//		mpEvent = @"Change Email";
//		
//	} else if (controller.view.tag == HONSettingsMailComposerTypeReportAbuse) {
//		mpEvent = NSLocalizedString(@"report_abuse", @"Report Abuse / Bug");
//	}
//	
//	NSString *mpAction = @"";
//	switch (result) {
//		case MFMailComposeResultCancelled:
//			mpAction = @"Canceled";
//			break;
//			
//		case MFMailComposeResultFailed:
//			mpAction = @"Failed";
//			break;
//			
//		case MFMailComposeResultSaved:
//			mpAction = @"Saved";
//			break;
//			
//		case MFMailComposeResultSent:
//			mpAction = @"Sent";
//			break;
//			
//		default:
//			mpAction = @"Not Sent";
//			break;
//	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - AlertView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == HONSettingsAlertTypeNotifications) {
		//[[HONAnalyticsReporter sharedInstance] trackEvent:[NSString stringWithFormat:@"Settings Tab - Toggle Notifications %@ Alert", (!_notificationSwitch.on) ? @"On" : @"Off"]
//										 withProperties:@{@"btn"	: (buttonIndex == 0) ? @"Cancel" : @"Confirm"}];
		
		if (buttonIndex == 0)
			_notificationSwitch.on = !_notificationSwitch.on;
		
		else {
			[[HONAPICaller sharedInstance] togglePushNotificationsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] areEnabled:_notificationSwitch.on completion:^(NSDictionary *result) {
				if ([result objectForKey:@"id"] != [NSNull null])
					[HONAppDelegate writeUserInfo:result];
			}];
		}
		
	} else if (alertView.tag == HONSettingsAlertTypeDeactivate) {
//		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Settings Tab - Deactivate Alert " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]];
		
		if (buttonIndex == 1) {			
			[[HONAPICaller sharedInstance] deactivateUserWithCompletion:^(NSObject *result) {
//				[HONAppDelegate resetTotals];
				[[HONStateMitigator sharedInstance] resetAllTotalCounters];
				
				[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"is_deactivated"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
				KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
				[keychain setObject:@"" forKey:CFBridgingRelease(kSecAttrAccount)];
				
				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
					[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_FIRST_RUN" object:nil];
				}];
			}];
		}
	
	} else if (alertView.tag == HONSettingsAlertTypeDeleteChallenges) {
//		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Settings Tab - Remove Content Alert " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]];
		
		if (buttonIndex == 1) {
			[[HONAPICaller sharedInstance] removeAllChallengesForUserWithCompletion:^(NSObject *result){
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_PROFILE" object:nil];
			}];
		}
	} else if (alertView.tag == HONSettingsAlertTypeLogout) {
//		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Settings Tab - Logout Alert " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]];
		
		if (buttonIndex == 1) {
			KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
			[keychain setObject:@"" forKey:CFBridgingRelease(kSecAttrAccount)];
			
			[self dismissViewControllerAnimated:NO completion:^(void) {
				[[[UIApplication sharedApplication] delegate].window.rootViewController.navigationController popToRootViewControllerAnimated:NO];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_TAB" object:@(0)];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_FIRST_RUN" object:nil];
//				[HONAppDelegate resetTotals];
			}];
			
//			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:^(void) {
//				[[NSNotificationCenter defaultCenter] postNotificationName:@"CHANGE_TAB" object:@(0)];
//				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_FIRST_RUN" object:nil];
//			}];
		}
	}
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Settings Tab - User Search Action Sheet"
//										 withProperties:@{@"btn"	: (buttonIndex == 0) ? @"phone" : (buttonIndex == 1) ? @"username" : @"cancel"}];
		
		if (buttonIndex == 0) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONContactsSearchViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		
		} else if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUsernameSearchViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	}
}

@end
