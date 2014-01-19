//
//  HONPopularViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 7/8/13 @ 5:02 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONPopularViewController.h"
#import "HONPopularUserViewCell.h"
#import "HONPopularUserVO.h"
#import "HONHeaderView.h"
#import "HONSearchBarHeaderView.h"
#import "HONUserProfileViewController.h"
#import "HONAddContactsViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONAPICaller.h"
#import "HONImagingDepictor.h"
#import "HONUserVO.h"


@interface HONPopularViewController () <HONSearchBarHeaderViewDelegate, HONPopularUserViewCellDelegate>
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *selectedUsers;
@property (nonatomic, strong) NSMutableArray *addUsers;
@property (nonatomic, strong) NSMutableArray *removeUsers;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HONSearchBarHeaderView *searchHeaderView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic) BOOL hasUpdated;
@end


@implementation HONPopularViewController

- (id)init {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Popular People - Open"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
		_hasUpdated = NO;
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
- (void)_retrieveUsers:(NSString *)username {
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_searchUsers", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[[HONAPICaller sharedInstance] searchForUsersByUsername:username completion:^(NSObject *result){
		_users = [NSMutableArray array];
		for (NSDictionary *dict in (NSArray *)result) {
			[_users addObject:[HONPopularUserVO userWithDictionary:@{@"id"			: [dict objectForKey:@"id"],
																	 @"username"	: [dict objectForKey:@"username"],
																	 @"img_url"		: [dict objectForKey:@"avatar_url"]}]];
		}
		
		if (_progressHUD != nil) {
			if ([_users count] == 0) {
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = NSLocalizedString(@"hud_noResults", nil);
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:kHUDErrorTime];
				_progressHUD = nil;
				
				_users = [NSMutableArray array];
				for (NSDictionary *dict in [HONAppDelegate searchUsers])
					[_users addObject:[HONPopularUserVO userWithDictionary:dict]];
				
			} else {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
		}
		
		[_tableView reloadData];
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
	
	_users = [NSMutableArray array];
	_selectedUsers = [NSMutableArray array];
	_addUsers = [NSMutableArray array];
	_removeUsers = [NSMutableArray array];
	_cells = [NSMutableArray array];
	
	for (NSDictionary *dict in [HONAppDelegate searchUsers])
		[_users addObject:[HONPopularUserVO userWithDictionary:dict]];
	
	UIButton *selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
	selectAllButton.frame = CGRectMake(10.0, 10.0, 74.0, 24.0);
	[selectAllButton setBackgroundImage:[UIImage imageNamed:@"followAll_nonActive"] forState:UIControlStateNormal];
	[selectAllButton setBackgroundImage:[UIImage imageNamed:@"followAll_Active"] forState:UIControlStateHighlighted];
	[selectAllButton addTarget:self action:@selector(_goSelectAll) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initAsModalWithTitle:@"Search" hasTranslucency:NO];
//	[headerView addButton:selectAllButton];
	[headerView addButton:doneButton];
	[self.view addSubview:headerView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 64.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];	
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
	
	[HONAppDelegate incTotalForCounter:@"popular"];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
- (void)_goDone {
	[[Mixpanel sharedInstance] track:@"Popular People - Done"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];

	void (^completionBlock)(NSObject *result) = ^void(NSObject *result) {
		[HONAppDelegate writeFollowingList:(NSArray *)result];
	};
	
	for (HONPopularUserVO *vo in _removeUsers)
		[[HONAPICaller sharedInstance] stopFollowingUserWithUserID:vo.userID completion:completionBlock];

	for (HONPopularUserVO *vo in _selectedUsers)
		[[HONAPICaller sharedInstance] followUserWithUserID:vo.userID completion:completionBlock];
	
	
	if ([HONAppDelegate totalForCounter:@"popular"] == 0 && [HONAppDelegate switchEnabledForKey:@"popular_invite"]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Invite your friends to %@?", [HONAppDelegate brandedAppName]]
															message:@"Get more subscribers now, tap OK."
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"OK", nil];
		[alertView setTag:0];
		[alertView show];
	}

	
	if (_hasUpdated) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_PROFILE" object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:nil];
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goSelectAll {
	[[Mixpanel sharedInstance] track:@"Popular People - Select All"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	_hasUpdated = YES;
	[_selectedUsers removeAllObjects];
	[_removeUsers removeAllObjects];

	for (HONPopularUserVO *vo in _users) {
		[_selectedUsers addObject:vo];
		[_addUsers addObject:vo];
	}
	
	for (HONPopularUserViewCell *cell in _cells)
		[cell toggleSelected:YES];
}


#pragma mark - PopularUserViewCell Delegates
- (void)popularUserViewCell:(HONPopularUserViewCell *)cell user:(HONPopularUserVO *)popularUserVO toggleSelected:(BOOL)isSelected {
	if ([HONAppDelegate hasTakenSelfie]) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Popular People - %@elect%@", (isSelected) ? @"Des" : @"S", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
										  [NSString stringWithFormat:@"%d - @%@", popularUserVO.userID, popularUserVO.username], @"celeb", nil]];
		
		_hasUpdated = YES;
		if (isSelected) {
			[_selectedUsers addObject:popularUserVO];
			
		} else {
			NSMutableArray *removeVOs = [NSMutableArray array];
			for (HONPopularUserVO *vo in _selectedUsers) {
				for (HONPopularUserVO *dropVO in _users) {
					if ([vo.username isEqualToString:dropVO.username]) {
						[removeVOs addObject:vo];
					}
				}
			}
			
			[_selectedUsers removeObjectsInArray:removeVOs];
			removeVOs = nil;
			
			[_removeUsers addObject:popularUserVO];
		}
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_noSelfie_t", nil)
															message:NSLocalizedString(@"alert_noSelfie_m", nil)
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles:@"Take Photo", nil];
		[alertView setTag:2];
		[alertView show];
	}
}


