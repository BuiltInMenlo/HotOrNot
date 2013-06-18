//
//  HONChallengesViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"

#import "HONAppDelegate.h"
#import "HONChallengesViewController.h"
#import "HONChallengeViewCell.h"
#import "HONEmptyChallengeViewCell.h"
#import "HONChallengeVO.h"
#import "HONImagePickerViewController.h"
#import "HONTimelineViewController.h"
#import "HONHeaderView.h"
#import "HONSearchBarHeaderView.h"
#import "HONInviteNetworkViewController.h"
#import "HONVerifyMobileViewController.h"


const NSInteger kOlderThresholdSeconds = (60 * 60 * 24) * 2;;


@interface HONChallengesViewController() <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *recentChallenges;
@property(nonatomic, strong) NSMutableArray *olderChallenges;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@property(nonatomic, strong) NSDate *lastDate;
@property(nonatomic, strong) HONChallengeVO *challengeVO;
@property(nonatomic, strong) NSIndexPath *idxPath;
@property(nonatomic, strong) HONHeaderView *headerView;
@property(nonatomic, strong) NSMutableArray *friends;
@property(nonatomic, strong) UIButton *publicButton;
@property(nonatomic, strong) UIButton *privateButton;

@property(nonatomic) int blockCounter;
@property (nonatomic, strong) UIImageView *togglePrivateImageView;
@property (nonatomic) BOOL isPrivate;
@end

@implementation HONChallengesViewController

- (id)init {
	if ((self = [super init])) {
		_recentChallenges = [NSMutableArray array];
		_olderChallenges = [NSMutableArray array];
		_blockCounter = 0;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_acceptChallenge:) name:@"ACCEPT_CHALLENGE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_nextChallengeBlock:) name:@"NEXT_CHALLENGE_BLOCK" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshChallengesTab:) name:@"REFRESH_CHALLENGES_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshChallengesTab:) name:@"REFRESH_ALL_TABS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showFindFriends:) name:@"SHOW_FIND_FRIENDS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tabsDropped:) name:@"TABS_DROPPED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tabsRaised:) name:@"TABS_RAISED" object:nil];
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
- (void)_retrieveUser {
	if ([HONAppDelegate infoForUser]) {
		
		AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
		NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSString stringWithFormat:@"%d", 5], @"action",
										[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
										nil];
		
		[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSError *error = nil;
			if (error != nil) {
				VolleyJSONLog(@"AFNetworking [-]  HONChallengesViewController - Failed to parse job list JSON: %@", [error localizedFailureReason]);
				
				[_headerView toggleRefresh:NO];
				if (_progressHUD != nil) {
					[_progressHUD hide:YES];
					_progressHUD = nil;
				}
				
			} else {
				NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
				//VolleyJSONLog(@"AFNetworking [-]  HONChallengesViewController: %@", userResult);
				
				if ([userResult objectForKey:@"id"] != [NSNull null])
					[HONAppDelegate writeUserInfo:userResult];
				
				[_tableView reloadData];
				
				[_headerView toggleRefresh:NO];
				if (_progressHUD != nil) {
					[_progressHUD hide:YES];
					_progressHUD = nil;
				}
			}
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			VolleyJSONLog(@"AFNetworking [-]  ChallengesViewController %@", [error localizedDescription]);
			
			[_headerView toggleRefresh:NO];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
		}];
	}
}

- (void)_retrieveChallenges {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", (_isPrivate) ? 8 : 2], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							nil];
	
	[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-]  HONChallengesViewController - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			[_headerView toggleRefresh:NO];
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
		} else {
			NSArray *unsortedChallenges = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			NSArray *parsedLists = [NSMutableArray arrayWithArray:[unsortedChallenges sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"updated" ascending:NO]]]];
			//VolleyJSONLog(@"AFNetworking [-]  HONChallengesViewController: %@", unsortedChallenges);
			
			_recentChallenges = [NSMutableArray array];
			_olderChallenges = [NSMutableArray array];
			for (NSDictionary *serverList in parsedLists) {
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
				
				if (vo != nil) {
					if ([[NSDate date] timeIntervalSinceDate:vo.updatedDate] < kOlderThresholdSeconds)
						[_recentChallenges addObject:vo];
					
					else
						[_olderChallenges addObject:vo];
				}
			}

			_lastDate = ((HONChallengeVO *)[_olderChallenges lastObject]).addedDate;
			[_tableView reloadData];
			
			[_headerView toggleRefresh:NO];
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-]  ChallengesViewController %@", [error localizedDescription]);
		
		[_headerView toggleRefresh:NO];
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}

