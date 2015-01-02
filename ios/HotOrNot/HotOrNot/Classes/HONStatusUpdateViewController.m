//
//  HONStatusUpdateViewController.m
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSCharacterSet+AdditionalSets.h"
#import "NSDate+Operations.h"
#import "UIImageView+AFNetworking.h"
#import "UILabel+BoundingRect.h"
#import "UILabel+FormattedText.h"

#import "HONStatusUpdateViewController.h"
#import "HONReplySubmitViewController.h"
#import "HONCommentItemView.h"
#import "HONImageLoadingView.h"
#import "HONRefreshControl.h"
#import "HONScrollView.h"
#import "HONRefreshingLabel.h"

@interface HONStatusUpdateViewController ()
@property (nonatomic, strong) HONStatusUpdateVO *statusUpdateVO;
@property (nonatomic, strong) HONUserClubVO *clubVO;
@property (nonatomic, strong) HONScrollView *scrollView;
@property (nonatomic, strong) HONRefreshControl *refreshControl;
@property (nonatomic, strong) HONImageLoadingView *imageLoadingView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *commentsHolderView;
@property (nonatomic, strong) UIImageView *emotionImageView;

@property (nonatomic, strong) HONRefreshingLabel *scoreLabel;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *upVoteButton;
@property (nonatomic, strong) UIButton *downVoteButton;
@property (nonatomic, strong) NSMutableArray *retrievedReplies;
@property (nonatomic, strong) NSMutableArray *replies;
@property (nonatomic) BOOL isSubmitting;

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) NSTimer *overlayTimer;

@end

@implementation HONStatusUpdateViewController

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeStatusUpdate;
		_viewStateType = HONStateMitigatorViewStateTypeStatusUpdate;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_refreshStatusUpdate:)
													 name:@"REFRESH_STATUS_UPDATE" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_tareStatusUpdate:)
													 name:@"TARE_STATUS_UPDATE" object:nil];
	}
	
	return (self);
}

- (id)initWithStatusUpdate:(HONStatusUpdateVO *)statusUpdateVO forClub:(HONUserClubVO *)clubVO {
	NSLog(@"%@ - initWithStatusUpdate:[%@] forClub:[%d - %@]", [self description], statusUpdateVO.dictionary, clubVO.clubID, clubVO.clubName);
	if ((self = [self init])) {
		_statusUpdateVO = statusUpdateVO;
		_clubVO = clubVO;
	}
	
	return (self);
}

- (void)dealloc {
	[self destroy];
}


#pragma mark - Public APIs
- (void)destroy {
	[_commentsHolderView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONCommentItemView *view = (HONCommentItemView *)obj;
		[view removeFromSuperview];
	}];
	
	[super destroy];
}


#pragma mark - Data Calls
- (void)_retrieveStatusUpdate {
	[[HONAPICaller sharedInstance] retrieveClubByClubID:_clubVO.clubID withOwnerID:_clubVO.ownerID completion:^(NSDictionary *result) {
		_clubVO = [HONUserClubVO clubWithDictionary:result];
		
		[[HONAPICaller sharedInstance] retrieveStatusUpdateByStatusUpdateID:_statusUpdateVO.statusUpdateID completion:^(NSDictionary *result) {
			[self _retrieveRepliesAtPage:1];
		}];
	}];
}

- (void)_retrieveRepliesAtPage:(int)page {
	__block int nextPage = page + 1;
	[[HONAPICaller sharedInstance] retrieveRepliesForStatusUpdateByStatusUpdateID:_statusUpdateVO.statusUpdateID fromPage:page completion:^(NSDictionary *result) {
		NSLog(@"TOTAL:[%d]", [[result objectForKey:@"count"] intValue]);
		
		[_retrievedReplies addObjectsFromArray:[result objectForKey:@"results"]];
		
		if ([_retrievedReplies count] < [[result objectForKey:@"count"] intValue])
			[self _retrieveRepliesAtPage:nextPage];
		
		else {
			NSLog(@"FINISHED RETRIEVED:[%d]", [_retrievedReplies count]);
			
			[_retrievedReplies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSMutableDictionary *dict = [(NSDictionary *)obj mutableCopy];
				[dict setValue:@(_statusUpdateVO.clubID) forKey:@"club_id"];
				[dict setValue:@(_statusUpdateVO.statusUpdateID) forKey:@"parent_id"];
				
				[_replies addObject:[HONCommentVO commentWithDictionary:dict]];
			}];
			
			[self _didFinishDataRefresh];
		}
	}];
}

