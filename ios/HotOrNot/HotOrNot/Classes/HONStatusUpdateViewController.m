//
//  HONStatusUpdateViewController.m
//  HotOrNot
//
//  Created by BIM  on 11/20/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

#import <AWSiOSSDKv2/S3.h>

#import "NSArray+BuiltInMenlo.h"
#import "NSCharacterSet+BuiltinMenlo.h"
#import "NSDate+BuiltinMenlo.h"
#import "NSString+BuiltinMenlo.h"
#import "NSDictionary+BuiltInMenlo.h"
#import "PubNub+BuiltInMenlo.h"
#import "UIImageView+AFNetworking.h"
#import "UIView+BuiltinMenlo.h"

#import "KikAPI.h"
#import "PBJVision.h"

#import "HONStatusUpdateViewController.h"
#import "HONCommentItemView.h"
#import "HONScrollView.h"
#import "HONStatusUpdateHeaderView.h"
#import "HONStatusUpdateFooterView.h"
#import "HONChannelInviteButtonView.h"
#import "HONLoadingOverlayView.h"
#import "HONMediaRevealerView.h"

@interface HONStatusUpdateViewController () <HONChannelInviteButtonViewDelegate, HONCommentItemViewDelegate, HONMediaRevealerViewDelegate, HONLoadingOverlayViewDelegate, HONStatusUpdateFooterViewDelegate, HONStatusUpdateHeaderViewDelegate, PBJVisionDelegate>
- (PNChannel *)_channelSetupForStatusUpdate;

@property (nonatomic, strong) PNChannel *channel;
@property (nonatomic, strong) HONStatusUpdateVO *statusUpdateVO;
@property (nonatomic, strong) HONUserClubVO *clubVO;
@property (nonatomic, strong) HONScrollView *scrollView;
@property (nonatomic, strong) HONLoadingOverlayView *loadingOverlayView;
@property (nonatomic, strong) HONStatusUpdateHeaderView *statusUpdateHeaderView;

@property (nonatomic, strong) UIView *cameraPreviewView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *cameraPreviewLayer;
//@property (nonatomic, strong) PBJFocusView *cameraFocusView;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

@property (nonatomic, strong) UIButton *commentCloseButton;
@property (nonatomic, strong) UIButton *submitCommentButton;
@property (nonatomic, strong) UIImageView *footerImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSMutableArray *replies;
@property (nonatomic, strong) UIView *commentsHolderView;
@property (nonatomic, strong) UIView *commentFooterView;
@property (nonatomic, strong) HONStatusUpdateFooterView *statusUpdateFooterView;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSTimer *expireTimer;
@property (nonatomic, strong) NSTimer *durationTimer;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *expireLabel;
@property (nonatomic, strong) CALayer *maskLayer;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *hudView;
@property (nonatomic, strong) NSTimer *tintTimer;
@property (nonatomic, strong) UIButton *takePhotoButton;

@property (nonatomic, strong) HONMediaRevealerView *revealerView;

