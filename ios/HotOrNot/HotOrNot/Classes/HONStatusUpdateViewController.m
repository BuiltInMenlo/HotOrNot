//
//  HONStatusUpdateViewController.m
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSArray+BuiltinMenlo.h"
#import "NSCharacterSet+BuiltinMenlo.h"
#import "NSDate+BuiltinMenlo.h"
#import "NSDictionary+BuiltinMenlo.h"
#import "NSString+BuiltinMenlo.h"
#import "UIImageView+AFNetworking.h"
#import "UILabel+BuiltinMenlo.h"
#import "UIView+BuiltinMenlo.h"

#import "PBJFocusView.h"
#import "PBJStrobeView.h"
#import "PBJVision.h"

#import "HONStatusUpdateViewController.h"
#import "HONReplySubmitViewController.h"
#import "HONCommentItemView.h"
#import "HONCommentNotifyView.h"
#import "HONImageLoadingView.h"
#import "HONRefreshControl.h"
#import "HONScrollView.h"
#import "HONRefreshingLabel.h"
#import "HONStatusUpdateHeaderView.h"
#import "HONChannelInviteButtonView.h"

@interface HONStatusUpdateViewController () <HONChannelInviteButtonViewDelegate, HONStatusUpdateHeaderViewDelegate, PBJVisionDelegate>
- (PNChannel *)_channelSetupForStatusUpdate;

@property (nonatomic, strong) PNChannel *channel;
@property (nonatomic, strong) HONStatusUpdateVO *statusUpdateVO;
@property (nonatomic, strong) HONUserClubVO *clubVO;
@property (nonatomic, strong) HONScrollView *scrollView;
@property (nonatomic, strong) UIView *cameraHolderView;
@property (nonatomic, strong) HONRefreshControl *refreshControl;
@property (nonatomic, strong) HONStatusUpdateHeaderView *statusUpdateHeaderView;

@property (nonatomic, strong) UIView *cameraPreviewView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *cameraPreviewLayer;
@property (nonatomic, strong) PBJFocusView *cameraFocusView;
@property (nonatomic, strong) PBJStrobeView *strobeView;

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
@property (nonatomic) int participants;
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
		
		[self _setupCamera];
		[[PBJVision sharedInstance] startPreview];
	}
	
	return (self);
}

