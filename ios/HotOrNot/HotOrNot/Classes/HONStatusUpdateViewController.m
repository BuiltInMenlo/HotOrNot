//
//  HONStatusUpdateViewController.m
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

#import <AWSiOSSDKv2/S3.h>

#import "NSCharacterSet+BuiltinMenlo.h"
#import "NSDate+BuiltinMenlo.h"
#import "NSString+BuiltinMenlo.h"
#import "NSDictionary+BuiltInMenlo.h"
#import "PubNub+BuiltInMenlo.h"
#import "UIImageView+AFNetworking.h"
#import "UIView+BuiltinMenlo.h"

#import "PBJFocusView.h"
#import "PBJVision.h"

#import "HONStatusUpdateViewController.h"
#import "HONCommentItemView.h"
#import "HONScrollView.h"
#import "HONStatusUpdateHeaderView.h"
#import "HONStatusUpdateFooterView.h"
#import "HONChannelInviteButtonView.h"
#import "HONLoadingOverlayView.h"
#import "HONImageRevealerView.h"

@interface HONStatusUpdateViewController () <HONChannelInviteButtonViewDelegate, HONCommentItemViewDelegate, HONImageRevealerViewDelegate, HONLoadingOverlayViewDelegate, HONStatusUpdateFooterViewDelegate, HONStatusUpdateHeaderViewDelegate, PBJVisionDelegate>
- (PNChannel *)_channelSetupForStatusUpdate;

@property (nonatomic, strong) PNChannel *channel;
@property (nonatomic, strong) HONStatusUpdateVO *statusUpdateVO;
@property (nonatomic, strong) HONUserClubVO *clubVO;
@property (nonatomic, strong) HONScrollView *scrollView;
@property (nonatomic, strong) HONLoadingOverlayView *loadingOverlayView;
@property (nonatomic, strong) HONStatusUpdateHeaderView *statusUpdateHeaderView;

@property (nonatomic, strong) UIView *cameraPreviewView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *cameraPreviewLayer;
@property (nonatomic, strong) PBJFocusView *cameraFocusView;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

@property (nonatomic, strong) UIButton *commentCloseButton;
@property (nonatomic, strong) UIButton *submitCommentButton;
@property (nonatomic, strong) NSMutableArray *replies;
@property (nonatomic, strong) UIView *commentsHolderView;
@property (nonatomic, strong) UIView *commentFooterView;
@property (nonatomic, strong) HONStatusUpdateFooterView *statusUpdateFooterView;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSTimer *expireTimer;
@property (nonatomic, strong) UILabel *expireLabel;

