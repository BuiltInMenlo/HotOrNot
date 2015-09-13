//
//	HONStatusUpdateViewController.m
//	HotOrNot
//
//	Created by BIM	on 11/20/14.
//	Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#include <AudioToolbox/AudioToolbox.h>
#import <PhotosUI/PhotosUI.h>
#import <QuartzCore/QuartzCore.h>

#import <AWSiOSSDKv2/S3.h>
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import <PubNub/PubNub.h>


#import "NSArray+BuiltInMenlo.h"
#import "NSCharacterSet+BuiltinMenlo.h"
#import "NSDate+BuiltinMenlo.h"
#import "NSString+BuiltinMenlo.h"
#import "NSDictionary+BuiltInMenlo.h"
//#import "PubNub+BuiltInMenlo.h"
#import "UIImageView+AFNetworking.h"
#import "UIView+BuiltinMenlo.h"

#import "KikAPI.h"
#import "PBJVision.h"
#import "PBJVisionUtilities.h"
#import "WXApi.h"

#import "HONStatusUpdateViewController.h"
#import "HONCommentItemView.h"
#import "HONScrollView.h"
#import "HONStatusUpdateHeaderView.h"
#import "HONChannelInviteButtonView.h"
#import "HONLoadingOverlayView.h"
#import "HONMediaRevealerView.h"
#import "HONButton.h"

#import "GSMessengerShare.h"

NSString * const kPubNubConfigDomain = @"pubsub.pubnub.com";
NSString * const kPubNubPublishKey = @"pub-c-a4abb7b2-2e28-43c4-b8f1-b2de162a79c3";
NSString * const kPubNubSubscribeKey = @"sub-c-ed10ba66-c9b8-11e4-bf07-0619f8945a4f";
NSString * const kPubNubSecretKey = @"sec-c-OTI3ZWQ4NWYtZDRkNi00OGFjLTgxMjctZDkwYzRlN2NkNDgy";


@interface HONStatusUpdateViewController () <FBSDKMessengerURLHandlerDelegate, GSMessengerShareDelegate, HONChannelInviteButtonViewDelegate, HONCommentItemViewDelegate, HONMediaRevealerViewDelegate, HONLoadingOverlayViewDelegate, HONStatusUpdateHeaderViewDelegate, PBJVisionDelegate, PNObjectEventListener>
@property (nonatomic, strong) HONStatusUpdateVO *statusUpdateVO;
@property (nonatomic, strong) HONUserClubVO *clubVO;
@property (nonatomic, strong) HONScrollView *scrollView;
@property (nonatomic, strong) HONLoadingOverlayView *loadingOverlayView;
@property (nonatomic, strong) HONStatusUpdateHeaderView *statusUpdateHeaderView;

@property (nonatomic, strong) UIView *cameraPreviewView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *cameraPreviewLayer;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

@property (nonatomic, strong) HONButton *submitCommentButton;
@property (nonatomic, strong) UIImageView *footerImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSMutableArray *replies;
@property (nonatomic, strong) NSDictionary *selectedMessengerContent;
@property (nonatomic, strong) NSString *selectedMessengerText;
@property (nonatomic, strong) UIView *commentsHolderView;
@property (nonatomic, strong) UIView *commentFooterView;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *outboundURL;
@property (nonatomic, strong) NSTimer *expireTimer;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *expireLabel;
@property (nonatomic, strong) UILabel *participantsLabel;
@property (nonatomic, strong) UILabel *countdownLabel;
@property (nonatomic) int countdown;
@property (nonatomic, strong) UIButton *toggleMicButton;
@property (nonatomic, strong) UIButton *cameraFlipButton;
@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, strong) NSTimer *focusTimer;
@property (nonatomic, strong) NSTimer *preRecordTimer;
@property (nonatomic, strong) UIImageView *recordImageView;
@property (nonatomic, strong) UIButton *takePhotoButton;
@property (nonatomic, strong) UIButton *messengerButton;
@property (nonatomic, strong) UIButton *openCommentButton;
@property (nonatomic, strong) UIButton *videoVisibleButton;
@property (nonatomic, strong) HONButton *videoFocusButton;
@property (nonatomic, strong) HONButton *historyButton;
@property (nonatomic, strong) HONButton *replayButton;
@property (nonatomic, strong) HONButton *flagButton;
@property (nonatomic, strong) HONButton *cancelCameraButton;
@property (nonatomic, strong) UIView *tintView;
@property (nonatomic, strong) UIImageView *animationImageView;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UIButton *nameButton;
@property (nonatomic, strong) UIView *finaleTintView;
@property (nonatomic, strong) UIView *shareHolderView;
@property (nonatomic, strong) UIImageView *shareTutorialImageView;
@property (nonatomic, strong) UIImageView *cameraTutorialImageView;
@property (nonatomic, strong) NSDictionary *baseShareInfo;
@property (nonatomic, strong) NSString *thumbURL;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) UILongPressGestureRecognizer *lpGestureRecognizer;
@property (nonatomic, strong) NSTimer *bufferTimer;
@property (nonatomic, strong) NSMutableArray *videoPlaylist;
@property (nonatomic, strong) NSString *lastVideo;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UIImageView *loadingImageView;
@property (nonatomic, strong) NSMutableArray *shareTypes;
@property (nonatomic, strong) PubNub *client;
@property (nonatomic) int messageTotal;
@property (nonatomic) BOOL isDeepLink;
@property (nonatomic) BOOL isInvite;
@property (nonatomic) BOOL isShare;
@property (nonatomic, strong) HONMediaRevealerView *revealerView;
@property (nonatomic, strong) GSMessengerShare *messengerShare;

@property (nonatomic) BOOL isSubmitting;
@property (nonatomic) BOOL isActive;
@property (nonatomic) BOOL isTutorial;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL isFinale;
@property (nonatomic) int prerecordCounter;
@property (nonatomic) int participants;
@property (nonatomic) int comments;
@property (nonatomic) int videoQueue;
@property (nonatomic) float sysVolume;
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
		
//		[[NSNotificationCenter defaultCenter] addObserver:self
//												 selector:@selector(_playerItemEnded:)
//													 name:AVPlayerItemDidPlayToEndTimeNotification
//												   object:nil];
		
		PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:kPubNubPublishKey
																		 subscribeKey:kPubNubSubscribeKey];
		
		_client = [PubNub clientWithConfiguration:configuration];
		
		[self _setupCamera];
		[[PBJVision sharedInstance] startPreview];
	}
	
	return (self);
}

- (id)initFromDeepLinkWithChannelName:(NSString *)channelName {
	NSLog(@"%@ - initFromDeepLinkWithChannelName:[%@]", [self description], channelName);
	if ((self = [self initWithChannelName:channelName])) {
		_isDeepLink = YES;
	}
	
	return (self);
}

- (id)initWithChannelName:(NSString *)channelName {
	NSLog(@"%@ - initWithChannelName:[%@]", [self description], channelName);
	if ((self = [self init])) {
		_isDeepLink = NO;
		_channelName = channelName;
		_lastVideo = @"";
		
		
	}
	
	return (self);
}

- (id)initWithStatusUpdate:(HONStatusUpdateVO *)statusUpdateVO forClub:(HONUserClubVO *)clubVO {
	NSLog(@"%@ - initWithStatusUpdate:[%@] forClub:[%d - %@]", [self description], statusUpdateVO.dictionary, clubVO.clubID, clubVO.clubName);
	if ((self = [self init])) {
		_channelName = @"";
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
- (void)_submitTextComment {
	NSDictionary *dict = @{@"user_id"			: [[HONUserAssistant sharedInstance] activeUserID],
						   @"club_id"			: @(_clubVO.clubID),
						   @"img_url"			: [@"coords://" stringByAppendingFormat:@"%.04f_%.04f", [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude],
						   @"subject"			: [NSString stringWithFormat:@"%@;%@|%.04f_%.04f|__TXT__:%@", [[HONUserAssistant sharedInstance] activeUserID], [[HONUserAssistant sharedInstance] activeUsername], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude, _comment],
						   @"challenge_id"		: @(_statusUpdateVO.statusUpdateID)};
	NSLog(@"|:|◊≈◊~~◊~~◊≈◊~~◊~~◊≈◊| SUBMIT PARAMS:[%@]", dict);
	
	
	[_client publish:_comment toChannel:_channelName mobilePushPayload:@{@"apns"	: @{@"aps"	: @{@"alert"	: _comment,
																									@"sound"	: @"selfie_notification.aif",
																									@"channel"	: _channelName}}} withCompletion:^(PNPublishStatus *status) {
																										NSLog(@"\nSEND");// MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
																									}];
	
//	[PubNub sendMessage:_comment
//  applePushNotification:@{@"aps"	: @{@"alert"	: _comment,
//										@"sound"	: @"selfie_notification.aif",
//										@"channel"	: _channelName}}
//			  toChannel:_channel
//	withCompletionBlock:^(PNMessageState messageState, id data) {
//		NSLog(@"\nSEND MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
//	}];
	
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
	NSDictionary *dict = @{@"user_id"		: [[HONUserAssistant sharedInstance] activeUserID],
						   @"club_id"		: @(_clubVO.clubID),
						   @"img_url"		: urlPrefix,
						   //							 @"img_url"		: [@"coords://" stringByAppendingFormat:@"%.04f_%.04f", [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude],
						   @"subject"		: [NSString stringWithFormat:@"%@;%@|%.04f_%.04f|__IMG__:%@", [[HONUserAssistant sharedInstance] activeUserID], [[HONUserAssistant sharedInstance] activeUsername], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude, [urlPrefix lastComponentByDelimeter:@"/"]],
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
	
	[_client publish:_comment toChannel:[dict objectForKey:@"subject"] mobilePushPayload:@{@"apns"	: @{@"aps"	: @{@"alert"	: [dict objectForKey:@"subject"],
																													@"sound"	: @"selfie_notification.aif",
																													@"channel"	: _channelName}}} withCompletion:^(PNPublishStatus *status) {
																														NSLog(@"\nSEND");// MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
																													}];
	_isSubmitting = NO;
}


- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
 
	// Handle new message stored in message.data.message
	if (message.data.actualChannel) {
  
		// Message has been received on channel group stored in
		// message.data.subscribedChannel
	}
	else {
  
		// Message has been received on channel stored in
		// message.data.subscribedChannel
	}
	//NSLog(@"Received message: %@ on channel %@ at %@", message.data.message, message.data.subscribedChannel, message.data.timetoken);
	
	NSString *txtContent = ([message.data.message isKindOfClass:[NSDictionary class]]) ? ([message.data.message objectForKey:@"pn_other"] != nil) ? [message.data.message objectForKey:@"pn_other"] : @"" : message.data.message;
	NSLog(@"Received message: %@ on channel %@ at %@", txtContent, message.data.subscribedChannel, message.data.timetoken);
	
	if ([txtContent length] > 0) {
		if ([txtContent rangeOfString:@".mp4"].location != NSNotFound) {
			[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - playVideo"] withProperties:@{@"file"		: txtContent,
																																		  @"channel"	: _channelName}];
			
			NSURL *url = [NSURL URLWithString:[@"https://s3.amazonaws.com/popup-vids/" stringByAppendingString:txtContent]];
			[_videoPlaylist insertObject:url atIndex:0];
			
			[self _downloadVideo:txtContent];
			if (![_lastVideo isEqualToString:txtContent]) {
				[self _goReplay];
//				_videoQueue = 0;
//				_moviePlayer.contentURL = url;
//				[_moviePlayer play];
				
				_expireLabel.text = @"Loading video…";
				_expireLabel.alpha = 1.0;
			
			} else {
				
			}
			
		} else {
			NSDictionary *dict = @{@"id"				: @"0",
								   @"msg_id"			: @"0",
								   @"content_type"		: @((int)HONChatMessageTypeTXT),
								   
								   @"owner_member"		: @{@"id"	: @(2392),
															@"name"	: @""},
								   @"image"				: [@"coords://" stringByAppendingFormat:@"%.04f_%.04f", [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude],
								   @"text"				: txtContent,
								   
								   @"net_vote_score"	: @(0),
								   @"status"			: NSStringFromInt(0),
								   @"added"				: [NSDate stringFormattedISO8601],
								   @"updated"			: [NSDate stringFormattedISO8601]};
			
			
			HONCommentVO *commentVO = [HONCommentVO commentWithDictionary:dict];
			NSLog(@"ChatMessageType:[%@]", (commentVO.messageType == HONChatMessageTypeUndetermined) ? @"Undetermined" : (commentVO.messageType == HONChatMessageTypeACK) ? @"ACK" : (commentVO.messageType == HONChatMessageTypeBYE) ? @"BYE": (commentVO.messageType == HONChatMessageTypeTXT) ? @"Text" : (commentVO.messageType == HONChatMessageTypeIMG) ? @"Image" : (commentVO.messageType == HONChatMessageTypeVID) ? @"Video" : @"UNKNOWN");
			[self _appendComment:commentVO];
		}
	}
}


-(void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
 
	// Handle presence event event.data.presenceEvent (one of: join, leave, timeout,
	// state-change).
	if (event.data.actualChannel) {
		
		// Presence event has been received on channel group stored in
		// event.data.subscribedChannel
	}
	else {
		
		// Presence event has been received on channel stored in
		// event.data.subscribedChannel
	}
	NSLog(@"Did receive presence event: %@", event.data.presenceEvent);
}

- (void)client:(PubNub *)client didReceiveStatus:(PNSubscribeStatus *)status {
	
	if (status.category == PNUnexpectedDisconnectCategory) {
		// This event happens when radio / connectivity is lost
	}
	
	else if (status.category == PNConnectedCategory) {
  
		// Connect event. You can do stuff like publish, and know you'll get it.
		// Or just use the connected event to confirm you are subscribed for
		// UI / internal notifications, etc
  
	}
	else if (status.category == PNReconnectedCategory) {
  
		// Happens as part of our regular operation. This event happens when
		// radio / connectivity is lost, then regained.
	}
	else if (status.category == PNDecryptionErrorCategory) {
  
		// Handle messsage decryption error. Probably client configured to
		// encrypt messages and on live data feed it received plain text.
	}
 
}


- (void)_downloadVideo:(NSString *)filename {
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://s3.amazonaws.com/popup-vids/%@", filename]]];
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[request.URL.pathComponents lastObject]];
	operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
	
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSLog(@"Successfully downloaded file to %@", path);
		NSMutableArray *cachedVideos = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cached"] mutableCopy];
		
		if (![cachedVideos containsObject:path])
			[cachedVideos addObject:path];
		
		[[NSUserDefaults standardUserDefaults] replaceObject:[cachedVideos copy] forKey:@"cached"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
	}];
	
	[operation start];
}


- (void)_channelSetup {
	_channelName = ([_channelName length] == 0) ? [NSString stringWithFormat:@"%@_%d", [[HONDeviceIntrinsics sharedInstance] uniqueIdentifierWithoutSeperators:NO], [NSDate elapsedUTCSecondsSinceUnixEpoch]] : _channelName;
	
	
	_participants = 0;
	_videoQueue = 0;
	_comments = 0;
	_videoPlaylist = [NSMutableArray array];
	_outboundURL = @"pp1.link/…";
	
	[[NSUserDefaults standardUserDefaults] setObject:_channelName forKey:@"channel_name"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	NSDictionary *params = @{@"longUrl"	: [NSString stringWithFormat:@"http://popup.rocks/route.php?d=%@&a=popup", _channelName]};
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", @"https://www.googleapis.com/urlshortener/v1", @"url?key=AIzaSyCkGnRnlwqsDW8B1N9qfj4Irxgf-G2rX7g", params);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.googleapis.com/urlshortener/v1"]];
	[httpClient setDefaultHeader:@"Content-Type" value:@"application/json"];
	[httpClient setDefaultHeader:@"Referrer" value:@"com.builtinmenlo.marsh"];
	[httpClient setParameterEncoding:AFJSONParameterEncoding];
	[httpClient postPath:@"url?key=AIzaSyCkGnRnlwqsDW8B1N9qfj4Irxgf-G2rX7g" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];

		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];

		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			NSLog(@"short:[%@]", [result objectForKey:@"id"]);
			_outboundURL = [[result objectForKey:@"id"] stringByReplacingOccurrencesOfString:@"goo.gl" withString:@"pp1.link"];
			[_messengerShare overrrideWithOutboundURL:_outboundURL];

			NSMutableArray *channels = [[[NSUserDefaults standardUserDefaults] objectForKey:@"channel_history"] mutableCopy];
			__block BOOL isFound = NO;

			[channels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSMutableDictionary *dict = [(NSDictionary *)obj mutableCopy];
				if ([[dict objectForKey:@"channel"] isEqualToString:_channelName]) {
					[dict setObject:[_outboundURL stringByReplacingOccurrencesOfString:@"http://" withString:@""] forKey:@"title"];
					[dict setObject:_channelName forKey:@"channel"];
					[dict setObject:_outboundURL forKey:@"url"];
					[dict setObject:[NSDate date] forKey:@"timestamp"];
					[dict setObject:@(_participants) forKey:@"occupants"];

					[channels replaceObjectAtIndex:idx withObject:[dict copy]];
					[[NSUserDefaults standardUserDefaults] setObject:[channels copy] forKey:@"channel_history"];
					[[NSUserDefaults standardUserDefaults] synchronize];

					isFound = YES;
					*stop = YES;
				}
			}];


			if (!isFound) {
				[channels addObject:@{@"title"		: [_outboundURL stringByReplacingOccurrencesOfString:@"http://" withString:@""],
									  @"channel"	: _channelName,
									  @"url"		: _outboundURL,
									  @"timestamp"	: [NSDate date],
									  @"occupants"	: @(_participants)}];

				[[NSUserDefaults standardUserDefaults] setObject:[channels copy] forKey:@"channel_history"];
				[[NSUserDefaults standardUserDefaults] synchronize];
			}
		}

	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], @"https://www.googleapis.com/urlshortener/v1", @"url?key=AIzaSyCkGnRnlwqsDW8B1N9qfj4Irxgf-G2rX7g", [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
	
	[_client addListener:self];
	[_client subscribeToChannels:@[_channelName] withPresence:YES];
	[_client pushNotificationEnabledChannelsForDeviceWithPushToken:[[HONDeviceIntrinsics sharedInstance] dataPushToken] andCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
		
		[UIView animateWithDuration:0.250 delay:3.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
			_expireLabel.alpha = 0.0;
		} completion:^(BOOL finished) {
		}];
		
		[self.client hereNowForChannel:_channelName withVerbosity:PNHereNowUUID
							completion:^(PNPresenceChannelHereNowResult *result,
										 PNErrorStatus *status) {
								
								NSLog(@"::: PRESENCE OBSERVER - [%@] :::", result.data.uuids);
								NSLog(@"PARTICIPANTS:[%d]", (int)[result.data.uuids count]);
								
								_participants = (int)[result.data.uuids count];
								_participantsLabel.text = [NSString stringWithFormat:@"%d", MAX(0, _participants - 1)];
								
								if (_participants > 1)
									_expireLabel.text = [NSString stringWithFormat:@"Alerting… %d %@", MAX(0, _participants - 1), ((_participants - 1) == 1) ? @"person" : @"people"];
								
								// Check whether request successfully completed or not.
								if (!status.isError) {
									// Handle downloaded presence information using:
									//   result.data.uuids - list of uuids.
									//   result.data.occupancy - total number of active subscribers.
								} else {
									
									// Handle presence audit error. Check 'category' property to find out possible issue because of which request did fail.
									// Request can be resent using: [status retry];
								}
							}];
		
		
		[self.client historyForChannel:_channelName start:nil end:nil limit:100
						withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
							
//--							[[HONAudioMaestro sharedInstance] cafPlaybackWithFilename:@"join_channel"];
							NSLog(@"::: HISTORY OBSERVER - [%d] :::", (int)[result.data.messages count]);
							
							// Check whether request successfully completed or not.
							if (!status.isError) {
								
								[result.data.messages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
									NSDictionary *dict = (NSDictionary *)obj;
									
									NSString *txtContent = ([dict isKindOfClass:[NSDictionary class]]) ? ([dict objectForKey:@"pn_other"] != nil) ? [dict objectForKey:@"pn_other"] : ([dict objectForKey:@"text"] != nil) ? [dict objectForKey:@"text"] : @"" : @"";
									NSLog(@"txtContent:[%@]", txtContent);
									
									if ([txtContent length] > 0 && [txtContent rangeOfString:@".mp4"].location != NSNotFound) {
										NSURL *url = [NSURL URLWithString:[@"https://s3.amazonaws.com/popup-vids/" stringByAppendingString:txtContent]];
										[_videoPlaylist addObject:url];
										[self _downloadVideo:[url lastPathComponent]];
										
										if (_moviePlayer.contentURL == nil) {
											_moviePlayer.contentURL = url;
//--											[_moviePlayer play];
											
											_animationImageView.hidden = NO;
											_expireLabel.text = @"Loading video…";
											_expireLabel.alpha = 1.0;
											[UIView animateWithDuration:0.250 delay:3.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
												_expireLabel.alpha = 0.0;
											} completion:^(BOOL finished) {
											}];
										}
									}
								}];
								
								
								// Handle downloaded history using:
								//   result.data.start - oldest message time stamp in response
								//   result.data.end - newest message time stamp in response
								//   result.data.messages - list of messages
							}
							// Request processing failed.
							else {
								
								// Handle message history download error. Check 'category' property to find
								// out possible issue because of which request did fail.
								//
								// Request can be resent using: [status retry];
							}
							
							
							if ([_videoPlaylist count] == 0) {
								_takePhotoButton.enabled = YES;
								_messengerButton.enabled = YES;
								_historyButton.enabled = YES;
								_cameraFlipButton.enabled = YES;
								_openCommentButton.enabled = YES;
							
							} else {
//--								if ([MPMusicPlayerController applicationMusicPlayer].volume != 0.0)
//--									[[MPMusicPlayerController applicationMusicPlayer] setVolume:0.0];
								
								[self _advanceVideo];
								[UIView animateWithDuration:0.250 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
									_finaleTintView.alpha = 1.0;
									
								} completion:^(BOOL finished) {
								}];
							}
						}];
		
		
		
