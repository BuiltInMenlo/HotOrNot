//
//  HONUserClubViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 02/27/2014 @ 10:31 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "EGORefreshTableHeaderView.h"
#import "JLBPopSlideTransition.h"
#import "MBProgressHUD.h"

#import "HONUserClubsViewController.h"

#import "HONTableHeaderView.h"
#import "HONUserClubViewCell.h"
#import "HONChangeAvatarViewController.h"
#import "HONCreateClubViewController.h"
#import "HONUserClubSettingsViewController.h"
#import "HONUserClubInviteViewController.h"
#import "HONFeedViewController.h"
#import "HONUserClubVO.h"


#import "HONTrivialUserVO.h"

@interface HONUserClubsViewController () <EGORefreshTableHeaderDelegate, HONUserClubViewCellDelegate>
@property (nonatomic, strong) UIViewController *wrapperViewController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HONUserClubVO *ownClub;
@property (nonatomic, strong) HONUserClubVO *selectedClub;
@property (nonatomic, strong) NSMutableArray *joinedClubs;
@property (nonatomic, strong) NSMutableArray *invitedClubs;
@property (nonatomic, strong) HONProfileHeaderButtonView *profileHeaderButtonView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSArray *defaultCaptions;
@property (nonatomic, strong) NSArray *bakedClubs;
@property (nonatomic, strong) NSArray *bakedClubs2;
@end


@implementation HONUserClubsViewController

- (id)initWithWrapperViewController:(UIViewController *)wrapperViewController {
	if ((self = [super init])) {
		_wrapperViewController = wrapperViewController;
		
		_defaultCaptions = @[];
		_defaultCaptions = @[@"Add friends to my club",
							 @"Find my high school's club"];
				
		_joinedClubs = [NSMutableArray array];
		_invitedClubs = [NSMutableArray array];
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

- (void)refresh {
	[self _goRefresh];
}

- (void)tare {
	[_tableView setContentOffset:CGPointMake(0.0, -64.0) animated:YES];
}


#pragma mark - Data Calls
- (void)_retrieveClubs {
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	_joinedClubs = [NSMutableArray array];
	[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		if ([[((NSDictionary *)result) objectForKey:@"owned"] count] > 0)
			_ownClub = [HONUserClubVO clubWithDictionary:[[((NSDictionary *)result) objectForKey:@"owned"] objectAtIndex:0]];
			//_ownClub = [HONUserClubVO clubWithDictionary:[((NSDictionary *)result) objectForKey:@"owned"]];
		
		
		for (NSDictionary *dict in [((NSDictionary *)result) objectForKey:@"joined"])
			[_joinedClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
		
		
		// --//> *** POPULATED FPO CLUBS *** <//-- //
		for (NSDictionary *dict in [[HONClubAssistant sharedInstance] fpoJoinedClubs]) {
			[_joinedClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
		} // --//> *** POPULATED FPO CLUBS *** <//-- //
		
		
		[self _retreiveClubInvites];
	}];
}

- (void)_retreiveClubInvites {
	_invitedClubs = [NSMutableArray array];
		
	[[HONAPICaller sharedInstance] retrieveClubInvitesForUserWithUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		for (NSDictionary *dict in (NSArray *)result)
			[_invitedClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
		
		
		// --//> *** POPULATED FPO CLUBS *** <//-- //
		for (NSDictionary *dict in [[HONClubAssistant sharedInstance] fpoInviteClubs]) {
			[_invitedClubs addObject:[HONUserClubVO clubWithDictionary:dict]];
		} // --//> *** POPULATED FPO CLUBS *** <//-- //
		
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		self.view.hidden = NO;
		[_tableView reloadData];
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
	}];
}

- (void)_joinClub:(HONUserClubVO *)vo {
	[[HONAPICaller sharedInstance] joinClub:vo withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		[self _retrieveClubs];
	}];
}

- (void)_leaveClub:(HONUserClubVO *)vo {
	[[HONAPICaller sharedInstance] leaveClub:vo withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
		[self _retrieveClubs];
	}];
}


- (void)_retrieveChallenges {
	NSMutableArray *challenges = [NSMutableArray array];
	[[HONAPICaller sharedInstance] retrieveChallengesForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result){
		for (NSDictionary *dict in (NSArray *)result) {
			HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:dict];
			[challenges addObject:vo];
		}
		
		HONFeedViewController *feedViewController = [[HONFeedViewController alloc] init];
		feedViewController.challenges = challenges;
		JLBPopSlideTransition *transition = [JLBPopSlideTransition new];
		feedViewController.transitioningDelegate = transition;
		[_wrapperViewController presentViewController:feedViewController animated:YES completion:nil];
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	
	self.view.frame = CGRectMake(0.0, kNavHeaderHeight + 55.0, 320.0, [UIScreen mainScreen].bounds.size.height - (kNavHeaderHeight + 55.0));
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.view.frame.size.height) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	[_tableView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 49.0, 0.0)];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_tableView];
	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0, -_tableView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height) usingTareOffset:0.0];
	_refreshTableHeaderView.delegate = self;
	_refreshTableHeaderView.scrollView = _tableView;
	[_tableView addSubview:_refreshTableHeaderView];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self tare];
	self.view.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidAppear:animated];
	
	[self _retrieveClubs];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
