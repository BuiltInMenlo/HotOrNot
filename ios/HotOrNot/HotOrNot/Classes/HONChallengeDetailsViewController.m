//
//  HONChallengeDetailsViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/7/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

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
#import "HONTimelineCreatorHeaderView.h"
#import "HONTimelineItemFooterView.h"
#import "HONChallengeDetailsGridView.h"
#import "HONUserProfileViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONImagingDepictor.h"
#import "HONImageLoadingView.h"
#import "HONEmotionVO.h"


@interface HONChallengeDetailsViewController () <HONTimelineHeaderCreatorViewDelegate, HONTimelineItemFooterViewDelegate, HONSnapPreviewViewControllerDelegate, EGORefreshTableHeaderDelegate, HONParticipantGridViewDelegate>
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONSnapPreviewViewController *snapPreviewViewController;
@property (nonatomic, strong) HONTimelineItemFooterView *timelineItemFooterView;
@property (nonatomic, strong) HONChallengeDetailsGridView *participantsGridView;
@property (nonatomic, strong) UIView *bgHolderView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentHolderView;
@property (nonatomic, strong) UIView *heroHolderView;
@property (nonatomic, strong) UIImageView *heroImageView;
@property (nonatomic, strong) UIView *gridHolderView;
@property (nonatomic, strong) UILabel *commentsLabel;
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
		
		_challengeVO = vo;
		_bgImageView = imageView;
		
		self.view.backgroundColor = [UIColor whiteColor];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshAllTabs:) name:@"REFRESH_ALL_TABS" object:nil];
		
//		NSMutableArray *mChallenge = [vo.challengers mutableCopy];
//		int min = ([vo.challengers count] < 5) ? 0 : 5;
//		int diff = ([vo.challengers count]) - min;
//		int len = (diff == min) ? 0 : diff;
//		[mChallenge removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(min, len)]];		
//		NSLog(@"CHALLENGE:[%@]", vo.dictionary);
//		NSLog(@"CREATOR[%@] -- CHALLENGERS:[%d]", vo.creatorVO.subjectName, [vo.challengers count]);
//		int cnt = 0;
//		for (HONOpponentVO *vo in _challengeVO.challengers) {
//			NSLog(@"\tCHALLENGER:[%@]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n\n", vo.subjectName);
//
//			if (++cnt == 5)
//				break;
//		}
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
- (void)_retrieveChallenge {
	_isRefreshing = YES;
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", _challengeVO.challengeID], @"challengeID",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallengeObject, params);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIChallengeObject parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			_challengeVO = [HONChallengeVO challengeWithDictionary:result];
			
			[self _participantCheck];
			[self _remakeUI];
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
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			//NSDictionary *flagResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], flagResult);
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:nil];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		
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
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
//			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
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
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			if (result != nil)
				[HONAppDelegate writeSubscribeeList:result];
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


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	_bgHolderView = [[UIView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:_bgHolderView];
	
	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
	[closeButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[closeButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
	
	_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height)];
	_scrollView.contentSize = CGSizeMake(320.0, MAX([UIScreen mainScreen].bounds.size.height + 1.0, (((int)![HONAppDelegate isRetina4Inch]) * -80.0) + 108.0 + ((kHeroVolleyHeroHeight + 84.0) + (kSnapThumbSize.height * (([_challengeVO.challengers count] / 4) + 1)))));
	_scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
	_scrollView.pagingEnabled = NO;
	_scrollView.delegate = self;
	_scrollView.showsVerticalScrollIndicator = YES;
	_scrollView.showsHorizontalScrollIndicator = NO;
	[self.view addSubview:_scrollView];
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timelineBackground"]];
	bgImageView.frame = CGRectOffset(bgImageView.frame, 0.0, 64.0);
	[_scrollView addSubview:bgImageView];
	
	//NSLog(@"_scrollView.contentSize:[%@] ROWS:[%d/%d] (%d)", NSStringFromCGSize(_scrollView.contentSize), ([_challengeVO.challengers count] / 4) + 1, [_challengeVO.challengers count], (int)(kSnapThumbSize.height * (([_challengeVO.challengers count] / 4) + 1)));
	
	_contentHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 64.0, 320.0, _scrollView.contentSize.height)];
	_contentHolderView.frame = CGRectOffset(_contentHolderView.frame, 0.0, _scrollView.contentInset.top);
	[_scrollView addSubview:_contentHolderView];
	
	_refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -self.view.frame.size.height + 64.0, self.view.frame.size.width, self.view.frame.size.height) withHeaderOffset:NO];
	_refreshTableHeaderView.delegate = self;
	[_scrollView addSubview:_refreshTableHeaderView];
	
	_headerView = [[HONHeaderView alloc] initAsModalWithTitle:_challengeVO.subjectName];
	[_headerView addButton:closeButton];
	[self.view addSubview:_headerView];
	
	[self _participantCheck];
	[self _remakeUI];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[_bgHolderView addSubview:_bgImageView];
	