@property (nonatomic, strong) HONImageRevealerView *revealerView;

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
		pasteboard.string = [NSString stringWithFormat:@"http://popup.vlly.im/%d/", _statusUpdateVO.statusUpdateID];
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
			[PubNub sendMessage:[NSString stringWithFormat:@"%d|%.04f_%.04f|__BYE__:", [[HONUserAssistant sharedInstance] activeUserID], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude] toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
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

- (void)_submitTextComment {
	NSDictionary *dict = @{@"user_id"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
						   @"club_id"		: @(_clubVO.clubID),
						   @"img_url"		: [@"coords://" stringByAppendingFormat:@"%.04f_%.04f", [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude],
						   @"subject"		: [NSString stringWithFormat:@"%d;%@|%.04f_%.04f|__TXT__:%@", [[HONUserAssistant sharedInstance] activeUserID], [[HONUserAssistant sharedInstance] activeUsername], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude, _comment],
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
		NSLog(@"\nSEND MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
	}];
	
	_isSubmitting = NO;
}

#pragma mark - Data Calls
- (void)_uploadPhoto:(UIImage *)image {
	__block NSString *filename = [NSString stringWithFormat:@"%d_%@", (int)[[NSDate date] timeIntervalSince1970], [[[HONDeviceIntrinsics sharedInstance] identifierForVendorWithoutSeperators:YES] lowercaseString]];
	NSString *imageURLPrefix = [NSString stringWithFormat:@"%@/%@", [HONAPICaller s3BucketForType:HONAmazonS3BucketTypeClubsSource], filename];
	
	UIImage *processedImage = [[HONImageBroker sharedInstance] prepForUploading:image];
	
	NSLog(@"FILE PREFIX: %@", imageURLPrefix);
	NSLog(@"SRC IMAGE:[%@]", NSStringFromCGSize(image.size));
	NSLog(@"ADJ IMAGE:[%@]", NSStringFromCGSize(processedImage.size));
	
	[[HONAPICaller sharedInstance] uploadPhotoToS3:UIImageJPEGRepresentation(processedImage, [HONImageBroker compressJPEGPercentage]) intoBucketType:HONAmazonS3BucketTypeClubsSource withFilename:filename completion:^(BOOL success, NSError *error) {
		NSLog(@"S3 UPLOADED:[%@]\n%@", NSStringFromBOOL(success), error);
		
		if (success) {
			[PubNub sendMessage:[NSString stringWithFormat:@"%d|%.04f_%.04f|__FIN__:%@", [[HONUserAssistant sharedInstance] activeUserID], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude, filename]
					  toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
						  NSLog(@"\nSEND MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
			}];

			;[_loadingOverlayView outro];
			[self _submitPhotoReplyWithURLPrefix:imageURLPrefix];
		
		} else {
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
}

- (void)_submitPhotoReplyWithURLPrefix:(NSString *)urlPrefix {
	NSDictionary *dict = @{@"user_id"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
						   @"club_id"		: @(_clubVO.clubID),
						   @"img_url"		: urlPrefix,
//						   @"img_url"		: [@"coords://" stringByAppendingFormat:@"%.04f_%.04f", [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude],
						   @"subject"		: [NSString stringWithFormat:@"%d;%@|%.04f_%.04f|__IMG__:%@", [[HONUserAssistant sharedInstance] activeUserID], [[HONUserAssistant sharedInstance] activeUsername], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude, [urlPrefix lastComponentByDelimeter:@"/"]],
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
//	PNChannel *channel = [PNChannel channelWithName:[NSString stringWithFormat:@"%d_%d", _statusUpdateVO.userID, _statusUpdateVO.statusUpdateID] shouldObservePresence:YES];
	
	PNChannel *channel = [[HONPubNubOverseer sharedInstance] channelForStatusUpdate:_statusUpdateVO];
	[PubNub subscribeOn:@[channel]];
	
	[[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
		PNChannel *channel = [channels firstObject];
		
		NSLog(@"\n::: SUBSCRIPTION OBSERVER - [%@](%@)\n", (state == PNSubscriptionProcessSubscribedState) ? @"Subscribed" : (state == PNSubscriptionProcessRestoredState) ? @"Restored" : (state == PNSubscriptionProcessNotSubscribedState) ? @"NotSubscribed" : (state == PNSubscriptionProcessWillRestoreState) ? @"WillRestore" : @"UNKNOWN", channel.name);
		
		if (state == PNSubscriptionProcessSubscribedState || state == PNSubscriptionProcessRestoredState) {
			_channel = channel;
			_participants = 1;
			
			[PubNub sendMessage:[NSString stringWithFormat:@"%d|%.04f_%.04f|__SYN__:", [[HONUserAssistant sharedInstance] activeUserID], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude] toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
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
		NSLog(@"ChatMessageType:[%@]", (commentVO.messageType == HONChatMessageTypeUndetermined) ? @"Undetermined" : (commentVO.messageType == HONChatMessageTypeACK) ? @"ACK" : (commentVO.messageType == HONChatMessageTypeBYE) ? @"BYE": (commentVO.messageType == HONChatMessageTypeTXT) ? @"Text" : (commentVO.messageType == HONChatMessageTypeIMG) ? @"Image" : (commentVO.messageType == HONChatMessageTypeVID) ? @"Video" : @"UNKNOWN");
		NSLog(@"commentVO.userID:[%d]", commentVO.userID);
		
		if (commentVO.messageType == HONChatMessageTypeSYN) {
			if (commentVO.userID != [[HONUserAssistant sharedInstance] activeUserID]) {
				_participants++;
				
				commentVO.textContent = @"just joined";
				[self _appendComment:commentVO];
				
				[PubNub sendMessage:[NSString stringWithFormat:@"%d;%@|%.04f_%.04f|__ACK__:%d", [[HONUserAssistant sharedInstance] activeUserID], [[HONUserAssistant sharedInstance] activeUsername], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude, commentVO.userID] toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
					//NSLog(@"\nSEND MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
				}];
			
			} else {
				NSDictionary *dict = @{@"id"				: @"0",
									   @"msg_id"			: @"0",
									   @"content_type"		: @((int)HONChatMessageTypeBOT),
									   
									   @"owner_member"		: @{@"id"	: @(2392),
																@"name"	: @"Botly"},
									   @"image"				: [@"coords://" stringByAppendingFormat:@"%.04f_%.04f", [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude],
									   @"text"				: @"Welcome to Popup Chat!",
									   
									   @"net_vote_score"	: @(0),
									   @"status"			: NSStringFromInt(0),
									   @"added"				: [NSDate stringFormattedISO8601],
									   @"updated"			: [NSDate stringFormattedISO8601]};
				
				[self _appendComment:[HONCommentVO commentWithDictionary:dict]];
			}
			
		} else if (commentVO.messageType == HONChatMessageTypeBOT) {
			[self _appendComment:commentVO];
			
		} else if (commentVO.messageType == HONChatMessageTypeACK) {
			if ([commentVO.textContent intValue] == [[HONUserAssistant sharedInstance] activeUserID])
				_participants++;
		
		} else if (commentVO.messageType == HONChatMessageTypeBYE) {
			_participants = MAX(0, --_participants);
			
			if (commentVO.userID != [[HONUserAssistant sharedInstance] activeUserID]) {
				commentVO.textContent = @"just left";
				[self _appendComment:commentVO];
			}
		
		} else if (commentVO.messageType == HONChatMessageTypeTXT) {
			[self _appendComment:commentVO];
		
		} else if (commentVO.messageType == HONChatMessageTypeIMG) {
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
			
			void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
				NSLog(@"SOURCE IMAGE:[%@] (%.06f)", NSStringFromCGSize(image.size), [[HONImageBroker sharedInstance] aspectRatioForImage:image]);
				[self _appendComment:commentVO];
			};
			
			//NSLog(@"URL:[%@]", [commentVO.imagePrefix stringByAppendingString:kPhotoHDSuffix]);
			[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[commentVO.imagePrefix stringByAppendingString:kPhotoHDSuffix]]
																cachePolicy:kOrthodoxURLCachePolicy
															timeoutInterval:[HONAPICaller timeoutInterval]]
							  placeholderImage:nil
									   success:imageSuccessBlock
									   failure:nil];
			
		} else if (commentVO.messageType == HONChatMessageTypeVID) {
			_moviePlayer.contentURL = [NSURL URLWithString:[@"https://d1fqnfrnudpaz6.cloudfront.net/" stringByAppendingString:commentVO.textContent]];
			_moviePlayer.view.hidden = NO;
			[_moviePlayer play];
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
				_moviePlayer.view.hidden = YES;
			});
			
			[self _appendComment:commentVO];
	
		} else {
			NSLog(@"UNKNOWN COMMENT TYPE [%d]", (int)commentVO.messageType);
		}
		
		if (_expireTimer != nil) {
			[_expireTimer invalidate];
			_expireTimer = nil;
		}
		
		if (_participants < 2) {
//			if ([_commentTextField isFirstResponder])
//				[self _goCancelComment];
			
			_expireSeconds = (_expireSeconds == 0) ? 600 : _expireSeconds;
			_expireTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
															target:self selector:@selector(_updateExpireTime)
														  userInfo:nil
														   repeats:YES];
		} else {
			_expireLabel.text = [NSString stringWithFormat:@"%d other %@ here right now…", _participants - 1, (_participants - 1 == 1) ? @"person is" : @"people are"];
		}
	}];
	
//	[[PNObservationCenter defaultCenter] addMessageProcessingObserver:self withBlock:^(PNMessageState state, id data) {
//		NSLog(@"\n::: MESSAGE PROC OBSERVER - [%@](%@)\n", (state == PNMessageSent) ? @"MessageSent" : (state == PNMessageSending) ? @"MessageSending" : (state == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
//	}];
	
	
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
- (void)_goReloadContent {
	[_commentsHolderView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONCommentItemView *view = (HONCommentItemView *)obj;
		[view removeFromSuperview];
	}];
	
	_commentsHolderView.frame = CGRectResizeHeight(_commentsHolderView.frame, 0.0);
	_scrollView.contentSize = CGRectResizeHeight(_scrollView.frame, 0.0).size;
	
	_replies = [NSMutableArray array];
	[self _retrieveStatusUpdate];
}

- (void)_didFinishDataRefresh {
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
			
			int mins = _expireSeconds / 60;
			int secs = _expireSeconds % 60;
			
			_expireLabel.text = [NSString stringWithFormat:[[NSUserDefaults standardUserDefaults] objectForKey:@"expire_interval"], mins, secs];
			
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
	pasteboard.string = [NSString stringWithFormat:@"http://popup.vlly.im/%d/", _statusUpdateVO.statusUpdateID];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - enter"];
	
	self.view.backgroundColor = [UIColor blackColor];// [UIColor colorWithRed:0.337 green:0.239 blue:0.510 alpha:1.00];
	
	_isActive = YES;
	_isSubmitting = NO;
	
	_comment = @"";
	_expireSeconds = 600;
	_participants = 0;
	
//	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"placeholderClubPhoto_%.fx%.f", [[HONDeviceIntrinsics sharedInstance] scaledScreenSize].width, [[HONDeviceIntrinsics sharedInstance] scaledScreenSize].height]]];
//	bgImageView.frame = CGRectResize(bgImageView.frame, [[HONDeviceIntrinsics sharedInstance] scaledScreenSize]);
//	[self.view addSubview:bgImageView];
	
	_cameraPreviewView = [[UIView alloc] initWithFrame:CGRectFromSize(self.view.frame.size)];
	_cameraPreviewView.alpha = 0.5;
	_cameraPreviewLayer = [[PBJVision sharedInstance] previewLayer];
	_cameraPreviewLayer.frame = _cameraPreviewView.bounds;
	_cameraPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[_cameraPreviewView.layer addSublayer:_cameraPreviewLayer];
	[self.view addSubview:_cameraPreviewView];
	[[PBJVision sharedInstance] setPresentationFrame:_cameraPreviewView.frame];
	
//	NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"];
//	_moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
	_moviePlayer = [[MPMoviePlayerController alloc] init];//WithContentURL:[NSURL URLWithString:@"https://d1fqnfrnudpaz6.cloudfront.net/video_97D31566-55C7-4142-9ED7-FAA62BF54DB1.mp4"]];
	_moviePlayer.controlStyle = MPMovieControlStyleNone;
	_moviePlayer.shouldAutoplay = YES;
	_moviePlayer.view.frame = self.view.frame;
	_moviePlayer.view.hidden = YES;
	[self.view addSubview:_moviePlayer.view];
	//[moviePlayer setFullscreen:NO animated:YES];
	
	_statusUpdateHeaderView = [[HONStatusUpdateHeaderView alloc] initWithStatusUpdateVO:_statusUpdateVO];
	_statusUpdateHeaderView.delegate = self;
	
	_statusUpdateFooterView = [[HONStatusUpdateFooterView alloc] init];
//	_statusUpdateFooterView.backgroundColor = [[HONColorAuthority sharedInstance] honDebugDefaultColor];
	_statusUpdateFooterView.delegate = self;
	
	_commentFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 53.0, self.view.frame.size.width, 53.0)];
	_commentFooterView.backgroundColor = [UIColor blackColor];
//	_commentFooterView.hidden = YES;
	
	_expireLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, self.view.frame.size.height - 120.0, self.view.frame.size.width - 20.0, 22.0)];
	_expireLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
	_expireLabel.backgroundColor = [UIColor clearColor];
	_expireLabel.textColor = [UIColor whiteColor];
	_expireLabel.text = @"";
	
	_scrollView = [[HONScrollView alloc] initWithFrame:CGRectMake(0.0, _statusUpdateHeaderView.frameEdges.bottom, self.view.frame.size.width, self.view.frame.size.height - (_statusUpdateHeaderView.frameEdges.bottom + _statusUpdateFooterView.frame.size.height + _expireLabel.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height))];
