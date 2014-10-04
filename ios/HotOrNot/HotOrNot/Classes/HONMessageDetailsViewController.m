//
//  HONMessageDetailsViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/19/2014 @ 15:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONMessageDetailsViewController.h"
#import "HONHeaderView.h"
#import "HONSelfieCameraViewController.h"
#import "HONMessageReplyViewCell.h"
#import "HONTrivialUserVO.h"

@interface HONMessageDetailsViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HONMessageVO *messageVO;
@end


@implementation HONMessageDetailsViewController

- (id)initWithMessage:(HONMessageVO *)messageVO {
	if ((self = [super init])) {
		_messageVO = messageVO;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshMessage:) name:@"REFRESH_MESSAGE" object:nil];
	}
	
	return (self);
}

- (BOOL)shouldAutorotate {
	return (NO);
}

#pragma mark - Data Calls
- (void)_retrieveMessage {
	[[HONAPICaller sharedInstance] retrieveMessageForMessageID:_messageVO.messageID completion:^(NSDictionary *result) {
		_messageVO = [HONMessageVO messageWithDictionary:result];
		
		[_tableView reloadData];
	}];
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	_tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_tableView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:((HONOpponentVO *)[_messageVO.participants lastObject]).username];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(6.0, 2.0, 44.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:backButton];
	
	UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	replyButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
	[replyButton setBackgroundImage:[UIImage imageNamed:@"replyButton_nonActive"] forState:UIControlStateNormal];
	[replyButton setBackgroundImage:[UIImage imageNamed:@"replyButton_Active"] forState:UIControlStateHighlighted];
	[replyButton addTarget:self action:@selector(_goReply) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:replyButton];
}

#pragma mark - Navigation
- (void)_goBack {

	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goRefresh {
		
	[HONAppDelegate incTotalForCounter:@"messages"];
	[self _retrieveMessage];
}

- (void)_goReply {

	
	NSMutableArray *recipients = [NSMutableArray array];
	for (HONOpponentVO *vo in _messageVO.participants) {
		BOOL isFound = NO;
		for (HONOpponentVO *recipientVO in recipients) {
			if (recipientVO.userID == vo.userID) {
				isFound = YES;
				break;
			}
		}
		
		if (!isFound)
			[recipients addObject:vo];
	}
	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initAsMessageReply:_messageVO withRecipients:[recipients copy]]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:NO completion:nil];
}


#pragma mark - Notifications
- (void)_refreshMessage:(NSNotification *)notification {
	NSLog(@"**_[_refreshMessage]_**");
	[self _retrieveMessage];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (2 + [_messageVO.replies count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONMessageReplyViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil) {
		cell = [[HONMessageReplyViewCell alloc] init];
		if (indexPath.section < [_messageVO.replies count] + 1) {
			HONOpponentVO *vo = (indexPath.section == [_messageVO.replies count]) ? (HONOpponentVO *)_messageVO.creatorVO : (HONOpponentVO *)[_messageVO.replies objectAtIndex:indexPath.section];
			cell.messageReplyVO = vo;
		}
	}
	
//	cell.delegate = self;
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath.section < [_messageVO.replies count] + 1 ? 310.0 : 49.0);
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

@end
