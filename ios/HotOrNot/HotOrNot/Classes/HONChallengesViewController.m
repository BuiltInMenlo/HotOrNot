//
//  HONChallengesViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "ASIFormDataRequest.h"
#import "UIImageView+WebCache.h"
#import <KiipSDK/KiipSDK.h>
#import "Mixpanel.h"
#import "MBProgressHUD.h"
#import "TapForTap.h"

#import "HONAppDelegate.h"
#import "HONChallengesViewController.h"
#import "HONChallengeViewCell.h"
#import "HONChallengeVO.h"
#import "HONSettingsViewController.h"
#import "HONImagePickerViewController.h"
#import "HONLoginViewController.h"
#import "HONPhotoViewController.h"
#import "HONVoteViewController.h"
#import "HONResultsViewController.h"
#import "HONHeaderView.h"
#import "HONFacebookCaller.h"
#import "HONChallengePreviewView.h"


@interface HONChallengesViewController() <UIAlertViewDelegate, UIGestureRecognizerDelegate, FBLoginViewDelegate, ASIHTTPRequestDelegate, TapForTapAdViewDelegate>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *challenges;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@property(nonatomic) BOOL isFirstRun;
@property(nonatomic) BOOL isMoreLoading;
@property(nonatomic, strong) UIImageView *tutorialOverlayImgView;
@property(nonatomic, strong) NSDate *lastDate;
@property(nonatomic, strong) HONChallengeVO *challengeVO;
@property(nonatomic, strong) NSIndexPath *idxPath;
@property(nonatomic, strong) UIButton *refreshButton;
@property(nonatomic, strong) HONHeaderView *headerView;
@property(nonatomic, strong) NSMutableArray *friends;
@property(nonatomic, retain) HONChallengePreviewView *previewView;
@property(nonatomic) int blockCounter;

- (void)_retrieveChallenges;
- (void)_retrieveUser;
@end

@implementation HONChallengesViewController

@synthesize tableView = _tableView;
@synthesize challenges = _challenges;
@synthesize isFirstRun = _isFirstRun;
@synthesize tutorialOverlayImgView = _tutorialOverlayImgView;
@synthesize lastDate = _lastDate;
@synthesize challengeVO = _challengeVO;
@synthesize idxPath = _idxPath;
@synthesize refreshButton = _refreshButton;
@synthesize headerView = _headerView;
@synthesize isMoreLoading = _isMoreLoading;

