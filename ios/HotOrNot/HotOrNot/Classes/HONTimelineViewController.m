//
//  HONTimelineViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "Mixpanel.h"

#import "HONTimelineViewController.h"
#import "HONTimelineItemViewCell.h"
#import "HONUserProfileViewCell.h"
#import "HONAppDelegate.h"
#import "HONChallengeVO.h"
#import "HONUserVO.h"
#import "HONFacebookCaller.h"
#import "HONRegisterViewController.h"
#import "HONImagePickerViewController.h"
#import "HONHeaderView.h"
#import "HONSearchBarHeaderView.h"
#import "HONVotersViewController.h"
#import "HONCommentsViewController.h"
#import "HONLoginViewController.h"
#import "HONTimelineItemDetailsViewController.h"
#import "HONUsernameViewController.h"

@interface HONTimelineViewController() <UIActionSheetDelegate>
@property(nonatomic) int subjectID;
@property(nonatomic, strong) NSString *subjectName;
@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) UIImageView *tutorialOverlayImgView;
@property(nonatomic, strong) UIImageView *toggleImgView;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *challenges;
@property(nonatomic) BOOL isPushView;
@property(nonatomic, strong) HONChallengeVO *challengeVO;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@property(nonatomic) int submitAction;
@property(nonatomic, strong) HONHeaderView *headerView;
@property(nonatomic, strong) HONSearchBarHeaderView *searchHeaderView;
@property(nonatomic, strong) UIImageView *emptySetImgView;
@property(nonatomic, strong) HONUserVO *userVO;
@end

@implementation HONTimelineViewController

- (id)init {
	if ((self = [super init])) {
		_subjectID = 0;
		_submitAction = 4;
		_isPushView = NO;
		
		self.view.backgroundColor = [UIColor whiteColor];
		_challenges = [NSMutableArray new];
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithSubjectID:(int)subjectID {
	if ((self = [super init])) {
		_isPushView = YES;
		
		_subjectID = subjectID;
		
		self.view.backgroundColor = [UIColor whiteColor];
		_challenges = [NSMutableArray new];
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithSubjectName:(NSString *)subjectName {
	if ((self = [super init])) {
		_isPushView = YES;
		_subjectName = subjectName;
		
		self.view.backgroundColor = [UIColor whiteColor];
		_challenges = [NSMutableArray new];
		
		[self _registerNotifications];
	}
	
	return (self);
}


- (id)initWithUsername:(NSString *)username {
	if ((self = [super init])) {
		_isPushView = YES;
		
		_subjectID = 0;
		_challengeVO = nil;
		_subjectName = nil;
		_username = username;
		
		self.view.backgroundColor = [UIColor whiteColor];
		_challenges = [NSMutableArray new];
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		_isPushView = YES;
		
		_subjectID = 0;
		_challengeVO = vo;
		_subjectName = _challengeVO.subjectName;
		
		self.view.backgroundColor = [UIColor whiteColor];
		_challenges = [NSMutableArray new];
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (void)_registerNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showTutorial:) name:@"SHOW_TUTORIAL" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshVoteTab:) name:@"REFRESH_VOTE_TAB" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshVoteTab:) name:@"REFRESH_ALL_TABS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showNotInSessionDetails:) name:@"SHOW_NOT_IN_SESSION_DETAILS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showInSessionCreatorDetails:) name:@"SHOW_IN_SESSION_CREATOR_DETAILS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showInSessionChallengerDetails:) name:@"SHOW_IN_SESSION_CHALLENGER_DETAILS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_newCreatorChallenge:) name:@"NEW_CREATOR_CHALLENGE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_newChallengerChallenge:) name:@"NEW_CHALLENGER_CHALLENGE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_newSubjectChallenge:) name:@"NEW_SUBJECT_CHALLENGE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_shareChallenge:) name:@"SHARE_CHALLENGE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showVoters:) name:@"SHOW_VOTERS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showComments:) name:@"SHOW_COMMENTS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSearchTable:) name:@"SHOW_SEARCH_TABLE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_hideSearchTable:) name:@"HIDE_SEARCH_TABLE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showUserShare:) name:@"SHOW_USER_SHARE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_resignSearchBarFocus:) name:@"RESIGN_SEARCH_BAR_FOCUS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tabsDropped:) name:@"TABS_DROPPED" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tabsRaised:) name:@"TABS_RAISED" object:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (NO);
}


