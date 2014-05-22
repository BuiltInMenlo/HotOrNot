//
//  HONClubPhotoViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/7/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONClubPhotoViewController.h"
#import "HONHeaderView.h"

#import "HONImagePickerViewController.h"
#import "HONVotersViewController.h"
#import "HONCommentsViewController.h"
#import "HONSnapPreviewViewController.h"
#import "HONTimelineCellHeaderView.h"
#import "HONTimelineCellSubjectView.h"
#import "HONTimelineItemFooterView.h"
#import "HONChallengeDetailsGridView.h"
#import "HONUserProfileViewController.h"
#import "HONChangeAvatarViewController.h"
#import "HONImageLoadingView.h"
#import "HONEmotionVO.h"


@interface HONClubPhotoViewController () <HONTimelineCellHeaderViewDelegate, HONTimelineCellSubjectViewDelegate, HONTimelineItemFooterViewDelegate, HONSnapPreviewViewControllerDelegate, HONParticipantGridViewDelegate, EGORefreshTableHeaderDelegate>
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
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UILabel *commentsLabel;
@property (nonatomic, strong) HONOpponentVO *opponentVO;
@property (nonatomic, strong) HONOpponentVO *heroOpponentVO;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic) BOOL isChallengeCreator;
@property (nonatomic) BOOL isChallengeOpponent;
@property (nonatomic) int opponentCounter;
@property (nonatomic) int challengeID;
@property (nonatomic, strong) HONImageLoadingView *loadingIndicatorView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end

@implementation HONClubPhotoViewController

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		_challengeVO = vo;
		
		self.view.backgroundColor = [UIColor whiteColor];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshAllTabs:) name:@"REFRESH_ALL_TABS" object:nil];
	}
	
	return (self);
}

