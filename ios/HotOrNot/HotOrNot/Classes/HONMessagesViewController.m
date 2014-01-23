//
//  HONMessagesViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/18/2014 @ 14:09.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "EGORefreshTableHeaderView.h"

#import "HONMessagesViewController.h"
#import "HONAPICaller.h"
#import "HONDeviceTraits.h"
#import "HONChangeAvatarViewController.h"
#import "HONImagePickerViewController.h"
#import "HONMessageRecipientsViewController.h"
#import "HONHeaderView.h"
#import "HONCreateSnapButtonView.h"
#import "HONMessageItemViewCell.h"
#import "HONMessageVO.h"
#import "HONMessageDetailsViewController.h"


@interface HONMessagesViewController () <EGORefreshTableHeaderDelegate, HONMessageItemViewCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@end


@implementation HONMessagesViewController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedMessagesTab:) name:@"SELECTED_MESSAGES_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tareMessagesTab:) name:@"TARE_MESSAGES_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshMessagesTab:) name:@"REFRESH_MESSAGES_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshMessagesTab:) name:@"REFRESH_ALL_TABS" object:nil];
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
- (void)_retreiveMessages {
	[[HONAPICaller sharedInstance] retrieveMessagesForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result){
		_messages = [NSMutableArray array];
		for (NSDictionary *dict in (NSArray *)result) {
			HONMessageVO *vo = [HONMessageVO messageWithDictionary:dict];
			[_messages addObject:vo];
		}
		
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
		[_tableView reloadData];
	 }];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	_messages = [NSMutableArray array];
	
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
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"Messages" hasTranslucency:YES];
	[_headerView addButton:[[HONProfileHeaderButtonView alloc] initWithTarget:self action:@selector(_goCreateMessage)]];
	[_headerView addButton:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge)]];
	[self.view addSubview:_headerView];
	
	[self _retreiveMessages];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if ([HONAppDelegate incTotalForCounter:@"messages"] == 1) {
		_tutorialImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
		_tutorialImageView.image = [UIImage imageNamed:([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? @"tutorial_home-568h@2x" : @"tutorial_home"];
		_tutorialImageView.userInteractionEnabled = YES;
		_tutorialImageView.alpha = 0.0;
		
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.frame = CGRectMake(241.0, ([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? 97.0 : 50.0, 44.0, 44.0);
		[closeButton setBackgroundImage:[UIImage imageNamed:@"tutorial_closeButton_nonActive"] forState:UIControlStateNormal];
		[closeButton setBackgroundImage:[UIImage imageNamed:@"tutorial_closeButton_Active"] forState:UIControlStateHighlighted];
		[closeButton addTarget:self action:@selector(_goRemoveTutorial) forControlEvents:UIControlEventTouchDown];
		[_tutorialImageView addSubview:closeButton];
		
		UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		avatarButton.frame = CGRectMake(-1.0, ([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? 416.0 : 374.0, 320.0, 64.0);
		[avatarButton setBackgroundImage:[UIImage imageNamed:@"tutorial_profilePhoto_nonActive"] forState:UIControlStateNormal];
		[avatarButton setBackgroundImage:[UIImage imageNamed:@"tutorial_profilePhoto_Active"] forState:UIControlStateHighlighted];
		[avatarButton addTarget:self action:@selector(_goTakeAvatar) forControlEvents:UIControlEventTouchDown];
		[_tutorialImageView addSubview:avatarButton];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_tutorialImageView];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_tutorialImageView.alpha = 1.0;
		}];
	}
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
	[[Mixpanel sharedInstance] track:@"Messages - Refresh"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[HONAppDelegate incTotalForCounter:@"messages"];
	[self _retreiveMessages];
}

- (void)_goCreateMessage {
	[[Mixpanel sharedInstance] track:@"Messages - Create Message"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONMessageRecipientsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:@"Messages - Create Volley"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initAsNewChallenge]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goTakeAvatar {
	[[Mixpanel sharedInstance] track:@"Timeline - Take New Avatar"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		if (_tutorialImageView != nil) {
			_tutorialImageView.alpha = 0.0;
		}
	} completion:^(BOOL finished) {
		if (_tutorialImageView != nil) {
			[_tutorialImageView removeFromSuperview];
			_tutorialImageView = nil;
		}
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:nil];
	}];
}

- (void)_goRemoveTutorial {
	[UIView animateWithDuration:0.25 animations:^(void) {
		if (_tutorialImageView != nil) {
			_tutorialImageView.alpha = 0.0;
		}
	} completion:^(BOOL finished) {
	}];
}


#pragma mark - Notifications
- (void)_selectedMessagesTab:(NSNotification *)notification {
//	[_tableView setContentOffset:CGPointMake(0.0, -64.0) animated:YES];
	//[self _retrieveChallenges];
	
	if (_tutorialImageView != nil) {
		[_tutorialImageView removeFromSuperview];
		_tutorialImageView = nil;
	}
}

- (void)_refreshMessagesTab:(NSNotification *)notification {
	//	NSLog(@"_refreshHomeTab");
	
	if (_tableView.contentOffset.y < 150.0)
		[_tableView setContentOffset:CGPointZero animated:YES];
	
	[self _retreiveMessages];
}

- (void)_tareMessagesTab:(NSNotification *)notification {
	NSLog(@"::|> tareMessagesTab <|::");
	
	if (_tableView.contentOffset.y > 0) {
		_tableView.pagingEnabled = NO;
		[_tableView setContentOffset:CGPointZero animated:YES];
	}
}


#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
//	NSLog(@"**_[egoRefreshTableHeaderDidTriggerRefresh]_**");
	[self _goRefresh];
}

- (void)egoRefreshTableHeaderDidFinishTareAnimation:(EGORefreshTableHeaderView *)view {
//	NSLog(@"**_[egoRefreshTableHeaderDidFinishTareAnimation]_**");
}


#pragma mark - MessageItemViewCell Delegates
- (void)messageItemViewCell:(HONMessageItemViewCell *)cell showProfileForUserID:(int)userID forMessage:(HONMessageVO *)messageVO {
	[[Mixpanel sharedInstance] track:@"Messages - Show Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
}

- (void)messageItemViewCell:(HONMessageItemViewCell *)cell showMessage:(HONMessageVO *)messageVO {
	[[Mixpanel sharedInstance] track:@"Messages - Show Details"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if (!messageVO.hasViewed) {
		NSMutableArray *userIDs = [NSMutableArray array];
		for (HONOpponentVO *vo in messageVO.participants)
			[userIDs addObject:[NSString stringWithFormat:@"%d", vo.userID]];
		
		[[HONAPICaller sharedInstance] markMessageAsSeenForMessageID:messageVO.messageID withUsers:userIDs completion:nil];
	}
	
	[cell updateAsSeen];
	[self.navigationController pushViewController:[[HONMessageDetailsViewController alloc] initWithMessage:messageVO] animated:YES];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ([_messages count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONMessageItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		HONMessageVO *vo = (HONMessageVO *)[_messages objectAtIndex:indexPath.section];
		cell = [[HONMessageItemViewCell alloc] init];
		cell.messageVO = vo;
	}
	
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
}


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	//	NSLog(@"**_[scrollViewDidScroll]_** offset:[%.02f] size:[%.02f]", scrollView.contentOffset.y, scrollView.contentSize.height);
	[_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	//	NSLog(@"**_[scrollViewDidEndDragging]_** offset:[%.02f] inset:[%.02f]", scrollView.contentOffset.y, scrollView.contentInset.top);
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}




@end
