//
//  HONProfileViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "KikAPI.h"
#import "MBProgressHUD.h"

#import "HONProfileViewController.h"
#import "HONSettingsViewController.h"
#import "HONUserProfileViewCell.h"
#import "HONPastChallengerViewCell.h"
#import "HONHeaderView.h"
#import "HONImagePickerViewController.h"
#import "HONSearchBarHeaderView.h"
#import "HONContactUserVO.h"
#import "HONImagePickerViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONAddContactsViewController.h"
#import "HONAddContactViewCell.h"
#import "HONTimelineViewController.h"
#import "HONVerifyViewController.h"
#import "HONInvitePopularViewController.h"
#import "HONInviteCelebViewController.h"

@interface HONProfileViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, HONUserProfileViewCellDelegate>
@property (nonatomic, strong) NSMutableArray *recentOpponents;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (strong, nonatomic) FBRequestConnection *requestConnection;
@property (nonatomic) BOOL hasRefreshed;
@end

@implementation HONProfileViewController

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor whiteColor];
		
		_recentOpponents = [NSMutableArray array];
		_friends = [NSMutableArray array];
		_contacts = [NSMutableArray array];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshProfileTab:) name:@"REFRESH_PROFILE_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshProfileTab:) name:@"REFRESH_ALL_TABS" object:nil];
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
- (void)_retrievePastUsers {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 4], @"action",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPISearch, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPISearch parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
		} else {
			
			NSArray *parsedUsers = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], parsedUsers);
			
			int cnt = 0;
			for (NSDictionary *serverList in parsedUsers) {
				HONUserVO *vo = [HONUserVO userWithDictionary:serverList];
				
				if (vo != nil)
					[_recentOpponents addObject:vo];
				
				cnt++;
				if (cnt == kRecentOpponentsDisplayTotal)
					break;
			}
						
			[_tableView reloadData];
			
			if (_progressHUD != nil) {
				if ([_recentOpponents count] == 0) {
					_progressHUD.minShowTime = kHUDTime;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
					_progressHUD.labelText = NSLocalizedString(@"hud_noResults", nil);
					[_progressHUD show:NO];
					[_progressHUD hide:YES afterDelay:kHUDErrorTime];
					_progressHUD = nil;
					
				} else {
					[_progressHUD hide:YES];
					_progressHUD = nil;
				}
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPISearch, [error localizedDescription]);
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}

- (void)_callFB {
	FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
	FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:@"/me/friends"];
	[newConnection addRequest:request completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
		if (self.requestConnection && connection != self.requestConnection)
			return;
		
		self.requestConnection = nil;
		
		if (error == nil) {
			int cnt = 0;
			NSMutableArray *friends = [NSMutableArray array];
			for (NSDictionary *dict in [(NSDictionary *)result objectForKey:@"data"]) {
				[friends addObject:[dict objectForKey:@"id"]];
				
				cnt++;
				if (cnt == 50)
					break;
			}
			
			//FBFrictionlessRecipientCache *friendCache = [[FBFrictionlessRecipientCache alloc] init];
			//[friendCache prefetchAndCacheForSession:nil];
			
			//NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[friends componentsJoinedByString:@","], @"to", nil];
			NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1554917948", @"to", nil];
			[FBWebDialogs presentRequestsDialogModallyWithSession:nil message:@"Come snap @ me in Volley!" title:nil parameters:params handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
				if (error)
					NSLog(@"Error sending request.");
				
			 	else
					NSLog((result == FBWebDialogResultDialogNotCompleted) ? @"User canceled request." : @"Request Sent.");
			}];
		}
		
		NSLog(@"%@", (error) ? error.localizedDescription : (NSDictionary *)result);
	}];
	
	[self.requestConnection cancel];
	self.requestConnection = newConnection;
	[newConnection start];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	_hasRefreshed = NO;
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h@2x" : @"mainBG"]];
	bgImageView.frame = self.view.bounds;
	[self.view addSubview:bgImageView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kNavBarHeaderHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (20.0 + kNavBarHeaderHeight + kTabSize.height)) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor colorWithWhite:0.900 alpha:1.0]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 70.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:[NSString stringWithFormat:@"@%@", [[HONAppDelegate infoForUser] objectForKey:@"name"]]];
	[[_headerView refreshButton] addTarget:self action:@selector(_goRefresh) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_headerView];
	
	UIButton *createChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	createChallengeButton.frame = CGRectMake(270.0, 0.0, 50.0, 44.0);
	[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"createChallengeButton_nonActive"] forState:UIControlStateNormal];
	[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"createChallengeButton_Active"] forState:UIControlStateHighlighted];
	[createChallengeButton addTarget:self action:@selector(_goCreateChallenge) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:createChallengeButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goRefresh {
	[[Mixpanel sharedInstance] track:@"Profile - Refresh"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_hasRefreshed = YES;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_PROFILE_TAB" object:nil];
}

- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:@"Profile - Create Snap"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}


#pragma mark - Notifications
- (void)_refreshProfileTab:(NSNotification *)notification {
	[_tableView setContentOffset:CGPointZero animated:YES];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 5], @"action",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			 
		} else {
			NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			if ([userResult objectForKey:@"id"] != [NSNull null])
				[HONAppDelegate writeUserInfo:userResult];
			
			[(HONUserProfileViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] updateCell];
			[_headerView setTitle:[NSString stringWithFormat:@"@%@", [[HONAppDelegate infoForUser] objectForKey:@"name"]]];
			
			_recentOpponents = [NSMutableArray array];
			_friends = [NSMutableArray array];
			_contacts = [NSMutableArray array];
			
			[self _retrievePastUsers];
			_friends = [HONAppDelegate friendsList];
		}
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}


