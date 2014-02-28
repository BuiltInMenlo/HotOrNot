//
//  HONUserClubsViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 02/27/2014 @ 10:31 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "EGORefreshTableHeaderView.h"

#import "HONUserClubsViewController.h"
#import "HONAnalyticsParams.h"
#import "HONAPICaller.h"
#import "HONColorAuthority.h"
#import "HONHeaderView.h"
#import "HONFontAllocator.h"
#import "HONProfileHeaderButtonView.h"
#import "HONMessagesButtonView.h"
#import "HONCreateSnapButtonView.h"
#import "HONUserProfileViewController.h"
#import "HONMessagesViewController.h"
#import "HONImagePickerViewController.h"
#import "HONMatchContactsViewController.h"
#import "HONUserClubVO.h"


@interface HONUserClubsViewController () <EGORefreshTableHeaderDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HONUserClubVO *ownClub;
@property (nonatomic, strong) NSMutableArray *joinedClubs;
@property (nonatomic, strong) HONProfileHeaderButtonView *profileHeaderButtonView;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) NSArray *defaultCaptions;
@end


@implementation HONUserClubsViewController

- (id)init {
	if ((self = [super init])) {
		_defaultCaptions = @[@"Quick Links",
							 @"Find friends who have a Selfieclub",
							 @"Invite friends to my selfieclub",
							 @"Verify my phone number"];
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
- (void)_retrieveClubs {
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result){
		_joinedClubs = [NSMutableArray array];
		
		if ([[((NSDictionary *)result) objectForKey:@"owned"] count] > 0)
			_ownClub = [HONUserClubVO clubWithDictionary:[((NSDictionary *)result) objectForKey:@"owned"]];
		
		for (NSDictionary *dict in [((NSDictionary *)result) objectForKey:@"joined"])
			[_joinedClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
		
		[_tableView reloadData];
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_tableView];
	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0, -_tableView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height) headerOverlaps:NO];
	_refreshTableHeaderView.delegate = self;
	_refreshTableHeaderView.scrollView = _tableView;
	[_tableView addSubview:_refreshTableHeaderView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"Clubs" hasTranslucency:YES];
	[_headerView addButton:[[HONProfileHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)]];
	[_headerView addButton:[[HONMessagesButtonView alloc] initWithTarget:self action:@selector(_goMessages)]];
	[_headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge)]];
	[self.view addSubview:_headerView];
	
	[self _retrieveClubs];
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
- (void)_goRefresh {
	[[Mixpanel sharedInstance] track:@"Clubs - Refresh" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	[self _retrieveClubs];
}

- (void)_goProfile {
	[[Mixpanel sharedInstance] track:@"Clubs - Profile" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] init];
	userPofileViewController.userID = [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
	[navigationController setNavigationBarHidden:YES];
	[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goMessages {
	[[Mixpanel sharedInstance] track:@"Clubs - Messages" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONMessagesViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:@"Clubs - Create Challenge" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initAsNewChallenge]];
	[navigationController setNavigationBarHidden:YES];
	[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goInviteFriends {
	[[Mixpanel sharedInstance] track:@"Clubs - Invite Friends" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
}

- (void)_goInviteContacts {
	[[Mixpanel sharedInstance] track:@"Clubs - Invite Contacts" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
}

- (void)_goVerifyPhone {
	[[Mixpanel sharedInstance] track:@"Clubs - Verify Phone" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONMatchContactsViewController alloc] initAsEmailVerify:NO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}



#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self _goRefresh];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((section == 0) ? 1 : (section == 1) ? [_joinedClubs count] : 4);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (3);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rowHeader"]];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(3.0, 3.0, 200.0, 24.0)];
	label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
	label.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	label.backgroundColor = [UIColor clearColor];
	label.text = (section == 0) ? @"MY SELFIECLUB" : @"SELFIECLUBS I HAVE JOINED";
	[imageView addSubview:label];
	
	return (imageView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[UITableViewCell alloc] init];
	
	
	if (indexPath.section == 0) {
		
	
	} else if (indexPath.section == 1) {
		
	
	} else {
		cell.textLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15];
		cell.textLabel.text = [_defaultCaptions objectAtIndex:indexPath.row];
		
		if (indexPath.row == 0)
			cell.textLabel.textColor = [UIColor blackColor];
		
		else {
			cell.textLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
			cell.textLabel.textAlignment = NSTextAlignmentCenter;
		}
	}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 || indexPath.section == 1)
		return (63.0);
	
	else
		return (43.0);
	
//	if (indexPath.row == [_alertItems count] + 5)
//		return ((([_alertItems count] + 5) > 7 + ((int)([[HONDeviceTraits sharedInstance] isPhoneType5s]) * 2)) ? 49.0 : 0.0);
//	
//	return (49.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return ((section < 2) ? 24.0 : 0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return ((indexPath.section == 2 && indexPath.row == 0) ? nil : indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	if (indexPath.section == 2) {
		switch (indexPath.row - 1) {
			case 0:
				[self _goInviteFriends];
				break;
				
			case 1:
				[self _goInviteContacts];
				break;
				
			case 2:
				[self _goVerifyPhone];
				break;
								
			default:
				break;
		}
	}
}


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	//	NSLog(@"**_[scrollViewDidScroll]_** offset:[%.02f] size:[%.02f]", scrollView.contentOffset.y, scrollView.contentSize.height);
	[_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	//	NSLog(@"**_[scrollViewDidEndDragging]_** offset:[%.02f] size:[%.02f]", scrollView.contentOffset.y, scrollView.contentSize.height);
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	//	NSLog(@"**_[scrollViewDidEndScrollingAnimation]_** offset:[%.02f] size:[%.02f]", scrollView.contentOffset.y, scrollView.contentSize.height);
	[_tableView setContentOffset:CGPointZero animated:NO];
}

@end
