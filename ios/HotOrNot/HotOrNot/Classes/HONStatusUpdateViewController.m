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
#import "HONCommentViewCell.h"
#import "HONImageLoadingView.h"
#import "HONRefreshControl.h"
#import "HONScrollView.h"
#import "HONTableView.h"
#import "HONRefreshingLabel.h"

@interface HONStatusUpdateViewController () <HONCommentViewCellDelegate>
@property (nonatomic, strong) HONStatusUpdateVO *statusUpdateVO;
@property (nonatomic, strong) HONUserClubVO *clubVO;
@property (nonatomic, strong) HONScrollView *scrollView;
@property (nonatomic, strong) HONRefreshControl *refreshControl;
@property (nonatomic, strong) HONImageLoadingView *imageLoadingView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *emotionImageView;

@property (nonatomic, strong) HONRefreshingLabel *scoreLabel;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *upVoteButton;
@property (nonatomic, strong) UIButton *downVoteButton;
@property (nonatomic, strong) UIImageView *inputBGImageView;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UIButton *submitCommentButton;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) HONTableView *tableView;
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
		
		_comment = @"";
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
	[[_tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONCommentViewCell *cell = (HONCommentViewCell *)obj;
		cell.delegate = nil;
	}];
	
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
	
	[self destroy];
}


#pragma mark - Public APIs
- (void)destroy {
	[super destroy];
}