//	if ([HONAppDelegate incTotalForCounter:@"details"] == 0) {
//		_tutorialImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
//		_tutorialImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina4Inch]) ? @"tutorial_details-568h@2x" : @"tutorial_details"];
//		_tutorialImageView.userInteractionEnabled = YES;
//		_tutorialImageView.alpha = 0.0;
//		
//		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		closeButton.frame = _tutorialImageView.frame;
//		[closeButton addTarget:self action:@selector(_goRemoveTutorial) forControlEvents:UIControlEventTouchDown];
//		[_tutorialImageView addSubview:closeButton];
//		
//		[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_tutorialImageView];
//		[UIView animateWithDuration:0.25 animations:^(void) {
//			_tutorialImageView.alpha = 1.0;
//		}];
//	}
}


#pragma mark - UI Presentation
- (void)_remakeUI {
	for (UIView *view in _contentHolderView.subviews)
		[view removeFromSuperview];
	
	[self _makeHero];
	[self _makeParticipantGrid];
	[self _makeFooterTabBar];
}

- (void)_makeHero {
	_heroHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kHeroVolleyHeroHeight)];
	_heroHolderView.clipsToBounds = YES;
	[_contentHolderView addSubview:_heroHolderView];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:_heroHolderView asLargeLoader:NO];
	[_heroHolderView addSubview:imageLoadingView];
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_heroImageView.image = image;
		
		UIImageView *gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"homeFade"]];
		gradientImageView.alpha = 0.0;
		[_heroHolderView addSubview:gradientImageView];
		
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_heroImageView.alpha = 1.0;
			gradientImageView.alpha = 1.0;
		} completion:^(BOOL finished) {
		}];
	};
	
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RECREATE_IMAGE_SIZES" object:[NSString stringWithFormat:@"%@%@", _heroOpponentVO.imagePrefix, kSnapLargeSuffix]];
	};
	
	_heroImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapLargeSize.width, kSnapLargeSize.height)];
	_heroImageView.userInteractionEnabled = YES;
	_heroImageView.alpha = 0.0;
	[_heroHolderView addSubview:_heroImageView];
	[_heroImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _heroOpponentVO.imagePrefix, kSnapLargeSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
						  placeholderImage:nil
								   success:successBlock
								   failure:failureBlock];
	
	
	
	UIButton *heroPreviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
	heroPreviewButton.frame = CGRectMake(0.0, 0.0, _heroHolderView.frame.size.width, _heroHolderView.frame.size.height);
	[heroPreviewButton addTarget:self action:@selector(_goHeroPreview) forControlEvents:UIControlEventTouchUpInside];
	[_heroHolderView addSubview:heroPreviewButton];
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	lpGestureRecognizer.minimumPressDuration = 0.25;
	[_scrollView addGestureRecognizer:lpGestureRecognizer];
	
	HONTimelineCreatorHeaderView *creatorHeaderView = [[HONTimelineCreatorHeaderView alloc] initWithChallenge:_challengeVO];
	creatorHeaderView.delegate = self;
	[_contentHolderView addSubview:creatorHeaderView];
	
	_timelineItemFooterView = [[HONTimelineItemFooterView alloc] initAtPosY:kHeroVolleyHeroHeight withChallenge:_challengeVO];
	_timelineItemFooterView.delegate = self;
	[_contentHolderView addSubview:_timelineItemFooterView];
}