//	_scrollView.backgroundColor = [[HONColorAuthority sharedInstance] honDebugColor:HONDebugGreenColor];
	_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, 0.0);
	_scrollView.contentInset = UIEdgeInsetsMake(MAX(0.0, (_scrollView.frame.size.height - _commentsHolderView.frame.size.height)), _scrollView.contentInset.left, 10.0, _scrollView.contentInset.right);
	_scrollView.alwaysBounceVertical = YES;
	_scrollView.delegate = self;
	[self.view addSubview:_scrollView];
	
	[self.view addSubview:_statusUpdateHeaderView];
	[self.view addSubview:_statusUpdateFooterView];
	[self.view addSubview:_commentFooterView];
	[self.view addSubview:_expireLabel];
	
	_commentsHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _scrollView.frame.size.width, 0.0)];
	[_scrollView addSubview:_commentsHolderView];
	
	_commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 13.0, _commentsHolderView.frame.size.width - 100.0, 23.0)];
	_commentTextField.backgroundColor = [UIColor blackColor];
	[_commentTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_commentTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_commentTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_commentTextField setReturnKeyType:UIReturnKeySend];
	[_commentTextField setTextColor:[UIColor whiteColor]];
	[_commentTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	_commentTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
	_commentTextField.keyboardType = UIKeyboardTypeDefault;
	_commentTextField.placeholder = NSLocalizedString(@"enter_comment", @"Comment");
	_commentTextField.text = @"";
	_commentTextField.delegate = self;
	[_commentFooterView addSubview:_commentTextField];
	
	_submitCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitCommentButton.frame = CGRectMake(_commentFooterView.frame.size.width - 80.0, 0.0, 79.0, 53.0);
	[_submitCommentButton setBackgroundImage:[UIImage imageNamed:@"submitCommentButton_nonActive"] forState:UIControlStateNormal];
	[_submitCommentButton setBackgroundImage:[UIImage imageNamed:@"submitCommentButton_Active"] forState:UIControlStateHighlighted];
	[_submitCommentButton setBackgroundImage:[UIImage imageNamed:@"submitCommentButton_Disabled"] forState:UIControlStateDisabled];
	[_submitCommentButton addTarget:self action:@selector(_goTextComment) forControlEvents:UIControlEventTouchUpInside];
	[_submitCommentButton setEnabled:NO];
	[_commentFooterView addSubview:_submitCommentButton];
	
	_commentCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_commentCloseButton.frame = CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - (kNavHeaderHeight + 260.0));
	[_commentCloseButton addTarget:self action:@selector(_goCancelComment) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
	[self _goReloadContent];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:animated:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewDidAppear:animated];
	
