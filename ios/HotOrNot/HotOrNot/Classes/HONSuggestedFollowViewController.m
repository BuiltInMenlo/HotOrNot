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
#import "HONTableHeaderView.h"
#import "HONUserProfileViewController.h"
#import "HONAddContactsViewController.h"
#import "HONChangeAvatarViewController.h"
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
	
	for (NSDictionary *dict in @[])
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
	doneButton.frame = CGRectMake(222.0, 0.0, 93.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButtonBlue_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButtonBlue_Active"] forState:UIControlStateHighlighted];
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
	
//	for (HONTrivialUserVO *vo in _removeUsers) {
//		[[HONAPICaller sharedInstance] stopFollowingUserWithUserID:vo.userID completion:^(NSArray *result) {
//			[HONAppDelegate writeFollowingList:result];
//		}];
//	}
//
//	for (HONTrivialUserVO *vo in _selectedUsers) {
//		[[HONAPICaller sharedInstance] followUserWithUserID:vo.userID completion:^(NSArray *result) {
//			[HONAppDelegate writeFollowingList:result];
//		}];
//	}
	
	
//	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Do you want to follow everyone in the list?"
//														message:@""
//													   delegate:self
//											  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
//											  otherButtonTitles:NSLocalizedString(@"alert_yes", nil), nil];
//	[alertView setTag:1];
//	[alertView show];
		
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:nil];
//	[self dismissViewControllerAnimated:YES completion:nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_PROFILE" object:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goSelectAll {
	
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
	return ([[HONTableHeaderView alloc] initWithTitle:@"FOLLOW POPULAR PEOPLE"]);
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
//	for (HONTrivialUserVO *userVO in [HONAppDelegate followingListWithRefresh:NO]) {
//		if (vo.userID == userVO.userID) {
//			isFound = YES;
//			[_selectedUsers addObject:vo];
//			break;
//		}
//	}
	
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
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUserProfileViewController alloc] initWithUserID:vo.userID]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			
		} else {
			[self dismissViewControllerAnimated:YES completion:^(void) {
			}];
		}
		
	} else if (alertView.tag == 1) {
		
		if (buttonIndex == 1) {
			[_selectedUsers removeAllObjects];
			for (NSDictionary *dict in @[])
				[_selectedUsers addObject:[HONTrivialUserVO userWithDictionary:dict]];
			
			for (HONSuggestedFollowViewCell *cell in _cells)
				[cell toggleSelected:YES];
			
//			for (HONTrivialUserVO *vo in _selectedUsers) {
//				[[HONAPICaller sharedInstance] followUserWithUserID:vo.userID completion:^(NSArray *result) {
//					[HONAppDelegate writeFollowingList:result];
//				}];
//			}
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:nil];
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

@end