#pragma mark - Data Calls
- (void)_retrieveChallenges {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	
	if (_subjectID == 0) {
		if (_subjectName != nil) {
			[params setObject:[NSString stringWithFormat:@"%d", 8] forKey:@"action"];
			[params setObject:_subjectName forKey:@"subjectName"];
			
		} else {
			if (_username != nil) {
				[params setObject:_username forKey:@"username"];
				[params setObject:[NSString stringWithFormat:@"%d", 9] forKey:@"action"];
				
			} else
				[params setObject:[NSString stringWithFormat:@"%d", _submitAction] forKey:@"action"];
		}
	} else {
		[params setObject:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
		[params setObject:[NSString stringWithFormat:@"%d", _subjectID] forKey:@"subjectID"];
	}
	
	[httpClient postPath:kVotesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"HONHONTimelineViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
		} else {
			NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//NSLog(@"HONHONTimelineViewController AFNetworking: %@", parsedLists);
			_challenges = [NSMutableArray new];
			
			int cnt = 0;
			for (NSDictionary *serverList in parsedLists) {
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
				
				if (vo != nil) {
					//NSLog(@"%d)--> ADDING CHALLENGE[%@]", cnt, vo.dictionary);
					[_challenges addObject:vo];
					cnt++;
				}
			}
			
			_emptySetImgView.hidden = ([_challenges count] > 0);
			[_tableView reloadData];
			
			if ([_challenges count] == 0) {
				[[[UIAlertView alloc] initWithTitle:@"Nothing Here!"
											message:@"No PicChallenges in session. You should start one."
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
		}
		
		[_headerView toggleRefresh:NO];
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"HONTimelineViewController AFNetworking %@", [error localizedDescription]);
		
		[_headerView toggleRefresh:NO];
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"Connection Error", @"Status message when no network detected");
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}

- (void)_retrieveSingleChallenge:(HONChallengeVO *)vo {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 3], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", vo.challengeID], @"challengeID",
							nil];
	
	[httpClient postPath:kVotesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"HONHONTimelineViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
		} else {
			NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//NSLog(@"HONHONTimelineViewController AFNetworking: %@", parsedLists);
			_challenges = [NSMutableArray new];
			
			int cnt = 0;
			for (NSDictionary *serverList in parsedLists) {
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
				
				if (vo != nil) {
					//NSLog(@"%d)--> ADDING CHALLENGE[%@]", cnt, vo.dictionary);
					[_challenges addObject:vo];
					cnt++;
				}
			}
			
			_emptySetImgView.hidden = ([_challenges count] > 0);
			[_tableView reloadData];
			
			if ([_challenges count] == 0) {
				[[[UIAlertView alloc] initWithTitle:@"Nothing Here!"
											message:@"No PicChallenges in session. You should start one."
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
		}
		
		[_headerView toggleRefresh:NO];
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"HONTimelineViewController AFNetworking %@", [error localizedDescription]);
		
		[_headerView toggleRefresh:NO];
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"Connection Error", @"Status message when no network detected");
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}


- (void)_retrieveUser {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 8], @"action",
									_username, @"username",
									nil];
	
	[httpClient postPath:kUsersAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			NSLog(@"HONTimelineViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
		} else {
			//NSLog(@"HONTimelineViewController AFNetworking: %@", userResult);
			
			if ([userResult objectForKey:@"id"] != [NSNull null]) {
				_userVO = [HONUserVO userWithDictionary:userResult];
				[_tableView reloadData];
				
				if (_challengeVO == nil)
					[self _retrieveChallenges];
				
				else
					[self _retrieveSingleChallenge:_challengeVO];
				
				
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"HONTimelineViewController AFNetworking %@", [error localizedDescription]);
	}];
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h@2x" : @"mainBG"];
	[self.view addSubview:bgImgView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:(_isPushView) ? (_username != nil) ? [NSString stringWithFormat:@"@%@", _username] : _subjectName : @"Home"];
	[_headerView toggleRefresh:NO];
	[_headerView refreshButton].hidden = _isPushView;
	[self.view addSubview:_headerView];
	
	if (_isPushView) {
		UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		backButton.frame = CGRectMake(3.0, 0.0, 64.0, 44.0);
		[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
		[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
		[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addSubview:backButton];
	
	} else {
		[[_headerView refreshButton] addTarget:self action:@selector(_goRefresh) forControlEvents:UIControlEventTouchUpInside];
	}
	
	UIButton *createChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	createChallengeButton.frame = CGRectMake(270.0, 0.0, 44.0, 44.0);
	[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"createChallengeButton_nonActive"] forState:UIControlStateNormal];
	[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"createChallengeButton_Active"] forState:UIControlStateHighlighted];
	[createChallengeButton addTarget:self action:@selector(_goCreateChallenge) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:createChallengeButton];
	
	_emptySetImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 88.0, 320.0, 285.0)];
	_emptySetImgView.image = [UIImage imageNamed:@"noSnapsAvailable"];
	_emptySetImgView.hidden = YES;
	[self.view addSubview:_emptySetImgView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (kNavHeaderHeight + 78.0)) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 249.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Getting Challenges…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	if ([_username length] > 0) {
		[self _retrieveUser];
	
	} else {
		if (_challengeVO == nil)
			[self _retrieveChallenges];
		
		else
			[self _retrieveSingleChallenge:_challengeVO];
	}
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"boot_total"] intValue] == 0)
		[self performSelector:@selector(_goTutorial) withObject:self afterDelay:0.5];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goBack {
	[[Mixpanel sharedInstance] track:@"Timeline Profile - Go Back"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goRefresh {
	[_headerView toggleRefresh:YES];
	
//	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
//	_progressHUD.labelText = @"Refreshing…";
//	_progressHUD.mode = MBProgressHUDModeIndeterminate;
//	_progressHUD.minShowTime = kHUDTime;
//	_progressHUD.taskInProgress = YES;
	
	[[Mixpanel sharedInstance] track:@"Timeline - Refresh"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if ([_username length] > 0) {
		[self _retrieveUser];
		
	} else {
		if (_challengeVO == nil)
			[self _retrieveChallenges];
		
		else
			[self _retrieveSingleChallenge:_challengeVO];
	}
}

- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:@"Timeline - Create Snap"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goTutorial {
	[[Mixpanel sharedInstance] track:@"Register User"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	int boot_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"boot_total"] intValue];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++boot_total] forKey:@"boot_total"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRegisterViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:^(void) {
	}];
}