//	if ([_statusUpdateVO.comment isEqualToString:@"YES"]) {
//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Popup link has been copied to your clipboard!"
//															message:[NSString stringWithFormat:@"popup.vlly.im/%d/\nYour Popup will expire in 10 minutes if no one joins. Would you like to share now?", _statusUpdateVO.statusUpdateID]
//														   delegate:self
//												  cancelButtonTitle:@"Share Popup"
//												  otherButtonTitles:NSLocalizedString(@"What's a Popup?", nil), @"Cancel", nil];
//		[alertView setTag:HONStatusUpdateAlertViewTypeIntro];
//		[alertView show];
//	}
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
		[alertView setTag:HONStatusUpdateAlertViewTypeBack];
		[alertView show];
	
	} else
		[self _popBack];
}


- (void)_goShare {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - share"];
	
	NSDictionary *metaData = @{@"type"		: @((int)HONSocialActionTypeShare),
							   @"deeplink"	: NSStringFromInt(_statusUpdateVO.statusUpdateID),
							   @"title"		: [NSString stringWithFormat:@"Popup link has been copied to your clipboard!\nhttp://popup.vlly.im/%d\nShare now for people to join.", _statusUpdateVO.statusUpdateID],
							   @"message"	: [NSString stringWithFormat:@"Join my Popup! (expires in 10 mins) http://popup.vlly.im/%d/", _statusUpdateVO.statusUpdateID]};
	
	[UIPasteboard generalPasteboard].string = [metaData objectForKey:@"message"];
	[[NSUserDefaults standardUserDefaults] replaceObject:metaData forKey:@"share_props"];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:(metaData != nil) ? [metaData objectForKey:@"title"] : nil
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Copy Chat URL", @"Share on SMS", @"Share Kik", @"Share Line", @"Share Kakao", nil];
	[actionSheet setTag:0];
	[actionSheet showInView:self.view];
	
}

