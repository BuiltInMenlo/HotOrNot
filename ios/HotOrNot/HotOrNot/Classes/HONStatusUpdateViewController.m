//
//  HONStatusUpdateViewController.m
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <LayerKit/LayerKit.h>

#import "NSArray+BuiltinMenlo.h"
#import "NSCharacterSet+BuiltinMenlo.h"
#import "NSDate+BuiltinMenlo.h"
#import "NSDictionary+BuiltinMenlo.h"
#import "NSString+BuiltinMenlo.h"
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
@property (nonatomic, strong) PNChannel *channel;
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
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UILabel *typingStatusLabel;
@property (nonatomic, strong) UIImageView *inputBGImageView;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UIButton *imageCommentButton;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) UIView *emptyCommentsView;
@property (nonatomic, strong) NSTimer *expireTimer;
@property (nonatomic, strong) UILabel *expireLabel;

@property (nonatomic) BOOL isSubmitting;
@property (nonatomic) BOOL isActive;
@property (nonatomic) int expireSeconds;

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
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_appEnteringBackground:)
													 name:@"APP_ENTERING_BACKGROUND" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_appLeavingBackground:)
													 name:@"APP_LEAVING_BACKGROUND" object:nil];
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
	[[HONAPICaller sharedInstance] retrieveStatusUpdateByStatusUpdateID:_statusUpdateVO.statusUpdateID completion:^(NSDictionary *result) {
		
		_channel = [PNChannel channelWithName:[NSString stringWithFormat:@"%d_%d", _statusUpdateVO.userID, _statusUpdateVO.statusUpdateID] shouldObservePresence:YES];
		[PubNub subscribeOnChannel:_channel];
		
		NSLog(@"PARTICIPANTS:[%lu]", (unsigned long)_channel.participantsCount);
		
		if (_channel.participantsCount < 2) {
			_emptyCommentsView.hidden = NO;
			_expireTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
															target:self selector:@selector(_updateExpireTime)
														  userInfo:nil
														   repeats:YES];
		}
		
		[[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
			
			switch (state) {
				case PNSubscriptionProcessSubscribedState:
					NSLog(@"OBSERVER: Subscribed to Channel: %@", channels[0]);
					break;
					
				case PNSubscriptionProcessNotSubscribedState:
					NSLog(@"OBSERVER: Not subscribed to Channel: %@, Error: %@", channels[0], error);
					break;
					
				case PNSubscriptionProcessWillRestoreState:
					NSLog(@"OBSERVER: Will re-subscribe to Channel: %@", channels[0]);
					break;
					
				case PNSubscriptionProcessRestoredState:
					NSLog(@"OBSERVER: Re-subscribed to Channel: %@", channels[0]);
					break;
			}
		}];
		
		// Observer looks for message received events
		[[PNObservationCenter defaultCenter] addMessageReceiveObserver:self withBlock:^(PNMessage *message) {
			NSLog(@"OBSERVER: Channel: %@, Message: %@", message.channel.name, message.message);
			
			NSMutableDictionary *dict = [@{@"id"				: message.message,
										   @"msg_id"			: message.message,
										   
										   @"owner_member"		: @{@"id"	: @([[HONUserAssistant sharedInstance] activeUserID]),
																	@"name"	: [[HONUserAssistant sharedInstance] activeUsername]},
										   
										   @"img"				: message.message,
										   @"text"				: message.message,
										   
										   @"net_vote_score"	: @(0),
										   @"status"			: NSStringFromInt(0),
										   @"added"				: (message.date != nil) ? [message.date.date formattedISO8601String] : [NSDate stringFormattedISO8601],
										   @"updated"			: (message.date != nil) ? [message.date.date formattedISO8601String] : [NSDate stringFormattedISO8601]} mutableCopy];
			
			
			[self _appendComment:[HONCommentVO commentWithDictionary:dict]];
		}];
		
		[[PNObservationCenter defaultCenter] addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
			switch (state) {
				case PNMessageSent:
					NSLog(@"OBSERVER: Message Sent.");
					break;
					
				case PNMessageSending:
					NSLog(@"OBSERVER: Sending Message...");
					break;
					
				case PNMessageSendingError:
					NSLog(@"OBSERVER: ERROR: Failed to Send Message.");
					break;
					
				default:
					break;
			}
		}];
		
		_statusUpdateVO.replies = [_replies copy];
		[self _didFinishDataRefresh];

	}];
}