@property (nonatomic) BOOL isSubmitting;
@property (nonatomic) BOOL isActive;
@property (nonatomic) int expireSeconds;
@property (nonatomic) int participants;
@property (nonatomic) int comments;
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
		
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_playbackStateChanged:)
													 name:MPMoviePlayerPlaybackStateDidChangeNotification object:_moviePlayer];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_playbackEnded:)
													 name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer];
		
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
						  
						  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
							  [_loadingOverlayView outro];
						  });
			}];

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
			_comments = 0;
			
			[PubNub sendMessage:[NSString stringWithFormat:@"%d|%.04f_%.04f|__SYN__:", [[HONUserAssistant sharedInstance] activeUserID], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude] toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
				//NSLog(@"\nSEND MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
			}];
			
		} else if (state == PNSubscriptionProcessNotSubscribedState) {
		} else if (state == PNSubscriptionProcessWillRestoreState) {
		}
	}];
	
	// APNS enabled already?
	[PubNub requestPushNotificationEnabledChannelsForDevicePushToken:[[HONDeviceIntrinsics sharedInstance] dataPushToken]
										 withCompletionHandlingBlock:^(NSArray *channels, PNError *error){
											 if (channels.count == 0 )
											 {
												 NSLog(@"BLOCK: requestPushNotificationEnabledChannelsForDevicePushToken: Channel: %@ , Error %@",channels,error);
												 
												 // Enable APNS on this Channel with deviceToken
												 [PubNub enablePushNotificationsOnChannel:channel
																	  withDevicePushToken:[[HONDeviceIntrinsics sharedInstance] dataPushToken]
															   andCompletionHandlingBlock:^(NSArray *channel, PNError *error){
																   NSLog(@"BLOCK: enablePushNotificationsOnChannel: %@ , Error %@", channel, error);
															   }];
											 }
											 
											 NSLog(@"BLOCK: requestPushNotificationEnabledChannelsForDevicePushToken: Channel: %@",channels);
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
//				NSDictionary *dict = @{@"id"				: @"0",
//									   @"msg_id"			: @"0",
//									   @"content_type"		: @((int)HONChatMessageTypeBOT),
//									   
//									   @"owner_member"		: @{@"id"	: @(2392),
//																@"name"	: @"Botly"},
//									   @"image"				: [@"coords://" stringByAppendingFormat:@"%.04f_%.04f", [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude],
//									   @"text"				: @"Welcome to Popup Chat!",
//									   
//									   @"net_vote_score"	: @(0),
//									   @"status"			: NSStringFromInt(0),
//									   @"added"				: [NSDate stringFormattedISO8601],
//									   @"updated"			: [NSDate stringFormattedISO8601]};
//				
//				[self _appendComment:[HONCommentVO commentWithDictionary:dict]];
//
//				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
//					NSDictionary *dict = @{@"id"				: @"0",
//										   @"msg_id"			: @"0",
//										   @"content_type"		: @((int)HONChatMessageTypeBOT),
//										   
//										   @"owner_member"		: @{@"id"	: @(2392),
//																	@"name"	: @"Botly"},
//										   @"image"				: [@"coords://" stringByAppendingFormat:@"%.04f_%.04f", [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude],
//										   @"text"				: [NSString stringWithFormat:@"changed the topic to “%@”", _statusUpdateVO.subjectName],
//										   
//										   @"net_vote_score"	: @(0),
//										   @"status"			: NSStringFromInt(0),
//										   @"added"				: [NSDate stringFormattedISO8601],
//										   @"updated"			: [NSDate stringFormattedISO8601]};
//					
//					[self _appendComment:[HONCommentVO commentWithDictionary:dict]];
//					
//					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
//						NSDictionary *dict = @{@"id"				: @"0",
//											   @"msg_id"			: @"0",
//											   @"content_type"		: @((int)HONChatMessageTypeAUT),
//											   
//											   @"owner_member"		: @{@"id"	: @(2392),
//																		@"name"	: @"Botly"},
//											   @"image"				: [@"coords://" stringByAppendingFormat:@"%.04f_%.04f", [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude],
//											   @"text"				: [NSString stringWithFormat:@"Share your Popup now! http://popup.vlly.im/%d/", _statusUpdateVO.statusUpdateID],
//											   
//											   @"net_vote_score"	: @(0),
//											   @"status"			: NSStringFromInt(0),
//											   @"added"				: [NSDate stringFormattedISO8601],
//											   @"updated"			: [NSDate stringFormattedISO8601]};
//						
//						[self _appendComment:[HONCommentVO commentWithDictionary:dict]];
//				
//						[[NSUserDefaults standardUserDefaults] setObject:NSStringFromBOOL(YES) forKey:@"chat_share"];
//						[[NSUserDefaults standardUserDefaults] synchronize];
				
//					});
//				});
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
			if (commentVO.userID != [[HONUserAssistant sharedInstance] activeUserID]) {
				void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
					NSLog(@"SOURCE IMAGE:[%@] (%.06f)", NSStringFromCGSize(image.size), [[HONImageBroker sharedInstance] aspectRatioForImage:image]);
					_imageView.image = image;
					_imageView.hidden = NO;
					[self _appendComment:commentVO];
					
					[UIView animateWithDuration:0.333 animations:^(void) {
						_imageView.alpha = 1.0;
					} completion:^(BOOL finished) {
						dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
							[UIView animateWithDuration:0.333
											 animations:^(void) {
												 _imageView.alpha = 0.0;
											 } completion:^(BOOL finished) {
												 _imageView.hidden = YES;
												 _imageView.image = nil;
												 _imageView.alpha = 1.0;
											 }];
						});
					}];
				};
				
				//NSLog(@"URL:[%@]", [commentVO.imagePrefix stringByAppendingString:kPhotoHDSuffix]);
				_imageView.alpha = 0.0;
				[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[commentVO.imagePrefix stringByAppendingString:kPhotoHDSuffix]]
																	cachePolicy:kOrthodoxURLCachePolicy
																timeoutInterval:[HONAPICaller timeoutInterval]]
								  placeholderImage:nil
										   success:imageSuccessBlock
										   failure:nil];
			
			} else
				[self _appendComment:commentVO];
			
		} else if (commentVO.messageType == HONChatMessageTypeVID) {
			//if (_bgView.frame.size.height == self.view.frame.size.height * 0.5) {
				if ([MPMusicPlayerController applicationMusicPlayer].volume != 0.0)
					[[MPMusicPlayerController applicationMusicPlayer] setVolume:0.0];
				
				[UIView animateKeyframesWithDuration:0.25 delay:0.00
											 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut)
										  animations:^(void) {
											  _moviePlayer.view.alpha = 0.0;
										  } completion:^(BOOL finished) {
											  _moviePlayer.contentURL = [NSURL URLWithString:commentVO.imagePrefix];
											  [_moviePlayer play];
										  }];
				
				_statusLabel.text = @"Loading video…";
				//[self _appendComment:commentVO];
			//}
	
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
//			_expireTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
//															target:self selector:@selector(_updateExpireTime)
//														  userInfo:nil
//														   repeats:YES];
		} else {
			_expireLabel.text = [NSString stringWithFormat:@"%d", _participants - 1];
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
			
//			int mins = _expireSeconds / 60;
//			int secs = _expireSeconds % 60;
			
			_expireLabel.text = @"Send a pop…";// [NSString stringWithFormat:[[NSUserDefaults standardUserDefaults] objectForKey:@"expire_interval"], mins, secs];
			
		} else
			[self _popBack];
		
	} else {
		if (_expireTimer != nil) {
			[_expireTimer invalidate];
			_expireTimer = nil;
		}
	}
	
	if (_expireSeconds % 86400 == 0) {
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
}

