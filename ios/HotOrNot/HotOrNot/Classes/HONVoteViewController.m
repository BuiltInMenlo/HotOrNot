//
//  HONVoteViewController
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#import "Mixpanel.h"

#import "HONVoteViewController.h"
#import "HONVoteItemViewCell.h"
#import "HONAppDelegate.h"
#import "HONVoteHeaderView.h"
#import "HONChallengeVO.h"
#import "HONFacebookCaller.h"
#import "HONImagePickerViewController.h"
#import "HONPhotoViewController.h"
#import "HONHeaderView.h"
#import "HONVotersViewController.h"

@interface HONVoteViewController() <UIActionSheetDelegate, ASIHTTPRequestDelegate>
- (void)_retrieveChallenges;
@property(nonatomic) int subjectID;
@property(nonatomic, strong) UIImageView *toggleImgView;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *challenges;
@property(nonatomic, strong) ASIFormDataRequest *challengesRequest;
@property(nonatomic) BOOL isPushView;
@property(nonatomic, strong) HONChallengeVO *challengeVO;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@property(nonatomic, strong)  UIButton *refreshButton;
@property(nonatomic) int submitAction;
@property(nonatomic, strong) HONHeaderView *headerView;
@property(nonatomic, strong) UIImageView *emptySetImgView;
@end

@implementation HONVoteViewController
@synthesize subjectID = _subjectID;
@synthesize toggleImgView = _toggleImgView;
@synthesize tableView = _tableView;
@synthesize challenges = _challenges;
@synthesize challengesRequest = _challengesRequest;
@synthesize isPushView = _isPushView;
@synthesize challengeVO = _challengeVO;
@synthesize refreshButton = _refreshButton;
@synthesize submitAction = _submitAction;
@synthesize headerView = _headerView;
@synthesize emptySetImgView = _emptySetImgView;

- (id)init {
	if ((self = [super init])) {
		self.subjectID = 0;
		self.submitAction = 1;
		
		self.view.backgroundColor = [UIColor whiteColor];
		self.challenges = [NSMutableArray new];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteMain:) name:@"VOTE_MAIN" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteSub:) name:@"VOTE_SUB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteMore:) name:@"VOTE_MORE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshList:) name:@"REFRESH_LIST" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showVoters:) name:@"SHOW_VOTERS" object:nil];
	}
	
	return (self);
}

- (id)initWithSubject:(int)subjectID {
	if ((self = [super init])) {
		_isPushView = YES;
		
		self.subjectID = subjectID;
		
		self.view.backgroundColor = [UIColor whiteColor];
		self.challenges = [NSMutableArray new];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteMain:) name:@"VOTE_MAIN" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteSub:) name:@"VOTE_SUB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteMore:) name:@"VOTE_MORE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshList:) name:@"REFRESH_LIST" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showVoters:) name:@"SHOW_VOTERS" object:nil];
	}
	
	return (self);
}

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		_isPushView = YES;
		
		self.subjectID = 0;
		self.challengeVO = vo;
		
		self.view.backgroundColor = [UIColor whiteColor];
		self.challenges = [NSMutableArray new];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteMain:) name:@"VOTE_MAIN" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteSub:) name:@"VOTE_SUB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteMore:) name:@"VOTE_MORE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshList:) name:@"REFRESH_LIST" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showVoters:) name:@"SHOW_VOTERS" object:nil];
	}
	
	return (self);
}
							
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	//NSLog(@"SUBJECT:[%d][%d]", self.subjectID, _isPushView);
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h.png" : @"mainBG.png"];
	[self.view addSubview:bgImgView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@""];
	[self.view addSubview:_headerView];
		
	if (_isPushView) {
		UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		backButton.frame = CGRectMake(0.0, 0.0, 74.0, 44.0);
		[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
		[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
		[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addSubview:backButton];
	
	} else {
		_toggleImgView = [[UIImageView alloc] initWithFrame:CGRectMake(75.0, 1.0, 169.0, 44.0)];
		_toggleImgView.image = [UIImage imageNamed:@"toggle_trending.png"];
		[_headerView addSubview:_toggleImgView];
		
		UIButton *trendingButton = [UIButton buttonWithType:UIButtonTypeCustom];
		trendingButton.frame = CGRectMake(76.0, 5.0, 84.0, 34.0);
		[trendingButton addTarget:self action:@selector(_goTrending) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addSubview:trendingButton];
		
		UIButton *recentButton = [UIButton buttonWithType:UIButtonTypeCustom];
		recentButton.frame = CGRectMake(161.0, 5.0, 84.0, 34.0);
		[recentButton addTarget:self action:@selector(_goRecent) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addSubview:recentButton];
	}
	
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
	
	_emptySetImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 225.0, 320.0, 34.0)];
	_emptySetImgView.image = [UIImage imageNamed:@"noChallengesOverlay.png"];
	[self.view addSubview:_emptySetImgView];
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 113.0) style:UITableViewStylePlain];
	[self.tableView setBackgroundColor:[UIColor clearColor]];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.rowHeight = 249.0;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.userInteractionEnabled = YES;
	self.tableView.scrollsToTop = NO;
	self.tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:self.tableView];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Getting Challenges…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	if (self.challengeVO == nil)
		[self _retrieveChallenges];
	
	else {
		[self _retrieveSingleChallenge:self.challengeVO];
	}
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
	[self _retrieveChallenges];
	
	if ([_challenges count] == 0)
		[[[UIAlertView alloc] initWithTitle:@"Nothing Here!" message:@"No PicChallenges in session. You should start one." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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

- (void)_retrieveChallenges {
	self.challengesRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kVotesAPI]]];
	[self.challengesRequest setDelegate:self];
	[self.challengesRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	if (self.subjectID == 0)
		[self.challengesRequest setPostValue:[NSString stringWithFormat:@"%d", self.submitAction] forKey:@"action"];
	
	else {
		[self.challengesRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
		[self.challengesRequest setPostValue:[NSString stringWithFormat:@"%d", self.subjectID] forKey:@"subjectID"];
	}
	
	[self.challengesRequest startAsynchronous];
}

- (void)_retrieveSingleChallenge:(HONChallengeVO *)vo {
	self.challengesRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kVotesAPI]]];
	[self.challengesRequest setDelegate:self];
	[self.challengesRequest setPostValue:[NSString stringWithFormat:@"%d", 3] forKey:@"action"];
	[self.challengesRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[self.challengesRequest setPostValue:[NSString stringWithFormat:@"%d", vo.challengeID] forKey:@"challengeID"];
	[self.challengesRequest startAsynchronous];
}