- (id)initWithStatusUpdate:(HONStatusUpdateVO *)statusUpdateVO forClub:(HONUserClubVO *)clubVO {
	NSLog(@"%@ - initWithStatusUpdate:[%@] forClub:[%d - %@]", [self description], statusUpdateVO.dictionary, clubVO.clubID, clubVO.clubName);
	if ((self = [self init])) {
		_statusUpdateVO = statusUpdateVO;
		_clubVO = clubVO;
		
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		pasteboard.string = [NSString stringWithFormat:@"doodch.at/%d/", _statusUpdateVO.statusUpdateID];
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

- (void)leaveActiveChat {
	[self _popBack];
}


#pragma mark - Data Calls
- (void)_retrieveStatusUpdate {
	if (_expireTimer != nil) {
		[_expireTimer invalidate];
		_expireTimer = nil;
	}
	
	[[HONAPICaller sharedInstance] retrieveChallengeForChallengeID:_statusUpdateVO.statusUpdateID completion:^(NSDictionary *result) {
//	[[HONAPICaller sharedInstance] retrieveStatusUpdateByStatusUpdateID:_statusUpdateVO.statusUpdateID completion:^(NSDictionary *result) {
		
		_statusUpdateVO = [HONStatusUpdateVO statusUpdateWithDictionary:result];
		
		if (_channel == nil || [[_channel.name lastComponentByDelimeter:@"_"] intValue] != _statusUpdateVO.statusUpdateID) {
			_channel = [self _channelSetupForStatusUpdate];
		
		} else {
			[PubNub sendMessage:[NSString stringWithFormat:@"%d|%.04f_%.04f|__BYE__", [[HONUserAssistant sharedInstance] activeUserID], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude] toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
				if (messageState == PNMessageSent) {
					NSLog(@"\nSEND MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
					[PubNub unsubscribeFrom:@[_channel] withCompletionHandlingBlock:^(NSArray *array, PNError *error) {
					}];
					
					[[PNObservationCenter defaultCenter] removeClientChannelSubscriptionStateObserver:self];
					[[PNObservationCenter defaultCenter] removeMessageReceiveObserver:self];
				}
			}];
		}
		
		_statusUpdateVO.replies = [_replies copy];
		[self _didFinishDataRefresh];
	}];
}

- (void)_submitCommentReply:(BOOL)isText {
	NSDictionary *dict = @{@"user_id"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
						   @"club_id"		: @(_clubVO.clubID),
						   @"img_url"		: [@"coords://" stringByAppendingFormat:@"%.04f_%.04f", [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude],
						   @"subject"		: [NSString stringWithFormat:@"%d|%.04f_%.04f|%@", [[HONUserAssistant sharedInstance] activeUserID], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude, (isText) ? _comment : @"emoji"],
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
	
	[PubNub sendMessage:[dict objectForKey:@"subject"] toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
		//NSLog(@"\nSEND MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
	}];
	
	_isSubmitting = NO;
}

- (PNChannel *)_channelSetupForStatusUpdate {
	PNChannel *channel = [PNChannel channelWithName:[NSString stringWithFormat:@"%d_%d", _statusUpdateVO.userID, _statusUpdateVO.statusUpdateID] shouldObservePresence:YES];
	[PubNub subscribeOn:@[channel]];
	
	[[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
		PNChannel *channel = [channels firstObject];
		
		NSLog(@"\n::: SUBSCRIPTION OBSERVER - [%@](%@)\n", (state == PNSubscriptionProcessSubscribedState) ? @"Subscribed" : (state == PNSubscriptionProcessRestoredState) ? @"Restored" : (state == PNSubscriptionProcessNotSubscribedState) ? @"NotSubscribed" : (state == PNSubscriptionProcessWillRestoreState) ? @"WillRestore" : @"UNKNOWN", channel.name);
		
		if (state == PNSubscriptionProcessSubscribedState || state == PNSubscriptionProcessRestoredState) {
			_channel = channel;
			_participants = 1;
			
			NSMutableDictionary *dict = [@{@"id"				: @"0",
										   @"msg_id"			: @"0",
										   @"content_type"		: @((int)HONCommentContentTypeSYN),
										   
										   @"owner_member"		: @{@"id"	: @([[HONUserAssistant sharedInstance] activeUserID]),
																	@"name"	: [[HONUserAssistant sharedInstance] activeUsername]},
										   @"image"				: [@"coords://" stringByAppendingFormat:@"%.04f_%.04f", [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude],
										   @"text"				: @"you have joined this |DOOD CHAT|",
										   
										   @"net_vote_score"	: @(0),
										   @"status"			: NSStringFromInt(0),
										   @"added"				: [NSDate stringFormattedISO8601],
										   @"updated"			: [NSDate stringFormattedISO8601]} mutableCopy];
			
			
			[self _appendComment:[HONCommentVO commentWithDictionary:dict]];
			
			[PubNub sendMessage:[NSString stringWithFormat:@"%d|%.04f_%.04f|__SYN__", [[HONUserAssistant sharedInstance] activeUserID], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude] toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
				//NSLog(@"\nSEND MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
			}];
			
		} else if (state == PNSubscriptionProcessNotSubscribedState) {
		} else if (state == PNSubscriptionProcessWillRestoreState) {
		}
	}];
	
	// Observer looks for message received events
	[[PNObservationCenter defaultCenter] addMessageReceiveObserver:self withBlock:^(PNMessage *message) {
		NSLog(@"\n::: MESSAGE REC OBSERVER:[%@](%@)", message.channel.name, message.message);
		
		HONCommentVO *commentVO = [HONCommentVO commentWithMessage:message];
		NSLog(@"CommentType:[%@]\n", (commentVO.commentContentType == HONCommentContentTypeSYN) ? @"SYN" : (commentVO.commentContentType == HONCommentContentTypeACK) ? @"ACK" : (commentVO.commentContentType == HONCommentContentTypeBYE) ? @"BYE": (commentVO.commentContentType == HONCommentContentTypeText) ? @"Text" : @"UNKNOWN");
		NSLog(@"commentVO.userID:[%d]", commentVO.userID);
		
		if (commentVO.commentContentType == HONCommentContentTypeSYN) {
			if (commentVO.userID != [[HONUserAssistant sharedInstance] activeUserID]) {
				_participants++;
				
				commentVO.textContent = @"a user has joined this |DOOD CHAT|";
				[self _appendComment:commentVO];
				
				[PubNub sendMessage:[NSString stringWithFormat:@"%d|%.04f_%.04f|%d__ACK__", [[HONUserAssistant sharedInstance] activeUserID], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude, commentVO.userID] toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
					//NSLog(@"\nSEND MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
				}];
			}
			
		} else if (commentVO.commentContentType == HONCommentContentTypeACK) {
			if ([commentVO.textContent intValue] == [[HONUserAssistant sharedInstance] activeUserID])
				_participants++;
		
		} else if (commentVO.commentContentType == HONCommentContentTypeBYE) {
			_participants = MAX(0, --_participants);
			
			if (commentVO.userID != [[HONUserAssistant sharedInstance] activeUserID]) {
				commentVO.textContent = @"a user has left this |DOOD CHAT|";
				[self _appendComment:commentVO];
			}
		
		} else if (commentVO.commentContentType == HONCommentContentTypeText) {
			[self _appendComment:commentVO];
		}
		
		if (_expireTimer != nil) {
			[_expireTimer invalidate];
			_expireTimer = nil;
		}
		
		
		_emptyCommentsView.hidden = (_participants > 1);
		_commentsHolderView.hidden = (_participants < 2);
		_footerView.hidden = (_participants < 2);
		
		[_imageCommentButton setEnabled:(_participants >= 10)];
		
		if (_participants < 2) {
			
			if ([_commentTextField isFirstResponder])
				[self _goCancelComment];
				
			_expireSeconds = 600;
			_expireTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
															target:self selector:@selector(_updateExpireTime)
														  userInfo:nil
														   repeats:YES];
		} else {
			
		}
	}];
	
	
//	[[PNObservationCenter defaultCenter] addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
//		NSLog(@"\n::: MESSAGE PROC OBSERVER - [%@](%@)\n", (state == PNMessageSent) ? @"MessageSent" : (state == PNMessageSending) ? @"MessageSending" : (state == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
//	}];
	
	
	
	////////////////////////////////////////////////////////////////////////////////
	
	/*
	[[PNObservationCenter defaultCenter] addPresenceEventObserver:self withBlock:^(PNPresenceEvent *event) {
		NSLog(@"::: PRESENCE OBSERVER - [%@] :::", event);
		NSLog(@"PARTICIPANTS:[%d]", (int)event.channel.participantsCount);
		
		if (event.type == PNPresenceEventChanged) {
			NSLog(@"PRESENCE OBSERVER: Changed Event on Channel: %@, w/ Participant: %@", event.channel.name, event.client.identifier);
			
		} else if (event.type == PNPresenceEventJoin) {
			NSLog(@"PRESENCE OBSERVER: Join Event on Channel: %@, w/ Participant: %@", event.channel.name, event.client.identifier);
			
			_channel = event.channel;
			_participants++;
			
			[_creatorView updateParticipantTotal:(int)_channel.participantsCount];
			
			_emptyCommentsView.hidden = (_channel.participantsCount > 1);
			_commentsHolderView.hidden = (_channel.participantsCount < 2);
			_footerView.hidden = (_channel.participantsCount < 2);
			[_imageCommentButton setEnabled:(_channel.participantsCount >= 10)];
			
			if (_channel.participantsCount > 1) {
				NSMutableDictionary *dict = [@{@"id"				: @"0",
											   @"msg_id"			: @"0",
											   @"content_type"		: @((int)HONCommentContentTypeNotify),
											   
											   @"owner_member"		: @{@"id"	: @(0),
																		@"name"	: @""},
											   
											   @"image"				: @"coords://",
											   @"text"				: @"a user has joined this |DOOD CHAT|",
											   
											   @"net_vote_score"	: @(0),
											   @"status"			: NSStringFromInt(0),
											   @"added"				: [NSDate stringFormattedISO8601],
											   @"updated"			: [NSDate stringFormattedISO8601]} mutableCopy];
				
				
				[self _appendComment:[HONCommentVO commentWithDictionary:dict]];
			}
			
		} else if (event.type == PNPresenceEventLeave) {
			NSLog(@"PRESENCE OBSERVER: Leave Event on Channel: %@, w/ Participant: %@", event.channel.name, event.client.identifier);
			_channel = event.channel;
			[_creatorView updateParticipantTotal:(int)_channel.participantsCount];
			
			_emptyCommentsView.hidden = (_channel.participantsCount > 1);
			_commentsHolderView.hidden = (_channel.participantsCount < 2);
			_footerView.hidden = (_channel.participantsCount < 2);
			[_imageCommentButton setEnabled:(_channel.participantsCount >= 10)];
			
			if (_channel.participantsCount > 1) {
				NSMutableDictionary *dict = [@{@"id"				: @"0",
											   @"msg_id"			: @"0",
											   @"content_type"		: @((int)HONCommentContentTypeJoin),
											   
											   @"owner_member"		: @{@"id"	: @(0),
																		@"name"	: @""},
											   
											   @"image"				: @"coords://",
											   @"text"				: @"a user has left this |DOOD CHAT|",
											   
											   @"net_vote_score"	: @(0),
											   @"status"			: NSStringFromInt(0),
											   @"added"				: [NSDate stringFormattedISO8601],
											   @"updated"			: [NSDate stringFormattedISO8601]} mutableCopy];
				
				[self _appendComment:[HONCommentVO commentWithDictionary:dict]];
			}
			
			if (_channel.participantsCount < 2) {
				_expireSeconds = 600;
				_expireTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
																target:self selector:@selector(_updateExpireTime)
															  userInfo:nil
															   repeats:YES];
			}
			
		} else if (event.type == PNPresenceEventStateChanged) {
			NSLog(@"PRESENCE OBSERVER: State Changed Event on Channel: %@, w/ Participant: %@", event.channel.name, event.client.identifier);
			
		} else if (event.type == PNPresenceEventTimeout) {
			NSLog(@"PRESENCE OBSERVER: Timeout Event on Channel: %@, w/ Participant: %@", event.channel.name, event.client.identifier);
		}
	}];
	*/
	
	return (channel);
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
	
	[UIView animateWithDuration:0.125 animations:^(void) {
		_typingStatusLabel.alpha = 0.0;
	} completion:^(BOOL finished) {
		_typingStatusLabel.text = NSLocalizedString(@"typing_status", @"someone is typing…");
	}];
	
	NSLog(@"%@._didFinishDataRefresh", self.class);
}

- (void)_updateExpireTime {
	
	if (_participants < 2) {
		if (--_expireSeconds >= 0) {
//			NSLog(@"_updateExpireTime:[%d] // (%d) -(%@)", _expireSeconds, _expireSeconds % 20, NSStringFromBOOL(_isActive));
			
			if (_expireSeconds % 120 == 0 && !_isActive) {
				
				int secs = [[[NSUserDefaults standardUserDefaults] objectForKey:@"occupancy_timeout"] intValue];
				int mins = [NSDate elapsedMinutesFromSeconds:secs];
				int hours = [NSDate elapsedHoursFromSeconds:secs];
				
				UILocalNotification *localNotification = [[UILocalNotification alloc] init];
				localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:0];
				localNotification.timeZone = [NSTimeZone systemTimeZone];
				localNotification.alertAction = @"View";
				localNotification.alertBody = [NSString stringWithFormat:@"Chat link expires in less than %@!", (hours > 0) ? [NSString stringWithFormat:@"%d hour%@", hours, (hours == 1) ? @"" : @"s"] : (mins > 0) ? [NSString stringWithFormat:@"%d minute%@", mins, (mins == 1) ? @"" : @"s"] : [NSString stringWithFormat:@"%d second%@", secs, (secs == 1) ? @"" : @"s"]];  //[[[[NSUserDefaults standardUserDefaults] objectForKey:@"alert_formats"] objectForKey:@"participant_push"] objectForKey:@"msg"];
				localNotification.soundName = @"selfie_notification.caf";
				localNotification.userInfo = @{};
				
				[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
			}
			
			NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
			paragraphStyle.minimumLineHeight = 35.0;
			paragraphStyle.maximumLineHeight = paragraphStyle.minimumLineHeight;
			paragraphStyle.alignment = NSTextAlignmentCenter;
			
			
			int mins = _expireSeconds / 60;
			int secs = _expireSeconds % 60;
			
			_expireLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:[[NSUserDefaults standardUserDefaults] objectForKey:@"expire_interval"], mins, secs] attributes:@{NSParagraphStyleAttributeName	: paragraphStyle}];
			[_expireLabel setTextColor:[UIColor redColor] range:NSMakeRange([_expireLabel.text length] - 4, 4)];
			
		} else
			[self _popBack];
		
	} else {
		if (_expireTimer != nil) {
			[_expireTimer invalidate];
			_expireTimer = nil;
		}
	}
}