- (void)_updateTint {
	NSArray *colors = @[[UIColor colorWithRed:0.396 green:0.596 blue:0.922 alpha:1.00],
						[UIColor colorWithRed:0.839 green:0.729 blue:0.400 alpha:1.00],
						[UIColor colorWithRed:0.400 green:0.839 blue:0.698 alpha:1.00],
						[UIColor colorWithRed:0.337 green:0.239 blue:0.510 alpha:1.00]];
	
	UIColor *color = [colors randomElement];
	[UIView animateWithDuration:0.25 animations:^(void) {
		[[HONViewDispensor sharedInstance] tintView:_bgView withColor:color];
	} completion:nil];
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
	
	_bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height * 0.5)];
	_bgView.backgroundColor = [UIColor colorWithRed:0.400 green:0.839 blue:0.698 alpha:1.00];
	[self.view addSubview:_bgView];
	
	_tintTimer = [NSTimer scheduledTimerWithTimeInterval:1.25
												  target:self
												selector:@selector(_updateTint)
												userInfo:nil repeats:YES];
	
	_moviePlayer = [[MPMoviePlayerController alloc] init];//WithContentURL:[NSURL URLWithString:@"https://d1fqnfrnudpaz6.cloudfront.net/video_97D31566-55C7-4142-9ED7-FAA62BF54DB1.mp4"]];
	_moviePlayer.controlStyle = MPMovieControlStyleNone;
	_moviePlayer.shouldAutoplay = YES;
	_moviePlayer.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height * 0.5);
	_moviePlayer.view.alpha = 0.0;
	[self.view addSubview:_moviePlayer.view];
	
//	UIScrollView *irisScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height * 0.5)];
//	irisScrollView.contentSize = CGSizeMake(self.view.frame.size.width * 4.0, self.view.frame.size.height * 0.5);
//	irisScrollView.pagingEnabled = YES;
	
	_cameraPreviewView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height * 0.5, self.view.frame.size.width, self.view.frame.size.height * 0.5)];
	_cameraPreviewView.backgroundColor = [UIColor blackColor];
	
	//_cameraPreviewView.hidden = YES;
	_cameraPreviewLayer = [[PBJVision sharedInstance] previewLayer];
	_cameraPreviewLayer.opacity = 0.33;
	_cameraPreviewLayer.frame = _cameraPreviewView.bounds;
	_cameraPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[_cameraPreviewView.layer addSublayer:_cameraPreviewLayer];
	[self.view addSubview:_cameraPreviewView];
	[[PBJVision sharedInstance] setPresentationFrame:_cameraPreviewView.frame];
	
	_imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
	_imageView.hidden = YES;
	[self.view addSubview:_imageView];
	
	_statusUpdateHeaderView = [[HONStatusUpdateHeaderView alloc] initWithStatusUpdateVO:_statusUpdateVO];
	_statusUpdateHeaderView.delegate = self;
	
	_statusUpdateFooterView = [[HONStatusUpdateFooterView alloc] init];
	_statusUpdateFooterView.delegate = self;
	
	_commentFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 55.0, self.view.frame.size.width, 55.0)];
	//_commentFooterView.backgroundColor = [UIColor blackColor];
	
	_footerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commentInput2BG"]];
	_footerImageView.frame = CGRectOffset(_footerImageView.frame, 10.0, -10.0);
	[_commentFooterView addSubview:_footerImageView];
	
	_expireLabel = [[UILabel alloc] initWithFrame:CGRectMake(45.0, (self.view.frame.size.height * 0.5) + 11.0, 100.0, 22.0)];
	_expireLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:20];
	_expireLabel.backgroundColor = [UIColor clearColor];
	_expireLabel.textColor = [UIColor whiteColor];
	_expireLabel.text = @"1";
	
