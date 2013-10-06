//
//  HONChallengeDetailsViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/7/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <Twitter/TWTweetComposeViewController.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONHeaderView.h"
#import "HONChallengeDetailsViewController.h"
#import "HONImagePickerViewController.h"
#import "HONVotersViewController.h"
#import "HONCommentsViewController.h"
#import "HONSnapPreviewViewController.h"
#import "HONRefreshButtonView.h"
#import "HONUserProfileViewController.h"
#import "HONImagingDepictor.h"

@interface HONChallengeDetailsViewController () <HONSnapPreviewViewControllerDelegate, EGORefreshTableHeaderDelegate>
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONSnapPreviewViewController *snapPreviewViewController;
@property (nonatomic, strong) UIView *bgHolderView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *heroImageHolderView;
@property (nonatomic, strong) UIImageView *heroImageView;
@property (nonatomic, strong) UIView *gridHolderView;
@property (nonatomic, strong) UILabel *commentsLabel;
@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, strong) NSTimer *tapTimer;
@property (nonatomic, strong) HONOpponentVO *opponentVO;
@property (nonatomic, strong) HONOpponentVO *heroOpponentVO;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic) BOOL isChallengeCreator;
@property (nonatomic) BOOL isChallengeOpponent;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic) int opponentCounter;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIImageView *blurredImageView;
@end

@implementation HONChallengeDetailsViewController

- (id)initWithChallenge:(HONChallengeVO *)vo withBackground:(UIImageView *)imageView {
	if ((self = [super init])) {
//		NSLog(@"CHALLENGE:[%@]", vo.dictionary);
		_challengeVO = vo;
		_bgImageView = imageView;
		
		self.view.backgroundColor = [UIColor clearColor];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshAllTabs:) name:@"REFRESH_ALL_TABS" object:nil];
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
- (void)_refreshChallenge {
	_isRefreshing = YES;
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
							nil];
	
	NSLog(@"PARAMS:[%@]", params);	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallengeObject);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIChallengeObject parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			_challengeVO = [HONChallengeVO challengeWithDictionary:result];
			[self performSelector:@selector(_makeUI) withObject:nil afterDelay:0.25];
		}
		
		_isRefreshing = NO;
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_scrollView];
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		
		_isRefreshing = NO;
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_scrollView];
		
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

- (void)_flagChallenge {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 11], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			//NSDictionary *flagResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], flagResult);
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_VOTE_TAB" object:nil];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
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


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	[self _makeUI];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[_bgHolderView addSubview:_bgImageView];

	int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"details_total"] intValue];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++total] forKey:@"details_total"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if (total == 0) {
		_tutorialImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
		_tutorialImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"tutorial_details-568h@2x" : @"tutorial_details"];
		_tutorialImageView.userInteractionEnabled = YES;
		_tutorialImageView.alpha = 0.0;
		
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.frame = _tutorialImageView.frame;
		[closeButton addTarget:self action:@selector(_goRemoveTutorial) forControlEvents:UIControlEventTouchDown];
		[_tutorialImageView addSubview:closeButton];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_tutorialImageView];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_tutorialImageView.alpha = 1.0;
		}];
	}
//
//	if (modal_total == 0) {
//		[[[UIAlertView alloc] initWithTitle:@""
//									message:@"Tap and hold any image to view fullscreen!"
//								   delegate:nil
//						  cancelButtonTitle:@"OK"
//						  otherButtonTitles:nil] show];
//	}
}


#pragma mark - UI Presentation
- (void)_reloadHeroImage {
	__weak typeof(self) weakSelf = self;
	
	NSLog(@"RELOADING:[%@]", [NSString stringWithFormat:@"%@_l.jpg", _heroOpponentVO.imagePrefix]);
	
	_heroImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 370.0, 370.0)];
	_heroImageView.alpha = 0.0;
	[_heroImageHolderView addSubview:_heroImageView];
	[_heroImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_l.jpg", _heroOpponentVO.imagePrefix]]
																		cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
									  placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
										  weakSelf.heroImageView.image = image;
										  [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.heroImageView.alpha = 1.0; } completion:nil];
									  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
										  NSLog(@"Error:[%@]", error.description);
									  }];
}