- (id)initWithChallengeID:(int)challengeID {
	if ((self = [super init])) {
		_challengeID = challengeID;
		_challengeVO = nil;
		
		self.view.backgroundColor = [UIColor whiteColor];
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


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
//	_bgHolderView = [[UIView alloc] initWithFrame:self.view.frame];
//	[self.view addSubview:_bgHolderView];
	
	_heroHolderView = [[UIView alloc] initWithFrame:self.view.frame];
	_heroHolderView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:_heroHolderView];
	
	_loadingIndicatorView = [[HONImageLoadingView alloc] initInViewCenter:_heroHolderView asLargeLoader:NO];
	_loadingIndicatorView.frame = CGRectOffset(_loadingIndicatorView.frame, 0.0, 40.0);
	[_heroHolderView addSubview:_loadingIndicatorView];
	
	_heroImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
	[_heroHolderView addSubview:_heroImageView];
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_heroImageView.image = image;
	};
	
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		//		[[HONAPICaller sharedInstance] notifyToProcessImageSizesForURLPrefix:_heroOpponentVO.imagePrefix completion:nil];
	};
	
	NSLog(@"DETAILS:[%@]", [_heroOpponentVO.imagePrefix stringByAppendingString:kSnapLargeSuffix]);
	
	_heroImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapTabSize.width, kSnapTabSize.height)];
	_heroImageView.userInteractionEnabled = YES;
	[_heroHolderView addSubview:_heroImageView];
	[_heroImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_heroOpponentVO.imagePrefix stringByAppendingString:kSnapLargeSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
						  placeholderImage:nil
								   success:successBlock
								   failure:failureBlock];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 2.0, 93.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backWhiteButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backWhiteButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	
	UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 129.0, 320.0, 69.0)];
	//UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 80.0, 320.0, 69.0)];
	[self.view addSubview:infoView];
	
	UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 0.0, 288.0, 18.0)];
	usernameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:14];
	usernameLabel.textColor = [UIColor whiteColor];
	usernameLabel.backgroundColor = [UIColor clearColor];
	usernameLabel.shadowColor = [UIColor blackColor];
	usernameLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	usernameLabel.text = _challengeVO.creatorVO.username;
	[infoView addSubview:usernameLabel];
	
	UILabel *emotionLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 25.0, 120.0, 18.0)];
	emotionLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:14];
	emotionLabel.textColor = [UIColor whiteColor];
	emotionLabel.backgroundColor = [UIColor clearColor];
	emotionLabel.shadowColor = [UIColor blackColor];
	emotionLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	emotionLabel.text = [@"- is feeling " stringByAppendingString:_challengeVO.subjectName];
	[infoView addSubview:emotionLabel];
	
	int xOffset = 0;
	for (int i=0; i<4; i++) {
		UIImageView *emoticonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fpo_emotionIcon-SM"]];
		emoticonImageView.frame = CGRectMake((emotionLabel.frame.origin.x + emotionLabel.frame.size.width) + xOffset, 16.0, 44.0, 44.0);
		[infoView addSubview:emoticonImageView];
		
		xOffset += 44;
	}
	
	xOffset = 4;
	for (int i=0; i<5; i++) {
		UIImageView *emoticonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fpo_emotionIcon-SM"]];
		emoticonImageView.frame = CGRectMake(xOffset, 58.0, 44.0, 44.0);
		[infoView addSubview:emoticonImageView];
		
		xOffset += 44;
	}
	
	_footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, CGRectGetHeight([UIScreen mainScreen].bounds) - 47.0, 320.0, 44.0)];
	[self.view addSubview:_footerView];
	
	UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	likeButton.frame = CGRectMake(-1.0, 2.0, 44.0, 44.0);
	[likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive"] forState:UIControlStateNormal];
	[likeButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active"] forState:UIControlStateHighlighted];
//	[likeButton addTarget:self action:@selector(_goLike) forControlEvents:UIControlEventTouchUpInside];
	[_footerView addSubview:likeButton];
	
	UILabel *likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(36.0, 9.0, 160.0, 28.0)];
	likesLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:11];
	likesLabel.textColor = [UIColor whiteColor];
	likesLabel.backgroundColor = [UIColor clearColor];
	likesLabel.shadowColor = [UIColor blackColor];
	likesLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	likesLabel.text = [NSString stringWithFormat:@"Likes (%d)", MIN(_challengeVO.totalLikes, 999)];
	[_footerView addSubview:likesLabel];
	
	UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	replyButton.frame = CGRectMake(86.0, 0.0, 44.0, 44.0);
	[replyButton setBackgroundImage:[UIImage imageNamed:@"replySelfieButton_nonActive"] forState:UIControlStateNormal];
	[replyButton setBackgroundImage:[UIImage imageNamed:@"replySelfieButton_Active"] forState:UIControlStateHighlighted];
//	[replyButton addTarget:self action:@selector(_goReply) forControlEvents:UIControlEventTouchUpInside];
	[_footerView addSubview:replyButton];
	
	UILabel *repliesLabel = [[UILabel alloc] initWithFrame:CGRectMake(128.0, 9.0, 160.0, 28.0)];
	repliesLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:11];
	repliesLabel.textColor = [UIColor whiteColor];
	repliesLabel.backgroundColor = [UIColor clearColor];
	repliesLabel.shadowColor = [UIColor blackColor];
	repliesLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	repliesLabel.text = [NSString stringWithFormat:@"Replies (%d)", MIN([_challengeVO.challengers count], 999)];
	[_footerView addSubview:repliesLabel];
	
	UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
	moreButton.frame = CGRectMake(265.0, 2.0, 44.0, 44.0);
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreButton_nonActive"] forState:UIControlStateNormal];
	[moreButton setBackgroundImage:[UIImage imageNamed:@"moreButton_Active"] forState:UIControlStateHighlighted];
//	[moreButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	[_footerView addSubview:moreButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}


#pragma mark - UI Presentation
- (void)_removeSnapOverlay {
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
}

- (void)_rebuildUI {
	[self _orphanUI];
	[self _adoptUI];
}

