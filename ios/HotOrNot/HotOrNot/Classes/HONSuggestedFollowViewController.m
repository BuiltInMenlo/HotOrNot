//
//  HONSuggestedFollowViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 11/22/2013 @ 13:41 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"


#import "HONSuggestedFollowViewController.h"
#import "HONSuggestedFollowViewCell.h"
#import "HONPopularUserVO.h"
#import "HONHeaderView.h"
#import "HONUserProfileViewController.h"
#import "HONAddContactsViewController.h"
#import "HONChangeAvatarViewController.h"
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
- (void)_addFriend:(int)userID {
	NSDictionary *params = @{@"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"target"	: [NSString stringWithFormat:@"%d", userID],
							 @"auto"	: @"0"};
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIAddFriend);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIAddFriend parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (result != nil)
				[HONAppDelegate writeFollowingList:result];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if (_progressHUD == nil)
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

- (void)_removeFriend:(int)userID {
	NSDictionary *params = @{@"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"target"	: [NSString stringWithFormat:@"%d", userID]};
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIRemoveFriend);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIRemoveFriend parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (result != nil)
				[HONAppDelegate writeFollowingList:result];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if (_progressHUD == nil)
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
		[_users addObject:[HONPopularUserVO userWithDictionary:dict]];
	
//	UIButton *selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	selectAllButton.frame = CGRectMake(10.0, 10.0, 74.0, 24.0);
//	[selectAllButton setBackgroundImage:[UIImage imageNamed:@"followAll_nonActive"] forState:UIControlStateNormal];
//	[selectAllButton setBackgroundImage:[UIImage imageNamed:@"followAll_Active"] forState:UIControlStateHighlighted];
//	[selectAllButton addTarget:self action:@selector(_goSelectAll) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initAsModalWithTitle:@"Suggested" hasTranslucency:NO];
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
	
	if ([_selectedUsers count] > 0) {
		for (HONPopularUserVO *vo in _selectedUsers)
			[self _addFriend:vo.userID];
		
		int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"popular_total"] intValue];
		if (total == 0 && [HONAppDelegate switchEnabledForKey:@"popular_invite"]) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Invite your friends to %@?", [HONAppDelegate brandedAppName]]
																message:@"Get more subscribers now, tap OK."
															   delegate:self
													  cancelButtonTitle:@"No"
													  otherButtonTitles:@"OK", nil];
			[alertView setTag:0];
			[alertView show];
			
		}
		
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
	[[Mixpanel sharedInstance] track:@"Popular People - Select All"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	[_selectedUsers removeAllObjects];
	[_removeUsers removeAllObjects];
//	for (NSDictionary *dict in [HONAppDelegate popularPeople])
//		[_selectedUsers addObject:[HONPopularUserVO userWithDictionary:dict]];
//
//	for (HONPopularUserViewCell *cell in _cells)
//		[cell toggleSelected:YES];


// delselect all
//	if ([_addUsers count] == [_users count]) {
//		[_addUsers removeAllObjects];
//
//		for (HONPopularUserVO *vo in _users)
//			[_removeUsers addObject:vo];
//
//		for (HONPopularUserViewCell *cell in _cells)
//			[cell toggleSelected:NO];
//
//	} else {
	[_removeUsers removeAllObjects];
	for (HONPopularUserVO *vo in _users) {
		[_selectedUsers addObject:vo];
		[_addUsers addObject:vo];
	}
	
	for (HONSuggestedFollowViewCell *cell in _cells)
		[cell toggleSelected:YES];
//	}
}


#pragma mark - SuggestedViewCell Delegates
- (void)followViewCell:(HONSuggestedFollowViewCell *)cell user:(HONPopularUserVO *)userVO toggleSelected:(BOOL)isSelected {
	if ([HONAppDelegate hasTakenSelfie]) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Popular People - %@elect%@", (isSelected) ? @"Des" : @"S", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
										  [NSString stringWithFormat:@"%d - @%@", userVO.userID, userVO.username], @"celeb", nil]];
		
		if (isSelected) {
			[_selectedUsers addObject:userVO];
			
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
	label.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:13];
	label.textColor = [HONAppDelegate honGreyTextColor];
	label.backgroundColor = [UIColor clearColor];
	label.text = @"Follow popular people";
	[headerImageView addSubview:label];
	
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONSuggestedFollowViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONSuggestedFollowViewCell alloc] init];
	
	HONPopularUserVO *vo = (HONPopularUserVO *)[_users objectAtIndex:indexPath.row];
	cell.popularUserVO = vo;
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
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
			for (NSDictionary *dict in [HONAppDelegate popularPeople])
				[_selectedUsers addObject:[HONPopularUserVO userWithDictionary:dict]];
			
			for (HONSuggestedFollowViewCell *cell in _cells)
				[cell toggleSelected:YES];
			
			for (HONPopularUserVO *vo in _selectedUsers)
				[self _addFriend:vo.userID];
			
			int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"popular_total"] intValue];
			if (total == 0 && [HONAppDelegate switchEnabledForKey:@"popular_invite"]) {
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