- (void)_goFlag {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - flag"];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
														message:NSLocalizedString(@"alert_flag_m", nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
											  otherButtonTitles:NSLocalizedString(@"alert_ok", nil), nil];
	[alertView setTag:HONStatusUpdateAlertViewTypeFlag];
	[alertView show];
}

- (void)_goImageComment {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - photo"];
	
	_loadingOverlayView = [[HONLoadingOverlayView alloc] init];
	_loadingOverlayView.delegate = self;
//	[_statusUpdateFooterView toggleTakePhotoButton:NO];
	[[PBJVision sharedInstance] capturePhoto];
}

- (void)_goTextComment {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - comment"];
	
	_isSubmitting = YES;
	[_submitCommentButton setEnabled:NO];
	
	_comment = _commentTextField.text;
	_commentTextField.text = @"";
	
	[self _submitTextComment];
}

- (void)_goActivateTextComment {
	if (![_commentTextField isFirstResponder])
		[_commentTextField becomeFirstResponder];
}

- (void)_goCancelComment {
	_commentTextField.text = @"";
	if ([_commentTextField isFirstResponder])
		[_commentTextField resignFirstResponder];
	
//	_commentFooterView.hidden = YES;
	_scrollView.frame = CGRectResizeHeight(_scrollView.frame, self.view.frame.size.height - (_statusUpdateHeaderView.frameEdges.bottom + _statusUpdateFooterView.frame.size.height + _expireLabel.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height));
	
	if (_scrollView.contentSize.height - _scrollView.frame.size.height > 0)
		[_scrollView setContentOffset:CGPointMake(0.0, MAX(0.0, _scrollView.contentSize.height - _scrollView.frame.size.height)) animated:YES];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
//		_statusUpdateHeaderView.frame = CGRectTranslateY(_statusUpdateHeaderView.frame, kNavHeaderHeight);
//		_scrollView.frame = CGRectTranslateY(_scrollView.frame, _statusUpdateHeaderView.frameEdges.bottom);
//		_scrollView.frame = CGRectOffsetY(_scrollView.frame, _statusUpdateHeaderView.frame.size.height);
		_commentFooterView.frame = CGRectTranslateY(_commentFooterView.frame, self.view.frame.size.height - _commentFooterView.frame.size.height);
		_expireLabel.frame = CGRectTranslateY(_expireLabel.frame, _scrollView.frameEdges.bottom);
		[_scrollView setContentInset:UIEdgeInsetsMake(MAX(0.0, (_scrollView.frame.size.height - _commentsHolderView.frame.size.height)), _scrollView.contentInset.left, _scrollView.contentInset.bottom, _scrollView.contentInset.right)];
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
- (void)_appEnteringBackground:(NSNotification *)notification {
	_isActive = NO;
}

- (void)_appLeavingBackground:(NSNotification *)notification {
	_isActive = YES;
}


- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
//	NSLog(@"UITextFieldTextDidChangeNotification:[%@]", [notification object]);
	UITextField *textField = (UITextField *)[notification object];
	
#if __APPSTORE_BUILD__ == 0
	if ([textField.text isEqualToString:@"¡"]) {
		textField.text = [[[HONDeviceIntrinsics sharedInstance] phoneNumber] substringFromIndex:2];
	}
#endif
	
	[_submitCommentButton setEnabled:([textField.text length] > 0)];
//	if ([textField.text length] == 0)
//		[textField resignFirstResponder];
}


#pragma mark - UI Presentation
- (void)_setupCamera {
	PBJVision *vision = [PBJVision sharedInstance];
	vision.delegate = self;
	vision.cameraDevice = ([vision isCameraDeviceAvailable:PBJCameraDeviceBack]) ? PBJCameraDeviceBack : PBJCameraDeviceFront;
//	vision.cameraMode = PBJCameraModePhoto;
	vision.cameraMode = PBJCameraModeVideo;
	vision.cameraOrientation = PBJCameraOrientationPortrait;
	vision.focusMode = PBJFocusModeContinuousAutoFocus;
	vision.outputFormat = PBJOutputFormatStandard;
	vision.videoRenderingEnabled = NO;
	vision.additionalCompressionProperties = @{AVVideoProfileLevelKey : AVVideoProfileLevelH264Baseline30}; // AVVideoProfileLevelKey requires specific captureSessionPreset
}