- (void)_orphanUI {
	for (UIView *view in _contentHolderView.subviews)
		[view removeFromSuperview];
}

- (void)_adoptUI {
	[self _makeHero];
	[self _makeParticipantGrid];
	[self _makeFooterTabBar];
}

- (void)_makeHero {
	_heroHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kDetailsHeroImageHeight)];
	_heroHolderView.clipsToBounds = YES;
	[_contentHolderView addSubview:_heroHolderView];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:_heroHolderView asLargeLoader:NO];
	[_heroHolderView addSubview:imageLoadingView];
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_heroImageView.image = image;
	};
	
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
//		[[HONAPICaller sharedInstance] notifyToProcessImageSizesForURLPrefix:_heroOpponentVO.imagePrefix completion:nil];
	};
	
	_heroImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSnapTabSize.width, kSnapTabSize.height)];
	_heroImageView.userInteractionEnabled = YES;
	[_heroHolderView addSubview:_heroImageView];
	[_heroImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_heroOpponentVO.imagePrefix stringByAppendingString:kSnapTabSuffix]] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
						  placeholderImage:nil
								   success:successBlock
								   failure:failureBlock];
	
	HONTimelineCellSubjectView *timelineCellSubjectView = [[HONTimelineCellSubjectView alloc] initAtOffsetY:20.0 + ((kDetailsHeroImageHeight - 44.0) * 0.5) withSubjectName:_challengeVO.subjectName withUsername:_challengeVO.creatorVO.username];
	timelineCellSubjectView.delegate = self;
	[_heroHolderView addSubview:timelineCellSubjectView];
	
	
	UIButton *heroPreviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
	heroPreviewButton.frame = CGRectMake(0.0, 0.0, _heroHolderView.frame.size.width, _heroHolderView.frame.size.height);
	[heroPreviewButton addTarget:self action:@selector(_goHeroPreview) forControlEvents:UIControlEventTouchUpInside];
	[_heroHolderView addSubview:heroPreviewButton];
	
	HONTimelineCellHeaderView *creatorHeaderView = [[HONTimelineCellHeaderView alloc] initWithChallenge:_challengeVO];
	creatorHeaderView.frame = CGRectOffset(creatorHeaderView.frame, 0.0, 64.0);
	creatorHeaderView.delegate = self;
	[_heroHolderView addSubview:creatorHeaderView];
	
	_timelineItemFooterView = [[HONTimelineItemFooterView alloc] initAtPosY:kDetailsHeroImageHeight - 56.0 withChallenge:_challengeVO];
	_timelineItemFooterView.delegate = self;
	[_heroHolderView addSubview:_timelineItemFooterView];
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	lpGestureRecognizer.minimumPressDuration = 0.25;
	[_scrollView addGestureRecognizer:lpGestureRecognizer];
}

- (void)_makeParticipantGrid {
	_participantsGridView = [[HONChallengeDetailsGridView alloc] initAtPos:kDetailsHeroImageHeight forChallenge:_challengeVO asPrimaryOpponent:_heroOpponentVO];
	_participantsGridView.delegate = self;
	[_contentHolderView addSubview:_participantsGridView];
}

- (void)_makeFooterTabBar {
	CGSize size;
	
	UIButton *joinFooterButton = [UIButton buttonWithType:UIButtonTypeCustom];
	joinFooterButton.frame = CGRectMake(0.0, 1.0, 43.0, 44.0);
	[joinFooterButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateNormal];
	[joinFooterButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColorHighlighted] forState:UIControlStateHighlighted];
	[joinFooterButton.titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:17.0]];
	[joinFooterButton setTitle:@"Reply" forState:UIControlStateNormal];
	[joinFooterButton addTarget:self action:@selector(_goJoinChallenge) forControlEvents:UIControlEventTouchUpInside];
	
	if ([[HONDeviceIntrinsics sharedInstance] isIOS7]) {
		size = [joinFooterButton.titleLabel.text boundingRectWithSize:CGSizeMake(150.0, 22.0)
															  options:NSStringDrawingTruncatesLastVisibleLine
														   attributes:@{NSFontAttributeName:joinFooterButton.titleLabel.font}
															  context:nil].size;
		
	} //else
