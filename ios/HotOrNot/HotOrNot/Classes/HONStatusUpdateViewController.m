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
#import "HONStatusUpdateCreatorView.h"

@interface HONStatusUpdateViewController ()
@property (nonatomic, strong) HONStatusUpdateVO *statusUpdateVO;
@property (nonatomic, strong) HONUserClubVO *clubVO;
@property (nonatomic, strong) HONScrollView *scrollView;
@property (nonatomic, strong) HONRefreshControl *refreshControl;
@property (nonatomic, strong) UIImageView *imageLoadingView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *commentsHolderView;
@property (nonatomic, strong) UIImageView *inputBGImageView;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UIButton *submitCommentButton;
@property (nonatomic, strong) NSString *comment;

@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) HONRefreshingLabel *scoreLabel;
@property (nonatomic, strong) UIButton *commentCloseButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *upVoteButton;
@property (nonatomic, strong) UIButton *downVoteButton;
@property (nonatomic, strong) NSMutableArray *retrievedReplies;
@property (nonatomic, strong) NSMutableArray *replies;
@property (nonatomic, strong) HONStatusUpdateCreatorView *creatorView;
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
	
	[_scrollView setContentOffset:CGPointMake(0.0, -95.0) animated:NO];
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
			
			_replies = [[[_replies reverseObjectEnumerator] allObjects] copy];
			[self _didFinishDataRefresh];
		}
	}];
}

- (void)_submitCommentReply {
	NSDictionary *dict = @{@"user_id"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
						   @"img_url"		: [[HONClubAssistant sharedInstance] defaultStatusUpdatePhotoURL],
						   @"club_id"		: @(_clubVO.clubID),
						   @"subject"		: _comment,
						   @"challenge_id"	: @(_statusUpdateVO.statusUpdateID)};
	NSLog(@"|:|◊≈◊~~◊~~◊≈◊~~◊~~◊≈◊| SUBMIT PARAMS:[%@]", dict);
	
	NSLog(@"*^*|~|*|~|*|~|*|~|*|~|*|~| SUBMITTING -=- [%@] |~|*|~|*|~|*|~|*|~|*|~|*^*", dict);
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
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			if ([_overlayTimer isValid])
				[_overlayTimer invalidate];
			
			if (_overlayTimer != nil);
			_overlayTimer = nil;
			
			if (_overlayView != nil) {
				[_overlayView removeFromSuperview];
				_overlayView = nil;
			}
			
			_isSubmitting = NO;
			[self _goReloadContent];
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
	
	_commentsHolderView.frame = CGRectResizeHeight(_commentsHolderView.frame, 0.0);
	_scrollView.contentSize = CGRectResizeHeight(_scrollView.frame, 0.0).size;
	
	if (![_refreshControl isRefreshing])
		[_refreshControl beginRefreshing];
	
	_retrievedReplies = [NSMutableArray array];
	_replies = [NSMutableArray array];
	
	[self _retrieveStatusUpdate];
}