- (void)_makeUI {
	for (UIView *view in self.view.subviews)
		[view removeFromSuperview];
	
	_bgHolderView = [[UIView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:_bgHolderView];
	
	[_bgHolderView addSubview:_bgImageView];
	
	_isChallengeCreator = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _challengeVO.creatorVO.userID);
	_isChallengeOpponent = NO;
	for (HONOpponentVO *vo in _challengeVO.challengers) {
		if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == vo.userID) {
			_isChallengeOpponent = YES;
			break;
		}
	}
	
	int respondedOpponents = 0;
	for (HONOpponentVO *vo in _challengeVO.challengers) {
		if ([vo.imagePrefix length] > 0)
			respondedOpponents++;
	}
	
	_heroOpponentVO = _challengeVO.creatorVO;
	if ([_challengeVO.challengers count] > 0 && ([((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0]).joinedDate timeIntervalSinceNow] > [_heroOpponentVO.joinedDate timeIntervalSinceNow]))
		_heroOpponentVO = (HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0];
	
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height)];
	_scrollView.contentSize = CGSizeMake(320.0, MAX([UIScreen mainScreen].bounds.size.height + 1.0, (![HONAppDelegate isRetina5] * 88.0) + 500.0 + (kSnapMediumDim * (respondedOpponents / 4))));
	//_scrollView.contentInset = UIEdgeInsetsMake(64.0f, 0.0f, -64.0f, 0.0f);
	_scrollView.pagingEnabled = NO;
	_scrollView.delegate = self;
	_scrollView.showsVerticalScrollIndicator = YES;
	_scrollView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_scrollView];
	
	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
	[closeButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[closeButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
	
	_headerView = [[HONHeaderView alloc] initAsModalWithTitle:_challengeVO.subjectName];
	[_headerView addButton:closeButton];
	[self.view addSubview:_headerView];
	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height) withHeaderOffset:NO];
	_refreshTableHeaderView.delegate = self;
	[_scrollView addSubview:_refreshTableHeaderView];
	[_refreshTableHeaderView refreshLastUpdatedDate];
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	lpGestureRecognizer.minimumPressDuration = 0.25;
	[_scrollView addGestureRecognizer:lpGestureRecognizer];
	
	__weak typeof(self) weakSelf = self;
	_heroImageHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 370.0)];
	_heroImageHolderView.clipsToBounds = YES;
	[_scrollView addSubview:_heroImageHolderView];
	
	_heroImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 568.0)];
	_heroImageView.userInteractionEnabled = YES;
	_heroImageView.alpha = 0.0;
	[_heroImageHolderView addSubview:_heroImageView];
	[_heroImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@Large_640x1136.jpg", _heroOpponentVO.imagePrefix]]
																		cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
									  placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
										  weakSelf.heroImageView.image = image;
										  [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) { weakSelf.heroImageView.alpha = 1.0; } completion:nil];
									  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//										  [weakSelf _reloadHeroImage];
									  }];
	
	UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
	leftButton.frame = _heroImageView.frame;
	[leftButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
	//[leftButton addTarget:self action:@selector(_goTapCreator) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:leftButton];
	
	
	_gridHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 370.0, 320.0, kSnapMediumDim)];
	[_scrollView addSubview:_gridHolderView];
	
	BOOL isOpponent = NO;
	_opponentCounter = 0;
	for (HONOpponentVO *opponentVO in _challengeVO.challengers) {
		if ([opponentVO.imagePrefix length] > 0) {
			
			HONOpponentVO *vo = ([opponentVO.imagePrefix isEqualToString:_heroOpponentVO.imagePrefix]) ? _challengeVO.creatorVO : opponentVO;
			isOpponent = (vo.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]);
			
			CGPoint pos = CGPointMake(kSnapMediumDim * (_opponentCounter % 4), kSnapMediumDim * (_opponentCounter / 4));
			UIView *opponentHolderView = [[UIView alloc] initWithFrame:CGRectMake(pos.x, pos.y, kSnapMediumDim, kSnapMediumDim)];
			[_gridHolderView addSubview:opponentHolderView];
			
			UIImageView *opponentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapMediumDim, kSnapMediumDim)];
			opponentImageView.userInteractionEnabled = YES;
			[opponentImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@Small_160x160.jpg", vo.imagePrefix]] placeholderImage:nil];
			[opponentHolderView addSubview:opponentImageView];
			
			UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
			rightButton.frame = opponentImageView.frame;
			[rightButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
			[rightButton addTarget:self action:@selector(_goUserProfile:) forControlEvents:UIControlEventTouchUpInside];
			[rightButton setTag:vo.userID];
			[opponentHolderView addSubview:rightButton];
			
			_opponentCounter++;
		}
	}
	
	_gridHolderView.frame = CGRectMake(0.0, 370.0, 320.0, kSnapMediumDim + (kSnapMediumDim * (respondedOpponents / 4)));
	
	UIView *footerHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 322.0, 320.0, 44.0)];
	[_scrollView addSubview:footerHolderView];
	