//		size = [joinFooterButton.titleLabel.text sizeWithFont:joinFooterButton.titleLabel.font constrainedToSize:CGSizeMake(150.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
	
	joinFooterButton.frame = CGRectMake(joinFooterButton.frame.origin.x, joinFooterButton.frame.origin.y, size.width, size.height);
	
	UIButton *shareFooterButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareFooterButton.frame = CGRectMake(0.0, 0.0, 80.0, 44.0);
	[shareFooterButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateNormal];
	[shareFooterButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColorHighlighted] forState:UIControlStateHighlighted];
	[shareFooterButton.titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:17.0]];
	[shareFooterButton setTitle:@"Share" forState:UIControlStateNormal];
	[shareFooterButton addTarget:self action:@selector(_goShareChallenge) forControlEvents:UIControlEventTouchUpInside];
	
	if ([[HONDeviceIntrinsics sharedInstance] isIOS7]) {
		size = [shareFooterButton.titleLabel.text boundingRectWithSize:CGSizeMake(150.0, 22.0)
															   options:NSStringDrawingTruncatesLastVisibleLine
															attributes:@{NSFontAttributeName:shareFooterButton.titleLabel.font}
															   context:nil].size;
		
	} //else
//		size = [shareFooterButton.titleLabel.text sizeWithFont:shareFooterButton.titleLabel.font constrainedToSize:CGSizeMake(150.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
	
	shareFooterButton.frame = CGRectMake(shareFooterButton.frame.origin.x, shareFooterButton.frame.origin.y, size.width, size.height);
	
	UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
	flagButton.frame = CGRectMake(0.0, 0.0, 31.0, 44.0);
	[flagButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateNormal];
	[flagButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColorHighlighted] forState:UIControlStateHighlighted];
	[flagButton.titleLabel setFont:[[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:17.0]];
	[flagButton setTitle:@"Flag" forState:UIControlStateNormal];
	[flagButton addTarget:self action:@selector(_goFlagChallenge) forControlEvents:UIControlEventTouchUpInside];
	
	if ([[HONDeviceIntrinsics sharedInstance] isIOS7]) {
		size = [flagButton.titleLabel.text boundingRectWithSize:CGSizeMake(150.0, 22.0)
														options:NSStringDrawingTruncatesLastVisibleLine
													 attributes:@{NSFontAttributeName:flagButton.titleLabel.font}
														context:nil].size;
		
	} //else
//		size = [flagButton.titleLabel.text sizeWithFont:flagButton.titleLabel.font constrainedToSize:CGSizeMake(150.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
	
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
- (void)_goBack {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline Details - Back"];
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)_goLongPress:(UILongPressGestureRecognizer *)lpGestureRecognizer {
	if (lpGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint touchPoint = [lpGestureRecognizer locationInView:_scrollView];
		
		_opponentVO = (CGRectContainsPoint(_heroHolderView.frame, touchPoint)) ? _heroOpponentVO : nil;
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline Details - Show Photo Details"
										  withChallenge:_challengeVO
										 andParticipant:_opponentVO];
		
		if (_opponentVO != nil) {
			UIView *tagView = [[UIView alloc] initWithFrame:CGRectZero];
			[tagView setTag:_opponentVO.userID];
			
			[self _goUserProfile:_opponentVO];
		}
		
	} else if (lpGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
	}
}

- (void)_goRefresh {
	[[HONAPICaller sharedInstance] retrieveChallengeForChallengeID:_challengeVO.challengeID completion:^(NSObject *result){
		_challengeVO = [HONChallengeVO challengeWithDictionary:(NSDictionary *)result];
		
		[self _participantCheck];
		[self _rebuildUI];
		
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_scrollView];
	}];
}