- (void)_goTutorialClose {
	_tutorialOverlayImgView.hidden = YES;
	[_tutorialOverlayImgView removeFromSuperview];
}

- (void)_goChangeUsername {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUsernameViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:^(void) {
		[self _goTutorialClose];
	}];
}


#pragma mark - Notifications
- (void)_shareChallenge:(NSNotification *)notification {
	_challengeVO = (HONChallengeVO *)[notification object];
	
	if (FBSession.activeSession.state == 513)
		[HONFacebookCaller postToTimeline:_challengeVO];
	
	else {
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[HONLoginViewController alloc] init]];
		[navController setNavigationBarHidden:YES];
		[self presentViewController:navController animated:YES completion:nil];
	}
}

- (void)_refreshVoteTab:(NSNotification *)notification {
	[_searchHeaderView backgroundingReset];
	[_tableView setContentOffset:CGPointZero animated:YES];
	[_headerView toggleRefresh:YES];
	
//	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
//	_progressHUD.labelText = @"Refreshing…";
//	_progressHUD.mode = MBProgressHUDModeIndeterminate;
//	_progressHUD.minShowTime = kHUDTime;
//	_progressHUD.taskInProgress = YES;
	
	if ([_username length] > 0) {
		[self _retrieveUser];
		
	} else {
		if (_challengeVO == nil)
			[self _retrieveChallenges];
		
		else
			[self _retrieveSingleChallenge:_challengeVO];
	}
}

