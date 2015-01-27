//
//  HONStatusUpdateViewController.m
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <LayerKit/LayerKit.h>

#import "LYRConversation+BuiltinMenlo.h"
#import "NSCharacterSet+BuiltinMenlo.h"
#import "NSDate+BuiltinMenlo.h"
#import "UIImageView+AFNetworking.h"
#import "UILabel+BuiltinMenlo.h"

#import "HONStatusUpdateViewController.h"
#import "HONReplySubmitViewController.h"
#import "HONCommentItemView.h"
#import "HONImageLoadingView.h"
#import "HONRefreshControl.h"
#import "HONScrollView.h"
#import "HONRefreshingLabel.h"
#import "HONStatusUpdateCreatorView.h"

@interface HONStatusUpdateViewController () <HONStatusUpdateCreatorViewDelegate>
@property (nonatomic, strong) LYRConversation *conversation;
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
//	[[HONAPICaller sharedInstance] retrieveClubByClubID:_clubVO.clubID withOwnerID:_clubVO.ownerID completion:^(NSDictionary *result) {
//		_clubVO = [HONUserClubVO clubWithDictionary:result];
//		[self _retrieveRepliesAtPage:1];
//	}];
	
	
	[[HONAPICaller sharedInstance] retrieveStatusUpdateByStatusUpdateID:_statusUpdateVO.statusUpdateID completion:^(NSDictionary *result) {
		NSError *error = nil;
		LYRQuery *convoQuery = [LYRQuery queryWithClass:[LYRConversation class]];
		convoQuery.predicate = [LYRPredicate predicateWithProperty:@"identifier" operator:LYRPredicateOperatorIsEqualTo value:[_statusUpdateVO.dictionary objectForKey:@"img"]];
		_conversation = [[[[HONLayerKitAssistant sharedInstance] client] executeQuery:convoQuery error:&error] firstObject];
		
		NSLog(@"CONVO: -=- (%@) -=- [%@]\n%@", [_statusUpdateVO.dictionary objectForKey:@"img"], _conversation, _conversation.metadata);
		
		if (!error) {
			if ([_conversation.participants containsObject:NSStringFromInt([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue])]) {
				[[HONLayerKitAssistant sharedInstance] addParticipants:@[NSStringFromInt([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue])] toConversation:_conversation withCompletion:^(BOOL success, NSError *error) {
					if (!success) {
						NSLog(@"Couldn't add me self to the convo!");
					}
					
					LYRQuery *msgsQuery = [LYRQuery queryWithClass:[LYRMessage class]];
					msgsQuery.predicate = [LYRPredicate predicateWithProperty:@"conversation" operator:LYRPredicateOperatorIsEqualTo value:_conversation];
					msgsQuery.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
					
					NSOrderedSet *messages = [[[HONLayerKitAssistant sharedInstance] client] executeQuery:msgsQuery error:&error];
					NSLog(@"QUERY:[%@] -=- %@\n%d", NSStringFromBOOL(error == nil), (error != nil) ? error : @"", [messages count]);
					
					NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(MIN(1, [messages count] - 1), [messages count] - 1)];
					[messages enumerateObjectsAtIndexes:indexSet options:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
						LYRMessage *message = (LYRMessage *)obj;
						NSLog(@"MESSAGE(%d) : [%@] -=- {%@}/{%@}", idx, message.identifierSuffix, [message.sentAt formattedISO8601StringUTC], [message.receivedAt formattedISO8601StringUTC]);
						[_replies addObject:[HONCommentVO commentWithMessage:message]];
					}];
					
					[_conversation markAllMessagesAsRead:nil];
					
//					LYRQueryController *queryController = [[[HONLayerKitAssistant sharedInstance] client] queryControllerWithQuery:msgsQuery];
//					BOOL success2 = [queryController execute:&error];
//					if (!success2) {
//						NSLog(@"Query failed with error: %@", error);
//					} else {
//						NSLog(@"Query fetched %tu message objects", [queryController totalNumberOfObjects]);
//						
//						for (int i=0; i<queryController.numberOfSections; i++) {
//							for (int j=0; j<[queryController numberOfObjectsInSection:i]; j++) {
//								[_replies addObject:[HONCommentVO commentWithMessage:(LYRMessage *)[queryController objectAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]]]];
					
								
//								LYRMessage *message = (LYRMessage *)[queryController objectAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
//								LYRMessagePart *messagePart = [message.parts firstObject];
//								
//								NSDictionary *dict = @{@"id"				: message.identifierSuffix,
//													   @"owner_member"		: @{@"id"	: message.sentByUserID,
//																				@"name"	: message.sentByUserID},
//													   @"img"				: message.identifier,
//													   @"text"				: [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding],
//													   @"net_vote_score"	: @(0),
//													   @"added"				: [message.sentAt formattedISO8601StringUTC],
//													   @"updated"			: [message.sentAt formattedISO8601StringUTC]};
//								
//								[_replies addObject:[HONCommentVO commentWithDictionary:dict]];
//							}
//						}
					
						_statusUpdateVO.replies = [_replies copy];
//					}
					
					[self _didFinishDataRefresh];
				}];
			}
		}
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
			NSLog(@"FINISHED RETRIEVING COMMENTS:[%d]", [_retrievedReplies count]);
			
			[[[_retrievedReplies reverseObjectEnumerator] allObjects] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSMutableDictionary *dict = [(NSDictionary *)obj mutableCopy];
				[dict setValue:@(_statusUpdateVO.clubID) forKey:@"club_id"];
				[dict setValue:@(_statusUpdateVO.statusUpdateID) forKey:@"parent_id"];
				
				[_replies addObject:[HONCommentVO commentWithDictionary:dict]];
			}];
			
			_statusUpdateVO.replies = [_replies copy];
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
		}
	}];
	
	NSDictionary *alertDict = ([[_conversation.metadata objectForKey:@"creator_id"] intValue] != [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? @{LYRMessageOptionsPushNotificationAlertKey: [NSString stringWithFormat:@"%@ says “%@”", [[HONAppDelegate infoForUser] objectForKey:@"username"], _comment]} : nil;
	
	// Creates a message part with a text/plain MIMEType and returns a new message object with the given conversation and array of message parts - Sends the specified message
	NSError *error = nil;
	LYRMessage *message = [[[HONLayerKitAssistant sharedInstance] client] newMessageWithParts:@[[LYRMessagePart messagePartWithMIMEType:kMIMETypeTextPlain data:[_comment dataUsingEncoding:NSUTF8StringEncoding]]] options:alertDict error:&error];
	NSLog (@"MESSAGE OBJ:[%@]", message.identifier);
	
	BOOL success = [_conversation sendMessage:message error:&error];
	NSLog (@"MESSAGE RESULT:- %@ -=- %@", NSStringFromBOOL(success), error);
	
	_isSubmitting = NO;
	
	
//	if (success)
//		[self _appendComment:[HONCommentVO commentWithMessage:message]];
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
	
	if (![_refreshControl isRefreshing])
		[_refreshControl beginRefreshing];

	[self _goReloadContent];
}

- (void)_goReloadContent {
	[_commentsHolderView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONCommentItemView *view = (HONCommentItemView *)obj;
		[view removeFromSuperview];
	}];
	
	_commentsHolderView.frame = CGRectResizeHeight(_commentsHolderView.frame, 0.0);
	_scrollView.contentSize = CGRectResizeHeight(_scrollView.frame, 0.0).size;
	
	_retrievedReplies = [NSMutableArray array];
	_replies = [NSMutableArray array];
	
	[self _retrieveStatusUpdate];
}