- (void)_copyDeeplink {
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = [NSString stringWithFormat:@"doodch.at/%d/", _statusUpdateVO.statusUpdateID];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - enter"];
	
	_isActive = YES;
	_isSubmitting = NO;
	
	_comment = @"";
	_expireSeconds = 600;
	_participants = 0;
	
	_cameraPreviewView = [[UIView alloc] initWithFrame:CGRectFromSize(self.view.frame.size)];
	_cameraPreviewView.backgroundColor = [UIColor blackColor];
	_cameraPreviewLayer = [[PBJVision sharedInstance] previewLayer];
	_cameraPreviewLayer.frame = _cameraPreviewView.bounds;
	_cameraPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[_cameraPreviewView.layer addSublayer:_cameraPreviewLayer];
	[self.view addSubview:_cameraPreviewView];
	[[PBJVision sharedInstance] setPresentationFrame:_cameraPreviewView.frame];
	
	_scrollView = [[HONScrollView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight + 84.0, 320.0, self.view.frame.size.height - (0.0 + kNavHeaderHeight + 84.0 + 64.0) + [[UIApplication sharedApplication] statusBarFrame].size.height)];
	_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, 0.0);
	_scrollView.contentInset = UIEdgeInsetsZero;
	_scrollView.alwaysBounceVertical = YES;
	_scrollView.delegate = self;
	[self.view addSubview:_scrollView];
	
	_refreshControl = [[HONRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_scrollView addSubview: _refreshControl];
	
	_commentsHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _scrollView.frame.size.width, 0.0)];
	_commentsHolderView.hidden = YES;
	[_scrollView addSubview:_commentsHolderView];
	
	
	_statusUpdateHeaderView = [[HONStatusUpdateHeaderView alloc] initWithStatusUpdateVO:_statusUpdateVO];
	_statusUpdateHeaderView.delegate = self;
	[self.view addSubview:_statusUpdateHeaderView];
	
	_footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 64.0, self.view.frame.size.width, 64.0)];
	_footerView.hidden = YES;
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
	
	_commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(11.0, 13.0, 232.0, 20.0)];
	[_commentTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_commentTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_commentTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_commentTextField setReturnKeyType:UIReturnKeySend];
	[_commentTextField setTextColor:[UIColor blackColor]];
	[_commentTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	_commentTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
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
	[_imageCommentButton setEnabled:NO];
//	[_inputBGImageView addSubview:_imageCommentButton];
	
	_commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_commentButton.frame = CGRectMake(257.0, 0.0, 64.0, 44.0);
	[_commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_nonActive"] forState:UIControlStateNormal];
	[_commentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_Active"] forState:UIControlStateHighlighted];
	[_commentButton addTarget:self action:@selector(_goTextComment) forControlEvents:UIControlEventTouchUpInside];
	[_commentButton setEnabled:NO];
	[_inputBGImageView addSubview:_commentButton];
	
	_emptyCommentsView = [[UIView alloc] initWithFrame:CGRectMake(0.0, _statusUpdateHeaderView.frameEdges.bottom, self.view.frame.size.width, self.view.frame.size.height - _statusUpdateHeaderView.frameEdges.bottom)];
	[self.view addSubview:_emptyCommentsView];
	
	_expireLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 50.0, 260.0, 85.0)];
	_expireLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:19];
	_expireLabel.backgroundColor = [UIColor clearColor];
	_expireLabel.textColor = [UIColor blackColor];
	_expireLabel.numberOfLines = 2;
	_expireLabel.textAlignment = NSTextAlignmentCenter;
	_expireLabel.text = @"";
	[_emptyCommentsView addSubview:_expireLabel];
	