//	NSString *opponents = @"";
//	for (HONOpponentVO *vo in _challengeVO.challengers) {
//		opponents = [opponents stringByAppendingFormat:@"%@, ", vo.username];
//	}
	
	
	
//	NSString *emails = @"";
//	for (HONContactUserVO *vo in addresses) {
//		emails = [emails stringByAppendingFormat:@"%@|", vo.email];
//	}
//	
//	NSLog(@"SELECTED CONTACTS:[%@]", [emails substringToIndex:[emails length] - 1]);
	
	
	//NSString *opponents = [NSString stringWithFormat:@"%@%@%@", _challengeVO.creatorVO.username, (isOpponent) ? @", you" : @"", (_opponentCounter > 0) ? [NSString stringWithFormat:@" & %d others", _opponentCounter] : @""];
	
	UILabel *creatorNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(9.0, 0.0, 290.0, 19.0)];
	creatorNameLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:16];
	creatorNameLabel.textColor = [UIColor whiteColor];
	creatorNameLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
	creatorNameLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	creatorNameLabel.backgroundColor = [UIColor clearColor];
	creatorNameLabel.text = [NSString stringWithFormat:@"%@%@%@", _challengeVO.creatorVO.username, (isOpponent) ? @", you" : @"", (_opponentCounter > 0) ? [NSString stringWithFormat:@" & %d other%@…", _opponentCounter, (_opponentCounter != 1) ? @"s" : @""] : @""];//_challengeVO.creatorVO.username;
	[footerHolderView addSubview:creatorNameLabel];
	
	UIButton *creatorButton = [UIButton buttonWithType:UIButtonTypeCustom];
	creatorButton.frame = CGRectMake(9.0, 0.0, 150.0, 44.0);
	[creatorButton setBackgroundImage:[UIImage imageNamed:@"blackOverlay_50"] forState:UIControlStateHighlighted];
	[creatorButton addTarget:self action:@selector(_goHeroProfile) forControlEvents:UIControlEventTouchUpInside];
	[footerHolderView addSubview:creatorButton];
	
	//CGSize size = [creatorNameLabel.text sizeWithFont:creatorNameLabel.font constrainedToSize:CGSizeMake(150.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 17.0, 270.0, 27.0)];
	subjectLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17];
	subjectLabel.textColor = [UIColor whiteColor];
	subjectLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
	subjectLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.text = _challengeVO.subjectName;
	[footerHolderView addSubview:subjectLabel];
	
	UIButton *likesButton = [UIButton buttonWithType:UIButtonTypeCustom];
	likesButton.frame = CGRectMake(280.0, 15.0, 24.0, 24.0);
	[likesButton setBackgroundImage:[UIImage imageNamed:@"likeIcon"] forState:UIControlStateNormal];
	[likesButton setBackgroundImage:[UIImage imageNamed:@"likeIcon"] forState:UIControlStateHighlighted];
	[footerHolderView addSubview:likesButton];
	
	_likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(230.0, 17.0, 40.0, 19.0)];
	_likesLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:16];
	_likesLabel.textColor = [UIColor whiteColor];
	_likesLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
	_likesLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	_likesLabel.backgroundColor = [UIColor clearColor];
	_likesLabel.textAlignment = NSTextAlignmentRight;
	_likesLabel.text = ([self _calcScore] > 99) ? @"99+" : [NSString stringWithFormat:@"%d", [self _calcScore]];
	[footerHolderView addSubview:_likesLabel];
	
//	UIButton *challengersButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	challengersButton.frame = CGRectMake(266.0, 19.0, 24.0, 24.0);
//	[challengersButton setBackgroundImage:[UIImage imageNamed:@"smallPersonIcon"] forState:UIControlStateNormal];
//	[challengersButton setBackgroundImage:[UIImage imageNamed:@"smallPersonIcon"] forState:UIControlStateHighlighted];
//	[footerHolderView addSubview:challengersButton];
//	
//	UILabel *challengersLabel = [[UILabel alloc] initWithFrame:CGRectMake(282.0, 20.0, 40.0, 22.0)];
//	challengersLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:16];
//	challengersLabel.textColor = [UIColor whiteColor];
//	challengersLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.33];
//	challengersLabel.shadowOffset = CGSizeMake(1.0, 1.0);
//	challengersLabel.backgroundColor = [UIColor clearColor];
//	challengersLabel.textAlignment = NSTextAlignmentCenter;
//	challengersLabel.text = (_opponentCounter > 99) ? @"99+" : [NSString stringWithFormat:@"%d", _opponentCounter];
//	[footerHolderView addSubview:challengersLabel];
		
