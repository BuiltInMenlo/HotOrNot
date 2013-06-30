//
//  HONTimelineViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import <MessageUI/MFMessageComposeViewController.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONTimelineViewController.h"
#import "HONTimelineItemViewCell.h"
#import "HONUserProfileViewCell.h"
#import "HONUserVO.h"
#import "HONRegisterViewController.h"
#import "HONImagePickerViewController.h"
#import "HONHeaderView.h"
#import "HONVotersViewController.h"
#import "HONCommentsViewController.h"
#import "HONRestrictedLocaleViewController.h"
#import "HONInstagramLoginViewController.h"
#import "HONAddFriendsViewController.h"
#import "HONEmptyTimelineView.h"
#import "HONAddContactsViewController.h"


@interface HONTimelineViewController() <MFMessageComposeViewControllerDelegate>
@property (readonly, nonatomic, assign) HONTimelineSubmitType timelineSubmitType;@property (nonatomic) int submitAction;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSDictionary *challengerDict;
@property (nonatomic, strong) HONEmptyTimelineView *emptyTimelineView;
@property (nonatomic, strong) UIImageView *toggleImgView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *challenges;
@property (nonatomic) BOOL isPushView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) UIImageView *emptySetImgView;
@property (nonatomic, strong) HONUserVO *userVO;
@end

@implementation HONTimelineViewController

- (id)init {
	NSLog(@"%@ - init", [[self class] description]);
	if ((self = [super init])) {
		_isPushView = NO;
		_submitAction = 10;
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithPublic {
	NSLog(@"%@ - init", [[self class] description]);
	if ((self = [super init])) {
		_isPushView = NO;
		_submitAction = 4;
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithSubject:(NSString *)subjectName {
	NSLog(@"%@ - initWithSubject:[%@]", [[self class] description], subjectName);
	if ((self = [super init])) {
		_isPushView = YES;
		_subjectName = subjectName;
		_submitAction = 8;
		
		[self _registerNotifications];
	}
	
	return (self);
}


- (id)initWithUsername:(NSString *)username {
	NSLog(@"%@ - initWithUsername:[%@]", [[self class] description], username);
	if ((self = [super init])) {
		_isPushView = YES;
		_submitAction = 9;
		_username = username;
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithUserID:(int)userID andOpponentID:(int)opponentID {
	NSLog(@"%@ - initWithUserID:[%d] andOpponentID:[%d]", [[self class] description], userID, opponentID);
	if ((self = [super init])) {
		_isPushView = YES;
		_submitAction = 7;
		_challengerDict = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithInt:userID], @"user1",
								 [NSNumber numberWithInt:opponentID], @"user2", nil];
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (void)_registerNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showRegistration:) name:@"SHOW_REGISTRATION" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshVoteTab:) name:@"REFRESH_VOTE_TAB" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshVoteTab:) name:@"REFRESH_ALL_TABS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_newChallenge:) name:@"NEW_CHALLENGE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_newCreatorChallenge:) name:@"NEW_CREATOR_CHALLENGE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_newChallengerChallenge:) name:@"NEW_CHALLENGER_CHALLENGE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_newSubjectChallenge:) name:@"NEW_SUBJECT_CHALLENGE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_newUserChallenge:) name:@"NEW_USER_CHALLENGE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_joinActiveChallenge:) name:@"JOIN_ACTIVE_CHALLENGE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showVoters:) name:@"SHOW_VOTERS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showComments:) name:@"SHOW_COMMENTS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSMSVerify:) name:@"SHOW_SMS_VERIFY" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_removeSMSVerify:) name:@"REMOVE_SMS_VERIFY" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tabsDropped:) name:@"TABS_DROPPED" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_tabsRaised:) name:@"TABS_RAISED" object:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}

- (BOOL)shouldAutorotate {
	return (NO);
}


#pragma mark - Data Calls
- (void)_retrieveChallenges {
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[params setObject:[NSString stringWithFormat:@"%d", _submitAction] forKey:@"action"];
	
	// all public
	if (_submitAction == 4) {
		
	// between two users
	} else if (_submitAction == 7) {
		[params setObject:[_challengerDict objectForKey:@"user1"] forKey:@"userID"];
		[params setObject:[_challengerDict objectForKey:@"user2"] forKey:@"challengerID"];
	
	// with hashtag
	} else if (_submitAction == 8) {
		[params setObject:_subjectName forKey:@"subjectName"];
	
	// a user's
	} else if (_submitAction == 9) {
		[params setObject:_username forKey:@"username"];
	
	// a user's friends
	} else if (_submitAction == 10) {
		
	}
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *challengesResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], challengesResult);
			
			_challenges = [NSMutableArray new];
			
			for (NSDictionary *serverList in challengesResult) {
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
				
				if (vo != nil) {
					[_challenges addObject:vo];
				}
			}
			
			if (_submitAction == 7) {
				HONChallengeVO *vo = (HONChallengeVO *)[_challenges lastObject];
				[_headerView setTitle:[NSString stringWithFormat:@"@%@", (vo.creatorID == [[_challengerDict objectForKey:@"user1"] intValue] && vo.creatorID != [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? vo.creatorName : vo.challengerName]];
			}
						
			_emptySetImgView.hidden = ([_challenges count] > 0);
			[_tableView reloadData];
		}
		
		[_headerView toggleRefresh:NO];
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
		
		[_headerView toggleRefresh:NO];
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}

