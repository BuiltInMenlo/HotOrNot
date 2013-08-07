//
//  HONProfileViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <MessageUI/MFMessageComposeViewController.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "KikAPI.h"
#import "MBProgressHUD.h"

#import "HONProfileViewController.h"
#import "HONSettingsViewController.h"
#import "HONUserProfileViewCell.h"
#import "HONPastChallengerViewCell.h"
#import "HONRefreshButtonView.h"
#import "HONImagePickerViewController.h"
#import "HONSearchBarHeaderView.h"
#import "HONContactUserVO.h"
#import "HONImagePickerViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONAddContactsViewController.h"
#import "HONAddContactViewCell.h"
#import "HONTimelineViewController.h"
#import "HONVerifyViewController.h"
#import "HONPopularViewController.h"
#import "HONInviteCelebViewController.h"
#import "HONImagingDepictor.h"

@interface HONProfileViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, HONUserProfileViewCellDelegate>
@property (nonatomic, strong) NSMutableArray *recentOpponents;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HONRefreshButtonView *refreshButtonView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (strong, nonatomic) FBRequestConnection *requestConnection;
@property (nonatomic) BOOL hasRefreshed;
@end

@implementation HONProfileViewController

- (id)init {
	if ((self = [super init])) {
		
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
//	[self.view addSubview:bgImageView];
	
	UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
	moreButton.frame = CGRectMake(0.0, 0.0, 64.0, 44.0);
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreHeaderButton_nonActive"] forState:UIControlStateNormal];
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreHeaderButton_Active"] forState:UIControlStateHighlighted];
	[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
	
	_refreshButtonView = [[HONRefreshButtonView alloc] initWithTarget:self action:@selector(_goRefresh)];
	self.navigationController.navigationBar.topItem.title = [NSString stringWithFormat:@"@%@", [[HONAppDelegate infoForUser] objectForKey:@"name"]];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_refreshButtonView];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (20.0 + kTabSize.height)) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
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
	[HONAppDelegate offsetSubviewsForIOS7:self.view];
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

- (void)_goMore {
	[[Mixpanel sharedInstance] track:@"Profile - More Shelf"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Change avatar", @"Settings", @"Send volley", @"Find friends", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	[actionSheet setTag:0];
	[actionSheet showInView:[HONAppDelegate appTabBarController].view];
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
			self.navigationController.navigationBar.topItem.title = [NSString stringWithFormat:@"@%@", [[HONAppDelegate infoForUser] objectForKey:@"name"]];
			
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
- (void)userProfileViewCellNewSnap:(HONUserProfileViewCell *)cell {
	[self _goCreateChallenge];
}

- (void)userProfileViewCellShowSettings:(HONUserProfileViewCell *)cell {
	[[Mixpanel sharedInstance] track:@"Profile - Settings"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSettingsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)userProfileViewCellFindFriends:(HONUserProfileViewCell *)cell {
	[[Mixpanel sharedInstance] track:@"Profile - Find Friends Button"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
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
		
	} else if (section == 3) {
		return (4);
		
	} else {
		return (3);
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (5);
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
		label.text = [NSString stringWithFormat:@"Recent (%d)", [_recentOpponents count]];
		
	} else if (section == 2) {
		label.text = [NSString stringWithFormat:@"Friends (%d)", [_friends count]];
		
	} else if (section == 3) {
		label.text = @"Find & invite friends";
	
	} else {
		label.text = @"Verify my account";
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
														   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"age"] intValue]], @"age",
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
		
	} else if (indexPath.section == 3) {
		if (indexPath.row == 0) {
			HONPastChallengerViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
			
			if (cell == nil)
				cell = [[HONPastChallengerViewCell alloc] initAsRandomUser:YES];
			
			HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]], @"id",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"points",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue]], @"votes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue]], @"pokes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"pics",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"age"] intValue]], @"age",
															   @"Find friends who volley", @"username",
															   @"", @"fb_id",
															   @"", @"avatar_url", nil]];
			cell.userVO = userVO;
			[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
			
			return (cell);
			
		} else if (indexPath.row == 1) {
			HONPastChallengerViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
			
			if (cell == nil)
				cell = [[HONPastChallengerViewCell alloc] initAsRandomUser:YES];
			
			HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]], @"id",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"points",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue]], @"votes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue]], @"pokes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"pics",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"age"] intValue]], @"age",
															   @"Find cool people who volley", @"username",
															   @"", @"fb_id",
															   @"", @"avatar_url", nil]];
			cell.userVO = userVO;
			[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
			
			return (cell);
			
		} else if (indexPath.row == 2) {
			HONPastChallengerViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
			
			if (cell == nil)
				cell = [[HONPastChallengerViewCell alloc] initAsRandomUser:YES];
			
			HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]], @"id",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"points",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue]], @"votes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue]], @"pokes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"pics",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"age"] intValue]], @"age",
															   @"Promote on Instagram", @"username",
															   @"", @"fb_id",
															   @"", @"avatar_url", nil]];
			cell.userVO = userVO;
			[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
			
			return (cell);
			
		} else {
			HONPastChallengerViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
			
			if (cell == nil)
				cell = [[HONPastChallengerViewCell alloc] initAsRandomUser:YES];
			
			HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]], @"id",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"points",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue]], @"votes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue]], @"pokes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"pics",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"age"] intValue]], @"age",
															   @"Promote on Kik", @"username",
															   @"", @"fb_id",
															   @"", @"avatar_url", nil]];
			cell.userVO = userVO;
			[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
			
			return (cell);
		}
	
	} else {
		if (indexPath.row == 0) {
			HONPastChallengerViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
			
			if (cell == nil)
				cell = [[HONPastChallengerViewCell alloc] initAsRandomUser:YES];
			
			
			HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]], @"id",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"points",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue]], @"votes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue]], @"pokes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"pics",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"age"] intValue]], @"age",
															   @"Send SMS", @"username",
															   @"", @"fb_id",
															   @"", @"avatar_url", nil]];
			cell.userVO = userVO;
			[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
			
			return (cell);
			
		} else if (indexPath.row == 1) {
			HONPastChallengerViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
			
			if (cell == nil)
				cell = [[HONPastChallengerViewCell alloc] initAsRandomUser:YES];
			
			
			HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]], @"id",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"points",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue]], @"votes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue]], @"pokes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"pics",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"age"] intValue]], @"age",
															   @"Send Mobile #", @"username",
															   @"", @"fb_id",
															   @"", @"avatar_url", nil]];
			cell.userVO = userVO;
			[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
			
			return (cell);
			
		} else {
			HONPastChallengerViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
			
			if (cell == nil)
				cell = [[HONPastChallengerViewCell alloc] initAsRandomUser:YES];
			
			
			HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]], @"id",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"points",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue]], @"votes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue]], @"pokes",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"pics"] intValue]], @"pics",
															   [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"age"] intValue]], @"age",
															   @"Send Email", @"username",
															   @"", @"fb_id",
															   @"", @"avatar_url", nil]];
			cell.userVO = userVO;
			[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
			
			return (cell);
		}
	}
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0)
		return (237.0);
	
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
			[[Mixpanel sharedInstance] track:@"Profile - Add Contacts"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			
		} else if (indexPath.row == 1) {
			[[Mixpanel sharedInstance] track:@"Profile - Popular"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONPopularViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			
		} else if (indexPath.row == 2) {
			[[Mixpanel sharedInstance] track:@"Profile - Promote Instagram"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			UIImage *image = [HONImagingDepictor prepImageForSharing:[UIImage imageNamed:@"share_template"] avatarImage:[HONAppDelegate avatarImage] username:[[HONAppDelegate infoForUser] objectForKey:@"name"]];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SEND_TO_INSTAGRAM" object:[NSDictionary dictionaryWithObjectsAndKeys:
																									[HONAppDelegate instagramShareComment], @"caption",
																									image, @"image", nil]];
			
		} else if (indexPath.row == 3) {
			[[Mixpanel sharedInstance] track:@"Profile - Promote Kik"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			UIImage *shareImage = [HONImagingDepictor prepImageForSharing:[UIImage imageNamed:@"share_template"] avatarImage:[HONAppDelegate avatarImage] username:[[HONAppDelegate infoForUser] objectForKey:@"name"]];
			NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/volley_test.jpg"];
			[UIImageJPEGRepresentation(shareImage, 1.0f) writeToFile:savePath atomically:YES];
			
			KikAPIMessage *myMessage = [KikAPIMessage message];
			myMessage.title = [HONAppDelegate instagramShareComment];
			myMessage.description = @"";
			myMessage.previewImage = UIImageJPEGRepresentation(shareImage, 1.0f);
			myMessage.filePath = savePath;
			myMessage.iphoneURIs = [NSArray arrayWithObjects:@"volley://", nil];
			myMessage.genericURIs = [NSArray arrayWithObjects:@"http://taps.io/MTA5MDAz", nil];
			
			[KikAPIClient sendMessage:myMessage];
			
		}
	
	} else {
		if (indexPath.row == 0) {
			[[Mixpanel sharedInstance] track:@"Profile - Verify SMS"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			if ([MFMessageComposeViewController canSendText]) {
				MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
				messageComposeViewController.messageComposeDelegate = self;
				messageComposeViewController.recipients = [NSArray arrayWithObject:[HONAppDelegate twilioSMS]];
				messageComposeViewController.body = [NSString stringWithFormat:@"Verify my mobile phone # with my Volley account! verification code: %@", [[HONAppDelegate infoForUser] objectForKey:@"sms_code"]];
				[self presentViewController:messageComposeViewController animated:YES completion:^(void) {}];
				
			} else {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SMS Not Avaiable"
																	message:@"We use SMS to verify Volley account and your device currently does not support this feature!"
																   delegate:nil
														  cancelButtonTitle:@"OK"
														  otherButtonTitles:nil];
				[alertView show];
			}
			
		} else if (indexPath.row == 1) {
			[[Mixpanel sharedInstance] track:@"Profile - Verify Mobile"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONVerifyViewController alloc] initAsEmailVerify:NO]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			
		} else {
			[[Mixpanel sharedInstance] track:@"Profile - Verify Email"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONVerifyViewController alloc] initAsEmailVerify:YES]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	}
}