//	for (int i=0; i<5; i++) {
//		HONChannelInviteButtonView *inviteButtonView = [[HONChannelInviteButtonView alloc] initWithFrame:CGRectMake(0.0, _emptyCommentsView.frame.size.height - ((5.0 - i) * 44.0), _emptyCommentsView.frame.size.width, 44.0) asButtonType:(HONChannelInviteButtonType)i];
//		inviteButtonView.delegate = self;
//		[_emptyCommentsView addSubview:inviteButtonView];
//	}
	
	_commentCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_commentCloseButton.frame = CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - (kNavHeaderHeight + 260.0));
	[_commentCloseButton addTarget:self action:@selector(_goCancelComment) forControlEvents:UIControlEventTouchUpInside];
	
	
	UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	commentButton.frame = CGRectMake(105.0, 200.0, 111.0, 111.0);
	[commentButton setBackgroundImage:[UIImage imageNamed:@"composeButton_nonActive"] forState:UIControlStateNormal];
	[commentButton setBackgroundImage:[UIImage imageNamed:@"composeButton_Active"] forState:UIControlStateHighlighted];
	[commentButton addTarget:self action:@selector(_goImageComment) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:commentButton];
	
	_headerView = [[HONHeaderView alloc] init];
//	[_headerView addBackButtonWithTarget:self action:@selector(_goBack)];
	[self.view addSubview:_headerView];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	[_scrollView setContentOffset:CGPointMake(0.0, -95.0) animated:NO];
	[self _goReloadContent];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:animated:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidDisappear:animated:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewDidDisappear:animated];
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
	
	} else
		[self _popBack];
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