//	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(149.0, 29.0, 160.0, 16.0)];
//	timeLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:14];
//	timeLabel.textColor = [UIColor whiteColor];
//	timeLabel.backgroundColor = [UIColor clearColor];
//	timeLabel.textAlignment = NSTextAlignmentRight;
//	timeLabel.text = (_challengeVO.expireSeconds > 0) ? [HONAppDelegate formattedExpireTime:_challengeVO.expireSeconds] : [HONAppDelegate timeSinceDate:_challengeVO.updatedDate];
//	[footerHolderView addSubview:timeLabel];
	
	
	UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
	joinButton.frame = CGRectMake(6.0, 158.0, 78.0, 78.0);
	[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_nonActive"] forState:UIControlStateNormal];
	[joinButton setBackgroundImage:[UIImage imageNamed:@"joinButton_Active"] forState:UIControlStateHighlighted];
	[joinButton addTarget:self action:@selector(_goJoinChallenge) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:joinButton];
		
//	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 58.0)];
//	[_scrollView addSubview:headerView];
//	
//	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(9.0, 5.0, 170.0, 28.0)];
//	subjectLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:26];
//	subjectLabel.textColor = [UIColor whiteColor];
//	subjectLabel.backgroundColor = [UIColor clearColor];
//	subjectLabel.text = _challengeVO.subjectName;
//	[headerView addSubview:subjectLabel];
	
	UIButton *joinFooterButton = [UIButton buttonWithType:UIButtonTypeCustom];
	joinFooterButton.frame = CGRectMake(0.0, 0.0, 35.0, 44.0);
	[joinFooterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[joinFooterButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateHighlighted];
	[joinFooterButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontMedium] fontWithSize:16.0]];
	[joinFooterButton setTitle:@"Join" forState:UIControlStateNormal];
	[joinFooterButton addTarget:self action:@selector(_goJoinChallenge) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *shareFooterButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareFooterButton.frame = CGRectMake(0.0, 0.0, 80.0, 44.0);
	[shareFooterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[shareFooterButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateHighlighted];
	[shareFooterButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontMedium] fontWithSize:16.0]];
	[shareFooterButton setTitle:@"Share" forState:UIControlStateNormal];
	[shareFooterButton addTarget:self action:@selector(_goShareChallenge) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
	flagButton.frame = CGRectMake(0.0, 0.0, 31.0, 44.0);
	[flagButton setTitleColor:[UIColor colorWithRed:0.808 green:0.420 blue:0.431 alpha:1.0] forState:UIControlStateNormal];
	[flagButton setTitleColor:[UIColor colorWithRed:0.325 green:0.169 blue:0.174 alpha:1.0] forState:UIControlStateHighlighted];
	[flagButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16.0]];
	[flagButton setTitle:@"Flag" forState:UIControlStateNormal];
	[flagButton addTarget:self action:@selector(_goFlagChallenge) forControlEvents:UIControlEventTouchUpInside];
	
	UIToolbar *footerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 44.0, 320.0, 44.0)];
	[footerToolbar setBarStyle:UIBarStyleBlackTranslucent];
	[footerToolbar setItems:[NSArray arrayWithObjects:
							 [[UIBarButtonItem alloc] initWithCustomView:joinFooterButton],
							 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
							 [[UIBarButtonItem alloc] initWithCustomView:shareFooterButton],
							 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
							 [[UIBarButtonItem alloc] initWithCustomView:flagButton],
							 nil]];
	[self.view addSubview:footerToolbar];
}

- (int)_calcScore {
	int score = _challengeVO.creatorVO.score;
	for (HONOpponentVO *vo in _challengeVO.challengers)
		score += vo.score;
	
	return (score);
}


