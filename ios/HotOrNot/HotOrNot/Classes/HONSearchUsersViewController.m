//
//  HONSearchUsersViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 7/8/13 @ 5:02 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONSearchUsersViewController.h"
#import "HONSearchUserViewCell.h"
#import "HONTrivialUserVO.h"
#import "HONHeaderView.h"
#import "HONSearchBarView.h"
#import "HONUserProfileViewController.h"
#import "HONAddContactsViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONUserVO.h"


@interface HONSearchUsersViewController () <HONSearchBarViewDelegate, HONSearchUserViewCellDelegate>
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *selectedUsers;
@property (nonatomic, strong) NSMutableArray *addUsers;
@property (nonatomic, strong) NSMutableArray *removeUsers;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HONSearchBarView *searchHeaderView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic) BOOL hasUpdated;
@end


@implementation HONSearchUsersViewController

- (id)init {
	if ((self = [super init])) {
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
			[_users addObject:[HONTrivialUserVO userWithDictionary:@{@"id"			: [dict objectForKey:@"id"],
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
					[_users addObject:[HONTrivialUserVO userWithDictionary:dict]];
				
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
		[_users addObject:[HONTrivialUserVO userWithDictionary:dict]];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Search"];
	[self.view addSubview:headerView];
	
	UIButton *selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
	selectAllButton.frame = CGRectMake(10.0, 10.0, 74.0, 24.0);
	[selectAllButton setBackgroundImage:[UIImage imageNamed:@"followAll_nonActive"] forState:UIControlStateNormal];
	[selectAllButton setBackgroundImage:[UIImage imageNamed:@"followAll_Active"] forState:UIControlStateHighlighted];
	[selectAllButton addTarget:self action:@selector(_goSelectAll) forControlEvents:UIControlEventTouchUpInside];
//	[headerView addButton:selectAllButton];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(222.0, 0.0, 93.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:doneButton];
	
	
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
	
	[HONAppDelegate incTotalForCounter:@"search"];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
- (void)_goDone {
	[[Mixpanel sharedInstance] track:@"Search Users - Done"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];

	void (^completionBlock)(NSObject *result) = ^void(NSObject *result) {
		[HONAppDelegate writeFollowingList:(NSArray *)result];
	};
	
	for (HONTrivialUserVO *vo in _removeUsers)
		[[HONAPICaller sharedInstance] stopFollowingUserWithUserID:vo.userID completion:completionBlock];

	for (HONTrivialUserVO *vo in _selectedUsers)
		[[HONAPICaller sharedInstance] followUserWithUserID:vo.userID completion:completionBlock];
	
	
	if ([HONAppDelegate totalForCounter:@"search"] == 0 && [HONAppDelegate switchEnabledForKey:@"popular_invite"]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invite your friends to Selfieclub?"
															message:@"Get more subscribers now, tap OK."
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"OK", nil];
		[alertView setTag:0];
		[alertView show];
	}

	
	if (_hasUpdated) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_PROFILE" object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:nil];
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goSelectAll {
	[[Mixpanel sharedInstance] track:@"Search Users - Select All"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	_hasUpdated = YES;
	[_selectedUsers removeAllObjects];
	[_removeUsers removeAllObjects];

	for (HONTrivialUserVO *vo in _users) {
		[_selectedUsers addObject:vo];
		[_addUsers addObject:vo];
	}
	
	for (HONSearchUserViewCell *cell in _cells)
		[cell toggleSelected:YES];
}


#pragma mark - SearchUserViewCell Delegates
- (void)searchUserViewCell:(HONSearchUserViewCell *)cell user:(HONTrivialUserVO *)trivialUserVO toggleSelected:(BOOL)isSelected {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Search Users People - %@elect", (isSelected) ? @"Des" : @"S"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d - @%@", trivialUserVO.userID, trivialUserVO.username], @"celeb", nil]];
	
	_hasUpdated = YES;
	if (isSelected) {
		[_selectedUsers addObject:trivialUserVO];
		
	} else {
		NSMutableArray *removeVOs = [NSMutableArray array];
		for (HONTrivialUserVO *vo in _selectedUsers) {
			for (HONTrivialUserVO *dropVO in _users) {
				if ([vo.username isEqualToString:dropVO.username]) {
					[removeVOs addObject:vo];
				}
			}
		}
		
		[_selectedUsers removeObjectsInArray:removeVOs];
		removeVOs = nil;
		
		[_removeUsers addObject:trivialUserVO];
	}
}


#pragma mark - SearchBarHeader Delegates
- (void)searchBarViewCancel:(HONSearchBarView *)searchBarView {
	[[Mixpanel sharedInstance] track:@"Search Users - Cancel"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_users = [NSMutableArray array];
	for (NSDictionary *dict in [HONAppDelegate searchUsers])
		[_users addObject:[HONTrivialUserVO userWithDictionary:dict]];
	
	[_tableView reloadData];
}

- (void)searchBarView:(HONSearchBarView *)searchBarView enteredSearch:(NSString *)searchQuery {
	[[Mixpanel sharedInstance] track:@"Contacts - Select Follow In-App Contact"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  searchQuery, @"query", nil]];
	
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
	_searchHeaderView = [[HONSearchBarView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, kSearchHeaderHeight)];
	_searchHeaderView.delegate = self;
	
	return (_searchHeaderView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONSearchUserViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONSearchUserViewCell alloc] init];
	
	HONTrivialUserVO *vo = (HONTrivialUserVO *)[_users objectAtIndex:indexPath.row];
	cell.trivialUserVO = vo;
	[cell toggleSelected:[HONAppDelegate isFollowingUser:vo.userID]];
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	BOOL isFound = NO;
	for (HONTrivialUserVO *userVO in [HONAppDelegate followingListWithRefresh:NO]) {
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
	
	HONTrivialUserVO *vo = [_users objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:vo.userID] animated:YES];
	
//	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithUserID:vo.userID];
//	userPofileViewController.userID = vo.userID;
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Search Users - Invite Friends %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
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
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Search Users - Select All %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
		if (buttonIndex == 1) {
			[_selectedUsers removeAllObjects];
			for (NSDictionary *dict in [HONAppDelegate searchUsers])
				[_selectedUsers addObject:[HONTrivialUserVO userWithDictionary:dict]];
			
			for (HONSearchUserViewCell *cell in _cells)
				[cell toggleSelected:YES];
			
			for (HONTrivialUserVO *vo in _selectedUsers) {
				[[HONAPICaller sharedInstance] followUserWithUserID:vo.userID completion:^void(NSObject *result) {
					[HONAppDelegate writeFollowingList:(NSArray *)result];
				}];
			}
			
			if ([HONAppDelegate totalForCounter:@"search"] == 0 && [HONAppDelegate switchEnabledForKey:@"popular_invite"]) {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invite your friends to Selfieclub?"
																	message:@"Get more subscribers now, tap OK."
																   delegate:self
														  cancelButtonTitle:@"No"
														  otherButtonTitles:@"OK", nil];
				[alertView setTag:0];
				[alertView show];
				
				
			}
		}
	
	} else if (alertView.tag == 2) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Search Users - Select Blocked %@", (buttonIndex == 0) ? @"Cancel" : @"Take Photo"]
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