- (id)init {
	if ((self = [super init])) {
		//self.tabBarItem.image = [UIImage imageNamed:@"tab01_nonActive"];
		self.challenges = [NSMutableArray array];
		self.isFirstRun = YES;
		_blockCounter = 0;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showPreview:) name:@"SHOW_PREVIEW" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_dailyChallenge:) name:@"DAILY_CHALLENGE" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_nextChallengeBlock:) name:@"NEXT_CHALLENGE_BLOCK" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshList:) name:@"REFRESH_LIST" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showTutorial:) name:@"SHOW_TUTORIAL" object:nil];
	}
	
	return (self);
}
							
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	NSLog(@"self.view.bounds:[%fx%f][%fx%f]", self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -45.0, 320.0, self.view.bounds.size.height)];
	//bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"backgroundBG-568h.png" : @"backgroundBG.png"];
	bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h.png" : @"mainBG.png"];
	[self.view addSubview:bgImgView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"Challenges"];
	[self.view addSubview:_headerView];
	
	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	activityIndicatorView.frame = CGRectMake(284.0, 10.0, 24.0, 24.0);
	[activityIndicatorView startAnimating];
	[_headerView addSubview:activityIndicatorView];
	
	UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	inviteButton.frame = CGRectMake(270.0, 0.0, 50.0, 45.0);
	[inviteButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_nonActive.png"] forState:UIControlStateNormal];
	[inviteButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_Active.png"] forState:UIControlStateHighlighted];
	[inviteButton addTarget:self action:@selector(_goInvite) forControlEvents:UIControlEventTouchUpInside];
	inviteButton.hidden = (FBSession.activeSession.state != 513);
	[_headerView addSubview:inviteButton];
	
	_refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_refreshButton.frame = CGRectMake(270.0, 0.0, 50.0, 45.0);
	[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_nonActive.png"] forState:UIControlStateNormal];
	[_refreshButton setBackgroundImage:[UIImage imageNamed:@"refreshButton_Active.png"] forState:UIControlStateHighlighted];
	[_refreshButton addTarget:self action:@selector(_goRefresh) forControlEvents:UIControlEventTouchUpInside];
	//[_headerView addSubview:_refreshButton];
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 45.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 113.0) style:UITableViewStylePlain];
	[self.tableView setBackgroundColor:[UIColor clearColor]];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.rowHeight = 70.0;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.userInteractionEnabled = YES;
	self.tableView.scrollsToTop = NO;
	self.tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:self.tableView];
	
	[self _retrieveChallenges];
	[self _retrieveUser];
	
	
	UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
	lpgr.minimumPressDuration = 1.0;
	lpgr.delegate = self;
	[self.tableView addGestureRecognizer:lpgr];
	
	[[Kiip sharedInstance] saveMoment:@"Test Moment" withCompletionHandler:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// banner
	if ([HONAppDelegate isTapForTapEnabled])
		[self.view addSubview:[[TapForTapAdView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 50.0, 320.0, 50.0) delegate:self]];
	
	// ad modal
//	[TapForTapInterstitial prepare];
//	[TapForTapInterstitial showWithRootViewController: self]; // or possibly self.navigationController
	
	// app wall
//	[TapForTapAppWall prepare];
//	[TapForTapAppWall showWithRootViewController: self]; // or possibly self.navigationController
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	//NSLog(@"viewDidAppear");
	
	[self _retrieveChallenges];
	[self _retrieveUser];
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

- (void)_goLogin {
	NSLog(@"_goLogin");
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONLoginViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_retrieveChallenges {
	_isMoreLoading = YES;
	
	ASIFormDataRequest *challengeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
	[challengeRequest setDelegate:self];
	[challengeRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
	[challengeRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[challengeRequest setTag:1];
	[challengeRequest startAsynchronous];
}

- (void)_retrieveUser {
	if ([HONAppDelegate infoForUser]) {
		ASIFormDataRequest *userRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kUsersAPI]]];
		[userRequest setDelegate:self];
		[userRequest setPostValue:[NSString stringWithFormat:@"%d", 5] forKey:@"action"];
		[userRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
		[userRequest setTag:0];
		[userRequest startAsynchronous];
	}
}


-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[gestureRecognizer locationInView:self.tableView]];
	HONChallengeVO *vo = (HONChallengeVO *)[_challenges objectAtIndex:indexPath.row - 1];
	self.challengeVO = vo;
	
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		if (indexPath == nil)
			NSLog(@"long press on table view but not on a row");
		
		else {
			NSLog(@"long press on table view at row %d", indexPath.row);
			
			if ([vo.status isEqualToString:@"Accept"]) {
				_previewView = [[HONChallengePreviewView alloc] initWithFrame:CGRectMake(7.0, 70.0, 320.0, (kLargeH * 0.5)) withCreator:vo];
				[self.view addSubview:_previewView];
			
			} else if ([vo.status isEqualToString:@"Waiting"]) {
				_previewView = [[HONChallengePreviewView alloc] initWithFrame:CGRectMake(7.0, 70.0, 320.0, (kLargeH * 0.5)) withCreator:vo];
				[self.view addSubview:_previewView];
			
			} else if ([vo.status isEqualToString:@"Started"] || [vo.status isEqualToString:@"Completed"]) {
				NSString *msg = (vo.scoreCreator > vo.scoreChallenger) ? [NSString stringWithFormat:@"You are winning this challenge! %d to %d! Do you want to challenge another friend?", vo.scoreCreator, vo.scoreChallenger] : [NSString stringWithFormat:@"You are losing this challenge! %d to %d! Do you want to challenge another friend?", vo.scoreCreator, vo.scoreChallenger];
				
				if (vo.scoreCreator == vo.scoreChallenger)
					msg = [NSString stringWithFormat:@"You are tied in this challenge! %d to %d! Do you want to challenge another friend?", vo.scoreCreator, vo.scoreChallenger];
				
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Challenge Stats"
																					 message:msg
																					delegate:self
																		cancelButtonTitle:@"Yes"
																		otherButtonTitles:@"No", nil];
				[alertView setTag:3];
				[alertView show];
			}
		}
	
	} else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		if (_previewView != nil) {
			[_previewView removeFromSuperview];
			_previewView = nil;
		}
		
		if ([vo.status isEqualToString:@"Accept"]) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Accept Challenge"
																				 message:@"Do you want to accept this challenge? (Tip: Tap and hold to view images.)"
																				delegate:self
																	cancelButtonTitle:@"Yes"
																	otherButtonTitles:@"No", nil];
			[alertView setTag:2];
			[alertView show];
		}
	}
}