//		block((!status.isError ? result.data.channels : nil),
//			  (status.isError ? status.errorData.information : nil));
	}];
}

- (void)_flagStatusUpdate {
	NSDictionary *dict = @{@"user_id"		: [[HONUserAssistant sharedInstance] activeUserID],
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
	
	//dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.33 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
		[self _channelSetup];
		[self _didFinishDataRefresh];
	//});
}

- (void)_didFinishDataRefresh {
	NSLog(@"%@._didFinishDataRefresh", self.class);
}

- (void)_copyDeeplink {
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = [NSString stringWithFormat:@"http://popup.vlly.im/%d/", _statusUpdateVO.statusUpdateID];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	NSLog(@"DEEPLINK:[%d]", _isDeepLink);
	
	_baseShareInfo = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"GSMessengerShareInfo"
																								ofType:@"plist"]];
	
	[super loadView];
	
	//if ((BOOL)[[[_baseShareInfo objectForKey:kKakaoTalkKey] objectForKey:@"override"] intValue] && [[[_baseShareInfo objectForKey:kKakaoTalkKey] objectForKey:@"image_url"] length] > 0) {
		[[HONImageBroker sharedInstance] writeImageFromWeb:[[_baseShareInfo objectForKey:kKakaoTalkKey] objectForKey:@"image_url"] withUserDefaultsKey:@"kakao_image"];
	//}
	
	if ([[_baseShareInfo objectForKey:@"main_image_url"] length] > 0)
		[[HONImageBroker sharedInstance] writeImageFromWeb:[_baseShareInfo objectForKey:@"main_image_url"] withUserDefaultsKey:@"main_image_url"];
	
	if ([[_baseShareInfo objectForKey:@"sub_image_url"] length] > 0)
		[[HONImageBroker sharedInstance] writeImageFromWeb:[_baseShareInfo objectForKey:@"sub_image_url"] withUserDefaultsKey:@"sub_image_url"];
	
	[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"in_chat"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	_messageTotal = 0;
	
	
	self.view.backgroundColor = (_isDeepLink) ? [UIColor colorWithRed:0.400 green:0.839 blue:0.698 alpha:1.00] : [UIColor blackColor];// [UIColor colorWithRed:0.396 green:0.596 blue:0.922 alpha:1.00];
	self.view.backgroundColor = [UIColor blackColor];
	//_sysVolume = [MPMusicPlayerController applicationMusicPlayer].volume;
	_isShare = NO;
	_isInvite = NO;
	_isActive = YES;
	_isSubmitting = NO;
	_isPlaying = NO;
	_isFinale = YES;
	
	_comment = @"";
	_participants = 0;
	
	_moviePlayer = [[MPMoviePlayerController alloc] init];//WithContentURL:[NSURL URLWithString:@"https://s3.amazonaws.com/popup-vids/video_97D31566-55C7-4142-9ED7-FAA62BF54DB1.mp4"]];
	_moviePlayer.controlStyle = MPMovieControlStyleNone;
	_moviePlayer.view.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:0.396 green:0.596 blue:0.922 alpha:1.00];
	_moviePlayer.shouldAutoplay = YES;
	_moviePlayer.repeatMode = MPMovieRepeatModeNone;// ModeOne;
	_moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
	_moviePlayer.view.frame = self.view.frame;
	_moviePlayer.view.frame = CGRectOffset(_moviePlayer.view.frame, 0.0, -(self.view.frame.size.height - (self.view.frame.size.height * 1.0000)) * 0.5);// self.view.frame;//CGRectMake(0.0, 0.0, self.view.frame.size.width, (self.view.frame.size.height * 1.0000) + 1.0);
	[self.view addSubview:_moviePlayer.view];
    
//    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
//    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
//    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
//    
//    __block NSMutableArray *frames = [NSMutableArray array];
//    [fetchResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        PHAsset *lastAsset = (PHAsset *)obj;
//        [[PHImageManager defaultManager] requestImageForAsset:lastAsset
//                                                   targetSize:self.view.frame.size
//                                                  contentMode:PHImageContentModeAspectFill
//                                                      options:nil
//                                                resultHandler:^(UIImage *result, NSDictionary *info) {
//                                                    NSLog(@"PHImageManager request results %@ and info %@", result, info);
//                                                    [frames addObject:result];
//                                                }];
//    }];
//    
//    
//    UIImageView * animImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
//    animImageView.animationImages = frames;
//    animImageView.animationDuration = [frames count] * 0.125;
//    animImageView.animationRepeatCount = 0;
//    [animImageView startAnimating];
//    [self.view addSubview:animImageView];
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"deadmau5" ofType: @"mp3"];
//    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath ];
//    AVAudioPlayer *myAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
//    myAudioPlayer.numberOfLoops = -1; //infinite loop
//    [myAudioPlayer play];
//    });


	[self.view addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraGradient"]]];
	
	_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, _moviePlayer.view.frame.size.width, _moviePlayer.view.frame.size.height)];
	_imageView.hidden = YES;
	[self.view addSubview:_imageView];
	
	_cameraPreviewView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height * 1.0000, self.view.frame.size.width, self.view.frame.size.height)];
	_cameraPreviewView.backgroundColor = (_isDeepLink) ? [UIColor colorWithRed:0.400 green:0.839 blue:0.698 alpha:1.00] : [UIColor blackColor];
	
	_cameraPreviewLayer = [[PBJVision sharedInstance] previewLayer];
	_cameraPreviewLayer.frame = _cameraPreviewView.bounds;
	_cameraPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[_cameraPreviewView.layer addSublayer:_cameraPreviewLayer];
	[self.view addSubview:_cameraPreviewView];
	
	_finaleTintView = [[UIView alloc] initWithFrame:self.view.frame];
	_finaleTintView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.60];
	_finaleTintView.alpha = 0.0;
	//[self.view addSubview:_finaleTintView];
	
	_videoFocusButton = [HONButton buttonWithType:UIButtonTypeCustom];
	_videoFocusButton.frame = _finaleTintView.frame;
	[_videoFocusButton addTarget:self action:@selector(_goVideoFocus) forControlEvents:UIControlEventTouchUpInside];
	[_finaleTintView addSubview:_videoFocusButton];
	
	
