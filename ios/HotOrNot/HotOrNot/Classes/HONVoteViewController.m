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

@interface HONVoteViewController() <UIActionSheetDelegate, ASIHTTPRequestDelegate>
- (void)_retrieveChallenges;
@property(nonatomic) int subjectID;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *challenges;
@property(nonatomic, strong) ASIFormDataRequest *challengesRequest;
@property(nonatomic) BOOL isPushView;
@property(nonatomic, strong) HONChallengeVO *challengeVO;
@end

@implementation HONVoteViewController
@synthesize subjectID = _subjectID;
@synthesize tableView = _tableView;
@synthesize challenges = _challenges;
@synthesize challengesRequest = _challengesRequest;
@synthesize isPushView = _isPushView;
@synthesize challengeVO = _challengeVO;

- (id)init {
	if ((self = [super init])) {
		self.tabBarItem.image = [UIImage imageNamed:@"tab02_nonActive"];
		self.subjectID = 0;
		
		self.view.backgroundColor = [UIColor whiteColor];
		self.challenges = [NSMutableArray new];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteMain:) name:@"VOTE_MAIN" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteSub:) name:@"VOTE_SUB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteMore:) name:@"VOTE_MORE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_zoomImage:) name:@"ZOOM_IMAGE" object:nil];
	}
	
	return (self);
}

- (id)initWithSubject:(int)subjectID {
	if ((self = [super init])) {
		_isPushView = YES;
		
		self.tabBarItem.image = [UIImage imageNamed:@"tab02_nonActive"];
		self.subjectID = subjectID;
		
		self.view.backgroundColor = [UIColor whiteColor];
		self.challenges = [NSMutableArray new];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteMain:) name:@"VOTE_MAIN" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteSub:) name:@"VOTE_SUB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteMore:) name:@"VOTE_MORE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_zoomImage:) name:@"ZOOM_IMAGE" object:nil];
	}
	
	return (self);
}

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		_isPushView = YES;
		
		self.tabBarItem.image = [UIImage imageNamed:@"tab02_nonActive"];
		self.subjectID = 0;
		self.challengeVO = vo;
		
		self.view.backgroundColor = [UIColor whiteColor];
		self.challenges = [NSMutableArray new];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteMain:) name:@"VOTE_MAIN" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteSub:) name:@"VOTE_SUB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_voteMore:) name:@"VOTE_MORE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_zoomImage:) name:@"ZOOM_IMAGE" object:nil];
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
	
	UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 45.0)];
	[headerImgView setImage:[UIImage imageNamed:@"headerTitleBackground.png"]];
	headerImgView.userInteractionEnabled = YES;
	[self.view addSubview:headerImgView];
	
	if (_isPushView) {
		UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		backButton.frame = CGRectMake(5.0, 5.0, 54.0, 34.0);
		[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
		[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
		[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		//backButton = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
		[backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[backButton setTitle:@"Back" forState:UIControlStateNormal];
		[headerImgView addSubview:backButton];
	}
	
	UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
	refreshButton.frame = CGRectMake(290.0, 10.0, 20.0, 20.0);
	[refreshButton setBackgroundImage:[UIImage imageNamed:@"genericButton_nonActive.png"] forState:UIControlStateNormal];
	[refreshButton setBackgroundImage:[UIImage imageNamed:@"genericButton_Active.png"] forState:UIControlStateHighlighted];
	[refreshButton addTarget:self action:@selector(_goRefresh) forControlEvents:UIControlEventTouchUpInside];
	[headerImgView addSubview:refreshButton];
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 95.0) style:UITableViewStylePlain];
	[self.tableView setBackgroundColor:[UIColor clearColor]];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.rowHeight = 249.0;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.userInteractionEnabled = YES;
	self.tableView.scrollsToTop = NO;
	self.tableView.showsVerticalScrollIndicator = YES;
	self.tableView.contentInset = UIEdgeInsetsMake(55.0, 0.0f, 55.0f, 0.0f);
	[self.view addSubview:self.tableView];
	
	UIImageView *tableHeaderImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -55.0, 320.0, 55.0)];
	tableHeaderImgView.image = [UIImage imageNamed:@"headerBackground.png"];
	tableHeaderImgView.userInteractionEnabled = YES;
	
	UILabel *ptsLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 20.0, 50.0, 16.0)];
	//ptsLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	//ptsLabel = [SNAppDelegate snLinkColor];
	ptsLabel.backgroundColor = [UIColor clearColor];
	ptsLabel.text = [NSString stringWithFormat:@"%d", [[[HONAppDelegate infoForUser] objectForKey:@"points"] intValue]];
	[tableHeaderImgView addSubview:ptsLabel];
	
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(140.0, 20.0, 150.0, 16.0)];
	//subjectLabel = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:11];
	//subjectLabel = [SNAppDelegate snLinkColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.textAlignment = NSTextAlignmentCenter;
	subjectLabel.text = [NSString stringWithFormat:@"#%@", [HONAppDelegate dailySubjectName]];
	[tableHeaderImgView addSubview:subjectLabel];
	
	UIButton *dailyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	dailyButton.frame = CGRectMake(108.0, 5.0, 195.0, 50.0);
	[dailyButton addTarget:self action:@selector(_goDailyChallenge) forControlEvents:UIControlEventTouchUpInside];
	[tableHeaderImgView addSubview:dailyButton];
	
	[self.tableView addSubview:tableHeaderImgView];
	
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
	[self _retrieveChallenges];
}

- (void)_goDailyChallenge {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithSubject:[HONAppDelegate dailySubjectName]]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
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
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.view];
}

- (void)_zoomImage:(NSNotification *)notification {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONPhotoViewController alloc] initWithImagePath:[notification object]]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ([_challenges count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	HONVoteHeaderView *headerView = [[HONVoteHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 50.0)];
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
	return (249.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (50.0);
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
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

@end