//	_scrollView = [[HONScrollView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height * 0.5, self.view.frame.size.width, (self.view.frame.size.height * 0.5) - _commentFooterView.frame.size.height)];
	_scrollView = [[HONScrollView alloc] initWithFrame:CGRectMake(0.0, _statusUpdateHeaderView.frameEdges.bottom, self.view.frame.size.width, self.view.frame.size.height - (_statusUpdateHeaderView.frameEdges.bottom + 15.0 + [UIApplication sharedApplication].statusBarFrame.size.height))];
	//_scrollView.backgroundColor = [[HONColorAuthority sharedInstance] honDebugColor:HONDebugGreenColor];
	_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, 0.0);
	_scrollView.contentInset = UIEdgeInsetsMake(MAX(0.0, (_scrollView.frame.size.height - _commentsHolderView.frame.size.height)), _scrollView.contentInset.left, 10.0, _scrollView.contentInset.right);
	_scrollView.alwaysBounceVertical = YES;
	_scrollView.delegate = self;
	[self.view addSubview:_scrollView];
	
	_hudView = [[UIView alloc] initWithFrame:self.view.frame];
	[self.view addSubview:_hudView];
	
//	UIView *maskView = [[UIView alloc] initWithFrame:self.view.frame];
//	maskView.layer.frame = CGRectMake(0.0, self.view.frame.size.height * 0.5, self.view.frame.size.width, self.view.frame.size.height * 0.5);
//	maskView.backgroundColor = [UIColor blackColor];
//	
//	_maskLayer = maskView.layer;
//	_scrollView.layer.mask = _maskLayer;
//	_scrollView.layer.masksToBounds = YES;

	
	[self.view addSubview:_statusUpdateHeaderView];
	[self.view addSubview:_commentFooterView];
	
	_takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_takePhotoButton.frame = CGRectMake((self.view.frame.size.width - 74.0), self.view.frame.size.height - 74.0, 64.0, 64.0);
	[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_nonActive"] forState:UIControlStateNormal];
	[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_Active"] forState:UIControlStateHighlighted];
	[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButtonDisabled"] forState:UIControlStateDisabled];
	[_takePhotoButton addTarget:self action:@selector(_goImageComment) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_takePhotoButton];
	
	UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
	flagButton.frame = CGRectMake(self.view.frame.size.width - 44.0, (self.view.frame.size.height * 0.5) - 44.0, 84.0, 44.0);
	[flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_nonActive"] forState:UIControlStateNormal];
	[flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_Active"] forState:UIControlStateHighlighted];
	[flagButton addTarget:self action:@selector(_goFlag) forControlEvents:UIControlEventTouchUpInside];
	[_hudView addSubview:flagButton];
	
	UIImageView *participantsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"participantsIcon"]];
	participantsImageView.frame = CGRectOffset(participantsImageView.frame, 0.0, self.view.frame.size.height * 0.5);
	[_hudView addSubview:participantsImageView];
	
	_statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 165.0, self.view.frame.size.width - 20.0, 30.0)];
	_statusLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:26];
	_statusLabel.backgroundColor = [UIColor clearColor];
	_statusLabel.textColor = [UIColor whiteColor];
	_statusLabel.text = @"Send a pop…";
	[_bgView addSubview:_statusLabel];
	
	UIButton *cameraFlipButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cameraFlipButton.frame = CGRectMake(self.view.frame.size.width - 52.0, (self.view.frame.size.height * 0.5) + 5.0, 52.0, 46.0);
	[cameraFlipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_nonActive"] forState:UIControlStateNormal];
	[cameraFlipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_Active"] forState:UIControlStateHighlighted];
	[cameraFlipButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
	[_hudView addSubview:cameraFlipButton];
	
	[_hudView addSubview:_expireLabel];
	
	_commentsHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _scrollView.frame.size.width, 0.0)];
	[_scrollView addSubview:_commentsHolderView];
	
	_commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 12.0, _commentsHolderView.frame.size.width - 100.0, 23.0)];
	_commentTextField.backgroundColor = [UIColor clearColor];
	[_commentTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_commentTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_commentTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_commentTextField setReturnKeyType:UIReturnKeySend];
	[_commentTextField setTextColor:[UIColor whiteColor]];
	[_commentTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	_commentTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
	_commentTextField.keyboardType = UIKeyboardTypeDefault;
	_commentTextField.placeholder = @"";
	_commentTextField.text = @"";
	_commentTextField.delegate = self;
	[_commentFooterView addSubview:_commentTextField];
	
	_submitCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitCommentButton.frame = CGRectMake(_commentFooterView.frame.size.width - 46.0, 0.0, 46.0, 46.0);
	[_submitCommentButton setBackgroundImage:[UIImage imageNamed:@"submitCommentButton_nonActive"] forState:UIControlStateNormal];
	[_submitCommentButton setBackgroundImage:[UIImage imageNamed:@"submitCommentButton_Active"] forState:UIControlStateHighlighted];
	[_submitCommentButton setBackgroundImage:[UIImage imageNamed:@"submitCommentButton_Disabled"] forState:UIControlStateDisabled];
	[_submitCommentButton addTarget:self action:@selector(_goTextComment) forControlEvents:UIControlEventTouchUpInside];
	_submitCommentButton.hidden = YES;
	[_commentFooterView addSubview:_submitCommentButton];
	
	_commentCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_commentCloseButton.frame = CGRectMake(0.0, 0.0, 320.0, self.view.frame.size.height - (260.0));
	[_commentCloseButton addTarget:self action:@selector(_goCancelComment) forControlEvents:UIControlEventTouchUpInside];
	
	UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	lpGestureRecognizer.minimumPressDuration = 0.25;
	lpGestureRecognizer.delaysTouchesBegan = YES;
	[self.view addGestureRecognizer:lpGestureRecognizer];
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
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"0428Cohort - shareiOS" withProperties:@{@"chat"	: @(_statusUpdateVO.statusUpdateID)}];
	
	NSDictionary *metaData = @{@"type"		: @((int)HONSocialActionTypeShare),
							   @"deeplink"	: NSStringFromInt(_statusUpdateVO.statusUpdateID),
							   @"title"		: [NSString stringWithFormat:@"Popup link has been copied to your clipboard!\nhttp://popup.vlly.im/%d\nShare now for people to join.", _statusUpdateVO.statusUpdateID],
							   @"message"	: [NSString stringWithFormat:@"Join my Popup! (expires in 10 mins) http://popup.vlly.im/%d/", _statusUpdateVO.statusUpdateID]};
	
	[UIPasteboard generalPasteboard].string = [metaData objectForKey:@"message"];
	[[NSUserDefaults standardUserDefaults] replaceObject:metaData forKey:@"share_props"];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Popup link has been copied to your clipboard!"
														message:[NSString stringWithFormat:@"http://popup.vlly.im/%d\nShare now for people to join.", _statusUpdateVO.statusUpdateID]
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"alert_cancel", @"Cancel")
											  otherButtonTitles:@"Copy to Clipboard", @"Share on SMS", @"Share Kik", nil];//, @"Share Line", @"Share Kakao", nil];
	[alertView setTag:HONStatusUpdateAlertViewTypeShare];
	[alertView show];
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
	