- (void)_showNotInSessionDetails:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	[[Mixpanel sharedInstance] track:@"Timeline - Single Snap Details"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", vo.challengeID, vo.subjectName], @"challenge", nil]];
		
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[HONTimelineItemDetailsViewController alloc] initAsNotInSession:vo]];
	[navController setNavigationBarHidden:YES];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
	[self presentViewController:navController animated:NO completion:nil];
}

- (void)_showInSessionCreatorDetails:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	[[Mixpanel sharedInstance] track:@"Timeline - Creator Snap Details"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", vo.challengeID, vo.subjectName], @"challenge", nil]];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[HONTimelineItemDetailsViewController alloc] initAsInSessionCreator:vo]];
	[navController setNavigationBarHidden:YES];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
	[self presentViewController:navController animated:NO completion:nil];
}

- (void)_showInSessionChallengerDetails:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	[[Mixpanel sharedInstance] track:@"Timeline - Challenger Snap Details"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", vo.challengeID, vo.subjectName], @"challenge", nil]];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[HONTimelineItemDetailsViewController alloc] initAsInSessionChallenger:vo]];
	[navController setNavigationBarHidden:YES];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
	[self presentViewController:navController animated:NO completion:nil];
}

- (void)_newCreatorChallenge:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	[[Mixpanel sharedInstance] track:@"Timeline - New Snap at Creator"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", vo.challengeID, vo.subjectName], @"challenge", nil]];
	
	HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
																		[NSString stringWithFormat:@"%d", vo.creatorID], @"id",
																		[NSString stringWithFormat:@"%d", 0], @"points",
																		[NSString stringWithFormat:@"%d", 0], @"votes",
																		[NSString stringWithFormat:@"%d", 0], @"pokes",
																		[NSString stringWithFormat:@"%d", 0], @"pics",
																		vo.creatorName, @"username",
																		vo.creatorFB, @"fb_id",
																		vo.creatorAvatar, @"avatar_url", nil]];
	
	UINavigationController *navigationController = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == vo.creatorID) ? [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithSubject:vo.subjectName]] : [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:userVO withSubject:vo.subjectName]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_newChallengerChallenge:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	[[Mixpanel sharedInstance] track:@"Timeline - New Snap at Challenger"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", vo.challengeID, vo.subjectName], @"challenge", nil]];
	
	HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
																		[NSString stringWithFormat:@"%d", vo.challengerID], @"id",
																		[NSString stringWithFormat:@"%d", 0], @"points",
																		[NSString stringWithFormat:@"%d", 0], @"votes",
																		[NSString stringWithFormat:@"%d", 0], @"pokes",
																		[NSString stringWithFormat:@"%d", 0], @"pics",
																		vo.challengerName, @"username",
																		vo.challengerFB, @"fb_id",
																		vo.challengerAvatar, @"avatar_url", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:userVO withSubject:vo.subjectName]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_newSubjectChallenge:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	[[Mixpanel sharedInstance] track:@"Timeline - New Snap with Hashtag"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 vo.subjectName, @"subject", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithSubject:vo.subjectName]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_showVoters:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	[[Mixpanel sharedInstance] track:@"Timeline - Show Voters"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", vo.challengeID, vo.subjectName], @"challenge", nil]];
	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONVotersViewController alloc] initWithChallenge:vo]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:NO completion:nil];
	
	[self.navigationController pushViewController:[[HONVotersViewController alloc] initWithChallenge:vo] animated:YES];
}

- (void)_showComments:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	[[Mixpanel sharedInstance] track:@"Vote Wall - Comments"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", vo.challengeID, vo.subjectName], @"challenge", nil]];
	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCommentsViewController alloc] initWithChallenge:vo]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:NO completion:nil];
	
	[self.navigationController pushViewController:[[HONCommentsViewController alloc] initWithChallenge:vo] animated:YES];
}

- (void)_showSearchTable:(NSNotification *)notification {
	[UIView animateWithDuration:0.25 animations:^(void) {
		self.view.frame = CGRectMake(self.view.frame.origin.x, -44.0, self.view.frame.size.width, self.view.frame.size.height);
	}];
}

