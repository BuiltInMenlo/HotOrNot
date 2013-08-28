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
#import "HONOpponentVO.h"
#import "HONUserVO.h"
#import "HONTimelineHeaderView.h"
#import "HONRegisterViewController.h"
#import "HONImagePickerViewController.h"
#import "HONRefreshButtonView.h"
#import "HONCreateSnapButtonView.h"
#import "HONVotersViewController.h"
#import "HONCommentsViewController.h"
#import "HONSettingsViewController.h"
#import "HONInviteCelebViewController.h"
#import "HONEmptyTimelineView.h"
#import "HONAddContactsViewController.h"
#import "HONPopularViewController.h"
#import "HONVerifyViewController.h"
#import "HONImagingDepictor.h"
#import "HONChallengeDetailsViewController.h"
#import "HONSnapPreviewViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONChallengeOverlayView.h"


@interface HONTimelineViewController() <UIActionSheetDelegate, UIAlertViewDelegate, HONUserProfileViewCellDelegate, HONUserProfileRequestViewCellDelegate, HONTimelineItemViewCellDelegate, HONEmptyTimelineViewDelegate, HONTimelineHeaderViewDelegate, HONChallengeOverlayViewDelegate>
@property (readonly, nonatomic, assign) HONTimelineType timelineType;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSDictionary *challengerDict;
@property (nonatomic, strong) HONEmptyTimelineView *emptyTimelineView;
@property (nonatomic, strong) HONSnapPreviewViewController *snapPreviewViewController;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONOpponentVO *opponentVO;
@property (nonatomic, strong) HONChallengeOverlayView *challengeOverlayView;
@property (nonatomic, strong) UIView *bannerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *challenges;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic) BOOL isPushView;
@property (nonatomic) BOOL isPublic;
@property (nonatomic) BOOL isProfileViewable;
@property (nonatomic) BOOL isProfileFiltered;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONRefreshButtonView *refreshButtonView;
@property (nonatomic, strong) UIScrollView *findFriendsScrollView;
@property (nonatomic, strong) UIImageView *tooltipImageView;
@property (nonatomic, strong) HONUserVO *userVO;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic) int userID;
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