#pragma mark - Navigation
- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:@"Create Challenge Button - Challenge Wall"
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
	[[Mixpanel sharedInstance] track:@"Invite Friends - Challenge Wall"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"INVITE_FRIENDS" object:nil];
	
	_friends = [NSMutableArray array];
	
	[FBRequestConnection startWithGraphPath:@"me/friends" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
		//NSLog(@"FRIENDS:[%@]", (NSDictionary *)result);
		for (NSDictionary *friend in [(NSDictionary *)result objectForKey:@"data"])
			[_friends addObject: [friend objectForKey:@"id"]];
		
		NSLog(@"RETRIEVED (%d) FRIENDS", [_friends count]);
	}];
}

- (void)_goInvite {
	NSRange range;
	range.length = 50;
	range.location = _blockCounter * range.length;
	
	if (range.location >= [_friends count])
		range.location = 0;
	
	if (range.location + range.length > [_friends count])
		range.length = [_friends count] - range.location;
	
	NSLog(@"INVITING (%d-%d)/%d", range.location, range.location + range.length, [_friends count]);
	[HONFacebookCaller sendAppRequestBroadcastWithIDs:[_friends subarrayWithRange:range]];
	_blockCounter++;
}

- (void)_goRefresh {
	[[Mixpanel sharedInstance] track:@"Challenge Wall - Refresh"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_refreshButton.hidden = YES;
	[self _retrieveChallenges];
	[self _retrieveUser];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Refreshing…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
}

- (void)_goTutorialCancel {
	int boot_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"boot_total"] intValue];
	boot_total++;
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:boot_total] forKey:@"boot_total"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	_tutorialOverlayImgView.hidden = YES;
	[_tutorialOverlayImgView removeFromSuperview];
	
	[self _retrieveChallenges];
	[self _retrieveUser];
}

- (void)_goTutorialClose {
	[[Mixpanel sharedInstance] track:@"Tutorial Challenge Button"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	int boot_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"boot_total"] intValue];
	boot_total++;
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:boot_total] forKey:@"boot_total"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	_tutorialOverlayImgView.hidden = YES;
	[_tutorialOverlayImgView removeFromSuperview];
	
	[self _retrieveChallenges];
	[self _retrieveUser];
	[self _goCreateChallenge];
}


#pragma mark - Notifications
- (void)_showPreview:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONPhotoViewController alloc] initWithImagePath:vo.imageURL withTitle:vo.subjectName]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_dailyChallenge:(NSNotification *)notification {
//	if (FBSession.activeSession.state == 513) {
	[[Mixpanel sharedInstance] track:@"Daily Challenge - Challenge Wall"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initAsDailyChallenge:[HONAppDelegate dailySubjectName]]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:nil];
	
//	} else
//		[self _goLogin];
}

- (void)_nextChallengeBlock:(NSNotification *)notification {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	ASIFormDataRequest *nextChallengesRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
	[nextChallengesRequest setDelegate:self];
	[nextChallengesRequest setPostValue:[NSString stringWithFormat:@"%d", 12] forKey:@"action"];
	[nextChallengesRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[nextChallengesRequest setPostValue:[dateFormat stringFromDate:self.lastDate] forKey:@"datetime"];
	[nextChallengesRequest setTag:2];
	[nextChallengesRequest startAsynchronous];
}

- (void)_refreshList:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
	
	[_tableView setContentOffset:CGPointZero animated:YES];
	[self _retrieveChallenges];
	[self _retrieveUser];
}

