//
//  HONPopularViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo. All rights reserved.
//

#import "ASIFormDataRequest.h"
#import "Mixpanel.h"

#import "HONPopularViewController.h"
#import "HONImagePickerViewController.h"
#import "HONVoteViewController.h"
#import "HONLoginViewController.h"
#import "HONPopularUserViewCell.h"
#import "HONPopularSubjectViewCell.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"
#import "HONChallengeTableHeaderView.h"
#import "HONPopularSubjectVO.h"
#import "HONPopularUserVO.h"

@interface HONPopularViewController() <ASIHTTPRequestDelegate>
- (void)_retrievePopularUsers;
- (void)_retrievePopularSubjects;

@property(nonatomic) BOOL isUsersList;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIImageView *toggleImgView;
@property(nonatomic, strong) NSMutableArray *users;
@property(nonatomic, strong) NSMutableArray *subjects;
@property(nonatomic, strong) UIButton *refreshButton;
@property(nonatomic, strong) HONHeaderView *headerView;
@property(nonatomic, strong) HONPopularUserVO *popularUserVO;
@property(nonatomic, strong) HONPopularSubjectVO *popularSubjectVO;
@end

@implementation HONPopularViewController

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor whiteColor];
		
		_users = [NSMutableArray new];
		_subjects = [NSMutableArray new];
		_isUsersList = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_popularUserChallenge:) name:@"POPULAR_USER_CHALLENGE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_popularSubjectChallenge:) name:@"POPULAR_SUBJECT_CHALLENGE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshList:) name:@"REFRESH_LIST" object:nil];
	}
	
	return (self);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h.png" : @"mainBG.png"];
	[self.view addSubview:bgImgView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"Popular"];
	[self.view addSubview:_headerView];
	
	_toggleImgView = [[UIImageView alloc] initWithFrame:CGRectMake(75.0, 1.0, 169.0, 44.0)];
	_toggleImgView.image = [UIImage imageNamed:@"toggle_leaders.png"];
	[_headerView addSubview:_toggleImgView];
	
	UIButton *leadersButton = [UIButton buttonWithType:UIButtonTypeCustom];
	leadersButton.frame = CGRectMake(76.0, 5.0, 84.0, 34.0);
	[leadersButton addTarget:self action:@selector(_goLeaders) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:leadersButton];
	
	UIButton *tagsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	tagsButton.frame = CGRectMake(161.0, 5.0, 84.0, 34.0);
	[tagsButton addTarget:self action:@selector(_goTags) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:tagsButton];
	
	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	activityIndicatorView.frame = CGRectMake(284.0, 10.0, 24.0, 24.0);
	[activityIndicatorView startAnimating];
	[_headerView addSubview:activityIndicatorView];
	
	_refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_refreshButton.frame = CGRectMake(270.0, 0.0, 50.0, 45.0);
	[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_nonActive.png"] forState:UIControlStateNormal];
	[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_Active.png"] forState:UIControlStateHighlighted];
	[_refreshButton addTarget:self action:@selector(_goRefresh) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:_refreshButton];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 108.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 70.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	[self _retrievePopularUsers];
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
	
	if (_isUsersList)
		[self _retrievePopularUsers];
	
	else
		[self _retrievePopularSubjects];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (NO);//interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)_retrievePopularSubjects {
	_isUsersList = NO;
	_toggleImgView.image = [UIImage imageNamed:@"toggle_hashTags.png"];
	
	ASIFormDataRequest *subjectsRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kPopularAPI]]];
	[subjectsRequest setDelegate:self];
	[subjectsRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
	[subjectsRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[subjectsRequest startAsynchronous];
}


- (void)_retrievePopularUsers {
	_isUsersList = YES;
	_toggleImgView.image = [UIImage imageNamed:@"toggle_leaders.png"];
	
	ASIFormDataRequest *usersRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kPopularAPI]]];
	[usersRequest setDelegate:self];
	[usersRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
	[usersRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[usersRequest startAsynchronous];
}


#pragma mark - Navigation
- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:@"Create Challenge Button - Popular"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
//	if (FBSession.activeSession.state == 513) {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
	
//	} else
//		[self _goLogin];
}