- (void)_submitCommentReply:(BOOL)isText {
	NSDictionary *dict = @{@"user_id"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
						   @"img_url"		: [[HONClubAssistant sharedInstance] defaultStatusUpdatePhotoURL],
						   @"club_id"		: @(_clubVO.clubID),
						   @"subject"		: (isText) ? _comment : @"emoji",
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
	
	// Send a goodbye message
	[PubNub sendMessage:_comment toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
		if (messageState == PNMessageSent) {
		}
	}];
	
//	NSString *pushContent = (isText) ? [NSString stringWithFormat:@"%@ says “%@”", [[HONUserAssistant sharedInstance] activeUsername], _comment] : [NSString stringWithFormat:@"%@ posted an image", [[HONUserAssistant sharedInstance] activeUsername]];
//	LYRMessagePart *messagePart = (isText) ? [LYRMessagePart messagePartWithMIMEType:kMIMETypeTextPlain data:[_comment dataUsingEncoding:NSUTF8StringEncoding]] : [LYRMessagePart messagePartWithMIMEType:kMIMETypeImagePNG data:UIImagePNGRepresentation([UIImage imageNamed:@"emojiMessage-001"])];
//	
//	NSError *error = nil;
//	LYRMessage *message = [[[HONLayerKitAssistant sharedInstance] client] newMessageWithParts:@[messagePart] options:((_conversation.creatorID != [[HONUserAssistant sharedInstance] activeUserID]) ? @{LYRMessageOptionsPushNotificationAlertKey: pushContent} : nil) error:&error];
//	NSLog (@"MESSAGE OBJ:[%@]", message.identifier);
//	
//	BOOL success = [_conversation sendMessage:message error:&error];
//	NSLog (@"MESSAGE RESULT:- %@ -=- %@", NSStringFromBOOL(success), error);
	
	_isSubmitting = NO;
}

