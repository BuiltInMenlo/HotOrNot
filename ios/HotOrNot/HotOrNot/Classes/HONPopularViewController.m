//
//  HONPopularViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo. All rights reserved.
//

#import "HONPopularViewController.h"
#import "HONCreateChallengeViewController.h"
#import "HONVoteViewController.h"

#import "HONPopularUserViewCell.h"
#import "HONPopularSubjectViewCell.h"
#import "HONAppDelegate.h"
#import "ASIFormDataRequest.h"

#import "HONPopularSubjectVO.h"
#import "HONPopularUserVO.h"

@interface HONPopularViewController() <ASIHTTPRequestDelegate>

@property(nonatomic) BOOL isUsersList;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *users;
@property(nonatomic, strong) NSMutableArray *subjects;
@property(nonatomic, strong) ASIFormDataRequest *subjectsRequest;
@property(nonatomic, strong) ASIFormDataRequest *usersRequest;

@end

@implementation HONPopularViewController

@synthesize tableView = _tableView;
@synthesize users = _users;
@synthesize subjects = _subjects;
@synthesize isUsersList = _isUsersList;

- (id)init {
	if ((self = [super init])) {
		self.title = NSLocalizedString(@"Popular", @"Popular");
		self.tabBarItem.image = [UIImage imageNamed:@"first"];
		
		self.users = [NSMutableArray new];
		self.subjects = [NSMutableArray new];
		
		self.isUsersList = YES;
		
		self.view.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1.0];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - 50.0) style:UITableViewStylePlain];
	[self.tableView setBackgroundColor:[UIColor clearColor]];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.rowHeight = 56.0;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.userInteractionEnabled = YES;
	self.tableView.scrollsToTop = NO;
	self.tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:self.tableView];
	
	self.usersRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kPopularAPI]]];
	[self.usersRequest setDelegate:self];
	[self.usersRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
	[self.usersRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[self.usersRequest startAsynchronous];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Navigation
- (void)_goLeaders {
	self.isUsersList = YES;
	
	self.usersRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kPopularAPI]]];
	[self.usersRequest setDelegate:self];
	[self.usersRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
	[self.usersRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[self.usersRequest startAsynchronous];
}

- (void)_goTags {
	self.isUsersList = NO;
	
	self.usersRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kPopularAPI]]];
	[self.usersRequest setDelegate:self];
	[self.usersRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
	[self.usersRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[self.usersRequest startAsynchronous];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (self.isUsersList)
		return ([self.users count]);
	
	else
		return ([self.subjects count]);
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 50.0)];
	headerView.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
	
	UIButton *leadersButton = [UIButton buttonWithType:UIButtonTypeCustom];
	leadersButton.frame = CGRectMake(20.0, 2.0, 140.0, 43.0);
	[leadersButton setBackgroundColor:[UIColor whiteColor]];
	[leadersButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_nonActive.png"] forState:UIControlStateNormal];
	[leadersButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_Active.png"] forState:UIControlStateHighlighted];
	[leadersButton addTarget:self action:@selector(_goLeaders) forControlEvents:UIControlEventTouchUpInside];
	//leadersButton = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
	[leadersButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	[leadersButton setTitle:@"Leaders" forState:UIControlStateNormal];
	[headerView addSubview:leadersButton];
	
	UIButton *tagsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	tagsButton.frame = CGRectMake(160.0, 2.0, 140.0, 43.0);
	[tagsButton setBackgroundColor:[UIColor whiteColor]];
	[tagsButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_nonActive.png"] forState:UIControlStateNormal];
	[tagsButton setBackgroundImage:[UIImage imageNamed:@"challengeButton_Active.png"] forState:UIControlStateHighlighted];
	[tagsButton addTarget:self action:@selector(_goTags) forControlEvents:UIControlEventTouchUpInside];
	//tagsButton = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
	[tagsButton setTitleColor:[UIColor colorWithWhite:0.396 alpha:1.0] forState:UIControlStateNormal];
	[tagsButton setTitle:@"Tags" forState:UIControlStateNormal];
	[headerView addSubview:tagsButton];
	
	return (headerView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (self.isUsersList) {
		HONPopularUserViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
			cell = [[HONPopularUserViewCell alloc] init];
		}
		
		cell.userVO = [_users objectAtIndex:indexPath.row];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		
		return (cell);
	
	} else {
		HONPopularSubjectViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
			cell = [[HONPopularSubjectViewCell alloc] init];
		}
		
		cell.subjectVO = [_subjects objectAtIndex:indexPath.row];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		
		return (cell);
	}
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (56.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (50.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	if (self.isUsersList) {
		NSLog(@"CHALLENGE USER");
		[self.navigationController pushViewController:[[HONCreateChallengeViewController alloc] init] animated:YES];
	
	} else {
		HONPopularSubjectVO *vo = (HONPopularSubjectVO *)[_subjects objectAtIndex:indexPath.row];
		
		NSLog(@"VOTE SUBJECT :[%@]", vo.subjectName);
		[self.navigationController pushViewController:[[HONVoteViewController alloc] initWithSubject:vo.subjectID] animated:YES];
	}
	
	//	[UIView animateWithDuration:0.25 animations:^(void) {
	//		((HONChallengeViewCell *)[tableView cellForRowAtIndexPath:indexPath]).overlayView.alpha = 1.0;
	//
	//	} completion:^(BOOL finished) {
	//		((HONChallengeViewCell *)[tableView cellForRowAtIndexPath:indexPath]).overlayView.alpha = 0.0;
	//	}];
	
	//[self.navigationController pushViewController:[[SNFriendProfileViewController alloc] initWithTwitterUser:(SNTwitterUserVO *)[_friends objectAtIndex:indexPath.row]] animated:YES];
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"HONPopularViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	
		@autoreleasepool {
			NSError *error = nil;
			if (error != nil)
				NSLog(@"Failed to parse user JSON: %@", [error localizedDescription]);
			
			else {
				NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
				
				if (_isUsersList) {
					_users = [NSMutableArray new];
					
					NSMutableArray *list = [NSMutableArray array];
					for (NSDictionary *serverList in parsedLists) {
						HONPopularUserVO *vo = [HONPopularUserVO userWithDictionary:serverList];
						NSLog(@"VO:[%d]", vo.userID);
						
						if (vo != nil)
							[list addObject:vo];
					}
					
					_users = [list copy];
				
				} else {
					_subjects = [NSMutableArray new];
					
					NSMutableArray *list = [NSMutableArray array];
					for (NSDictionary *serverList in parsedLists) {
						HONPopularSubjectVO *vo = [HONPopularSubjectVO subjectWithDictionary:serverList];
						NSLog(@"VO:[%@]", vo.subjectName);
						
						if (vo != nil)
							[list addObject:vo];
					}
					
					_subjects = [list copy];
				}
				
				[_tableView reloadData];
			}
		}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

@end