- (void)_didFinishDataRefresh {
	if ([_refreshControl isRefreshing])
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
	
	
	_creatorView = [[HONStatusUpdateCreatorView alloc] initWithStatusUpdateVO:_statusUpdateVO];
	_creatorView.delegate = self;
	[self.view addSubview:_creatorView];
	
	
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
	[_submitCommentButton addTarget:self action:@selector(_goCommentFocus) forControlEvents:UIControlEventTouchUpInside];
	[_inputBGImageView addSubview:_submitCommentButton];
	
	_commentCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_commentCloseButton.frame = CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - (kNavHeaderHeight + 260.0));
	[_commentCloseButton addTarget:self action:@selector(_goCancelReply) forControlEvents:UIControlEventTouchUpInside];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"Conversation"];
	[_headerView addBackButtonWithTarget:self action:@selector(_goBack)];
	//[_headerView addFlagButtonWithTarget:self action:@selector(_goFlag)];
	[self.view addSubview:_headerView];

}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
	[_scrollView setContentOffset:CGPointMake(0.0, -95.0) animated:NO];
	[self _goReloadContent];
	
	/* ~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~ */
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_clientObjectsDidChangeNotification:)
												 name:LYRClientObjectsDidChangeNotification object:nil];
	/* ~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~ */
	// --=#=--#=--#=-=#=-#=--=#--=#--=#=-- //
	/* ~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~ */
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_conversationDidReceiveTypingIndicatorNotification:)
												 name:LYRConversationDidReceiveTypingIndicatorNotification object:nil];
	/* ~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~ */
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