- (id)initWithUserID:(int)userID {
	if ((self = [super init])) {
		_isPushView = YES;
		_isPublic = YES;
		_isProfileFiltered = YES;
		_timelineType = HONTimelineTypeSingleUser;
		_userID = userID;
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithUsername:(NSString *)username {
	if ((self = [super init])) {
		_isPushView = YES;
		_isPublic = YES;
		_isProfileFiltered = YES;
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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedVoteTab:) name:@"SELECTED_VOTE_TAB" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshVoteTab:) name:@"REFRESH_VOTE_TAB" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectedVoteTab:) name:@"REFRESH_ALL_TABS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_removeVerify:) name:@"REMOVE_VERIFY" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showPopularUsers:) name:@"SHOW_POPULAR_USERS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showAddContacts:) name:@"SHOW_ADD_CONTACTS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_killTooltip:) name:@"KILL_TOOLTIP" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_removePreview:) name:@"REMOVE_PREVIEW" object:nil];
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
	
	UIImageView *bannerImageView = [[UIImageView alloc] initWithFrame:_bannerView.frame];
	[bannerImageView setImageWithURL:[NSURL URLWithString:[HONAppDelegate bannerForSection:(_timelineType == HONTimelineTypeFriends) ? 0 : 3]] placeholderImage:nil];
	[_bannerView addSubview:bannerImageView];
	
	UIButton *bannerButton = [UIButton buttonWithType:UIButtonTypeCustom];
	bannerButton.frame = bannerImageView.frame;
	[bannerButton addTarget:self action:@selector(_goCloseBanner) forControlEvents:UIControlEventTouchUpInside];
	[_bannerView addSubview:bannerButton];
	
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[params setObject:[NSString stringWithFormat:@"%d", _timelineType] forKey:@"action"];
	[params setObject:(_isPublic) ? @"N" : @"Y" forKey:@"isPrivate"];
	
	// all public
	if (_timelineType == HONTimelineTypePublic) {
		
		// with hashtag
	} else if (_timelineType == HONTimelineTypeSubject) {
		[params setObject:_subjectName forKey:@"subjectName"];
		
		// a user's
	} else if (_timelineType == HONTimelineTypeSingleUser) {
		[params setObject:_username forKey:@"username"];
		[params setObject:[NSString stringWithFormat:@"%d", _isProfileFiltered] forKey:@"p"];
	}
	
	NSLog(@"PARAMS:[%@]", params);
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *challengesResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], challengesResult);
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], [challengesResult objectAtIndex:0]);
			
			_challenges = [NSMutableArray array];
			
			for (NSDictionary *serverList in challengesResult) {
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
				
				if (vo != nil) {
					if (vo.expireSeconds != 0)
						[_challenges addObject:vo];
				}
			}
			
			if (_timelineType == HONTimelineTypeOpponents) {
				HONChallengeVO *vo = (HONChallengeVO *)[_challenges lastObject];
				self.navigationController.navigationBar.topItem.title = [NSString stringWithFormat:@"@%@", ([((HONOpponentVO *)[vo.challengers lastObject]).username length] == 0) ? vo.creatorVO.username : (vo.creatorVO.userID == [[_challengerDict objectForKey:@"user1"] intValue] && vo.creatorVO.userID != [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? vo.creatorVO.username : ((HONOpponentVO *)[vo.challengers lastObject]).username];
			}
			
			[_tableView reloadData];
		}
		
		[_refreshButtonView toggleRefresh:NO];
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
		
		[_refreshButtonView toggleRefresh:NO];
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

- (void)_retrieveUserByID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 5], @"action",
							[NSString stringWithFormat:@"%d", _userID], @"userID",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			_userVO = [HONUserVO userWithDictionary:userResult];
			_username = _userVO.username;
			
			self.navigationController.navigationBar.topItem.title = @"Me";
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

- (void)_retrieveUserByUsername {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 8], @"action",
							_username, @"username",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			_userVO = [HONUserVO userWithDictionary:userResult];
			
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
							@"0", @"auto", nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIAddFriend);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIAddFriend parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

- (void)_removeFriend:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", userID], @"target", nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIRemoveFriend);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIRemoveFriend parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
							[NSString stringWithFormat:@"%d", 10], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", userID], @"targetID",
							[NSString stringWithFormat:@"%d", 0], @"approves",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
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