- (void)_goImageComment {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - photo"];
	
	[[PBJVision sharedInstance] capturePhoto];
	
//	if (_participants >= 10) {
//		_isSubmitting = YES;
//		
//		_commentTextField.text = @"";
//		_comment = @"EMOJI";
//		
//		[self _submitCommentReply:NO];
//		
//	} else {
//		[[[UIAlertView alloc] initWithTitle:@"Emoji board unlocked when chat has more than 10 friends"
//									message:nil
//								   delegate:nil
//						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
//						  otherButtonTitles:nil, nil] show];
//	}
}

- (void)_goTextComment {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - comment"];
	
	_isSubmitting = YES;
	[_commentButton setEnabled:NO];
	
	_comment = _commentTextField.text;
	_commentTextField.text = @"";
	
	[self _submitCommentReply:YES];
}

- (void)_goCancelComment {
	_commentTextField.text = @"";
	if ([_commentTextField isFirstResponder])
		[_commentTextField resignFirstResponder];
	
	_scrollView.frame = CGRectResizeHeight(_scrollView.frame, self.view.frame.size.height - (0.0 + kNavHeaderHeight + 84.0 + 64.0) + [[UIApplication sharedApplication] statusBarFrame].size.height);
	[_scrollView setContentOffset:CGPointMake(0.0, MAX(0.0, _scrollView.contentSize.height - _scrollView.frame.size.height)) animated:YES];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_statusUpdateHeaderView.frame = CGRectTranslateY(_statusUpdateHeaderView.frame, kNavHeaderHeight);
		_scrollView.frame = CGRectTranslateY(_scrollView.frame, _statusUpdateHeaderView.frameEdges.bottom);
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
	[_imageCommentButton setEnabled:(_participants >= 10)];
	
	_commentButton.hidden = ([_commentTextField.text length] == 0);
	[_commentButton setEnabled:([_commentTextField.text length] > 0)];
//	[_conversation sendTypingIndicator:LYRTypingDidBegin];
}


#pragma mark - UI Presentation
- (void)_setupCamera {
	PBJVision *vision = [PBJVision sharedInstance];
	vision.delegate = self;
	
	vision.cameraDevice = ([vision isCameraDeviceAvailable:PBJCameraDeviceBack]) ? PBJCameraDeviceBack : PBJCameraDeviceFront;
//	_flipButton.hidden = (![vision isCameraDeviceAvailable:PBJCameraDeviceBack]);
	
//	vision.cameraMode = PBJCameraModeVideo;
	vision.cameraMode = PBJCameraModePhoto;
	vision.cameraOrientation = PBJCameraOrientationPortrait;
	vision.focusMode = PBJFocusModeContinuousAutoFocus;
	vision.outputFormat = PBJOutputFormatStandard;
	vision.videoRenderingEnabled = NO;
	vision.additionalCompressionProperties = @{AVVideoProfileLevelKey : AVVideoProfileLevelH264Baseline30}; // AVVideoProfileLevelKey requires specific captureSessionPreset
	
	// specify a maximum duration with the following property
	// vision.maximumCaptureDuration = CMTimeMakeWithSeconds(5, 600); // ~ 5 seconds
}