- (void)_flagStatusUpdate {
	NSDictionary *dict = @{@"user_id"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
						   @"img_url"		: [[HONClubAssistant sharedInstance] defaultStatusUpdatePhotoURL],
						   @"club_id"		: @(_statusUpdateVO.clubID),
						   @"subject"		: @"__FLAG__",
						   @"challenge_id"	: @(_statusUpdateVO.statusUpdateID)};
	
	[[HONAPICaller sharedInstance] submitStatusUpdateWithDictionary:dict completion:^(NSDictionary *result) {
		if ([[result objectForKey:@"result"] isEqualToString:@"fail"]) {
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kProgressHUDMinDuration;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", @"Upload fail");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
			_progressHUD = nil;
			
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:nil];
			[self _goReloadContent];
		}
	}];
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
//	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Status Update - Refresh"];
	[[HONStateMitigator sharedInstance] incrementTotalCounterForType:HONStateMitigatorTotalTypeFriendsTabRefresh];
	
	[self _goReloadContent];
}

- (void)_goReloadContent {
	[_commentsHolderView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONCommentItemView *view = (HONCommentItemView *)obj;
		[view removeFromSuperview];
	}];
	
	if (![_refreshControl isRefreshing])
		[_refreshControl beginRefreshing];
	
	_retrievedReplies = [NSMutableArray array];
	_replies = [NSMutableArray array];
	
	[self _retrieveStatusUpdate];
}

- (void)_didFinishDataRefresh {
	[_refreshControl endRefreshing];
	[_scrollView setContentOffset:CGPointZero animated:YES];
	[self _makeComments];
	
	NSLog(@"%@._didFinishDataRefresh", self.class);
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - enter"];
	
	_isSubmitting = NO;
	_scrollView = [[HONScrollView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - kNavHeaderHeight)];
	_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, 378.0);
	_scrollView.contentInset = UIEdgeInsetsMake(-20.0, 0.0, 20.0, 0.0);
	[_scrollView setContentOffset:CGPointZero animated:YES];
	_scrollView.alwaysBounceVertical = YES;
	_scrollView.delegate = self;
	[self.view addSubview:_scrollView];
	
	_refreshControl = [[HONRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_scrollView addSubview: _refreshControl];
	
	_imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:self.view asLargeLoader:NO];
	[_scrollView addSubview:_imageLoadingView];
	
	_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 320.0)];
	[_scrollView addSubview:_imageView];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_imageView.image = image;
		
		[_imageLoadingView stopAnimating];
		[_imageLoadingView removeFromSuperview];
		_imageLoadingView = nil;
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		[_imageView setImageWithURL:[NSURL URLWithString:[[[HONClubAssistant sharedInstance] defaultStatusUpdatePhotoURL] stringByAppendingString:kSnapLargeSuffix]]];
		
		[_imageLoadingView stopAnimating];
		[_imageLoadingView removeFromSuperview];
		_imageLoadingView = nil;
	};
	
	NSString *url = [[_statusUpdateVO.composeImageVO.urlPrefix stringByAppendingString:kComposeImageURLSuffix640] stringByAppendingString:kComposeImageStaticFileExtension];
	NSLog(@"URL:[%@]", url);
	[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]
													  cachePolicy:kOrthodoxURLCachePolicy
												  timeoutInterval:[HONAppDelegate timeoutInterval]]
					placeholderImage:nil
							 success:imageSuccessBlock
							 failure:imageFailureBlock];
	
	NSLog(@"SUBJECT:[%d]", [[_statusUpdateVO.dictionary objectForKey:@"text"] length]);
	if ([_statusUpdateVO.comment length] > 0) {
		UIView *imgOverlayView = [[UIView alloc] initWithFrame:_imageView.frame];
		imgOverlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.900];
		[_scrollView addSubview:imgOverlayView];
		
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 120.0, 280.0, 44.0)];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.textColor = [UIColor whiteColor];
		subjectLabel.textAlignment = NSTextAlignmentCenter;
		subjectLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:26];
		subjectLabel.text = _statusUpdateVO.comment;
		[_scrollView addSubview:subjectLabel];
	}
	