//	AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
//	playerViewController.player = [AVPlayer playerWithURL:];
//	self.avPlayerViewcontroller = playerViewController;
//	[self resizePlayerToViewSize];
//	[view addSubview:playerViewController.view];
//	view.autoresizesSubviews = TRUE;
	
	
	_loadingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
	_loadingImageView.frame = _moviePlayer.view.frame;
	_loadingImageView.backgroundColor = [UIColor redColor];
	_loadingImageView.hidden = YES;
	//[self.view addSubview:_loadingImageView];
	
	_statusUpdateHeaderView = [[HONStatusUpdateHeaderView alloc] initWithStatusUpdateVO:_statusUpdateVO];
	_statusUpdateHeaderView.delegate = self;
	
	_commentFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 55.0, self.view.frame.size.width, 55.0)];
	_commentFooterView.hidden = YES;
	
	_footerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commentInputBG"]];
	[_commentFooterView addSubview:_footerImageView];
	
	_participantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 110.0, 28.0, 100.0, 26.0)];
	_participantsLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:26];
	_participantsLabel.backgroundColor = [UIColor clearColor];
	_participantsLabel.textAlignment = NSTextAlignmentRight;
	_participantsLabel.textColor = [UIColor whiteColor];
	_participantsLabel.text = @"0";
	[self.view addSubview:_participantsLabel];
	
	UIButton *invite2Button = [UIButton buttonWithType:UIButtonTypeCustom];
	invite2Button.frame = _expireLabel.frame;
	[invite2Button addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	//[self.view addSubview:invite2Button];
	
	_tintView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - (_commentFooterView.frame.size.height + 216.0))];
	_tintView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.50];
	_tintView.alpha = 0.0;
	[self.view addSubview:_tintView];
	
	_scrollView = [[HONScrollView alloc] initWithFrame:CGRectMake(0.0, _statusUpdateHeaderView.frameEdges.bottom, self.view.frame.size.width, self.view.frame.size.height - (_statusUpdateHeaderView.frameEdges.bottom + 60.0 + [UIApplication sharedApplication].statusBarFrame.size.height))];
	//	_scrollView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.33];
	_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, 0.0);
	_scrollView.contentInset = UIEdgeInsetsMake(MAX(0.0, (_scrollView.frame.size.height - _commentsHolderView.frame.size.height)), _scrollView.contentInset.left, 10.0, _scrollView.contentInset.right);
	_scrollView.alwaysBounceVertical = YES;
	_scrollView.delegate = self;
	[self.view addSubview:_scrollView];
	
	_animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 206.0) * 0.5, -40.0 + (((self.view.frame.size.height * 1.0000) - 206.0) * 0.5), 206.0, 206.0)];
	_animationImageView.hidden = YES;
	[self.view addSubview:_animationImageView];
	
	
	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityIndicatorView.center = CGPointMake(_animationImageView.bounds.size.width * 0.5, _animationImageView.bounds.size.height * 0.5);
	[activityIndicatorView startAnimating];
	[_animationImageView addSubview:activityIndicatorView];
	
	_flagButton = [HONButton buttonWithType:UIButtonTypeCustom];
	[_flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_nonActive"] forState:UIControlStateNormal];
	[_flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_Active"] forState:UIControlStateHighlighted];
	_flagButton.frame = CGRectOffset(_flagButton.frame, 33.0, -14.0 + ((self.view.frame.size.height - _flagButton.frame.size.height) * 0.5));
	[_flagButton addTarget:self action:@selector(_goFlag) forControlEvents:UIControlEventTouchUpInside];
	_flagButton.alpha = 0.0;
	[_finaleTintView addSubview:_flagButton];
	
	_replayButton = [HONButton buttonWithType:UIButtonTypeCustom];
	[_replayButton setBackgroundImage:[UIImage imageNamed:@"replayButton_nonActive"] forState:UIControlStateNormal];
	[_replayButton setBackgroundImage:[UIImage imageNamed:@"replayButton_Active"] forState:UIControlStateHighlighted];
	_replayButton.frame = CGRectOffset(_replayButton.frame, (self.view.frame.size.width - _replayButton.frame.size.width) * 0.5, -14.0 + ((self.view.frame.size.height - _replayButton.frame.size.height) * 0.5));
	[_replayButton addTarget:self action:@selector(_goReplay) forControlEvents:UIControlEventTouchUpInside];
	_replayButton.alpha = 0.0;
	[_finaleTintView addSubview:_replayButton];
	
	_historyButton = [HONButton buttonWithType:UIButtonTypeCustom];
	[_historyButton setBackgroundImage:[UIImage imageNamed:@"historyButton_nonActive"] forState:UIControlStateNormal];
	[_historyButton setBackgroundImage:[UIImage imageNamed:@"historyButton_Active"] forState:UIControlStateHighlighted];
	_historyButton.frame = CGRectOffset(_historyButton.frame, (self.view.frame.size.width - _historyButton.frame.size.width) - 33.0, -14.0 + ((self.view.frame.size.height - _historyButton.frame.size.height) * 0.5));
	[_historyButton addTarget:self action:@selector(_goNextVideo) forControlEvents:UIControlEventTouchUpInside];
	_historyButton.alpha = 0.0;
	[_finaleTintView addSubview:_historyButton];
	
	
	[self.view addSubview:_statusUpdateHeaderView];
	[self.view addSubview:_commentFooterView];
	
	_toggleMicButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_toggleMicButton.frame = CGRectMake(2.0, (self.view.frame.size.height * 1.0000) + 10.0, 44.0, 44.0);
	[_toggleMicButton setBackgroundImage:[UIImage imageNamed:@"toggleMicButton_nonActive"] forState:UIControlStateNormal];
	[_toggleMicButton setBackgroundImage:[UIImage imageNamed:@"toggleMicButton_Active"] forState:UIControlStateHighlighted];
	[_toggleMicButton addTarget:self action:@selector(_goToggleMic) forControlEvents:UIControlEventTouchUpInside];
	//[self.view addSubview:_toggleMicButton];
	
	_videoVisibleButton = [HONButton buttonWithType:UIButtonTypeCustom];
	_videoVisibleButton.frame = CGRectMake(12.0, (self.view.frame.size.height * 1.0000) - 49.0, 42.0, 42.0);
	[_videoVisibleButton setBackgroundImage:[UIImage imageNamed:@"videoVisibleButton-off_nonActive"] forState:UIControlStateNormal];
	[_videoVisibleButton setBackgroundImage:[UIImage imageNamed:@"videoVisibleButton-off_Active"] forState:UIControlStateHighlighted];
	//_videoVisibleButton.frame = CGRectOffset(_videoVisibleButton.frame, 2.0, (self.view.frame.size.height * 1.0000) - (_videoVisibleButton.frame.size.height + 5.0));
	[_videoVisibleButton addTarget:self action:@selector(_goToggleVideoVisible) forControlEvents:UIControlEventTouchUpInside];
	//[self.view addSubview:_videoVisibleButton];
	
	_openCommentButton = [HONButton buttonWithType:UIButtonTypeCustom];
	_openCommentButton.frame = CGRectMake(0.0, 0.0, 72.0, 72.0);
	[_openCommentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_nonActive"] forState:UIControlStateNormal];
	[_openCommentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_Active"] forState:UIControlStateHighlighted];
	_openCommentButton.frame = CGRectOffset(_openCommentButton.frame, self.view.frame.size.width - _openCommentButton.frame.size.width - 8.0, (self.view.frame.size.height - _openCommentButton.frame.size.height) - 7.0);
	[_openCommentButton addTarget:self action:@selector(_goOpenComment) forControlEvents:UIControlEventTouchUpInside];
	_openCommentButton.enabled = NO;
	[self.view addSubview:_openCommentButton];
	
	_cameraFlipButton = [HONButton buttonWithType:UIButtonTypeCustom];
	_cameraFlipButton.frame = CGRectMake(0.0, 0.0, 44.0, 44.0);
	[_cameraFlipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_nonActive"] forState:UIControlStateNormal];
	[_cameraFlipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_Active"] forState:UIControlStateHighlighted];
	_cameraFlipButton.frame = CGRectOffset(_cameraFlipButton.frame, 10.0, (self.view.frame.size.height - _cameraFlipButton.frame.size.height) - 7.0);
	[_cameraFlipButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
	_cameraFlipButton.enabled = NO;
	[self.view addSubview:_cameraFlipButton];
	
	_nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 181.0 * (([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? kScreenMult.height : 1.0), self.view.frame.size.width - 40.0, 30.0)];
	_nameTextField.backgroundColor = [UIColor clearColor];
	[_nameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_nameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_nameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	_nameTextField.textAlignment = NSTextAlignmentCenter;
	[_nameTextField setReturnKeyType:UIReturnKeySend];
	[_nameTextField setTextColor:[UIColor whiteColor]];
	[_nameTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_nameTextField setTag:0];
	_nameTextField.font = [[[HONFontAllocator sharedInstance] cartoGothicBook] fontWithSize:30];
	_nameTextField.keyboardType = UIKeyboardTypeDefault;
	_nameTextField.placeholder = @"What is your name?";
	_nameTextField.text = @"";
	_nameTextField.hidden = YES;
	_nameTextField.delegate = self;
	[self.view addSubview:_nameTextField];
	
	
	
	_cancelCameraButton = [HONButton buttonWithType:UIButtonTypeCustom];
	_cancelCameraButton.frame = CGRectMake(6.0, 26.0, 40.0, 40.0);
	[_cancelCameraButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
	[_cancelCameraButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
	[_cancelCameraButton addTarget:self action:@selector(_goCancelCamera) forControlEvents:UIControlEventTouchUpInside];
	_cancelCameraButton.hidden = YES;
	[self.view addSubview:_cancelCameraButton];
	
	
	
	_messengerButton = [HONButton buttonWithType:UIButtonTypeCustom];
	_messengerButton.frame = CGRectMake(0.0, 0.0, 72.0, 72.0);
	[_messengerButton setBackgroundImage:[UIImage imageNamed:@"shareButton_nonActive"] forState:UIControlStateNormal];
	[_messengerButton setBackgroundImage:[UIImage imageNamed:@"shareButton_Active"] forState:UIControlStateHighlighted];
	_messengerButton.frame = CGRectOffset(_messengerButton.frame, ((self.view.frame.size.width * 0.5) - _messengerButton.frame.size.width) - 8.0, (self.view.frame.size.height - _messengerButton.frame.size.height) - 55.0);
	[_messengerButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	_messengerButton.enabled = NO;
	[self.view addSubview:_messengerButton];
	
	_takePhotoButton = [HONButton buttonWithType:UIButtonTypeCustom];
	_takePhotoButton.frame = CGRectMake(0.0, 0.0, 72.0, 72.0);
	[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_nonActive"] forState:UIControlStateNormal];
	[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_Active"] forState:UIControlStateHighlighted];
	_takePhotoButton.frame = CGRectOffset(_takePhotoButton.frame, 6.0 + (self.view.frame.size.width * 0.5), (self.view.frame.size.height - _takePhotoButton.frame.size.height) - 55.0);
	[_takePhotoButton addTarget:self action:@selector(_goImageComment) forControlEvents:UIControlEventTouchUpInside];
	_takePhotoButton.enabled = NO;
	[self.view addSubview:_takePhotoButton];
	
	_shareTutorialImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nameTutorial"]];
	_shareTutorialImageView.frame = CGRectOffset(_shareTutorialImageView.frame, 0.0, 25.0 + (_messengerButton.frame.origin.y - _shareTutorialImageView.frame.size.height));
	
	_cameraTutorialImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraTutorial"]];
	_cameraTutorialImageView.frame = CGRectOffset(_cameraTutorialImageView.frame, 0.0, 27.0 + (_takePhotoButton.frame.origin.y - _cameraTutorialImageView.frame.size.height));
	
	if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"channel_tutorial"] isEqualToString:@"YES"]) {
		_isTutorial = YES;
		[self.view addSubview:_cameraTutorialImageView];
	}
	
	_commentsHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _scrollView.frame.size.width, 0.0)];
	[_scrollView addSubview:_commentsHolderView];
	
	_commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 16.0, _commentsHolderView.frame.size.width - 100.0, 23.0)];
	_commentTextField.backgroundColor = [UIColor clearColor];
	[_commentTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_commentTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_commentTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_commentTextField setReturnKeyType:UIReturnKeySend];
	[_commentTextField setTextColor:[UIColor whiteColor]];
	[_commentTextField setTag:1];
	[_commentTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	_commentTextField.font = [[[HONFontAllocator sharedInstance] avenirHeavy] fontWithSize:20];
	_commentTextField.keyboardType = UIKeyboardTypeDefault;
	_commentTextField.placeholder = @"Enter message";
	_commentTextField.text = @"";
	_commentTextField.delegate = self;
	[_commentFooterView addSubview:_commentTextField];
	
	_submitCommentButton = [HONButton buttonWithType:UIButtonTypeCustom];
	_submitCommentButton.frame = CGRectMake(_commentFooterView.frame.size.width - 65.0, 8.0, 50.0, 34.0);
	[_submitCommentButton setBackgroundImage:[UIImage imageNamed:@"submitCommentButton_nonActive"] forState:UIControlStateNormal];
	[_submitCommentButton setBackgroundImage:[UIImage imageNamed:@"submitCommentButton_Active"] forState:UIControlStateHighlighted];
	[_submitCommentButton setBackgroundImage:[UIImage imageNamed:@"submitCommentButton_Disabled"] forState:UIControlStateDisabled];
	[_submitCommentButton addTarget:self action:@selector(_goTextComment) forControlEvents:UIControlEventTouchUpInside];
	_submitCommentButton.hidden = YES;
	[_commentFooterView addSubview:_submitCommentButton];
	
	_countdownLabel = [[UILabel alloc] initWithFrame:_participantsLabel.frame];
	_countdownLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:26];
	_countdownLabel.backgroundColor = [UIColor clearColor];
	_countdownLabel.textAlignment = NSTextAlignmentRight;
	_countdownLabel.textColor = [UIColor whiteColor];
	_countdownLabel.text = @"5";
	_countdownLabel.hidden = YES;
	[self.view addSubview:_countdownLabel];
	
	
	_lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_goLongPress:)];
	_lpGestureRecognizer.minimumPressDuration = 0.25;
	_lpGestureRecognizer.delaysTouchesBegan = YES;
	[self.view addGestureRecognizer:_lpGestureRecognizer];
	
	[self _goSetName];
	
	_messengerShare = [GSMessengerShare sharedInstance];
	[_messengerShare addMessengerShareTypes:@[@(GSMessengerShareTypeFBMessenger), @(GSMessengerShareTypeKik), @(GSMessengerShareTypeWhatsApp), @(GSMessengerShareTypeLine), @(GSMessengerShareTypeKakaoTalk), @(GSMessengerShareTypeWeChat), @(GSMessengerShareTypeSMS), @(GSMessengerShareTypeHike), @(GSMessengerShareTypeViber)]];
	_messengerShare.delegate = self;
	
	_logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"brandingHeader"]];
	_logoImageView.frame = CGRectOffset(_logoImageView.frame, self.view.frame.size.width - _logoImageView.frame.size.width + 14.0, self.view.frame.size.height - _logoImageView.frame.size.height);
	_logoImageView.hidden = YES;
	[self.view addSubview:_logoImageView];
	
	_recordImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recordDot"]];
	_recordImageView.frame = CGRectOffset(_recordImageView.frame, 8.0, 28.0);
	_recordImageView.hidden = YES;
	//[self.view addSubview:_recordImageView];
	
	_expireLabel = [[UILabel alloc] initWithFrame:CGRectMake(25.0, (self.view.frame.size.height * 0.5) - 13.0, self.view.frame.size.width - 50.0, 20.0)];//[[UILabel alloc] initWithFrame:CGRectMake(10.0, (self.view.frame.size.height * 1.0000) - 60.0, self.view.frame.size.width - 20.0, 40.0)];
	_expireLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
	_expireLabel.backgroundColor = [UIColor clearColor];
	_expireLabel.textAlignment = NSTextAlignmentCenter;
	_expireLabel.textColor = [UIColor whiteColor];
	_expireLabel.text = @"Loading channel…";
	[self.view addSubview:_expireLabel];
    
    PHLivePhotoView *livePhotoView = [[PHLivePhotoView alloc] initWithFrame:self.view.frame];
    livePhotoView.backgroundColor = [UIColor redColor];
    //[self.view addSubview:livePhotoView];
    
    
    
//    [[PHImageManager defaultManager] requestLivePhotoForAsset:lastAsset
//                                                   targetSize:self.view.frame.size
//                                                  contentMode:PHImageContentModeDefault
//                                                      options:PHImageRequestOptionsDeliveryModeOpportunistic
//                                                resultHandler:^(PHLivePhoto *livePhoto, NSDictionary *info) {
//                                                    NSLog(@"LIVE PHOTO:\n%@", info);
//                                                    [livePhotoView setLivePhoto:livePhoto];
//                                                }];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:animated:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewDidAppear:animated];
	
	[self _goReloadContent];
}

- (void)viewDidDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidDisappear:animated:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewDidDisappear:animated];
    [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.8];
}


#pragma mark - Navigation
- (void)_goBack {
	if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"back_chat"] isEqualToString:@"YES"]) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
															message:@"This will delete your conversation."
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
												  otherButtonTitles:NSLocalizedString(@"alert_ok", nil), nil];
		[alertView setTag:HONStatusUpdateAlertViewTypeBack];
		[alertView show];
		
	} else {
		[_statusUpdateHeaderView changeTitle:@"Cleaning up…"];
		[self _popBack];
	}
}

