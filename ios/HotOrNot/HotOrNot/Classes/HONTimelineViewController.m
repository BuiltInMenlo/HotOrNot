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
#import "UIImageView+AFNetworking.h"

#import "HONTimelineViewController.h"
#import "HONTimelineItemViewCell.h"
#import "HONUserProfileViewCell.h"
#import "HONUserProfileRequestViewCell.h"
#import "HONUserVO.h"
#import "HONRegisterViewController.h"
#import "HONImagePickerViewController.h"
#import "HONHeaderView.h"
#import "HONVotersViewController.h"
#import "HONCommentsViewController.h"
#import "HONRestrictedLocaleViewController.h"
#import "HONInviteCelebViewController.h"
#import "HONEmptyTimelineView.h"
#import "HONAddContactsViewController.h"
#import "HONPopularViewController.h"
#import "HONVerifyViewController.h"
#import "HONImagingDepictor.h"


@interface HONTimelineViewController() <UIActionSheetDelegate, UIAlertViewDelegate, HONUserProfileViewCellDelegate, HONUserProfileRequestViewCellDelegate, HONTimelineItemViewCellDelegate, HONEmptyTimelineViewDelegate>
@property (readonly, nonatomic, assign) HONTimelineType timelineType;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSDictionary *challengerDict;
@property (nonatomic, strong) HONEmptyTimelineView *emptyTimelineView;
@property (nonatomic, strong) UIImageView *toggleImgView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *challenges;
@property (nonatomic) BOOL isPushView;
@property (nonatomic) BOOL isPublic;
@property (nonatomic) BOOL isProfileViewable;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) UIScrollView *findFriendsScrollView;
@property (nonatomic, strong) UIImageView *tooltipImageView;
@property (nonatomic, strong) HONUserVO *userVO;
@property (nonatomic, strong) UIButton *backButton;
@end

@implementation HONTimelineViewController

- (id)initWithPublic {
	if ((self = [super init])) {
		_isPushView = NO;
		_isPublic = YES;
		_timelineType = HONTimelineTypePublic;
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithFriends {
	if ((self = [super init])) {
		_isPushView = NO;
		_isPublic = YES;
		_timelineType = HONTimelineTypeFriends;
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithSubject:(NSString *)subjectName {
	if ((self = [super init])) {
		_isPushView = YES;
		_isPublic = YES;
		_subjectName = subjectName;
		_timelineType = HONTimelineTypeSubject;
		
		[self _registerNotifications];
	}
	
	return (self);
}


- (id)initWithUsername:(NSString *)username {
	if ((self = [super init])) {
		_isPushView = YES;
		_isPublic = YES;
		_timelineType = HONTimelineTypeSingleUser;
		_username = username;
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithUserID:(int)userID andOpponentID:(int)opponentID asPublic:(BOOL)isPublic {
	if ((self = [super init])) {
		_isPushView = YES;
		_isPublic = isPublic;
		_timelineType = HONTimelineTypeOpponents;
		_challengerDict = [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithInt:userID], @"user1",
						   [NSNumber numberWithInt:opponentID], @"user2", nil];
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (void)_registerNotifications {
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showRegistration:) name:@"SHOW_REGISTRATION" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshVoteTab:) name:@"REFRESH_VOTE_TAB" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshVoteTab:) name:@"REFRESH_ALL_TABS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_removeVerify:) name:@"REMOVE_VERIFY" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showPopularUsers:) name:@"SHOW_POPULAR_USERS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showAddContacts:) name:@"SHOW_ADD_CONTACTS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_killTooltip:) name:@"KILL_TOOLTIP" object:nil];
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
	[params setObject:[NSString stringWithFormat:@"%d", _timelineType] forKey:@"action"];
	[params setObject:(_isPublic) ? @"N" : @"Y" forKey:@"isPrivate"];
	
	// all public
	if (_timelineType == HONTimelineTypePublic) {
		
		// between two users
	} else if (_timelineType == HONTimelineTypeOpponents) {
		[params setObject:[_challengerDict objectForKey:@"user1"] forKey:@"userID"];
		[params setObject:[_challengerDict objectForKey:@"user2"] forKey:@"challengerID"];
		
		// with hashtag
	} else if (_timelineType == HONTimelineTypeSubject) {
		[params setObject:_subjectName forKey:@"subjectName"];
		
		// a user's
	} else if (_timelineType == HONTimelineTypeSingleUser) {
		[params setObject:_username forKey:@"username"];
		
		// a user's friends
	} else if (_timelineType == HONTimelineTypeFriends) {
	}
	
	//NSLog(@"PARAMS:[%@]", params);
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *challengesResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], challengesResult);
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], [challengesResult objectAtIndex:0]);
			
			_challenges = [NSMutableArray new];
			
			for (NSDictionary *serverList in challengesResult) {
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
				
				if (vo != nil) {
					if (vo.expireSeconds != 0)
						[_challenges addObject:vo];
				}
			}
			
			if (_timelineType == HONTimelineTypeOpponents) {
				HONChallengeVO *vo = (HONChallengeVO *)[_challenges lastObject];
				[_headerView setTitle:[NSString stringWithFormat:@"@%@", ([vo.challengerName length] == 0) ? vo.creatorName : (vo.creatorID == [[_challengerDict objectForKey:@"user1"] intValue] && vo.creatorID != [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? vo.creatorName : vo.challengerName]];
			}
			
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
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
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
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			_userVO = [HONUserVO userWithDictionary:userResult];
			
			_isProfileViewable = ([[[HONAppDelegate infoForUser] objectForKey:@"age"] intValue] == _userVO.age || [[[HONAppDelegate infoForUser] objectForKey:@"age"] intValue] <= 0 || _userVO.age <= 0);
			for (HONUserVO *vo in [HONAppDelegate friendsList]) {
				if (vo.userID == _userVO.userID) {
					_isProfileViewable = YES;
					break;
				}
			}
			
			if (!_isProfileViewable)
				[_headerView setTitle:@"Sending Request…"];
			
			_backButton.hidden = !_isProfileViewable;
			
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
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}

- (void)_addFriend:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", userID], @"target",
							@"1", @"auto", nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIAddFriends);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIAddFriends parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			if (result != nil)
				[HONAppDelegate writeFriendsList:result];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}