//	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(246.0, 90.0, 60.0, 20.0)];
//	timeLabel.backgroundColor = [UIColor clearColor];
//	timeLabel.textColor = [UIColor whiteColor];
//	timeLabel.textAlignment = NSTextAlignmentRight;
//	timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
//	timeLabel.text = [[HONDateTimeAlloter sharedInstance] intervalSinceDate:_statusUpdateVO.updatedDate];
//	[self.view addSubview:timeLabel];
	
	UIView *votesHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 240.0, 320.0, 50.0)];
//	voteHolderView.backgroundColor = [[HONColorAuthority sharedInstance] honDebugDefaultColor];
	[_scrollView addSubview:votesHolderView];
	
	_upVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_upVoteButton.frame = CGRectMake(0.0, 0.0, 49.0, 49.0);
	[_upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvoteButton_nonActive"] forState:UIControlStateDisabled];
	[_upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvoteButton_nonActive"] forState:UIControlStateNormal];
	[_upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvoteButton_Active"] forState:UIControlStateHighlighted];
	[_upVoteButton setEnabled:(![[HONClubAssistant sharedInstance] hasVotedForStatusUpdate:_statusUpdateVO])];
	[votesHolderView addSubview:_upVoteButton];
	
	_scoreLabel = [[HONRefreshingLabel alloc] initWithFrame:CGRectMake(100.0, 10.0, 120.0, 26.0)];
	_scoreLabel.backgroundColor = [UIColor clearColor];
	_scoreLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:24];
	_scoreLabel.textAlignment = NSTextAlignmentCenter;
	_scoreLabel.textColor = [UIColor whiteColor];
	[_scoreLabel setText:NSStringFromInt(_statusUpdateVO.score)];
	[votesHolderView addSubview:_scoreLabel];
	
	_downVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_downVoteButton.frame = CGRectMake(250.0, 0.0, 49.0, 49.0);
	[_downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvoteButton_nonActive"] forState:UIControlStateDisabled];
	[_downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvoteButton_nonActive"] forState:UIControlStateNormal];
	[_downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvoteButton_Active"] forState:UIControlStateHighlighted];
	[_downVoteButton setEnabled:(![[HONClubAssistant sharedInstance] hasVotedForStatusUpdate:_statusUpdateVO])];
	[votesHolderView addSubview:_downVoteButton];
	
	NSLog(@"HAS VOTED:[%@]", NSStringFromBOOL([[HONClubAssistant sharedInstance] hasVotedForStatusUpdate:_statusUpdateVO]));
	if (![[HONClubAssistant sharedInstance] hasVotedForStatusUpdate:_statusUpdateVO]) {
		[_upVoteButton addTarget:self action:@selector(_goUpVote) forControlEvents:UIControlEventTouchUpInside];
		[_downVoteButton addTarget:self action:@selector(_goDownVote) forControlEvents:UIControlEventTouchUpInside];
	}
	
	UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	replyButton.frame = CGRectMake(0.0, 320.0, 320.0, 58.0);
	[replyButton setBackgroundImage:[UIImage imageNamed:@"submitButton_nonActive"] forState:UIControlStateNormal];
	[replyButton setBackgroundImage:[UIImage imageNamed:@"submitButton_nonActive"] forState:UIControlStateHighlighted];
	[replyButton addTarget:self action:@selector(_goReply) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:replyButton];

	
	UIView *bufferView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 378.0, 320.0, 25.0)];
	bufferView.backgroundColor = [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.947];
	[_scrollView addSubview:bufferView];
	
	_commentsHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 403.0, 320.0, 0.0)];
	_commentsHolderView.backgroundColor = [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.0];
	[_scrollView addSubview:_commentsHolderView];
	
	
	_headerView = [[HONHeaderView alloc] init];
	[self.view addSubview:_headerView];
	
	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeButton.frame = _headerView.frame;
	[closeButton setBackgroundImage:[UIImage imageNamed:@"statusUpdateHeaderButton_nonActive"] forState:UIControlStateNormal];
	[closeButton setBackgroundImage:[UIImage imageNamed:@"statusUpdateHeaderButton_Active"] forState:UIControlStateHighlighted];
	[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:closeButton];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
	[self _goReloadContent];
}


#pragma mark - Navigation
- (void)_goClose {
	[self dismissViewControllerAnimated:NO completion:^(void) {
	}];
}

- (void)_goFlag {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - flag"];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
														message:NSLocalizedString(@"alert_flag_m", nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
											  otherButtonTitles:NSLocalizedString(@"alert_ok", nil), nil];
	[alertView setTag:0];
	[alertView show];
}