#pragma mark - Data Calls
- (void)_retrieveStatusUpdate {
	[[HONAPICaller sharedInstance] retrieveClubByClubID:_clubVO.clubID withOwnerID:_clubVO.ownerID completion:^(NSDictionary *result) {
		
		_clubVO = [HONUserClubVO clubWithDictionary:result];
//		[[HONClubAssistant sharedInstance] writeClub:result];
//		
//		[_clubVO.submissions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//			HONClubPhotoVO *clubPhotoVO = (HONClubPhotoVO *)obj;
//			if (clubPhotoVO.challengeID == _clubPhotoVO.challengeID) {
//				_clubPhotoVO = [HONClubPhotoVO clubPhotoWithDictionary:clubPhotoVO.dictionary];
//				*stop = YES;
//			}
//		}];
		
		[self _didFinishDataRefresh];
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
						   @"club_id"		: @(_clubVO.clubID),
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
	[[_tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONCommentViewCell *viewCell = (HONCommentViewCell *)obj;
		[viewCell destroy];
	}];
	
	if (![_refreshControl isRefreshing])
		[_refreshControl beginRefreshing];
	
	_replies = [NSMutableArray array];
	[_tableView reloadData];
	
	[self _retrieveStatusUpdate];
}

- (void)_didFinishDataRefresh {
//	[[[HONClubAssistant sharedInstance] repliesForClubPhoto:_clubPhotoVO] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		HONCommentVO *vo = (HONCommentVO *)obj;
//		
//		if (![vo.textContent isEqualToString:@"__FLAG__"])
//			[_replies addObject:vo];
//	}];
	
	
	[_tableView reloadData];
	
	[_refreshControl endRefreshing];
	[_scrollView setContentOffset:CGPointZero animated:YES];
	
	NSLog(@"%@._didFinishDataRefresh", self.class);
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - enter"];
	
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_isSubmitting = NO;
//	[[[HONClubAssistant sharedInstance] repliesForClubPhoto:_clubPhotoVO] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		HONCommentVO *vo = (HONCommentVO *)obj;
//		
//		if (![vo.textContent isEqualToString:@"__FLAG__"])
//			[_replies addObject:vo];
//	}];
	
	_scrollView = [[HONScrollView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - kNavHeaderHeight)];
	_scrollView.contentInset = UIEdgeInsetsMake(-20.0, 0.0, 0.0, 0.0);
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
		UIView *subjectBGView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 242.0, 320.0, 44.0)];
		subjectBGView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
		[_scrollView addSubview:subjectBGView];
		
		UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 7.0, 280.0, 24.0)];
		subjectLabel.backgroundColor = [UIColor clearColor];
		subjectLabel.textColor = [UIColor whiteColor];
		subjectLabel.textAlignment = NSTextAlignmentCenter;
		subjectLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
		subjectLabel.text = _statusUpdateVO.comment;
		[subjectBGView addSubview:subjectLabel];
	}
	
	UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(246.0, 90.0, 60.0, 20.0)];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textColor = [UIColor whiteColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
	timeLabel.text = [[HONDateTimeAlloter sharedInstance] intervalSinceDate:_statusUpdateVO.updatedDate];
//	[self.view addSubview:timeLabel];
	
	UIButton *cancelReplyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelReplyButton.frame = _scrollView.frame;
	[cancelReplyButton addTarget:self action:@selector(_goCancelReply) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:cancelReplyButton];
	
	
	UIView *voteHolderView = [[UIView alloc] initWithFrame:CGRectMake(_scrollView.frame.size.width - 60.0, 57.0, 49.0, 150.0)];
//	voteHolderView.backgroundColor = [[HONColorAuthority sharedInstance] honDebugDefaultColor];
	[_scrollView addSubview:voteHolderView];
	
	_upVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_upVoteButton.frame = CGRectMake(0.0, 0.0, 49.0, 49.0);
	[_upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvoteButton_nonActive"] forState:UIControlStateDisabled];
	[_upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvoteButton_nonActive"] forState:UIControlStateNormal];
	[_upVoteButton setBackgroundImage:[UIImage imageNamed:@"upvoteButton_Active"] forState:UIControlStateHighlighted];
	[_upVoteButton setEnabled:(![[HONClubAssistant sharedInstance] hasVotedForStatusUpdate:_statusUpdateVO])];
	[voteHolderView addSubview:_upVoteButton];
	
	_scoreLabel = [[HONRefreshingLabel alloc] initWithFrame:CGRectMake(0.0, 60.0, 49.0, 26.0)];
	_scoreLabel.backgroundColor = [UIColor clearColor];
	_scoreLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:24];
	_scoreLabel.textAlignment = NSTextAlignmentCenter;
	_scoreLabel.textColor = [UIColor whiteColor];
	[_scoreLabel setText:NSStringFromInt(_statusUpdateVO.score)];
	[_scoreLabel toggleLoading:YES];
	[voteHolderView addSubview:_scoreLabel];
	
	_downVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_downVoteButton.frame = CGRectMake(0.0, 95.0, 49.0, 49.0);
	[_downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvoteButton_nonActive"] forState:UIControlStateDisabled];
	[_downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvoteButton_nonActive"] forState:UIControlStateNormal];
	[_downVoteButton setBackgroundImage:[UIImage imageNamed:@"downvoteButton_Active"] forState:UIControlStateHighlighted];
	[_downVoteButton setEnabled:(![[HONClubAssistant sharedInstance] hasVotedForStatusUpdate:_statusUpdateVO])];
	[voteHolderView addSubview:_downVoteButton];
	
	NSLog(@"HAS VOTED:[%@]", NSStringFromBOOL([[HONClubAssistant sharedInstance] hasVotedForStatusUpdate:_statusUpdateVO]));
	if (![[HONClubAssistant sharedInstance] hasVotedForStatusUpdate:_statusUpdateVO]) {
		[_upVoteButton addTarget:self action:@selector(_goUpVote) forControlEvents:UIControlEventTouchUpInside];
		[_downVoteButton addTarget:self action:@selector(_goDownVote) forControlEvents:UIControlEventTouchUpInside];
	}
	
//	[[HONAPICaller sharedInstance] retrieveVoteTotalForChallengeWithChallengeID:_clubPhotoVO.challengeID completion:^(NSString *result) {
//		_clubPhotoVO.score = [result intValue];
//		[_scoreLabel setText:NSStringFromInt(_statusUpdateVO.score)];
//		[_scoreLabel toggleLoading:NO];
//	}];
	
	_replies = [NSMutableArray array];
//	[[[HONClubAssistant sharedInstance] repliesForClubPhoto:_clubPhotoVO] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		HONCommentVO *vo = (HONCommentVO *)obj;
//		
//		if (![vo.textContent isEqualToString:@"__FLAG__"])
//			[_replies addObject:vo];
//	}];
	
	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - (([_replies count] > 0) ? 146.0 : 88.0), 320.0, self.view.frame.size.height - (kNavHeaderHeight + 44.0))];
	_tableView.backgroundColor = [UIColor whiteColor];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
	
	
	[_tableView reloadData];
	
	_inputBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commentInputBG"]];
	_inputBGImageView.frame = CGRectOffset(_inputBGImageView.frame, 0.0, self.view.frame.size.height - 44.0);
	_inputBGImageView.userInteractionEnabled = YES;
	[self.view addSubview:_inputBGImageView];
	
	_commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(15.0, 12.0, 232.0, 21.0)];
	[_commentTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_commentTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_commentTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_commentTextField setReturnKeyType:UIReturnKeySend];
	[_commentTextField setTextColor:[UIColor blackColor]];
	[_commentTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	_commentTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
	_commentTextField.keyboardType = UIKeyboardTypeDefault;
	_commentTextField.placeholder = NSLocalizedString(@"enter_comment", @"Comment");
	_commentTextField.text = @"";
	_commentTextField.delegate = self;
	[_inputBGImageView addSubview:_commentTextField];
	
	_submitCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitCommentButton.frame = CGRectMake(262.0, 0.0, 50.0, 44.0);
	_submitCommentButton.titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:17];
	[_submitCommentButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateNormal];
	[_submitCommentButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColorHighlighted] forState:UIControlStateHighlighted];
	[_submitCommentButton setTitleColor:[[HONColorAuthority sharedInstance] honGreyTextColor] forState:UIControlStateDisabled];
	[_submitCommentButton setTitle:NSLocalizedString(@"send_comment", @"Send") forState:UIControlStateNormal];
	[_submitCommentButton setTitle:NSLocalizedString(@"send_comment", @"Send") forState:UIControlStateHighlighted];
	[_submitCommentButton setTitle:NSLocalizedString(@"send_comment", @"Send") forState:UIControlStateDisabled];
	[_submitCommentButton addTarget:self action:@selector(_goCommentReply) forControlEvents:UIControlEventTouchUpInside];
	[_submitCommentButton setEnabled:NO];
	[_inputBGImageView addSubview:_submitCommentButton];
	
	_headerView = [[HONHeaderView alloc] init];
	[self.view addSubview:_headerView];
	
	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeButton.frame = _headerView.frame;
	[closeButton setBackgroundImage:[UIImage imageNamed:@"statusUpdateHeaderButton_nonActive"] forState:UIControlStateNormal];
	[closeButton setBackgroundImage:[UIImage imageNamed:@"statusUpdateHeaderButton_Active"] forState:UIControlStateHighlighted];
	[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:closeButton];
	
	UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
	flagButton.frame = CGRectMake(280.0, 0.0, 44.0, 44.0);
	[flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_nonActive"] forState:UIControlStateNormal];
	[flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_Active"] forState:UIControlStateHighlighted];
	[flagButton addTarget:self action:@selector(_goFlag) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addButton:flagButton];
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
	
	[_scoreLabel toggleLoading:NO];
	[[HONAPICaller sharedInstance] voteStatusUpdateWithStatusUpdateID:_statusUpdateVO.statusUpdateID isUpVote:NO completion:^(NSDictionary *result) {
		_statusUpdateVO.score--;
		_scoreLabel.text = NSStringFromInt(_statusUpdateVO.score);
		[_scoreLabel toggleLoading:YES];
		
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
//	if (_clubVO.distance > _clubVO.postRadius) {
//		[[[UIAlertView alloc] initWithTitle:@"Not in range!"
//									message:[NSString stringWithFormat:@"Must be within %d miles", (int)_clubVO.postRadius]
//								   delegate:nil
//						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
//						  otherButtonTitles:nil] show];
//		_commentTextField.text = @"";
//		
//	} else {
	
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
//	}
}

- (void)_goCancelReply {
	[self _goCollapseComments];
	
	_commentTextField.text = @"";
	if ([_commentTextField isFirstResponder])
		[_commentTextField resignFirstResponder];
}

- (void)_goCollapseComments {
	[_tableView setContentOffset:CGPointZero animated:YES];
	[_commentButton setSelected:NO];
	[UIView animateWithDuration:0.25
					 animations:^(void) {
						 _tableView.frame = CGRectTranslateY(_tableView.frame, self.view.frame.size.height - (([_replies count] > 0) ? 146.0 : 88.0));
//						 _tableView.frame = CGRectTranslateY(_tableView.frame, self.view.frame.size.height - 88.0);
					 } completion:^(BOOL finished) {
					 }];
}

- (void)_goToggleComments {
	BOOL isCollapsing = (_tableView.frame.origin.y == MAX(kNavHeaderHeight, ((self.view.frame.size.height - 88.0) - _tableView.contentSize.height) + [_tableView rectForHeaderInSection:0].size.height));
//	CGFloat offset = (_tableView.frame.origin.y == MAX(kNavHeaderHeight, ((self.view.frame.size.height - 88.0) - _tableView.contentSize.height) + [_tableView rectForHeaderInSection:0].size.height)) ? self.view.frame.size.height - 88.0 : MAX(kNavHeaderHeight, ((self.view.frame.size.height - 88.0) - _tableView.contentSize.height) + [_tableView rectForHeaderInSection:0].size.height);
//	CGFloat offset = (isCollapsing) ? self.view.frame.size.height - 88.0 : (MAX(kNavHeaderHeight, ((self.view.frame.size.height - 88.0) - _tableView.contentSize.height) + [_tableView rectForHeaderInSection:0].size.height)) + 1.0;
	CGFloat offset = (isCollapsing) ? self.view.frame.size.height - (([_replies count] > 0) ? 146.0 : 88.0) : (MAX(kNavHeaderHeight, ((self.view.frame.size.height - 88.0) - _tableView.contentSize.height) + [_tableView rectForHeaderInSection:0].size.height)) + 1.0;

	[_tableView setContentOffset:CGPointZero animated:YES];
	[_commentButton setSelected:!isCollapsing];
	[UIView animateWithDuration:0.25
					 animations:^(void) {
						 _tableView.frame = CGRectTranslateY(_tableView.frame, offset);
					 } completion:^(BOOL finished) {
					 }];
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
	
	if ([_tableView.visibleCells count] > 0)
		[_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
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


#pragma mark - CommentViewCell Delegates
- (void)commentViewCell:(HONCommentViewCell *)cell didDownVoteComment:(HONCommentVO *)commentVO {
	NSLog(@"[*:*] commentViewCell:didDownVoteComment:[%@])", commentVO.dictionary);
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - comment_down"];
	[[HONAPICaller sharedInstance] voteStatusUpdateWithStatusUpdateID:commentVO.commentID isUpVote:NO completion:^(NSDictionary *result) {
		[[HONClubAssistant sharedInstance] writeCommentAsVotedWithID:commentVO.commentID asUpVote:NO];
		commentVO.score--;
		[cell refreshScore];
	}];
}

- (void)commentViewCell:(HONCommentViewCell *)cell didUpVoteComment:(HONCommentVO *)commentVO {
	NSLog(@"[*:*] commentViewCell:didUpVoteComment:[%@])", commentVO.dictionary);
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - comment_up"];
	[[HONAPICaller sharedInstance] voteStatusUpdateWithStatusUpdateID:commentVO.commentID isUpVote:YES completion:^(NSDictionary *result) {
		[[HONClubAssistant sharedInstance] writeCommentAsVotedWithID:commentVO.commentID asUpVote:YES];
		commentVO.score++;
		[cell refreshScore];
	}];
}


#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_replies count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONCommentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONCommentViewCell alloc] init];
	[cell setSize:[tableView rectForRowAtIndexPath:indexPath].size];
	[cell setIndexPath:indexPath];
	cell.delegate = self;
	
	cell.commentVO = (HONCommentVO *)[_replies objectAtIndex:indexPath.row];
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *view = [[UIView alloc] initWithFrame:CGRectFromSize(CGSizeMake(320.0, 44.0))];
	view.backgroundColor = [UIColor whiteColor];
	
	_commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_commentButton.frame = CGRectMake(3.0, 1.0, 44.0, 44.0);
	[_commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_nonActive"] forState:UIControlStateNormal];
	[_commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_Active"] forState:UIControlStateHighlighted];
	[_commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_Selected"] forState:UIControlStateSelected];
	[view addSubview:_commentButton];
	
	if ([_replies count] > 0)
		[_commentButton addTarget:self action:@selector(_goToggleComments) forControlEvents:UIControlEventTouchUpInside];
	
	UILabel *repliesLabel = [[UILabel alloc] initWithFrame:CGRectMake(45.0, 12.0, 280.0, 20.0)];
	repliesLabel.backgroundColor = [UIColor clearColor];
	repliesLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	repliesLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
	repliesLabel.text = NSStringFromInt([_replies count]);
	[view addSubview:repliesLabel];
	
	
	
	return (view);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (74.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (44.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.alpha = 0.0;
	[UIView animateKeyframesWithDuration:0.125 delay:0.050 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
		cell.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_textFieldTextDidChangeChange:)
												 name:UITextFieldTextDidChangeNotification
											   object:textField];
	
	[self _goCollapseComments];
	[UIView animateWithDuration:0.25
					 animations:^(void) {
						 _inputBGImageView.frame = CGRectTranslateY(_inputBGImageView.frame, self.view.frame.size.height - (216.0 + _inputBGImageView.frame.size.height));
					 } completion:^(BOOL finished) {}];
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
