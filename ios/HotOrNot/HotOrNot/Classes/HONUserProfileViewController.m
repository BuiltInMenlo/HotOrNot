//
//  HONUserProfileViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/7/13 @ 9:46 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "EGORefreshTableHeaderView.h"
#import "UIImageView+AFNetworking.h"

#import "HONUserProfileViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONSnapPreviewViewController.h"
#import "HONAddContactsViewController.h"
#import "HONSettingsViewController.h"
#import "HONPopularViewController.h"
#import "HONImagingDepictor.h"
#import "HONOpponentVO.h"
#import "HONHeaderView.h"
#import "HONUserVO.h"


@interface HONUserProfileViewController () <HONSnapPreviewViewControllerDelegate>
@property (nonatomic, strong) HONUserVO *userVO;
@property (nonatomic, strong) UIView *bgHolderView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) HONSnapPreviewViewController *snapPreviewViewController;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *avatarHolderView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *subscribersLabel;
@property (nonatomic, strong) UILabel *volleysLabel;
@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, strong) UIView *gridHolderView;
@property (nonatomic, strong) NSMutableArray *challenges;
@property (nonatomic, strong) UIToolbar *footerToolbar;
@property (nonatomic, strong) UIButton *subscribeButton;
@property (nonatomic, strong) UIButton *flagButton;
@property (nonatomic) int challengeCounter;
@property (nonatomic) BOOL isRefreshing;
@end


@implementation HONUserProfileViewController

@synthesize userID = _userID;

- (id)initWithBackground:(UIImageView *)imageView {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor clearColor];
		_bgImageView = imageView;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshProfile:) name:@"REFRESH_PROFILE" object:nil];
	}
	
	return (self);
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
- (void)_retrieveUser:(BOOL)isRefresh {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 5], @"action",
							[NSString stringWithFormat:@"%d", _userID], @"userID",
							nil];
	
	NSLog(@"USER BY ID PARAMS:[%@]", params);
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
			[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
			
			_userVO = [HONUserVO userWithDictionary:userResult];
			
			if (isRefresh) {
				[_avatarImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
				_subscribersLabel.text = [NSString stringWithFormat:@"%@ subscriber%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[_userVO.friends count]]], ([_userVO.friends count] == 1) ? @"" : @"s"];
				_volleysLabel.text = [NSString stringWithFormat:@"%@ volley%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.pics]], (_userVO.pics == 1) ? @"" : @"s"];
				_likesLabel.text = [NSString stringWithFormat:@"%@ like%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]], (_userVO.votes == 1) ? @"" : @"s"];
			
			} else
				[self _makeUI];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}

- (void)_retrieveChallenges {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[params setObject:[NSString stringWithFormat:@"%d", 9] forKey:@"action"];
	[params setObject:@"N" forKey:@"isPrivate"];
	[params setObject:_userVO.username forKey:@"username"];
	[params setObject:[NSString stringWithFormat:@"%d", 1] forKey:@"p"];
	
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
			
			_isRefreshing = NO;
			[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_scrollView];
			
			_scrollView.contentSize = CGSizeMake(320.0, MAX([UIScreen mainScreen].bounds.size.height + 1.0, 555.0 + (kSnapMediumDim * ([_challenges count] / 5))));
			[self _makeGrid];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIVotes, [error localizedDescription]);
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
				[HONAppDelegate writeSubscribeeList:result];
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
				[HONAppDelegate writeSubscribeeList:result];
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


#pragma mark - Public APIs
- (void)setUserID:(int)userID {
	_userID = userID;
	[self _retrieveUser:NO];
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	_bgHolderView = [[UIView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:_bgHolderView];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height)];
	_scrollView.pagingEnabled = NO;
	_scrollView.delegate = self;
	_scrollView.showsVerticalScrollIndicator = YES;
	_scrollView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_scrollView];
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	lpGestureRecognizer.minimumPressDuration = 0.25;
	[_scrollView addGestureRecognizer:lpGestureRecognizer];
	
	//	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
	//	_refreshTableHeaderView.delegate = self;
	//	[_scrollView addSubview:_refreshTableHeaderView];
	//	[_refreshTableHeaderView refreshLastUpdatedDate];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:doneButton];
	
	_headerView = [[HONHeaderView alloc] initAsModalWithTitle:@""];
	[_headerView addButton:doneButton];
	[self.view addSubview:_headerView];
	
	_footerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 44.0, 320.0, 44.0)];
	[self.view addSubview:_footerToolbar];
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
	[_bgHolderView addSubview:_bgImageView];
	
	if ([[HONAppDelegate subscribeeList] count] < [HONAppDelegate profileFriendsThreshold]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
															message:@"Find more people to subscribe to?"
														   delegate:nil
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"Find people", nil];
		[alertView setTag:5];
		[alertView show];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
- (void)_goDone {
	if (_userVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Share Volley?"
															message:@"Would you like to share Volley on Instagram?"
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"Yes", nil];
		
		[alertView setTag:1];
		[alertView show];
	
	} else {
		BOOL isFriend = NO;
		for (HONUserVO *vo in [HONAppDelegate subscribeeList]) {
			if (vo.userID == _userVO.userID) {
				isFriend = YES;
				break;
			}
		}
		
		int profile_total = 0;
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"profile_total"]) {
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:profile_total] forKey:@"profile_total"];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
		profile_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"profile_total"] intValue];
		
		if (!isFriend  && profile_total < 3) {
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++profile_total] forKey:@"profile_total"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																message:[NSString stringWithFormat:@"Want to subscribe to @%@'s updates?", _userVO.username]
															   delegate:self
													  cancelButtonTitle:@"No"
													  otherButtonTitles:@"Yes", nil];
			[alertView setTag:0];
			[alertView show];
		
		} else {
			[self dismissViewControllerAnimated:YES completion:^(void) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
			}];
		}
	}
}