- (void)_goShare {
	//[_messengerShare showMessengerSharePickerOnViewController:self];
	
	_shareTypes = [NSMutableArray array];
	
	//[_shareTutorialImageView removeFromSuperview];
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Invite friends to this channel, select a messenger"
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Kik", @"Messenger", @"KakaoTalk", @"Line", @"WhatsApp", @"WeChat", @"SMS", nil];//@"Hike", @"Viber", nil];
	[actionSheet setTag:0];
	[actionSheet showInView:self.view];
}

- (void)_goToggleMic {
	//[[PBJVision sharedInstance] setAudioCaptureEnabled:![PBJVision sharedInstance].isAudioCaptureEnabled];
	
//	[_queuePlayer setMuted:!_queuePlayer.isMuted];
}

- (void)_goToggleVideoVisible {
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"What to hide"
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:[NSString stringWithFormat:@"%@ my camera", (_cameraPreviewView.alpha == 1.0) ? @"Hide" : @"Show"], [NSString stringWithFormat:@"%@ others", (_moviePlayer.view.alpha == 1.0) ? @"Hide" : @"Show"], nil];
	[actionSheet setTag:1];
	[actionSheet showInView:self.view];
}

- (void)_goVideoFocus {
//--	[[MPMusicPlayerController applicationMusicPlayer] setVolume:0.5];
	
	NSURL *url = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:((NSURL *)[_videoPlaylist objectAtIndex:_videoQueue]).lastPathComponent]];
	NSLog(@"QUEUE IND:[%02d/%02d] (%@)(%@)", _videoQueue, [_videoPlaylist count], [_videoPlaylist objectAtIndex:_videoQueue], url);
	
	[[[NSUserDefaults standardUserDefaults] objectForKey:@"cached"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSString *cachedFile = (NSString *)obj;
		
		if ([cachedFile isEqualToString:[url.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""]]) {
			NSLog(@"cachedFile: %@", cachedFile);
			_moviePlayer.contentURL = url;
			*stop = YES;
		}
	}];
	
	if (_moviePlayer.contentURL == nil) {
		_animationImageView.hidden = NO;
		_expireLabel.text = @"Loading video…";
		_expireLabel.alpha = 1.0;
		
		[self _downloadVideo:[url lastPathComponent]];
		_moviePlayer.contentURL = [_videoPlaylist objectAtIndex:_videoQueue];
	}
	
//--	[_moviePlayer play];
	[UIView animateWithDuration:0.250 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
		_finaleTintView.alpha = 0.0;
	} completion:^(BOOL finished) {
		_isFinale = YES;
		_isPlaying = NO;
	}];
}

- (void)_goNextVideo {
	//_isPlaying = YES;
	
	//[_moviePlayer stop];
	//_moviePlayer.contentURL = nil;
	
//--	[[MPMusicPlayerController applicationMusicPlayer] setVolume:0.5];
	
	[self _advanceVideo];
	[UIView animateWithDuration:0.250 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
		_finaleTintView.alpha = 0.0;
		
	} completion:^(BOOL finished) {
		_isFinale = YES;
	}];
}

- (void)_goFlag {
	//	[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - flag"]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
														message:NSLocalizedString(@"alert_flag_m", nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
											  otherButtonTitles:NSLocalizedString(@"alert_ok", nil), nil];
	[alertView setTag:HONStatusUpdateAlertViewTypeFlag];
	[alertView show];
}
- (void)_goReplay {
	_videoQueue = 0;
//--	[[MPMusicPlayerController applicationMusicPlayer] setVolume:0.5];
	_moviePlayer.contentURL = [_videoPlaylist firstObject];
	_isFinale = YES;
	_isPlaying = NO;
	
	[UIView animateWithDuration:0.250 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
		_finaleTintView.alpha = 0.0;
	} completion:^(BOOL finished) {
//--		[_moviePlayer play];
	}];
}

- (void)_goImageComment {
	_statusUpdateHeaderView.hidden = YES;
	
	[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"channel_tutorial"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[_cameraTutorialImageView removeFromSuperview];
	
	
	_finaleTintView.hidden = YES;
	_isFinale = YES;
	
	_imageView.alpha = 0.0;
	_openCommentButton.hidden = YES;
	_animationImageView.hidden = YES;
	
	_openCommentButton.alpha = 0.0;
	_messengerButton.alpha = 0.0;
	
	_logoImageView.hidden = YES;
	_videoVisibleButton.hidden = YES;
	
	_toggleMicButton.hidden = YES;
	_cameraFlipButton.hidden = YES;
	
	_participantsLabel.hidden = YES;
	_expireLabel.alpha = 1.0;
	_expireLabel.hidden = NO;
	_expireLabel.text = @"Ready to record…";
	//_expireLabel.frame = CGRectTranslateY(_expireLabel.frame, (self.view.frame.size.height * 0.5) - 10.0);
	
	_playerLayer.hidden = YES;
	_moviePlayer.view.hidden = YES;
	_submitCommentButton.hidden = YES;
	
	_isPlaying = YES;
	[_moviePlayer stop];
	
	_cameraPreviewView.frame = self.view.frame;
	_cameraPreviewLayer.frame = CGRectFromSize(_cameraPreviewView.frame.size);
	_cameraPreviewLayer.opacity = 1.0;
	
	_cancelCameraButton.hidden = NO;
	[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_Hold"] forState:UIControlStateNormal];
	[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_Pressed"] forState:UIControlStateHighlighted];
	_takePhotoButton.frame = CGRectTranslateX(_takePhotoButton.frame, (self.view.frame.size.width - _takePhotoButton.frame.size.width) * 0.5);
}

- (void)_goCancelCamera {
	_statusUpdateHeaderView.hidden = NO;
	_cancelCameraButton.hidden = YES;
	
	_isFinale = NO;
	_isPlaying = NO;
	_finaleTintView.hidden = NO;
	if ([_videoPlaylist count] > 0) {
		[self _goReplay];
	}
	
	_statusUpdateHeaderView.hidden = NO;
	_countdownLabel.text = @"";
	_countdownLabel.hidden = YES;
	_moviePlayer.view.hidden = NO;
	_playerLayer.hidden = NO;
	_videoVisibleButton.hidden = NO;
	_participantsLabel.hidden = NO;
	_toggleMicButton.hidden = NO;
	_logoImageView.hidden = YES;
	_cameraFlipButton.hidden = NO;
	_expireLabel.hidden = NO;
	
	_openCommentButton.alpha = 1.0;
	_messengerButton.alpha = 1.0;
	_openCommentButton.hidden = NO;
	_messengerButton.hidden = NO;
	
	_expireLabel.text = @"";
	_expireLabel.alpha = 0.0;
//	_expireLabel.frame = CGRectTranslateY(_expireLabel.frame, self.view.frame.size.height - 40.0);
	
	_takePhotoButton.alpha = 1.0;
	_cameraPreviewView.frame = CGRectMake(0.0, self.view.frame.size.height * 1.0000, self.view.frame.size.width, self.view.frame.size.height);
	[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_nonActive"] forState:UIControlStateNormal];
	[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_Active"] forState:UIControlStateHighlighted];
	_takePhotoButton.frame = CGRectTranslateX(_takePhotoButton.frame, 3.0 + (self.view.frame.size.width * 0.5));
	_cancelCameraButton.hidden = YES;
	
//--	if (_moviePlayer.contentURL != nil)
//--		[_moviePlayer play];
}

- (void)_goShareComment {
	[[[UIAlertView alloc] initWithTitle:nil
								message:@"Tap and hold to share"
							   delegate:nil
					  cancelButtonTitle:NSLocalizedString(@"alert_ok", @"Cancel")
					  otherButtonTitles:nil] show];
}

- (void)_goSetName {
	
	_comment = _nameTextField.text;
	[_statusUpdateHeaderView changeTitle:@""];
	
	_cameraPreviewView.hidden = NO;
	
	if ([_nameTextField isFirstResponder])
		[_nameTextField resignFirstResponder];
	
	_nameButton.hidden = YES;
	_nameTextField.hidden = YES;
	_commentTextField.hidden = NO;
	
	_cameraPreviewView.hidden = NO;
	
	[self _goCancelComment];
}

- (void)_goTextComment {
	[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - sendChat"] withProperties:@{@"channel"	: _channelName}];
	
	_isSubmitting = YES;
	[_submitCommentButton setEnabled:NO];
	
	_comment = _commentTextField.text;
	_commentTextField.text = @"";
	[self _submitTextComment];
}

- (void)_goOpenComment {
	if (![_commentTextField isFirstResponder])
		[_commentTextField becomeFirstResponder];
}

- (void)_goCancelComment {
	if (_expireTimer != nil) {
		[_expireTimer invalidate];
		_expireTimer = nil;
	}
	
	[_statusUpdateHeaderView changeButton:YES];
	
	_videoVisibleButton.hidden = NO;
	_commentTextField.text = @"";
	_expireLabel.hidden = NO;
	_commentFooterView.hidden = YES;
	_takePhotoButton.hidden = NO;
	_scrollView.hidden = YES;
	_toggleMicButton.hidden = NO;
	_cameraFlipButton.hidden = NO;
	_openCommentButton.alpha = 1.0;
	_messengerButton.alpha = 1.0;
	
	[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"text"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if ([_commentTextField isFirstResponder]) {
		[_commentTextField resignFirstResponder];
		
		_cameraPreviewView.hidden = YES;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
			_cameraPreviewView.hidden = NO;
		});
	}
	
	_commentTextField.placeholder = @"";
	_scrollView.hidden = YES;
	_scrollView.frame = CGRectResizeHeight(_scrollView.frame, self.view.frame.size.height - (_statusUpdateHeaderView.frameEdges.bottom + 60.0 + [UIApplication sharedApplication].statusBarFrame.size.height));
	
	_submitCommentButton.hidden = YES;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		
		_cameraPreviewView.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
	
	if (_scrollView.contentSize.height - _scrollView.frame.size.height > 0)
		[_scrollView setContentOffset:CGPointMake(0.0, MAX(0.0, _scrollView.contentSize.height - _scrollView.frame.size.height)) animated:YES];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_tintView.alpha = 0.0;
		_messengerButton.alpha = 1.0;
		_commentFooterView.frame = CGRectTranslateY(_commentFooterView.frame, self.view.frame.size.height - _commentFooterView.frame.size.height);
		[_scrollView setContentInset:UIEdgeInsetsMake(MAX(0.0, (_scrollView.frame.size.height - _commentsHolderView.frame.size.height)), _scrollView.contentInset.left, _scrollView.contentInset.bottom, _scrollView.contentInset.right)];
	} completion:^(BOOL finished) {
	}];
}

-(void)_goLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		NSLog(@"gestureRecognizer.state:[%@]", NSStringFromUIGestureRecognizerState(gestureRecognizer.state));
		
		CGPoint touchPoint = [gestureRecognizer locationInView:self.view];
		NSLog(@"TOUCH:%@", NSStringFromCGPoint(touchPoint));
		
		if (CGRectContainsPoint(_takePhotoButton.frame, touchPoint)) {// || CGRectContainsPoint(_messengerButton.frame, touchPoint)) {
			_isShare = CGRectContainsPoint(_messengerButton.frame, touchPoint);
			
			if ([_commentTextField isFirstResponder])
				[_commentTextField resignFirstResponder];
			
			_commentTextField.text = @"";
			
			[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"channel_tutorial"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			[_cameraTutorialImageView removeFromSuperview];
			
			_imageView.alpha = 0.0;
			_openCommentButton.hidden = YES;
			_animationImageView.hidden = YES;
			
			_openCommentButton.alpha = 0.0;
			_messengerButton.alpha = 0.0;
			
			_isFinale = YES;
			_finaleTintView.hidden = YES;
			
			_logoImageView.hidden = YES;
			_videoVisibleButton.hidden = YES;
			
			_toggleMicButton.hidden = YES;
			_cameraFlipButton.hidden = YES;
			
			_participantsLabel.hidden = YES;
			_expireLabel.hidden = YES;
			_expireLabel.text = @"";
			//_expireLabel.frame = CGRectTranslateY(_expireLabel.frame, self.view.frame.size.height - 40.0);
			
			_playerLayer.hidden = YES;
			_moviePlayer.view.hidden = YES;
			_submitCommentButton.hidden = YES;
			
			_isPlaying = YES;
			[_moviePlayer stop];
			_cameraPreviewView.frame = self.view.frame;
			_cameraPreviewLayer.frame = CGRectFromSize(_cameraPreviewView.frame.size);
			_cameraPreviewLayer.opacity = 1.0;
			
			_statusUpdateHeaderView.hidden = YES;
			_scrollView.hidden = YES;
			
			_commentFooterView.frame = CGRectTranslateY(_commentFooterView.frame, self.view.frame.size.height - _commentFooterView.frame.size.height);
			
			
			_countdown = 5;
			_countdownLabel.text = [NSString stringWithFormat:@":%02d", _countdown];
			_countdownLabel.hidden = NO;
			
			_recordImageView.hidden = NO;
//			_prerecordCounter = 0;
//			_preRecordTimer = [NSTimer scheduledTimerWithTimeInterval:0.50
//															   target:self
//															 selector:@selector(_updatePrerecord)
//															 userInfo:nil repeats:YES];
			
			[[PBJVision sharedInstance] startVideoCapture];
			
			_countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.00
															   target:self
															 selector:@selector(_updateCountdown)
															 userInfo:nil repeats:YES];

			
		}
		
	} else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		//[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - sendVideo"] withProperties:@{@"channel"	: @(_statusUpdateVO.statusUpdateID)}];
		
		NSLog(@"gestureRecognizer.state:[%@]", NSStringFromUIGestureRecognizerState(gestureRecognizer.state));
//---		_cameraPreviewView.frame = CGRectMake(0.0, self.view.frame.size.height * 1.0000, self.view.frame.size.width, self.view.frame.size.height * 1.0000);
		_cameraPreviewView.frame = CGRectMake(0.0, self.view.frame.size.height * 1.0000, self.view.frame.size.width, self.view.frame.size.height);
		
		_statusLabel.text = @"Sending popup…";
		_recordImageView.hidden = YES;
		_statusUpdateHeaderView.hidden = NO;
		
		if (_preRecordTimer) {
			[_preRecordTimer invalidate];
			_preRecordTimer = nil;
		}
		
		_finaleTintView.hidden = NO;
		
		[[PBJVision sharedInstance] endVideoCapture];
		_statusUpdateHeaderView.hidden = NO;
		_countdownLabel.text = @"";
		_countdownLabel.hidden = YES;
		_moviePlayer.view.hidden = NO;
		_playerLayer.hidden = NO;
		_videoVisibleButton.hidden = NO;
		_participantsLabel.hidden = NO;
		_toggleMicButton.hidden = NO;
		_logoImageView.hidden = YES;
		_cameraFlipButton.hidden = NO;
		_expireLabel.hidden = NO;
		
		_openCommentButton.alpha = 1.0;
		_messengerButton.alpha = 1.0;
		_openCommentButton.hidden = NO;
		_messengerButton.hidden = NO;
		
		_takePhotoButton.alpha = 1.0;
		[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_nonActive"] forState:UIControlStateNormal];
		[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_Active"] forState:UIControlStateHighlighted];
		_takePhotoButton.frame = CGRectTranslateX(_takePhotoButton.frame, 3.0 + (self.view.frame.size.width * 0.5));
		_cancelCameraButton.hidden = YES;
	}
}

- (void)_goFlipCamera {
	//	[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - flip_camera"]];
	
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
	_moviePlayer.contentURL = nil;
	_statusLabel.text = @"Send a pop…";
	[_moviePlayer stop];
	
//--	[[MPMusicPlayerController applicationMusicPlayer] setVolume:0.5];
}

- (void)_appLeavingBackground:(NSNotification *)notification {
	_isActive = YES;
	
//--	if (_moviePlayer.contentURL != nil)
//--		[_moviePlayer play];
}

- (void)_playbackStateChanged:(NSNotification *)notification {
	NSLog(@"_playbackStateChangedNotification:[%d][%d]", (int)_moviePlayer.loadState, (int)_moviePlayer.playbackState);
	
	if (_moviePlayer.duration == _moviePlayer.playableDuration) {
//	if (_moviePlayer.loadState == 0 && _moviePlayer.playbackState == 1) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
			_loadingImageView.hidden = YES;
			
			[UIView animateWithDuration:0.125 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
				_animationImageView.alpha = 0.0;
				_expireLabel.alpha = 0.0;
			} completion:^(BOOL finished) {
				_animationImageView.hidden = YES;
				_animationImageView.alpha = 1.0;
			}];
			
			_imageView.alpha = 0.0;
			_imageView.hidden = YES;
			
			_takePhotoButton.enabled = YES;
			_messengerButton.enabled = YES;
			_cameraFlipButton.enabled = YES;
			_openCommentButton.enabled = YES;
		});
	}
	
	if (_moviePlayer.loadState == 0 && _moviePlayer.playbackState == 1) {
//		_bufferTimer = [NSTimer scheduledTimerWithTimeInterval:5.00
//														target:self
//													  selector:@selector(_restartPlayback)
//													  userInfo:nil repeats:NO];
	}
	
	if (_moviePlayer.loadState == 3) {
		[_bufferTimer invalidate];
		
		if (_bufferTimer != nil)
			_bufferTimer = nil;
	}
	
	if (_moviePlayer.loadState == 3 && _moviePlayer.playbackState == 1) {
		if (![_commentTextField isFirstResponder] && _openCommentButton.alpha != 0.0) {
			_openCommentButton.alpha = 1.0;
			_messengerButton.alpha = 1.0;
			_openCommentButton.hidden = NO;
			_messengerButton.hidden = NO;
			
			[UIView animateWithDuration:0.250 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
				_expireLabel.alpha = 0.0;
			} completion:^(BOOL finished) {
			}];
		}
		
		[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - playVideo"] withProperties:@{@"file"		: [[_moviePlayer.contentURL absoluteString] lastComponentByDelimeter:@"/"],
																																	  @"channel"	: _channelName}];
		
	}
}