- (void)_appendComment:(HONCommentVO *)vo {
	NSLog(@"_appendComment:[%@]", (vo.commentContentType == HONCommentContentTypeSYN) ? @"SYN" : (vo.commentContentType == HONCommentContentTypeACK) ? @"ACK" : (vo.commentContentType == HONCommentContentTypeBYE) ? @"BYE": (vo.commentContentType == HONCommentContentTypeText) ? @"Text" : @"UNKNOWN");
	[_replies addObject:vo];
	
	if (vo.commentContentType == HONCommentContentTypeSYN) {
		HONCommentNotifyView *notifyView = [[HONCommentNotifyView alloc] initWithFrame:CGRectMake(0.0, _commentsHolderView.frame.size.height, 320.0, 50.0)];
		notifyView.alpha = 0.0;
		notifyView.commentVO = vo;
		[_commentsHolderView addSubview:notifyView];
		
		_commentsHolderView.frame = CGRectExtendHeight(_commentsHolderView.frame, notifyView.frame.size.height);

		[UIView animateKeyframesWithDuration:0.125 delay:0.00 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
			notifyView.alpha = 1.0;
		} completion:^(BOOL finished) {
		}];
		
	} else if (vo.commentContentType == HONCommentContentTypeBYE) {
		HONCommentNotifyView *notifyView = [[HONCommentNotifyView alloc] initWithFrame:CGRectMake(0.0, _commentsHolderView.frame.size.height, 320.0, 50.0)];
		notifyView.alpha = 0.0;
		notifyView.commentVO = vo;
		[_commentsHolderView addSubview:notifyView];
		
		_commentsHolderView.frame = CGRectExtendHeight(_commentsHolderView.frame, notifyView.frame.size.height);
		
		[UIView animateKeyframesWithDuration:0.125 delay:0.00 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
			notifyView.alpha = 1.0;
		} completion:^(BOOL finished) {
		}];
	
	} else if (vo.commentContentType == HONCommentContentTypeText) {
		CGFloat offset = 33.0;
		HONCommentItemView *itemView = [[HONCommentItemView alloc] initWithFrame:CGRectMake(0.0, offset + _commentsHolderView.frame.size.height, 320.0, 90.0)];
		itemView.alpha = 0.0;
		itemView.commentVO = vo;
		[_commentsHolderView addSubview:itemView];
		
		_commentsHolderView.frame = CGRectExtendHeight(_commentsHolderView.frame, itemView.frame.size.height);
		
		[UIView animateKeyframesWithDuration:0.25 delay:0.00 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
			itemView.alpha = 1.0;
			itemView.frame = CGRectOffsetY(itemView.frame, -offset);
		} completion:^(BOOL finished) {
		}];
	}
	
	_scrollView.contentSize = _commentsHolderView.frame.size;
	[_scrollView setContentOffset:CGPointMake(0.0, MAX(0.0, _scrollView.contentSize.height - _scrollView.frame.size.height)) animated:NO];
}

- (void)_popBack {
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	
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
	
	
	[PubNub sendMessage:[NSString stringWithFormat:@"%d|%.04f_%.04f|__BYE__", [[HONUserAssistant sharedInstance] activeUserID], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude] toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
		if (messageState == PNMessageSent) {
			NSLog(@"\nSEND MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
			[PubNub unsubscribeFrom:@[_channel] withCompletionHandlingBlock:^(NSArray *array, PNError *error) {
			}];
			
			[[PNObservationCenter defaultCenter] removeClientChannelSubscriptionStateObserver:self];
			[[PNObservationCenter defaultCenter] removeMessageReceiveObserver:self];
		}
	}];
	
	dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, 1.125 * NSEC_PER_SEC);
	dispatch_after(dispatchTime, dispatch_get_main_queue(), ^(void) {
		[[PBJVision sharedInstance] stopPreview];
		[self.navigationController popToRootViewControllerAnimated:YES];
	});
}


#pragma mark - PBJVisionDelegate

// session
- (void)visionSessionWillStart:(PBJVision *)vision {
	NSLog(@"[*:*] visionSessionWillStart [*:*]");
}

- (void)visionSessionDidStart:(PBJVision *)vision {
	NSLog(@"[*:*] visionSessionDidStart [*:*]");
	
//	if (![_cameraPreviewView superview])
//		[self.view addSubview:_cameraPreviewView];
}

- (void)visionSessionDidStop:(PBJVision *)vision {
	NSLog(@"[*:*] visionSessionDidStop [*:*]");
	
	[_cameraPreviewView removeFromSuperview];
}

// preview
- (void)visionSessionDidStartPreview:(PBJVision *)vision {
	NSLog(@"[*:*] visionSessionDidStartPreview [*:*]");
	
}

- (void)visionSessionDidStopPreview:(PBJVision *)vision {
	NSLog(@"[*:*] visionSessionDidStopPreview [*:*]");
}

// device
- (void)visionCameraDeviceWillChange:(PBJVision *)vision {
	NSLog(@"[*:*] visionCameraDeviceWillChange [*:*]");
}

- (void)visionCameraDeviceDidChange:(PBJVision *)vision {
	NSLog(@"[*:*] visionCameraDeviceDidChange [*:*]");
}