#pragma mark - UserProfileCell Delegates
- (void)userProfileViewCellShowSettings:(HONUserProfileViewCell *)cell {
	[[Mixpanel sharedInstance] track:@"Profile - Settings"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSettingsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)userProfileViewCellTakeNewAvatar:(HONUserProfileViewCell *)cell {
	[[Mixpanel sharedInstance] track:@"Profile - Take New Avatar"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return (1);
		
	} else if (section == 1) {
		return ([_recentOpponents count]);
		
	} else if (section == 2) {
		return ([_friends count]);
		
	} else {
		return (4);
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (4);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIImageView *headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableHeaderBackground"]];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(11.0, 6.0, 310.0, 20.0)];
	label.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:15];
	label.textColor = [HONAppDelegate honGreenTextColor];
	label.backgroundColor = [UIColor clearColor];
	[headerImageView addSubview:label];
	
	if (section == 0) {
		return (nil);
		
	} else if (section == 1) {
		label.text = @"Recent";
		
	} else if (section == 2) {
		label.text = [NSString stringWithFormat:@"Friends (%d)", [_friends count]];
		
	} else {
		label.text = @"Invite friends to Volley";
	}
	
	return (headerImageView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		HONUserProfileViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil)
			cell = [[HONUserProfileViewCell alloc] init];
		
		HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
														   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]], @"id",
														   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"points",
														   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue]], @"votes",
														   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue]], @"pokes",
														   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"pics",
														   [[HONAppDelegate infoForUser] objectForKey:@"username"], @"username",
														   [[HONAppDelegate infoForUser] objectForKey:@"fb_id"], @"fb_id",
														   [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"], @"avatar_url", nil]];
		
		cell.delegate = self;
		[cell setUserVO:userVO];
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		
		return (cell);
	
	} else if (indexPath.section == 1) {
		HONPastChallengerViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil)
			cell = [[HONPastChallengerViewCell alloc] initAsRandomUser:NO];
		
		cell.userVO = (HONUserVO *)[_recentOpponents objectAtIndex:indexPath.row];
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		
		return (cell);
		
	} else if (indexPath.section == 2) {
		HONPastChallengerViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil)
			cell = [[HONPastChallengerViewCell alloc] initAsRandomUser:NO];
		
		cell.userVO = (HONUserVO *)[_friends objectAtIndex:indexPath.row];
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		
		return (cell);
		
	} else {
		HONPastChallengerViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil)
			cell = [[HONPastChallengerViewCell alloc] initAsRandomUser:YES];
		
		if (indexPath.row == 0) {
			HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]], @"id",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"points",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue]], @"votes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue]], @"pokes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"pics",
															   @"Verify my Volley account", @"username",
															   @"", @"fb_id",
															   @"", @"avatar_url", nil]];
			cell.userVO = userVO;
		
		} else if (indexPath.row == 1) {
			HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]], @"id",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"points",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue]], @"votes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue]], @"pokes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"pics",
															   @"Find friends who volley", @"username",
															   @"", @"fb_id",
															   @"", @"avatar_url", nil]];
			cell.userVO = userVO;
			
		} else if (indexPath.row == 2) {
			HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]], @"id",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"points",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue]], @"votes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue]], @"pokes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"pics",
															   @"Find cool people who volley", @"username",
															   @"", @"fb_id",
															   @"", @"avatar_url", nil]];
			cell.userVO = userVO;
			
		} else if (indexPath.row == 3) {
			HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]], @"id",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"points",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue]], @"votes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue]], @"pokes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"pics",
															   @"Invite cool people who volley", @"username",
															   @"", @"fb_id",
															   @"", @"avatar_url", nil]];
			cell.userVO = userVO;
		}
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
			
		return (cell);
	}
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0)
		return (210.0);
	
	else
		return (kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return ((section == 0) ? 0.0 : kOrthodoxTableHeaderHeight);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.section == 0) ? nil : indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	if (indexPath.section == 1) {
		HONUserVO *vo = (HONUserVO *)[_recentOpponents objectAtIndex:indexPath.row];
		[[Mixpanel sharedInstance] track:@"Profile - Recent Opponent Timeline"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username], @"opponent", nil]];
		
		[self.navigationController pushViewController:[[HONTimelineViewController alloc] initWithUsername:vo.username] animated:YES];
		
	} else if (indexPath.section == 2) {
		HONUserVO *vo = (HONUserVO *)[_friends objectAtIndex:indexPath.row];
		[[Mixpanel sharedInstance] track:@"Profile - Friend Timeline"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username], @"friend", nil]];
		
		[self.navigationController pushViewController:[[HONTimelineViewController alloc] initWithUsername:vo.username] animated:YES];
	
	} else if (indexPath.section == 3) {
		if (indexPath.row == 0) {
			[[Mixpanel sharedInstance] track:@"Profile - Verify"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																	 delegate:self
															cancelButtonTitle:@"Cancel"
													   destructiveButtonTitle:nil
															otherButtonTitles:@"Use mobile #", @"Use email address", nil];
			actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
			[actionSheet setTag:0];
			[actionSheet showInView:[HONAppDelegate appTabBarController].view];
		
		} else if (indexPath.row == 1) {
			[[Mixpanel sharedInstance] track:@"Profile - Add Contacts"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			
		} else if (indexPath.row == 2) {
			[[Mixpanel sharedInstance] track:@"Profile - Popular"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInvitePopularViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		
		} else if (indexPath.row == 3) {
			[[Mixpanel sharedInstance] track:@"Profile - Invite Celeb"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteCelebViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	}
}


#pragma mark - ActionSheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:{
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONVerifyViewController alloc] initAsEmailVerify:NO]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			break;}
			
		case 1:{
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONVerifyViewController alloc] initAsEmailVerify:YES]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			break;}
	}
}


@end