- (void)_hideSearchTable:(NSNotification *)notification {
	[UIView animateWithDuration:0.25 animations:^(void) {
		self.view.frame = CGRectMake(self.view.frame.origin.x, 0.0, self.view.frame.size.width, self.view.frame.size.height);
	}];
}

- (void)_showUserShare:(NSNotification *)notification {
	NSLog(@"_showUserShare:[%@]", _userVO);
	
	if ([HONAppDelegate appTabBarController].view != nil && _userVO != nil) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																 delegate:self
														cancelButtonTitle:@"Cancel"
												   destructiveButtonTitle:@"Report User"
														otherButtonTitles:[NSString stringWithFormat:@"Snap @%@", _userVO.username], nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
		[actionSheet showInView:[HONAppDelegate appTabBarController].view];
	}
}

- (void)_resignSearchBarFocus:(NSNotification *)notification {
	if (_searchHeaderView != nil)
		[_searchHeaderView toggleFocus:NO];
}

- (void)_tabsDropped:(NSNotification *)notification {
	_tableView.frame = CGRectMake(0.0, kNavHeaderHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (kNavHeaderHeight + 29.0));
}

- (void)_tabsRaised:(NSNotification *)notification {
	_tableView.frame = CGRectMake(0.0, kNavHeaderHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (kNavHeaderHeight + 78.0));
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_challenges count]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	if (_isPushView)
		return (nil);
	
	else {
		_searchHeaderView = [[HONSearchBarHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, kSearchHeaderHeight)];
		return (_searchHeaderView);
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([_username length] > 0) {
		if (indexPath.row == 0) {
			HONUserProfileViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
			
			if (cell == nil) {
				cell = [[HONUserProfileViewCell alloc] init];
				cell.userVO = _userVO;
			}
			
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			return (cell);
		
		} else {
			HONTimelineItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
			
			if (cell == nil) {
				HONChallengeVO *vo = (HONChallengeVO *)[_challenges objectAtIndex:indexPath.row - 1];
				cell = (vo.statusID == 1 || vo.statusID == 2) ? [[HONTimelineItemViewCell alloc] initAsWaitingCell] : [[HONTimelineItemViewCell alloc] initAsStartedCell];
				cell.challengeVO = vo;
			}
			
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			return (cell);
			}
		
	} else {
		HONTimelineItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
			HONChallengeVO *vo = (HONChallengeVO *)[_challenges objectAtIndex:indexPath.row];
			cell = (vo.statusID == 1 || vo.statusID == 2) ? [[HONTimelineItemViewCell alloc] initAsWaitingCell] : [[HONTimelineItemViewCell alloc] initAsStartedCell];
			cell.challengeVO = vo;
		}
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		return (cell);
	}
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([_username length] > 0 && indexPath.row == 0)
		return (226.0);
	
	else {
		HONChallengeVO *vo = (HONChallengeVO *)[_challenges objectAtIndex:indexPath.row - ((int)[_username length] > 0)];
		return ((vo.statusID == 1 || vo.statusID == 2) ? 410.0 : 307.0);
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (kSearchHeaderHeight * (int)!_isPushView);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}


#pragma mark - ScrollView Delegates
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
}


#pragma mark - ActionSheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0: {
			[[Mixpanel sharedInstance] track:@"Timeline Profile - Flag"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
														 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
			
			AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
			NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 10], @"action",
									[NSString stringWithFormat:@"%d", _userVO.userID], @"userID",
									nil];
			
			[httpClient postPath:kUsersAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
				NSError *error = nil;
				if (error != nil) {
					NSLog(@"HONTimelineViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
					
				} else {
					NSDictionary *flagResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
					NSLog(@"HONTimelineViewController AFNetworking: %@", flagResult);
				}
				
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				NSLog(@"HONTimelineViewController AFNetworking %@", [error localizedDescription]);
			}];
			break;}
			
		case 1: {
			[[Mixpanel sharedInstance] track:@"Timeline - New Snap at User"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
														 [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
			
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:_userVO]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
			break;}
	}
}

@end
