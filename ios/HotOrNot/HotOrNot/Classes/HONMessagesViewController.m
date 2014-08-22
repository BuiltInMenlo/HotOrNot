//
//  HONMessagesViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/18/2014 @ 14:09.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "EGORefreshTableHeaderView.h"

#import "HONMessagesViewController.h"
#import "HONHeaderView.h"
#import "HONMessageVO.h"
#import "HONMessageRecipientsViewController.h"
#import "HONMessageItemViewCell.h"
#import "HONActivityItemViewCell.h"
#import "HONMessageDetailsViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONSelfieCameraViewController.h"
#import "HONMatchContactsViewController.h"
#import "HONSearchUsersViewController.h"
#import "HONSuggestedFollowViewController.h"


@interface HONMessagesViewController () <EGORefreshTableHeaderDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) NSMutableArray *messages;
@end


@implementation HONMessagesViewController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshMessages:) name:@"REFRESH_MESSAGES" object:nil];
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
	[[HONAPICaller sharedInstance] retrieveMessagesForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSArray *result){
		_messages = [NSMutableArray array];
		for (NSDictionary *dict in result) {
			HONMessageVO *vo = [HONMessageVO messageWithDictionary:dict];
			[_messages addObject:vo];
			
			NSLog(@"MESSAGE.VIEWED:[%@]", [vo.dictionary objectForKey:@"viewed"]);
		}
		
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
		[_tableView reloadData];
	 }];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
	
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
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Messages"];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 1.0, 93.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:backButton];
	
	UIButton *createMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	createMessageButton.frame = CGRectMake(272.0, 0.0, 44.0, 44.0);
	[createMessageButton setBackgroundImage:[UIImage imageNamed:@"addMessageButton_nonActive"] forState:UIControlStateNormal];
	[createMessageButton setBackgroundImage:[UIImage imageNamed:@"addMessageButton_Active"] forState:UIControlStateHighlighted];
	[createMessageButton addTarget:self action:@selector(_goCreateMessage) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:createMessageButton];
	
	[self _retreiveMessages];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
//	if ([HONAppDelegate incTotalForCounter:@"messages"] == 1) {
//	}
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
	
	[HONAppDelegate incTotalForCounter:@"messages"];
	[self _retreiveMessages];
}

- (void)_goCreateMessage {
	[self.navigationController pushViewController:[[HONMessageRecipientsViewController alloc] init] animated:YES];
}

- (void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goMatchPhone {
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONMatchContactsViewController alloc] initAsEmailVerify:NO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goMatchEmail {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONMatchContactsViewController alloc] initAsEmailVerify:YES]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goSearch {
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSearchUsersViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goSuggested {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSuggestedFollowViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - Notifications
- (void)_refreshMessages:(NSNotification *)notification {
//	NSLog(@"_refreshMessages");
	
	if (_tableView.contentOffset.y < 150.0)
		[_tableView setContentOffset:CGPointZero animated:YES];
	
	[self _retreiveMessages];
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
- (void)messageItemViewCell:(HONMessageItemViewCell *)cell showProfileForParticipant:(HONOpponentVO *)opponentVO forMessage:(HONMessageVO *)messageVO {
	
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((section < [_messages count]) ? 1 : 4);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ([_messages count] + 1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section < [_messages count]) {
		HONMessageItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
			HONMessageVO *vo = (HONMessageVO *)[_messages objectAtIndex:indexPath.section];
			cell = [[HONMessageItemViewCell alloc] init];
			cell.messageVO = vo;
		}
		
		//cell.delegate = self;
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		return (cell);
		
	} else {
		HONActivityItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil)
			cell = [[HONActivityItemViewCell alloc] init];
		
		[cell hideChevron];
		cell.textLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15];
		cell.textLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
		cell.textLabel.text = (indexPath.row == 0) ? @"Find friends to follow" : (indexPath.row == 1) ? @"Find clubs to join" : (indexPath.row == 2) ? @"Verify you phone number" : @"";
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		
		return (cell);
	}
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section < [_messages count])
		return (74.0);
	
	else
		return ((([_messages count] + 5) > 7 + ((int)([[HONDeviceIntrinsics sharedInstance] isPhoneType5s]) * 2)) ? 49.0 : 0.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//return ((indexPath.section < [_messages count] || indexPath.row == 4) ? nil : indexPath);
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	if (indexPath.section >= [_messages count]) {
		switch (indexPath.row) {
			case HONMessageRowTypeFindFriends:
				[self _goSearch];
				break;
				
			case HONMessageRowTypeFindClubs:
				[self _goSuggested];
				break;
				
			case HONMessageRowTypeMatchPhone:
				[self _goMatchPhone];
				
			default:
				break;
		}
	
	} else {
		HONMessageItemViewCell *cell = (HONMessageItemViewCell *)[tableView cellForRowAtIndexPath:indexPath];
		HONMessageVO *messageVO = cell.messageVO;
	
				
		if (!messageVO.hasViewed)
			[[HONAPICaller sharedInstance] markMessageAsSeenForMessageID:messageVO.messageID forParticipant:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:nil];
		
		[cell updateAsSeen];
		[self.navigationController pushViewController:[[HONMessageDetailsViewController alloc] initWithMessage:messageVO] animated:YES];
	}
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
