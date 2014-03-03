//
//  HONSuggestedFollowViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 11/22/2013 @ 13:41 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"


#import "HONSuggestedFollowViewController.h"
#import "HONSuggestedFollowViewCell.h"
#import "HONTrivialUserVO.h"
#import "HONHeaderView.h"
#import "HONUserProfileViewController.h"
#import "HONAddContactsViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONAPICaller.h"
#import "HONColorAuthority.h"
#import "HONFontAllocator.h"
#import "HONImagingDepictor.h"
#import "HONUserVO.h"

@interface HONSuggestedFollowViewController () <HONSuggestedFollowViewCellDelegate>
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *selectedUsers;
@property (nonatomic, strong) NSMutableArray *addUsers;
@property (nonatomic, strong) NSMutableArray *removeUsers;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end


@implementation HONSuggestedFollowViewController

- (id)init {
	if ((self = [super init])) {
		
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
	
	_users = [NSMutableArray array];
	_selectedUsers = [NSMutableArray array];
	_addUsers = [NSMutableArray array];
	_removeUsers = [NSMutableArray array];
	_cells = [NSMutableArray array];
	
	for (NSDictionary *dict in [HONAppDelegate popularPeople])
		[_users addObject:[HONTrivialUserVO userWithDictionary:dict]];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Suggested"];
	[self.view addSubview:headerView];
	
//	UIButton *selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	selectAllButton.frame = CGRectMake(10.0, 10.0, 74.0, 24.0);
//	[selectAllButton setBackgroundImage:[UIImage imageNamed:@"followAll_nonActive"] forState:UIControlStateNormal];
//	[selectAllButton setBackgroundImage:[UIImage imageNamed:@"followAll_Active"] forState:UIControlStateHighlighted];
//	[selectAllButton addTarget:self action:@selector(_goSelectAll) forControlEvents:UIControlEventTouchUpInside];
//	[headerView addButton:selectAllButton];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
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
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
- (void)_goDone {
	[[Mixpanel sharedInstance] track:@"Suggested People - Done"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	for (HONTrivialUserVO *vo in _removeUsers) {
		[[HONAPICaller sharedInstance] stopFollowingUserWithUserID:vo.userID completion:^(NSObject *result){
			[HONAppDelegate writeFollowingList:(NSArray *)result];
		}];
	}

	for (HONTrivialUserVO *vo in _selectedUsers) {
		[[HONAPICaller sharedInstance] followUserWithUserID:vo.userID completion:^(NSObject *result){
			[HONAppDelegate writeFollowingList:(NSArray *)result];
		}];
	}
	
	
	if ([HONAppDelegate incTotalForCounter:@"suggested"] == 1 && [HONAppDelegate switchEnabledForKey:@"popular_invite"]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Invite your friends to %@?", [HONAppDelegate brandedAppName]]
															message:@"Get more subscribers now, tap OK."
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"OK", nil];
		[alertView setTag:0];
		[alertView show];
			
		
	} else {
//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Do you want to follow everyone in the list?"
//															message:@""
//														   delegate:self
//												  cancelButtonTitle:@"No"
//												  otherButtonTitles:@"Yes", nil];
//		[alertView setTag:1];
//		[alertView show];
		
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:nil];
//		[self dismissViewControllerAnimated:YES completion:nil];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_PROFILE" object:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_HOME_TUTORIAL" object:nil];
}

- (void)_goSelectAll {
	[[Mixpanel sharedInstance] track:@"Suggested People - Select All"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	[_selectedUsers removeAllObjects];
	[_removeUsers removeAllObjects];
	
	for (HONTrivialUserVO *vo in _users) {
		[_selectedUsers addObject:vo];
		[_addUsers addObject:vo];
	}
	
	for (HONSuggestedFollowViewCell *cell in _cells)
		[cell toggleSelected:YES];
}


#pragma mark - SuggestedViewCell Delegates
- (void)followViewCell:(HONSuggestedFollowViewCell *)cell user:(HONTrivialUserVO *)userVO toggleSelected:(BOOL)isSelected {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Suggested People - %@elect", (isSelected) ? @"Des" : @"S"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d - @%@", userVO.userID, userVO.username], @"celeb", nil]];
	
	if (isSelected) {
		[_selectedUsers addObject:userVO];
		
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
		
		[_removeUsers addObject:userVO];
	}
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_users count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIImageView *headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraTableHeader"]];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 0.0, 320.0, kOrthodoxTableHeaderHeight - 1.0)];
	label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:13];
	label.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	label.backgroundColor = [UIColor clearColor];
	label.text = @"Follow popular people";
	[headerImageView addSubview:label];
	
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONSuggestedFollowViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONSuggestedFollowViewCell alloc] init];
	
	HONTrivialUserVO *vo = (HONTrivialUserVO *)[_users objectAtIndex:indexPath.row];
	cell.trivialUserVO = vo;
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
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
	return (206.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	HONTrivialUserVO *vo = [_users objectAtIndex:indexPath.row];
	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] init];
	userPofileViewController.userID = vo.userID;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Suggested People - Invite Friends %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
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
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Suggested People - Select All %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
		if (buttonIndex == 1) {
			[_selectedUsers removeAllObjects];
			for (NSDictionary *dict in [HONAppDelegate popularPeople])
				[_selectedUsers addObject:[HONTrivialUserVO userWithDictionary:dict]];
			
			for (HONSuggestedFollowViewCell *cell in _cells)
				[cell toggleSelected:YES];
			
			for (HONTrivialUserVO *vo in _selectedUsers) {
				[[HONAPICaller sharedInstance] followUserWithUserID:vo.userID completion:^(NSObject *result) {
					[HONAppDelegate writeFollowingList:(NSArray *)result];
				}];
			}
			
			if ([HONAppDelegate totalForCounter:@"suggested"] == 0 && [HONAppDelegate switchEnabledForKey:@"popular_invite"]) {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Invite your friends to %@?", [HONAppDelegate brandedAppName]]
																	message:@"Get more subscribers now, tap OK."
																   delegate:self
														  cancelButtonTitle:@"No"
														  otherButtonTitles:@"OK", nil];
				[alertView setTag:0];
				[alertView show];
				
				
			}
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:nil];
		[self dismissViewControllerAnimated:YES completion:nil];
		
	} else if (alertView.tag == 2) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Suggested People - Select Blocked %@", (buttonIndex == 0) ? @"Cancel" : @"Take Photo"]
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
