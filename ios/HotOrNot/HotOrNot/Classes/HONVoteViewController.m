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
	//self.tableView.contentInset = UIEdgeInsetsMake(9.0, 0.0f, 9.0f, 0.0f);
	[self.view addSubview:self.tableView];
	
	if (self.challengeVO) {
		_challenges = [NSMutableArray new];
		[_challenges addObject:self.challengeVO];
	
	} else
		[self _retrieveChallenges];
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

#pragma mark - Navigation
- (void)_goBack {
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)_goRefresh {
	[self _retrieveChallenges];
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


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ([self.challenges count]);
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
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
	//	[UIView animateWithDuration:0.25 animations:^(void) {
	//		((HONChallengeViewCell *)[tableView cellForRowAtIndexPath:indexPath]).overlayView.alpha = 1.0;
	//
	//	} completion:^(BOOL finished) {
	//		((HONChallengeViewCell *)[tableView cellForRowAtIndexPath:indexPath]).overlayView.alpha = 0.0;
	//	}];
	
	//[self.navigationController pushViewController:[[SNFriendProfileViewController alloc] initWithTwitterUser:(SNTwitterUserVO *)[_friends objectAtIndex:indexPath.row]] animated:YES];
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
