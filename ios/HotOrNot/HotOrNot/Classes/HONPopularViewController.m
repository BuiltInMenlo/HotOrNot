//
//  HONPopularViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo. All rights reserved.
//

#import "Mixpanel.h"
#import "HONPopularViewController.h"
#import "HONImagePickerViewController.h"
#import "HONVoteViewController.h"
#import "HONLoginViewController.h"

#import "HONPopularUserViewCell.h"
#import "HONPopularSubjectViewCell.h"
#import "HONAppDelegate.h"
#import "ASIFormDataRequest.h"
#import "HONHeaderView.h"

#import "HONPopularSubjectVO.h"
#import "HONPopularUserVO.h"

@interface HONPopularViewController() <ASIHTTPRequestDelegate>
- (void)_retrievePopularUsers;
- (void)_retrievePopularSubjects;

@property(nonatomic) BOOL isUsersList;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIImageView *toggleImgView;
@property(nonatomic, strong) NSMutableArray *users;
@property(nonatomic, strong) NSMutableDictionary *usersDictionary;
@property(nonatomic, strong) NSMutableArray *subjects;
@property(nonatomic, strong) NSArray *sectionTitles;
@property(nonatomic, strong) ASIFormDataRequest *subjectsRequest;
@property(nonatomic, strong) ASIFormDataRequest *usersRequest;
@property(nonatomic, strong) UIButton *refreshButton;
@property(nonatomic, strong) HONHeaderView *headerView;
@property(nonatomic, strong) HONPopularUserVO *popularUserVO;
@property(nonatomic, strong) HONPopularSubjectVO *popularSubjectVO;
@end

@implementation HONPopularViewController

@synthesize tableView = _tableView;
@synthesize toggleImgView = _toggleImgView;
@synthesize users = _users;
@synthesize usersDictionary = _usersDictionary;
@synthesize subjects = _subjects;
@synthesize isUsersList = _isUsersList;
@synthesize sectionTitles = _sectionTitles;
@synthesize refreshButton = _refreshButton;
@synthesize headerView = _headerView;
@synthesize popularUserVO = _popularUserVO;
@synthesize popularSubjectVO = _popularSubjectVO;

- (id)init {
	if ((self = [super init])) {
		//self.tabBarItem.image = [UIImage imageNamed:@"tab04_nonActive"];
		self.view.backgroundColor = [UIColor whiteColor];
		
		self.users = [NSMutableArray new];
		self.usersDictionary = [NSMutableDictionary dictionary];
		self.subjects = [NSMutableArray new];
		self.sectionTitles = [NSArray arrayWithObjects:@"#", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
		
		self.isUsersList = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_randomChallenge:) name:@"RANDOM_CHALLENGE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_popularUserChallenge:) name:@"POPULAR_USER_CHALLENGE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_popularSubjectChallenge:) name:@"POPULAR_SUBJECT_CHALLENGE" object:nil];
	}
	
	return (self);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"Popular" hasFBSwitch:NO];
	[self.view addSubview:_headerView];
	
	_toggleImgView = [[UIImageView alloc] initWithFrame:CGRectMake(75.0, 0.0, 169.0, 44.0)];
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
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 108.0) style:UITableViewStylePlain];
	[self.tableView setBackgroundColor:[UIColor clearColor]];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.rowHeight = 70.0;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.userInteractionEnabled = YES;
	self.tableView.scrollsToTop = NO;
	self.tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:self.tableView];
	
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
	
	if (self.isUsersList)
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
	self.isUsersList = NO;
	_toggleImgView.image = [UIImage imageNamed:@"toggle_hashTags.png"];
	
	self.usersRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kPopularAPI]]];
	[self.usersRequest setDelegate:self];
	[self.usersRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
	[self.usersRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[self.usersRequest startAsynchronous];
}


- (void)_retrievePopularUsers {
	self.isUsersList = YES;
	_toggleImgView.image = [UIImage imageNamed:@"toggle_leaders.png"];
	
	self.usersRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kPopularAPI]]];
	[self.usersRequest setDelegate:self];
	[self.usersRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
	[self.usersRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[self.usersRequest startAsynchronous];
}


#pragma mark - Navigation
- (void)_goLeaders {
	[[Mixpanel sharedInstance] track:@"Popular Toggle - Leaders"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];

	
	self.isUsersList = YES;
	_toggleImgView.image = [UIImage imageNamed:@"toggle_leaders.png"];
	
	self.usersRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kPopularAPI]]];
	[self.usersRequest setDelegate:self];
	[self.usersRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
	[self.usersRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[self.usersRequest startAsynchronous];
}

- (void)_goTags {
	[[Mixpanel sharedInstance] track:@"Voting Toggle - Hashtags"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];

	
	self.isUsersList = NO;
	_toggleImgView.image = [UIImage imageNamed:@"toggle_hashTags.png"];
	
	self.usersRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kPopularAPI]]];
	[self.usersRequest setDelegate:self];
	[self.usersRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
	[self.usersRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[self.usersRequest startAsynchronous];
}

- (void)_goRefresh {
	[[Mixpanel sharedInstance] track:@"Refresh - Popular"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_refreshButton.hidden = YES;
	
	if (self.isUsersList)
		[self _retrievePopularUsers];
	
	else
		[self _retrievePopularSubjects];
}

#pragma mark - Notifications
- (void)_randomChallenge:(NSNotification *)notification {
	if (FBSession.activeSession.state == 513) {
		HONPopularUserVO *vo = (HONPopularUserVO *)[_users objectAtIndex:(arc4random() % [_users count])];
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:vo.userID]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:nil];
	
	} else {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONLoginViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
	}
}