- (void)_showTutorial:(NSNotification *)notification {
	NSString *buttonImage;// = [NSString stringWithFormat:@"tutorial_00%d.png", ((arc4random() % 4) + 1)];
	
	int ind = (arc4random() % 4) + 1;
	[[Mixpanel sharedInstance] track:@"Tutorial"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d", ind], @"index", nil]];
	
	
	if ([HONAppDelegate isRetina5])
		buttonImage = [NSString stringWithFormat:@"tutorial_00%d-568h.png", ind];
	
	else
		buttonImage = [NSString stringWithFormat:@"tutorial_00%d.png", ind];
	
	_tutorialOverlayImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 10.0, 320.0, ([HONAppDelegate isRetina5]) ? 558.0 : 470.0)];
	_tutorialOverlayImgView.image = [UIImage imageNamed:buttonImage];
	_tutorialOverlayImgView.userInteractionEnabled = YES;
	[[[UIApplication sharedApplication] delegate].window addSubview:_tutorialOverlayImgView];
	
	UIButton *closeTutorialButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeTutorialButton.frame = _tutorialOverlayImgView.frame;
	[closeTutorialButton addTarget:self action:@selector(_goTutorialCancel) forControlEvents:UIControlEventTouchUpInside];
	[_tutorialOverlayImgView addSubview:closeTutorialButton];
	
	UIButton *createChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	createChallengeButton.frame = CGRectMake(0.0, 55.0, 320.0, 78.0);
	[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"startChallengeButtonClear.png"] forState:UIControlStateNormal];
	[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"startChallengeButtonClear_active.png"] forState:UIControlStateHighlighted];
	[createChallengeButton addTarget:self action:@selector(_goTutorialClose) forControlEvents:UIControlEventTouchUpInside];
	[_tutorialOverlayImgView addSubview:createChallengeButton];
	
	UIButton *createChallenge2Button = [UIButton buttonWithType:UIButtonTypeCustom];
	createChallenge2Button.frame = CGRectMake(128.0, _tutorialOverlayImgView.frame.size.height - 48.0, 64.0, 48.0);
	[createChallenge2Button setBackgroundImage:[UIImage imageNamed:@"tabbar_003_nonActive.png"] forState:UIControlStateNormal];
	[createChallenge2Button setBackgroundImage:[UIImage imageNamed:@"tabbar_003_active.png"] forState:UIControlStateHighlighted];
	[createChallenge2Button addTarget:self action:@selector(_goTutorialClose) forControlEvents:UIControlEventTouchUpInside];
	[_tutorialOverlayImgView addSubview:createChallenge2Button];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([self.challenges count] + 2);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 78.0)];
	
	UIButton *createChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	createChallengeButton.frame = CGRectMake(0.0, 0.0, 160.0, 78.0);
	[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"startChallengeButton.png"] forState:UIControlStateNormal];
	[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"startChallengeButton_active.png"] forState:UIControlStateHighlighted];
	[createChallengeButton addTarget:self action:@selector(_goCreateChallenge) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:createChallengeButton];
	
	UIButton *inviteFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	inviteFriendsButton.frame = CGRectMake(160.0, 0.0, 160.0, 78.0);
	[inviteFriendsButton setBackgroundImage:[UIImage imageNamed:@"startChallengeButton.png"] forState:UIControlStateNormal];
	[inviteFriendsButton setBackgroundImage:[UIImage imageNamed:@"startChallengeButton_active.png"] forState:UIControlStateHighlighted];
	[inviteFriendsButton addTarget:self action:@selector(_goInviteFriends) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:inviteFriendsButton];
	
	return (headerView);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONChallengeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];

	if (cell == nil) {
		if (indexPath.row == 0) {
			int score = [[[HONAppDelegate infoForUser] objectForKey:@"points"] intValue] + ([[[HONAppDelegate infoForUser] objectForKey:@"votes"] intValue] * [HONAppDelegate votePointMultiplier]) + ([[[HONAppDelegate infoForUser] objectForKey:@"pokes"] intValue] * [HONAppDelegate pokePointMultiplier]);
			cell = [[HONChallengeViewCell alloc] initAsTopCell:score withSubject:[HONAppDelegate dailySubjectName]];
		
		}else if (indexPath.row == [_challenges count] + 1)
			cell = [[HONChallengeViewCell alloc] initAsBottomCell:_isMoreLoading];
				
		else
			cell = [[HONChallengeViewCell alloc] initAsChallengeCell];
	}
	
	if (indexPath.row > 0 && indexPath.row < [_challenges count] + 1)
		cell.challengeVO = [_challenges objectAtIndex:indexPath.row - 1];
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0)
		return (55.0);
	
	else
		return (70.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (78.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < [_challenges count] + 1) {
		
		HONChallengeVO *vo = [_challenges objectAtIndex:indexPath.row - 1];
		if ([vo.status isEqualToString:@"Waiting"] || [vo.status isEqualToString:@"Accept"] || [vo.status isEqualToString:@"Started"] || [vo.status isEqualToString:@"Completed"])
			return (indexPath);
		
		else
			return (nil);
	}
	
	return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	//[(HONChallengeViewCell *)[tableView cellForRowAtIndexPath:indexPath] didSelect];
	
	HONChallengeVO *vo = [_challenges objectAtIndex:indexPath.row - 1];
	self.challengeVO = vo;
	
	NSLog(@"STATUS:[%@]", vo.status);
	if ([vo.status isEqualToString:@"Waiting"]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Waiting Challenge"
																		message:@"Do you want to poke this user? (Tip: Poking users gives the other person points.)"
																	  delegate:self
														  cancelButtonTitle:@"Yes"
														  otherButtonTitles:@"No", nil];
		[alertView setTag:1];
		[alertView show];
		
	} else if ([vo.status isEqualToString:@"Accept"]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Accept Challenge"
																		message:@"Do you want to accept this challenge? (Tip: Tap and hold to view images.)"
																	  delegate:self
														  cancelButtonTitle:@"Yes"
														  otherButtonTitles:@"No", nil];
		[alertView setTag:2];
		[alertView show];
	
	} else if ([vo.status isEqualToString:@"Started"] || [vo.status isEqualToString:@"Completed"]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"Y"];
		[self.navigationController pushViewController:[[HONVoteViewController alloc] initWithChallenge:vo] animated:YES];
	}
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return YES if you want the specified item to be editable.
	
	return (indexPath.row > 0 && indexPath.row < [_challenges count] + 1);
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		self.idxPath = indexPath;
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Challenge"
																		message:@"Do you want to report abuse?"
																	  delegate:self
														  cancelButtonTitle:@"Yes"
														  otherButtonTitles:@"No", nil];
		[alertView setTag:0];
		[alertView show];
	}
}