//	[[KikClient sharedInstance] openProfileForKikUsername:@"kikteam"];
	
//	KikMessage *message = [KikMessage photoMessageWithImageURL:@"http://popup.rocks/images/my_icon.png"
//													previewURL:@"http://popup.rocks/images/my_icon.png"];
//	[[KikClient sharedInstance] sendKikMessage:message];
	
//	UIImage *image = [UIImage imageNamed:@"noNetworkBG"];
//	KikMessage *message = [KikMessage photoMessageWithImage:image];
//	[[KikClient sharedInstance] sendKikMessage:message];
}

- (void)_goImageComment {
//	[[HONAnalyticsReporter sharedInstance] trackEvent:@"0428Cohort - image"];
	
//	_loadingOverlayView = [[HONLoadingOverlayView alloc] init];
//	_loadingOverlayView.delegate = self;
//	[_statusUpdateFooterView toggleTakePhotoButton:NO];
//	[[PBJVision sharedInstance] capturePhoto];
	
//	[[PBJVision sharedInstance] startVideoCapture];
//	_statusUpdateHeaderView.hidden = YES;
//	_statusUpdateFooterView.hidden = YES;
//	_scrollView.hidden = YES;
//	_expireLabel.hidden = YES;
	
//	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
//		[[PBJVision sharedInstance] endVideoCapture];
//		_statusUpdateHeaderView.hidden = NO;
//		_statusUpdateFooterView.hidden = NO;
//		_scrollView.hidden = NO;
//		_expireLabel.hidden = NO;
//	});
}