- (void)_appendComment:(HONCommentVO *)vo {
	NSLog(@"_appendComment:[%@]", (vo.messageType == HONChatMessageTypeSYN) ? @"SYN" : (vo.messageType == HONChatMessageTypeBOT) ? @"BOT" :(vo.messageType == HONChatMessageTypeACK) ? @"ACK" : (vo.messageType == HONChatMessageTypeBYE) ? @"BYE": (vo.messageType == HONChatMessageTypeTXT) ? @"Text" : (vo.messageType == HONChatMessageTypeIMG) ? @"Image" : (vo.messageType == HONChatMessageTypeVID) ? @"Video" : @"UNKNOWN");
	[_replies addObject:vo];
	
	CGFloat offset = 33.0;
	HONCommentItemView *itemView = [[HONCommentItemView alloc] initWithFrame:CGRectMake(0.0, offset + _commentsHolderView.frame.size.height, self.view.frame.size.width, 38.0)];
	itemView.delegate = self;
	itemView.commentVO = vo;
	itemView.alpha = 0.0;
	[_commentsHolderView addSubview:itemView];
	
	_commentsHolderView.frame = CGRectExtendHeight(_commentsHolderView.frame, itemView.frame.size.height);
	
	[UIView animateKeyframesWithDuration:0.25 delay:0.00
								 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut)
							  animations:^(void) {
		itemView.alpha = 1.0;
		itemView.frame = CGRectOffsetY(itemView.frame, -offset);
	} completion:^(BOOL finished) {
	}];

	_scrollView.contentSize = _commentsHolderView.frame.size;
	[_scrollView setContentInset:UIEdgeInsetsMake(MAX(0.0, (_scrollView.frame.size.height - _commentsHolderView.frame.size.height)), _scrollView.contentInset.left, _scrollView.contentInset.bottom, _scrollView.contentInset.right)];
	if (_scrollView.frame.size.height - _commentsHolderView.frame.size.height < 0)
		[_scrollView setContentOffset:CGPointMake(0.0, MAX(0.0, _scrollView.contentSize.height - _scrollView.frame.size.height)) animated:NO];
}

- (void)_popBack {
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	
	if (_expireTimer != nil) {
		[_expireTimer invalidate];
		_expireTimer = nil;
	}
	
//	UIView *matteView = [[UIView alloc] initWithFrame:CGRectFromSize(CGSizeMake(84.0, 44.0))];
//	matteView.backgroundColor = [UIColor blackColor];
//	[_statusUpdateHeaderView addSubview:matteView];
//	
	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	activityIndicatorView.frame = CGRectOffset(activityIndicatorView.frame, 11.0, 11.0);
	[activityIndicatorView startAnimating];
	[_statusUpdateHeaderView addSubview:activityIndicatorView];
	
//	UILabel *backLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 11.0, 120.0, 20.0)];
//	backLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:17];
//	backLabel.backgroundColor = [UIColor clearColor];
//	backLabel.textColor = [UIColor whiteColor];
//	backLabel.text = @"Deleting…";
//	[_statusUpdateHeaderView addSubview:backLabel];
	
	
	[PubNub sendMessage:[NSString stringWithFormat:@"%d|%.04f_%.04f|__BYE__:", [[HONUserAssistant sharedInstance] activeUserID], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude] toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
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
			messageComposeViewController.body = [NSString stringWithFormat:@"http://popup.vlly.im/%d/", _statusUpdateVO.statusUpdateID];
			messageComposeViewController.messageComposeDelegate = self;
			[self presentViewController:messageComposeViewController animated:YES completion:^(void) {}];
		}
		
		//	} else if (buttonType == HONChannelInviteButtonTypeEmail) {
		//		typeName = @"Email";
		
	} else if (buttonType == HONChannelInviteButtonTypeKakao) {
		typeName = @"Kakao";
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


#pragma mark - CommentItemView Delegates
- (void)commentItemView:(HONCommentItemView *)commentItemView hidePhotoForComment:(HONCommentVO *)commentVO {
	NSLog(@"[*:*] commentItemView:hidePhotoForComment:[%@] [*:*]", commentVO.imagePrefix);
	
	if (_revealerView != nil)
		[_revealerView outro];
}

- (void)commentItemView:(HONCommentItemView *)commentItemView showPhotoForComment:(HONCommentVO *)commentVO {
	NSLog(@"[*:*] commentItemView:showPhotoForComment:[%@] [*:*]", commentVO.imagePrefix);
	
	if (_revealerView != nil) {
		if (_revealerView.superview != nil)
			[_revealerView removeFromSuperview];
		
		_revealerView.delegate = nil;
		_revealerView = nil;
	}
	
	_revealerView = [[HONImageRevealerView alloc] initWithComment:commentVO];
	_revealerView.delegate = self;
	[self.view addSubview:_revealerView];
}


#pragma mark - HONImageRevealerView Delegates
- (void)imageRevealerViewDidIntro:(HONImageRevealerView *)imageRevealerView {
	NSLog(@"[*:*] imageRevealerViewDidIntro [*:*]");
}

- (void)imageRevealerViewDidOutro:(HONImageRevealerView *)imageRevealerView {
	NSLog(@"[*:*] imageRevealerViewDidOutro [*:*]");
	
	if (imageRevealerView != nil) {
		if (imageRevealerView.superview != nil)
			[imageRevealerView removeFromSuperview];
		
		imageRevealerView.delegate = nil;
		imageRevealerView = nil;
	}
}


#pragma mark - StatusUpdateFooterView Delegates
- (void)statusUpdateFooterViewEnterComment:(HONStatusUpdateFooterView *)statusUpdateFooterView {
	NSLog(@"[*:*] statusUpdateFooterViewEnterComment [*:*]");
	
//	_commentFooterView.hidden = NO;
	if (![_commentTextField isFirstResponder])
		[_commentTextField becomeFirstResponder];
}

- (void)statusUpdateFooterViewShowShare:(HONStatusUpdateFooterView *)statusUpdateFooterView {
	NSLog(@"[*:*] statusUpdateFooterViewShowShare [*:*]");
	[self _goShare];
}

- (void)statusUpdateFooterViewTakePhoto:(HONStatusUpdateFooterView *)statusUpdateFooterView {
	NSLog(@"[*:*] statusUpdateFooterViewTakePhoto [*:*]");
	//[self _goImageComment];
	
	[[PBJVision sharedInstance] startVideoCapture];
	_statusUpdateHeaderView.hidden = YES;
	_statusUpdateFooterView.hidden = YES;
	_scrollView.hidden = YES;
	_expireLabel.hidden = YES;
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
		[[PBJVision sharedInstance] endVideoCapture];
		_statusUpdateHeaderView.hidden = NO;
		_statusUpdateFooterView.hidden = NO;
		_scrollView.hidden = NO;
		_expireLabel.hidden = NO;
	});
}