- (void)_refreshList:(NSNotification *)notification {
	[_headerView updateFBSwitch];
	[self _goRefresh];
}

- (void)_popularUserChallenge:(NSNotification *)notification {
	_popularUserVO = (HONPopularUserVO *)[notification object];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Challenge User"
																	message:[NSString stringWithFormat:@"Want to challenge %@?", _popularUserVO.username]
																  delegate:self
													  cancelButtonTitle:@"Yes"
													  otherButtonTitles:@"No", nil];
	[alert show];
	
	
//	if (FBSession.activeSession.state == 513) {
//		HONPopularUserVO *vo = (HONPopularUserVO *)[notification object];
//		
//		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:vo.userID]];
//		[navigationController setNavigationBarHidden:YES];
//		[self presentViewController:navigationController animated:NO completion:nil];
//	
//	} else {
//		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONLoginViewController alloc] init]];
//		[navigationController setNavigationBarHidden:YES];
//		[self presentViewController:navigationController animated:YES completion:nil];
//	}
}

- (void)_popularSubjectChallenge:(NSNotification *)notification {
	_popularSubjectVO = (HONPopularSubjectVO *)[notification object];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Challenge User"
																	message:[NSString stringWithFormat:@"Want to start a #%@ challenge?", _popularSubjectVO.subjectName]
																  delegate:self
													  cancelButtonTitle:@"Yes"
													  otherButtonTitles:@"No", nil];
	[alert show];
		