- (void)_retrieveNextChallengeBlock {
	NSString *prevIDs = @"";
	for (HONChallengeVO *vo in _recentChallenges)
		prevIDs = [prevIDs stringByAppendingString:[NSString stringWithFormat:@"%d|", ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == vo.creatorID) ? vo.challengerID : vo.creatorID]];
	
	
	for (HONChallengeVO *vo in _olderChallenges)
		prevIDs = [prevIDs stringByAppendingString:[NSString stringWithFormat:@"%d|", ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == vo.creatorID) ? vo.challengerID : vo.creatorID]];
	
	
	//NSLog(@"NEXT\n%@\n%@", [prevIDs substringToIndex:[prevIDs length] - 1], _lastDate);
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 12], @"action",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									[prevIDs substringToIndex:[prevIDs length] - 1], @"prevIDs",
									_lastDate, @"datetime",
									nil];
	
	[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-]  HONChallengesViewController - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			[_headerView toggleRefresh:NO];
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
		} else {
			NSArray *unsortedChallenges = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			NSArray *parsedLists = [NSMutableArray arrayWithArray:[unsortedChallenges sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"updated" ascending:NO]]]];
			//VolleyJSONLog(@"AFNetworking [-]  HONChallengesViewController: %@", unsortedChallenges);
			
			//[_challenges removeLastObject];
			for (NSDictionary *serverList in parsedLists) {
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
				
				if (vo != nil) {
					if ([[NSDate date] timeIntervalSinceDate:vo.updatedDate] < 172800)
						[_recentChallenges addObject:vo];
					
					else
						[_olderChallenges addObject:vo];
				}
			}
			
			_lastDate = ((HONChallengeVO *)[_olderChallenges lastObject]).addedDate;
			[_tableView reloadData];
			
			HONChallengeViewCell *cell = (HONChallengeViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:([_olderChallenges count] - 1) inSection:0]];
			[cell toggleLoadMore:([parsedLists count] > 0)];
			
			[_headerView toggleRefresh:NO];
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-]  ChallengesViewController %@", [error localizedDescription]);
		
		[_headerView toggleRefresh:NO];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}