- (void)_goInviteFriends {
	[[Mixpanel sharedInstance] track:@"Invite Friends - Popular"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"INVITE_FRIENDS" object:nil];
}

- (void)_goLeaders {
	[[Mixpanel sharedInstance] track:@"Popular Toggle - Leaders"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];

	[self _retrievePopularUsers];
}

- (void)_goTags {
	[[Mixpanel sharedInstance] track:@"Voting Toggle - Hashtags"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];

	[self _retrievePopularSubjects];
}

- (void)_goRefresh {
	[[Mixpanel sharedInstance] track:@"Refresh - Popular"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_refreshButton.hidden = YES;
	
	if (_isUsersList)
		[self _retrievePopularUsers];
	
	else
		[self _retrievePopularSubjects];
}

#pragma mark - Notifications
- (void)_refreshList:(NSNotification *)notification {
	[_tableView setContentOffset:CGPointZero animated:YES];
	_refreshButton.hidden = YES;
	
	if (_isUsersList)
		[self _retrievePopularUsers];
	
	else
		[self _retrievePopularSubjects];
}

- (void)_popularUserChallenge:(NSNotification *)notification {
	_popularUserVO = (HONPopularUserVO *)[notification object];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Challenge User"
																	message:[NSString stringWithFormat:@"Want to challenge %@?", _popularUserVO.username]
																  delegate:self
													  cancelButtonTitle:@"Yes"
													  otherButtonTitles:@"No", nil];
	[alert show];
}