- (void)_flagStatusUpdate {
	NSDictionary *dict = @{@"user_id"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
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
	
//	_typingStatusLabel.text = NSLocalizedString(@"loading_status", @"loading…");
//	[UIView animateWithDuration:0.125
//					 animations:^(void) {
//						 _typingStatusLabel.alpha = 1.0;
//					 } completion:^(BOOL finished) {
//					 }];
	
	[self _retrieveStatusUpdate];
}

- (void)_didFinishDataRefresh {
	if ([_refreshControl isRefreshing])
		[_refreshControl endRefreshing];
	
	[_creatorView refreshScore];
	[self _makeComments];
	
	[UIView animateWithDuration:0.125
					 animations:^(void) {
						 _typingStatusLabel.alpha = 0.0;
					 } completion:^(BOOL finished) {
						 _typingStatusLabel.text = NSLocalizedString(@"typing_status", @"someone is typing…");
					 }];
	
	
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
	
	_emptyCommentsView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 148.0, 320.0, 500.0)];
	_emptyCommentsView.hidden = YES;
	[self.view addSubview:_emptyCommentsView];
	
	_expireLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 70.0, 260.0, 40.0)];
	_expireLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:17];
	_expireLabel.backgroundColor = [UIColor clearColor];
	_expireLabel.textColor = [UIColor blackColor];
	_expireLabel.numberOfLines = 2;
	_expireLabel.textAlignment = NSTextAlignmentCenter;
	_expireLabel.text = @"";
	[_emptyCommentsView addSubview:_expireLabel];
	
	UIButton *copyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	copyButton.frame = CGRectMake(60.0, 180.0, 160.0, 44.0);
	copyButton.backgroundColor = [UIColor redColor];
	[copyButton addTarget:self action:@selector(_goCopyDeeplink) forControlEvents:UIControlEventTouchUpInside];
	//[_emptyCommentsView addSubview:copyButton];
	
	UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareButton.frame = CGRectMake(60.0, 220.0, 160.0, 44.0);
	shareButton.backgroundColor = [UIColor greenColor];
	[shareButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	//[_emptyCommentsView addSubview:shareButton];
	
	
	_isActive = YES;
	_comment = @"";
	_expireSeconds = 600;
	_footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 64.0, 320.0, 64.0)];
	[self.view addSubview:_footerView];
	
	_typingStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0, 0.0, 120.0, 16.0)];
	_typingStatusLabel.font = [[[HONFontAllocator sharedInstance] cartoGothicItalic] fontWithSize:12];
	_typingStatusLabel.backgroundColor = [UIColor clearColor];
	_typingStatusLabel.textColor = [[HONColorAuthority sharedInstance] percentGreyscaleColor:0.75];
	_typingStatusLabel.alpha = 0.0;
	[_footerView addSubview:_typingStatusLabel];
	
	_inputBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commentInputBG"]];
	_inputBGImageView.frame = CGRectOffsetY(_inputBGImageView.frame, 20.0);
	_inputBGImageView.userInteractionEnabled = YES;
	[_footerView addSubview:_inputBGImageView];
	
	_commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(15.0, 11.0, 232.0, 22.0)];
	[_commentTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_commentTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_commentTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_commentTextField setReturnKeyType:UIReturnKeySend];
	[_commentTextField setTextColor:[UIColor blackColor]];
	[_commentTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	_commentTextField.font = [[[HONFontAllocator sharedInstance] cartoGothicBook] fontWithSize:18];
	_commentTextField.keyboardType = UIKeyboardTypeDefault;
	_commentTextField.placeholder = NSLocalizedString(@"enter_comment", @"Comment");
	_commentTextField.text = @"";
	_commentTextField.delegate = self;
	[_inputBGImageView addSubview:_commentTextField];
	
	_imageCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_imageCommentButton.frame = CGRectMake(270.0, 0.0, 44.0, 44.0);
	[_imageCommentButton setBackgroundImage:[UIImage imageNamed:@"emojiButton_nonActive"] forState:UIControlStateNormal];
	[_imageCommentButton setBackgroundImage:[UIImage imageNamed:@"emojiButton_Active"] forState:UIControlStateHighlighted];
	[_imageCommentButton addTarget:self action:@selector(_goImageComment) forControlEvents:UIControlEventTouchUpInside];
	[_inputBGImageView addSubview:_imageCommentButton];
	
	_commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_commentButton.frame = CGRectMake(260.0, 0.0, 64.0, 44.0);
	[_commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_nonActive"] forState:UIControlStateNormal];
	[_commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_Active"] forState:UIControlStateHighlighted];
	[_commentButton addTarget:self action:@selector(_goTextComment) forControlEvents:UIControlEventTouchUpInside];
	_commentButton.hidden = YES;
	[_inputBGImageView addSubview:_commentButton];
	
	_commentCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_commentCloseButton.frame = CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - (kNavHeaderHeight + 260.0));
	[_commentCloseButton addTarget:self action:@selector(_goCancelComment) forControlEvents:UIControlEventTouchUpInside];
	
	_headerView = [[HONHeaderView alloc] init];
	[_headerView addBackButtonWithTarget:self action:@selector(_goBack)];
//	[_headerView addFlagButtonWithTarget:self action:@selector(_goFlag)];
	[_headerView addMoreButtonWithTarget:self action:@selector(_goMore)];
	[self.view addSubview:_headerView];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
	[_scrollView setContentOffset:CGPointMake(0.0, -95.0) animated:NO];
	[self _goReloadContent];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_clientObjectsDidChangeNotification:)
												 name:LYRClientObjectsDidChangeNotification object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_conversationDidReceiveTypingIndicatorNotification:)
												 name:LYRConversationDidReceiveTypingIndicatorNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:animated:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidDisappear:animated:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewDidDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:LYRClientObjectsDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:LYRConversationDidReceiveTypingIndicatorNotification object:nil];
}


#pragma mark - Navigation
- (void)_goBack {
	if (_expireTimer != nil) {
		[_expireTimer invalidate];
		_expireTimer = nil;
	}
	
	if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"back_chat"] isEqualToString:@"YES"]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
															message:@"This will delete your conversation."
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
												  otherButtonTitles:NSLocalizedString(@"alert_ok", nil), nil];
		[alertView setTag:1];
		[alertView show];
	
	} else {
		[[UIApplication sharedApplication] cancelAllLocalNotifications];
		
		UIView *matteView = [[UIView alloc] initWithFrame:CGRectFromSize(CGSizeMake(84.0, 44.0))];
		matteView.backgroundColor = [UIColor colorWithRed:0.361 green:0.898 blue:0.576 alpha:1.00];
		[_headerView addSubview:matteView];
		
		UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		activityIndicatorView.frame = CGRectOffset(activityIndicatorView.frame, 11.0, 11.0);
		[activityIndicatorView startAnimating];
		[_headerView addSubview:activityIndicatorView];
		
		UILabel *backLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 11.0, 120.0, 20.0)];
		backLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:17];
		backLabel.backgroundColor = [UIColor clearColor];
		backLabel.textColor = [UIColor whiteColor];
		backLabel.text = @"Deleting…";
		[_headerView addSubview:backLabel];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSDictionary *dict = @{@"user_id"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
								   @"img_url"		: [[HONClubAssistant sharedInstance] defaultStatusUpdatePhotoURL],
								   @"club_id"		: @(_statusUpdateVO.clubID),
								   @"subject"		: @"__DELETE__",
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
		});
		
		dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, 1.125 * NSEC_PER_SEC);
		dispatch_after(dispatchTime, dispatch_get_main_queue(), ^(void) {
			[self.navigationController popViewControllerAnimated:YES];
//			[self dismissViewControllerAnimated:NO completion:^(void) {
//			}];
		});
	}
}