#pragma mark - Navigation
- (void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goRefresh {
	[[Mixpanel sharedInstance] track:@"Vote Wall - Refresh"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_refreshButton.hidden = YES;
	[self _retrieveChallenges];
}

- (void)_goDailyChallenge {
	[[Mixpanel sharedInstance] track:@"Daily Challenge - Vote Wall"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithSubject:[HONAppDelegate dailySubjectName]]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:@"Create Challenge Button - Vote Wall"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	//	if (FBSession.activeSession.state == 513) {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
	
	//	} else
	//		[self _goLogin];
}

- (void)_goTrending {
	[[Mixpanel sharedInstance] track:@"Voting Toggle - Trending"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_toggleImgView.image = [UIImage imageNamed:@"toggle_trending.png"];
	self.submitAction = 1;
	
	self.challengesRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kVotesAPI]]];
	[self.challengesRequest setDelegate:self];
	[self.challengesRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[self.challengesRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
	[self.challengesRequest startAsynchronous];
}

- (void)_goRecent {
	[[Mixpanel sharedInstance] track:@"Voting Toggle - Most Recent"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];

	
	_toggleImgView.image = [UIImage imageNamed:@"toggle_recent.png"];
	self.submitAction = 4;
	
	self.challengesRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kVotesAPI]]];
	[self.challengesRequest setDelegate:self];
	[self.challengesRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[self.challengesRequest setPostValue:[NSString stringWithFormat:@"%d", 4] forKey:@"action"];
	[self.challengesRequest startAsynchronous];
}