#pragma mark - Navigation
-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint touchPoint = [lpGestureRecognizer locationInView:_scrollView];
//		NSLog(@"TOUCH PT:[%@] <%@>", NSStringFromCGPoint(touchPoint), NSStringFromCGRect(_gridHolderView.frame));
		
		_opponentVO = nil;
		if (CGRectContainsPoint(_heroImageHolderView.frame, touchPoint))
			_opponentVO = _heroOpponentVO;
		
		if (CGRectContainsPoint(_gridHolderView.frame, touchPoint)) {
			int col = touchPoint.x / kSnapMediumDim;
			int row = (touchPoint.y - _gridHolderView.frame.origin.y) / kSnapMediumDim;
			int index = (row * 4) + col;
			
			if (index < _opponentCounter) {
				if ([((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:index]).imagePrefix isEqualToString:_heroOpponentVO.imagePrefix])
					_opponentVO = _challengeVO.creatorVO;
				
				else
					_opponentVO = (HONOpponentVO *)[_challengeVO.challengers objectAtIndex:index];
			}
		}
		
		if (_opponentVO != nil) {
			[[Mixpanel sharedInstance] track:@"Timeline Details - Show Photo Detail"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
											  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
											  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent",
											  nil]];
			
			_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initWithOpponent:_opponentVO forChallenge:_challengeVO asRoot:YES];
			_snapPreviewViewController.delegate = self;
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
		}
		
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
		[[Mixpanel sharedInstance] track:@"Timeline Details - Hide Photo Detail"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
										  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent",
										  nil]];
		
		[_snapPreviewViewController showControls];
	}
}

- (void)_goRefresh {
	_isRefreshing = YES;
	[self _refreshChallenge];
}

- (void)_goClose {
	[[Mixpanel sharedInstance] track:@"Timeline Details - Close"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	[self dismissViewControllerAnimated:YES completion:^(void) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
	}];

}

- (void)_goScore {
	[[Mixpanel sharedInstance] track:@"Timeline Details - Show Voters"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	[self.navigationController pushViewController:[[HONVotersViewController alloc] initWithChallenge:_challengeVO] animated:YES];
}

- (void)_goComments {
	[[Mixpanel sharedInstance] track:@"Timeline Details - Comments"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	[self.navigationController pushViewController:[[HONCommentsViewController alloc] initWithChallenge:_challengeVO] animated:YES];
}


- (void)_goHeroProfile {
	[[Mixpanel sharedInstance] track:@"Timeline Details - Hero Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _heroOpponentVO.userID, _heroOpponentVO.username], @"opponent", nil]];
	
	_blurredImageView = [[UIImageView alloc] initWithImage:[HONImagingDepictor createBlurredScreenShot]];
	_blurredImageView.alpha = 0.0;
	[self.view addSubview:_blurredImageView];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blurredImageView.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
	
	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithBackground:_blurredImageView];
	userPofileViewController.userID = _challengeVO.creatorVO.userID;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goUserProfile:(id)sender {
	UIButton *button = (UIButton *)sender;
	
	[[Mixpanel sharedInstance] track:@"Timeline Details - User Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", button.tag, @""], @"opponent", nil]];
	
	_blurredImageView = [[UIImageView alloc] initWithImage:[HONImagingDepictor createBlurredScreenShot]];
	_blurredImageView.alpha = 0.0;
	[self.view addSubview:_blurredImageView];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blurredImageView.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
	
	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithBackground:_blurredImageView];
	userPofileViewController.userID = button.tag;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
	
	
}