- (void)_goClose {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline Details - Close"
									  withChallenge:_challengeVO];
	
	[self dismissViewControllerAnimated:YES completion:^(void) {
	}];

}

- (void)_goScore {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline Details - Show Voters"
									  withChallenge:_challengeVO];
	
	[self.navigationController pushViewController:[[HONVotersViewController alloc] initWithChallenge:_challengeVO] animated:YES];
}

- (void)_goComments {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline Details - Show Comments"
									  withChallenge:_challengeVO];
	
	[self.navigationController pushViewController:[[HONCommentsViewController alloc] initWithChallenge:_challengeVO] animated:YES];
}


- (void)_goHeroPreview {
	NSLog(@"_goHeroPreview");
	if (_snapPreviewViewController != nil) {
		[_snapPreviewViewController.view removeFromSuperview];
		_snapPreviewViewController = nil;
	}
	
	_snapPreviewViewController = [[HONSnapPreviewViewController alloc] initWithOpponent:_heroOpponentVO forChallenge:_challengeVO];
	_snapPreviewViewController.delegate = self;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ADD_VIEW_TO_WINDOW" object:_snapPreviewViewController.view];
}

- (void)_goUserProfile:(HONOpponentVO *)oppoentVO {
	 [[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline Details - "
									   withChallenge:_challengeVO
									  andParticipant:oppoentVO];
	 
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:oppoentVO.userID] animated:YES];
//	HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] init];
//	userPofileViewController.userID = userID;
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goJoinChallenge {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline Details - Join Challenge"
									  withChallenge:_challengeVO];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithJoinChallenge:_challengeVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goLikeCreator {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline Details - Like Challenge"
									  withChallenge:_challengeVO];

	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"likeOverlay"]]];
	
	[[HONAPICaller sharedInstance] upvoteChallengeWithChallengeID:_challengeVO.challengeID forOpponent:_challengeVO.creatorVO completion:^(NSObject *result){
		if (result != nil)
			_challengeVO = [HONChallengeVO challengeWithDictionary:(NSDictionary *)result];
		
		[_timelineItemFooterView updateChallenge:_challengeVO];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_LIKE_COUNT" object:_challengeVO.dictionary];
	}];
}

- (void)_goShareChallenge {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline Details - Share Challenge"
									  withChallenge:_challengeVO];
	
	NSString *igCaption = [NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:0], _heroOpponentVO.subjectName, _heroOpponentVO.username];
	NSString *twCaption = [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:0], _heroOpponentVO.subjectName, _heroOpponentVO.username, [HONAppDelegate shareURL]];
	NSString *fbCaption = [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:0], _heroOpponentVO.subjectName, _heroOpponentVO.username, [HONAppDelegate shareURL]];
	NSString *smsCaption = [NSString stringWithFormat:[HONAppDelegate smsShareCommentForIndex:0], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]];
	NSString *emailCaption = [[[[HONAppDelegate emailShareCommentForIndex:0] objectForKey:@"subject"] stringByAppendingString:@"|"] stringByAppendingString:[NSString stringWithFormat:[[HONAppDelegate emailShareCommentForIndex:0] objectForKey:@"body"], [[HONAppDelegate infoForUser] objectForKey:@"username"], [HONAppDelegate shareURL]]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[igCaption, twCaption, fbCaption, smsCaption, emailCaption],
																							@"image"			: _heroImageView.image,
																							@"url"				: [_heroOpponentVO.imagePrefix stringByAppendingString:kSnapLargeSuffix],
																							@"mp_event"			: @"Timeline Details",
																							@"view_controller"	: self}];
}

- (void)_goFlagChallenge {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline Details - Flag Challenge"
									  withChallenge:_challengeVO];
	
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
	[[HONAPICaller sharedInstance] retrieveChallengeForChallengeID:_challengeVO.challengeID completion:^(NSObject *result){
		_challengeVO = [HONChallengeVO challengeWithDictionary:(NSDictionary *)result];
		
		[self _participantCheck];
		[self _rebuildUI];
		
		[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_scrollView];
	}];
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