#pragma mark - ActionSheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		switch (buttonIndex) {
			case 0:{
				[[Mixpanel sharedInstance] track:@"Profile - More Self Change Avatar"
									  properties:[NSDictionary dictionaryWithObjectsAndKeys:
												  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
				[navigationController setNavigationBarHidden:YES];
				[self presentViewController:navigationController animated:NO completion:nil];
				
				break;}
				
			case 1:{
				[[Mixpanel sharedInstance] track:@"Profile - More Self Settings"
									  properties:[NSDictionary dictionaryWithObjectsAndKeys:
												  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSettingsViewController alloc] init]];
				[navigationController setNavigationBarHidden:YES];
				[self presentViewController:navigationController animated:YES completion:nil];
				break;}
				
			case 2:{
				[[Mixpanel sharedInstance] track:@"Profile - More Self Status Update"
									  properties:[NSDictionary dictionaryWithObjectsAndKeys:
												  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] init]];
				[navigationController setNavigationBarHidden:YES];
				[self presentViewController:navigationController animated:NO completion:nil];
				break;}
				
			case 3:{
				[[Mixpanel sharedInstance] track:@"Profile - More Self Add Contacts"
									  properties:[NSDictionary dictionaryWithObjectsAndKeys:
												  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
				[navigationController setNavigationBarHidden:YES];
				[self presentViewController:navigationController animated:YES completion:nil];
				break;}
		}
	}
}



#pragma mark - MessageCompose Delegates
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	//NSLog(@"messageComposeViewController:didFinishWithResult:[%d]", result);
	
	[self dismissViewControllerAnimated:YES completion:^(void) {
		if (result == MessageComposeResultSent) {
			[[Mixpanel sharedInstance] track:@"Profile - Verfiy SMS Sent"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		} else if (result == MessageComposeResultFailed) {
			[[Mixpanel sharedInstance] track:@"Profile - Verfiy SMS Failed"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		} else if (result == MessageComposeResultCancelled) {
			[[Mixpanel sharedInstance] track:@"Profile - Verfiy SMS Canceled"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		}
	}];
}


@end
