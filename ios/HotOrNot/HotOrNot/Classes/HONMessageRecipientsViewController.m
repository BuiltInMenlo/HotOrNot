//
//  HONMessageRecipientsViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/22/2014 @ 14:50.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "EGORefreshTableHeaderView.h"

#import "HONMessageRecipientsViewController.h"
#import "HONHeaderView.h"
#import "HONTableHeaderView.h"
#import "HONMessageRecipientViewCell.h"
#import "HONSelfieCameraViewController.h"
#import "HONTrivialUserVO.h"


@interface HONMessageRecipientsViewController () <EGORefreshTableHeaderDelegate, HONMessageRecipientViewCellDelegate>
@property (nonatomic, strong) NSMutableArray *followers;
@property (nonatomic, strong) NSMutableArray *following;
@property (nonatomic, strong) NSMutableArray *selectedRecipients;
@property (nonatomic, strong) UITableView *tableView;
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
//	for (HONTrivialUserVO *vo in [HONAppDelegate followersListWithRefresh:YES]) {
//		[_followers addObject:[HONTrivialUserVO userWithDictionary:@{@"id"			: [@"" stringFromInt:vo.userID],
//																	 @"username"	: vo.username,
//																	 @"img_url"		: vo.avatarPrefix}]];
//	}
	
	_following = [NSMutableArray array];
//	for (HONTrivialUserVO *vo in [HONAppDelegate followingListWithRefresh:NO]) {
//		[_following addObject:[HONTrivialUserVO userWithDictionary:@{@"id"			: [@"" stringFromInt:vo.userID],
//																	 @"username"	: vo.username,
//																	 @"img_url"		: vo.avatarPrefix}]];
//	}
	
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
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Select"];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 1.0, 93.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:backButton];
	
	UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextButton.frame = CGRectMake(222.0, 0.0, 93.0, 44.0);
	[nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_nonActive"] forState:UIControlStateNormal];
	[nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_Active"] forState:UIControlStateHighlighted];
	[nextButton addTarget:self action:@selector(_goNext) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:nextButton];
	
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
- (void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goNext {
	if ([_selectedRecipients count] == 0) {
		[[[UIAlertView alloc] initWithTitle:@"No One Selected!"
									message:@"You need to choose at least one person."
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		
	} else {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initAsNewMessageWithRecipients:[_selectedRecipients copy]]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:nil];
	}
}

- (void)_goRefresh {
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
- (void)messageRecipientViewCell:(HONMessageRecipientViewCell *)recipientViewCell toggleSelected:(BOOL)isSelected forRecipient:(HONTrivialUserVO *)userVO {

	
	if (isSelected) {
		BOOL isFound = NO;
		for (HONTrivialUserVO *vo in _selectedRecipients) {
			if (vo.userID  == userVO.userID) {
				isFound = YES;
				break;
			}
		}
		
		if (!isFound)
			[_selectedRecipients addObject:userVO];
	
	} else {
		NSMutableArray *removeVOs = [NSMutableArray array];
		for (HONTrivialUserVO *vo in _selectedRecipients) {
			if (vo.userID  == userVO.userID)
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
	return ([[HONTableHeaderView alloc] initWithTitle:(section == 0) ? @"FOLLOWING" : @"FOLLOWERS"]);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONMessageRecipientViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		HONTrivialUserVO *vo = (indexPath.section == 0) ? (HONTrivialUserVO *)[_followers objectAtIndex:indexPath.row] : (HONTrivialUserVO *)[_following objectAtIndex:indexPath.row];
		cell = [[HONMessageRecipientViewCell alloc] init];
		cell.userVO = vo;
	}
	
	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (49.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (kOrthodoxTableHeaderHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	[(HONMessageRecipientViewCell *)[tableView cellForRowAtIndexPath:indexPath] toggleSelected];
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