- (void)_goRefresh {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"My Clubs - Refresh"];
	
	[self _retrieveClubs];
}

- (void)_goClubSettings:(HONUserClubVO *)userClubVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"My Clubs - Settings"
									   withUserClub:userClubVO];
		
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[_wrapperViewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goInviteFriends {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"My Clubs - Invite Friends"];
	
	if (_ownClub == nil) {
		[[[UIAlertView alloc] initWithTitle:@"You Haven't Created A Club!"
									message:@"You need to create your own club before inviting anyone."
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	
	} else {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUserClubInviteViewController alloc] initWithClub:_ownClub]];
		[navigationController setNavigationBarHidden:YES];
		[_wrapperViewController presentViewController:navigationController animated:YES completion:nil];
	}
}

- (void)_goFindSchoolClub {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"My Clubs - Find High School"];
	
	[[[UIAlertView alloc] initWithTitle:@"No clubs found nearby!"
								message:@"Check back later"
							   delegate:nil
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}

- (void)_goFindNearbyClubs {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Clubs - Nearby Clubs"];
	
	[[[UIAlertView alloc] initWithTitle:@"No clubs found nearby!"
								message:@"Check back later"
							   delegate:nil
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}

- (void)_goShare {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"My Clubs - Share"];
	
	NSString *igCaption = [NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"]];
	NSString *twCaption = [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *fbCaption = [NSString stringWithFormat:[HONAppDelegate facebookShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *smsCaption = [NSString stringWithFormat:[HONAppDelegate smsShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *emailCaption = [[[[HONAppDelegate emailShareCommentForIndex:1] objectForKey:@"subject"] stringByAppendingString:@"|"] stringByAppendingString:[NSString stringWithFormat:[[HONAppDelegate emailShareCommentForIndex:1] objectForKey:@"body"], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[igCaption, twCaption, fbCaption, smsCaption, emailCaption],
																							@"image"			: ([[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"] rangeOfString:@"defaultAvatar"].location == NSNotFound) ? [HONAppDelegate avatarImage] : [HONImagingDepictor shareTemplateImageForType:HONImagingDepictorShareTemplateTypeDefault],
																							@"url"				: [[HONAppDelegate infoForUser] objectForKey:@"avatar_url"],
																							@"mp_event"			: @"User Profile - Share",
																							@"view_controller"	: self}];
}


#pragma mark - UserClubViewCell Delegates
- (void)userClubViewCell:(HONUserClubViewCell *)cell acceptInviteForClub:(HONUserClubVO *)userClubVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"My Clubs - Accept Invite"
									   withUserClub:userClubVO];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Accept Invite to the %@ club?", userClubVO.clubName]
														message:@""
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:0];
	[alertView show];
}

- (void)userClubViewCell:(HONUserClubViewCell *)cell settingsForClub:(HONUserClubVO *)userClubVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"My Clubs - Edit Settings"
									   withUserClub:userClubVO];
		
	_selectedClub = userClubVO;
	
	if (userClubVO.clubID == _ownClub.clubID) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUserClubSettingsViewController alloc] initWithClub:_ownClub]];
		[navigationController setNavigationBarHidden:YES];
		[_wrapperViewController presentViewController:navigationController animated:YES completion:nil];

	} else {
//		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUserClubSettingsViewController alloc] initWithClub:userClubVO]];
//		[navigationController setNavigationBarHidden:YES];
//		[_wrapperViewController presentViewController:navigationController animated:YES completion:nil];
		
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
																 delegate:self
														cancelButtonTitle:@"Cancel"
												   destructiveButtonTitle:nil
														otherButtonTitles:@"Quit this club", nil];
		[actionSheet setTag:0];
		[actionSheet showInView:self.view];
	}
}


#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self _goRefresh];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((section == 0) ? 1 + [_joinedClubs count] : [_invitedClubs count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (2);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);//[[HONTableHeaderView alloc] initWithTitle:(section == 0) ? @"CLUBS" : @"ACCEPT"]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONUserClubViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONUserClubViewCell alloc] initAsInviteCell:(indexPath.section == 1)];
	
	
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			if (_ownClub == nil) {
				//cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewCellBG_normal"]];
				cell.textLabel.frame = CGRectOffset(cell.textLabel.frame, 0.0, -2.0);
				cell.textLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:12];
				cell.textLabel.textColor = [UIColor blackColor];
				cell.textLabel.textAlignment = NSTextAlignmentLeft;
				cell.textLabel.text = @"Create club";
				
				UIImageView *plusImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"createClubButton_nonActive"]];
				plusImageView.frame = CGRectOffset(plusImageView.frame, 240.0, 5.0);
				[cell.contentView addSubview:plusImageView];
				
			} else {
				cell.userClubVO = _ownClub;
				cell.delegate = self;
			}
		
		} else {
			cell.userClubVO = (HONUserClubVO *)[_joinedClubs objectAtIndex:indexPath.row - 1]; //>-1
			cell.delegate = self;
		}
		
	} else if (indexPath.section == 1) {
		cell.userClubVO = [_invitedClubs objectAtIndex:indexPath.row];
		cell.delegate = self;
	}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (84.0);
	
	if (indexPath.section == 0 || indexPath.section == 1)
		return (kOrthodoxTableCellHeight);
	
	else
		return (45.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);//(section == 0 || section == 1) ? kOrthodoxTableHeaderHeight : 0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			if (_ownClub == nil) {
				[[HONAnalyticsParams sharedInstance] trackEvent:@"My Clubs - Create Club"];
				
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] init]];
				[navigationController setNavigationBarHidden:YES];
				[_wrapperViewController presentViewController:navigationController animated:YES completion:nil];
				
			} else {
				
				[self _retrieveChallenges];
			}
		
		} else {
			[self _retrieveChallenges];
		}
		
	} else if (indexPath.section == 1) {
		HONUserClubVO *vo = (HONUserClubVO *)[_invitedClubs objectAtIndex:indexPath.row];
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Accept Invite to the %@ club?", vo.clubName]
															message:@""
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"Yes", nil];
		[alertView setTag:0];
		[alertView show];
		
	} else if (indexPath.section == 2) {
		if (indexPath.row == 0)
			[self _goInviteFriends];
			
		else if (indexPath.row == 1)
			[self _goFindSchoolClub];
		
//		else if (indexPath.row == 2)
//			[self _goShare];//[self _goFindNearbyClubs];
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


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"My Clubs - Settings " stringByAppendingString:(buttonIndex == 0) ? @"Quit" : @"Cancel"]
										   withUserClub:_selectedClub];
		
		if (buttonIndex == 0)
			[self _leaveClub:_selectedClub];
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"My Clubs - Accept Invite " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]
										   withUserClub:_selectedClub];		
		if (buttonIndex == 1)
			[self _joinClub:_selectedClub];
	}
}

@end