- (void)_goMore {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"share"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"share"];
	
	[[NSUserDefaults standardUserDefaults] setObject:@{@"deeplink"	: [NSString stringWithFormat:@"dood://%d", _statusUpdateVO.statusUpdateID]} forKey:@"share"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[HONSocialCoordinator sharedInstance] presentActionSheetForSharingWithMetaData:@{@"deeplink"	: [NSString stringWithFormat:@"dood://%d", _statusUpdateVO.statusUpdateID]}];
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

- (void)_goCopyDeeplink {
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = [NSString stringWithFormat:@"Get Derp - A live photo feed of who is doing what around you. getdood.com/%d", _statusUpdateVO.statusUpdateID];
}

- (void)_goShare {
	[[NSUserDefaults standardUserDefaults] setObject:@{@"deeplink"	: [NSString stringWithFormat:@"dood://%d", _statusUpdateVO.statusUpdateID]} forKey:@"share"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[HONSocialCoordinator sharedInstance] presentActionSheetForSharingWithMetaData:@{@"deeplink"	: [NSString stringWithFormat:@"dood://%d", _statusUpdateVO.statusUpdateID]}];
}

- (void)_goDownload {
	
}


- (void)_goImageComment {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - emoji"];
	
	if (_channel.participantsCount >= 10) {
		_isSubmitting = YES;
		
		_commentTextField.text = @"";
		_comment = @"0123456789";
		
		[self _submitCommentReply:NO];
		
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Emoji board unlocked when chat has more than 10 friends"
															message:nil
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
												  otherButtonTitles:nil, nil];
		[alertView setTag:3];
		[alertView show];
	}
}

- (void)_goTextComment {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - comment"];
	
	if (_channel.participantsCount > 1) {
		_isSubmitting = YES;
		[_commentButton setEnabled:NO];
		
		_comment = _commentTextField.text;
		_commentTextField.text = @"";
		
		[self _submitCommentReply:YES];
	
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You need some users in chat before you can type"
															message:nil
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
												  otherButtonTitles:@"Share", nil];
		[alertView setTag:2];
		[alertView show];
	}
}