- (void)_makeParticipantGrid {
	_participantsGridView = [[HONChallengeDetailsGridView alloc] initAtPos:kHeroVolleyHeroHeight + _timelineItemFooterView.frame.size.height forChallenge:_challengeVO asPrimaryOpponent:_heroOpponentVO];
	_participantsGridView.delegate = self;
	[_contentHolderView addSubview:_participantsGridView];
}

- (void)_makeFooterTabBar {
	CGSize size;
	
	UIButton *joinFooterButton = [UIButton buttonWithType:UIButtonTypeCustom];
	joinFooterButton.frame = CGRectMake(0.0, 0.0, 43.0, 44.0);
	[joinFooterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[joinFooterButton setTitleColor:[HONAppDelegate honGreyTextColor] forState:UIControlStateHighlighted];
	[joinFooterButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16.0]];
	[joinFooterButton setTitle:@"Reply" forState:UIControlStateNormal];
	[joinFooterButton addTarget:self action:@selector(_goJoinChallenge) forControlEvents:UIControlEventTouchUpInside];
	
	if ([HONAppDelegate isIOS7]) {
		size = [joinFooterButton.titleLabel.text boundingRectWithSize:CGSizeMake(150.0, 22.0)
															  options:NSStringDrawingTruncatesLastVisibleLine
														   attributes:@{NSFontAttributeName:joinFooterButton.titleLabel.font}
															  context:nil].size;
		
	} else
		size = [joinFooterButton.titleLabel.text sizeWithFont:joinFooterButton.titleLabel.font constrainedToSize:CGSizeMake(150.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
	
	joinFooterButton.frame = CGRectMake(joinFooterButton.frame.origin.x, joinFooterButton.frame.origin.y, size.width, size.height);
	
	UIButton *shareFooterButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareFooterButton.frame = CGRectMake(0.0, 0.0, 80.0, 44.0);
	[shareFooterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[shareFooterButton setTitleColor:[HONAppDelegate honGreyTextColor] forState:UIControlStateHighlighted];
	[shareFooterButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16.0]];
	[shareFooterButton setTitle:@"Share" forState:UIControlStateNormal];
	[shareFooterButton addTarget:self action:@selector(_goShareChallenge) forControlEvents:UIControlEventTouchUpInside];
	
	if ([HONAppDelegate isIOS7]) {
		size = [shareFooterButton.titleLabel.text boundingRectWithSize:CGSizeMake(150.0, 22.0)
															   options:NSStringDrawingTruncatesLastVisibleLine
															attributes:@{NSFontAttributeName:shareFooterButton.titleLabel.font}
															   context:nil].size;
		
	} else
		size = [shareFooterButton.titleLabel.text sizeWithFont:shareFooterButton.titleLabel.font constrainedToSize:CGSizeMake(150.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
	
	shareFooterButton.frame = CGRectMake(shareFooterButton.frame.origin.x, shareFooterButton.frame.origin.y, size.width, size.height);
	
	UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
	flagButton.frame = CGRectMake(0.0, 0.0, 31.0, 44.0);
	[flagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[flagButton setTitleColor:[HONAppDelegate honGreyTextColor] forState:UIControlStateHighlighted];
	[flagButton.titleLabel setFont:[[HONAppDelegate helveticaNeueFontRegular] fontWithSize:16.0]];
	[flagButton setTitle:@"Flag" forState:UIControlStateNormal];
	[flagButton addTarget:self action:@selector(_goFlagChallenge) forControlEvents:UIControlEventTouchUpInside];
	
	if ([HONAppDelegate isIOS7]) {
		size = [flagButton.titleLabel.text boundingRectWithSize:CGSizeMake(150.0, 22.0)
														options:NSStringDrawingTruncatesLastVisibleLine
													 attributes:@{NSFontAttributeName:flagButton.titleLabel.font}
														context:nil].size;
		
	} else
		size = [flagButton.titleLabel.text sizeWithFont:flagButton.titleLabel.font constrainedToSize:CGSizeMake(150.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
	
	flagButton.frame = CGRectMake(flagButton.frame.origin.x, flagButton.frame.origin.y, size.width, size.height);
	
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


#pragma mark - Navigation
-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint touchPoint = [lpGestureRecognizer locationInView:_scrollView];
		
		_opponentVO = (CGRectContainsPoint(_heroHolderView.frame, touchPoint)) ? _heroOpponentVO : nil;
		[[Mixpanel sharedInstance] track:@"Timeline Details - Show Photo Detail"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
										  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
		
		if (_opponentVO != nil) {
			UIView *tagView = [[UIView alloc] initWithFrame:CGRectZero];
			[tagView setTag:_opponentVO.userID];
			
			[self _goUserProfile:_opponentVO.userID];
		}
		
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
	}
}

- (void)_goRefresh {
	_isRefreshing = YES;
	[self _retrieveChallenge];
}

- (void)_goClose {
	[[Mixpanel sharedInstance] track:@"Timeline Details - Close"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:nil];
	[self dismissViewControllerAnimated:YES completion:^(void) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
	}];

}

- (void)_goScore {
	[[Mixpanel sharedInstance] track:@"Timeline Details - Show Voters"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	[self.navigationController pushViewController:[[HONVotersViewController alloc] initWithChallenge:_challengeVO] animated:YES];
}

- (void)_goComments {
	[[Mixpanel sharedInstance] track:@"Timeline Details - Comments"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	[self.navigationController pushViewController:[[HONCommentsViewController alloc] initWithChallenge:_challengeVO] animated:YES];
}


- (void)_goHeroPreview {
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
	
	_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initWithOpponent:_heroOpponentVO forChallenge:_challengeVO];
	_snapPreviewViewController.delegate = self;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
}

- (void)_goUserProfile:(int)userID {
	[[Mixpanel sharedInstance] track:@"Timeline Details - User Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", userID, @""], @"opponent", nil]];
	
	[self _addBlur];
	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithBackground:_blurredImageView];
	userPofileViewController.userID = userID;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goJoinChallenge {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline Details - Join Challenge%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithJoinChallenge:_challengeVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goShareChallenge {
	[[Mixpanel sharedInstance] track:@"Timeline Details - Share Challenge"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[[NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:0], _heroOpponentVO.subjectName, _heroOpponentVO.username], [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:0], _heroOpponentVO.subjectName, _heroOpponentVO.username, [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@?mt=8&uo=4", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]]],
																							@"image"			: _heroImageView.image,
																							@"url"				: @"",
																							@"mp_event"			: @"Timeline Details",
																							@"view_controller"	: self}];
}

- (void)_goFlagChallenge {
	[[Mixpanel sharedInstance] track:@"Timeline Details - Flag Challenge"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
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
	[self _retrieveChallenge];
}


#pragma mark - UI Presentation
- (void)_addBlur {
//	_blurredImageView = [[UIImageView alloc] initWithImage:[HONImagingDepictor createBlurredScreenShot]];
//	_blurredImageView.alpha = 0.0;
//	[self.view addSubview:_blurredImageView];
//
//	[UIView animateWithDuration:0.25 animations:^(void) {
//		_blurredImageView.alpha = 1.0;
//	} completion:^(BOOL finished) {
//	}];
}


#pragma mark - Data Housekeeping
- (void)_participantCheck {
	_isChallengeCreator = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _challengeVO.creatorVO.userID);
	_isChallengeOpponent = NO;
	_opponentCounter = 0;
	
	for (HONOpponentVO *vo in _challengeVO.challengers) {
		_opponentCounter++;
		
		if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == vo.userID) {
			_isChallengeOpponent = YES;
			break;
		}
	}
	
	_heroOpponentVO = _challengeVO.creatorVO;
//	if ([_challengeVO.challengers count] > 0 && ([((HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0]).joinedDate timeIntervalSinceNow] > [_heroOpponentVO.joinedDate timeIntervalSinceNow]) && !_challengeVO.isCelebCreated && !_challengeVO.isExploreChallenge)
//		_heroOpponentVO = (HONOpponentVO *)[_challengeVO.challengers objectAtIndex:0];
}


#pragma mark - TimelineHeaderCreator Delegates
- (void)timelineHeaderView:(HONTimelineCreatorHeaderView *)cell showProfile:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Timeline Details - Header Show Profile%@", ([HONAppDelegate hasTakenSelfie]) ? @"" : @" Blocked"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", opponentVO.userID, opponentVO.username], @"participant", nil]];
	
	[self _goUserProfile:opponentVO.userID];
}


#pragma mark - HeroFooterView Delegates
- (void)footerView:(HONTimelineItemFooterView *)cell showProfileForParticipant:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Timeline Details - User Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", opponentVO.userID, opponentVO.username], @"opponent", nil]];
	
	
	[self _addBlur];
	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithBackground:_blurredImageView];
	userPofileViewController.userID = opponentVO.userID;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)footerView:(HONTimelineItemFooterView *)cell joinChallenge:(HONChallengeVO *)challengeVO {
	[self _goJoinChallenge];
}