- (void)_updateChallengeAsSeen {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 6], @"action",
									[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
									nil];
	
	[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil)
			NSLog(@"AFNetworking HONChallengesViewController - Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			NSLog(@"AFNetworking HONChallengesViewController: %@", result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-]  ChallengePreviewViewController %@", [error localizedDescription]);
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	_isPrivate = NO;
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h@2x" : @"mainBG"];
	[self.view addSubview:bgImgView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:NSLocalizedString(@"header_activity", nil)];
	[[_headerView refreshButton] addTarget:self action:@selector(_goRefresh) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_headerView];
	
	UIButton *createChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	createChallengeButton.frame = CGRectMake(266.0, 0.0, 54.0, 44.0);
	[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"createChallengeButton_nonActive"] forState:UIControlStateNormal];
	[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"createChallengeButton_Active"] forState:UIControlStateHighlighted];
	[createChallengeButton addTarget:self action:@selector(_goCreateChallenge) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:createChallengeButton];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kNavBarHeaderHeight + 44.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (20.0 + kNavBarHeaderHeight + kTabSize.height + 44.0)) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 70.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	UIView *toggleHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, kNavBarHeaderHeight, 320.0, 51.0)];
	[self.view addSubview:toggleHolderView];
	
	_togglePrivateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 51.0)];
	_togglePrivateImageView.image = [UIImage imageNamed:@"publicPrivate_toggleB"];
	[toggleHolderView addSubview:_togglePrivateImageView];
	
	_publicButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_publicButton.frame = CGRectMake(0.0, 0.0, 160.0, 44.0);
	_publicButton.titleLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:16];
	[_publicButton setTitleColor:[HONAppDelegate honGrey455Color] forState:UIControlStateNormal];
	[_publicButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[_publicButton setTitle:@"Public" forState:UIControlStateNormal];
	[_publicButton addTarget:self action:@selector(_goPublicChallenges) forControlEvents:UIControlEventTouchUpInside];
	[_publicButton setSelected:YES];
	[toggleHolderView addSubview:_publicButton];
	
	_privateButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_privateButton.frame = CGRectMake(160.0, 0.0, 160.0, 44.0);
	_privateButton.titleLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:16];
	[_privateButton setTitleColor:[HONAppDelegate honGrey455Color] forState:UIControlStateNormal];
	[_privateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[_privateButton setTitle:@"Private" forState:UIControlStateNormal];
	[_privateButton addTarget:self action:@selector(_goPrivateChallenges) forControlEvents:UIControlEventTouchUpInside];
	[_privateButton setSelected:NO];
	[toggleHolderView addSubview:_privateButton];
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
	
	[self _retrieveChallenges];
	[self _retrieveUser];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:@"Activity - Create Snap"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goRefresh {
	[[Mixpanel sharedInstance] track:@"Activity - Refresh"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[_headerView toggleRefresh:YES];
	[self _retrieveChallenges];
	[self _retrieveUser];
}

- (void)_goPublicChallenges {
	_isPrivate = NO;
	
	[_publicButton setSelected:YES];
	[_privateButton setSelected:NO];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	_togglePrivateImageView.image = [UIImage imageNamed:@"publicPrivate_toggleB"];
	[self _retrieveChallenges];
}

- (void)_goPrivateChallenges {
	_isPrivate = YES;
	
	[_publicButton setSelected:NO];
	[_privateButton setSelected:YES];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	_togglePrivateImageView.image = [UIImage imageNamed:@"publicPrivate_toggleA"];
	[self _retrieveChallenges];
}


#pragma mark - Notifications
- (void)_acceptChallenge:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithChallenge:vo]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_nextChallengeBlock:(NSNotification *)notification {	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[self _retrieveNextChallengeBlock];
}

- (void)_refreshChallengesTab:(NSNotification *)notification {
	[_tableView setContentOffset:CGPointZero animated:YES];
	[_headerView toggleRefresh:YES];
	[self _retrieveChallenges];
	[self _retrieveUser];
}

- (void)_showFindFriends:(NSNotification *)notification {
	if (rand() % 100 > 0) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONVerifyMobileViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
		
	} else {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteNetworkViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
	}
}

- (void)_tabsDropped:(NSNotification *)notification {
	_tableView.frame = CGRectMake(0.0, kNavBarHeaderHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (kNavBarHeaderHeight + 29.0));
}