- (void)_didFinishDataRefresh {
	[_refreshControl endRefreshing];
//	[_scrollView setContentOffset:CGPointZero animated:NO];
	
	_scoreLabel.text = NSStringFromInt(_statusUpdateVO.score);
	[self _makeComments];
	
	NSLog(@"%@._didFinishDataRefresh", self.class);
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - enter"];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"Conversation"];
	[_headerView addBackButtonWithTarget:self action:@selector(_goBack)];
	[_headerView addFlagButtonWithTarget:self action:@selector(_goFlag)];
	[self.view addSubview:_headerView];
	
	
	_creatorView = [[HONStatusUpdateCreatorView alloc] initWithStatusUpdateVO:_statusUpdateVO];
	_creatorView.frame = CGRectOffset(_creatorView.frame, 0.0, kNavHeaderHeight);
	[self.view addSubview:_creatorView];
	
	_imageLoadingView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imageLoadingDots_home"]];
	_imageLoadingView.frame = CGRectOffset(_imageLoadingView.frame, 21.0, 22.0);
	[_creatorView addSubview:_imageLoadingView];
	
	_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, 12.0, 50.0, 50.0)];
	[_creatorView addSubview:_imageView];
	[[HONViewDispensor sharedInstance] maskView:_imageView withMask:[UIImage imageNamed:@"topicMask"]];
	
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
	
	
	
	NSString *url = _statusUpdateVO.imagePrefix;
	NSLog(@"URL:[%@]", url);
	[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]
														cachePolicy:kOrthodoxURLCachePolicy
													timeoutInterval:[HONAppDelegate timeoutInterval]]
					  placeholderImage:nil
							   success:imageSuccessBlock
							   failure:imageFailureBlock];
	
	
	
	
	_usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(71.0, 11.0, 200.0, 16.0)];
	_usernameLabel.backgroundColor = [UIColor clearColor];
	_usernameLabel.textColor = [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.58];
	_usernameLabel.font = [[[HONFontAllocator sharedInstance] cartoGothicBold] fontWithSize:13];
	_usernameLabel.text = _statusUpdateVO.username;
	[_creatorView addSubview:_usernameLabel];
	
	
	//	NSLog(@"SUBJECT:[%d]", [[_statusUpdateVO.dictionary objectForKey:@"text"] length]);
	
	NSLog(@"TOPIC:[%@]", _statusUpdateVO.topicName);
	NSLog(@"SUBJECT:[%@]", _statusUpdateVO.subjectName);;
	
	
	NSString *actionCaption = [NSString stringWithFormat:@"— is %@ %@", _statusUpdateVO.topicName, _statusUpdateVO.subjectName];
	UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(71.0, 32.0, 280.0, 20.0)];
	subjectLabel.backgroundColor = [UIColor clearColor];
	subjectLabel.textColor = [UIColor blackColor];
	subjectLabel.font = [[[HONFontAllocator sharedInstance] cartoGothicBook] fontWithSize:16];
	subjectLabel.text = actionCaption;
	[_creatorView addSubview:subjectLabel];
	
	if ([actionCaption rangeOfString:_statusUpdateVO.subjectName].location != NSNotFound)
		[subjectLabel setFont:[[[HONFontAllocator sharedInstance] cartoGothicBold] fontWithSize:16] range:[actionCaption rangeOfString:_statusUpdateVO.subjectName]];
	
	
	UIImageView *timeIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timeIcon"]];
	timeIconImageView.frame = CGRectOffset(timeIconImageView.frame, 72.0, 58.0);
	[_creatorView addSubview:timeIconImageView];
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(88.0, 58.0, 208.0, 16.0)];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textColor = [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.75];
	timeLabel.font = [[[HONFontAllocator sharedInstance] cartoGothicBook] fontWithSize:12];
	timeLabel.text = [[HONDateTimeAlloter sharedInstance] intervalSinceDate:_statusUpdateVO.addedDate];
	[_creatorView addSubview:timeLabel];
	
	_upVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_upVoteButton.frame = CGRectMake(276.0, 0.0, 44.0, 44.0);
	[_upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvoteButton_nonActive"] forState:UIControlStateDisabled];
	[_upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvoteButton_nonActive"] forState:UIControlStateNormal];
	[_upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvoteButton_Active"] forState:UIControlStateHighlighted];
	[_upVoteButton setEnabled:(![[HONClubAssistant sharedInstance] hasVotedForStatusUpdate:_statusUpdateVO])];
	[_creatorView addSubview:_upVoteButton];
	
	_downVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_downVoteButton.frame = CGRectMake(276.0, 40.0, 44.0, 44.0);
	[_downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvoteButton_nonActive"] forState:UIControlStateDisabled];
	[_downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvoteButton_nonActive"] forState:UIControlStateNormal];
	[_downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvoteButton_Active"] forState:UIControlStateHighlighted];
	[_downVoteButton setEnabled:(![[HONClubAssistant sharedInstance] hasVotedForStatusUpdate:_statusUpdateVO])];
	[_creatorView addSubview:_downVoteButton];
	
	NSLog(@"HAS VOTED:[%@]", NSStringFromBOOL([[HONClubAssistant sharedInstance] hasVotedForStatusUpdate:_statusUpdateVO]));
	if (![[HONClubAssistant sharedInstance] hasVotedForStatusUpdate:_statusUpdateVO]) {
		[_upVoteButton addTarget:self action:@selector(_goUpVote) forControlEvents:UIControlEventTouchUpInside];
		[_downVoteButton addTarget:self action:@selector(_goDownVote) forControlEvents:UIControlEventTouchUpInside];
	}
	
	_scoreLabel = [[HONRefreshingLabel alloc] initWithFrame:CGRectMake(275.0, 32.0, 44.0, 20.0)];
	_scoreLabel.backgroundColor = [UIColor clearColor];
	_scoreLabel.font = [[[HONFontAllocator sharedInstance] cartoGothicBook] fontWithSize:12];
	_scoreLabel.textAlignment = NSTextAlignmentCenter;
	_scoreLabel.textColor = [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.75];
	_scoreLabel.text = NSStringFromInt(_statusUpdateVO.score);
	[_creatorView addSubview:_scoreLabel];
	
	_isSubmitting = NO;
	_scrollView = [[HONScrollView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight + 84.0, 320.0, self.view.frame.size.height - (kNavHeaderHeight + 84.0))];
	_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, 0.0);
	[_scrollView setContentInset:kOrthodoxTableViewEdgeInsets];
	_scrollView.alwaysBounceVertical = YES;
	_scrollView.delegate = self;
	[self.view addSubview:_scrollView];
	
	_refreshControl = [[HONRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_scrollView addSubview: _refreshControl];
	
	_commentsHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 0.0)];
	[_scrollView addSubview:_commentsHolderView];
	
	
	
	_inputBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commentInputBG"]];
	_inputBGImageView.frame = CGRectOffset(_inputBGImageView.frame, 0.0, self.view.frame.size.height - 44.0);
	_inputBGImageView.userInteractionEnabled = YES;
	[self.view addSubview:_inputBGImageView];
	
	_commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(15.0, 12.0, 232.0, 21.0)];
	[_commentTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_commentTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_commentTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_commentTextField setReturnKeyType:UIReturnKeyDone];
	[_commentTextField setTextColor:[UIColor blackColor]];
	[_commentTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	_commentTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
	_commentTextField.keyboardType = UIKeyboardTypeDefault;
	_commentTextField.placeholder = NSLocalizedString(@"enter_comment", @"Comment");
	_commentTextField.text = @"";
	_commentTextField.delegate = self;
	[_inputBGImageView addSubview:_commentTextField];
	
	_submitCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitCommentButton.frame = CGRectMake(265.0, 0.0, 44.0, 44.0);
	[_submitCommentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_nonActive"] forState:UIControlStateNormal];
	[_submitCommentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_Active"] forState:UIControlStateHighlighted];
	[_submitCommentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_Disabled"] forState:UIControlStateDisabled];
	[_submitCommentButton addTarget:self action:@selector(_goCommentReply) forControlEvents:UIControlEventTouchUpInside];
	[_submitCommentButton setEnabled:NO];
	[_inputBGImageView addSubview:_submitCommentButton];
	
	_commentCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_commentCloseButton.frame = CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - (216.0 + _inputBGImageView.frame.size.height));
	[_commentCloseButton addTarget:self action:@selector(_goCancelReply) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
	[_scrollView setContentOffset:CGPointMake(0.0, -95.0) animated:NO];
	[self _goReloadContent];
}


#pragma mark - Navigation
- (void)_goBack {
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

- (void)_goCommentReply {
	_isSubmitting = YES;
	
	if ([_commentTextField isFirstResponder])
		[_commentTextField resignFirstResponder];
	
	NSLog(@"DIST:[%.04f] RADIUS:[%.04f]", _clubVO.distance, _clubVO.postRadius);
	
	_comment = _commentTextField.text;
	_commentTextField.text = @"";
	_overlayView = [[UIView alloc] initWithFrame:self.view.frame];
	_overlayView.backgroundColor = [UIColor colorWithWhite:0.00 alpha:0.667];
	[self.view addSubview:_overlayView];
	
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kProgressHUDMinDuration;
	_progressHUD.taskInProgress = YES;
	
	
	[self _submitCommentReply];
}

- (void)_goCancelReply {
	_commentTextField.text = @"";
	if ([_commentTextField isFirstResponder])
		[_commentTextField resignFirstResponder];
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
	
	[_scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
	//	NSLog(@"UITextFieldTextDidChangeNotification:[%@]", [notification object]);
	
#if __APPSTORE_BUILD__ == 0
	if ([_commentTextField.text isEqualToString:@"¡"]) {
		_commentTextField.text = [[[HONDeviceIntrinsics sharedInstance] phoneNumber] substringFromIndex:2];
	}
#endif
	
	[_submitCommentButton setEnabled:([_commentTextField.text length] > 0)];
}



#pragma mark - UI Presentation
- (void)_makeComments {
	_commentsHolderView.frame = CGRectExtendHeight(_commentsHolderView.frame, [_replies count] * 90.0);
	_scrollView.contentSize = _commentsHolderView.frame.size;
	
	[_replies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONCommentItemView *itemView = [[HONCommentItemView alloc] initWithFrame:CGRectMake(0.0,  90.0 * idx, 320.0, 90.0)];
		itemView.alpha = 0.0;
		itemView.commentVO = (HONCommentVO *)obj;
		[_commentsHolderView addSubview:itemView];
		
		[UIView animateKeyframesWithDuration:0.25 delay:(0.125 * ([_replies count] - idx)) options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
			itemView.alpha = 1.0;
		} completion:^(BOOL finished) {
		}];
	}];
	
	if ([_replies count] > 4)
		[_scrollView setContentOffset:CGPointMake(0.0, (_scrollView.contentSize.height - _scrollView.frame.size.height) + _scrollView.contentInset.bottom) animated:YES];
}

- (void)_orphanSubmitOverlay {
	NSLog(@"::|> _orphanSubmitOverlay <|::");
	
	if ([_overlayTimer isValid])
		[_overlayTimer invalidate];
	
	if (_overlayTimer != nil);
	_overlayTimer = nil;
	
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	if (_overlayView != nil) {
		[_overlayView removeFromSuperview];
		_overlayView = nil;
	}
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_textFieldTextDidChangeChange:)
												 name:UITextFieldTextDidChangeNotification
											   object:textField];
	
	[UIView animateWithDuration:0.25
					 animations:^(void) {
						 _inputBGImageView.frame = CGRectTranslateY(_inputBGImageView.frame, self.view.frame.size.height - (216.0 + _inputBGImageView.frame.size.height));
					 } completion:^(BOOL finished) {
						 [self.view addSubview:_commentCloseButton];
					 }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([string rangeOfCharacterFromSet:[NSCharacterSet invalidCharacterSet]].location != NSNotFound)
		return (NO);
	
	return ([textField.text length] < 70 || [string isEqualToString:@""]);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UITextFieldTextDidChangeNotification"
												  object:textField];
	[UIView animateWithDuration:0.25
					 animations:^(void) {
						 _inputBGImageView.frame = CGRectTranslateY(_inputBGImageView.frame, self.view.frame.size.height - 44.0);
					 } completion:^(BOOL finished) {
						 [_commentCloseButton removeFromSuperview];
					 }];
}

- (void)_onTextEditingDidEnd:(id)sender {
	NSLog(@"[*:*] _onTextEditingDidEnd:[%@]", _commentTextField.text);
	
	if (!_isSubmitting && [_commentTextField.text length] > 0)
		[self _goCommentReply];
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
