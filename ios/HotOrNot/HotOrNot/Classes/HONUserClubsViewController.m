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
#import "HONUserClubViewCell.h"
#import "HONUserProfileViewController.h"
#import "HONMessagesViewController.h"
#import "HONImagePickerViewController.h"
#import "HONUserClubDetailsViewController.h"
#import "HONCreateClubViewController.h"
#import "HONUserClubSettingsViewController.h"
#import "HONUserClubsSearchViewController.h"
#import "HONUserClubInviteViewController.h"
#import "HONMatchContactsViewController.h"
#import "HONUserClubVO.h"


#import "HONTrivialUserVO.h"

@interface HONUserClubsViewController () <EGORefreshTableHeaderDelegate, HONUserClubViewCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HONUserClubVO *ownClub;
@property (nonatomic, strong) NSMutableArray *joinedClubs;
@property (nonatomic, strong) HONProfileHeaderButtonView *profileHeaderButtonView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) NSArray *defaultCaptions;
@end


@implementation HONUserClubsViewController

- (id)init {
	if ((self = [super init])) {
		_defaultCaptions = @[@"Quick Links",
							 @"Find friends who have a Selfieclub",
							 @"Invite friends to my Selfieclub",
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
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Clubs"];
	[headerView addButton:[[HONProfileHeaderButtonView alloc] initWithTarget:self action:@selector(_goProfile)]];
	[headerView addButton:[[HONMessagesButtonView alloc] initWithTarget:self action:@selector(_goMessages)]];
	[headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge)]];
	[self.view addSubview:headerView];
	
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
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]] animated:YES];
	
	//:/>
//	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]];
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goMessages {
	[[Mixpanel sharedInstance] track:@"Clubs - Messages" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	[self.navigationController pushViewController:[[HONMessagesViewController alloc] init] animated:YES];
}

- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:@"Clubs - Create Challenge" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initAsNewChallenge]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goClubSettings:(HONUserClubVO *)userClubVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	properties[@"club"] = [NSString stringWithFormat:@"%d - %@", userClubVO.clubID, userClubVO.clubName];
	[[Mixpanel sharedInstance] track:@"Clubs - Settings" properties:properties];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goClubDetails:(HONUserClubVO *)userClubVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	properties[@"club"] = [NSString stringWithFormat:@"%d - %@", userClubVO.clubID, userClubVO.clubName];
	[[Mixpanel sharedInstance] track:@"Clubs - Details" properties:properties];
	
	[self.navigationController pushViewController:[[HONUserClubDetailsViewController alloc] init] animated:YES];
}

- (void)_goFindSelfieclubs {
	[[Mixpanel sharedInstance] track:@"Clubs - Find Selfieclubs" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUserClubsSearchViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goInviteFriends {
	[[Mixpanel sharedInstance] track:@"Clubs - Invite Friends" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUserClubInviteViewController alloc] initAsModal:YES]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goVerifyPhone {
	[[Mixpanel sharedInstance] track:@"Clubs - Verify Phone" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONMatchContactsViewController alloc] initAsEmailVerify:NO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - UserClubViewCell Delegates
- (void)userClubViewCell:(HONUserClubViewCell *)cell settingsForClub:(HONUserClubVO *)userClubVO {
	NSMutableDictionary *properties = [[[HONAnalyticsParams sharedInstance] userProperty] mutableCopy];
	properties[@"club"] = [NSString stringWithFormat:@"%d - %@", userClubVO.clubID, userClubVO.clubName];
	[[Mixpanel sharedInstance] track:@"Clubs - Settings" properties:properties];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUserClubSettingsViewController alloc] init]];
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
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 4.0, 200.0, 16.0)];
	label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:11];
	label.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	label.backgroundColor = [UIColor clearColor];
	label.text = (section == 0) ? @"MY CLUBS" : @"CLUBS I HAVE JOINED";
	[imageView addSubview:label];
	
	return (imageView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONUserClubViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONUserClubViewCell alloc] init];
	
	
	if (indexPath.section == 0) {
		if (_ownClub == nil) {
			cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rowBackground"]];
			cell.textLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15];
			cell.textLabel.text = @"Tap here to start your own Selfieclub";
			cell.textLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
			cell.textLabel.textAlignment = NSTextAlignmentCenter;
		
		} else {
			cell.userClubVO = _ownClub;
			cell.delegate = self;
		}
		
	} else if (indexPath.section == 1) {
		cell.userClubVO = [_joinedClubs objectAtIndex:indexPath.row];
		cell.delegate = self;
	
	} else {
		cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rowBackground"]];
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
	
	if (indexPath.section == 0) {
		if (_ownClub == nil) {
			[[Mixpanel sharedInstance] track:@"Clubs - Create Club" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
			
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			
		} else
			[self _goClubDetails:_ownClub];
		
	} else if (indexPath.section == 1)
		[self _goClubDetails:(HONUserClubVO *)[_joinedClubs objectAtIndex:indexPath.row]];
		
	else if (indexPath.section == 2) {
		switch (indexPath.row - 1) {
			case 0:
				[self _goFindSelfieclubs];
				break;
				
			case 1:
//				if (_ownClub != nil)
					[self _goInviteFriends];
				
//				else {
//					[[[UIAlertView alloc] initWithTitle:@"You Don't Have a Selfieclub!"
//												message:@"You need to create your Selfieclub before inviting someone."
//											   delegate:nil
//									  cancelButtonTitle:@"OK"
//									  otherButtonTitles:nil] show];
//				}
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