- (void)_tabsRaised:(NSNotification *)notification {
	_tableView.frame = CGRectMake(0.0, kNavBarHeaderHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (kNavBarHeaderHeight + 81.0));
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((section == 0) ? [_recentChallenges count] : [_olderChallenges count] + 1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (2);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 31.0)];
	headerView.image = [UIImage imageNamed:@"tableHeaderBackground"];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(9.0, 0.0, 310.0, 31.0)];
	label.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:14];
	label.textColor = [HONAppDelegate honBlueTxtColor];
	label.backgroundColor = [UIColor clearColor];
	label.text = (section == 0) ? @"Recent" : @"Older";
	[headerView addSubview:label];
	
	return (headerView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		HONChallengeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil)
			cell = [[HONChallengeViewCell alloc] initAsLoadMoreCell:NO];
	
		cell.challengeVO = [_recentChallenges objectAtIndex:indexPath.row];
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		return (cell);
		
	} else {
		if ([_olderChallenges count] == 0) {
			HONEmptyChallengeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
			
			if (cell == nil)
				cell = [[HONEmptyChallengeViewCell alloc] init];
			
			[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
			return (cell);
		
		} else {
			HONChallengeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
			
			if (cell == nil)
				cell = [[HONChallengeViewCell alloc] initAsLoadMoreCell:([_olderChallenges count] > 0 && indexPath.row == [_olderChallenges count])];
			
			if (indexPath.row < [_olderChallenges count])
				cell.challengeVO = [_olderChallenges objectAtIndex:indexPath.row];
			
			[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
			return (cell);
		}
	}
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.section == 1 && [_olderChallenges count] == 0) ? kOrthodoxTableCellHeight * 2.0 : kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (kOrthodoxTableHeaderHeight);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		HONChallengeVO *vo = [_recentChallenges objectAtIndex:indexPath.row];
		if ([vo.status isEqualToString:@"Created"] || [vo.status isEqualToString:@"Waiting"] || [vo.status isEqualToString:@"Accept"] || [vo.status isEqualToString:@"Started"] || [vo.status isEqualToString:@"Completed"])
			return (indexPath);
		
		else
			return (nil);
		
	} else {
		if (indexPath.row < [_olderChallenges count]) {
			HONChallengeVO *vo = [_olderChallenges objectAtIndex:indexPath.row];
			if ([vo.status isEqualToString:@"Created"] || [vo.status isEqualToString:@"Waiting"] || [vo.status isEqualToString:@"Accept"] || [vo.status isEqualToString:@"Started"] || [vo.status isEqualToString:@"Completed"])
				return (indexPath);
			
			else
				return (nil);
		}
	}
	
	return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	//[(HONChallengeViewCell *)[tableView cellForRowAtIndexPath:indexPath] didSelect];
	
	HONChallengeVO *vo = (indexPath.section == 0) ? [_recentChallenges objectAtIndex:indexPath.row] : [_olderChallenges objectAtIndex:indexPath.row];
	_challengeVO = vo;
	
	//NSLog(@"STATUS:[%@]", vo.status);
	if ([vo.status isEqualToString:@"Created"]) {
		[self.navigationController pushViewController:[[HONTimelineViewController alloc] initWithChallenge:vo] animated:YES];
		
	} else if ([vo.status isEqualToString:@"Waiting"]) {
		[self _updateChallengeAsSeen];
		[(HONChallengeViewCell *)[tableView cellForRowAtIndexPath:indexPath] updateHasSeen];
		[self.navigationController pushViewController:[[HONTimelineViewController alloc] initWithUserID:_challengeVO.creatorID challengerID:_challengeVO.challengerID] animated:YES];
		
	} else if ([vo.status isEqualToString:@"Accept"]) {
		[self _updateChallengeAsSeen];
		[(HONChallengeViewCell *)[tableView cellForRowAtIndexPath:indexPath] updateHasSeen];
		[self.navigationController pushViewController:[[HONTimelineViewController alloc] initWithUserID:_challengeVO.challengerID challengerID:_challengeVO.creatorID] animated:YES];
			
	} else if ([vo.status isEqualToString:@"Started"] || [vo.status isEqualToString:@"Completed"]) {
		[self.navigationController pushViewController:[[HONTimelineViewController alloc] initWithUserID:_challengeVO.creatorID challengerID:_challengeVO.challengerID] animated:YES];
	}
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// return YES if you want the specified item to be editable.
	return ((indexPath.section == 0) || (indexPath.section == 1 && indexPath.row < [_olderChallenges count]));
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		HONChallengeVO *vo = (indexPath.section == 0) ? (HONChallengeVO *)[_recentChallenges objectAtIndex:indexPath.row] : (HONChallengeVO *)[_olderChallenges objectAtIndex:indexPath.row];
		
		[[Mixpanel sharedInstance] track:@"Activity - Swipe Row"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
													 [NSString stringWithFormat:@"%d - %@", vo.challengeID, vo.subjectName], @"challenge", nil]];
		
		_idxPath = indexPath;
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Challenge"
																		message:@"Do you want to remove this challenge?"
																	  delegate:self
														  cancelButtonTitle:@"Report Abuse"
														  otherButtonTitles:@"Yes", @"No", nil];
		[alertView setTag:indexPath.section];
		[alertView show];
	}
}


#pragma mark - ScrollView Delegates
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
}