- (void)_upvoteChallenge:(int)userID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 6], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
							[NSString stringWithFormat:@"%d", userID], @"challengerID",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIVotes parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSDictionary *voteResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], voteResult);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h@2x" : @"mainBG"]];
	bgImageView.frame = self.view.bounds;
	//[self.view addSubview:bgImageView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_userVO = nil;
	_isProfileViewable = YES;
	
	_challenges = [NSMutableArray array];
	_cells = [NSMutableArray array];
	
	if (_isPushView) {
		NSString *title = @"Me";
		if (_timelineType == HONTimelineTypeSubject) {
			title = _subjectName;
		
		} else if (_timelineType == HONTimelineTypeSingleUser && _username != nil) {
			title = [NSString stringWithFormat:@"@%@", _username];
			
			if ([[[HONAppDelegate infoForUser] objectForKey:@"username"] isEqualToString:_username] && [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"current_tab"] intValue] == 3) {
				_refreshButtonView = [[HONRefreshButtonView alloc] initWithTarget:self action:@selector(_goRefresh)];
				self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_refreshButtonView];
			}
		}
		
		self.navigationController.navigationBar.topItem.title = (_timelineType == HONTimelineTypeSingleUser && [[[HONAppDelegate infoForUser] objectForKey:@"username"] isEqualToString:_username]) ? @"Me" : title;
		
	} else {
		_refreshButtonView = [[HONRefreshButtonView alloc] initWithTarget:self action:@selector(_goRefresh)];
		self.navigationController.navigationBar.topItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headerLogo"]];
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_refreshButtonView];
	}
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[HONCreateSnapButtonView alloc] initWithTarget:self action:@selector(_goCreateChallenge)]];
	
	_bannerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 90.0)];
	[self.view addSubview:_bannerView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 90.0 * [[[NSUserDefaults standardUserDefaults] objectForKey:@"timeline2_banner"] isEqualToString:@"YES"], [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 14.0 - kTabSize.height - (90.0 * [[[NSUserDefaults standardUserDefaults] objectForKey:@"timeline2_banner"] isEqualToString:@"YES"])) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.rowHeight = 249.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self.view addSubview:_tableView];
	
	_findFriendsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, ([HONAppDelegate isRetina5]) ? 454.0 : 366.0)];
	_findFriendsScrollView.contentSize = CGSizeMake(_findFriendsScrollView.frame.size.width, _findFriendsScrollView.frame.size.height+ 1.0);
	_findFriendsScrollView.pagingEnabled = NO;
	_findFriendsScrollView.showsVerticalScrollIndicator = YES;
	_findFriendsScrollView.showsHorizontalScrollIndicator = NO;
	_findFriendsScrollView.backgroundColor = [UIColor whiteColor];
	_findFriendsScrollView.hidden = YES; //([_challenges count] > 0 || [[HONAppDelegate friendsList] count] > 0 || _isPushView);
	//[self.view addSubview:_findFriendsScrollView];
	
	UIImageView *findFriendsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, ([HONAppDelegate isRetina5]) ? 454.0 : 366.0)];
	findFriendsImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"findFriends-568h@2x" : @"findFriends"];
	findFriendsImageView.userInteractionEnabled = YES;
	[_findFriendsScrollView addSubview:findFriendsImageView];
	
	UIButton *ctaButton = [UIButton buttonWithType:UIButtonTypeCustom];
	ctaButton.frame = CGRectMake(0.0, 302.0, 320.0, 53.0);
	[ctaButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
	[ctaButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
	[ctaButton addTarget:self action:@selector(_goAddContactsAlert) forControlEvents:UIControlEventTouchUpInside];
	[findFriendsImageView addSubview:ctaButton];
	
//	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
//	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
//	_progressHUD.mode = MBProgressHUDModeIndeterminate;
//	_progressHUD.minShowTime = kHUDTime;
//	_progressHUD.taskInProgress = YES;
	
	[self performSelector:@selector(_retrieveChallenges) withObject:nil afterDelay:0.5];
	
	if (_timelineType == HONTimelineTypeSingleUser) {
		if (_username != nil)
			[self _retrieveUserByUsername];
		
		else
			[self _retrieveUserByID];
	}
	
	if (!_isPushView) {
#if __ALWAYS_VERIFY__ == 1
		[self _goVerify];
#endif
		
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] == nil)
			[self _goRegistration];
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
	[_refreshButtonView toggleRefresh:YES];
	[[Mixpanel sharedInstance] track:@"Timeline - Refresh"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if (_timelineType == HONTimelineTypeSingleUser)
		[self _retrieveUserByUsername];
	
	[self _retrieveChallenges];
}

- (void)_goCreateChallenge {
	[[Mixpanel sharedInstance] track:@"Timeline - Create Snap"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self _removeToolTip];
	
//	if (_userVO == nil) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:NO completion:nil];
		
//	} else {
//		if ([_userVO.username isEqualToString:[[HONAppDelegate infoForUser] objectForKey:@"name"]]) {
//			[[[UIAlertView alloc] initWithTitle:@"Snap Problem!"
//										message:@"You cannot snap at yourself!"
//									   delegate:nil
//							  cancelButtonTitle:@"OK"
//							  otherButtonTitles:nil] show];
//			
//		} else {
//			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:_userVO]];
//			[navigationController setNavigationBarHidden:YES];
//			[self presentViewController:navigationController animated:YES completion:nil];
//		}
//	}
}

- (void)_goCloseBanner {
	[[Mixpanel sharedInstance] track:@"Timeline - Close Banner"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void) {
		_tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y - 90.0, _tableView.frame.size.width, _tableView.frame.size.height + 90.0);
	} completion:^(BOOL finished) {
		[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"timeline2_banner"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}];
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
	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONRestrictedLocaleViewController alloc] init]];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:NO completion:^(void) {
//	}];
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
	if (_timelineType == HONTimelineTypeFriends) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Find friends who Volley"
															message:@"Would you like to find friends who Volley?"
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"Yes", nil];
		[alertView setTag:1];
		[alertView show];
	}
}