- (void)_goUpVote {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - details_up"];
	
	[_upVoteButton setEnabled:NO];
	[_upVoteButton removeTarget:self action:@selector(_goUpVote) forControlEvents:UIControlEventTouchUpInside];
	
	[_downVoteButton setEnabled:NO];
	[_downVoteButton removeTarget:self action:@selector(_goDownVote) forControlEvents:UIControlEventTouchUpInside];
	
	[_scoreLabel toggleLoading:YES];
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"likeOverlay"]]];
	[[HONAPICaller sharedInstance] voteStatusUpdateWithStatusUpdateID:_statusUpdateVO.statusUpdateID isUpVote:NO completion:^(NSDictionary *result) {
		_statusUpdateVO.score++;
		_scoreLabel.text = NSStringFromInt(_statusUpdateVO.score);
		[_scoreLabel toggleLoading:NO];
		
		[[HONClubAssistant sharedInstance] writeStatusUpdateAsVotedWithID:_statusUpdateVO.statusUpdateID asUpVote:YES];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_SCORE" object:_statusUpdateVO];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:nil];
	}];
}

- (void)_goDownVote {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - details_down"];
	
	[_upVoteButton setEnabled:NO];
	[_upVoteButton removeTarget:self action:@selector(_goUpVote) forControlEvents:UIControlEventTouchUpInside];
	
	[_downVoteButton setEnabled:NO];
	[_downVoteButton removeTarget:self action:@selector(_goDownVote) forControlEvents:UIControlEventTouchUpInside];
	
	[_scoreLabel toggleLoading:YES];
	[[HONAPICaller sharedInstance] voteStatusUpdateWithStatusUpdateID:_statusUpdateVO.statusUpdateID isUpVote:NO completion:^(NSDictionary *result) {
		_statusUpdateVO.score--;
		_scoreLabel.text = NSStringFromInt(_statusUpdateVO.score);
		[_scoreLabel toggleLoading:NO];
		
		[[HONClubAssistant sharedInstance] writeStatusUpdateAsVotedWithID:_statusUpdateVO.statusUpdateID asUpVote:NO];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_SCORE" object:_statusUpdateVO];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:nil];
	}];
}

- (void)_goReply {
	NSDictionary *dict = @{@"user_id"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
						   @"img_url"		: [[HONClubAssistant sharedInstance] defaultStatusUpdatePhotoURL],
						   @"club_id"		: @(_statusUpdateVO.clubID),
						   @"subject"		: @"",
						   @"challenge_id"	: @(_statusUpdateVO.statusUpdateID)};
	NSLog(@"|:|◊≈◊~~◊~~◊≈◊~~◊~~◊≈◊| SUBMIT PARAMS:[%@]", dict);
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONReplySubmitViewController alloc] initWithSubmitParameters:dict]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
//	NSLog(@"[:|:] _goPanGesture:[%@]-=(%@)=-", NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	[super _goPanGesture:gestureRecognizer];
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Friends Tab - Club Row Swipe"
	//										 withUserClub:cell.clubVO];
	
	if ([gestureRecognizer velocityInView:self.view].x <= -1500) {
		[self dismissViewControllerAnimated:YES completion:^(void) {
		}];
	}
}


#pragma mark - Notifications
- (void)_refreshStatusUpdate:(NSNotification *)notification {
	NSLog(@"::|> _refreshStatusUpdate <|::");
	
	[self _goReloadContent];
}

- (void)_tareStatusUpdate:(NSNotification *)notification {
	NSLog(@"::|> _tareStatusUpdate <|::");
	
	[_scrollView scrollRectToVisible:[UIScreen mainScreen].bounds animated:YES];
}


#pragma mark - UI Presentation
- (void)_makeComments {
	_commentsHolderView.frame = CGRectExtendHeight(_commentsHolderView.frame, [_replies count] * 44.0);
	_scrollView.contentSize = CGSizeExpand(_scrollView.contentSize, CGSizeMake(0.0, _commentsHolderView.frame.size.height));
	
	[_replies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONCommentItemView *itemView = [[HONCommentItemView alloc] initWithFrame:CGRectMake(0.0,  44.0 * idx, 320.0, 44.0)];
		itemView.commentVO = (HONCommentVO *)obj;
		[_commentsHolderView addSubview:itemView];
	}];
}


#pragma mark - MailCompose Delegates
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[controller dismissViewControllerAnimated:NO completion:^(void) {
	}];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		if (buttonIndex == 1) {
			[self _flagStatusUpdate];
		}
	}
}


@end