#pragma mark - AlerView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"BUTTON INDEX:[%d]", buttonIndex);
	
	// delete
	if (alertView.tag == 0) {
		HONChallengeVO *vo = (HONChallengeVO *)[_recentChallenges objectAtIndex:_idxPath.row];
		switch(buttonIndex) {
			case 0: {
				[[Mixpanel sharedInstance] track:@"Activity - Flag"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", vo.challengeID, vo.subjectName], @"challenge", nil]];
				
				[_recentChallenges removeObjectAtIndex:_idxPath.row];
				[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_idxPath] withRowAnimation:UITableViewRowAnimationFade];
				
				AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
				NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSString stringWithFormat:@"%d", 11], @"action",
												[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
												[NSString stringWithFormat:@"%d", vo.challengeID], @"challengeID",
												nil];
				
				[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					NSError *error = nil;
					if (error != nil) {
						VolleyJSONLog(@"AFNetworking [-]  HONChallengesViewController - Failed to parse job list JSON: %@", [error localizedFailureReason]);
						
					} else {
						[self _goRefresh];
					}
					
				} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					VolleyJSONLog(@"AFNetworking [-]  ChallengesViewController %@", [error localizedDescription]);
					
					_progressHUD.minShowTime = kHUDTime;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
					_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
					[_progressHUD show:NO];
					[_progressHUD hide:YES afterDelay:1.5];
					_progressHUD = nil;
				}];
				break;}
				
			case 1:
				[[Mixpanel sharedInstance] track:@"Activity - Delete"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", vo.challengeID, vo.subjectName], @"challenge", nil]];
				
				[_recentChallenges removeObjectAtIndex:_idxPath.row];
				[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_idxPath] withRowAnimation:UITableViewRowAnimationFade];
				
				AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
				NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSString stringWithFormat:@"%d", 10], @"action",
												[NSString stringWithFormat:@"%d", vo.challengeID], @"challengeID",
												nil];
				
				[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					NSError *error = nil;
					if (error != nil) {
						VolleyJSONLog(@"AFNetworking [-]  HONChallengesViewController - Failed to parse job list JSON: %@", [error localizedFailureReason]);
						
					} else {
					}
					
				} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					VolleyJSONLog(@"AFNetworking [-]  ChallengesViewController %@", [error localizedDescription]);
					
					_progressHUD.minShowTime = kHUDTime;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
					_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
					[_progressHUD show:NO];
					[_progressHUD hide:YES afterDelay:1.5];
					_progressHUD = nil;
				}];
				break;
		}
	
	} else if (alertView.tag == 1) {
		HONChallengeVO *vo = (HONChallengeVO *)[_olderChallenges objectAtIndex:_idxPath.row];
		switch(buttonIndex) {
			case 0: {
				[[Mixpanel sharedInstance] track:@"Activity - Flag"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", vo.challengeID, vo.subjectName], @"challenge", nil]];
				
				[_olderChallenges removeObjectAtIndex:_idxPath.row];
				[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_idxPath] withRowAnimation:UITableViewRowAnimationFade];
				
				AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
				NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSString stringWithFormat:@"%d", 11], @"action",
												[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
												[NSString stringWithFormat:@"%d", vo.challengeID], @"challengeID",
												nil];
				
				[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					NSError *error = nil;
					if (error != nil) {
						VolleyJSONLog(@"AFNetworking [-]  HONChallengesViewController - Failed to parse job list JSON: %@", [error localizedFailureReason]);
						
					} else {
						[self _goRefresh];
					}
					
				} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					VolleyJSONLog(@"AFNetworking [-]  ChallengesViewController %@", [error localizedDescription]);
					
					_progressHUD.minShowTime = kHUDTime;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
					_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
					[_progressHUD show:NO];
					[_progressHUD hide:YES afterDelay:1.5];
					_progressHUD = nil;
				}];
				break;}
				
			case 1:
				[[Mixpanel sharedInstance] track:@"Activity - Delete"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", vo.challengeID, vo.subjectName], @"challenge", nil]];
				
				[_olderChallenges removeObjectAtIndex:_idxPath.row];
				[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_idxPath] withRowAnimation:UITableViewRowAnimationFade];
				
				AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
				NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSString stringWithFormat:@"%d", 10], @"action",
												[NSString stringWithFormat:@"%d", vo.challengeID], @"challengeID",
												nil];
				
				[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
					NSError *error = nil;
					if (error != nil) {
						VolleyJSONLog(@"AFNetworking [-]  HONChallengesViewController - Failed to parse job list JSON: %@", [error localizedFailureReason]);
						
					} else {
					}
					
				} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					VolleyJSONLog(@"AFNetworking [-]  ChallengesViewController %@", [error localizedDescription]);
					
					_progressHUD.minShowTime = kHUDTime;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
					_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
					[_progressHUD show:NO];
					[_progressHUD hide:YES afterDelay:1.5];
					_progressHUD = nil;
				}];
				break;
		}
	}
}


@end