- (void)_selectedVoteTab:(NSNotification *)notification {
	[_tableView setContentOffset:CGPointZero animated:YES];
	[_refreshButtonView toggleRefresh:YES];
	
	if (_timelineType == HONTimelineTypeSingleUser)
		[self _retrieveUserByUsername];
	
	[self _retrieveChallenges];
}

- (void)_refreshVoteTab:(NSNotification *)notification {
	[_refreshButtonView toggleRefresh:YES];
	
	if (_timelineType == HONTimelineTypeSingleUser)
		[self _retrieveUserByUsername];
	
	[self _retrieveChallenges];
}

- (void)_killTooltip:(NSNotification *)notification {
	[self _removeToolTip];
}

- (void)_removePreview:(NSNotification *)notification {
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
	
	_challengeOverlayView = [[HONChallengeOverlayView alloc] initWithChallenge:_challengeVO forOpponent:_opponentVO];
	_challengeOverlayView.delegate = self;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_challengeOverlayView];
}


#pragma mark - TimelineHeader Delegates
- (void)timelineHeaderView:(HONTimelineHeaderView *)cell showDetails:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Timeline Header - Show Challenge"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	[self.navigationController pushViewController:[[HONChallengeDetailsViewController alloc] initWithChallenge:challengeVO asModal:NO] animated:YES];
}

- (void)timelineHeaderView:(HONTimelineHeaderView *)cell showCreatorTimeline:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline Header - Show Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.creatorVO.userID, _challengeVO.creatorVO.username], @"creator", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_USER_SEARCH_TIMELINE" object:challengeVO.creatorVO.username];
}

#pragma mark - TimelineItemCell Delegates
- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline - Show Challenge"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	[self.navigationController pushViewController:[[HONChallengeDetailsViewController alloc] initWithChallenge:challengeVO asModal:NO] animated:YES];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell acceptChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline - Accept Challenge"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithChallenge:challengeVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell joinChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline - Join Challenge"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithJoinChallenge:challengeVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showComments:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline - Comments"
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
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline - Show Voters"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	[self.navigationController pushViewController:[[HONVotersViewController alloc] initWithChallenge:challengeVO] animated:YES];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell snapAtChallenger:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline - New Snap at Challenger"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
													   [NSString stringWithFormat:@"%d", ((HONOpponentVO *)[challengeVO.challengers lastObject]).userID], @"id",
													   [NSString stringWithFormat:@"%d", 0], @"points",
													   [NSString stringWithFormat:@"%d", 0], @"votes",
													   [NSString stringWithFormat:@"%d", 0], @"pokes",
													   [NSString stringWithFormat:@"%d", 0], @"pics",
													   [NSString stringWithFormat:@"%d", 0], @"age",
													   ((HONOpponentVO *)[challengeVO.challengers lastObject]).username, @"username",
													   ((HONOpponentVO *)[challengeVO.challengers lastObject]).fbID, @"fb_id",
													   ((HONOpponentVO *)[challengeVO.challengers lastObject]).avatarURL, @"avatar_url", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithUser:userVO withSubject:challengeVO.subjectName]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell snapAtCreator:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline - New Snap at Creator"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge", nil]];
	
	HONUserVO *userVO = [HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
													   [NSString stringWithFormat:@"%d", challengeVO.creatorVO.userID], @"id",
													   [NSString stringWithFormat:@"%d", 0], @"points",
													   [NSString stringWithFormat:@"%d", 0], @"votes",
													   [NSString stringWithFormat:@"%d", 0], @"pokes",
													   [NSString stringWithFormat:@"%d", 0], @"pics",
													   [NSString stringWithFormat:@"%d", 0], @"age",
													   challengeVO.creatorVO.username, @"username",
													   challengeVO.creatorVO.fbID, @"fb_id",
													   challengeVO.creatorVO.avatarURL, @"avatar_url", nil]];
	
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