- (void)_goTextComment {
//	[[HONAnalyticsReporter sharedInstance] trackEvent:@"0428Cohort - comment"];
	
	_isSubmitting = YES;
	[_submitCommentButton setEnabled:NO];
	
	_comment = _commentTextField.text;
	_commentTextField.text = @"";
	
	if (++_comments == 1) {
		[[HONAPICaller sharedInstance] updateUsernameForUser:_comment completion:^(NSDictionary *result) {
			if (![[result objectForKey:@"result"] isEqualToString:@"fail"])
				[[HONUserAssistant sharedInstance] writeActiveUserInfo:result];
		}];
		
		NSMutableDictionary *userInfo = [[[HONUserAssistant sharedInstance] activeUserInfo] mutableCopy];
		[userInfo replaceObject:_comment forKey:@"username"];
		[[HONUserAssistant sharedInstance] writeActiveUserInfo:[userInfo copy]];
		
		NSDictionary *dict = @{@"id"				: @"0",
							   @"msg_id"			: @"0",
							   @"content_type"		: @((int)HONChatMessageTypeBOT),
							   
							   @"owner_member"		: @{@"id"	: @(2392),
														@"name"	: @"Botly"},
							   @"image"				: [@"coords://" stringByAppendingFormat:@"%.04f_%.04f", [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude],
							   @"text"				: [NSString stringWithFormat:@"You changed your name to “%@”", _comment],
							   
							   @"net_vote_score"	: @(0),
							   @"status"			: NSStringFromInt(0),
							   @"added"				: [NSDate stringFormattedISO8601],
							   @"updated"			: [NSDate stringFormattedISO8601]};
		
		[self _appendComment:[HONCommentVO commentWithDictionary:dict]];
		
	} else
		[self _submitTextComment];
}

- (void)_goActivateTextComment {
	if (![_commentTextField isFirstResponder])
		[_commentTextField becomeFirstResponder];
}

- (void)_goCancelComment {
	_commentTextField.text = @"";
	_footerImageView.image = [UIImage imageNamed:(_comments == 0) ? @"commentInput2BG" : @"commentInputBG"];
	
	if ([_commentTextField isFirstResponder])
		[_commentTextField resignFirstResponder];
	
	_footerImageView.hidden = NO;
	_scrollView.frame = CGRectResizeHeight(_scrollView.frame, self.view.frame.size.height - (_statusUpdateHeaderView.frameEdges.bottom + _statusUpdateFooterView.frame.size.height + _expireLabel.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height));
	
	_takePhotoButton.hidden = NO;
	_submitCommentButton.hidden = YES;
	
	if (_scrollView.contentSize.height - _scrollView.frame.size.height > 0)
		[_scrollView setContentOffset:CGPointMake(0.0, MAX(0.0, _scrollView.contentSize.height - _scrollView.frame.size.height)) animated:YES];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_hudView.alpha = 1.0;
		_commentFooterView.frame = CGRectTranslateY(_commentFooterView.frame, self.view.frame.size.height - _commentFooterView.frame.size.height);
//		_expireLabel.frame = CGRectTranslateY(_expireLabel.frame, _scrollView.frameEdges.bottom);
		_takePhotoButton.frame = CGRectTranslateY(_takePhotoButton.frame, self.view.frame.size.height - 74.0);
		[_scrollView setContentInset:UIEdgeInsetsMake(MAX(0.0, (_scrollView.frame.size.height - _commentsHolderView.frame.size.height)), _scrollView.contentInset.left, _scrollView.contentInset.bottom, _scrollView.contentInset.right)];
	} completion:^(BOOL finished) {
		[_commentCloseButton removeFromSuperview];
	}];
}

-(void)_goLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		NSLog(@"gestureRecognizer.state:[%@]", NSStringFromUIGestureRecognizerState(gestureRecognizer.state));
		
		CGPoint touchPoint = [gestureRecognizer locationInView:self.view];
		NSLog(@"TOUCH:%@", NSStringFromCGPoint(touchPoint));
		
		if (CGRectContainsPoint(_takePhotoButton.frame, touchPoint)) {
			[_moviePlayer stop];
			_moviePlayer.view.hidden = YES;
			_cameraPreviewView.frame = CGRectMake(0.0, self.view.frame.size.height * 0.25, self.view.frame.size.width, self.view.frame.size.height * 0.5);
			_bgView.frame = CGRectMake(0.0, 20.0, 0.0, 60.0);
			_cameraPreviewLayer.opacity = 1.0;
			[[PBJVision sharedInstance] startVideoCapture];
			_statusUpdateHeaderView.hidden = YES;
			_statusUpdateFooterView.hidden = YES;
			_commentFooterView.hidden = YES;
			_scrollView.hidden = YES;
			_hudView.hidden = YES;
			
			[UIView animateKeyframesWithDuration:3.00 delay:0.00
										 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveLinear)
									  animations:^(void) {
										  _bgView.frame = CGRectResizeWidth(_bgView.frame, self.view.frame.size.width);
									  } completion:^(BOOL finished) {
									  }];
		}
		
	} else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"0428Cohort - sendVideo" withProperties:@{@"chat"	: @(_statusUpdateVO.statusUpdateID)}];
		
		NSLog(@"gestureRecognizer.state:[%@]", NSStringFromUIGestureRecognizerState(gestureRecognizer.state));
		_cameraPreviewView.frame = CGRectMake(0.0, self.view.frame.size.height * 0.5, self.view.frame.size.width, self.view.frame.size.height * 0.5);
		[_bgView.layer removeAllAnimations];
		_bgView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height * 0.5);
		_cameraPreviewLayer.opacity = 0.33;
		_statusLabel.text = @"Sending popup…";
		
		[[PBJVision sharedInstance] endVideoCapture];
		_statusUpdateHeaderView.hidden = NO;
		_statusUpdateFooterView.hidden = NO;
		_commentFooterView.hidden = NO;
		_scrollView.hidden = NO;
		_hudView.hidden = NO;
	}
}