// mode
- (void)visionCameraModeWillChange:(PBJVision *)vision {
	NSLog(@"[*:*] visionCameraModeWillChange [*:*]");
}

- (void)visionCameraModeDidChange:(PBJVision *)vision {
	NSLog(@"[*:*] visionCameraModeDidChange [*:*]");
}

// format
- (void)visionOutputFormatWillChange:(PBJVision *)vision {
	NSLog(@"[*:*] visionOutputFormatWillChange [*:*]");
}

- (void)visionOutputFormatDidChange:(PBJVision *)vision {
	NSLog(@"[*:*] visionOutputFormatDidChange [*:*]");
}

- (void)vision:(PBJVision *)vision didChangeCleanAperture:(CGRect)cleanAperture {
	NSLog(@"[*:*] vision:didChangeCleanAperture:[%@] [*:*]", NSStringFromCGRect(cleanAperture));
}

// focus / exposure
- (void)visionWillStartFocus:(PBJVision *)vision {
	//NSLog(@"[*:*] visionWillStartFocus [*:*]");
}

- (void)visionDidStopFocus:(PBJVision *)vision {
	//NSLog(@"[*:*] visionDidStopFocus [*:*]");
	
	if (_cameraFocusView && [_cameraFocusView superview]) {
		[_cameraFocusView stopAnimation];
	}
}

- (void)visionWillChangeExposure:(PBJVision *)vision {
	//NSLog(@"[*:*] visionWillChangeExposure [*:*]");
}

- (void)visionDidChangeExposure:(PBJVision *)vision {
	//NSLog(@"[*:*] visionDidChangeExposure [*:*]");
	
	if (_cameraFocusView && [_cameraFocusView superview]) {
		[_cameraFocusView stopAnimation];
	}
}

// flash
- (void)visionDidChangeFlashMode:(PBJVision *)vision {
	NSLog(@"[*:*] visionDidChangeFlashMode [*:*]");
}

// photo
- (void)visionWillCapturePhoto:(PBJVision *)vision {
	NSLog(@"[*:*] visionWillCapturePhoto [*:*]");
}

- (void)visionDidCapturePhoto:(PBJVision *)vision {
	NSLog(@"[*:*] visionDidCapturePhoto [*:*]");
}

- (void)vision:(PBJVision *)vision capturedPhoto:(NSDictionary *)photoDict error:(NSError *)error {
	NSLog(@"[*:*] vision:capturedPhoto:[%@] error:[%@] [*:*]", [photoDict objectForKey:PBJVisionPhotoMetadataKey], error);
	
	// handle error properly
	if (error)
		return;
	
	
	UIImage *image = [photoDict objectForKey:PBJVisionPhotoImageKey];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	imageView.frame = CGRectFromSize([UIScreen mainScreen].bounds.size);
	[self.view addSubview:imageView];
	
	
	/*
	_currentPhoto = photoDict;
	
	// save to library
	NSData *photoData = _currentPhoto[PBJVisionPhotoJPEGKey];
	NSDictionary *metadata = _currentPhoto[PBJVisionPhotoMetadataKey];
	[_assetLibrary writeImageDataToSavedPhotosAlbum:photoData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error1) {
		if (error1 || !assetURL) {
			// handle error properly
			return;
		}
		
		NSString *albumName = @"PBJVision";
		__block BOOL albumFound = NO;
		[_assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
			if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
				albumFound = YES;
				[_assetLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
					[group addAsset:asset];
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photo Saved!" message: @"Saved to the camera roll."
																   delegate:nil
														  cancelButtonTitle:nil
														  otherButtonTitles:@"OK", nil];
					[alert show];
				} failureBlock:nil];
			}
			if (!group && !albumFound) {
				__weak ALAssetsLibrary *blockSafeLibrary = _assetLibrary;
				[_assetLibrary addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group1) {
					[blockSafeLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
						[group1 addAsset:asset];
						UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Photo Saved!" message: @"Saved to the camera roll."
																	   delegate:nil
															  cancelButtonTitle:nil
															  otherButtonTitles:@"OK", nil];
						[alert show];
					} failureBlock:nil];
				} failureBlock:nil];
			}
		} failureBlock:nil];
	}];
	
	_currentPhoto = nil;
	 */
}

// video capture
- (void)visionDidStartVideoCapture:(PBJVision *)vision {
	NSLog(@"[*:*] visionDidStartVideoCapture [*:*]");
	
	[_strobeView start];
//	_recording = YES;
}

- (void)visionDidPauseVideoCapture:(PBJVision *)vision {
	NSLog(@"[*:*] visionDidPauseVideoCapture [*:*]");
	
	[_strobeView stop];
}