#pragma mark - Notifications
- (void)_voteMain:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	//NSLog(@"VOTE MAIN \n%d", vo.challengeID);
	
	[[Mixpanel sharedInstance] track:@"Upvote Left"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", vo.challengeID, vo.subjectName], @"user", nil]];
	
	ASIFormDataRequest *voteRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kVotesAPI]]];
	[voteRequest setDelegate:self];
	[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
	[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[voteRequest setPostValue:[NSString stringWithFormat:@"%d", vo.challengeID] forKey:@"challengeID"];
	[voteRequest setPostValue:@"Y" forKey:@"creator"];
	[voteRequest startAsynchronous];
	
	[HONAppDelegate setVote:vo.challengeID];
}

- (void)_voteSub:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	//NSLog(@"VOTE SUB \n%d", vo.challengeID);
	
	[[Mixpanel sharedInstance] track:@"Upvote Right"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", vo.challengeID, vo.subjectName], @"user", nil]];
	
	ASIFormDataRequest *voteRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kVotesAPI]]];
	[voteRequest setDelegate:self];
	[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
	[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[voteRequest setPostValue:[NSString stringWithFormat:@"%d", vo.challengeID] forKey:@"challengeID"];
	[voteRequest setPostValue:@"N" forKey:@"creator"];
	[voteRequest startAsynchronous];
	
	[HONAppDelegate setVote:vo.challengeID];
}

- (void)_voteMore:(NSNotification *)notification {
	_challengeVO = (HONChallengeVO *)[notification object];
	
	[[Mixpanel sharedInstance] track:@"Vote - More"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"user", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																				delegate:self
																	cancelButtonTitle:@"Cancel"
															 destructiveButtonTitle:@"Report Abuse"
																	otherButtonTitles:@"Take This Challenge w/ Friends", @"Challenge This User	", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	
//	if (_isPushView)
//		[actionSheet showInView:self.view];
//	
//	else
		[actionSheet showInView:[HONAppDelegate appTabBarController].view];
}

- (void)_refreshList:(NSNotification *)notification {
	[self _retrieveChallenges];
}

- (void)_showVoters:(NSNotification *)notification {
	[[Mixpanel sharedInstance] track:@"Vote Wall - Voters"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"Y"];
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	[self.navigationController pushViewController:[[HONVotersViewController alloc] initWithChallenge:vo] animated:YES];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_challenges count] + 1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 78.0)];
	
	UIButton *createChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	createChallengeButton.frame = CGRectMake(0.0, 0.0, 320.0, 78.0);
	[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"startChallengeButton.png"] forState:UIControlStateNormal];
	[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"startChallengeButton_active.png"] forState:UIControlStateHighlighted];
	[createChallengeButton addTarget:self action:@selector(_goCreateChallenge) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:createChallengeButton];
	
	return (headerView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//static NSString * MyIdentifier = @"SNTwitterFriendViewCell_iPhone";
	
	//SNTwitterFriendViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNTwitterFriendViewCell_iPhone cellReuseIdentifier]];
	HONVoteItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	//NSMutableArray *letterArray = [_friendsDictionary objectForKey:[_sectionTitles objectAtIndex:indexPath.section]];
	
	
	if (cell == nil) {
		if (indexPath.row == 0)
			cell = [[HONVoteItemViewCell alloc] initAsTopCell:[[[HONAppDelegate infoForUser] objectForKey:@"points"] intValue] withSubject:[HONAppDelegate dailySubjectName]];
		
		else {
			HONChallengeVO *vo = (HONChallengeVO *)[_challenges objectAtIndex:indexPath.row - 1];
			
			cell = (vo.statusID == 2) ? [[HONVoteItemViewCell alloc] initAsWaitingCell] : [[HONVoteItemViewCell alloc] initAsStartedCell];
			cell.challengeVO = vo;
		}
	}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0)
		return (55.0);
	
	else
		return (424.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (78.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}


#pragma mark - ActionSheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	ASIFormDataRequest *voteRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
	UINavigationController *navigationController;
	
	NSLog(@"BUTTON:[%d][%d]", buttonIndex, actionSheet.destructiveButtonIndex);
	
	switch (buttonIndex) {
		case 0:
			[[Mixpanel sharedInstance] track:@"Vote Wall - Flag"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
														 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"user", nil]];
			
			[voteRequest setDelegate:self];
			[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 11] forKey:@"action"];
			[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
			[voteRequest setPostValue:[NSString stringWithFormat:@"%d", self.challengeVO.challengeID] forKey:@"challengeID"];
			[voteRequest startAsynchronous];
			break;
						
		case 1:
			navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithSubject:self.challengeVO.subjectName]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			break;
			
		case 2:
			navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:self.challengeVO.creatorID]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			break;
	}
}

#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"HONVoteViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	if ([request isEqual:self.challengesRequest]) {
		@autoreleasepool {
			NSError *error = nil;
			if (error != nil)
				NSLog(@"Failed to parse user JSON: %@", [error localizedDescription]);
			
			else {
				NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
				_challenges = [NSMutableArray new];
				
				NSMutableArray *list = [NSMutableArray array];
				for (NSDictionary *serverList in parsedLists) {
					HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
					//NSLog(@"VO:[%@]", vo.image2URL);
					
					if (vo != nil)
						[list addObject:vo];
				}
				
				_challenges = [list copy];
				_emptySetImgView.hidden = ([_challenges count] > 0);
				[_tableView reloadData];
			}
		}
	
	} else {
	}
	
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	_refreshButton.hidden = NO;
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
	
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
}

@end