#pragma mark - AlerView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	ASIFormDataRequest *challengeRequest;
	HONChallengeVO *vo;
	
	NSLog(@"BUTTON INDEX:[%d]", buttonIndex);
	
	// delete
	if (alertView.tag == 0) {
		[[Mixpanel sharedInstance] track:@"Challenge Wall - Delete"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
													 [NSString stringWithFormat:@"%d - %@", self.challengeVO.challengeID, self.challengeVO.subjectName], @"challenge", nil]];
		
		vo = (HONChallengeVO *)[_challenges objectAtIndex:self.idxPath.row - 1];
		
		[self.challenges removeObjectAtIndex:self.idxPath.row - 1];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.idxPath] withRowAnimation:UITableViewRowAnimationFade];
		
		challengeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
		[challengeRequest setPostValue:[NSString stringWithFormat:@"%d", 10] forKey:@"action"];
		[challengeRequest setPostValue:[NSString stringWithFormat:@"%d", vo.challengeID] forKey:@"challengeID"];
		[challengeRequest startAsynchronous];
		
		switch(buttonIndex) {
			case 0:
				[[Mixpanel sharedInstance] track:@"Challenge Wall - Flag"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", self.challengeVO.challengeID, self.challengeVO.subjectName], @"challenge", nil]];
				
				ASIFormDataRequest *voteRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
				[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 11] forKey:@"action"];
				[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
				[voteRequest setPostValue:[NSString stringWithFormat:@"%d", self.challengeVO.challengeID] forKey:@"challengeID"];
				[voteRequest startAsynchronous];
				break;
		}
	
	} else if (alertView.tag == 1) {
		switch (buttonIndex) {
			case 0:
				[[Mixpanel sharedInstance] track:@"Challenge Wall - Poke Challenger"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", self.challengeVO.challengeID, self.challengeVO.subjectName], @"challenge", nil]];
				
				ASIFormDataRequest *voteRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kUsersAPI]]];
				[voteRequest setPostValue:[NSString stringWithFormat:@"%d", 6] forKey:@"action"];
				[voteRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"pokerID"];
				[voteRequest setPostValue:[NSString stringWithFormat:@"%d", _challengeVO.challengerID] forKey:@"pokeeID"];
				[voteRequest startAsynchronous];
				break;
		}
		
	} else if (alertView.tag == 2) {
		switch (buttonIndex) {
			case 0: {
				[[Mixpanel sharedInstance] track:@"Challenge Wall - Accept"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", self.challengeVO.challengeID, self.challengeVO.subjectName], @"challenge", nil]];
				
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithChallenge:self.challengeVO]];
				[navigationController setNavigationBarHidden:YES];
				[self presentViewController:navigationController animated:NO completion:nil];
				break;}
		}
	
	} else if (alertView.tag == 3) {
		switch (buttonIndex) {
			case 0: {
				[[Mixpanel sharedInstance] track:@"Challenge Wall - Re-Challenge"
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
															 [NSString stringWithFormat:@"%d - %@", self.challengeVO.challengeID, self.challengeVO.subjectName], @"challenge", nil]];
				
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithSubject:self.challengeVO.subjectName]];
				[navigationController setNavigationBarHidden:YES];
				[self presentViewController:navigationController animated:NO completion:nil];
				break;}
		}
	}
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request {
	//NSLog(@"HONChallengesViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	// load more
	if (request.tag == 2) {
		@autoreleasepool {
			NSError *error = nil;
			if (error != nil)
				NSLog(@"Failed to parse user JSON: %@", [error localizedDescription]);
			
			else {
				NSArray *unsortedChallenges = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
				NSArray *parsedLists = [NSMutableArray arrayWithArray:[unsortedChallenges sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"added" ascending:NO]]]];
				
				for (NSDictionary *serverList in parsedLists) {
					HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
					
					if (vo != nil)
						[_challenges addObject:vo];
				}
				
				if ([parsedLists count] == 0)
					_isMoreLoading = NO;
				
				self.lastDate = ((HONChallengeVO *)[_challenges lastObject]).addedDate;
				[_tableView reloadData];
			}
		}
	
		// user
	} else if (request.tag == 0) {
		@autoreleasepool {
			NSError *error = nil;
			NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			
			if (error != nil)
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			else {
				if ([userResult objectForKey:@"id"] != [NSNull null])
					[HONAppDelegate writeUserInfo:userResult];
			}
		}
		
		[_tableView reloadData];
		
		// 1st challenges
	} else if (request.tag == 1) {
		@autoreleasepool {
			NSError *error = nil;
			if (error != nil)
				NSLog(@"Failed to parse user JSON: %@", [error localizedDescription]);
			
			else {
				NSArray *unsortedChallenges = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
				NSArray *parsedLists = [NSMutableArray arrayWithArray:[unsortedChallenges sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"added" ascending:NO]]]];
				
				_challenges = [NSMutableArray array];
				for (NSDictionary *serverList in parsedLists) {
					HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
					
					if (vo != nil)
						[_challenges addObject:vo];
				}
				
				if ([parsedLists count] % 10 != 0)
					_isMoreLoading = NO;
				
				//_challenges = [list copy];
				
				self.lastDate = ((HONChallengeVO *)[_challenges lastObject]).addedDate;
				[_tableView reloadData];
			}
		}
	}
	
	_refreshButton.hidden = NO;
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
	
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
}


- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
	NSLog(@"------LOGGED IN-------");
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
	NSLog(@"-------LOGGED OUT-------");
}


#pragma mark - TapForTapAdViewDelegates
- (UIViewController *)rootViewController {
	return (self);
}

@end