- (void)visionDidResumeVideoCapture:(PBJVision *)vision {
	NSLog(@"[*:*] visionDidResumeVideoCapture [*:*]");
	
	[_strobeView start];
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error {
	NSLog(@"[*:*] vision:capturedVideo:[%@] error:[%@] [*:*]", videoDict, error);
	
//	_recording = NO;
	
	if (error && [error.domain isEqual:PBJVisionErrorDomain] && error.code == PBJVisionErrorCancelled) {
		NSLog(@"recording session cancelled");
		return;
		
	} else if (error) {
		NSLog(@"encounted an error in video capture (%@)", error);
		return;
	}
	
	/*
	_currentVideo = videoDict;
	
	NSString *videoPath = [_currentVideo  objectForKey:PBJVisionVideoPathKey];
	[_assetLibrary writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:videoPath] completionBlock:^(NSURL *assetURL, NSError *error1) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Video Saved!" message: @"Saved to the camera roll."
													   delegate:self
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil];
		[alert show];
	}];
	*/
}

// progress
- (void)vision:(PBJVision *)vision didCaptureVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
	NSLog(@"[*:*] vision:didCaptureVideoSampleBuffer:[%.04f] [*:*]", vision.capturedVideoSeconds);
}

- (void)vision:(PBJVision *)vision didCaptureAudioSample:(CMSampleBufferRef)sampleBuffer {
	NSLog(@"[*:*] vision:didCaptureAudioSample:[%.04f] [*:*]", vision.capturedAudioSeconds);
}


#pragma mark - ChannelInviteButtonView Delegates
- (void)channelInviteButtonView:(HONChannelInviteButtonView *)buttonView didSelectType:(HONChannelInviteButtonType)buttonType {
	NSLog(@"[*:*] channelInviteButtonView:didSelectType:[%d] [*:*]", (int)buttonType);
	
	BOOL hasSchema = YES;
	NSString *typeName = @"";
	NSString *urlSchema = @"";
	
	[self _copyDeeplink];
	
	if (buttonType == HONChannelInviteButtonTypeClipboard) {
		typeName = @"Clipboard";
		
		[[[UIAlertView alloc] initWithTitle:@"Chat link copied to clipboard!"
									message:nil
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
		
		
	} else if (buttonType == HONChannelInviteButtonTypeSMS) {
		typeName = @"SMS";
		
		if ([MFMessageComposeViewController canSendText]) {
			MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
			messageComposeViewController.body = [NSString stringWithFormat:@"doodch.at/%d/", _statusUpdateVO.statusUpdateID];
			messageComposeViewController.messageComposeDelegate = self;
			[self presentViewController:messageComposeViewController animated:YES completion:^(void) {}];
		}

//	} else if (buttonType == HONChannelInviteButtonTypeEmail) {
//		typeName = @"Email";
		
	} else if (buttonType == HONChannelInviteButtonTypeKakao) {
		typeName = @"Kakao";;
		urlSchema = @"kakaolink://";
		
	} else if (buttonType == HONChannelInviteButtonTypeKik) {
		typeName = @"Kik";
		urlSchema = @"kik://";
		
	} else if (buttonType == HONChannelInviteButtonTypeLine) {
		typeName = @"LINE";
		urlSchema = @"line://";
	}
	
	if (!hasSchema) {
		[[[UIAlertView alloc] initWithTitle:@"Not Avialable"
									message:[NSString stringWithFormat:@"This device isn't allowed or doesn't recognize %@!", typeName]
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
	
	} else {
		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlSchema]]) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlSchema]];
		}
	}
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:[@"DETAILS - " stringByAppendingString:typeName]];
}


#pragma mark - StatusUpdateHeaderView Delegates
- (void)statusUpdateHeaderView:(HONStatusUpdateHeaderView *)statusUpdateHeaderView copyLinkForStatusUpdate:(HONStatusUpdateVO *)statusUpdateVO {
	NSLog(@"[*:*] statusUpdateHeaderView:copyLinkForStatusUpdate:[%@] [*:*]", NSStringFromInt(statusUpdateVO.statusUpdateID));
}

- (void)statusUpdateHeaderViewGoBack:(HONStatusUpdateHeaderView *)statusUpdateHeaderView {
	NSLog(@"[*:*] statusUpdateHeaderViewGoBack [*:*]");
	
	[self _goBack];
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_textFieldTextDidChangeChange:)
												 name:UITextFieldTextDidChangeNotification
											   object:textField];
	
	_scrollView.frame = CGRectResizeHeight(_scrollView.frame, self.view.frame.size.height - (8.0 + kNavHeaderHeight + _footerView.frame.size.height + 216.0) + [[UIApplication sharedApplication] statusBarFrame].size.height);
	[_scrollView setContentOffset:CGPointMake(0.0, MAX(0.0, _scrollView.contentSize.height - _scrollView.frame.size.height)) animated:YES];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		 _statusUpdateHeaderView.frame = CGRectTranslateY(_statusUpdateHeaderView.frame, kNavHeaderHeight - _statusUpdateHeaderView.frame.size.height);
		 _scrollView.frame = CGRectTranslateY(_scrollView.frame, kNavHeaderHeight);
		
		 _footerView.frame = CGRectTranslateY(_footerView.frame, self.view.frame.size.height - (_footerView.frame.size.height + 216.0));
	 } completion:^(BOOL finished) {
		 
		 _commentCloseButton.frame = _scrollView.frame;
		 [self.view addSubview:_commentCloseButton];
	 }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
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
			pasteboard.string = [NSString stringWithFormat:@"doodch.at/%d/", _statusUpdateVO.statusUpdateID];

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
			pasteboard.string = [NSString stringWithFormat:@"doodch.at/%d/", _statusUpdateVO.statusUpdateID];
			
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
			
			[self _popBack];
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
