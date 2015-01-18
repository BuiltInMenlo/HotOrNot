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

@interface HONStatusUpdateViewController () <HONStatusUpdateCreatorViewDelegate>
@property (nonatomic, strong) HONStatusUpdateVO *statusUpdateVO;
@property (nonatomic, strong) HONUserClubVO *clubVO;
@property (nonatomic, strong) HONScrollView *scrollView;
@property (nonatomic, strong) HONRefreshControl *refreshControl;
@property (nonatomic, strong) HONStatusUpdateCreatorView *creatorView;

@property (nonatomic, strong) UIButton *commentCloseButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) NSMutableArray *retrievedReplies;
@property (nonatomic, strong) NSMutableArray *replies;
@property (nonatomic, strong) UIView *commentsHolderView;
@property (nonatomic, strong) UIImageView *inputBGImageView;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UIButton *submitCommentButton;
@property (nonatomic, strong) NSString *comment;

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
	
	[_creatorView refreshScore];
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
	//[_headerView addFlagButtonWithTarget:self action:@selector(_goFlag)];
	[self.view addSubview:_headerView];
	
	
	_creatorView = [[HONStatusUpdateCreatorView alloc] initWithStatusUpdateVO:_statusUpdateVO];
	_creatorView.delegate = self;
	[self.view addSubview:_creatorView];
	

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
	
	_comment = @"";
	
	_inputBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commentInputBG"]];
	_inputBGImageView.frame = CGRectOffset(_inputBGImageView.frame, 0.0, self.view.frame.size.height - 44.0);
	_inputBGImageView.userInteractionEnabled = YES;
	[self.view addSubview:_inputBGImageView];
	
	_commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(15.0, 11.0, 232.0, 22.0)];
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
	_submitCommentButton.frame = CGRectMake(270.0, 0.0, 44.0, 44.0);
	[_submitCommentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_nonActive"] forState:UIControlStateNormal];
	[_submitCommentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_Active"] forState:UIControlStateHighlighted];
	[_submitCommentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_Disabled"] forState:UIControlStateDisabled];
	[_submitCommentButton addTarget:self action:@selector(_goCommentToggle) forControlEvents:UIControlEventTouchUpInside];
	[_inputBGImageView addSubview:_submitCommentButton];
	
	_commentCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_commentCloseButton.frame = CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - (kNavHeaderHeight + 260.0));
	_commentCloseButton.backgroundColor = [[HONColorAuthority sharedInstance] honDebugDefaultColor];
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


- (void)_goCommentToggle {
	if (![_commentTextField isFirstResponder])
		[_commentTextField becomeFirstResponder];
	
	else
		[_commentTextField resignFirstResponder];
}

- (void)_goCommentSubmit {
	_isSubmitting = YES;
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - comment"];
	
	if ([_commentTextField isFirstResponder])
		[_commentTextField resignFirstResponder];
	
	NSLog(@"DIST:[%.04f] RADIUS:[%.04f]", _clubVO.distance, _clubVO.postRadius);
	
	_comment = _commentTextField.text;
	_commentTextField.text = @"";
	_overlayView = [[UIView alloc] initWithFrame:self.view.frame];
	_overlayView.backgroundColor = [UIColor colorWithWhite:0.00 alpha:0.75];
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


#pragma mark - StatusUpdateCreatorView Delegates
- (void)statusUpdateCreatorViewDidDownVote:(HONStatusUpdateCreatorView *)statusUpdateCreatorView {
	NSLog(@"[*:*] statusUpdateCreatorViewDidDownVote [*:*]");
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - details_down"];
}

- (void)statusUpdateCreatorViewDidUpVote:(HONStatusUpdateCreatorView *)statusUpdateCreatorView {
	NSLog(@"[*:*] statusUpdateCreatorViewDidUpVote [*:*]");
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - details_up"];
	
//	[[NSNotificationCenter defaultCenter] postNotificationName:@"PLAY_OVERLAY_ANIMATION" object:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"likeOverlay"]]];
}

- (void)statusUpdateCreatorViewOpenAppStore:(HONStatusUpdateCreatorView *)statusUpdateCreatorView {
	NSLog(@"[*:*] statusUpdateCreatorViewOpenAppStore [*:*]");
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:_statusUpdateVO.appStoreURL]];
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
						 if (!_isSubmitting && [textField.text length] > 0)
							 [self _goCommentSubmit];
					 }];
}

- (void)_onTextEditingDidEnd:(id)sender {
	NSLog(@"[*:*] _onTextEditingDidEnd:[%@]", _commentTextField.text);
	
	if (!_isSubmitting && [_commentTextField.text length] > 0)
		[self _goCommentSubmit];
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