- (void)timelineItemViewCell:(HONTimelineItemViewCell *)cell showPreview:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	_opponentVO = opponentVO;
	
	_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initWithOpponent:opponentVO];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
}

- (void)timelineItemViewCellHidePreview:(HONTimelineItemViewCell *)cell {
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
	
	_challengeOverlayView = [[HONChallengeOverlayView alloc] initWithChallenge:_challengeVO forOpponent:_opponentVO];
	_challengeOverlayView.delegate = self;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_challengeOverlayView];
}

#pragma mark - ChallengeOverlay Delegates
- (void)challengeOverlayViewUpvote:(HONChallengeOverlayView *)challengeOverlayView opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	_opponentVO = opponentVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline - Upvote"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	if (_challengeOverlayView != nil) {
		[_challengeOverlayView removeFromSuperview];
		_challengeOverlayView = nil;
	}
	
	UIImageView *heartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heartAnimation"]];
	heartImageView.frame = CGRectOffset(heartImageView.frame, 28.0, (([UIScreen mainScreen].bounds.size.height - 108.0) * 0.5) + 10.0);
	[self.view addSubview:heartImageView];
	
	[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		heartImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[heartImageView removeFromSuperview];
	}];
	
	for (HONTimelineItemViewCell *cell in _cells) {
		if (cell.challengeVO.challengeID == challengeVO.challengeID)
			[cell upvoteUser:opponentVO.userID];
	}
	
	[self _upvoteChallenge:_opponentVO.userID];
}

- (void)challengeOverlayViewFlag:(HONChallengeOverlayView *)challengeOverlayView opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	_opponentVO = opponentVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline - Flag"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:@"This person will be flagged for review"
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes, flag user", nil];
	
	[alertView setTag:2];
	[alertView show];
	
	if (_challengeOverlayView != nil) {
		[_challengeOverlayView removeFromSuperview];
		_challengeOverlayView = nil;
	}
}

- (void)challengeOverlayViewProfile:(HONChallengeOverlayView *)challengeOverlayView opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	_opponentVO = opponentVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline - User Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_USER_SEARCH_TIMELINE" object:_opponentVO.username];
	
	if (_challengeOverlayView != nil) {
		[_challengeOverlayView removeFromSuperview];
		_challengeOverlayView = nil;
	}
}

- (void)challengeOverlayViewClose:(HONChallengeOverlayView *)challengeOverlayView {
	if (_challengeOverlayView != nil) {
		[_challengeOverlayView removeFromSuperview];
		_challengeOverlayView = nil;
	}
}


#pragma mark - UserProfileCell Delegates
- (void)userProfileViewCell:(HONUserProfileViewCell *)cell flagUser:(HONUserVO *)userVO {
	[[Mixpanel sharedInstance] track:@"Timeline Profile - Flag User"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", userVO.userID, userVO.username], @"friend", nil]];
	
	[[Mixpanel sharedInstance] track:@"Timeline - Flag"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:@"This person will be flagged for review"
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes, flag user", nil];
	
	[alertView setTag:2];
	[alertView show];
	
	[self _flagUser:userVO.userID];
}

- (void)userProfileViewCell:(HONUserProfileViewCell *)cell addFriend:(HONUserVO *)userVO {
	_userVO = userVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline Profile - Add Friend"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", userVO.userID, userVO.username], @"friend", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:[NSString stringWithFormat:@"You will receive Volley updates from @%@", userVO.username]
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:3];
	[alertView show];
}