#pragma mark - StatusUpdateHeaderView Delegates
- (void)statusUpdateHeaderViewChangeCamera:(HONStatusUpdateHeaderView *)statusUpdateHeaderView {
	NSLog(@"[*:*] statusUpdateHeaderViewChangeCamera [*:*]");
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - flip_camera"];
	
	PBJVision *vision = [PBJVision sharedInstance];
	vision.cameraDevice = (vision.cameraDevice == PBJCameraDeviceBack) ? PBJCameraDeviceFront : PBJCameraDeviceBack;
}

- (void)statusUpdateHeaderViewCopyLink:(HONStatusUpdateHeaderView *)statusUpdateHeaderView {
	NSLog(@"[*:*] statusUpdateHeaderViewCopyLink [*:*]");
	[self _goShare];
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
	
	_scrollView.frame = CGRectResizeHeight(_scrollView.frame, self.view.frame.size.height - (_statusUpdateHeaderView.frameEdges.bottom + _commentFooterView.frame.size.height + _expireLabel.frame.size.height + 216.0));
	
	if (_scrollView.contentSize.height - _scrollView.frame.size.height > 0)
		[_scrollView setContentOffset:CGPointMake(0.0, MAX(0.0, _scrollView.contentSize.height - _scrollView.frame.size.height)) animated:YES];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
//		 _statusUpdateHeaderView.frame = CGRectTranslateY(_statusUpdateHeaderView.frame, kNavHeaderHeight - _statusUpdateHeaderView.frame.size.height);
//		 _scrollView.frame = CGRectTranslateY(_scrollView.frame, _statusUpdateHeaderView.frameEdges.bottom);
//		_scrollView.frame = CGRectOffsetY(_scrollView.frame, -_statusUpdateHeaderView.frame.size.height);
		
		[_scrollView setContentInset:UIEdgeInsetsMake(MAX(0.0, (_scrollView.frame.size.height - _commentsHolderView.frame.size.height)), _scrollView.contentInset.left, _scrollView.contentInset.bottom, _scrollView.contentInset.right)];
		_expireLabel.frame = CGRectTranslateY(_expireLabel.frame, _scrollView.frameEdges.bottom);
		 _commentFooterView.frame = CGRectTranslateY(_commentFooterView.frame, self.view.frame.size.height - (_commentFooterView.frame.size.height + 216.0));
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
	if (actionSheet.tag == 0) {
		if (buttonIndex == 0) {
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - copy_clipboard"];
			
			[[[UIAlertView alloc] initWithTitle:@"Paste anywhere to share!"
										message:@""
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
		
		} else if (buttonIndex == 1) {
			if ([MFMessageComposeViewController canSendText]) {
				MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
				messageComposeViewController.body = [NSString stringWithFormat:@"Join my Popup! (expires in 10 mins) http://popup.vlly.im/%d/", _statusUpdateVO.statusUpdateID];
				messageComposeViewController.messageComposeDelegate = self;
				
				[self presentViewController:messageComposeViewController animated:YES completion:^(void) {}];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"SMS Error"
											message:@"Cannot send SMS from this device!"
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
			}
			
		} else if (buttonIndex == 2) {
			NSString *typeName = @"";
			NSString *urlSchema = @"";
			
			typeName = @"Kik";
			urlSchema = @"kik://";
			
			if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlSchema]]) {
				[[[UIAlertView alloc] initWithTitle:@"Not Avialable"
											message:[NSString stringWithFormat:@"This device isn't allowed or doesn't recognize %@!", typeName]
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
				
			} else {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlSchema]];
			}
		
		} else if (buttonIndex == 3) {
			NSString *typeName = @"";
			NSString *urlSchema = @"";
			
			if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlSchema]]) {
				[[[UIAlertView alloc] initWithTitle:@"Not Avialable"
											message:[NSString stringWithFormat:@"This device isn't allowed or doesn't recognize %@!", typeName]
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
				
			} else {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlSchema]];
			}
		
		} else if (buttonIndex == 4) {
			NSString *typeName = @"";
			NSString *urlSchema = @"";
			
			typeName = @"Kakao";
			urlSchema = @"kakaolink://";
			
			if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlSchema]]) {
				[[[UIAlertView alloc] initWithTitle:@"Not Avialable"
											message:[NSString stringWithFormat:@"This device isn't allowed or doesn't recognize %@!", typeName]
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
				
			} else {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlSchema]];
			}
		}
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	if (alertView.tag == HONStatusUpdateAlertViewTypeIntro) {
		if (buttonIndex == 0) {
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - intro_share"];

			[self _goShare];
			
		} else if (buttonIndex == 1) {
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - intro_help"];

			[[[UIAlertView alloc] initWithTitle:nil
										message:@"A Popup is real time chat that can only be accessed by sharing a unique a Popup link. The link will only work on mobile and only work if the user has the Popup application installed."
										delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
			
		} else if (buttonIndex == 2) {
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - intro_cancel"];
		}
		
	} else if (alertView.tag == HONStatusUpdateAlertViewTypeBack) {
		if (buttonIndex == 1) {
			[[NSUserDefaults standardUserDefaults] setObject:NSStringFromBOOL(YES) forKey:@"back_chat"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			[self _popBack];
		}
	} else if (alertView.tag == HONStatusUpdateAlertViewTypeFlag) {
		if (buttonIndex == 1) {
			[self _flagStatusUpdate];
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
	
	//[_cameraPreviewView removeFromSuperview];
}

// preview
- (void)visionSessionDidStartPreview:(PBJVision *)vision {
	NSLog(@"[*:*] visionSessionDidStartPreview [*:*]");
}

- (void)visionSessionDidStopPreview:(PBJVision *)vision {
	NSLog(@"[*:*] visionSessionDidStopPreview [*:*]");
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
		[[PBJVision sharedInstance] startPreview];
	});
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
	NSLog(@"[*:*] vision:capturedPhoto:[%d] error:[%@] [*:*]", [[photoDict objectForKey:PBJVisionPhotoMetadataKey] count], error);
	
	[[PBJVision sharedInstance] stopPreview];
//	[_cameraPreviewView removeFromSuperview];
//	_cameraPreviewView = nil;
//	_cameraPreviewLayer = nil;
//	
//	_cameraPreviewView = [[UIView alloc] initWithFrame:CGRectFromSize(self.view.frame.size)];
//	_cameraPreviewView.alpha = 0.5;
//	_cameraPreviewLayer = [[PBJVision sharedInstance] previewLayer];
//	_cameraPreviewLayer.frame = _cameraPreviewView.bounds;
//	_cameraPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//	[_cameraPreviewView.layer addSublayer:_cameraPreviewLayer];
//	[self.view addSubview:_cameraPreviewView];
//	[[PBJVision sharedInstance] setPresentationFrame:_cameraPreviewView.frame];
	
	if (error != nil) {
		[[[UIAlertView alloc] initWithTitle:@"Error taking photo!"
									message:nil
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
		[_statusUpdateFooterView toggleTakePhotoButton:YES];
		
	} else {
		[_statusUpdateFooterView toggleTakePhotoButton:YES];
		[self _uploadPhoto:[photoDict objectForKey:PBJVisionPhotoImageKey]];
	}
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error {
	NSLog(@"[*:*] vision:capturedVideo:[%@] [*:*]", videoDict);
	
	NSString *bucketName = @"hotornot-challenges";
	
	NSString *path = [videoDict objectForKey:PBJVisionVideoPathKey];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	
	AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
	uploadRequest.bucket = bucketName;
	uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
	uploadRequest.key = [[path pathComponents] lastObject];
	uploadRequest.contentType = @"video/mp4";
	uploadRequest.body = url;
	
	AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
	[[transferManager upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
		if (task.error)
			NSLog(@"AWSS3TransferManager: **ERROR** [%@]", task.error);
		
		else {
			NSLog(@"AWSS3TransferManager: !!SUCCESS!! [%@]", task.error);
			
			[PubNub sendMessage:[NSString stringWithFormat:@"%d|%.04f_%.04f|__VID__:%@", [[HONUserAssistant sharedInstance] activeUserID], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude, [[path pathComponents] lastObject]]
					  toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
						  NSLog(@"\nSEND MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
					  }];
			
		}
		return (nil);
	}];
}


// progress
- (void)vision:(PBJVision *)vision didCaptureVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
	NSLog(@"[*:*] vision:didCaptureVideoSampleBuffer:[%.04f] [*:*]", vision.capturedVideoSeconds);
}

- (void)vision:(PBJVision *)vision didCaptureAudioSample:(CMSampleBufferRef)sampleBuffer {
	NSLog(@"[*:*] vision:didCaptureAudioSample:[%.04f] [*:*]", vision.capturedAudioSeconds);
}


@end