- (void)_goCommentFocus {
	if (![_commentTextField isFirstResponder])
		[_commentTextField becomeFirstResponder];
}

- (void)_goCommentSubmit {
	_isSubmitting = YES;
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - comment"];
	
	_comment = _commentTextField.text;
	_commentTextField.text = @"";
	
	[self _submitCommentReply];
}

- (void)_goCancelReply {
	_commentTextField.text = @"";
	if ([_commentTextField isFirstResponder])
		[_commentTextField resignFirstResponder];
	
	[UIView animateWithDuration:0.25
					 animations:^(void) {
						 _creatorView.frame = CGRectTranslateY(_creatorView.frame, kNavHeaderHeight);
						 _scrollView.frame = CGRectTranslateY(_scrollView.frame, kNavHeaderHeight + 84.0);
						 _inputBGImageView.frame = CGRectTranslateY(_inputBGImageView.frame, self.view.frame.size.height - 44.0);
					 } completion:^(BOOL finished) {
						 [_commentCloseButton removeFromSuperview];
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

- (void)_clientObjectsDidChangeNotification:(NSNotification *)notification {
	NSLog (@"::|>_clientObjectsDidChangeNotification:%@\n[=-=-=-=-=-=-=-=]\n", notification);
	
	NSArray *changes = [notification.userInfo objectForKey:LYRClientObjectChangesUserInfoKey];
	for (NSDictionary *change in changes) {
		LYRObjectChangeType updateKey = (LYRObjectChangeType)[[change objectForKey:LYRObjectChangeTypeKey] integerValue];
		
		if ([[change objectForKey:LYRObjectChangeObjectKey] isKindOfClass:[LYRConversation class]]) {
			// Object is a conversation
		}
		
		if ([[change objectForKey:LYRObjectChangeObjectKey]isKindOfClass:[LYRMessage class]]) {
			LYRMessage *message = (LYRMessage *)[change objectForKey:LYRObjectChangeObjectKey];
			NSLog(@"Message Update:(%@) -=- %@", (updateKey == LYRObjectChangeTypeCreate) ? @"Create" : (updateKey == LYRObjectChangeTypeUpdate) ? @"Update" : (updateKey == LYRObjectChangeTypeDelete) ? @"Delete" : @"UNKNOWN", message.identifierSuffix);
			
			if (updateKey == LYRObjectChangeTypeCreate) {
				[self _appendComment:[HONCommentVO commentWithMessage:message]];
				
			} else if (updateKey == LYRObjectChangeTypeUpdate) {
				
				__block int ind = -1;
				[_replies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
					HONCommentVO *vo = (HONCommentVO *)obj;
					
					if ([vo.messageID isEqualToString:message.identifierSuffix]) {
						ind = idx;
						*stop = YES;
					}
				}];
				
				
				if (ind > -1) {
//					[NSMutableArray arrayWithArray:[[message recipientStatusByUserID]
//													sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]];
//
//
					LYRRecipientStatus status = [[HONLayerKitAssistant sharedInstance] latestRecipientStatusForMessage:message];
					
					
					NSLog(@"LAST STATUS:%d", [[HONLayerKitAssistant sharedInstance] latestRecipientStatusForMessage:message]);
					
					HONCommentItemView *itemView = (HONCommentItemView *)[_commentsHolderView.subviews objectAtIndex:ind];
					[itemView updateStatus:(status == LYRRecipientStatusSent) ? HONCommentStatusTypeSent : (status == LYRRecipientStatusDelivered) ? HONCommentStatusTypeDelivered : (status == LYRRecipientStatusRead) ? HONCommentStatusTypeSeen : HONCommentStatusTypeUnknown];
				}
					
				
				
			} else if (updateKey == LYRObjectChangeTypeDelete) {
				
			}
		}
	}
	
}

- (void)_conversationDidReceiveTypingIndicatorNotification:(NSNotification *)notification {
	NSLog (@"::|>_conversationDidReceiveTypingIndicatorNotification:%@\n[=-=-=-=-=-=-=-=]\n", notification);
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
	
	if (_scrollView.contentSize.height > _scrollView.frame.size.height)
		[_scrollView setContentOffset:CGPointMake(0.0, (_scrollView.contentSize.height - _scrollView.frame.size.height) + _scrollView.contentInset.bottom) animated:YES];
}

- (void)_appendComment:(HONCommentVO *)vo {
	[_replies addObject:vo];
	
	_commentsHolderView.frame = CGRectExtendHeight(_commentsHolderView.frame, 90.0);
	_scrollView.contentSize = _commentsHolderView.frame.size;
	
//	if (_scrollView.contentSize.height > _scrollView.frame.size.height)
//		[_scrollView setContentOffset:CGPointMake(0.0, (_scrollView.contentOffset.y - 90.0) + _scrollView.contentInset.bottom) animated:YES];
	
	if (_scrollView.contentSize.height > _scrollView.frame.size.height)
		[_scrollView setContentOffset:CGPointMake(0.0, (_scrollView.contentSize.height - _scrollView.frame.size.height) + _scrollView.contentInset.bottom) animated:YES];
	
	
	HONCommentItemView *itemView = [[HONCommentItemView alloc] initWithFrame:CGRectMake(0.0, 33.0 + (90.0 * ([_replies count] - 1)), 320.0, 90.0)];
	itemView.alpha = 0.0;
	itemView.commentVO = vo;
	[_commentsHolderView addSubview:itemView];
	
	[UIView animateKeyframesWithDuration:0.25 delay:0.00 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
		itemView.alpha = 1.0;
		itemView.frame = CGRectTranslateY(itemView.frame, 90.0 * ([_replies count] - 1));
	} completion:^(BOOL finished) {
	}];
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
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - down_vote"];
}

- (void)statusUpdateCreatorViewDidUpVote:(HONStatusUpdateCreatorView *)statusUpdateCreatorView {
	NSLog(@"[*:*] statusUpdateCreatorViewDidUpVote [*:*]");
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - up_vote"];
	
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
						 _creatorView.frame = CGRectTranslateY(_creatorView.frame, kNavHeaderHeight - _creatorView.frame.size.height);
						 _scrollView.frame = (_scrollView.frame.origin.y >= kNavHeaderHeight + 84.0) ? CGRectTranslateY(_scrollView.frame, (_scrollView.contentSize.height < (216.0 + _inputBGImageView.frame.size.height) ? _scrollView.frame.origin.y : _scrollView.frame.origin.y - (216.0 + _inputBGImageView.frame.size.height))) : CGRectTranslateY(_scrollView.frame, 0.0);
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
	
	if (!_isSubmitting && [textField.text length] > 0)
		[self _goCommentSubmit];
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
