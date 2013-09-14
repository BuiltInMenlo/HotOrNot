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
#import "HONOpponentVO.h"
#import "HONSnapPreviewViewController.h"


@interface HONUserProfileViewController () <HONSnapPreviewViewControllerDelegate>
@property (nonatomic, strong) UIView *bgHolderView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) HONSnapPreviewViewController *snapPreviewViewController;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameAgeLabel;
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
@synthesize userVO = _userVO;

- (id)initWithBackground:(UIImageView *)imageView {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor clearColor];
		_bgImageView = imageView;
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
- (void)_retrieveUser {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 5], @"action",
							[NSString stringWithFormat:@"%d", _userVO.userID], @"userID",
							nil];
	
	//NSLog(@"USER BY ID PARAMS:[%@]", params);
	
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
			[_avatarImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
			_nameAgeLabel.text = [NSString stringWithFormat:@"@%@, %d", _userVO.username, [HONAppDelegate ageForDate:_userVO.birthday]];
			_subscribersLabel.text = [NSString stringWithFormat:@"%@ subscriber%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[_userVO.friends count]]], ([_userVO.friends count] == 1) ? @"" : @"s"];
			_volleysLabel.text = [NSString stringWithFormat:@"%@ volley%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.pics]], (_userVO.pics == 1) ? @"" : @"s"];
			_likesLabel.text = [NSString stringWithFormat:@"%@ like%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]], (_userVO.votes == 1) ? @"" : @"s"];
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
			
			_scrollView.contentSize = CGSizeMake(320.0, MAX([UIScreen mainScreen].bounds.size.height + 1.0, 535.0 + (kSnapMediumDim * ([_challenges count] / 5))));
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
	doneButton.frame = CGRectMake(252.0, 20.0, 64.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:doneButton];
	
	_subscribeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_subscribeButton.frame = CGRectMake(0.0, 0.0, 95.0, 44.0);
	[_subscribeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_subscribeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
	[_subscribeButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16.0]];
	
	_flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_flagButton.frame = CGRectMake(0.0, 0.0, 31.0, 44.0);
	[_flagButton setTitleColor:[UIColor colorWithRed:0.733 green:0.380 blue:0.392 alpha:1.0] forState:UIControlStateNormal];
	[_flagButton setTitleColor:[UIColor colorWithRed:0.560 green:0.291 blue:0.299 alpha:1.0] forState:UIControlStateHighlighted];
	[_flagButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16.0]];
	[_flagButton setTitle:@"Flag" forState:UIControlStateNormal];
	[_flagButton addTarget:self action:@selector(_goFlag) forControlEvents:UIControlEventTouchUpInside];
	
	_footerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 44.0, 320.0, 44.0)];
	[_footerToolbar setBarStyle:UIBarStyleBlackTranslucent];
	[_footerToolbar setItems:[NSArray arrayWithObjects:
							 [[UIBarButtonItem alloc] initWithCustomView:_subscribeButton],
							 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
							 [[UIBarButtonItem alloc] initWithCustomView:_flagButton], nil]];
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
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Public APIs
- (void)setUserVO:(HONUserVO *)userVO {
	_userVO = userVO;
	
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
	
	CALayer *maskLayer = [CALayer layer];
	UIImage *mask = [UIImage imageNamed:@"profileImageMask.png"];
	maskLayer.contents = (id)mask.CGImage;
	maskLayer.frame = (CGRect){CGPointZero, mask.size};
	
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(83.0, 58.0, 153.0, 153.0)];
	_avatarImageView.layer.mask = maskLayer;
	[_avatarImageView setImageWithURL:[NSURL URLWithString:_userVO.imageURL] placeholderImage:nil];
	[_scrollView addSubview:_avatarImageView];
	
	UIImageView *avatarCoverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profileAvatarBackground"]];
	avatarCoverImageView.frame = _avatarImageView.frame;
	[_scrollView addSubview:avatarCoverImageView];
	
	UIImageView *verifiedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verifiedUser"]];
	verifiedImageView.frame = CGRectOffset(verifiedImageView.frame, 197.0, 106.0);
	verifiedImageView.hidden = ([HONAppDelegate ageForDate:_userVO.birthday] > 19);
	[_scrollView addSubview:verifiedImageView];
	
	_nameAgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 227.0, 290.0, 28.0)];
	_nameAgeLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:24];
	_nameAgeLabel.textColor = [UIColor whiteColor];
	_nameAgeLabel.textAlignment = NSTextAlignmentCenter;
	_nameAgeLabel.backgroundColor = [UIColor clearColor];
	_nameAgeLabel.text = [NSString stringWithFormat:@"@%@, %d", _userVO.username, [HONAppDelegate ageForDate:_userVO.birthday]];
	[_scrollView addSubview:_nameAgeLabel];
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	_subscribersLabel = [[UILabel alloc] initWithFrame:CGRectMake(21.0, 275.0, 260.0, 28.0)];
	_subscribersLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:24];
	_subscribersLabel.textColor = [UIColor whiteColor];
	_subscribersLabel.backgroundColor = [UIColor clearColor];
	_subscribersLabel.text = [NSString stringWithFormat:@"%@ subscriber%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:[_userVO.friends count]]], ([_userVO.friends count] == 1) ? @"" : @"s"];
	[_scrollView addSubview:_subscribersLabel];
	
	_volleysLabel = [[UILabel alloc] initWithFrame:CGRectMake(21.0, 325.0, 260.0, 28.0)];
	_volleysLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:24];
	_volleysLabel.textColor = [UIColor whiteColor];
	_volleysLabel.backgroundColor = [UIColor clearColor];
	_volleysLabel.text = [NSString stringWithFormat:@"%@ volley%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.pics]], (_userVO.pics == 1) ? @"" : @"s"];
	[_scrollView addSubview:_volleysLabel];
	
	_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(21.0, 373.0, 260.0, 28.0)];
	_likesLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:24];
	_likesLabel.textColor = [UIColor whiteColor];
	_likesLabel.backgroundColor = [UIColor clearColor];
	_likesLabel.text = [NSString stringWithFormat:@"%@ like%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:_userVO.votes]], (_userVO.votes == 1) ? @"" : @"s"];
	[_scrollView addSubview:_likesLabel];
	
	_footerToolbar.hidden = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _userVO.userID);
	
	[_subscribeButton setTitle:(isFriend) ? @"Unsubscribe" : @"Subscribe" forState:UIControlStateNormal];
	[_subscribeButton addTarget:self action:(isFriend) ? @selector(_goUnsubscribe) : @selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
	_subscribeButton.frame = CGRectMake(0.0, 0.0, (isFriend) ? 95.0 : 73.0, 44.0);

	
	[self _retrieveChallenges];
}