- (void)_retrieveSingleChallenge:(HONChallengeVO *)vo {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 3], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", vo.challengeID], @"challengeID",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *parsedLists = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], parsedLists);
			_challenges = [NSMutableArray new];
			
			for (NSDictionary *serverList in parsedLists) {
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
				
				if (vo != nil) {
					[_challenges addObject:vo];
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
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
		
		[_headerView toggleRefresh:NO];
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}

- (void)_retrieveUser {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 8], @"action",
									_username, @"username",
									nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			_userVO = [HONUserVO userWithDictionary:userResult];
			[_tableView reloadData];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h@2x" : @"mainBG"]]];	
	
	_userVO = nil;
	_challenges = [NSMutableArray array];
		
	if (_isPushView) {
		
		NSString *title = @"";
		if (_submitAction == 8)
			title = _subjectName;
		
		else if (_submitAction == 9)
			title = [NSString stringWithFormat:@"@%@", _username];
		
		
		_headerView = [[HONHeaderView alloc] initWithTitle:title];
		[_headerView hideRefreshing];
		
		UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		backButton.frame = CGRectMake(3.0, 0.0, 64.0, 44.0);
		[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
		[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
		[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addSubview:backButton];
	
	} else {
		_headerView = [[HONHeaderView alloc] initAsVoteWall];
		[[_headerView refreshButton] addTarget:self action:@selector(_goRefresh) forControlEvents:UIControlEventTouchUpInside];
	}
	
	UIButton *createChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	createChallengeButton.frame = CGRectMake(270.0, 0.0, 50.0, 44.0);
	[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"createChallengeButton_nonActive"] forState:UIControlStateNormal];
	[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"createChallengeButton_Active"] forState:UIControlStateHighlighted];
	[createChallengeButton addTarget:self action:@selector(_goCreateChallenge) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:createChallengeButton];
	
	_emptySetImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 88.0, 320.0, 285.0)];
	_emptySetImgView.image = [UIImage imageNamed:@"noSnapsAvailable"];
	_emptySetImgView.hidden = YES;
	[self.view addSubview:_emptySetImgView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kNavBarHeaderHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - ((20.0 + kNavBarHeaderHeight + kTabSize.height) * (int)(![[[HONAppDelegate infoForUser] objectForKey:@"username"] isEqualToString:_username]))) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 249.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	[self.view addSubview:_headerView];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	if (_submitAction == 9)
		[self _retrieveUser];
		
	[self _retrieveChallenges];

	
#if __ALWAYS_INVITE__ == 1
	[HONAppDelegate writeFriendsList:[NSArray array]];
#endif
	
	if ([[HONAppDelegate friendsList] count] == 0 && !_isPushView)
		[self _goMobileSignup];
	
	if ([HONAppDelegate isLocaleEnabled] || [[NSUserDefaults standardUserDefaults] objectForKey:@"passed_invite"] != nil) {
#if __ALWAYS_REGISTER__ == 1
		[self performSelector:@selector(_goRegistration) withObject:self afterDelay:0.5];
#endif
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"boot_total"] intValue] == 0)
			[self performSelector:@selector(_goRegistration) withObject:self afterDelay:0.25];
		
	} else
		[self performSelector:@selector(_goLocaleRestriction) withObject:self afterDelay:0.33];
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
	[[Mixpanel sharedInstance] track:@"Timeline - Refresh"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if (_submitAction == 9)
		[self _retrieveUser];
	
	[self _retrieveChallenges];
}

- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:@"Timeline - Create Snap"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if (_userVO == nil) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:nil];
	
	} else {
		if ([_userVO.username isEqualToString:[[HONAppDelegate infoForUser] objectForKey:@"name"]]) {
			[[[UIAlertView alloc] initWithTitle:@"Snap Problem!"
												 message:@"You cannot snap at yourself!"
												delegate:nil
									cancelButtonTitle:@"OK"
									otherButtonTitles:nil] show];
			
		} else
			[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_USER_CHALLENGE" object:_userVO];
	}
}

- (void)_goTimelineBanner {
	[[Mixpanel sharedInstance] track:@"Timeline - Banner"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInstagramLoginViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goLocaleRestriction {
	//[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"boot_total"];
	//[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[Mixpanel sharedInstance] track:@"Timeline - Locale Restricted"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRestrictedLocaleViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:^(void) {
	}];
}

