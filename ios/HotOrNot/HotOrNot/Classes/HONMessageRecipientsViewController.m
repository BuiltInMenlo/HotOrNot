//
//  HONMessageRecipientsViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/22/2014 @ 14:50.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "EGORefreshTableHeaderView.h"

#import "HONMessageRecipientsViewController.h"
#import "HONColorAuthority.h"
#import "HONHeaderView.h"
#import "HONMessageRecipientVO.h"
#import "HONMessageRecipientViewCell.h"
#import "HONImagePickerViewController.h"
#import "HONUserVO.h"


@interface HONMessageRecipientsViewController () <EGORefreshTableHeaderDelegate, HONMessageRecipientViewCellDelegate>
@property (nonatomic, strong) NSMutableArray *followers;
@property (nonatomic, strong) NSMutableArray *following;
@property (nonatomic, strong) NSMutableArray *selectedRecipients;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@end


@implementation HONMessageRecipientsViewController

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
- (void)_buildRecipients {
	_followers = [NSMutableArray array];
	for (HONUserVO *vo in [HONAppDelegate followersListWithRefresh:YES]) {
		[_followers addObject:[HONMessageRecipientVO recipientWithDictionary:@{@"id"		: [NSString stringWithFormat:@"%d", vo.userID],
																			   @"username"	: vo.username,
																			   @"avatar"	: vo.avatarPrefix}]];
	}
	
	_following = [NSMutableArray array];
	for (HONUserVO *vo in [HONAppDelegate followingListWithRefresh:NO]) {
		[_following addObject:[HONMessageRecipientVO recipientWithDictionary:@{@"id"		: [NSString stringWithFormat:@"%d", vo.userID],
																			   @"username"	: vo.username,
																			   @"avatar"	: vo.avatarPrefix}]];
	}
	
	[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
	[_tableView reloadData];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	_selectedRecipients = [NSMutableArray array];
	
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
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	
	_headerView = [[HONHeaderView alloc] initAsModalWithTitle:@"Recipients" hasTranslucency:YES];
	[_headerView addButton:doneButton];
	[self.view addSubview:_headerView];
	
	[self _buildRecipients];
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
	if ([_selectedRecipients count] == 0) {
		[[Mixpanel sharedInstance] track:@"Message Recipients - Cancel"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		[self.navigationController dismissViewControllerAnimated:YES completion:nil];
		
	} else {
		[[Mixpanel sharedInstance] track:@"Message Recipients - Create Message"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initAsMessageToRecipients:[_selectedRecipients copy]]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:nil];
	}
}

- (void)_goRefresh {
	[[Mixpanel sharedInstance] track:@"Message Recipients - Refresh"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	[self _buildRecipients];
}

#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
//	NSLog(@"**_[egoRefreshTableHeaderDidTriggerRefresh]_**");
	[self _goRefresh];
}

- (void)egoRefreshTableHeaderDidFinishTareAnimation:(EGORefreshTableHeaderView *)view {
//	NSLog(@"**_[egoRefreshTableHeaderDidFinishTareAnimation]_**");
}


#pragma mark - MessageRecipientViewCell Delegates
- (void)messageRecipientViewCell:(HONMessageRecipientViewCell *)recipientViewCell toggleSelected:(BOOL)isSelected forRecipient:(HONMessageRecipientVO *)messageRecipientVO {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Message Recipients - %@elect Recipient", (isSelected) ? @"S" : @"D"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", messageRecipientVO.userID, messageRecipientVO.username], @"recipient", nil]];
	
	
	if (isSelected) {
		BOOL isFound = NO;
		for (HONMessageRecipientVO *vo in _selectedRecipients) {
			if (vo.userID  == messageRecipientVO.userID) {
				isFound = YES;
				break;
			}
		}
		
		if (!isFound)
			[_selectedRecipients addObject:messageRecipientVO];
	
	} else {
		NSMutableArray *removeVOs = [NSMutableArray array];
		for (HONMessageRecipientVO *vo in _selectedRecipients) {
			if (vo.userID  == messageRecipientVO.userID)
				[removeVOs addObject:vo];
		}
		
		[_selectedRecipients removeObjectsInArray:removeVOs];
		removeVOs = nil;
	}
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((section == 0) ? [_followers count] : [_following count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (2);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIImageView *headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraTableHeader"]];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 0.0, 320.0, kOrthodoxTableHeaderHeight - 1.0)];
	label.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:13];
	label.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor]; //	[HONAppDelegate honPercentGreyscaleColor:0.467]
	label.backgroundColor = [UIColor clearColor];
	label.text = (section == 0) ? @"Following…" : @"Followers…";
	[headerImageView addSubview:label];
	
	return (headerImageView);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONMessageRecipientViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		HONMessageRecipientVO *vo = (indexPath.section == 0) ? (HONMessageRecipientVO *)[_followers objectAtIndex:indexPath.row] : (HONMessageRecipientVO *)[_following objectAtIndex:indexPath.row];
		cell = [[HONMessageRecipientViewCell alloc] init];
		cell.messageRecipientVO = vo;
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
	return (kOrthodoxTableHeaderHeight);
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