//- (void)_playerItemEnded:(NSNotification *)notification {
//	NSLog(@"_playerItemEndedNotification:[%@]", [notification object]);
//	
//	_videoQueue = ++_videoQueue % [_queuePlayer.items count];
//	NSLog(@"QueuePlayerItems:[%d]\n%@", _videoQueue, _queuePlayer.items);
//	
////	AVPlayerItem *playerItem = [_queuePlayer currentItem];
//	AVPlayerItem *playerItem = ([_queuePlayer.items count] > 1) ? [_queuePlayer.items lastObject] : [_queuePlayer currentItem];
//	[playerItem seekToTime:kCMTimeZero];
//	
//	if ([_queuePlayer.items count] > 1)
//		[_queuePlayer advanceToNextItem];
//	
//	[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - playVideo"] withProperties:@{@"file"		: [[((AVURLAsset *)playerItem.asset).URL absoluteString] lastComponentByDelimeter:@"/"],
//																																  @"channel"	: _channelName}];
//	
//	
//}

- (void)_playbackEnded:(NSNotification *)notification {
	NSLog(@"_playbackEndedNotification:[%@]", [notification object]);
	
	if (!_isPlaying) {
//		if (_isFinale) {
//			_isFinale = NO;
//			[_moviePlayer play];
//		
//		} else {
			[self _advanceVideo];
			[UIView animateWithDuration:0.250 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseIn) animations:^(void) {
				_finaleTintView.alpha = 1.0;
				_flagButton.alpha = 1.0;
				_replayButton.alpha = 1.0;
				_historyButton.alpha = 1.0;

			} completion:^(BOOL finished) {
//				if ([MPMusicPlayerController applicationMusicPlayer].volume != 0.0)
//					[[MPMusicPlayerController applicationMusicPlayer] setVolume:0.0];
			}];
		}
//	}
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
	
	if (textField.tag == 0 && [textField.text length] == 0)
		textField.text = @"What is your name?";
}


#pragma mark - UI Presentation
- (void)_setupCamera {
	PBJVision *vision = [PBJVision sharedInstance];
	vision.delegate = self;
	vision.cameraDevice = ([vision isCameraDeviceAvailable:PBJCameraDeviceFront]) ? PBJCameraDeviceFront : PBJCameraDeviceBack;
//	[vision setMaximumCaptureDuration:CMTimeMakeWithSeconds(5, 600)];
	vision.cameraMode = PBJCameraModeVideo;
	vision.cameraOrientation = PBJCameraOrientationPortrait;
	vision.focusMode = PBJFocusModeLocked;// PBJFocusModeContinuousAutoFocus;
	vision.exposureMode = PBJExposureModeContinuousAutoExposure;
	vision.outputFormat = PBJOutputFormatStandard;
	vision.videoRenderingEnabled = YES;
	vision.captureSessionPreset = AVCaptureSessionPresetLow;
	[vision setPresentationFrame:_cameraPreviewView.frame];
	[vision setVideoFrameRate:24];
	vision.additionalCompressionProperties = @{AVVideoProfileLevelKey : AVVideoProfileLevelH264MainAutoLevel,
											   AVVideoAllowFrameReorderingKey : @(NO)}; // AVVideoProfileLevelKey requires specific captureSessionPreset
	
	_focusTimer = [NSTimer scheduledTimerWithTimeInterval:2.50
												   target:self
												 selector:@selector(_updateFocus)
												 userInfo:nil repeats:YES];
	
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

- (void)_updateCountdown {
	if (--_countdown <= 0) {
		[_countdownTimer invalidate];
		_countdownTimer = nil;
		
		_countdownLabel.text = @"";
		_countdownLabel.hidden = YES;
//		_expireLabel.hidden = NO;
	}
	
	_countdownLabel.text = [NSString stringWithFormat:@":%02d", _countdown];
}


- (void)_updateFocus {
	CGPoint adjustPoint = [PBJVisionUtilities convertToPointOfInterestFromViewCoordinates:self.view.center inFrame:self.view.frame];
	[[PBJVision sharedInstance] focusExposeAndAdjustWhiteBalanceAtAdjustedPoint:adjustPoint];
}

- (void)_updatePrerecord {
	_recordImageView.hidden = !_recordImageView.hidden;
	
	if (++_prerecordCounter == 6) {
		[_preRecordTimer invalidate];
		_preRecordTimer = nil;
		_recordImageView.hidden = NO;
		[[PBJVision sharedInstance] startVideoCapture];
		
		_countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.00
														   target:self
														 selector:@selector(_updateCountdown)
														 userInfo:nil repeats:YES];
	}
}

- (void)_restartPlayback {
	[_bufferTimer invalidate];
	_bufferTimer = nil;
	
	[_moviePlayer stop];
//--	[_moviePlayer play];
}

- (void)_advanceVideo {
	_isPlaying = NO;
	
	_imageView.hidden = NO;
	_imageView.alpha = 1.0;
	
	if ([_videoPlaylist count] > 0) {
		_videoQueue = ++_videoQueue % [_videoPlaylist count];
		NSURL *url = [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:((NSURL *)[_videoPlaylist objectAtIndex:_videoQueue]).lastPathComponent]];
		NSLog(@"QUEUE IND:[%02d/%02d] (%@)(%@)", _videoQueue, [_videoPlaylist count], [_videoPlaylist objectAtIndex:_videoQueue], url);
		
		[[[NSUserDefaults standardUserDefaults] objectForKey:@"cached"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSString *cachedFile = (NSString *)obj;
			
			if ([cachedFile isEqualToString:[url.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""]]) {
				NSLog(@"cachedFile: %@", cachedFile);
				_moviePlayer.contentURL = url;
				*stop = YES;
			}
		}];
		
		
		if (_moviePlayer.contentURL == nil) {
			_animationImageView.hidden = NO;
			_expireLabel.text = @"Loading video…";
			_expireLabel.alpha = 1.0;
			
			[self _downloadVideo:[url lastPathComponent]];
			_moviePlayer.contentURL = [_videoPlaylist objectAtIndex:_videoQueue];
		}
	}
	
//--	[_moviePlayer play];
}

- (void)_updateTint {
//	NSArray *colors = @[//[UIColor colorWithRed:0.396 green:0.596 blue:0.922 alpha:1.00],
//						[UIColor colorWithRed:0.839 green:0.729 blue:0.400 alpha:1.00],
//						[UIColor colorWithRed:0.400 green:0.839 blue:0.698 alpha:1.00],
//						[UIColor colorWithRed:0.337 green:0.239 blue:0.510 alpha:1.00]];
	
	//UIColor *color = [colors randomElement];
	[UIView animateWithDuration:0.25 animations:^(void) {
	} completion:nil];
}

- (void)_pokeMessage {
	[_client publish:_comment toChannel:@"user has requested you to record a Popup" mobilePushPayload:@{@"apns"	: @{@"aps"	: @{@"alert"	: @"user has requested you to record a Popup",
																																@"sound"	: @"selfie_notification.aif",
																																@"channel"	: _channelName}}} withCompletion:^(PNPublishStatus *status) {
																																	NSLog(@"\nSEND");// MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
																																}];
}

- (void)_popBack {
	[_focusTimer invalidate];
	_focusTimer = nil;
	
	if (_expireTimer != nil) {
		[_expireTimer invalidate];
		_expireTimer = nil;
	}
	
	_moviePlayer.repeatMode = MPMovieRepeatModeOne;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerPlaybackStateDidChangeNotification
												  object:_moviePlayer];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerPlaybackDidFinishNotification
												  object:_moviePlayer];
	
	
	NSMutableArray *channels = [[[NSUserDefaults standardUserDefaults] objectForKey:@"channel_history"] mutableCopy];
	__block BOOL isFound = NO;
	
	[channels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSMutableDictionary *dict = [(NSDictionary *)obj mutableCopy];
		if ([[dict objectForKey:@"channel"] isEqualToString:_channelName]) {
			[dict setObject:[_outboundURL stringByReplacingOccurrencesOfString:@"http://" withString:@""] forKey:@"title"];
			[dict setObject:_channelName forKey:@"channel"];
			[dict setObject:_outboundURL forKey:@"url"];
			[dict setObject:[NSDate date] forKey:@"timestamp"];
			[dict setObject:@(_participants) forKey:@"occupants"];
			
			[channels replaceObjectAtIndex:idx withObject:[dict copy]];
			[[NSUserDefaults standardUserDefaults] setObject:[channels copy] forKey:@"channel_history"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			isFound = YES;
			*stop = YES;
		}
	}];
	
	
	if (!isFound) {
		[channels addObject:@{@"title"		: [_outboundURL stringByReplacingOccurrencesOfString:@"http://" withString:@""],
							  @"channel"	: _channelName,
							  @"url"		: _outboundURL,
							  @"timestamp"	: [NSDate date],
							  @"occupants"	: @(_participants)}];
		
		[[NSUserDefaults standardUserDefaults] setObject:[channels copy] forKey:@"channel_history"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	NSLog(@"CHANNEL_HISTORY:\n%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"channel_history"]);
	
	[[NSUserDefaults standardUserDefaults] setObject:NSStringFromBOOL(NO) forKey:@"chat_share"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
//--	[[MPMusicPlayerController applicationMusicPlayer] setVolume:0.5];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[[PBJVision sharedInstance] stopPreview];
		[_moviePlayer stop];
		_moviePlayer.contentURL = nil;
		_moviePlayer = nil;
	});
	
	[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"in_chat"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - GSMessengerShare Delegates
- (void)didCloseMessengerShare {
	NSLog(@"[*:*] didCloseMessengerShare [*:*]");
}

- (void)didSelectMessengerShareWithType:(GSMessengerShareType)messengerType {
	NSLog(@"[*:*] didSelectMessengerShareWithType:[%d] [*:*]", (int)messengerType);
	[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - sharePopup"] withProperties:@{@"channel"	: _channelName, @"messenger"	: (messengerType == GSMessengerShareTypeFBMessenger) ? @"Messenger" : (messengerType == GSMessengerShareTypeHike) ? @"Hike" : (messengerType == GSMessengerShareTypeKakaoTalk) ? @"Kakao" : (messengerType == GSMessengerShareTypeKik) ? @"Kik" : (messengerType == GSMessengerShareTypeLine) ? @"Line" : (messengerType == GSMessengerShareTypeSMS) ? @"SMS" : (messengerType == GSMessengerShareTypeViber) ? @"Viber" : (messengerType == GSMessengerShareTypeWeChat) ? @"WeChat" : (messengerType == GSMessengerShareTypeWhatsApp) ? @"WhatsApp" : @"OTHER"}];
	
	[[GSMessengerShare sharedInstance] dismissMessengerSharePicker];
}

- (void)didSkipMessengerShare {
	NSLog(@"[*:*] didSkipMessengerShare [*:*]");
	
	if ([[_moviePlayer.contentURL absoluteString] length] > 0) {
		[_moviePlayer stop];
//--		[_moviePlayer play];
	}
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
	
	//	[[HONAnalyticsReporter sharedInstance] trackEvent:[@"DETAILS - " stringByAppendingString:typeName]];
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


#pragma mark - StatusUpdateHeaderView Delegates
- (void)statusUpdateHeaderViewChangeCamera:(HONStatusUpdateHeaderView *)statusUpdateHeaderView {
	NSLog(@"[*:*] statusUpdateHeaderViewChangeCamera [*:*]");
	//	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - flip_camera"];
	
	PBJVision *vision = [PBJVision sharedInstance];
	vision.cameraDevice = (vision.cameraDevice == PBJCameraDeviceBack) ? PBJCameraDeviceFront : PBJCameraDeviceBack;
}

- (void)statusUpdateHeaderViewCopyLink:(HONStatusUpdateHeaderView *)statusUpdateHeaderView {
	NSLog(@"[*:*] statusUpdateHeaderViewCopyLink [*:*]");
	[self _goFlag];
}

- (void)statusUpdateHeaderViewGoBack:(HONStatusUpdateHeaderView *)statusUpdateHeaderView {
	NSLog(@"[*:*] statusUpdateHeaderViewGoBack [*:*]");
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"text"] isEqualToString:@"NO"])
		[self _goBack];
	
	else
		[self _goCancelComment];
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
	
	_shareTutorialImageView.hidden = YES;
	_commentFooterView.hidden = NO;
	_expireLabel.hidden = YES;
	_scrollView.hidden = NO;
	_toggleMicButton.hidden = YES;
	_cameraFlipButton.hidden = YES;
	_videoVisibleButton.hidden = YES;
	_scrollView.frame = CGRectResizeHeight(_scrollView.frame, self.view.frame.size.height - (_statusUpdateHeaderView.frameEdges.bottom + _commentFooterView.frame.size.height + 216.0 + 10.0));
	_submitCommentButton.hidden = NO;
	_openCommentButton.alpha = 0.0;
	_messengerButton.alpha = 0.0;
	
	[_statusUpdateHeaderView changeButton:NO];
	
	_expireTimer = [NSTimer scheduledTimerWithTimeInterval:(arc4random() % 25) + 30.0
													target:self
													 selector:@selector(_pokeMessage)
													 userInfo:nil repeats:NO];
	
	if (textField.tag == 1) {
		_cameraPreviewView.hidden = YES;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
			_cameraPreviewView.hidden = NO;
		});
		
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"text"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		_commentTextField.placeholder = @"Type a message…";
		_scrollView.hidden = NO;
		
	} else {
	}
	
	if (_scrollView.contentSize.height - _scrollView.frame.size.height > 0)
		[_scrollView setContentOffset:CGPointMake(0.0, MAX(0.0, _scrollView.contentSize.height - _scrollView.frame.size.height)) animated:YES];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_tintView.alpha = 1.0;
		[_scrollView setContentInset:UIEdgeInsetsMake(MAX(0.0, (_scrollView.frame.size.height - _commentsHolderView.frame.size.height)), _scrollView.contentInset.left, _scrollView.contentInset.bottom, _scrollView.contentInset.right)];
		_commentFooterView.frame = CGRectTranslateY(_commentFooterView.frame, self.view.frame.size.height - (_commentFooterView.frame.size.height + 216.0));
		_messengerButton.alpha = 0.0;
	} completion:^(BOOL finished) {
	}];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (!_isSubmitting && [textField.text length] > 0 && textField.tag == 1)
		[self _goTextComment];
	
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([string rangeOfCharacterFromSet:[NSCharacterSet invalidCharacterSet]].location != NSNotFound)
		return (NO);
	
	if (textField.tag == 0 && [textField.text isEqualToString:@"What is your name?"])
		textField.text = @"";
	
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


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		
		GSMessengerShareType _selectedMessengerType = (GSMessengerShareType)buttonIndex + 1;
		[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - sharePopup"] withProperties:@{@"channel"	: _channelName, @"messenger"	: (_selectedMessengerType == GSMessengerShareTypeFBMessenger) ? @"Messenger" : (_selectedMessengerType == GSMessengerShareTypeHike) ? @"Hike" : (_selectedMessengerType == GSMessengerShareTypeKakaoTalk) ? @"Kakao" : (_selectedMessengerType == GSMessengerShareTypeKik) ? @"Kik" : (_selectedMessengerType == GSMessengerShareTypeLine) ? @"Line" : (_selectedMessengerType == GSMessengerShareTypeSMS) ? @"SMS" : (_selectedMessengerType == GSMessengerShareTypeViber) ? @"Viber" : (_selectedMessengerType == GSMessengerShareTypeWeChat) ? @"WeChat" : (_selectedMessengerType == GSMessengerShareTypeWhatsApp) ? @"WhatsApp" : @"OTHER"}];
		
		NSDictionary *shareInfo = [self _shareInfoForMessengerShareType:_selectedMessengerType];
		NSLog(@"shareInfo:\n%@", shareInfo);
		
		if (_selectedMessengerType == GSMessengerShareTypeFBMessenger) {
			NSError *error;
			NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[shareInfo objectForKey:@"options"]
															   options:0
																 error:&error];
			
			if ([FBSDKMessengerSharer messengerPlatformCapabilities] & FBSDKMessengerPlatformCapabilityImage) {
				FBSDKMessengerURLHandler *messengerURLHandler = [[FBSDKMessengerURLHandler alloc] init];
				messengerURLHandler.delegate = self;
				
				FBSDKMessengerShareOptions *options = [[FBSDKMessengerShareOptions alloc] init];
				options.metadata = [[NSString alloc] initWithData:jsonData
														 encoding:NSUTF8StringEncoding];
				options.contextOverride = [[FBSDKMessengerBroadcastContext alloc] init];
				
				_selectedMessengerContent = @{@"share_image"	: [shareInfo objectForKey:@"share_image"],
											  @"options"		: options};
				
				UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
				pasteboard.string = [NSString stringWithFormat:@"%@ %@", [shareInfo objectForKey:@"body_text"], [shareInfo objectForKey:@"link"]];
				
				NSString *caption = _expireLabel.text;
				_expireLabel.text = @"Launching FB Messenger to share…";
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
					_expireLabel.text = caption;
				});
				
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
				[FBSDKMessengerSharer shareImage:[_selectedMessengerContent objectForKey:@"share_image"]
									 withOptions:[_selectedMessengerContent objectForKey:@"options"]];
				