- (void)_goCancelComment {
	_commentTextField.text = @"";
	if ([_commentTextField isFirstResponder])
		[_commentTextField resignFirstResponder];
	
	[UIView animateWithDuration:0.25
					 animations:^(void) {
						 _creatorView.frame = CGRectTranslateY(_creatorView.frame, kNavHeaderHeight);
						 _scrollView.frame = CGRectTranslateY(_scrollView.frame, kNavHeaderHeight + 84.0);
						 _footerView.frame = CGRectTranslateY(_footerView.frame, self.view.frame.size.height - _footerView.frame.size.height);
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
	

}

- (void)_tareStatusUpdate:(NSNotification *)notification {
	NSLog(@"::|> _tareStatusUpdate <|::");
	
	[_scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)_appEnteringBackground:(NSNotification *)notification {
	_isActive = NO;
}

- (void)_appLeavingBackground:(NSNotification *)notification {
	_isActive = YES;
}


- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
	//	NSLog(@"UITextFieldTextDidChangeNotification:[%@]", [notification object]);
	
#if __APPSTORE_BUILD__ == 0
	if ([_commentTextField.text isEqualToString:@"¡"]) {
		_commentTextField.text = [[[HONDeviceIntrinsics sharedInstance] phoneNumber] substringFromIndex:2];
	}
#endif
	
	_imageCommentButton.hidden = ([_commentTextField.text length] > 0);
	[_imageCommentButton setEnabled:(_channel.participantsCount >= 10)];
	
	_commentButton.hidden = ([_commentTextField.text length] == 0);
	[_commentButton setEnabled:([_commentTextField.text length] > 0)];
//	[_conversation sendTypingIndicator:LYRTypingDidBegin];
}

- (void)_clientObjectsDidChangeNotification:(NSNotification *)notification {
//	NSLog (@"::|>_clientObjectsDidChangeNotification:%@\n[=-=-=-=-=-=-=-=]\n", notification);
	
	NSArray *changes = [notification.userInfo objectForKey:LYRClientObjectChangesUserInfoKey];
	for (NSDictionary *change in changes) {
		LYRObjectChangeType updateKey = (LYRObjectChangeType)[[change objectForKey:LYRObjectChangeTypeKey] integerValue];
		
		if ([[change objectForKey:LYRObjectChangeObjectKey] isKindOfClass:[LYRConversation class]]) {
			// Object is a conversation
		}
		
		if ([[change objectForKey:LYRObjectChangeObjectKey]isKindOfClass:[LYRMessage class]]) {
			LYRMessage *message = (LYRMessage *)[change objectForKey:LYRObjectChangeObjectKey];
			
			if ([message.conversation.identifierSuffix isEqualToString:_conversation.identifierSuffix]) {
				NSLog(@"Message Update:(%@) -=- %@", (updateKey == LYRObjectChangeTypeCreate) ? @"Create" : (updateKey == LYRObjectChangeTypeUpdate) ? @"Update" : (updateKey == LYRObjectChangeTypeDelete) ? @"Delete" : @"UNKNOWN", message.identifierSuffix);
				
				if (updateKey == LYRObjectChangeTypeCreate) {
					[message markAsRead:nil];
					
					[self _appendComment:[HONCommentVO commentWithMessage:message]];
					
				} else if (updateKey == LYRObjectChangeTypeUpdate) {
					
					__block int ind = -1;
					[_replies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
						HONCommentVO *vo = (HONCommentVO *)obj;
						
						if ([vo.messageID isEqualToString:message.identifierSuffix]) {
							ind = (int)idx;
							*stop = YES;
						}
					}];
					
					
					if (ind > -1) {
						HONCommentItemView *itemView = (HONCommentItemView *)[_commentsHolderView.subviews objectAtIndex:ind];
						LYRRecipientStatus status = [[HONLayerKitAssistant sharedInstance] latestRecipientStatusForMessage:message];
						[itemView updateStatus:(status == LYRRecipientStatusSent) ? HONCommentStatusTypeSent : (status == LYRRecipientStatusDelivered) ? HONCommentStatusTypeDelivered : (status == LYRRecipientStatusRead) ? HONCommentStatusTypeSeen : HONCommentStatusTypeUnknown];
					}
						
					
				} else if (updateKey == LYRObjectChangeTypeDelete) {
					
				}
			}
		}
	}
}

- (void)_conversationDidReceiveTypingIndicatorNotification:(NSNotification *)notification {
	NSLog (@"::|>_conversationDidReceiveTypingIndicatorNotification:%@\n[=-=-=-=-=-=-=-=]\n", notification.userInfo);
	
	LYRConversation *conversation = (LYRConversation *)[notification object];
	if ([conversation.identifierSuffix isEqualToString:_conversation.identifierSuffix]) {
		
//		NSString *participantID = [notification.userInfo objectForKey:LYRTypingIndicatorParticipantUserInfoKey];
		LYRTypingIndicator typingIndicator = [notification.userInfo[LYRTypingIndicatorValueUserInfoKey] unsignedIntegerValue];
		
		[UIView animateWithDuration:0.125
						 animations:^(void) {
							 _typingStatusLabel.alpha = (typingIndicator == LYRTypingDidBegin);
						 } completion:^(BOOL finished) {
						 }];
	}
}


#pragma mark - UI Presentation
- (void)_makeComments {
//	_commentsHolderView.frame = CGRectExtendHeight(_commentsHolderView.frame, [_replies count] * 90.0);
	
	__block CGFloat lastBottom = _commentsHolderView.frame.size.height;
	[_replies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONCommentItemView *itemView = [[HONCommentItemView alloc] initWithFrame:CGRectMake(0.0, lastBottom, 320.0, 90.0)];
		itemView.alpha = 0.0;
		itemView.commentVO = (HONCommentVO *)obj;
		[_commentsHolderView addSubview:itemView];
		
		lastBottom += itemView.frame.size.height;
		_commentsHolderView.frame = CGRectExtendHeight(_commentsHolderView.frame, itemView.frame.size.height);
		
		[UIView animateKeyframesWithDuration:0.25 delay:(0.125 * ([_replies count] - idx)) options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
			itemView.alpha = 1.0;
		} completion:^(BOOL finished) {
		}];
	}];
	
	_scrollView.contentSize = _commentsHolderView.frame.size;
	
	if (_scrollView.contentSize.height > _scrollView.frame.size.height)
		[_scrollView setContentOffset:CGPointMake(0.0, (_scrollView.contentSize.height - _scrollView.frame.size.height) + _scrollView.contentInset.bottom) animated:NO];
}