- (void)_goFlipCamera {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - flip_camera"];
	
	PBJVision *vision = [PBJVision sharedInstance];
	vision.cameraDevice = (vision.cameraDevice == PBJCameraDeviceBack) ? PBJCameraDeviceFront : PBJCameraDeviceBack;
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

- (void)_playbackStateChanged:(NSNotification *)notification {
	NSLog(@"_playbackStateChangedNotification:[%d][%d]", _moviePlayer.loadState, _moviePlayer.playbackState);
	
	if (_moviePlayer.loadState == 0) {
		_moviePlayer.view.hidden = NO;
		[UIView animateKeyframesWithDuration:0.25 delay:0.00
									 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut)
								  animations:^(void) {
									  _moviePlayer.view.alpha = 1.0;
								  } completion:^(BOOL finished) {
								  }];
	}
	
}

- (void)_playbackEnded:(NSNotification *)notification {
	NSLog(@"_playbackEndedNotification:[%@]", [notification object]);
	[_moviePlayer play];
	
//	[UIView animateKeyframesWithDuration:0.25 delay:0.00
//								 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut)
//							  animations:^(void) {
//								  _moviePlayer.view.alpha = 0.0;
//							  } completion:^(BOOL finished) {
//							  }];
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
	
	for (UIView *view in _commentsHolderView.subviews) {
		CGFloat offset = (_commentsHolderView.frameEdges.bottom - view.frame.origin.y) - 22.0;
		NSLog(@"offset:[%0.4f]", offset);
		
		view.alpha = 1.0 - (offset / 198.352);
	}
	
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
	
	if (_tintTimer != nil) {
		[_tintTimer invalidate];
		_tintTimer = nil;
	}
	
//	UIView *matteView = [[UIView alloc] initWithFrame:CGRectFromSize(CGSizeMake(40.0, 44.0))];
//	matteView.backgroundColor = [UIColor colorWithRed:0.110 green:0.553 blue:0.984 alpha:1.00];
//	[_statusUpdateHeaderView addSubview:matteView];

//	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//	activityIndicatorView.frame = CGRectOffset(activityIndicatorView.frame, 11.0, 11.0);
//	[activityIndicatorView startAnimating];
//	[_statusUpdateHeaderView addSubview:activityIndicatorView];
//	
	[PubNub sendMessage:[NSString stringWithFormat:@"%d|%.04f_%.04f|__BYE__:", [[HONUserAssistant sharedInstance] activeUserID], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude] toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
		if (messageState == PNMessageSent) {
			NSLog(@"\nSEND MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
			[PubNub unsubscribeFrom:@[_channel] withCompletionHandlingBlock:^(NSArray *array, PNError *error) {
			}];
			
			[[PNObservationCenter defaultCenter] removeClientChannelSubscriptionStateObserver:self];
			[[PNObservationCenter defaultCenter] removeMessageReceiveObserver:self];
		}
	}];
	
	[[NSUserDefaults standardUserDefaults] setObject:NSStringFromBOOL(NO) forKey:@"chat_share"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
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
	
	_revealerView = [[HONMediaRevealerView alloc] initWithComment:commentVO];
	_revealerView.delegate = self;
	[self.view addSubview:_revealerView];
}

- (void)commentItemViewShareLink:(HONCommentItemView *)commentItemView {
	NSLog(@"[*:*] commentItemViewShareLink [*:*]");
	if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb-messenger://"]]) {
		[[[UIAlertView alloc] initWithTitle:@"Not Avialable"
									message:@"This device isn't allowed or doesn't recognize FB Messenger!"
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil) 
						  otherButtonTitles:nil] show];
		
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb-messenger://"]];
	}
}

#pragma mark - HONMediaRevealerView Delegates
- (void)mediaRevealerViewDidIntro:(HONMediaRevealerView *)mediaRevealerView {
	NSLog(@"[*:*] mediaRevealerViewDidIntro [*:*]");
}