//				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You are being directed to Messenger."
//																	message:@"Use the selected messenger to share your Popup with friends."
//																   delegate:self
//														  cancelButtonTitle:@"OK"
//														  otherButtonTitles:nil];
//				[alertView setTag:GSMessengerShareTypeFBMessenger];
//				[alertView show];
				});
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"FB Messenger Not Available!"
											message:@"Cannot open FB Messenger on this device"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
			
		} else if (_selectedMessengerType == GSMessengerShareTypeKakaoTalk) {
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"kakaotalk://"]]) {
				
				_selectedMessengerContent = @{@"link_objs"	: [shareInfo objectForKey:@"link_objs"]};
				
				UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
				pasteboard.string = [NSString stringWithFormat:@"%@ %@", [shareInfo objectForKey:@"body_text"], [shareInfo objectForKey:@"link"]];
				
				NSString *caption = _expireLabel.text;
				_expireLabel.text = @"Launching Kakao to share…";
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
					_expireLabel.text = caption;
				});
				
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
				[KOAppCall openKakaoTalkAppLink:[_selectedMessengerContent objectForKey:@"link_objs"]];
				
//				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You are being directed to Kakao."
//																	message:@"Use the selected messenger to share your Popup with friends."
//																   delegate:self
//														  cancelButtonTitle:@"OK"
//														  otherButtonTitles:nil];
//				[alertView setTag:GSMessengerShareTypeKakaoTalk];
//				[alertView show];
				});
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"KakaoTalk Not Available!"
											message:@"Cannot open KakaoTalk right now"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
			
		} else if (_selectedMessengerType == GSMessengerShareTypeKik) {
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"card://"]]) {
				_selectedMessengerContent = @{@"link"	: [@"card://" stringByAppendingFormat:@"kik.popup.rocks/index.php?d=%@&a=popup", _channelName]};
				
				UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
				pasteboard.string = [NSString stringWithFormat:@"%@ %@", [shareInfo objectForKey:@"body_text"], [shareInfo objectForKey:@"outbound_url"]];
				
				NSString *caption = _expireLabel.text;
				_expireLabel.text = @"Launching Kik to share…";
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
					_expireLabel.text = caption;
				});
				
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[_selectedMessengerContent objectForKey:@"link"]]];
				
//				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You are being directed to Kik."
//																	message:@"Use the selected messenger to share your Popup with friends."
//																   delegate:self
//														  cancelButtonTitle:@"OK"
//														  otherButtonTitles:nil];
//				[alertView setTag:GSMessengerShareTypeKik];
//				[alertView show];
				});
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"Kik Not Available!"
											message:@"Cannot open Kik on this device"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
			
		} else if (_selectedMessengerType == GSMessengerShareTypeLine) {
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"line://"]]) {
				
				_selectedMessengerContent = @{@"link"	: [@"line://" stringByAppendingFormat:@"msg/text/%@", [[[shareInfo objectForKey:@"body_text"] stringByAppendingString:[shareInfo objectForKey:@"link"]] urlEncodedString]]};
				
				UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
				pasteboard.string = [NSString stringWithFormat:@"%@ %@", [shareInfo objectForKey:@"body_text"], [shareInfo objectForKey:@"link"]];
				
				NSString *caption = _expireLabel.text;
				_expireLabel.text = @"Launching LINE to share…";
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
					_expireLabel.text = caption;
				});
				
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[_selectedMessengerContent objectForKey:@"link"]]];
				
//				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You are being directed to LINE."
//																	message:@"Use the selected messenger to share your Popup with friends."
//																   delegate:self
//														  cancelButtonTitle:@"OK"
//														  otherButtonTitles:nil];
//				[alertView setTag:GSMessengerShareTypeLine];
//				[alertView show];
				});
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"LINE Not Available!"
											message:@"Cannot open LINE on this device"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
			
		} else if (_selectedMessengerType == GSMessengerShareTypeSMS) {
			if ([MFMessageComposeViewController canSendText]) {
				
				_selectedMessengerContent = @{@"body_text"	: [shareInfo objectForKey:@"body_text"],
											  @"link"		: [shareInfo objectForKey:@"link"]};
				
				UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
				pasteboard.string = [NSString stringWithFormat:@"%@ %@", [shareInfo objectForKey:@"body_text"], [shareInfo objectForKey:@"link"]];
				
				NSString *caption = _expireLabel.text;
				_expireLabel.text = @"Launching SMS to share…";
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
					_expireLabel.text = caption;
				});
				
				MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
				messageComposeViewController.body = [NSString stringWithFormat:@"%@\n%@", [_selectedMessengerContent objectForKey:@"body_text"], [_selectedMessengerContent objectForKey:@"link"]];
				messageComposeViewController.messageComposeDelegate = self;
				[self presentViewController:messageComposeViewController animated:YES completion:^(void) {}];
				
//				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You are being directed to SMS."
//																	message:@"Use the selected messenger to share your Popup with friends."
//																   delegate:self
//														  cancelButtonTitle:@"OK"
//														  otherButtonTitles:nil];
//				[alertView setTag:GSMessengerShareTypeSMS];
//				[alertView show];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"SMS Not Available!"
											message:@"SMS is not allowed for this device"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
			
		} else if (_selectedMessengerType == GSMessengerShareTypeWhatsApp) {
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"whatsapp://"]]) {
				
				_selectedMessengerContent = @{@"link"	: [@"whatsapp://" stringByAppendingFormat:@"send?text=%@&abid=", [[NSString stringWithFormat:@"%@ %@", [shareInfo objectForKey:@"body_text"], [shareInfo objectForKey:@"link"]] urlEncodedString]]};
				
				UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
				pasteboard.string = [NSString stringWithFormat:@"%@ %@", [shareInfo objectForKey:@"body_text"], [shareInfo objectForKey:@"link"]];
				
				NSString *caption = _expireLabel.text;
				_expireLabel.text = @"Launching WhatsApp to share…";
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
					_expireLabel.text = caption;
				});
				
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[_selectedMessengerContent objectForKey:@"link"]]];
				
//				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You are being directed to WhatsApp."
//																	message:@"Use the selected messenger to share your Popup with friends."
//																   delegate:self
//														  cancelButtonTitle:@"OK"
//														  otherButtonTitles:nil];
//				[alertView setTag:GSMessengerShareTypeWhatsApp];
//				[alertView show];
				});
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"WhatsApp Not Available!"
											message:@"Cannot open WhatsApp on this device"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
			
		} else if (_selectedMessengerType == GSMessengerShareTypeWeChat) {
			if ([WXApi isWXAppSupportApi]) {
				_selectedMessengerContent = @{@"title"		: [shareInfo objectForKey:@"title"],
											  @"body_text"	: [shareInfo objectForKey:@"body_text"],
											  @"image"		: [shareInfo objectForKey:@"image"],
											  @"url"		: [shareInfo objectForKey:@"link"]};
				
				UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
				pasteboard.string = [NSString stringWithFormat:@"%@ %@", [shareInfo objectForKey:@"body_text"], [shareInfo objectForKey:@"link"]];
				
				NSString *caption = _expireLabel.text;
				_expireLabel.text = @"Launching WeChat to share…";
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
					_expireLabel.text = caption;
				});
				
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
				
				[WXApi registerApp:@"ID:wxad3790468c7ae7dd"
				   withDescription:[[NSBundle mainBundle] bundleIdentifier]];
				
				WXImageObject *imageObject = [WXImageObject object];
				imageObject.imageData = UIImageJPEGRepresentation([_selectedMessengerContent objectForKey:@"image"], 0.85);
				
				WXWebpageObject *webpageObject = [WXWebpageObject object];
				webpageObject.webpageUrl = [_selectedMessengerContent objectForKey:@"url"];
				
				WXMediaMessage *message = [WXMediaMessage message];
				message.title = [_selectedMessengerContent objectForKey:@"title"];
				message.description = [_selectedMessengerContent objectForKey:@"body_text"];
				[message setThumbImage:[_selectedMessengerContent objectForKey:@"image"]];
				message.mediaObject = webpageObject;
				
				SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
				req.text = [NSString stringWithFormat:@"%@ %@", [_selectedMessengerContent objectForKey:@"title"], [_selectedMessengerContent objectForKey:@"body_text"]];
				req.bText = NO;
				req.message = message;
				req.scene = WXSceneSession;
				[WXApi sendReq:req];
				
//				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You are being directed to WeChat."
//																	message:@"Use the selected messenger to share your Popup with friends."
//																   delegate:self
//														  cancelButtonTitle:@"OK"
//														  otherButtonTitles:nil];
//				[alertView setTag:GSMessengerShareTypeWeChat];
//				[alertView show];
				});
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"WeChat Not Available!"
											message:@"Cannot open WeChat on this device"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
			
		/*} else if (_selectedMessengerType == GSMessengerShareTypeViber) {
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"viber://"]]) {
				_selectedMessengerText = [NSString stringWithFormat:@"%@ %@", [shareInfo objectForKey:@"body_text"], [shareInfo objectForKey:@"link"]];
				
				UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
				pasteboard.string = _selectedMessengerText;
				
				NSString *caption = _expireLabel.text;
				_expireLabel.text = @"Launching Viber to share…";
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
					_expireLabel.text = caption;
				});
				
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"viber://" stringByAppendingString:_selectedMessengerText]]];
				
//				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You are being directed to Viber."
//																	message:@"Use the selected messenger to share your Popup with friends."
//																   delegate:self
//														  cancelButtonTitle:@"OK"
//														  otherButtonTitles:nil];
//				[alertView setTag:GSMessengerShareTypeViber];
//				[alertView show];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"Viber Not Available!"
											message:@"Cannot open Viber on this device"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
			
		} else if (_selectedMessengerType == GSMessengerShareTypeHike) {
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"combsbhike://"]]) {
				_selectedMessengerText = [NSString stringWithFormat:@"%@ %@", [shareInfo objectForKey:@"body_text"], [shareInfo objectForKey:@"link"]];
				
				UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
				pasteboard.string = _selectedMessengerText;
				
				NSString *caption = _expireLabel.text;
				_expireLabel.text = @"Launching Hike to share…";
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
					_expireLabel.text = caption;
				});
				
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"combsbhike://" stringByAppendingString:_selectedMessengerText]]];
				
//				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You are being directed to Hike."
//																	message:@"Use the selected messenger to share your Popup with friends."
//																   delegate:self
//														  cancelButtonTitle:@"OK"
//														  otherButtonTitles:nil];
//				[alertView setTag:GSMessengerShareTypeHike];
//				[alertView show];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"Hike Not Available!"
											message:@"Cannot open Hike on this device"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
			
		} else if (_selectedMessengerType == GSMessengerShareTypeOTHER) {
		*/	
		} else {
			shareInfo = @{};
		}
	
	} else if (actionSheet.tag == 1) {
		if (buttonIndex == 1) {
			_moviePlayer.view.alpha = !(BOOL)_moviePlayer.view.alpha;
			
		} else if (buttonIndex == 0) {
			_cameraPreviewView.alpha = !(BOOL)_cameraPreviewView.alpha;
		}
		
		[_videoVisibleButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"videoVisibleButton-%@_nonActive", (_moviePlayer.view.alpha == 1.0) ? @"off" : @"on"]] forState:UIControlStateNormal];
		[_videoVisibleButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"videoVisibleButton-%@_Active", (_moviePlayer.view.alpha == 1.0) ? @"off" : @"on"]] forState:UIControlStateHighlighted];
	}
}