- (void)_flagUser:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", userID], @"userID", nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h@2x" : @"mainBG"]];
	bgImageView.frame = self.view.bounds;
	[self.view addSubview:bgImageView];
	
	_userVO = nil;
	_isProfileViewable = YES;
	_challenges = [NSMutableArray array];
	
	if (_isPushView) {
		
		NSString *title = @"";
		if (_timelineType == HONTimelineTypeSubject)
			title = _subjectName;
		
		else if (_timelineType == HONTimelineTypeSingleUser)
			title = [NSString stringWithFormat:@"@%@", _username];
		
		
		_headerView = [[HONHeaderView alloc] initWithTitle:title];
		[_headerView hideRefreshing];
		
		_backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_backButton.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
		[_backButton setBackgroundImage:[UIImage imageNamed:@"backButtonArrow_nonActive"] forState:UIControlStateNormal];
		[_backButton setBackgroundImage:[UIImage imageNamed:@"backButtonArrow_Active"] forState:UIControlStateHighlighted];
		[_backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
		_backButton.hidden = !_isProfileViewable;
		[_headerView addSubview:_backButton];
		
		UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
		moreButton.frame = CGRectMake(256.0, 0.0, 64.0, 44.0);
		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreHeaderButton_nonActive"] forState:UIControlStateNormal];
		[moreButton setBackgroundImage:[UIImage imageNamed:@"moreHeaderButton_Active"] forState:UIControlStateHighlighted];
		[moreButton addTarget:self action:@selector(_goMore) forControlEvents:UIControlEventTouchUpInside];
//		[_headerView addSubview:moreButton];
		
	} else {
		_headerView = [[HONHeaderView alloc] initAsVoteWall];
		[[_headerView refreshButton] addTarget:self action:@selector(_goRefresh) forControlEvents:UIControlEventTouchUpInside];
	}
	
	UIButton *createChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	createChallengeButton.frame = CGRectMake(270.0, 0.0, 50.0, 44.0);
	[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"createChallengeButton_nonActive"] forState:UIControlStateNormal];
	[createChallengeButton setBackgroundImage:[UIImage imageNamed:@"createChallengeButton_Active"] forState:UIControlStateHighlighted];
	[createChallengeButton addTarget:self action:@selector(_goCreateChallenge) forControlEvents:UIControlEventTouchUpInside];
	createChallengeButton.hidden = _isPushView;
	[_headerView addSubview:createChallengeButton];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kNavBarHeaderHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - ((20.0 + kNavBarHeaderHeight + kTabSize.height) * (int)(![[[HONAppDelegate infoForUser] objectForKey:@"username"] isEqualToString:_username]))) style:UITableViewStylePlain];
	//[_tableView setBackgroundColor:(_isPushView) ? [UIColor colorWithWhite:0.900 alpha:1.0] : [UIColor whiteColor]];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 249.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.userInteractionEnabled = YES;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	_findFriendsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, kNavBarHeaderHeight, 320.0, ([HONAppDelegate isRetina5]) ? 454.0 : 366.0)];
	_findFriendsScrollView.contentSize = CGSizeMake(_findFriendsScrollView.frame.size.width, _findFriendsScrollView.frame.size.height+ 1.0);
	_findFriendsScrollView.pagingEnabled = NO;
	_findFriendsScrollView.showsVerticalScrollIndicator = YES;
	_findFriendsScrollView.showsHorizontalScrollIndicator = NO;
	_findFriendsScrollView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:_findFriendsScrollView];
	
	UIImageView *findFriendsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, ([HONAppDelegate isRetina5]) ? 454.0 : 366.0)];
	findFriendsImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"findFriends-568h@2x" : @"findFriends"];
	findFriendsImageView.userInteractionEnabled = YES;
	findFriendsImageView.hidden = ([_challenges count] > 0 || [[HONAppDelegate friendsList] count] > 0 || _isPushView);
	[_findFriendsScrollView addSubview:findFriendsImageView];
	
	UIButton *ctaButton = [UIButton buttonWithType:UIButtonTypeCustom];
	ctaButton.frame = CGRectMake(0.0, 302.0, 320.0, 53.0);
	[ctaButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
	[ctaButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
	[ctaButton addTarget:self action:@selector(_goAddContactsAlert) forControlEvents:UIControlEventTouchUpInside];
	[findFriendsImageView addSubview:ctaButton];
	
	[self.view addSubview:_headerView];
	
//	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
//	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
//	_progressHUD.mode = MBProgressHUDModeIndeterminate;
//	_progressHUD.minShowTime = kHUDTime;
//	_progressHUD.taskInProgress = YES;
	
	if (_timelineType == HONTimelineTypeSingleUser)
		[self performSelector:@selector(_retrieveUser) withObject:nil afterDelay:0.25];
	
	[self _retrieveChallenges];
	//[self performSelector:@selector(_retrieveChallenges) withObject:nil afterDelay:0.5];
	
#if __ALWAYS_REGISTER__ == 1
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"passed_registration"];
	[[NSUserDefaults standardUserDefaults] synchronize];
#endif
	
	
	if (!_isPushView) {
#if __ALWAYS_VERIFY__ == 1
		[self _goVerify];
#endif
		
//		if ([[[HONAppDelegate infoForUser] objectForKey:@"sms_verified"] intValue] == 0 && [[HONAppDelegate friendsList] count] == 0)
//			[self _goVerify];
		
		if ([HONAppDelegate isLocaleEnabled]) {
			if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] == nil) {
				_tooltipImageView = [[UIImageView alloc] initWithFrame:CGRectMake(72.0, 35.0, 244.0, 94.0)];
				_tooltipImageView.image = [UIImage imageNamed:@"tapTheCameraOverlay"];
				[self.view addSubview:_tooltipImageView];
				
				[self performSelector:@selector(_goRegistration) withObject:self afterDelay:0.25];
			}
			
		} else
			[self performSelector:@selector(_goLocaleRestriction) withObject:self afterDelay:0.33];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[HONAppDelegate offsetSubviewsForIOS7:self.view];
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
	
	if (_timelineType == HONTimelineTypeSingleUser)
		[self _retrieveUser];
	
	[self _retrieveChallenges];
}

- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:@"Timeline - Create Snap"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self _removeToolTip];
	
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
			
		} else {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:_userVO]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	}
}

- (void)_goMore {
	[[Mixpanel sharedInstance] track:@"Timeline Profile - More Self"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"challenger", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:@"Report abuse"
													otherButtonTitles:@"Photo message", @"Follow user", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	[actionSheet setTag:1];
	[actionSheet showInView:[HONAppDelegate appTabBarController].view];
}

- (void)_goTimelineBanner {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline - Banner (%@)", [HONAppDelegate timelineBannerType]]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	if ([[[HONAppDelegate timelineBannerType] lowercaseString] isEqualToString:@"celeb"]) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteCelebViewController alloc] init]];
		if ([[HONAppDelegate timelineBannerURL] length] > 0) {
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	
	} else if ([[[HONAppDelegate timelineBannerType] lowercaseString] isEqualToString:@"popular"]) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONPopularViewController alloc] init]];
		if ([[HONAppDelegate timelineBannerURL] length] > 0) {
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	
	} else if ([[[HONAppDelegate timelineBannerType] lowercaseString] isEqualToString:@"instagram"]) {
		UIImage *image = [HONImagingDepictor prepImageForSharing:[UIImage imageNamed:@"share_template"] avatarImage:[HONAppDelegate avatarImage] username:[[HONAppDelegate infoForUser] objectForKey:@"name"]];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SEND_TO_INSTAGRAM" object:[NSDictionary dictionaryWithObjectsAndKeys:
																								[HONAppDelegate instagramShareComment], @"caption",
																								image, @"image", nil]];
	}
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

