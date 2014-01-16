//
//  HONFollowingViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 10/4/13 @ 5:47 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"

#import "HONAPICaller.h"
#import "HONFollowingViewController.h"
#import "HONFollowUserViewCell.h"
#import "HONHeaderView.h"
#import "HONUserProfileViewController.h"
#import "HONUserVO.h"


@interface HONFollowingViewController () <HONFollowUserViewCellDelegate>
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONUserVO *userVO;
@property (nonatomic, strong) NSMutableArray *subscribees;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) int userID;
@property (nonatomic) BOOL hasUpdated;
@end


@implementation HONFollowingViewController


- (id)initWithUserID:(int)userID {
	if ((self = [super init])) {
		_userID = userID;
		_hasUpdated = NO;
		_subscribees = [NSMutableArray array];
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
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initAsModalWithTitle:@"Following" hasTranslucency:NO];
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
	
	[[HONAPICaller sharedInstance] retrieveUserByUserID:_userID completion:^(NSObject *result) {
		if ([(NSDictionary *)result objectForKey:@"id"] != nil) {
			_userVO = [HONUserVO userWithDictionary:(NSDictionary *)result];
			
			[[HONAPICaller sharedInstance] retrieveFollowersForUserByUserID:_userID completion:^(NSObject *result){
				NSMutableArray *users = [NSMutableArray arrayWithCapacity:[(NSArray *)result count]];
				for (NSDictionary *dict in (NSArray *)result)
					[users addObject:[dict objectForKey:@"user"]];
				
				NSArray *following = [NSArray arrayWithArray:[users sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]];
				for (NSDictionary *dict in following) {
					[_subscribees addObject:[HONUserVO userWithDictionary:@{@"id"			: [NSString stringWithFormat:@"%d", [[dict objectForKey:@"id"] intValue]],
																			@"points"		: [NSString stringWithFormat:@"%d", 0],
																			@"total_votes"	: [NSString stringWithFormat:@"%d", 0],
																			@"pokes"		: [NSString stringWithFormat:@"%d", 0],
																			@"pics"			: [NSString stringWithFormat:@"%d", 0],
																			@"age"			: [NSString stringWithFormat:@"%d", 0],
																			@"username"		: [dict objectForKey:@"username"],
																			@"fb_id"		: @"",
																			@"avatar_url"	: [HONAppDelegate cleanImagePrefixURL:[dict objectForKey:@"avatar_url"]]}]];
				}
				
				[_tableView reloadData];
			}];
		}
	}];
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
	[[Mixpanel sharedInstance] track:@"Following - Done"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if (_hasUpdated)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_PROFILE" object:nil];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_subscribees count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONFollowUserViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONFollowUserViewCell alloc] init];
	
	HONUserVO *vo = (HONUserVO *)[_subscribees objectAtIndex:indexPath.row];
	
	cell.userVO = vo;
	cell.delegate = self;
	[cell toggleSelected:[HONAppDelegate isFollowingUser:vo.userID]];
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
	bgImageView.backgroundColor = [UIColor whiteColor];
	
	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] init];
	userPofileViewController.userID = ((HONUserVO *)[_subscribees objectAtIndex:indexPath.row]).userID;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - SubscriberCell Delegates
- (void)followViewCell:(HONFollowUserViewCell *)cell user:(HONUserVO *)userVO toggleSelected:(BOOL)isSelected {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Subscribers List - %@ User", (isSelected) ? @"Select" : @"Deselect"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_hasUpdated = YES;
	
	void (^completionBlock)(NSObject *result) = ^void(NSObject *result) {
		[HONAppDelegate writeFollowingList:(NSArray *)result];
	};
	
	if (isSelected)
		[[HONAPICaller sharedInstance] followUserWithUserID:userVO.userID completion:completionBlock];
	
	else
		[[HONAPICaller sharedInstance] stopFollowingUserWithUserID:userVO.userID completion:completionBlock];
}


@end