- (void)_goChangeAvatar {
	[[Mixpanel sharedInstance] track:@"User Profile - Take New Avatar"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goRefresh {
	[self _retrieveUser:YES];
	
	for (UIImageView *imageView in _gridHolderView.subviews)
		[imageView removeFromSuperview];
	
	[_gridHolderView removeFromSuperview];
	_gridHolderView = nil;
	
	[self _retrieveChallenges];
}

- (void)_goSubscribe {
	[[Mixpanel sharedInstance] track:@"User Profile - Subscribe"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"friend", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:[NSString stringWithFormat:@"You will receive Volley updates from @%@", _userVO.username]
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:3];
	[alertView show];
}

- (void)_goUnsubscribe {
	[[Mixpanel sharedInstance] track:@"User Profile - Unsubscribe"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"friend", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:[NSString stringWithFormat:@"You will no longer receive Volley updates from @%@", _userVO.username]
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:4];
	[alertView show];
}

- (void)_goFlag {
	[[Mixpanel sharedInstance] track:@"User Profile - Flag"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:@"This person will be flagged for review"
													   delegate:self
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes, flag user", nil];
	
	[alertView setTag:2];
	[alertView show];
}

- (void)_goInviteFriends {
	[[Mixpanel sharedInstance] track:@"User Profile - Find Friends"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goSettings {
	[[Mixpanel sharedInstance] track:@"Profile - Settings"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSettingsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - Notifications
- (void)_refreshProfile:(NSNotification *)notification {
	[self _goRefresh];
}


#pragma mark - UI Presentation
- (void)_reloadAvatarImage {
	__weak typeof(self) weakSelf = self;
	
	CGSize imageSize = ([HONAppDelegate isRetina5]) ? CGSizeMake(426.0, 568.0) : CGSizeMake(360.0, 480.0);
	NSMutableString *imageURL = [_userVO.imageURL mutableCopy];
	[imageURL replaceOccurrencesOfString:@".jpg" withString:@"_o.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imageURL length])];
	[imageURL replaceOccurrencesOfString:@"Large_640x1136_o.jpg" withString:@"_o.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imageURL length])];
	CGRect frame = CGRectMake((imageSize.width - 320.0) * -0.5, -114.0, imageSize.width, imageSize.height);
	
	NSLog(@"PROFILE RELOADING:[%@]", imageURL);
	
	_avatarHolderView.clipsToBounds = YES;
	_avatarImageView = [[UIImageView alloc] initWithFrame:frame];
	_avatarImageView.alpha = 0.0;
	[_avatarHolderView addSubview:_avatarImageView];
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]
															   cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
							 placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
								 weakSelf.avatarImageView.image = image;
								 [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.avatarImageView.alpha = 1.0; } completion:nil];
							 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
								 NSLog(@"%@", weakSelf.userVO.imageURL);
							 }];
}

-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint touchPoint = [lpGestureRecognizer locationInView:_scrollView];
		
		HONChallengeVO *challengeVO = nil;
		HONOpponentVO *opponentVO = nil;
		
		if (CGRectContainsPoint(_gridHolderView.frame, touchPoint)) {
			int col = touchPoint.x / (kSnapMediumDim + 1.0);
			int row = (touchPoint.y - _gridHolderView.frame.origin.y) / (kSnapMediumDim + 1.0);
			
			if ((row * 4) + col < [_challenges count]) {
				challengeVO = (HONChallengeVO *)[_challenges objectAtIndex:(row * 4) + col];
				opponentVO = challengeVO.creatorVO;
			}
		}
		
		if (opponentVO != nil) {
			[[Mixpanel sharedInstance] track:@"User Profile - Show Photo Detail"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
											  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
											  [NSString stringWithFormat:@"%d - %@", opponentVO.userID, opponentVO.username], @"opponent",
											  nil]];
			
			_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initWithOpponent:opponentVO forChallenge:challengeVO asRoot:YES];
			_snapPreviewViewController.delegate = self;
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
		}
		
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
		[_snapPreviewViewController showControls];
	}
}

- (void)_makeUI {
	BOOL isUser = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID);
	
	BOOL isFriend = NO;
	if (!isUser) {
		for (HONUserVO *vo in [HONAppDelegate subscribeeList]) {
			if (vo.userID == _userVO.userID) {
				isFriend = YES;
				break;
			}
		}
	}
	
	[_headerView setTitle:[NSString stringWithFormat:@"%@, %d", _userVO.username, [HONAppDelegate ageForDate:_userVO.birthday]]];
	
	UIImageView *verifiedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkIcon"]];
	verifiedImageView.frame = CGRectOffset(verifiedImageView.frame, 10.0, 11.0);
	verifiedImageView.hidden = (_userVO.abuseCount > -10);
	[_headerView addButton:verifiedImageView];
	
	_avatarHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 224.0)];
	_avatarHolderView.clipsToBounds = YES;
	[_scrollView addSubview:_avatarHolderView];
	
	NSMutableString *imageURL = [_userVO.imageURL mutableCopy];
	[imageURL replaceOccurrencesOfString:@".jpg" withString:@"Large_640x1136.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imageURL length])];
	[imageURL replaceOccurrencesOfString:@"Large_640x1136Large_640x1136.jpg" withString:@"Large_640x1136.jpg" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imageURL length])];
	CGRect frame = CGRectMake(0.0, -114.0, 320.0, 568.0);
	
	NSLog(@"PROFILE LOADING:[%@]", imageURL);
	
	__weak typeof(self) weakSelf = self;
	_avatarImageView = [[UIImageView alloc] initWithFrame:frame];
	_avatarImageView.alpha = 0.0;
	[_avatarImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]
															  cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
							placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
								weakSelf.avatarImageView.image = image;
								[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.avatarImageView.alpha = 1.0; } completion:nil];
							} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
								[weakSelf _reloadAvatarImage];
							}];
	[_avatarHolderView addSubview:_avatarImageView];
	
	UIButton *profilePicButton = [UIButton buttonWithType:UIButtonTypeCustom];
	profilePicButton.frame = CGRectMake(270.0, 178.0, 44.0, 44.0);
	[profilePicButton setBackgroundImage:[UIImage imageNamed:@"addPhoto_nonActive"] forState:UIControlStateNormal];
	[profilePicButton setBackgroundImage:[UIImage imageNamed:@"addPhoto_Active"] forState:UIControlStateHighlighted];
	[profilePicButton addTarget:self action:@selector(_goChangeAvatar) forControlEvents:UIControlEventTouchUpInside];
	profilePicButton.hidden = !([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID);
	[_scrollView addSubview:profilePicButton];
	
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	_subscribersLabel = [[UILabel alloc] initWithFrame:CGRectMake(21.0, 260.0, 260.0, 30.0)];
	_subscribersLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:25];
	_subscribersLabel.textColor = [UIColor whiteColor];
	_subscribersLabel.backgroundColor = [UIColor clearColor];
	_subscribersLabel.text = [NSString stringWithFormat:@"%@ subscriber%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[_userVO.friends count]]], ([_userVO.friends count] == 1) ? @"" : @"s"];
	[_scrollView addSubview:_subscribersLabel];
	
	_volleysLabel = [[UILabel alloc] initWithFrame:CGRectMake(21.0, 312.0, 260.0, 30.0)];
	_volleysLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:25];
	_volleysLabel.textColor = [UIColor whiteColor];
	_volleysLabel.backgroundColor = [UIColor clearColor];
	_volleysLabel.text = [NSString stringWithFormat:@"%@ volley%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.pics]], (_userVO.pics == 1) ? @"" : @"s"];
	[_scrollView addSubview:_volleysLabel];
	
	_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(21.0, 364.0, 260.0, 30.0)];
	_likesLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:25];
	_likesLabel.textColor = [UIColor whiteColor];
	_likesLabel.backgroundColor = [UIColor clearColor];
	_likesLabel.text = [NSString stringWithFormat:@"%@ like%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]], (_userVO.votes == 1) ? @"" : @"s"];
	[_scrollView addSubview:_likesLabel];
	
	if (_userVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) {
		UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		inviteButton.frame = CGRectMake(0.0, 0.0, 92.0, 44.0);
		[inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[inviteButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateHighlighted];
		[inviteButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16.0]];
		[inviteButton setTitle:@"Invite friends" forState:UIControlStateNormal];
		[inviteButton addTarget:self action:@selector(_goInviteFriends) forControlEvents:UIControlEventTouchUpInside];
		
		UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		settingsButton.frame = CGRectMake(0.0, 0.0, 59.0, 44.0);
		[settingsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[settingsButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateHighlighted];
		[settingsButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16.0]];
		[settingsButton setTitle:@"Settings" forState:UIControlStateNormal];
		[settingsButton addTarget:self action:@selector(_goSettings) forControlEvents:UIControlEventTouchUpInside];
		
		[_footerToolbar setItems:[NSArray arrayWithObjects:
								  [[UIBarButtonItem alloc] initWithCustomView:inviteButton],
								  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
								  [[UIBarButtonItem alloc] initWithCustomView:settingsButton], nil]];
	
	} else {
		_subscribeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_subscribeButton.frame = CGRectMake(0.0, 0.0, 95.0, 44.0);
		[_subscribeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[_subscribeButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateHighlighted];
		[_subscribeButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16.0]];
		
		UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
		flagButton.frame = CGRectMake(0.0, 0.0, 31.0, 44.0);
		[flagButton setTitleColor:[UIColor colorWithRed:0.733 green:0.380 blue:0.392 alpha:1.0] forState:UIControlStateNormal];
		[flagButton setTitleColor:[UIColor colorWithRed:0.325 green:0.169 blue:0.174 alpha:1.0] forState:UIControlStateHighlighted];
		[flagButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16.0]];
		[flagButton setTitle:@"Flag" forState:UIControlStateNormal];
		[flagButton addTarget:self action:@selector(_goFlag) forControlEvents:UIControlEventTouchUpInside];
		
		[_footerToolbar setItems:[NSArray arrayWithObjects:
								  [[UIBarButtonItem alloc] initWithCustomView:_subscribeButton],
								  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
								  [[UIBarButtonItem alloc] initWithCustomView:flagButton], nil]];
	}
	