#pragma mark - TimelineCellHeaderCreator Delegates
- (void)timelineCellHeaderView:(HONTimelineCellHeaderView *)cell showProfile:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline Details - Header Show Profile"
									  withChallenge:challengeVO
									 andParticipant:opponentVO];
	
	[self _goUserProfile:opponentVO];
}


#pragma mark - TimelineSubject Delegates
- (void)timelineCellSubjectViewShowProfile:(HONTimelineCellSubjectView *)subjectView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline Details - User Profile"
									  withChallengeCreator:_challengeVO];
	
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:_challengeVO.creatorVO.userID] animated:YES];
}


#pragma mark - TimelineItemFooterView Delegates
- (void)footerView:(HONTimelineItemFooterView *)cell showProfileForParticipant:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline Details - User Profile"
									  withChallenge:challengeVO
									 andParticipant:opponentVO];
	
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:opponentVO.userID] animated:YES];
}

- (void)footerView:(HONTimelineItemFooterView *)cell joinChallenge:(HONChallengeVO *)challengeVO {
	[self _goJoinChallenge];
}

- (void)footerView:(HONTimelineItemFooterView *)cell showDetailsForChallenge:(HONChallengeVO *)challengeVO {
}

- (void)footerView:(HONTimelineItemFooterView *)cell likeChallenge:(HONChallengeVO *)challengeVO {
	[self _goLikeCreator];
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
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline Details - User Profile"
									  withChallenge:challengeVO
									 andParticipant:opponentVO];
	
	[self.navigationController pushViewController:[[HONUserProfileViewController alloc] initWithUserID:opponentVO.userID] animated:YES];
}


#pragma mark - SnapPreview Delegates
- (void)snapPreviewViewControllerClose:(HONSnapPreviewViewController *)snapPreviewViewController {
	[self _removeSnapOverlay];
}

- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController upvoteOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_challengeVO = challengeVO;
	_opponentVO = opponentVO;
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Timeline Details - Upvote"
									  withChallenge:challengeVO
									 andParticipant:opponentVO];
	
	[self _removeSnapOverlay];
	
//	[_timelineItemFooterView upvoteUser:opponentVO.userID onChallenge:challengeVO];
	[_timelineItemFooterView updateChallenge:_challengeVO];
}

- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController flagOpponent:(HONOpponentVO *)opponentVO forChallenge:(HONChallengeVO *)challengeVO {
	_opponentVO = opponentVO;
	[self _removeSnapOverlay];
}

- (void)snapPreviewViewController:(HONSnapPreviewViewController *)snapPreviewViewController joinChallenge:(HONChallengeVO *)challengeVO {
	[self _removeSnapOverlay];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithJoinChallenge:_challengeVO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}


#pragma mark - RefreshTableHeader Delegates
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
//	NSLog(@"[*:*] egoRefreshTableHeaderDidTriggerRefresh offset:[%.02f] inset:[%@] [*:*]", _scrollView.contentOffset.y, NSStringFromUIEdgeInsets(_scrollView.contentInset));
	[self _goRefresh];
}


#pragma mark - ScrollView Delegates
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	NSLog(@"[*:*] scrollViewDidScroll offset:[%.02f] inset:[%@] [*:*]", scrollView.contentOffset.y, NSStringFromUIEdgeInsets(scrollView.contentInset));
	[_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//	NSLog(@"[*:*] scrollViewDidEndDragging offset:[%.02f] inset:[%@] [*:*]", scrollView.contentOffset.y, NSStringFromUIEdgeInsets(scrollView.contentInset));
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Timeline Details - Flag " stringByAppendingString:(buttonIndex == 0) ? @"Abusive" : @"Cancel"]
								   withChallengeCreator:_challengeVO];
		
		if (buttonIndex == 0) {
			[[HONAPICaller sharedInstance] flagChallengeByChallengeID:_challengeVO.challengeID completion:nil];
		}
	}
}

@end