- (void)_goVerify {
	if (_emptyTimelineView == nil) {
		_emptyTimelineView = [[HONEmptyTimelineView alloc] initWithFrame:self.view.bounds];
		_emptyTimelineView.delegate = self;
		[self.view addSubview:_emptyTimelineView];
	}
}

- (void)_goAddContactsAlert {
	[[Mixpanel sharedInstance] track:@"Add Friends - Open"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	[self _removeToolTip];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
	
//	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Verify Account First?"
//														message:@"Would you like to verify your account before looking for friends (recommended)?"
//													   delegate:self
//											  cancelButtonTitle:@"Yes"
//											  otherButtonTitles:@"No", nil];
//	[alertView setTag:0];
//	[alertView show];
}

- (void)_goNewChallengeAtUser:(HONUserVO *)userVO {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:userVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - UI Presentation
- (void)_removeToolTip {
	if (_tooltipImageView != nil) {
		[_tooltipImageView removeFromSuperview];
		_tooltipImageView = nil;
	}
}


#pragma mark - Notifications
- (void)_removeVerify:(NSNotification *)notification {
	if (_emptyTimelineView != nil) {
		_emptyTimelineView.hidden = YES;
		[_emptyTimelineView removeFromSuperview];
	}
	
	_findFriendsScrollView.hidden = [[HONAppDelegate friendsList] count] > 0;
	
	if ([[notification object] isEqualToString:@"Y"])
		_findFriendsScrollView.hidden = YES;
}

- (void)_showPopularUsers:(NSNotification *)notification {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONPopularViewController alloc] init]];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_showAddContacts:(NSNotification *)notification {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Find Friends?"
														message:@"Would you like to find friends from your contacts list?"
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:1];
	[alertView show];
}

- (void)_refreshVoteTab:(NSNotification *)notification {
	[_tableView setContentOffset:CGPointZero animated:YES];
	[_headerView toggleRefresh:YES];
	
	if (_timelineType == HONTimelineTypeSingleUser)
		[self _retrieveUser];
	
	[self _retrieveChallenges];
}

- (void)_killTooltip:(NSNotification *)notification {
	[self _removeToolTip];
}