//	_footerToolbar.hidden = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID);
	
	[_subscribeButton setTitle:(isFriend) ? @"Unsubscribe" : @"Subscribe" forState:UIControlStateNormal];
	[_subscribeButton addTarget:self action:(isFriend) ? @selector(_goUnsubscribe) : @selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
	_subscribeButton.frame = CGRectMake(0.0, 0.0, (isFriend) ? 95.0 : 73.0, 44.0);
	
	
	[self _retrieveChallenges];
}

- (void)_makeGrid {
	_gridHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 429.0, 320.0, kSnapMediumDim * (([_challenges count] / 4) + 1))];
	_gridHolderView.backgroundColor = [UIColor clearColor];
	[_scrollView addSubview:_gridHolderView];
	
	_challengeCounter = 0;
	for (HONChallengeVO *vo in _challenges) {
		CGPoint pos = CGPointMake(kSnapMediumDim * (_challengeCounter % 4), kSnapMediumDim * (_challengeCounter / 4));
		
		UIView *imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(pos.x, pos.y, kSnapMediumDim, kSnapMediumDim)];
		[_gridHolderView addSubview:imageHolderView];
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapMediumDim, kSnapMediumDim)];
		imageView.userInteractionEnabled = YES;
		[imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@Small_160x160.jpg", vo.creatorVO.imagePrefix]] placeholderImage:nil];
		[imageHolderView addSubview:imageView];
		
		_challengeCounter++;
	}
}


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