#pragma mark - SearchBar Delegates
- (void)searchBarHeaderFocus:(HONSearchBarHeaderView *)searchBarHeaderView {
}

- (void)searchBarHeaderCancel:(HONSearchBarHeaderView *)searchBarHeaderView {
	_users = [NSMutableArray array];
	for (NSDictionary *dict in [HONAppDelegate searchUsers])
		[_users addObject:[HONPopularUserVO userWithDictionary:dict]];
	
	[_tableView reloadData];
}

- (void)searchBarHeader:(HONSearchBarHeaderView *)searchBarHeaderView enteredSearch:(NSString *)searchQuery {
	[self _retrieveUsers:searchQuery];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_users count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	_searchHeaderView = [[HONSearchBarHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, kSearchHeaderHeight)];
	_searchHeaderView.delegate = self;
	
	return (_searchHeaderView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONPopularUserViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONPopularUserViewCell alloc] init];
	
	HONPopularUserVO *vo = (HONPopularUserVO *)[_users objectAtIndex:indexPath.row];
	cell.popularUserVO = vo;
	[cell toggleSelected:[HONAppDelegate isFollowingUser:vo.userID]];
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	BOOL isFound = NO;
	for (HONUserVO *userVO in [HONAppDelegate followingList]) {
		if (vo.userID == userVO.userID) {
			isFound = YES;
			[_selectedUsers addObject:vo];
			break;
		}
	}
	
	[cell toggleSelected:isFound];
	[_cells addObject:cell];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (kSearchHeaderHeight);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	HONPopularUserVO *vo = [_users objectAtIndex:indexPath.row];
	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] init];
	userPofileViewController.userID = vo.userID;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Popular People - Invite Friends %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			
		} else {
			[self dismissViewControllerAnimated:YES completion:^(void) {
			}];
		}
	
	} else if (alertView.tag == 1) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Popular People - Select All %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
		if (buttonIndex == 1) {
			[_selectedUsers removeAllObjects];
			for (NSDictionary *dict in [HONAppDelegate searchUsers])
				[_selectedUsers addObject:[HONPopularUserVO userWithDictionary:dict]];
			
			for (HONPopularUserViewCell *cell in _cells)
				[cell toggleSelected:YES];
			
			for (HONPopularUserVO *vo in _selectedUsers) {
				[[HONAPICaller sharedInstance] followUserWithUserID:vo.userID completion:^void(NSObject *result) {
					[HONAppDelegate writeFollowingList:(NSArray *)result];
				}];
			}
			
			if ([HONAppDelegate totalForCounter:@"popular"] == 0 && [HONAppDelegate switchEnabledForKey:@"popular_invite"]) {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Invite your friends to %@?", [HONAppDelegate brandedAppName]]
																	message:@"Get more subscribers now, tap OK."
																   delegate:self
														  cancelButtonTitle:@"No"
														  otherButtonTitles:@"OK", nil];
				[alertView setTag:0];
				[alertView show];
				
				
			}
		}
	
	} else if (alertView.tag == 2) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Popular People - Select Blocked %@", (buttonIndex == 0) ? @"Cancel" : @"Take Photo"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:NO completion:nil];
		}
	}
}

@end
