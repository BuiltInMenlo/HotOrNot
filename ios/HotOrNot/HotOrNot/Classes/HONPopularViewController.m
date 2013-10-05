//
//  HONPopularViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 7/8/13 @ 5:02 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONPopularViewController.h"
#import "HONPopularUserViewCell.h"
#import "HONPopularUserVO.h"
#import "HONHeaderView.h"
#import "HONSearchBarHeaderView.h"
#import "HONUserProfileViewController.h"


@interface HONPopularViewController () <HONSearchBarHeaderViewDelegate, HONPopularUserViewCellDelegate>
@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *selectedUsers;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HONSearchBarHeaderView *searchHeaderView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end


@implementation HONPopularViewController

- (id)init {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Popular People - Open"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
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
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", userID], @"target",
							@"0", @"auto", nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIAddFriend);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIAddFriend parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			if (result != nil)
				[HONAppDelegate writeSubscribeeList:result];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}

- (void)_removeFriend:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", userID], @"target", nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIRemoveFriend);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIRemoveFriend parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			if (result != nil)
				[HONAppDelegate writeSubscribeeList:result];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}

- (void)_retrieveUsers:(NSString *)username {
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_searchUsers", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 1], @"action",
							username, @"username",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPISearch, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPISearch parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
		} else {
			NSArray *unsortedUsers = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			NSArray *parsedUsers = [NSMutableArray arrayWithArray:[unsortedUsers sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:NO]]]];
//			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], unsortedUsers);
			
			_users = [NSMutableArray array];
			for (NSDictionary *serverList in parsedUsers) {
				[_users addObject:[HONPopularUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
																		[serverList objectForKey:@"id"], @"id",
																		[serverList objectForKey:@"username"], @"username",
																		[serverList objectForKey:@"avatar_url"], @"img_url", nil]]];
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
					for (NSDictionary *dict in [HONAppDelegate popularPeople])
						[_users addObject:[HONPopularUserVO userWithDictionary:dict]];
					
				} else {
					[_progressHUD hide:YES];
					_progressHUD = nil;
				}
			}
			
			[_tableView reloadData];
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


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
	self.view.frame = CGRectOffset(self.view.frame, 0.0, 20.0);
	
	_users = [NSMutableArray array];
	_selectedUsers = [NSMutableArray array];
	
	for (NSDictionary *dict in [HONAppDelegate popularPeople])
		[_users addObject:[HONPopularUserVO userWithDictionary:dict]];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(252.0, 13.0, 64.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initAsModalWithTitle:@""];
	headerView.frame = CGRectOffset(headerView.frame, 0.0, -13.0);
	headerView.backgroundColor = [UIColor blackColor];
	[headerView addButton:doneButton];
	[self.view addSubview:headerView];
	
	UILabel *headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 41.0, 200.0, 24.0)];
	headerTitleLabel.backgroundColor = [UIColor clearColor];
	headerTitleLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:19];
	headerTitleLabel.textColor = [UIColor whiteColor];
	headerTitleLabel.textAlignment = NSTextAlignmentCenter;
	headerTitleLabel.text = @"Find People";
	[headerView addSubview:headerTitleLabel];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 64.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
//	UIButton *selectToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	selectToggleButton.frame = CGRectMake(0.0, kNavBarHeaderHeight, 320.0, 50.0);
//	[selectToggleButton setBackgroundImage:[UIImage imageNamed:@"singleTab_nonActive"] forState:UIControlStateNormal];
//	[selectToggleButton setBackgroundImage:[UIImage imageNamed:@"singleTab_nonActive"] forState:UIControlStateHighlighted];
//	//[selectToggleButton addTarget:self action:@selector(_goSelectAllToggle) forControlEvents:UIControlEventTouchUpInside];
//	[self.view addSubview:selectToggleButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[HONAppDelegate offsetSubviewsForIOS7:self.view];
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
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	for (HONPopularUserVO *vo in _selectedUsers)
		[self _addFriend:vo.userID];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - PopularUserVieCell Delegates
- (void)popularUserViewCell:(HONPopularUserViewCell *)cell user:(HONPopularUserVO *)popularUserVO toggleSelected:(BOOL)isSelected {
	if (isSelected) {
		[[Mixpanel sharedInstance] track:@"Popular People - Select"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - @%@", popularUserVO.userID, popularUserVO.username], @"celeb", nil]];
		
		[_selectedUsers addObject:popularUserVO];
		
	} else {
		[[Mixpanel sharedInstance] track:@"Popular People - Deselect"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - @%@", popularUserVO.userID, popularUserVO.username], @"celeb", nil]];
		
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
}


#pragma mark - SearchBar Delegates
- (void)searchBarHeaderFocus:(HONSearchBarHeaderView *)searchBarHeaderView {
}

- (void)searchBarHeaderCancel:(HONSearchBarHeaderView *)searchBarHeaderView {
	_users = [NSMutableArray array];
	for (NSDictionary *dict in [HONAppDelegate popularPeople])
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
	
	cell.popularUserVO = (HONPopularUserVO *)[_users objectAtIndex:indexPath.row];
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
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
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImageView.backgroundColor = [UIColor blackColor];
	
	HONPopularUserVO *vo = [_users objectAtIndex:indexPath.row];
	
	NSLog(@"didSelectRowAtIndexPath:[%@]", vo.username);
	
	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithBackground:bgImageView];
	userPofileViewController.userID = vo.userID;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		switch(buttonIndex) {
			case 0:
				[[Mixpanel sharedInstance] track:@"Invite Celeb - Confirm Done"
									  properties:[NSDictionary dictionaryWithObjectsAndKeys:
												  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
				[self dismissViewControllerAnimated:YES completion:nil];
				break;
				
			case 1:
				[[Mixpanel sharedInstance] track:@"Invite Celeb - Cancel Done"
									  properties:[NSDictionary dictionaryWithObjectsAndKeys:
												  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				break;
		}
	}
}

@end