- (void)_goJoinChallenge {
	[[Mixpanel sharedInstance] track:@"Timeline Details - Join Challenge"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithJoinChallenge:_challengeVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goShareChallenge {
	[[Mixpanel sharedInstance] track:@"Timeline Details - Share Challenge"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Twitter", @"Instagram", nil];
	[actionSheet setTag:1];
	[actionSheet showInView:self.view];
}

- (void)_goFlagChallenge {
	[[Mixpanel sharedInstance] track:@"Timeline Details - Flag Challenge"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Abusive content", nil];
	[actionSheet setTag:0];
	[actionSheet showInView:self.view];
}

- (void)_goRemoveTutorial {
	[UIView animateWithDuration:0.25 animations:^(void) {
		if (_tutorialImageView != nil) {
			_tutorialImageView.alpha = 0.0;
		}
	} completion:^(BOOL finished) {
		if (_tutorialImageView != nil) {
			[_tutorialImageView removeFromSuperview];
			_tutorialImageView = nil;
		}
	}];
}



#pragma mark - Notifications
- (void)_refreshAllTabs:(NSNotification *)notification {
	[self _refreshChallenge];
}


#pragma mark - SnapPreview Delegates
- (void)snapPreviewViewControllerClose:(HONSnapPreviewViewController *)snapPreviewViewController {
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
}

- (void)snapPreviewViewControllerUpvote:(HONSnapPreviewViewController *)snapPreviewViewController opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_opponentVO = opponentVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline Details - Upvote"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
	
	
	if (_opponentVO.userID == _challengeVO.creatorVO.userID)
		_challengeVO.creatorVO.score++;
	
	else
		((HONOpponentVO *)[_challengeVO.challengers lastObject]).score++;
	
	
	if ([HONAppDelegate hasVoted:_challengeVO.challengeID] == 0)
		[HONAppDelegate setVote:_challengeVO.challengeID forCreator:(_opponentVO.userID == _challengeVO.creatorVO.userID)];
	
	
	UIImageView *heartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heartAnimation"]];
	heartImageView.frame = CGRectOffset(heartImageView.frame, 28.0, ([UIScreen mainScreen].bounds.size.height * 0.5) - 18.0);
	[self.view addSubview:heartImageView];
	
	[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		heartImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[heartImageView removeFromSuperview];
	}];
	
	_likesLabel.text = (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score > 99) ? @"99+" : [NSString stringWithFormat:@"%d", (_challengeVO.creatorVO.score + ((HONOpponentVO *)[_challengeVO.challengers lastObject]).score)];
}

- (void)snapPreviewViewControllerFlag:(HONSnapPreviewViewController *)snapPreviewViewController opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_opponentVO = opponentVO;
	
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
}


#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self _goRefresh];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
	return (_isRefreshing);
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
	return ([NSDate date]);
}


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline Details - Flag %@", (buttonIndex == 0) ? @"Abusive" : @"Cancel"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
		
		if (buttonIndex == 0) {
//			[self _flagChallenge];
		}
	
	} else if (actionSheet.tag == 1) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline Details - Share %@", (buttonIndex == 0) ? @"Twitter" : (buttonIndex == 1) ? @"Instagram" : @"Cancel"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
		
		if (buttonIndex == 0) {
			if ([TWTweetComposeViewController canSendTweet]) {
				TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
				
				[tweetViewController setInitialText:_challengeVO.subjectName];
				[tweetViewController addImage:_heroImageView.image];
//				[tweetViewController addURL:[NSURL URLWithString:@"http://bit.ly/mywdays"]];
				[self presentViewController:tweetViewController animated:YES completion:nil];
				
				// check on this part using blocks. no more delegates? :)
				tweetViewController.completionHandler = ^(TWTweetComposeViewControllerResult res) {
					if (res == TWTweetComposeViewControllerResultDone) {
					} else if (res == TWTweetComposeViewControllerResultCancelled) {
					}
					
					[tweetViewController dismissViewControllerAnimated:YES completion:nil];
				};
			
			} else {
				[[[UIAlertView alloc] initWithTitle:@""
											message:@"Cannot use Twitter from this device!"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
		
		} else if (buttonIndex == 1) {
			NSString *instaURL = @"instagram://app";
			NSString *instaFormat = @"com.instagram.exclusivegram";
			NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/volley_instagram.igo"];
			UIImage *shareImage = [HONImagingDepictor prepImageForSharing:[UIImage imageNamed:@"share_template"]
															  avatarImage:[HONImagingDepictor cropImage:_heroImageView.image toRect:CGRectMake(0.0, 141.0, 640.0, 853.0)]
																 username:[[HONAppDelegate infoForUser] objectForKey:@"name"]];
			[UIImageJPEGRepresentation(shareImage, 1.0f) writeToFile:savePath atomically:YES];
			
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:instaURL]]) {
				_documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
				_documentInteractionController.UTI = instaFormat;
				_documentInteractionController.delegate = self;
				//_documentInteractionController.annotation = [NSDictionary dictionaryWithObject:[dict objectForKey:@"caption"] forKey:@"InstagramCaption"];
				[_documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"Not Available"
											message:@"This device isn't allowed or doesn't recognize instagram"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
		}
	}
}


#pragma mark - DocumentInteraction Delegates
- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller {
	[[Mixpanel sharedInstance] track:@"Presenting DocInteraction Shelf"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [controller name], @"controller", nil]];
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
	[[Mixpanel sharedInstance] track:@"Dismissing DocInteraction Shelf"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [controller name], @"controller", nil]];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
	[[Mixpanel sharedInstance] track:@"Launching DocInteraction App"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [controller name], @"controller", nil]];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
	[[Mixpanel sharedInstance] track:@"Entering DocInteraction App Foreground"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [controller name], @"controller", nil]];
}


@end