- (void)mediaRevealerViewDidOutro:(HONMediaRevealerView *)mediaRevealerView {
	NSLog(@"[*:*] mediaRevealerViewDidOutro [*:*]");
	
	if (mediaRevealerView != nil) {
		if (mediaRevealerView.superview != nil)
			[mediaRevealerView removeFromSuperview];
		
		mediaRevealerView.delegate = nil;
		mediaRevealerView = nil;
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
//	[self _goImageComment];
	
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

- (void)statusUpdateHeaderViewFlag:(HONStatusUpdateHeaderView *)statusUpdateHeaderView {
	NSLog(@"[*:*] statusUpdateHeaderViewFlag [*:*]");
	
	[self _goFlag];
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_textFieldTextDidChangeChange:)
												 name:UITextFieldTextDidChangeNotification
											   object:textField];
	
	_footerImageView.image = [UIImage imageNamed:@"commentInput2BG"];
	_footerImageView.hidden = YES;
	_scrollView.frame = CGRectResizeHeight(_scrollView.frame, self.view.frame.size.height - (_statusUpdateHeaderView.frameEdges.bottom + _commentFooterView.frame.size.height + _expireLabel.frame.size.height + 216.0));
	
	_takePhotoButton.hidden = YES;
	_submitCommentButton.hidden = NO;
	
	if (_scrollView.contentSize.height - _scrollView.frame.size.height > 0)
		[_scrollView setContentOffset:CGPointMake(0.0, MAX(0.0, _scrollView.contentSize.height - _scrollView.frame.size.height)) animated:YES];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		[_scrollView setContentInset:UIEdgeInsetsMake(MAX(0.0, (_scrollView.frame.size.height - _commentsHolderView.frame.size.height)), _scrollView.contentInset.left, _scrollView.contentInset.bottom, _scrollView.contentInset.right)];
//		_expireLabel.frame = CGRectTranslateY(_expireLabel.frame, _scrollView.frameEdges.bottom);
		_commentFooterView.frame = CGRectTranslateY(_commentFooterView.frame, self.view.frame.size.height - (_commentFooterView.frame.size.height + 216.0));
		_takePhotoButton.frame = CGRectTranslateY(_takePhotoButton.frame, self.view.frame.size.height - (_takePhotoButton.frame.size.height + 216.0));
		
		_hudView.alpha = 0.0;
	 } completion:^(BOOL finished) {
		 
		 //_commentCloseButton.frame = _scrollView.frame;
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
			[self _popBack];
		}
	
	} else if (alertView.tag == HONStatusUpdateAlertViewTypeShare) {
		if (buttonIndex == 1) {
//			[[HONAnalyticsReporter sharedInstance] trackEvent:@"0428Cohort - shareClipboard"];
			
			[[[UIAlertView alloc] initWithTitle:@"Paste anywhere to share!"
										message:@""
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
			
		} else if (buttonIndex == 2) {
//			[[HONAnalyticsReporter sharedInstance] trackEvent:@"0428Cohort - shareSMS"];
			
			if ([MFMessageComposeViewController canSendText]) {
				MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
				messageComposeViewController.body = [UIPasteboard generalPasteboard].string;
				messageComposeViewController.messageComposeDelegate = self;
				
				[self presentViewController:messageComposeViewController animated:YES completion:^(void) {}];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"SMS Error"
											message:@"Cannot send SMS from this device!"
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
			}
			
		} else if (buttonIndex == 3) {
//			[[HONAnalyticsReporter sharedInstance] trackEvent:@"0428Cohort - shareKik"];
			
			NSString *typeName = @"";
			NSString *urlSchema = @"";
			
			typeName = @"Kik";
			urlSchema = @"kik://";
			
			if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"kik://"]]) {
				[[[UIAlertView alloc] initWithTitle:@"Not Avialable"
											message:[NSString stringWithFormat:@"This device isn't allowed or doesn't recognize %@!", typeName]
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
				
			} else {
				KikMessage *message = [KikMessage articleMessageWithTitle:@"Popup on Kik"
																	 text:@"Join my Popup?"
															   contentURL:[NSString stringWithFormat:@"http://popup.rocks/deep.php?id=%d", _statusUpdateVO.statusUpdateID]
															   previewURL:@"http://popup.rocks/images/my_icon.png"];
				[[KikClient sharedInstance] sendKikMessage:message];
			}
			
		} else if (buttonIndex == 4) {
//			[[HONAnalyticsReporter sharedInstance] trackEvent:@"0428Cohort - shareLine"];
			
			NSString *typeName = @"Line";
			NSString *urlSchema = @"line://";
			
			if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlSchema]]) {
				[[[UIAlertView alloc] initWithTitle:@"Not Avialable"
											message:[NSString stringWithFormat:@"This device isn't allowed or doesn't recognize %@!", typeName]
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
				
			} else {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlSchema]];
			}
			
		} else if (buttonIndex == 5) {
//			[[HONAnalyticsReporter sharedInstance] trackEvent:@"0428Cohort - shareKakao"];
			
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
	
//	if (_cameraFocusView && [_cameraFocusView superview]) {
//		[_cameraFocusView stopAnimation];
//	}
}

- (void)visionWillChangeExposure:(PBJVision *)vision {
	//NSLog(@"[*:*] visionWillChangeExposure [*:*]");
}

- (void)visionDidChangeExposure:(PBJVision *)vision {
	//NSLog(@"[*:*] visionDidChangeExposure [*:*]");
	
//	if (_cameraFocusView && [_cameraFocusView superview]) {
//		[_cameraFocusView stopAnimation];
//	}
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
	NSLog(@"[*:*] vision:capturedPhoto:[%lu] error:[%@] [*:*]", (unsigned long)[[photoDict objectForKey:PBJVisionPhotoMetadataKey] count], error);
	
	[[PBJVision sharedInstance] stopPreview];
//
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