- (void)footerView:(HONTimelineItemFooterView *)cell showDetailsForChallenge:(HONChallengeVO *)challengeVO {
}


#pragma mark - GridView Delegates
- (void)participantGridView:(HONBasicParticipantGridView *)participantGridView showPreview:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
	
	_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initWithOpponent:opponentVO forChallenge:_challengeVO];
	_snapPreviewViewController.delegate = self;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
}

- (void)participantGridView:(HONBasicParticipantGridView *)participantGridView showProfile:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	[[Mixpanel sharedInstance] track:@"Timeline Details - User Profile"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", challengeVO.challengeID, challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", opponentVO.userID, opponentVO.username], @"opponent", nil]];
	
	[self _addBlur];
	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithBackground:_blurredImageView];
	userPofileViewController.userID = opponentVO.userID;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - SnapPreview Delegates
- (void)snapPreviewViewControllerClose:(HONSnapPreviewViewController *)snapPreviewViewController {
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
}

- (void)snapPreviewViewControllerUpvote:(HONSnapPreviewViewController *)snapPreviewViewController opponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	_opponentVO = opponentVO;
	
	[[Mixpanel sharedInstance] track:@"Timeline Details - Upvote"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge",
									  [NSString stringWithFormat:@"%d - %@", _opponentVO.userID, _opponentVO.username], @"opponent", nil]];
	
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
	
	UIImageView *heartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heartAnimation"]];
	heartImageView.frame = CGRectOffset(heartImageView.frame, 5.0, [UIScreen mainScreen].bounds.size.height - 130.0);
	[self.view addSubview:heartImageView];
	
	[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		heartImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[heartImageView removeFromSuperview];
	}];
	
	[_timelineItemFooterView upvoteUser:opponentVO.userID onChallenge:_challengeVO];
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
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
										  [NSString stringWithFormat:@"%d - %@", _challengeVO.challengeID, _challengeVO.subjectName], @"challenge", nil]];
		
		if (buttonIndex == 0) {
			[self _flagChallenge];
		}
	}
}

@end