- (void)_popularSubjectChallenge:(NSNotification *)notification {
	_popularSubjectVO = (HONPopularSubjectVO *)[notification object];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Challenge User"
																	message:[NSString stringWithFormat:@"Want to start a %@ challenge?", _popularSubjectVO.subjectName]
																  delegate:self
													  cancelButtonTitle:@"Yes"
													  otherButtonTitles:@"No", nil];
	[alert show];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (_isUsersList) {
		return ([_users count] + 1);
	
	} else
		return ([_subjects count] + 1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	HONChallengeTableHeaderView *headerView = [[HONChallengeTableHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 78.0)];
	[headerView.inviteFriendsButton addTarget:self action:@selector(_goInviteFriends) forControlEvents:UIControlEventTouchUpInside];
	[headerView.dailyChallengeButton addTarget:self action:@selector(_goCreateChallenge) forControlEvents:UIControlEventTouchUpInside];
	
	return (headerView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_isUsersList) {
		HONPopularUserViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
//			if (indexPath.row == 0) {
//				int score = [[[HONAppDelegate infoForUser] objectForKey:@"points"] intValue] + ([[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue] * [HONAppDelegate votePointMultiplier]) + ([[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue] * [HONAppDelegate pokePointMultiplier]);
//				cell = [[HONPopularUserViewCell alloc] initAsTopCell:score withSubject:[HONAppDelegate dailySubjectName]];
//			
//			} else if (indexPath.row == [_users count] + 1)
			if (indexPath.row == [_users count])
				cell = [[HONPopularUserViewCell alloc] initAsBottomCell];
			
			else
				cell = [[HONPopularUserViewCell alloc] initAsMidCell:indexPath.row];
		}
		
		if (indexPath.row < [_users count])
			cell.userVO = [_users objectAtIndex:indexPath.row];
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		return (cell);
	
	} else {
		HONPopularSubjectViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
//			if (indexPath.row == 0) {
//				int score = [[[HONAppDelegate infoForUser] objectForKey:@"points"] intValue] + ([[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue] * [HONAppDelegate votePointMultiplier]) + ([[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue] * [HONAppDelegate pokePointMultiplier]);
//				cell = [[HONPopularSubjectViewCell alloc] initAsTopCell:score withSubject:[HONAppDelegate dailySubjectName]];
//			
//			} else if (indexPath.row == [_subjects count] + 1)
			if (indexPath.row == [_subjects count])
				cell = [[HONPopularSubjectViewCell alloc] initAsBottomCell];
			
			else
				cell = [[HONPopularSubjectViewCell alloc] initAsMidCell:indexPath.row];
		}
		
		if (indexPath.row < [_subjects count])
			cell.subjectVO = [_subjects objectAtIndex:indexPath.row];
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		return (cell);
	}
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (70.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (78.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	[(HONBasePopularViewCell *)[tableView cellForRowAtIndexPath:indexPath] didSelect];
	
	if (_isUsersList) {
		HONPopularUserVO *vo = (HONPopularUserVO *)[_users objectAtIndex:indexPath.row];
		//NSLog(@"CHALLENGE USER");
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:vo.userID]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:nil];
	
	} else {
		HONPopularSubjectVO *vo = (HONPopularSubjectVO *)[_subjects objectAtIndex:indexPath.row];
		
		//NSLog(@"VOTE SUBJECT :[%d]", vo.actives);
		
		if (vo.actives > 0)
			[self.navigationController pushViewController:[[HONVoteViewController alloc] initWithSubject:vo.subjectID] animated:YES];
		
		else
			[[[UIAlertView alloc] initWithTitle:@"No Challenges" message:@"No games available!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}
}

#pragma mark - AlerView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch(buttonIndex) {
		case 0:
			if (_isUsersList) {
//				if (FBSession.activeSession.state == 513) {					
					UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:_popularUserVO.userID]];
					[navigationController setNavigationBarHidden:YES];
					[self presentViewController:navigationController animated:NO completion:nil];
					
//				} else {
//					UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONLoginViewController alloc] init]];
//					[navigationController setNavigationBarHidden:YES];
//					[self presentViewController:navigationController animated:YES completion:nil];
//				}
			
			} else {
//				if (FBSession.activeSession.state == 513) {
					UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithSubject:_popularSubjectVO.subjectName]];
					[navigationController setNavigationBarHidden:YES];
					[self presentViewController:navigationController animated:NO completion:nil];
					
//				} else {
//					UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONLoginViewController alloc] init]];
//					[navigationController setNavigationBarHidden:YES];
//					[self presentViewController:navigationController animated:YES completion:nil];
//				}
			}
			break;
			
		case 1:
			break;
	}
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request {
	//NSLog(@"HONPopularViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
		@autoreleasepool {
			NSError *error = nil;
			if (error != nil)
				NSLog(@"Failed to parse user JSON: %@", [error localizedDescription]);
			
			else {
				NSArray *unsortedList = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
				
				if (_isUsersList) {
					_users = [NSMutableArray new];
					for (NSDictionary *serverList in unsortedList) {
						HONPopularUserVO *vo = [HONPopularUserVO userWithDictionary:serverList];
						//NSLog(@"VO:[%d]", vo.userID);
						
						if (vo != nil)
							[_users addObject:vo];
					}
					
					NSArray * sortedUsers = [_users sortedArrayUsingDescriptors:
													 [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO]]];
					_users = [NSMutableArray arrayWithArray:sortedUsers];
					
				} else {
					NSArray * parsedLists = [unsortedList sortedArrayUsingDescriptors:
													 [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO]]];
					
					_subjects = [NSMutableArray new];
					for (NSDictionary *serverList in parsedLists) {
						HONPopularSubjectVO *vo = [HONPopularSubjectVO subjectWithDictionary:serverList];
						//NSLog(@"VO:[%@]", vo.subjectName);
						
						if (vo != nil)
							[_subjects addObject:vo];
					}
				}
				
				[_tableView reloadData];
			}
		}
	_refreshButton.hidden = NO;
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

@end