//#pragma mark - RefreshTableHeader Delegates
//- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
//	[self _goRefresh];
//}
//
//- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
//	return (_isRefreshing);
//}
//
//- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
//	return ([NSDate date]);
//}


#pragma mark - SnapPreview Delegates
- (void)snapPreviewViewControllerUpvote:(HONSnapPreviewViewController *)snapPreviewViewController opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	if (snapPreviewViewController != nil) {
		[snapPreviewViewController.view removeFromSuperview];
		snapPreviewViewController = nil;
	}
	
	UIImageView *heartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heartAnimation"]];
	heartImageView.frame = CGRectOffset(heartImageView.frame, 29.0, ([UIScreen mainScreen].bounds.size.height * 0.5) - 18.0);
	[self.view addSubview:heartImageView];
	
	[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		heartImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[heartImageView removeFromSuperview];
	}];
}

- (void)snapPreviewViewControllerFlag:(HONSnapPreviewViewController *)snapPreviewViewController opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	if (snapPreviewViewController != nil) {
		[snapPreviewViewController.view removeFromSuperview];
		snapPreviewViewController = nil;
	}
}

- (void)snapPreviewViewControllerClose:(HONSnapPreviewViewController *)snapPreviewViewController {
	if (snapPreviewViewController != nil) {
		[snapPreviewViewController.view removeFromSuperview];
		snapPreviewViewController = nil;
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Close Subscribe %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1)
			[self _addFriend:_userVO.userID];
		
		[self dismissViewControllerAnimated:YES completion:^(void) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
		}];
		
	} else if (alertView.tag == 1) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Share %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		
		[self dismissViewControllerAnimated:YES completion:^(void) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
			if (buttonIndex == 1) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SEND_TO_INSTAGRAM"
																	object:[NSDictionary dictionaryWithObjectsAndKeys:
																			[HONAppDelegate instagramShareComment], @"caption",
																			[HONImagingDepictor prepImageForSharing:[UIImage imageNamed:@"share_template"]
																										avatarImage:[HONAppDelegate avatarImage]
																										   username:[[HONAppDelegate infoForUser] objectForKey:@"name"]], @"image", nil]];
			}
		}];
		
	} else if (alertView.tag == 2) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Flag %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1) {
			[self _flagUser:_userVO.userID];
		}
		
	} else if (alertView.tag == 3) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Subscribe %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
		if (buttonIndex == 1) {
			[self _addFriend:_userVO.userID];
			[_subscribeButton setTitle:@"Unsubscribe" forState:UIControlStateNormal];
			_subscribeButton.frame = CGRectMake(0.0, 0.0, 95.0, 44.0);
			[_subscribeButton addTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
		}
		
	} else if (alertView.tag == 4) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Unsubscribe %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];
		
		if (buttonIndex == 1) {
			[self _removeFriend:_userVO.userID];
			[_subscribeButton setTitle:@"Subscribe" forState:UIControlStateNormal];
			_subscribeButton.frame = CGRectMake(0.0, 0.0, 73.0, 44.0);
			[_subscribeButton addTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
		}
	
	} else if (alertView.tag == 5) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"User Profile - Find People %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _userVO.userID, _userVO.username], @"opponent", nil]];

		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONPopularViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	}
}


@end