- (void)_appendComment:(HONCommentVO *)vo {
	
	if ([vo.textContent isEqualToString:@"0123456789"]) {
		vo.commentContentType = HONCommentContentTypeImage;
		vo.imageContent = [UIImage imageNamed:@"fpo_emotionButton_nonActive"];
		vo.textContent = @"";
	}
	
	
	[_replies addObject:vo];
	
	HONCommentItemView *itemView = [[HONCommentItemView alloc] initWithFrame:CGRectMake(0.0, 33.0 + _commentsHolderView.frame.size.height, 320.0, 90.0)];
	itemView.alpha = 0.0;
	itemView.commentVO = vo;
	[_commentsHolderView addSubview:itemView];
	
	_commentsHolderView.frame = CGRectExtendHeight(_commentsHolderView.frame, itemView.frame.size.height);
	_scrollView.contentSize = _commentsHolderView.frame.size;
	
	if (_scrollView.contentSize.height > _scrollView.frame.size.height)
		[_scrollView setContentOffset:CGPointMake(0.0, (_scrollView.contentSize.height - _scrollView.frame.size.height) + _scrollView.contentInset.bottom) animated:YES];
	
	[UIView animateKeyframesWithDuration:0.25 delay:0.00 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
		itemView.alpha = 1.0;
		itemView.frame = CGRectOffsetY(itemView.frame, -33.0);
	} completion:^(BOOL finished) {
	}];
}

- (void)_updateExpireTime {
	NSLog(@"_updateExpireTime:[%d]", _expireSeconds);
	
	_emptyCommentsView.hidden = (_channel.participantsCount >= 2);
	[_imageCommentButton setEnabled:(_channel.participantsCount >= 10)];
	
	if (_channel.participantsCount < 2) {
		if (_expireSeconds >= 0) {
			_expireSeconds--;
			
			if (_expireSeconds % 120 == 0 && !_isActive) {
				UILocalNotification *localNotification = [[UILocalNotification alloc] init];
				localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:0];
				localNotification.timeZone = [NSTimeZone systemTimeZone];
				localNotification.alertAction = @"View";
				localNotification.alertBody = @"Get more people";
				localNotification.soundName = @"selfie_notification.caf";
				localNotification.userInfo = @{};
				
				[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
			}
			
			
			int mins = _expireSeconds / 60;
			int secs = _expireSeconds % 60;
			
			_expireLabel.text = [NSString stringWithFormat:@"This chat will expire in %d:%02d\nif no one joins", mins, secs];
			
		} else {
			if (_expireTimer != nil) {
				[_expireTimer invalidate];
				_expireTimer = nil;
			}
			
			UIView *matteView = [[UIView alloc] initWithFrame:CGRectFromSize(CGSizeMake(84.0, 44.0))];
			matteView.backgroundColor = [UIColor colorWithRed:0.361 green:0.898 blue:0.576 alpha:1.00];
			[_headerView addSubview:matteView];
			
			UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
			activityIndicatorView.frame = CGRectOffset(activityIndicatorView.frame, 11.0, 11.0);
			[activityIndicatorView startAnimating];
			[_headerView addSubview:activityIndicatorView];
			
			UILabel *backLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 11.0, 120.0, 20.0)];
			backLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:17];
			backLabel.backgroundColor = [UIColor clearColor];
			backLabel.textColor = [UIColor whiteColor];
			backLabel.text = @"Deleting…";
			[_headerView addSubview:backLabel];
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				NSDictionary *dict = @{@"user_id"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
									   @"img_url"		: [[HONClubAssistant sharedInstance] defaultStatusUpdatePhotoURL],
									   @"club_id"		: @(_statusUpdateVO.clubID),
									   @"subject"		: @"__DELETE__",
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
			});
			
			dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, 1.125 * NSEC_PER_SEC);
			dispatch_after(dispatchTime, dispatch_get_main_queue(), ^(void) {
				[self dismissViewControllerAnimated:NO completion:^(void) {
				}];
			});
		}
		
	} else {
		_expireLabel.text = @"";
		
		if (_expireTimer != nil) {
			[_expireTimer invalidate];
			_expireTimer = nil;
		}
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
						 _scrollView.frame = CGRectTranslateY(_scrollView.frame, _scrollView.frame.origin.y - ((_scrollView.contentSize.height > _scrollView.frame.size.height) ? 216.0 : MAX(0.0, _scrollView.contentSize.height - 216.0) + 84.0));
						 _footerView.frame = CGRectTranslateY(_footerView.frame, self.view.frame.size.height - (216.0 + _footerView.frame.size.height));
					 } completion:^(BOOL finished) {
						 if (_scrollView.contentSize.height > _scrollView.frame.size.height)
							 [_scrollView setContentOffset:CGPointMake(0.0, (_scrollView.contentSize.height - _scrollView.frame.size.height) + _scrollView.contentInset.bottom) animated:YES];
						 
						 [self.view addSubview:_commentCloseButton];
					 }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[_conversation sendTypingIndicator:LYRTypingDidFinish];
	if (!_isSubmitting && [textField.text length] > 0)
		[self _goTextComment];
	
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([string rangeOfCharacterFromSet:[NSCharacterSet invalidCharacterSet]].location != NSNotFound)
		return (NO);
	
	return ([textField.text length] <= 200 || [string isEqualToString:@""]);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UITextFieldTextDidChangeNotification"
												  object:textField];
}

