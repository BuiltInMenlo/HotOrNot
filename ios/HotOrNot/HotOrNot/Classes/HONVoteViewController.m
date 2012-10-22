//
//  HONVoteViewController
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONVoteViewController.h"
#import "HONVoteItemViewCell.h"
#import "ASIFormDataRequest.h"
#import "HONAppDelegate.h"
#import "HONVoteHeaderView.h"
#import "HONChallengeVO.h"
#import "HONFacebookCaller.h"
#import "HONImagePickerViewController.h"
#import "HONPhotoViewController.h"
#import "HONHeaderView.h"

@interface HONVoteViewController() <UIActionSheetDelegate, ASIHTTPRequestDelegate>
- (void)_retrieveChallenges;
@property(nonatomic) int subjectID;
@property(nonatomic, strong) UIImageView *toggleImgView;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *challenges;
@property(nonatomic, strong) ASIFormDataRequest *challengesRequest;
@property(nonatomic) BOOL isPushView;
@property(nonatomic, strong) HONChallengeVO *challengeVO;
@property(nonatomic, strong)  UIButton *refreshButton;
@property(nonatomic) int submitAction;
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

- (id)init {
	if ((self = [super init])) {
		self.subjectID = 0;
		
		self.view.backgroundColor = [UIColor whiteColor];
		self.challenges = [NSMutableArray new];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteMain:) name:@"VOTE_MAIN" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteSub:) name:@"VOTE_SUB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteMore:) name:@"VOTE_MORE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_zoomImage:) name:@"ZOOM_IMAGE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshList:) name:@"REFRESH_LIST" object:nil];
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
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_zoomImage:) name:@"ZOOM_IMAGE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshList:) name:@"REFRESH_LIST" object:nil];
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
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_zoomImage:) name:@"ZOOM_IMAGE" object:nil];
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
	
	NSLog(@"SUBJECT:[%d][%d]", self.subjectID, _isPushView);
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@""];
	[self.view addSubview:headerView];
		
	if (_isPushView) {
		UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		backButton.frame = CGRectMake(5.0, 0.0, 74.0, 44.0);
		[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
		[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
		[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:backButton];
	}
	
	_toggleImgView = [[UIImageView alloc] initWithFrame:CGRectMake(75.0, 0.0, 169.0, 44.0)];
	_toggleImgView.image = [UIImage imageNamed:@"toggle_trending.png"];
	[headerView addSubview:_toggleImgView];
	
	UIButton *trendingButton = [UIButton buttonWithType:UIButtonTypeCustom];
	trendingButton.frame = CGRectMake(76.0, 5.0, 84.0, 34.0);
	[trendingButton addTarget:self action:@selector(_goTrending) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:trendingButton];
	
	UIButton *recentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	recentButton.frame = CGRectMake(161.0, 5.0, 84.0, 34.0);
	[recentButton addTarget:self action:@selector(_goRecent) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:recentButton];
	
	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	activityIndicatorView.frame = CGRectMake(282.0, 12.0, 24.0, 24.0);
	[activityIndicatorView startAnimating];
	[headerView addSubview:activityIndicatorView];
	
	_refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_refreshButton.frame = CGRectMake(270.0, 0.0, 50.0, 45.0);
	[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_nonActive.png"] forState:UIControlStateNormal];
	[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_Active.png"] forState:UIControlStateHighlighted];
	[_refreshButton addTarget:self action:@selector(_goRefresh) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:_refreshButton];
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 108.0) style:UITableViewStylePlain];
	[self.tableView setBackgroundColor:[UIColor clearColor]];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.rowHeight = 249.0;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.userInteractionEnabled = YES;
	self.tableView.scrollsToTop = NO;
	self.tableView.showsVerticalScrollIndicator = YES;
	//self.tableView.contentInset = UIEdgeInsetsMake(70.0, 0.0, 0.0, 0.0);
	//self.tableView.contentOffset = CGPointMake(0.0, -70.0);
	[self.view addSubview:self.tableView];
	
	UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, -70.0, 320.0, 70.0)];
	tableHeaderView.userInteractionEnabled = YES;
	
	UIButton *dailyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	dailyButton.frame = CGRectMake(0.0, 0.0, 320.0, 70.0);
	[dailyButton setBackgroundImage:[UIImage imageNamed:@"headerTableRow_nonActive.png"] forState:UIControlStateNormal];
	[dailyButton setBackgroundImage:[UIImage imageNamed:@"headerTableRow_Active.png"] forState:UIControlStateHighlighted];
	[dailyButton addTarget:self action:@selector(_goDailyChallenge) forControlEvents:UIControlEventTouchUpInside];
	[tableHeaderView addSubview:dailyButton];
	
	UILabel *ptsLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 40.0, 50.0, 16.0)];
	ptsLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
	ptsLabel.textColor = [HONAppDelegate honBlueTxtColor];
	ptsLabel.backgroundColor = [UIColor clearColor];
	ptsLabel.text = [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"points"] intValue]];
	[tableHeaderView addSubview:ptsLabel];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0, 40.0, 140.0, 16.0)];
	subjectLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
	subjectLabel.textColor = [HONAppDelegate honBlueTxtColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.textAlignment = NSTextAlignmentCenter;
	subjectLabel.text = [NSString stringWithFormat:@"#%@", [HONAppDelegate dailySubjectName]];
	[tableHeaderView addSubview:subjectLabel];
	//[self.tableView addSubview:tableHeaderView];
	
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
	self.challengesRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
	[self.challengesRequest setDelegate:self];
	[self.challengesRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	if (self.subjectID == 0)
		[self.challengesRequest setPostValue:[NSString stringWithFormat:@"%d", 5] forKey:@"action"];
	
	else {
		[self.challengesRequest setPostValue:[NSString stringWithFormat:@"%d", 7] forKey:@"action"];
		[self.challengesRequest setPostValue:[NSString stringWithFormat:@"%d", self.subjectID] forKey:@"subjectID"];
	}
	
	[self.challengesRequest startAsynchronous];
}

- (void)_retrieveSingleChallenge:(HONChallengeVO *)vo {
	self.challengesRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
	[self.challengesRequest setDelegate:self];
	[self.challengesRequest setPostValue:[NSString stringWithFormat:@"%d", 13] forKey:@"action"];
	[self.challengesRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[self.challengesRequest setPostValue:[NSString stringWithFormat:@"%d", vo.challengeID] forKey:@"challengeID"];
	[self.challengesRequest startAsynchronous];
}

#pragma mark - Navigation
- (void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goRefresh {
	_refreshButton.hidden = YES;
	[self _retrieveChallenges];
}

- (void)_goDailyChallenge {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithSubject:[HONAppDelegate dailySubjectName]]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goTrending {
	_toggleImgView.image = [UIImage imageNamed:@"toggle_trending.png"];
	self.submitAction = 5;
	
	self.challengesRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
	[self.challengesRequest setDelegate:self];
	[self.challengesRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[self.challengesRequest setPostValue:[NSString stringWithFormat:@"%d", 5] forKey:@"action"];
	[self.challengesRequest startAsynchronous];
}

- (void)_goRecent {
	_toggleImgView.image = [UIImage imageNamed:@"toggle_recent.png"];
	self.submitAction = 14;
	
	self.challengesRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
	[self.challengesRequest setDelegate:self];
	[self.challengesRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[self.challengesRequest setPostValue:[NSString stringWithFormat:@"%d", 14] forKey:@"action"];
	[self.challengesRequest startAsynchronous];
}


#pragma mark - Notifications
- (void)_voteMain:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	NSLog(@"VOTE MAIN \n%d", vo.challengeID);
	
	ASIFormDataRequest *voteRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
	[voteRequest setDelegate:self];
	[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
	[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[voteRequest setPostValue:[NSString stringWithFormat:@"%d", vo.challengeID] forKey:@"challengeID"];
	[voteRequest setPostValue:@"Y" forKey:@"creator"];
	[voteRequest startAsynchronous];
}

- (void)_voteSub:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	NSLog(@"VOTE SUB \n%d", vo.challengeID);
	
	ASIFormDataRequest *voteRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
	[voteRequest setDelegate:self];
	[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
	[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[voteRequest setPostValue:[NSString stringWithFormat:@"%d", vo.challengeID] forKey:@"challengeID"];
	[voteRequest setPostValue:@"N" forKey:@"creator"];
	[voteRequest startAsynchronous];
}

- (void)_voteMore:(NSNotification *)notification {
	_challengeVO = (HONChallengeVO *)[notification object];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																				delegate:self
																	cancelButtonTitle:@"Cancel"
															 destructiveButtonTitle:nil
																	otherButtonTitles:@"Flag Challenge", @"Share Challenge", @"ReChallenge", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	[actionSheet showInView:[HONAppDelegate appTabBarController].view];
}

- (void)_zoomImage:(NSNotification *)notification {
	NSDictionary *dict = (NSDictionary *)[notification object];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONPhotoViewController alloc] initWithImagePath:[dict objectForKey:@"img"] withTitle:[dict objectForKey:@"title"]]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_refreshList:(NSNotification *)notification {
	[self _retrieveChallenges];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ([_challenges count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	HONVoteHeaderView *headerView = [[HONVoteHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 54.0)];
	[headerView setChallengeVO:[_challenges objectAtIndex:section]];
	
	return (headerView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//static NSString * MyIdentifier = @"SNTwitterFriendViewCell_iPhone";
	
	//SNTwitterFriendViewCell_iPhone *cell = [tableView dequeueReusableCellWithIdentifier:[SNTwitterFriendViewCell_iPhone cellReuseIdentifier]];
	HONVoteItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	//NSMutableArray *letterArray = [_friendsDictionary objectForKey:[_sectionTitles objectAtIndex:indexPath.section]];
	
	
	if (cell == nil) {
		cell = [[HONVoteItemViewCell alloc] init];
	}
	
	cell.challengeVO = [_challenges objectAtIndex:indexPath.section];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (340.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (54.0);
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
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:self.challengeVO.creatorID]];
	
	NSLog(@"BUTTON:[%d]", buttonIndex);
	
	switch (buttonIndex ) {
		case 0:
			[voteRequest setDelegate:self];
			[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
			[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
			[voteRequest setPostValue:[NSString stringWithFormat:@"%d", self.challengeVO.challengeID] forKey:@"challengeID"];
			[voteRequest setPostValue:@"N" forKey:@"creator"];
			[voteRequest startAsynchronous];
			break;
			
		case 1:
			[HONFacebookCaller postToActivity:self.challengeVO withAction:@"share"];
			break;
			
		case 2:
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			break;
			
		case 3:
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
				[_tableView reloadData];
			}
		}
	
	} else {
	}
	
	_refreshButton.hidden = NO;
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

@end