#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"alertView:%d didDismissWithButtonIndex:%d", (int)alertView.tag, (int)buttonIndex);
	
	if (alertView.tag == GSMessengerShareTypeFBMessenger) {
		[FBSDKMessengerSharer shareImage:[_selectedMessengerContent objectForKey:@"share_image"]
							 withOptions:[_selectedMessengerContent objectForKey:@"options"]];
		
	} else if (alertView.tag == GSMessengerShareTypeKakaoTalk) {
		[KOAppCall openKakaoTalkAppLink:[_selectedMessengerContent objectForKey:@"link_objs"]];
		
	} else if (alertView.tag == GSMessengerShareTypeKik) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[_selectedMessengerContent objectForKey:@"link"]]];
		
	} else if (alertView.tag == GSMessengerShareTypeLine) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[_selectedMessengerContent objectForKey:@"link"]]];
		
	} else if (alertView.tag == GSMessengerShareTypeSMS) {
		MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
		messageComposeViewController.body = [NSString stringWithFormat:@"%@\n%@", [_selectedMessengerContent objectForKey:@"body_text"], [_selectedMessengerContent objectForKey:@"link"]];
		messageComposeViewController.messageComposeDelegate = self;
		[self presentViewController:messageComposeViewController animated:YES completion:^(void) {}];
		
	} else if (alertView.tag == GSMessengerShareTypeWhatsApp) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[_selectedMessengerContent objectForKey:@"link"]]];
		
	} else if (alertView.tag == GSMessengerShareTypeWeChat) {
		[WXApi registerApp:@"ID:wxad3790468c7ae7dd"
		   withDescription:[[NSBundle mainBundle] bundleIdentifier]];
		
		WXImageObject *imageObject = [WXImageObject object];
		imageObject.imageData = UIImageJPEGRepresentation([_selectedMessengerContent objectForKey:@"image"], 0.85);
		
		WXWebpageObject *webpageObject = [WXWebpageObject object];
		webpageObject.webpageUrl = [_selectedMessengerContent objectForKey:@"url"];
		
		WXMediaMessage *message = [WXMediaMessage message];
		message.title = [_selectedMessengerContent objectForKey:@"title"];
		message.description = [_selectedMessengerContent objectForKey:@"body_text"];
		[message setThumbImage:[_selectedMessengerContent objectForKey:@"image"]];
		message.mediaObject = webpageObject;
		
		SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
		req.text = [NSString stringWithFormat:@"%@ %@", [_selectedMessengerContent objectForKey:@"title"], [_selectedMessengerContent objectForKey:@"body_text"]];
		req.bText = NO;
		req.message = message;
		req.scene = WXSceneSession;
		[WXApi sendReq:req];
		
	} else if (alertView.tag == GSMessengerShareTypeHike) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"combsbhike://" stringByAppendingString:_selectedMessengerText]]];
		
	} else if (alertView.tag == GSMessengerShareTypeViber) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"Viber://" stringByAppendingString:_selectedMessengerText]]];
	
	} else if (alertView.tag == 99) {
		if (buttonIndex == 1) {
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"card://"]]) {
				[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - shareKik"] withProperties:@{@"channel"	: _channelName}];
				
				NSDictionary *shareInfo = [self _shareInfoForMessengerShareType:GSMessengerShareTypeKik];
				NSLog(@"shareInfo:\n%@", shareInfo);
				
				_selectedMessengerContent = @{@"link"	: [@"card://" stringByAppendingFormat:@"kik.popup.rocks/index.php?d=%@&a=popup", _channelName]};
				
				UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
				pasteboard.string = [NSString stringWithFormat:@"%@ %@", [shareInfo objectForKey:@"body_text"], [shareInfo objectForKey:@"outbound_url"]];
				
				NSString *caption = _expireLabel.text;
				_expireLabel.text = @"Launching Kik to share…";
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
					_expireLabel.text = caption;
				});
				
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[_selectedMessengerContent objectForKey:@"link"]]];
				
				//				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You are being directed to Kik."
				//																	message:@"Use the selected messenger to share your Popup with friends."
				//																   delegate:self
				//														  cancelButtonTitle:@"OK"
				//														  otherButtonTitles:nil];
				//				[alertView setTag:GSMessengerShareTypeKik];
				//				[alertView show];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"Kik Not Available!"
											message:@"Cannot open Kik on this device"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
		}
		