- (void)_onTextEditingDidEnd:(id)sender {
//	NSLog(@"[*:*] _onTextEditingDidEnd:[%@]", _commentTextField.text);
}


#pragma mark - Actionsheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == HONStatusUpdateActionSheetTypeDownloadAvailable) {
		if (buttonIndex == 0) {
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - download"];
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:_statusUpdateVO.appStoreURL]];
		
		} else if (buttonIndex == HONSocialPlatformShareTypeClipboard) {
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - copy_clipboard"];
			
			UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
			pasteboard.string = [NSString stringWithFormat:@"Get DOOD - A live photo feed of who is doing what around you. getdood.com/%@", [_statusUpdateVO.imagePrefix lastComponentByDelimeter:@"/"]];

			[[[UIAlertView alloc] initWithTitle:@"Paste anywhere to share!"
										message:@""
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
		
		} else if (buttonIndex == HONSocialPlatformShareTypeTwitter) {
			if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
				SLComposeViewController *twitterComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
				SLComposeViewControllerCompletionHandler completionBlock = ^(SLComposeViewControllerResult result) {
					[twitterComposeViewController dismissViewControllerAnimated:YES completion:nil];
				};
				
				[twitterComposeViewController setInitialText:[NSString stringWithFormat:[HONSocialCoordinator shareMessageForSocialPlatform:HONSocialPlatformShareTypeTwitter], [_statusUpdateVO.imagePrefix lastComponentByDelimeter:@"/"]]];
				[twitterComposeViewController addImage:[[HONUserAssistant sharedInstance] activeUserAvatar]];
				twitterComposeViewController.completionHandler = completionBlock;
				
				[self presentViewController:twitterComposeViewController animated:YES completion:nil];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@""
											message:@"Cannot use Twitter from this device!"
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
			}
			
		} else if (buttonIndex == HONSocialPlatformShareTypeInstagram) {
			NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/selfieclub_instagram.igo"];
			[[HONImageBroker sharedInstance] saveForInstagram:[[HONUserAssistant sharedInstance] activeUserAvatar]
												 withUsername:[[HONUserAssistant sharedInstance] activeUsername]
													   toPath:savePath];
			
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://app"]]) {
				UIDocumentInteractionController *documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
				documentInteractionController.UTI = @"com.instagram.exclusivegram";
				documentInteractionController.delegate = self;
				documentInteractionController.annotation = @{@"InstagramCaption"	: [NSString stringWithFormat:[HONSocialCoordinator shareMessageForSocialPlatform:HONSocialPlatformShareTypeInstagram], [_statusUpdateVO.imagePrefix lastComponentByDelimeter:@"/"]]};
				[documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
				
			} else {
				[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"alert_instagramError_t", nil) //@"Not Available"
											message:@"This device isn't allowed or doesn't recognize Instagram!"
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
			}
			
		} else if (buttonIndex == HONSocialPlatformShareTypeSMS) {
			if ([MFMessageComposeViewController canSendText]) {
				MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
				messageComposeViewController.body = [NSString stringWithFormat:[HONSocialCoordinator shareMessageForSocialPlatform:HONSocialPlatformShareTypeSMS], [_statusUpdateVO.imagePrefix lastComponentByDelimeter:@"/"]];
				messageComposeViewController.messageComposeDelegate = self;
				
				[self presentViewController:messageComposeViewController animated:YES completion:^(void) {}];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"SMS Error"
											message:@"Cannot send SMS from this device!"
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
			}
		}
	
	} else if (actionSheet.tag == HONStatusUpdateActionSheetTypeDownloadNotAvailable) {
		if (buttonIndex == 0) {
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - copy_clipboard"];
			
			UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
			pasteboard.string = [NSString stringWithFormat:@"Get Derp - A live photo feed of who is doing what around you. getdood.com/%d", _statusUpdateVO.statusUpdateID];
			
			[[[UIAlertView alloc] initWithTitle:@"Paste anywhere to share!"
										message:@""
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
			
		} else if (buttonIndex == 1) {
			if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
				SLComposeViewController *twitterComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
				SLComposeViewControllerCompletionHandler completionBlock = ^(SLComposeViewControllerResult result) {
					[twitterComposeViewController dismissViewControllerAnimated:YES completion:nil];
				};
				
				[twitterComposeViewController setInitialText:[NSString stringWithFormat:[HONSocialCoordinator shareMessageForSocialPlatform:HONSocialPlatformShareTypeTwitter], [_statusUpdateVO.imagePrefix lastComponentByDelimeter:@"/"]]];
				[twitterComposeViewController addImage:[[HONUserAssistant sharedInstance] activeUserAvatar]];
				twitterComposeViewController.completionHandler = completionBlock;
				
				[self presentViewController:twitterComposeViewController animated:YES completion:nil];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@""
											message:@"Cannot use Twitter from this device!"
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
			}
			
		} else if (buttonIndex == 2) {
			NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/selfieclub_instagram.igo"];
			[[HONImageBroker sharedInstance] saveForInstagram:[[HONUserAssistant sharedInstance] activeUserAvatar]
												 withUsername:[[HONUserAssistant sharedInstance] activeUsername]
													   toPath:savePath];
			
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://app"]]) {
				UIDocumentInteractionController *documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
				documentInteractionController.UTI = @"com.instagram.exclusivegram";
				documentInteractionController.delegate = self;
				documentInteractionController.annotation = @{@"InstagramCaption"	: [NSString stringWithFormat:[HONSocialCoordinator shareMessageForSocialPlatform:HONSocialPlatformShareTypeInstagram], [_statusUpdateVO.imagePrefix lastComponentByDelimeter:@"/"]]};
				[documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
				
			} else {
				[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"alert_instagramError_t", nil) //@"Not Available"
											message:@"This device isn't allowed or doesn't recognize Instagram!"
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
			}
			
		} else if (buttonIndex == 3) {
			if ([MFMessageComposeViewController canSendText]) {
				MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
				messageComposeViewController.body = [NSString stringWithFormat:[HONSocialCoordinator shareMessageForSocialPlatform:HONSocialPlatformShareTypeSMS], [_statusUpdateVO.imagePrefix lastComponentByDelimeter:@"/"]];
				messageComposeViewController.messageComposeDelegate = self;
				
				[self presentViewController:messageComposeViewController animated:YES completion:^(void) {}];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"SMS Error"
											message:@"Cannot send SMS from this device!"
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
			}
		}
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		if (buttonIndex == 1) {
			[self _flagStatusUpdate];
		}
	
	} else if (alertView.tag == 1) {
		if (buttonIndex == 1) {
			[[NSUserDefaults standardUserDefaults] setObject:NSStringFromBOOL(YES) forKey:@"back_chat"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			UIView *matteView = [[UIView alloc] initWithFrame:CGRectFromSize(CGSizeMake(84.0, 44.0))];
			matteView.backgroundColor = [UIColor colorWithRed:0.361 green:0.898 blue:0.576 alpha:1.00];
			[_headerView addSubview:matteView];
			
			UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
			activityIndicatorView.frame = CGRectOffset(activityIndicatorView.frame, 11.0, 11.0);
			[activityIndicatorView startAnimating];
			[_headerView addSubview:activityIndicatorView];
			
			UILabel *backLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 11.0, 120.0, 20.0)];
			backLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:17];
			backLabel.backgroundColor = [UIColor clearColor];
			backLabel.textColor = [UIColor whiteColor];
			backLabel.text = @"Deleting…";
			[_headerView addSubview:backLabel];
			
			dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, 1.125 * NSEC_PER_SEC);
			dispatch_after(dispatchTime, dispatch_get_main_queue(), ^(void) {
				[self dismissViewControllerAnimated:NO completion:^(void) {
				}];
			});
		}
	
	} else if (alertView.tag == 2) {
		if (buttonIndex == 1) {
			[[HONSocialCoordinator sharedInstance] presentActionSheetForSharingWithMetaData:@{@"deeplink"	: [NSString stringWithFormat:@"dood://%d", _statusUpdateVO.statusUpdateID]}];
		}
	}
}


#pragma mark - MailCompose Delegates
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[controller dismissViewControllerAnimated:NO completion:^(void) {
	}];
}


#pragma mark - MessageCompose Delegates
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	[controller dismissViewControllerAnimated:YES completion:nil];
}

@end