#pragma mark - TimelineItemCell Delegates
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell acceptChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Timeline - Accept Challenge"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithChallenge:challengeVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell joinChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Timeline - Join Challenge"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithJoinChallenge:challengeVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showComments:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Vote Wall - Comments"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	[self.navigationController pushViewController:[[HONCommentsViewController alloc] initWithChallenge:challengeVO] animated:YES];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showSubjectChallenges:(NSString *)subjectName {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUBJECT_SEARCH_TIMELINE" object:subjectName];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showUserChallenges:(NSString *)username {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_USER_SEARCH_TIMELINE" object:username];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showVoters:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Timeline - Show Voters"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	[self.navigationController pushViewController:[[HONVotersViewController alloc] initWithChallenge:challengeVO] animated:YES];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell snapAtChallenger:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Timeline - New Snap at Challenger"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
													   [NSString stringWithFormat:@"%d", challengeVO.challengerID], @"id",
													   [NSString stringWithFormat:@"%d", 0], @"points",
													   [NSString stringWithFormat:@"%d", 0], @"votes",
													   [NSString stringWithFormat:@"%d", 0], @"pokes",
													   [NSString stringWithFormat:@"%d", 0], @"pics",
													   [NSString stringWithFormat:@"%d", 0], @"age",
													   challengeVO.challengerName, @"username",
													   challengeVO.challengerFB, @"fb_id",
													   challengeVO.challengerAvatar, @"avatar_url", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:userVO withSubject:challengeVO.subjectName]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell snapAtCreator:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Timeline - New Snap at Creator"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
													   [NSString stringWithFormat:@"%d", challengeVO.creatorID], @"id",
													   [NSString stringWithFormat:@"%d", 0], @"points",
													   [NSString stringWithFormat:@"%d", 0], @"votes",
													   [NSString stringWithFormat:@"%d", 0], @"pokes",
													   [NSString stringWithFormat:@"%d", 0], @"pics",
													   [NSString stringWithFormat:@"%d", 0], @"age",
													   challengeVO.creatorName, @"username",
													   challengeVO.creatorFB, @"fb_id",
													   challengeVO.creatorAvatar, @"avatar_url", nil]];
	
	UINavigationController *navigationController;
	navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:userVO withSubject:challengeVO.subjectName]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell snapWithSubject:(NSString *)subjectName {
	[[Mixpanel sharedInstance] track:@"Timeline - New Snap with Hashtag"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  subjectName, @"subject", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithSubject:subjectName]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - UserProfileCell Delegates
- (void)userProfileViewCell:(HONUserProfileViewCell *)cell addFriend:(HONUserVO *)userVO {
	[[Mixpanel sharedInstance] track:@"Timeline Profile - Add Friend"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", userVO.userID, userVO.username], @"friend", nil]];
	
	[self _addFriend:userVO.userID];
}

- (void)userProfileViewCell:(HONUserProfileViewCell *)cell snapAtUser:(HONUserVO *)userVO {
	[[Mixpanel sharedInstance] track:@"Timeline Profile - Photo Message"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", userVO.userID, userVO.username], @"opponent", nil]];
	
	[self _goNewChallengeAtUser:userVO];
	//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:userVO]];
	//	[navigationController setNavigationBarHidden:YES];
	//	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)userProfileViewCell:(HONUserProfileViewCell *)cell showUserTimeline:(HONUserVO *)userVO {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_USER_SEARCH_TIMELINE" object:userVO.username];
}


#pragma mark - ProfileRequestView Delegates
- (void)profileRequestViewCellDoneAnimating:(HONUserProfileRequestViewCell *)profileRequestViewCell {
	_backButton.hidden = NO;
}

- (void)profileRequestViewCell:(HONUserProfileRequestViewCell *)profileRequestViewCell reportAbuse:(HONUserVO *)vo {
	[[Mixpanel sharedInstance] track:@"Timeline Profile - Report Abuse"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self _flagUser:vo.userID];
}

- (void)profileRequestViewCell:(HONUserProfileRequestViewCell *)profileRequestViewCell sendRequest:(HONUserVO *)vo {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:vo withSubject:@"#verifyMe"]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - EmptyTimelineView Delegates
- (void)emptyTimelineViewVerify:(HONEmptyTimelineView *)emptyTimelineView {
	[[Mixpanel sharedInstance] track:@"Timeline - Verify"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Use mobile #", @"Use email address", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	[actionSheet setTag:0];
	[actionSheet showInView:[HONAppDelegate appTabBarController].view];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (_isProfileViewable)
		return ([_challenges count] + ((int)(_userVO != nil && _timelineType == HONTimelineTypeSingleUser)));
	
	else
		return (1);
	
	//return (((int)(_isProfileViewable) * [_challenges count]) + ((int)(_userVO != nil && _timelineType == HONTimelineTypeSingleUser)));
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (_timelineType == HONTimelineTypeSingleUser)
		return (nil);
	
	else {
		UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)];
		
		UIImageView *bannerImageView = [[UIImageView alloc] initWithFrame:bgView.frame];
		[bannerImageView setImageWithURL:[NSURL URLWithString:[HONAppDelegate timelineBannerURL]] placeholderImage:nil];
		[bgView addSubview:bannerImageView];
		
		UIButton *bannerButton = [UIButton buttonWithType:UIButtonTypeCustom];
		bannerButton.frame = bannerImageView.frame;
		[bannerButton addTarget:self action:@selector(_goTimelineBanner) forControlEvents:UIControlEventTouchUpInside];
		[bgView addSubview:bannerButton];
		
		return (bgView);
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_timelineType == HONTimelineTypeSingleUser && _userVO != nil) {
		if (indexPath.row == 0) {
			if (_isProfileViewable) {
				HONUserProfileViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
				
				if (cell == nil) {
					cell = [[HONUserProfileViewCell alloc] init];
					cell.userVO = _userVO;
				}
				
				cell.delegate = self;
				[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
				return (cell);
				
			} else {
				HONUserProfileRequestViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
				
				if (cell == nil) {
					cell = [[HONUserProfileRequestViewCell alloc] init];
					cell.userVO = _userVO;
				}
				
				cell.delegate = self;
				[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
				return (cell);
			}
			
		} else {
			HONTimelineItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
			
			if (cell == nil) {
				HONChallengeVO *vo = (HONChallengeVO *)[_challenges objectAtIndex:indexPath.row - 1];
				cell = [[HONTimelineItemViewCell alloc] initAsStartedCell:(vo.statusID == 4)];
				cell.challengeVO = vo;
			}
			
			cell.delegate = self;
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			return (cell);
		}
		
	} else {
		HONTimelineItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
			HONChallengeVO *vo = (HONChallengeVO *)[_challenges objectAtIndex:indexPath.row];
			cell = [[HONTimelineItemViewCell alloc] initAsStartedCell:(vo.statusID == 4)];
			cell.challengeVO = vo;
		}
		
		cell.delegate = self;
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		return (cell);
	}
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		return ((_timelineType == HONTimelineTypeSingleUser) ? (_isProfileViewable) ? 237.0 : 620.0 : 320.0);
		
	} else
		return (320.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return ((([[HONAppDelegate timelineBannerURL] length] > 0) && !_isPushView) ? (int)!(_timelineType == HONTimelineTypeSingleUser) * 50.0 : 0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		if (buttonIndex == 0) {
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																	 delegate:self
															cancelButtonTitle:@"Cancel"
													   destructiveButtonTitle:nil
															otherButtonTitles:@"Use mobile #", @"Use email address", nil];
			actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
			[actionSheet setTag:0];
			[actionSheet showInView:[HONAppDelegate appTabBarController].view];
			
		} else if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
		
	} else if (alertView.tag == 1) {
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
			[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	}
}


#pragma mark - ActionSheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		switch (buttonIndex) {
			case 0:{
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONVerifyViewController alloc] initAsEmailVerify:NO]];
				[navigationController setNavigationBarHidden:YES];
				[self presentViewController:navigationController animated:YES completion:nil];
				break;}
				
			case 1:{
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONVerifyViewController alloc] initAsEmailVerify:YES]];
				[navigationController setNavigationBarHidden:YES];
				[self presentViewController:navigationController animated:YES completion:nil];
				break;}
		}
	
	} else if (actionSheet.tag == 1) {
		switch (buttonIndex) {
			case 0:{
				[[Mixpanel sharedInstance] track:@"Timeline Profile - More Self Flag User"
									  properties:[NSDictionary dictionaryWithObjectsAndKeys:
												  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"challenger", nil]];
				
				[self _flagUser:_userVO.userID];
				break;}
				
			case 1:{
				[[Mixpanel sharedInstance] track:@"Timeline Profile - More Self Snap At User"
									  properties:[NSDictionary dictionaryWithObjectsAndKeys:
												  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"challenger", nil]];
				
				[self _goNewChallengeAtUser:_userVO];
				break;}
				
			case 2:{
				[[Mixpanel sharedInstance] track:@"Timeline Profile - More Self Follow User"
									  properties:[NSDictionary dictionaryWithObjectsAndKeys:
												  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"challenger", nil]];
				
				[self _addFriend:_userVO.userID];
				break;}
		}
	}
}


@end