//	if (FBSession.activeSession.state == 513) {
//		HONPopularSubjectVO *vo = (HONPopularSubjectVO *)[notification object];
//		
//		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithSubject:vo.subjectName]];
//		[navigationController setNavigationBarHidden:YES];
//		[self presentViewController:navigationController animated:NO completion:nil];
//	
//	} else {
//		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONLoginViewController alloc] init]];
//		[navigationController setNavigationBarHidden:YES];
//		[self presentViewController:navigationController animated:YES completion:nil];
//	}
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (self.isUsersList) {
		return ([_users count] + 2);
//		NSMutableArray *letterArray = [_usersDictionary objectForKey:[_sectionTitles objectAtIndex:section]];
//		return ([letterArray count]);
	
	}else
		return ([_subjects count] + 2);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (self.isUsersList) {
		HONPopularUserViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
			if (indexPath.row == 0)
				cell = [[HONPopularUserViewCell alloc] initAsTopCell:[[[HONAppDelegate infoForUser] objectForKey:@"points"] intValue] withSubject:[HONAppDelegate dailySubjectName]];
			
			else if (indexPath.row == [_users count] + 1)
				cell = [[HONPopularUserViewCell alloc] initAsBottomCell];
			
			else
				cell = [[HONPopularUserViewCell alloc] initAsMidCell:indexPath.row];
		}
		
		if (indexPath.row > 0 && indexPath.row < [_users count] + 1)
			cell.userVO = [_users objectAtIndex:indexPath.row - 1];
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		return (cell);
	
	} else {
		HONPopularSubjectViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
			if (indexPath.row == 0)
				cell = [[HONPopularSubjectViewCell alloc] initAsTopCell:[[[HONAppDelegate infoForUser] objectForKey:@"points"] intValue] withSubject:[HONAppDelegate dailySubjectName]];
			
			else if (indexPath.row == [_subjects count] + 1)
				cell = [[HONPopularSubjectViewCell alloc] initAsBottomCell];
			
			else
				cell = [[HONPopularSubjectViewCell alloc] initAsMidCell:indexPath.row];
		}
		
		if (indexPath.row > 0 && indexPath.row < [_subjects count] + 1)
			cell.subjectVO = [_subjects objectAtIndex:indexPath.row - 1];
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		return (cell);
	}
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0)
		return (24.0);
	
	else
		return (70.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	BOOL isSelectable = NO;
	
	if (self.isUsersList) {
		if (indexPath.row > 0 && indexPath.row < [_users count] + 1)
			isSelectable = YES;
	
	} else {
		if (indexPath.row > 0 && indexPath.row < [_subjects count] + 1)
			isSelectable = YES;
	}
	
	if (isSelectable)
		return (indexPath);
	
	else
		return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	[(HONBasePopularViewCell *)[tableView cellForRowAtIndexPath:indexPath] didSelect];
	
	if (self.isUsersList) {
		HONPopularUserVO *vo = (HONPopularUserVO *)[_users objectAtIndex:indexPath.row - 1];
		NSLog(@"CHALLENGE USER");
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:vo.userID]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:nil];
	
	} else {
		HONPopularSubjectVO *vo = (HONPopularSubjectVO *)[_subjects objectAtIndex:indexPath.row - 1];
		
		NSLog(@"VOTE SUBJECT :[%d]", vo.actives);
		
		if (vo.actives > 0)
			[self.navigationController pushViewController:[[HONVoteViewController alloc] initWithSubject:vo.subjectID] animated:YES];
		
		else
			[[[UIAlertView alloc] initWithTitle:@"No Challenges" message:@"No games available!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}
	
	//	[UIView animateWithDuration:0.25 animations:^(void) {
	//		((HONChallengeViewCell *)[tableView cellForRowAtIndexPath:indexPath]).overlayView.alpha = 1.0;
	//
	//	} completion:^(BOOL finished) {
	//		((HONChallengeViewCell *)[tableView cellForRowAtIndexPath:indexPath]).overlayView.alpha = 0.0;
	//	}];
	
	//[self.navigationController pushViewController:[[SNFriendProfileViewController alloc] initWithTwitterUser:(SNTwitterUserVO *)[_friends objectAtIndex:indexPath.row]] animated:YES];
}

#pragma mark - AlerView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch(buttonIndex) {
		case 0:
			if (self.isUsersList) {
				if (FBSession.activeSession.state == 513) {					
					UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:_popularUserVO.userID]];
					[navigationController setNavigationBarHidden:YES];
					[self presentViewController:navigationController animated:NO completion:nil];
					
				} else {
					UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONLoginViewController alloc] init]];
					[navigationController setNavigationBarHidden:YES];
					[self presentViewController:navigationController animated:YES completion:nil];
				}
			
			} else {
				if (FBSession.activeSession.state == 513) {
					UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithSubject:_popularSubjectVO.subjectName]];
					[navigationController setNavigationBarHidden:YES];
					[self presentViewController:navigationController animated:NO completion:nil];
					
				} else {
					UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONLoginViewController alloc] init]];
					[navigationController setNavigationBarHidden:YES];
					[self presentViewController:navigationController animated:YES completion:nil];
				}
			}
			break;
			
		case 1:
			break;
	}
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
						//NSLog(@"VO:[%d]", vo.userID);
						
						if (vo != nil)
							[list addObject:vo];
						
						for (HONPopularUserVO *vo in list) {
							NSString *firstLetter = [[vo.username substringToIndex:1] uppercaseString];
							
							if ([firstLetter isEqualToString:@"0"] || [firstLetter isEqualToString:@"1"] || [firstLetter isEqualToString:@"2"] || [firstLetter isEqualToString:@"3"] || [firstLetter isEqualToString:@"4"] || [firstLetter isEqualToString:@"5"] || [firstLetter isEqualToString:@"6"] || [firstLetter isEqualToString:@"7"] || [firstLetter isEqualToString:@"8"] || [firstLetter isEqualToString:@"9"])
								firstLetter = @"#";
							
							if ([_usersDictionary objectForKey:firstLetter] == nil) {
								NSMutableArray * tmpArray = [NSMutableArray array];
								[tmpArray addObject:vo];
								[_usersDictionary setObject:tmpArray forKey:firstLetter];
								
							} else {
								NSMutableArray *letterArray = [_usersDictionary objectForKey:firstLetter];
								[letterArray addObject:vo];
								[_usersDictionary setObject:letterArray forKey:firstLetter];
							}
						}
					}
					
					_users = [list copy];
				
				} else {
					NSArray *unsortedChallenges = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
					NSArray *parsedLists = [NSMutableArray arrayWithArray:[unsortedChallenges sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO]]]];
					
					_subjects = [NSMutableArray new];
					
					NSMutableArray *list = [NSMutableArray array];
					for (NSDictionary *serverList in parsedLists) {
						HONPopularSubjectVO *vo = [HONPopularSubjectVO subjectWithDictionary:serverList];
						//NSLog(@"VO:[%@]", vo.subjectName);
						
						if (vo != nil && [list count] < 25)
							[list addObject:vo];
					}
					
					_subjects = [list copy];
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