#pragma mark - Navigation
- (void)_goDone {
	[self dismissViewControllerAnimated:YES completion:^(void) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
	}];
}

- (void)_goRefresh {
	[self _retrieveUser];
	
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

#pragma mark - UI Presentation
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

- (void)_makeGrid {
	_gridHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 429.0, 320.0, (kSnapMediumDim) * (([_challenges count] / 4) + 1))];
	_gridHolderView.backgroundColor = [UIColor clearColor];
	[_scrollView addSubview:_gridHolderView];
	
	_challengeCounter = 0;
	for (HONChallengeVO *vo in _challenges) {
		CGPoint pos = CGPointMake((kSnapMediumDim) * (_challengeCounter % 4), (kSnapMediumDim) * (_challengeCounter / 4));
		
		UIView *imageHolderView = [[UIView alloc] initWithFrame:CGRectMake(pos.x, pos.y, kSnapMediumDim, kSnapMediumDim)];
		[_gridHolderView addSubview:imageHolderView];
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapMediumDim, kSnapMediumDim)];
		imageView.userInteractionEnabled = YES;
		[imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_m.jpg", vo.creatorVO.imagePrefix]] placeholderImage:nil];
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
	heartImageView.frame = CGRectOffset(heartImageView.frame, 29.0, ([UIScreen mainScreen].bounds.size.height * 0.5) + 77.0);
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
	if (alertView.tag == 1) {
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
			[_subscribeButton addTarget:self action:@selector(_goSubscribe) forControlEvents:UIControlEventTouchUpInside];
		}
	}
}


@end