- (void)_goRegistration {
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

- (void)_goMobileSignup {
	_emptyTimelineView = [[HONEmptyTimelineView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:_emptyTimelineView];
}

- (void)_goMobileSignupClose {
	_emptyTimelineView.hidden = YES;
	[_emptyTimelineView removeFromSuperview];
}


#pragma mark - Notifications
- (void)_showSMSVerify:(NSNotification *)notification {
	[[Mixpanel sharedInstance] track:@"Verify Mobile - SMS"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if ([MFMessageComposeViewController canSendText]) {
		MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
		messageComposeViewController.messageComposeDelegate = self;
		messageComposeViewController.recipients = [NSArray arrayWithObject:@"2394313268"];
		messageComposeViewController.body = [[HONAppDelegate infoForUser] objectForKey:@"sms_code"];
		[self presentViewController:messageComposeViewController animated:YES completion:^(void) {}];
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SMS Error"
															message:@"Cannot send SMS from this device!"
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
	}
}

- (void)_removeSMSVerify:(NSNotification *)notification {
	[self _goMobileSignupClose];
}

- (void)_refreshVoteTab:(NSNotification *)notification {
	[_tableView setContentOffset:CGPointZero animated:YES];
	[_headerView toggleRefresh:YES];
	
	if (_submitAction == 9)
		[self _retrieveUser];
	
	[self _retrieveChallenges];
}

- (void)_newChallenge:(NSNotification *)notification {
	[self _goCreateChallenge];
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
	
	UINavigationController *navigationController = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == vo.creatorID) ? [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithSubject:vo.subjectName]] : (vo.statusID == 1 || vo.statusID == 2) ? [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithChallenge:vo]] : [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:userVO withSubject:vo.subjectName]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
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

- (void)_newUserChallenge:(NSNotification *)notification {
	HONUserVO *vo = (HONUserVO *)[notification object];
		
	[[Mixpanel sharedInstance] track:@"Timeline - New Snap at User"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username], @"challenger", nil]];
	
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:vo]];
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

- (void)_joinActiveChallenge:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	[[Mixpanel sharedInstance] track:@"Timeline - Join Challenge"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", vo.challengeID, vo.subjectName], @"challenge", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithJoinChallenge:vo]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_showVoters:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	[[Mixpanel sharedInstance] track:@"Timeline - Show Voters"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", vo.challengeID, vo.subjectName], @"challenge", nil]];
	[self.navigationController pushViewController:[[HONVotersViewController alloc] initWithChallenge:vo] animated:YES];
}

- (void)_showComments:(NSNotification *)notification {
	HONChallengeVO *vo = (HONChallengeVO *)[notification object];
	
	[[Mixpanel sharedInstance] track:@"Vote Wall - Comments"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d - %@", vo.challengeID, vo.subjectName], @"challenge", nil]];
	[self.navigationController pushViewController:[[HONCommentsViewController alloc] initWithChallenge:vo] animated:YES];
}

- (void)_tabsDropped:(NSNotification *)notification {
	_tableView.frame = CGRectMake(0.0, kNavBarHeaderHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (kNavBarHeaderHeight + 29.0));
}

- (void)_tabsRaised:(NSNotification *)notification {
	_tableView.frame = CGRectMake(0.0, kNavBarHeaderHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (kNavBarHeaderHeight + 81.0));
}

- (void)_showRegistration:(NSNotification *)notification {
	[self _goRegistration];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_challenges count] + (int)(_userVO != nil && _submitAction == 9));
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (_submitAction == 9)
		return (nil);
	
	else {
		UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)];
		
		UIImageView *bannerImageView = [[UIImageView alloc] initWithFrame:bgView.frame];
		[bannerImageView setImageWithURL:[NSURL URLWithString:[HONAppDelegate timelineBannerURL]] placeholderImage:nil];
//		[bannerImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[HONAppDelegate timelineBannerURL]]
//																					cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//																			  timeoutInterval:3] placeholderImage:nil success:nil failure:nil];
		[bgView addSubview:bannerImageView];
		
		UIButton *bannerButton = [UIButton buttonWithType:UIButtonTypeCustom];
		bannerButton.frame = bannerImageView.frame;
		[bannerButton addTarget:self action:@selector(_goTimelineBanner) forControlEvents:UIControlEventTouchUpInside];
		[bgView addSubview:bannerButton];
		
		return (bgView);
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_submitAction == 9 && _userVO != nil) {
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
	if (indexPath.row == 0) {
		return ((_submitAction == 9) ? 210.0 : 320.0);
		
	} else
		return (320.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (([[HONAppDelegate timelineBannerURL] length] > 0) ? (int)!(_submitAction == 9) * 50.0 : 0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}


#pragma mark - MessageCompose Delegates
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	//NSLog(@"messageComposeViewController:didFinishWithResult:[%d]", result);
	
	[self dismissViewControllerAnimated:YES completion:^(void) {
		if (result == MessageComposeResultSent) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	}];
}


@end