- (void)userProfileViewCell:(HONUserProfileViewCell *)cell removeFriend:(HONUserVO *)userVO {
	_userVO = userVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline Profile - Remove Friend"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", userVO.userID, userVO.username], @"friend", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:[NSString stringWithFormat:@"You will no longer receive Volley updates from @%@", userVO.username]
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:4];
	[alertView show];
}

- (void)userProfileViewCell:(HONUserProfileViewCell *)cell snapAtUser:(HONUserVO *)userVO {
	[[Mixpanel sharedInstance] track:@"Timeline Profile - Photo Message"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", userVO.userID, userVO.username], @"opponent", nil]];
	
	[self _goNewChallengeAtUser:userVO];
}

- (void)userProfileViewCell:(HONUserProfileViewCell *)cell showUserTimeline:(HONUserVO *)userVO {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_USER_SEARCH_TIMELINE" object:userVO.username];
}

- (void)userProfileViewCellMore:(HONUserProfileViewCell *)cell asProfile:(BOOL)isUser {
	if (isUser) {
		[[Mixpanel sharedInstance] track:@"Profile - Settings"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSettingsViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
	
	} else {
		BOOL isFriend = NO;
		for (HONUserVO *vo in [HONAppDelegate friendsList]) {
			if (vo.userID == _userVO.userID) {
				isFriend = YES;
				break;
			}
		}
		
		[[Mixpanel sharedInstance] track:@"Timeline Profile - More Self"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"challenger", nil]];
		
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																 delegate:self
														cancelButtonTitle:@"Cancel"
												   destructiveButtonTitle:@"Flag"
														otherButtonTitles:(isFriend) ? @"Unsubscribe" : @"Subscribe", nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
		[actionSheet setTag:1];
		[actionSheet showInView:[HONAppDelegate appTabBarController].view];
	}
}

- (void)userProfileViewCellFindFriends:(HONUserProfileViewCell *)cell {
	[[Mixpanel sharedInstance] track:@"Profile - Find Friends Button"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)userProfileViewCellTakeNewAvatar:(HONUserProfileViewCell *)cell {
	[[Mixpanel sharedInstance] track:@"Profile - Take New Avatar"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}


#pragma mark - ProfileRequestView Delegates
- (void)profileRequestViewCellDoneAnimating:(HONUserProfileRequestViewCell *)profileRequestViewCell {
	_backButton.hidden = NO;
}

- (void)profileRequestViewCell:(HONUserProfileRequestViewCell *)profileRequestViewCell showMore:(HONUserVO *)vo {
	[[Mixpanel sharedInstance] track:@"Profile Request - More Self"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", 
									  [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username], @"opponent", nil]];
	
	_userVO = vo;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:@"Report Abuse"
													otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	[actionSheet setTag:2];
	[actionSheet showInView:[HONAppDelegate appTabBarController].view];
	
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
	return (1);
	//return (((int)(_isProfileViewable) * [_challenges count]) + ((int)(_userVO != nil && _timelineType == HONTimelineTypeSingleUser)));
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (_isProfileViewable || _timelineType == HONTimelineTypeSubject)
		return ([_challenges count] + ((int)(_userVO != nil && _timelineType == HONTimelineTypeSingleUser)));
	
	else
		return (1);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (_timelineType == HONTimelineTypeSingleUser && section == 0)
		return (nil);
	
	else {
		HONTimelineHeaderView *headerView = [[HONTimelineHeaderView alloc] initWithChallenge:(HONChallengeVO *)[_challenges objectAtIndex:section - ((int)_timelineType == HONTimelineTypeSingleUser)]];
		headerView.delegate = self;
		return (headerView);
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_timelineType == HONTimelineTypeSingleUser && _userVO != nil) {
		if (indexPath.section == 0) {
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
				HONChallengeVO *vo = (HONChallengeVO *)[_challenges objectAtIndex:indexPath.section - 1];
				cell = [[HONTimelineItemViewCell alloc] initAsStartedCell:(vo.statusID == 4)];
				cell.challengeVO = vo;
			}
			
			[_cells addObject:cell];
			cell.delegate = self;
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			return (cell);
		}
		
	} else {
		HONTimelineItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
		
		if (cell == nil) {
			HONChallengeVO *vo = (HONChallengeVO *)[_challenges objectAtIndex:indexPath.section];
			cell = [[HONTimelineItemViewCell alloc] initAsStartedCell:(vo.statusID == 4)];
			cell.challengeVO = vo;
		}
		
		[_cells addObject:cell];
		cell.delegate = self;
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		return (cell);
	}
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0)
		return ((_timelineType == HONTimelineTypeSingleUser) ? 248.0 : 286.0);
		
	else {
		if (_timelineType == HONTimelineTypeSingleUser)
			return ((indexPath.section == [_challenges count]) ? 333.0 : 286.0);
		
		else
			return ((indexPath.section == [_challenges count] - 1) ? 333.0 : 286.0);
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return ((_timelineType == HONTimelineTypeSingleUser && section == 0) ? 0.0 : 56.0);
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
	
	} else if (alertView.tag == 2) {
		if (buttonIndex == 1)
			[self _flagUser:(_userVO != nil) ? _userVO.userID : _opponentVO.userID];
	
	} else if (alertView.tag == 3) {
		if (buttonIndex == 1) {
			[self _addFriend:_userVO.userID];
			HONUserProfileViewCell *cell = (HONUserProfileViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
			[cell updateFriendButton:YES];
		}
		
	} else if (alertView.tag == 4) {
		if (buttonIndex == 1) {
			[self _removeFriend:_userVO.userID];
			HONUserProfileViewCell *cell = (HONUserProfileViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
			[cell updateFriendButton:NO];
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
				
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
																	message:@"This person will be flagged for review"
																   delegate:self
														  cancelButtonTitle:@"No"
														  otherButtonTitles:@"Yes, flag user", nil];
				
				[alertView setTag:2];
				[alertView show];
				break;}
				
			case 1:{
				BOOL isFriend = NO;
				for (HONUserVO *vo in [HONAppDelegate friendsList]) {
					if (vo.userID == _userVO.userID) {
						isFriend = YES;
						break;
					}
				}
				
				
				[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline Profile - %@ Friend", (isFriend) ? @"Remove" : @"Add"]
									  properties:[NSDictionary dictionaryWithObjectsAndKeys:
												  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"challenger", nil]];
				
				if (isFriend) {;
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
																		message:[NSString stringWithFormat:@"You will no longer receive Volley updates from @%@", _userVO.username]
																	   delegate:self
															  cancelButtonTitle:@"No"
															  otherButtonTitles:@"Yes", nil];
					[alertView setTag:4];
					[alertView show];
				
				} else {
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
																		message:[NSString stringWithFormat:@"You will receive Volley updates from @%@", _userVO.username]
																	   delegate:self
															  cancelButtonTitle:@"No"
															  otherButtonTitles:@"Yes", nil];
					[alertView setTag:3];
					[alertView show];
				}
				
				break;}
		}
	
	} else if (actionSheet.tag == 2) {
		switch (buttonIndex) {
			case 0:{
				[[Mixpanel sharedInstance] track:@"Timeline Profile - More Self Flag User"
									  properties:[NSDictionary dictionaryWithObjectsAndKeys:
												  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"challenger", nil]];
				
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
																	message:@"This person will be flagged for review"
																   delegate:self
														  cancelButtonTitle:@"No"
														  otherButtonTitles:@"Yes, flag user", nil];
				
				[alertView setTag:2];
				[alertView show];
				break;}
		}
	}
}


@end