//		NSMutableDictionary *pushes = [[[NSUserDefaults standardUserDefaults] objectForKey:@"push_channels"] mutableCopy];
//		[pushes setObject:(buttonIndex == 1) ? @"YES" : @"NO" forKey:_channelName];
//		[[NSUserDefaults standardUserDefaults] replaceObject:[pushes copy] forKey:@"push_channels"];
//		[[NSUserDefaults standardUserDefaults] synchronize];
//
//		if (buttonIndex == 1) {
//			[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - enabledPush"] withProperties:@{@"channel"	: _channelName}];
//			[PubNub enablePushNotificationsOnChannel:_channel
//								 withDevicePushToken:[[HONDeviceIntrinsics sharedInstance] dataPushToken]
//						  andCompletionHandlingBlock:^(NSArray *channel, PNError *error){
//							  NSLog(@"BLOCK: enablePushNotificationsOnChannel: %@ , Error %@", channel, error);
//						  }];
//		}
	}
	
	
	
	if (alertView.tag != GSMessengerShareTypeSMS) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
			[self dismissViewControllerAnimated:NO completion:^(void) {}];
		});
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == HONStatusUpdateAlertViewTypeBack) {
		if (buttonIndex == 1) {
			[[NSUserDefaults standardUserDefaults] setObject:NSStringFromBOOL(YES) forKey:@"back_chat"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			[_statusUpdateHeaderView changeTitle:@"Cleaning up…"];
			[self _popBack];
		}
		
	} else if (alertView.tag == HONStatusUpdateAlertViewTypeFlag) {
		if (buttonIndex == 1) {
			[self _flagStatusUpdate];
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


#pragma mark - PBJVisionDelegate

-(UIImage *)_imageFromVideoWithURL:(NSURL *)url atTime:(CGFloat) time {
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
//    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
//    generator.appliesPreferredTrackTransform=TRUE;
//    CMTime thumbTime = CMTimeMakeWithSeconds(0, 1);
//    
//    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
//        if (result != AVAssetImageGeneratorSucceeded) {
//            NSLog(@"couldn't generate thumbnail, error:%@", error);
//        }
//        
//        UIImage *thumbImg = [UIImage imageWithCGImage:im];
//    };
//    
//    CGSize maxSize = CGSizeMake(320, 180);
//    generator.maximumSize = maxSize;
//    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
//    
    
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    NSError *error = nil;
    
    CMTime actualTime;
    CMTime frameTime = CMTimeMakeWithSeconds(time, 1.0);
    
    CGImageRef image = [gen copyCGImageAtTime:frameTime actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    
    return (thumb);
}

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
		
	} else {
		[self _uploadPhoto:[photoDict objectForKey:PBJVisionPhotoImageKey]];
	}
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error {
	NSLog(@"[*:*] vision:capturedVideo:[%@] [*:*]", videoDict);
	
	NSString *bucketName = @"popup-vids";
	
	NSString *path = [videoDict objectForKey:PBJVisionVideoPathKey];
	_lastVideo = [[path pathComponents] lastObject];
	
	NSMutableArray *cachedVideos = [[[NSUserDefaults standardUserDefaults] objectForKey:@"cached"] mutableCopy];
	[cachedVideos addObject:path];
	[[NSUserDefaults standardUserDefaults] setObject:[cachedVideos copy] forKey:@"cached"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	//_imageView.image = [[videoDict objectForKey:PBJVisionVideoThumbnailArrayKey] firstObject];
	
	UIView *matteView = [[UIView alloc] initWithFrame:_imageView.frame];
	[matteView addSubview:[[UIImageView alloc] initWithImage:(_isShare) ? [[videoDict objectForKey:PBJVisionVideoThumbnailArrayKey] lastObject] : [[videoDict objectForKey:PBJVisionVideoThumbnailArrayKey] firstObject]]];
	matteView.frame = CGRectResize(matteView.frame, CGSizeMake(matteView.frame.size.width * 0.5, matteView.frame.size.width * 0.5));
	
//	UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shareOverlay"]];
//	overlayImageView.frame = CGRectOffset(overlayImageView.frame, (matteView.frame.size.width - overlayImageView.frame.size.width) * 0.5, (matteView.frame.size.height - overlayImageView.frame.size.height) * 0.5);
//	[matteView addSubview:overlayImageView];
    
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    
    AVAsset *videoAsset = (AVAsset *)[AVAsset assetWithURL:url];
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    int tot = (float)CMTimeGetSeconds(videoAssetTrack.timeRange.duration) * 10.0;
    NSLog(@"TOT FRAMES:[%d]", tot);
    
//    NSNumber *dur = (CGFloat)[videoDict objectForKey:PBJVisionVideoPathKey];
    
    NSMutableArray *frames = [NSMutableArray array];
    [frames addObject:[[videoDict objectForKey:PBJVisionVideoThumbnailArrayKey] firstObject]];
    [frames addObject:[self _imageFromVideoWithURL:url atTime:(float)CMTimeGetSeconds(videoAssetTrack.timeRange.duration) * 0.5]];
    [frames addObject:[[videoDict objectForKey:PBJVisionVideoThumbnailArrayKey] lastObject]];
    
//    for (int i=0; i<tot; i++) {
//        UIImage *image = [self _imageFromVideoWithURL:url atTime:i * 0.1];
//        if (image == nil)
//            continue;
//        
//        [frames addObject:image];
//    }
    
    
    NSLog(@"FRAMES:[%d]", [frames count]);
    
    UIImageView * animImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    animImageView.animationImages = frames;
    animImageView.animationDuration = [frames count] * 0.125;
    animImageView.animationRepeatCount = 0;
    [animImageView startAnimating];
    [self.view addSubview:animImageView];

    
    
	
	
//	_thumbURL = [NSString stringWithFormat:@"%d.jpg", [NSDate elapsedUTCSecondsSinceUnixEpoch]];
//	NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:_thumbURL];
//	[UIImageJPEGRepresentation([matteView createImageFromView], 0.50) writeToFile:filePath atomically:YES];
//	
//	NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
//	//upload the image
//	AWSS3TransferManagerUploadRequest *imageUploadRequest = [AWSS3TransferManagerUploadRequest new];
//	imageUploadRequest.bucket = @"popup-thumbs";
//	imageUploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
//	imageUploadRequest.key = _thumbURL;
//	imageUploadRequest.body = fileUrl;
//	imageUploadRequest.contentType = @"image/jpeg";
	
	
//--	[[MPMusicPlayerController applicationMusicPlayer] setVolume:0.5];
	
	_isPlaying = NO;
	_videoQueue = 0;
	_moviePlayer.contentURL = url;
//--	[_moviePlayer play];
	
	
	//if (_participants <= 1)
	//	[self _goShare];
	
	
	AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
	uploadRequest.bucket = bucketName;
	uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
	uploadRequest.key = [[path pathComponents] lastObject];
	uploadRequest.contentType = @"video/mp4";
	uploadRequest.body = url;
	
	AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
//	[[transferManager upload:imageUploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
//		if (task.error) {
//			NSLog(@"AWSS3TransferManager: **ERROR** [%@]", task.error);
//			
//		} else {
//			NSLog(@"AWSS3TransferManager: !!SUCCESS!! [%@]", task.error);
//			
//			if (_isShare) {
//				[self _goShare];
//			}
//		}
//		
//		return (nil);
//	}];
	
	//if (!_isShare) {
		[[transferManager upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
			if (task.error) {
				NSLog(@"AWSS3TransferManager: **ERROR** [%@]", task.error);
			
			} else {
				NSLog(@"AWSS3TransferManager: !!SUCCESS!! [%@]", task.error);
				[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - sendVideo"] withProperties:@{@"channel"	: _channelName,
																																			  @"file"		: [[path pathComponents] lastObject]}];
				
				
				[_client publish:[[path pathComponents] lastObject] toChannel:_channelName mobilePushPayload:@{@"apns"	: @{@"aps"	: @{@"alert"	: @"Someone has posted a video.",
																																		@"sound"	: @"selfie_notification.aif",
																																		@"channel"	: _channelName}}} withCompletion:^(PNPublishStatus *status) {
																																			NSLog(@"\nSEND");// MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
																																		}];
			}
			
			return (nil);
		}];
//	}
}


// progress
- (void)vision:(PBJVision *)vision didCaptureVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
	NSLog(@"[*:*] vision:didCaptureVideoSampleBuffer:[%.04f] [*:*]", vision.capturedVideoSeconds);
}

- (void)vision:(PBJVision *)vision didCaptureAudioSample:(CMSampleBufferRef)sampleBuffer {
	NSLog(@"[*:*] vision:didCaptureAudioSample:[%.04f] [*:*]", vision.capturedAudioSeconds);
}


#pragma mark -


- (NSDictionary *)_shareInfoForMessengerShareType:(GSMessengerShareType)messengerShareType {
	NSMutableDictionary *shareInfo = [NSMutableDictionary dictionary];
	
//	if ([_outboundURL rangeOfString:@"&m="].location == NSNotFound)
//		_outboundURL = [_outboundURL stringByAppendingFormat:@"&m=%@", (messengerShareType == GSMessengerShareTypeFBMessenger) ? @"messenger" : (messengerShareType == GSMessengerShareTypeHike) ? @"hike" : (messengerShareType == GSMessengerShareTypeKakaoTalk) ? @"kakao" : (messengerShareType == GSMessengerShareTypeKik) ? @"kik" : (messengerShareType == GSMessengerShareTypeLine) ? @"line" : (messengerShareType == GSMessengerShareTypeSMS) ? @"sms" : (messengerShareType == GSMessengerShareTypeViber) ? @"viber" : (messengerShareType == GSMessengerShareTypeWeChat) ? @"wechat" : (messengerShareType == GSMessengerShareTypeWhatsApp) ? @"whatsapp" : @""];
//	
//	else {
//		NSRange range = [_outboundURL rangeOfString:@"&m="];
//		_outboundURL = [_outboundURL stringByReplacingCharactersInRange:NSMakeRange(range.location, [_outboundURL length] - range.location) withString:[NSString stringWithFormat:@"&m=%@", (messengerShareType == GSMessengerShareTypeFBMessenger) ? @"messenger" : (messengerShareType == GSMessengerShareTypeHike) ? @"hike" : (messengerShareType == GSMessengerShareTypeKakaoTalk) ? @"kakao" : (messengerShareType == GSMessengerShareTypeKik) ? @"kik" : (messengerShareType == GSMessengerShareTypeLine) ? @"line" : (messengerShareType == GSMessengerShareTypeSMS) ? @"sms" : (messengerShareType == GSMessengerShareTypeViber) ? @"viber" : (messengerShareType == GSMessengerShareTypeWeChat) ? @"wechat" : (messengerShareType == GSMessengerShareTypeWhatsApp) ? @"whatsapp" : @""]];
//	}
	
	NSLog(@"[:|:] [%@ - _shareInfoForMessengerType:%d] [:|:]", self.class, (int)messengerShareType);
	NSLog(@"_baseShareInfo:\n%@", _baseShareInfo);
	NSLog(@"_outboundURL:\n%@", _outboundURL);
	
	
	if (messengerShareType == GSMessengerShareTypeFBMessenger) {
		NSDictionary *fbShareInfo = [_baseShareInfo objectForKey:kFBMessengerKey];
		NSLog(@"fbShareInfo:\n%@", fbShareInfo);
		BOOL isOverride = (BOOL)[[fbShareInfo objectForKey:@"override"] intValue];
		
		[shareInfo setObject:([_outboundURL length] > 0) ? _outboundURL : ([[fbShareInfo objectForKey:@"outbound_url"] length] > 0) ? [fbShareInfo objectForKey:@"outbound_url"] : (!isOverride) ? [_baseShareInfo objectForKey:@"outbound_url"] : @"" forKey:@"link"];
		[shareInfo setObject:([[fbShareInfo objectForKey:@"body_text"] length] > 0) ? [fbShareInfo objectForKey:@"body_text"] : (!isOverride) ? [_baseShareInfo objectForKey:@"body_text"] : @"" forKey:@"body_text"];
		[shareInfo setObject:[UIImage imageNamed:([[fbShareInfo objectForKey:@"share_image"] length] > 0) ? [fbShareInfo objectForKey:@"share_image"] : (!isOverride) ? [_baseShareInfo objectForKey:@"main_image"] : @""] forKey:@"share_image"];
		[shareInfo setObject:([[fbShareInfo objectForKey:@"options"] count] > 0) ? [fbShareInfo objectForKey:@"options"] : (!isOverride) ? [_baseShareInfo objectForKey:@"options"] : @{} forKey:@"options"];
		
	} else if (messengerShareType == GSMessengerShareTypeKakaoTalk) {
		NSDictionary *kakaoShareInfo = [_baseShareInfo objectForKey:kKakaoTalkKey];
		NSLog(@"kakaoShareInfo:\n%@", kakaoShareInfo);
		BOOL isOverride = (BOOL)[[kakaoShareInfo objectForKey:@"override"] intValue];
		
		NSMutableArray *linkObjs = [NSMutableArray array];
		NSString *title = ([[kakaoShareInfo objectForKey:@"title"] length] > 0) ? [kakaoShareInfo objectForKey:@"title"] : (!isOverride) ? [_baseShareInfo objectForKey:@"title"] : @"";
		UIImage *image = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"kakao_image"]];//([[kakaoShareInfo objectForKey:@"image_url"] length] > 0) ? @"kakao_image" : (!isOverride) ? @"main_image_url" : nil]];
		//UIImage *image = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:([[kakaoShareInfo objectForKey:@"image_url"] length] > 0) ? @"kakao_image" : (!isOverride) ? @"main_image_url" : nil]];
		NSString *url = ([_outboundURL length] > 0) ? _outboundURL : ([[kakaoShareInfo objectForKey:@"outbound_url"] length] > 0) ? [kakaoShareInfo objectForKey:@"outbound_url"] : (!isOverride) ? [_baseShareInfo objectForKey:@"sub_image_url"] : @"";
		
		if ([title length] > 0) {
			[linkObjs addObject:[KakaoTalkLinkObject createLabel:title]];
		}
		
		if (image != nil) {
//			[[NSUserDefaults standardUserDefaults] replaceObject:UIImagePNGRepresentation(_imageView.image) forKey:@"kakao_image"];
//			[[NSUserDefaults standardUserDefaults] synchronize];
			
//			[linkObjs addObject:[KakaoTalkLinkObject createImage:[NSString stringWithFormat:@"https://s3.amazonaws.com/popup-thumbs/%@", _thumbURL]
//														   width:_imageView.image.size.width
//														  height:_imageView.image.size.height]];
			
			[linkObjs addObject:[KakaoTalkLinkObject createImage:([[kakaoShareInfo objectForKey:@"image_url"] length] > 0) ? [kakaoShareInfo objectForKey:@"image_url"] : (!isOverride) ? [_baseShareInfo objectForKey:@"main_image_url"] : @""
														   width:image.size.width
														  height:image.size.height]];
		}
		
		if ([url length] > 0) {
			[linkObjs addObject:[KakaoTalkLinkObject createWebButton:([[kakaoShareInfo objectForKey:@"button_text"] length] > 0) ? [kakaoShareInfo objectForKey:@"button_text"] : (!isOverride) ? [_baseShareInfo objectForKey:@"body_text"] : @""
																 url:url]];
		}
		
		[shareInfo setObject:[linkObjs copy] forKey:@"link_objs"];
		[shareInfo setObject:[kakaoShareInfo objectForKey:@"button_text"] forKey:@"body_text"];
		[shareInfo setObject:url forKey:@"link"];
		
		//		UIImage *image = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"main_image_url"]];
		//		shareInfo = @{@"link_objs"	: @[[KakaoTalkLinkObject createLabel:[_baseShareInfo objectForKey:@"title"]],
		//										[KakaoTalkLinkObject createImage:[_baseShareInfo objectForKey:@"main_image_url"]
		//																   width:image.size.width
		//																  height:image.size.height],
		//										[KakaoTalkLinkObject createWebButton:[_baseShareInfo objectForKey:@"subtitle"]
		//																		 url:[_baseShareInfo objectForKey:@"sub_image_url"]]]};
		
	} else if (messengerShareType == GSMessengerShareTypeKik) {
		NSDictionary *kikShareInfo = [_baseShareInfo objectForKey:kKikKey];
		NSLog(@"kikShareInfo:\n%@", kikShareInfo);
		BOOL isOverride = (BOOL)[[kikShareInfo objectForKey:@"override"] intValue];
		
		[shareInfo setObject:([[kikShareInfo objectForKey:@"title"] length] > 0) ? [kikShareInfo objectForKey:@"title"] : (!isOverride) ? [_baseShareInfo objectForKey:@"title"] : @"" forKey:@"title"];
		[shareInfo setObject:([[kikShareInfo objectForKey:@"subtitle"] length] > 0) ? [kikShareInfo objectForKey:@"subtitle"] : (!isOverride) ? [_baseShareInfo objectForKey:@"subtitle"] : @"" forKey:@"subtitle"];
		[shareInfo setObject:([[kikShareInfo objectForKey:@"icon_url"] length] > 0) ? [kikShareInfo objectForKey:@"icon_url"] : (!isOverride) ? [_baseShareInfo objectForKey:@"sub_image_url"] : @"" forKey:@"icon_url"];
		[shareInfo setObject:([[kikShareInfo objectForKey:@"image_url"] length] > 0) ? [kikShareInfo objectForKey:@"image_url"] : (!isOverride) ? [_baseShareInfo objectForKey:@"main_image_url"] : @"" forKey:@"image_url"];
		[shareInfo setObject:([[kikShareInfo objectForKey:@"body_text"] length] > 0) ? [kikShareInfo objectForKey:@"body_text"] : (!isOverride) ? [_baseShareInfo objectForKey:@"body_text"] : @"" forKey:@"body_text"];
		[shareInfo setObject:([_outboundURL length] > 0) ? _outboundURL : ([[kikShareInfo objectForKey:@"outbound_url"] length] > 0) ? [kikShareInfo objectForKey:@"outbound_url"] : (!isOverride) ? [_baseShareInfo objectForKey:@"outbound_url"] : @"" forKey:@"outbound_url"];
		
	} else if (messengerShareType == GSMessengerShareTypeLine) {
		NSDictionary *lineShareInfo = [_baseShareInfo objectForKey:kLineKey];
		NSLog(@"lineShareInfo:\n%@", lineShareInfo);
		BOOL isOverride = (BOOL)[[lineShareInfo objectForKey:@"override"] intValue];
		
		[shareInfo setObject:([[lineShareInfo objectForKey:@"body_text"] length] > 0) ? [lineShareInfo objectForKey:@"body_text"] : (!isOverride) ? [_baseShareInfo objectForKey:@"body_text"] : @"" forKey:@"body_text"];
		[shareInfo setObject:([_outboundURL length] > 0) ? _outboundURL : ([[lineShareInfo objectForKey:@"link"] length] > 0) ? [lineShareInfo objectForKey:@"link"] : (!isOverride) ? [_baseShareInfo objectForKey:@"outbound_url"] : @"" forKey:@"link"];
		
	} else if (messengerShareType == GSMessengerShareTypeSMS) {
		NSDictionary *smsShareInfo = [_baseShareInfo objectForKey:kSMSKey];
		NSLog(@"smsShareInfo:\n%@", smsShareInfo);
		BOOL isOverride = (BOOL)[[smsShareInfo objectForKey:@"override"] intValue];
		
		[shareInfo setObject:([[smsShareInfo objectForKey:@"body_text"] length] > 0) ? [smsShareInfo objectForKey:@"body_text"] : (!isOverride) ? [_baseShareInfo objectForKey:@"body_text"] : @"" forKey:@"body_text"];
		[shareInfo setObject:([_outboundURL length] > 0) ? _outboundURL : ([[smsShareInfo objectForKey:@"link"] length] > 0) ? [smsShareInfo objectForKey:@"link"] : (!isOverride) ? [_baseShareInfo objectForKey:@"outbound_url"] : @"" forKey:@"link"];
		
	} else if (messengerShareType == GSMessengerShareTypeWhatsApp) {
		NSDictionary *whatsAppShareInfo = [_baseShareInfo objectForKey:kWhatsAppKey];
		NSLog(@"whatsAppShareInfo:\n%@", whatsAppShareInfo);
		BOOL isOverride = (BOOL)[[whatsAppShareInfo objectForKey:@"override"] intValue];
		
		[shareInfo setObject:([[whatsAppShareInfo objectForKey:@"body_text"] length] > 0) ? [whatsAppShareInfo objectForKey:@"body_text"] : (!isOverride) ? [_baseShareInfo objectForKey:@"body_text"] : @"" forKey:@"body_text"];
		[shareInfo setObject:([_outboundURL length] > 0) ? _outboundURL : ([[whatsAppShareInfo objectForKey:@"link"] length] > 0) ? [whatsAppShareInfo objectForKey:@"link"] : (!isOverride) ? [_baseShareInfo objectForKey:@"outbound_url"] : @"" forKey:@"link"];
		
	} else if (messengerShareType == GSMessengerShareTypeWeChat) {
		NSDictionary *weChatShareInfo = [_baseShareInfo objectForKey:kWeChatKey];
		NSLog(@"weChatShareInfo:\n%@", weChatShareInfo);
		BOOL isOverride = (BOOL)[[weChatShareInfo objectForKey:@"override"] intValue];
		[shareInfo setObject:([[weChatShareInfo objectForKey:@"title"] length] > 0) ? [weChatShareInfo objectForKey:@"title"] : (!isOverride) ? [_baseShareInfo objectForKey:@"title"] : @"" forKey:@"title"];
		[shareInfo setObject:([[weChatShareInfo objectForKey:@"body_text"] length] > 0) ? [weChatShareInfo objectForKey:@"body_text"] : (!isOverride) ? [_baseShareInfo objectForKey:@"body_text"] : @"" forKey:@"body_text"];
		[shareInfo setObject:[UIImage imageNamed:([[weChatShareInfo objectForKey:@"image"] length] > 0) ? [weChatShareInfo objectForKey:@"image"] : (!isOverride) ? [_baseShareInfo objectForKey:@"main_image"] : nil] forKey:@"image"];
		[shareInfo setObject:([_outboundURL length] > 0) ? _outboundURL : ([[weChatShareInfo objectForKey:@"link"] length] > 0) ? [weChatShareInfo objectForKey:@"link"] : (!isOverride) ? [_baseShareInfo objectForKey:@"outbound_url"] : @"" forKey:@"link"];
		
	} else if (messengerShareType == GSMessengerShareTypeHike) {
		NSDictionary *hikeShareInfo = [_baseShareInfo objectForKey:kHikeKey];
		NSLog(@"hikeShareInfo:\n%@", hikeShareInfo);
		BOOL isOverride = (BOOL)[[hikeShareInfo objectForKey:@"override"] intValue];
		
		[shareInfo setObject:([[hikeShareInfo objectForKey:@"body_text"] length] > 0) ? [hikeShareInfo objectForKey:@"body_text"] : (!isOverride) ? [_baseShareInfo objectForKey:@"body_text"] : @"" forKey:@"body_text"];
		[shareInfo setObject:([_outboundURL length] > 0) ? _outboundURL : ([[hikeShareInfo objectForKey:@"link"] length] > 0) ? [hikeShareInfo objectForKey:@"link"] : (!isOverride) ? [_baseShareInfo objectForKey:@"outbound_url"] : @"" forKey:@"link"];
		
	} else if (messengerShareType == GSMessengerShareTypeViber) {
		NSDictionary *viberShareInfo = [_baseShareInfo objectForKey:kOTHERKey];
		NSLog(@"viberShareInfo:\n%@", viberShareInfo);
		BOOL isOverride = (BOOL)[[viberShareInfo objectForKey:@"override"] intValue];
		
		[shareInfo setObject:([[viberShareInfo objectForKey:@"body_text"] length] > 0) ? [viberShareInfo objectForKey:@"body_text"] : (!isOverride) ? [_baseShareInfo objectForKey:@"body_text"] : @"" forKey:@"body_text"];
		[shareInfo setObject:([_outboundURL length] > 0) ? _outboundURL : ([[viberShareInfo objectForKey:@"link"] length] > 0) ? [viberShareInfo objectForKey:@"link"] : (!isOverride) ? [_baseShareInfo objectForKey:@"outbound_url"] : @"" forKey:@"link"];
		
	} else if (messengerShareType == GSMessengerShareTypeOTHER) {
		NSDictionary *otherShareInfo = [_baseShareInfo objectForKey:kOTHERKey];
		NSLog(@"otherShareInfo:\n%@", otherShareInfo);
		BOOL isOverride = (BOOL)[[otherShareInfo objectForKey:@"override"] intValue];
		
		[shareInfo setObject:([[otherShareInfo objectForKey:@"body_text"] length] > 0) ? [otherShareInfo objectForKey:@"body_text"] : (!isOverride) ? [_baseShareInfo objectForKey:@"body_text"] : @"" forKey:@"body_text"];
		[shareInfo setObject:([_outboundURL length] > 0) ? _outboundURL : ([[otherShareInfo objectForKey:@"link"] length] > 0) ? [otherShareInfo objectForKey:@"link"] : (!isOverride) ? [_baseShareInfo objectForKey:@"outbound_url"] : @"" forKey:@"link"];
		
	} else {
		[shareInfo setObject:[_baseShareInfo objectForKey:@"body_text"] forKey:@"body_text"];
		[shareInfo setObject:([_outboundURL length] > 0) ? _outboundURL : [_baseShareInfo objectForKey:@"outbound_url"] forKey:@"link"];
	}
	
	NSLog(@"shareInfo:\n%@", shareInfo);
	return (shareInfo);
}

@end
