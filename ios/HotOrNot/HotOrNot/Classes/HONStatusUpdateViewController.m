//
//	HONStatusUpdateViewController.m
//	HotOrNot
//
//	Created by BIM	on 11/20/14.
//	Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

#import <AWSiOSSDKv2/S3.h>
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>

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
#import "HONChannelInviteButtonView.h"
#import "HONLoadingOverlayView.h"
#import "HONMediaRevealerView.h"
#import "HONButton.h"

#import "GSMessengerShare.h"

@interface HONStatusUpdateViewController () <FBSDKMessengerURLHandlerDelegate, GSMessengerShareDelegate, HONChannelInviteButtonViewDelegate, HONCommentItemViewDelegate, HONMediaRevealerViewDelegate, HONLoadingOverlayViewDelegate, HONStatusUpdateHeaderViewDelegate, PBJVisionDelegate>
- (PNChannel *)_channelSetupForStatusUpdate;

@property (nonatomic, strong) PNChannel *channel;
@property (nonatomic, strong) HONStatusUpdateVO *statusUpdateVO;
@property (nonatomic, strong) HONUserClubVO *clubVO;
@property (nonatomic, strong) HONScrollView *scrollView;
@property (nonatomic, strong) HONLoadingOverlayView *loadingOverlayView;
@property (nonatomic, strong) HONStatusUpdateHeaderView *statusUpdateHeaderView;

@property (nonatomic, strong) UIView *cameraPreviewView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *cameraPreviewLayer;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

@property (nonatomic, strong) UIButton *commentOpenButton;
@property (nonatomic, strong) UIButton *commentCloseButton;
@property (nonatomic, strong) UIButton *submitCommentButton;
@property (nonatomic, strong) UIImageView *footerImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSMutableArray *replies;
@property (nonatomic, strong) UIView *commentsHolderView;
@property (nonatomic, strong) UIView *commentFooterView;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSTimer *expireTimer;
@property (nonatomic, strong) NSTimer *durationTimer;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *expireLabel;
@property (nonatomic, strong) UILabel *countdownLabel;
@property (nonatomic) int countdown;
@property (nonatomic, strong) UIButton *flagButton;
@property (nonatomic, strong) UIButton *cameraFlipButton;
@property (nonatomic, strong) UIView *tintBGView;
@property (nonatomic, strong) UIImageView *nameImageView;
@property (nonatomic, strong) NSTimer *tintTimer;
@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, strong) UIView *movieFillView;
@property (nonatomic, strong) UIButton *takePhotoButton;
@property (nonatomic, strong) UIButton *messengerButton;
@property (nonatomic, strong) UIButton *openCommentButton;
@property (nonatomic, strong) UIImageView *animationImageView;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UIButton *nameButton;
@property (nonatomic, strong) UIView *shareHolderView;
@property (nonatomic, strong) UIView *tutorialView;
@property (nonatomic, strong) NSString *vidName;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) UILongPressGestureRecognizer *lpGestureRecognizer;
@property (nonatomic, strong) NSTimer *gestureTimer;
@property (nonatomic) int messageTotal;
@property (nonatomic) BOOL isIntro;

@property (nonatomic, strong) HONMediaRevealerView *revealerView;
@property (nonatomic, strong) GSMessengerShare *messengerShare;

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

- (id)initWithChannelName:(NSString *)channelName {
	NSLog(@"%@ - initWithChannelName:[%@]", [self description], channelName);
	if ((self = [self init])) {
		_channelName = channelName;
	}
	
	return (self);
}

- (id)initWithStatusUpdate:(HONStatusUpdateVO *)statusUpdateVO forClub:(HONUserClubVO *)clubVO {
	NSLog(@"%@ - initWithStatusUpdate:[%@] forClub:[%d - %@]", [self description], statusUpdateVO.dictionary, clubVO.clubID, clubVO.clubName);
	if ((self = [self init])) {
		_channelName = @"";
		_statusUpdateVO = statusUpdateVO;
		_clubVO = clubVO;
		
//		AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://kikgames.trydood.com/"]];
//		[httpClient getPath:@"sendpushfix.php" parameters:@{@"user"	: [[HONUserAssistant sharedInstance] activeUsername],
//														 @"channel"	: [NSString stringWithFormat:@"%d_%d", _statusUpdateVO.userID, _statusUpdateVO.statusUpdateID],
//														 @"message"	: @"joined"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
//															 NSError *error = nil;
//															 NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//															 
//															 if (error != nil) {
//																 SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
//																 [[HONAPICaller sharedInstance] showDataErrorHUD];
//																 
//															 } else {
//																 SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
//															 }
//															 
//															 [[[UIAlertView alloc] initWithTitle:@"PUSH"
//																						 message:[[[operation request] URL] absoluteString]
//																						delegate:nil
//																				 cancelButtonTitle:@"OK"
//																				 otherButtonTitles:nil] show];
//
//														 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//															 SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] pythonAPIBasePath], @"newsfeed/member/", [error localizedDescription]);
//															 [[HONAPICaller sharedInstance] showDataErrorHUD];
//														 }];
		
//		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//		pasteboard.string = [NSString stringWithFormat:@"http://popup.vlly.im/%d/", _statusUpdateVO.statusUpdateID];
	}
	
	return (self);
}

- (void)dealloc {
	[self destroy];
}


//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//	[super touchesBegan:touches withEvent:event];
//	UITouch *touch = [touches anyObject];
//	
//	NSLog(@"touchesBegan: %@", touch.view);
//	
//	if (_statusUpdateHeaderView.alpha == 1.0) {
//		_statusUpdateHeaderView.alpha = 0.0;
//		_statusLabel.alpha = 0.0;
//		_takePhotoButton.alpha = 0.0;
//		_expireLabel.alpha = 0.0;
//		_hudView.alpha = 0.0;
//		_footerImageView.alpha = 0.0;
//	
//	} else {
//		_statusUpdateHeaderView.alpha = 1.0;
//		_takePhotoButton.alpha = 1.0;
//		_expireLabel.alpha = 1.0;
//		_statusLabel.alpha = 1.0;
//		_hudView.alpha = 1.0;
//		_footerImageView.alpha = 1.0;
//	}
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//	[super touchesEnded:touches withEvent:event];
//	
//	NSLog(@"touchesEnded");
//}


#pragma mark - Public APIs
- (void)destroy {
	[_commentsHolderView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONCommentItemView *view = (HONCommentItemView *)obj;
		[view removeFromSuperview];
	}];
	
	[super destroy];
}


#pragma mark - Data Calls
- (void)_retrieveLastVideo {
	NSDictionary *params = @{@"action"	: @(2),
							 @"channel"	: _channel.name};
	
	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", @"http://gs.trydood.com", @"popup.php", params);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://gs.trydood.com"]];
	[httpClient postPath:@"popup.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
			[[HONAPICaller sharedInstance] showDataErrorHUD];
			
		} else {
			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			if ([[result objectForKey:@"url"] length] > 0) {
				_moviePlayer.view.alpha = 1.0;
				_moviePlayer.contentURL = [NSURL URLWithString:[@"https://d1fqnfrnudpaz6.cloudfront.net/" stringByAppendingString:[result objectForKey:@"url"]]];
				[_moviePlayer play];
				
				_nameImageView.hidden = YES;
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], @"http://gs.trydood.com", @"popup.php", [error localizedDescription]);
		[[HONAPICaller sharedInstance] showDataErrorHUD];
	}];
}

- (void)_retrieveStatusUpdate {
	if (_expireTimer != nil) {
		[_expireTimer invalidate];
		_expireTimer = nil;
	}
	
//	[[HONAPICaller sharedInstance] retrieveChallengeForChallengeID:_statusUpdateVO.statusUpdateID completion:^(NSDictionary *result) {
//	[[HONAPICaller sharedInstance] retrieveStatusUpdateByStatusUpdateID:_statusUpdateVO.statusUpdateID completion:^(NSDictionary *result) {
		
//		_statusUpdateVO = [HONStatusUpdateVO statusUpdateWithDictionary:result];
	
		if (_channel == nil || [[_channel.name lastComponentByDelimeter:@"_"] intValue] != _statusUpdateVO.statusUpdateID) {
			_channel = [self _channelSetupForStatusUpdate];
		
		} else {
//			[PubNub sendMessage:[NSString stringWithFormat:@"%d|%.04f_%.04f|__BYE__:", [[HONUserAssistant sharedInstance] activeUserID], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude] toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
//				if (messageState == PNMessageSent) {
//					NSLog(@"\nSEND MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
//					[PubNub unsubscribeFrom:@[_channel] withCompletionHandlingBlock:^(NSArray *array, PNError *error) {
//					}];
//
//					[[PNObservationCenter defaultCenter] removeClientChannelSubscriptionStateObserver:self];
//					[[PNObservationCenter defaultCenter] removeMessageReceiveObserver:self];
//				}
//			}];
		}
		
//		_statusUpdateVO.replies = [_replies copy];
		[self _didFinishDataRefresh];
//	}];
}

- (void)_submitTextComment {
	NSDictionary *dict = @{@"user_id"			: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
						   @"club_id"			: @(_clubVO.clubID),
						   @"img_url"			: [@"coords://" stringByAppendingFormat:@"%.04f_%.04f", [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude],
						   @"subject"			: [NSString stringWithFormat:@"%d;%@|%.04f_%.04f|__TXT__:%@", [[HONUserAssistant sharedInstance] activeUserID], [[HONUserAssistant sharedInstance] activeUsername], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude, _comment],
						   @"challenge_id"		: @(_statusUpdateVO.statusUpdateID)};
	NSLog(@"|:|◊≈◊~~◊~~◊≈◊~~◊~~◊≈◊| SUBMIT PARAMS:[%@]", dict);
	
	[PubNub sendMessage:[NSString stringWithFormat:@"{\"pn_apns\": {\"aps\": {\"alert\": \"Someone on Popup has messaged you\",\"badge\": %d,\"sound\": \"selfie_notification.aif\", \"channel\": \"%@\"}}}", _messageTotal, _channel.name]
			  toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
				  NSLog(@"\nSEND MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
			  }];

	[PubNub sendMessage:_comment toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
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
//							 @"img_url"		: [@"coords://" stringByAppendingFormat:@"%.04f_%.04f", [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude],
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
	
	NSString *channelName = ([_channelName length] == 0) ? [NSString stringWithFormat:@"%@_%d", [PubNub sharedInstance].clientIdentifier, [NSDate elapsedUTCSecondsSinceUnixEpoch]] : _channelName;
	PNChannel *channel = [PNChannel channelWithName:channelName shouldObservePresence:YES];//[[HONPubNubOverseer sharedInstance] channelForStatusUpdate:_statusUpdateVO];
	[PubNub subscribeOn:@[channel]];
	
	
	[_messengerShare overrrideWithOutboundURL:[NSString stringWithFormat:@"http://popup.rocks/route.php?d=%@&a=popup", channelName]];
	
	
//	NSDictionary *params = @{@"longUrl"	: [NSString stringWithFormat:@"http://popup.rocks/route.php?d=%@&a=popup", channelName]};
//	
//	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", @"https://www.googleapis.com/urlshortener/v1", @"url?key=AIzaSyBX_DeA87Df3IXHuARGaRjevIKoaT03FoU", params);
//	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.googleapis.com/urlshortener/v1"]];
//	[httpClient setDefaultHeader:@"Content-Type" value:@"application/json"];
//	[httpClient setDefaultHeader:@"Referrer" value:@"com.builtinmenlo.marsh"];
//	[httpClient setParameterEncoding:AFJSONParameterEncoding];
//	[httpClient postPath:@"url?key=AIzaSyBX_DeA87Df3IXHuARGaRjevIKoaT03FoU" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		NSError *error = nil;
//		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//		
//		if (error != nil) {
//			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
//			[[HONAPICaller sharedInstance] showDataErrorHUD];
//			
//		} else {
//			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
//			NSLog(@"short:[%@]", [result objectForKey:@"id"]);
//			[_messengerShare overrrideWithOutboundURL:[result objectForKey:@"id"]];
//		}
//		
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], @"https://www.googleapis.com/urlshortener/v1", @"url?key=AIzaSyBX_DeA87Df3IXHuARGaRjevIKoaT03FoU", [error localizedDescription]);
//		[[HONAPICaller sharedInstance] showDataErrorHUD];
//	}];
	
	[[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
		PNChannel *channel = [channels firstObject];
		
		NSLog(@"\n::: SUBSCRIPTION OBSERVER - [%@](%@)\n", (state == PNSubscriptionProcessSubscribedState) ? @"Subscribed" : (state == PNSubscriptionProcessRestoredState) ? @"Restored" : (state == PNSubscriptionProcessNotSubscribedState) ? @"NotSubscribed" : (state == PNSubscriptionProcessWillRestoreState) ? @"WillRestore" : @"UNKNOWN", channel.name);
		
		if (state == PNSubscriptionProcessSubscribedState || state == PNSubscriptionProcessRestoredState) {
			_channel = channel;
			_participants = 0;
			_comments = 0;
			
			[[PubNub sharedInstance] requestHistoryForChannel:channel
										from:nil
										  to:nil
									   limit:100 reverseHistory:NO
						 withCompletionBlock:^(NSArray *messages, PNChannel *channel, PNDate *startDate,
											   PNDate *endDate, PNError *error) {
							 
							 if (error == nil) {
								 // PubNub client successfully retrieved history for channel.
								 NSLog(@"requestHistoryForChannel - messages:\n%@", messages);
								 
								 [messages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
									 PNMessage *message = (PNMessage *)obj;
									 
									 NSString *txtContent = ([message.message isKindOfClass:[NSDictionary class]]) ? ([message.message objectForKey:@"text"] != nil) ? [message.message objectForKey:@"text"] : @"" : message.message;
									 NSLog(@"txtContent:[%@]", txtContent);
									 
									 if ([txtContent length] > 0) {
										 if ([txtContent rangeOfString:@".mp4"].location != NSNotFound) {
											 
											 _nameImageView.hidden = YES;
											 _moviePlayer.view.hidden = NO;
											 _moviePlayer.view.alpha = 1.0;
											 _moviePlayer.contentURL = [NSURL URLWithString:[@"https://d1fqnfrnudpaz6.cloudfront.net/" stringByAppendingString:txtContent]];
											 [_moviePlayer play];
											 
//											 _moviePlayer.view.frame = CGRectZero;
//											 
//											 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
//												 _moviePlayer.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height * 0.62);
//											 });
											 
											 *stop = YES;
										 }
									 }
								 }];
								 
							 } else {
								 NSLog(@"requestHistoryForChannel - error:\n%@", error);
								 
								 // PubNub did fail to retrieve history for specified channel and reason can be found in
								 // error instance.
								 //
								 // Always check 'error.code' to find out what caused error (check PNErrorCodes header file
								 // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion
								 // to get human readable description for error). 'error.associatedObject' contains PNChannel
								 // instance for which PubNub client was unable to receive history.
							 }
						 }];
			
//			[PubNub sendMessage:[NSString stringWithFormat:@"%d|%.04f_%.04f|__SYN__:", [[HONUserAssistant sharedInstance] activeUserID], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude] toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
//				//NSLog(@"\nSEND MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
//			}];
			
			//[self _retrieveLastVideo];

			
		} else if (state == PNSubscriptionProcessNotSubscribedState) {
		} else if (state == PNSubscriptionProcessWillRestoreState) {
		}
	}];
	
	// APNS enabled already?
	[PubNub enablePushNotificationsOnChannel:channel
						 withDevicePushToken:[[HONDeviceIntrinsics sharedInstance] dataPushToken]
					andCompletionHandlingBlock:^(NSArray *channel, PNError *error){
						NSLog(@"BLOCK: enablePushNotificationsOnChannel: %@ , Error %@", channel, error);
					}];

	[[PNObservationCenter defaultCenter] addPresenceEventObserver:self withBlock:^(PNPresenceEvent *event) {
		NSLog(@"::: PRESENCE OBSERVER - [%@] :::", event);
		NSLog(@"PARTICIPANTS:[%d]", (int)event.channel.participantsCount);
		
		PNChannel *channel = event.channel;
		_participants = channel.participantsCount;
		
		if (event.type == PNPresenceEventChanged) {
			NSLog(@"PRESENCE OBSERVER: Changed Event on Channel: %@, w/ Participant: %@", event.channel.name, event.client.identifier);
			
		} else if (event.type == PNPresenceEventJoin) {
			NSLog(@"PRESENCE OBSERVER: Join Event on Channel: %@, w/ Participant: %@", event.channel.name, event.client.identifier);
			
		} else if (event.type == PNPresenceEventLeave) {
			NSLog(@"PRESENCE OBSERVER: Leave Event on Channel: %@, w/ Participant: %@", event.channel.name, event.client.identifier);
			
		} else if (event.type == PNPresenceEventStateChanged) {
			NSLog(@"PRESENCE OBSERVER: State Changed Event on Channel: %@, w/ Participant: %@", event.channel.name, event.client.identifier);
			
		} else if (event.type == PNPresenceEventTimeout) {
			NSLog(@"PRESENCE OBSERVER: Timeout Event on Channel: %@, w/ Participant: %@", event.channel.name, event.client.identifier);
		}
		
		_expireLabel.text = [NSString stringWithFormat:@"%d %@ here", _participants, (_participants == 1) ? @"person" : @"people"];
	}];
	
	
	// Observer looks for message received events
	[[PNObservationCenter defaultCenter] addMessageReceiveObserver:self withBlock:^(PNMessage *message) {
		NSLog(@"\n::: MESSAGE REC OBSERVER:[%@](%@)", message.channel.name, message.message);
		
		_messageTotal++;
		
		NSString *txtContent = ([message.message isKindOfClass:[NSDictionary class]]) ? ([message.message objectForKey:@"text"] != nil) ? [message.message objectForKey:@"text"] : @"" : message.message;
		
		if ([txtContent length] > 0) {
			if ([txtContent rangeOfString:@".mp4"].location != NSNotFound) {
				NSDictionary *dict = @{@"id"				: @"0",
									   @"msg_id"			: @"0",
									   @"content_type"		: @((int)HONChatMessageTypeVID),
									   
									   @"owner_member"		: @{@"id"	: @(2392),
																@"name"	: @""},
									   @"image"				: [@"coords://" stringByAppendingFormat:@"%.04f_%.04f", [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude],
									   @"text"				: @"Posted a video!",
									   
									   @"net_vote_score"	: @(0),
									   @"status"			: NSStringFromInt(0),
									   @"added"				: [NSDate stringFormattedISO8601],
									   @"updated"			: [NSDate stringFormattedISO8601]};
				
				HONCommentVO *commentVO = [HONCommentVO commentWithDictionary:dict];
				NSLog(@"ChatMessageType:[%@]", (commentVO.messageType == HONChatMessageTypeUndetermined) ? @"Undetermined" : (commentVO.messageType == HONChatMessageTypeACK) ? @"ACK" : (commentVO.messageType == HONChatMessageTypeBYE) ? @"BYE": (commentVO.messageType == HONChatMessageTypeTXT) ? @"Text" : (commentVO.messageType == HONChatMessageTypeIMG) ? @"Image" : (commentVO.messageType == HONChatMessageTypeVID) ? @"Video" : @"UNKNOWN");
				
				[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - playVideo"] withProperties:@{@"file"	: [commentVO.imagePrefix lastComponentByDelimeter:@"/"],
																											 @"channel"	: _channel.name}];
				
//				[UIView animateKeyframesWithDuration:0.25 delay:0.00
//											 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut)
//												animations:^(void) {
//													//_moviePlayer.view.alpha = 0.0;
//												} completion:^(BOOL finished) {
													_moviePlayer.contentURL = [NSURL URLWithString:[@"https://d1fqnfrnudpaz6.cloudfront.net/" stringByAppendingString:txtContent]];
													[_moviePlayer play];
//												}];
				
				_animationImageView.hidden = NO;
				_statusLabel.text = @"Loading video…";
				//[self _appendComment:commentVO];
			
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

//- (void)_updateExpireTime {
//	if (_participants < 2) {
//		if (--_expireSeconds >= 0) {
//		} else
//			[self _popBack];
//		
//	} else {
//		if (_expireTimer != nil) {
//			[_expireTimer invalidate];
//			_expireTimer = nil;
//		}
//	}
//	
//	if (_expireSeconds % 86400 == 0) {
//		int secs = [[[NSUserDefaults standardUserDefaults] objectForKey:@"occupancy_timeout"] intValue];
//		int mins = [NSDate elapsedMinutesFromSeconds:secs];
//		int hours = [NSDate elapsedHoursFromSeconds:secs];
//		
//		UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//		localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:0];
//		localNotification.timeZone = [NSTimeZone systemTimeZone];
//		localNotification.alertAction = @"View";
//		localNotification.alertBody = [NSString stringWithFormat:@"Chat link expires in less than %@!", (hours > 0) ? [NSString stringWithFormat:@"%d hour%@", hours, (hours == 1) ? @"" : @"s"] : (mins > 0) ? [NSString stringWithFormat:@"%d minute%@", mins, (mins == 1) ? @"" : @"s"] : [NSString stringWithFormat:@"%d second%@", secs, (secs == 1) ? @"" : @"s"]];	//[[[[NSUserDefaults standardUserDefaults] objectForKey:@"alert_formats"] objectForKey:@"participant_push"] objectForKey:@"msg"];
//		localNotification.soundName = @"selfie_notification.caf";
//		localNotification.userInfo = @{};
//		
//		[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//	}
//}

- (void)_copyDeeplink {
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = [NSString stringWithFormat:@"http://popup.vlly.im/%d/", _statusUpdateVO.statusUpdateID];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
//	[[HONAnalyticsReporter sharedInstance] trackEvent:@"DETAILS - enter"];
	
	[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"in_chat"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	_messageTotal = 0;
	
	
	self.view.backgroundColor = [UIColor blackColor];// [UIColor colorWithRed:0.337 green:0.239 blue:0.510 alpha:1.00];
	
	_isIntro = YES;
	_isActive = YES;
	_isSubmitting = NO;
	
	_comment = @"";
	_expireSeconds = 600;
	_participants = 0;
	
	_tintBGView = [[UIView alloc] initWithFrame:self.view.frame];
	_tintBGView.backgroundColor = [UIColor colorWithRed:0.400 green:0.839 blue:0.698 alpha:1.00];
	[self.view addSubview:_tintBGView];
	
//	_tintTimer = [NSTimer scheduledTimerWithTimeInterval:1.25
//													target:self
//												selector:@selector(_updateTint)
//												userInfo:nil repeats:YES];
	
	_movieFillView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.5, 0.0, self.view.frame.size.width * 0.5, self.view.frame.size.width * 0.5)];
	_movieFillView.backgroundColor = [UIColor blackColor];
	_movieFillView.hidden = YES;
	[self.view addSubview:_movieFillView];
	
	_cameraPreviewView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height * 0.62, self.view.frame.size.width, self.view.frame.size.height * 0.62)];
	_cameraPreviewView.backgroundColor = [UIColor blackColor];
	_cameraPreviewView.alpha = 0.0;
	
	_cameraPreviewLayer = [[PBJVision sharedInstance] previewLayer];
	_cameraPreviewLayer.frame = _cameraPreviewView.bounds;
	_cameraPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[_cameraPreviewView.layer addSublayer:_cameraPreviewLayer];
	[self.view addSubview:_cameraPreviewView];
	[[PBJVision sharedInstance] setPresentationFrame:_cameraPreviewView.frame];
	[[PBJVision sharedInstance] setVideoFrameRate:12];
	
	
	
//	AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
//	playerViewController.player = [AVPlayer playerWithURL:];
//	self.avPlayerViewcontroller = playerViewController;
//	[self resizePlayerToViewSize];
//	[view addSubview:playerViewController.view];
//	view.autoresizesSubviews = TRUE;
	
	
	_moviePlayer = [[MPMoviePlayerController alloc] init];//WithContentURL:[NSURL URLWithString:@"https://d1fqnfrnudpaz6.cloudfront.net/video_97D31566-55C7-4142-9ED7-FAA62BF54DB1.mp4"]];
	_moviePlayer.controlStyle = MPMovieControlStyleNone;
//	_moviePlayer.view.backgroundColor = [UIColor redColor];
	_moviePlayer.shouldAutoplay = YES;
	_moviePlayer.repeatMode = MPMovieRepeatModeOne;
	_moviePlayer.scalingMode = MPMovieScalingModeFill;
	_moviePlayer.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height * 0.62);
	//_moviePlayer.view.alpha = 0.0;
	[self.view addSubview:_moviePlayer.view];
	
	
	_imageView = [[UIImageView alloc] initWithFrame:_moviePlayer.view.frame];
	_imageView.hidden = YES;
	[self.view addSubview:_imageView];
	
	_statusUpdateHeaderView = [[HONStatusUpdateHeaderView alloc] initWithStatusUpdateVO:_statusUpdateVO];
	_statusUpdateHeaderView.delegate = self;
	
	_commentFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 55.0, self.view.frame.size.width, 55.0)];
	_commentFooterView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.40];
	_commentFooterView.hidden = YES;
	
	_footerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commentInput2BG"]];
	[_commentFooterView addSubview:_footerImageView];
	
	_expireLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0, 31.0, self.view.frame.size.width - 160.0, 22.0)];
	_expireLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:18];
	_expireLabel.backgroundColor = [UIColor clearColor];
	_expireLabel.textAlignment = NSTextAlignmentCenter;
	_expireLabel.textColor = [UIColor whiteColor];
	_expireLabel.text = @"1 person here";
	[self.view addSubview:_expireLabel];
	
//	_scrollView = [[HONScrollView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height * 0.5, self.view.frame.size.width, (self.view.frame.size.height * 0.5) - _commentFooterView.frame.size.height)];
	_scrollView = [[HONScrollView alloc] initWithFrame:CGRectMake(0.0, _statusUpdateHeaderView.frameEdges.bottom, self.view.frame.size.width, self.view.frame.size.height - (_statusUpdateHeaderView.frameEdges.bottom + 60.0 + [UIApplication sharedApplication].statusBarFrame.size.height))];
//	_scrollView.backgroundColor = [[HONColorAuthority sharedInstance] honDebugColor:HONDebugGreenColor];
	_scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, 0.0);
	_scrollView.contentInset = UIEdgeInsetsMake(MAX(0.0, (_scrollView.frame.size.height - _commentsHolderView.frame.size.height)), _scrollView.contentInset.left, 10.0, _scrollView.contentInset.right);
	_scrollView.alwaysBounceVertical = YES;
	_scrollView.delegate = self;
	[self.view addSubview:_scrollView];
	
	_animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 206.0) * 0.5, 20.0 + (((self.view.frame.size.height * 0.5) - 206.0) * 0.5), 206.0, 206.0)];
//	_animationImageView.animationImages = @[[UIImage imageNamed:@"contentLoader_01"],
//											[UIImage imageNamed:@"contentLoader_02"],
//											[UIImage imageNamed:@"contentLoader_03"],
//											[UIImage imageNamed:@"contentLoader_04"],
//											[UIImage imageNamed:@"contentLoader_05"],
//											[UIImage imageNamed:@"contentLoader_06"],
//											[UIImage imageNamed:@"contentLoader_07"],
//											[UIImage imageNamed:@"contentLoader_08"]];
//	_animationImageView.animationDuration = 0.75;
//	_animationImageView.animationRepeatCount = 0;
	_animationImageView.hidden = YES;
//	[_animationImageView startAnimating];
	[self.view addSubview:_animationImageView];
	
	
	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityIndicatorView.center = CGPointMake(_animationImageView.bounds.size.width * 0.5, (_animationImageView.bounds.size.height + 50.0) * 0.5);
	[activityIndicatorView startAnimating];
	[_animationImageView addSubview:activityIndicatorView];
	
//	UIView *maskView = [[UIView alloc] initWithFrame:self.view.frame];
//	maskView.layer.frame = CGRectMake(0.0, self.view.frame.size.height * 0.5, self.view.frame.size.width, self.view.frame.size.height * 0.5);
//	maskView.backgroundColor = [UIColor blackColor];
//	
//	_maskLayer = maskView.layer;
//	_scrollView.layer.mask = _maskLayer;
//	_scrollView.layer.masksToBounds = YES;

	
	[self.view addSubview:_statusUpdateHeaderView];
	[self.view addSubview:_commentFooterView];
	
	
	_nameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nameTutorial"]];
	_nameImageView.frame = CGRectOffset(_nameImageView.frame, 0.0, self.view.frame.size.height * 0.55);
	[self.view addSubview:_nameImageView];
	
	_cameraFlipButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_cameraFlipButton.frame = CGRectMake(self.view.frame.size.width - 65.0, (self.view.frame.size.height * 0.62) + 5.0, 60.0, 60.0);
	[_cameraFlipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_nonActive"] forState:UIControlStateNormal];
	[_cameraFlipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_Active"] forState:UIControlStateHighlighted];
	[_cameraFlipButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_cameraFlipButton];
	
	
	_flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_flagButton.frame = CGRectMake((self.view.frame.size.width - 50.0) * 0.5, (self.view.frame.size.height * 0.5) - 50.0, 50.0, 50.0);
	[_flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_nonActive"] forState:UIControlStateNormal];
	[_flagButton setBackgroundImage:[UIImage imageNamed:@"flagButton_Active"] forState:UIControlStateHighlighted];
	[_flagButton addTarget:self action:@selector(_goFlag) forControlEvents:UIControlEventTouchUpInside];
	_flagButton.alpha = 0.0;
	//[self.view addSubview:_flagButton];
	
//	UIImageView *participantsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"participantsIcon"]];
//	participantsImageView.frame = CGRectOffset(participantsImageView.frame, 7.0, (self.view.frame.size.height * 0.5) + 9.0);
//	[_hudView addSubview:participantsImageView];
	
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
	_nameTextField.font = [[[HONFontAllocator sharedInstance] cartoGothicBook] fontWithSize:29];
	_nameTextField.keyboardType = UIKeyboardTypeDefault;
	_nameTextField.placeholder = @"What is your name?";
	_nameTextField.text = @"";
	_nameTextField.hidden = YES;
	_nameTextField.delegate = self;
	[self.view addSubview:_nameTextField];
	
//	_statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 165.0, self.view.frame.size.width - 40.0, 30.0)];
//	_statusLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:26];
//	_statusLabel.backgroundColor = [UIColor clearColor];
//	_statusLabel.textAlignment = NSTextAlignmentCenter;
//	_statusLabel.textColor = [UIColor whiteColor];
//	_statusLabel.text = @"Enter your name";
//	[_bgView addSubview:_statusLabel];
	
	_openCommentButton = [HONButton buttonWithType:UIButtonTypeCustom];
	_openCommentButton.frame = CGRectMake(27.0, self.view.frame.size.height - 80.0, 72.0, 72.0);
	[_openCommentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_nonActive"] forState:UIControlStateNormal];
	[_openCommentButton setBackgroundImage:[UIImage imageNamed:@"commentButton_Active"] forState:UIControlStateHighlighted];
	[_openCommentButton addTarget:self action:@selector(_goOpenComment) forControlEvents:UIControlEventTouchUpInside];
	_openCommentButton.hidden = YES;
	[self.view addSubview:_openCommentButton];
	
	_tutorialView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200.0) * 0.5, self.view.frame.size.height - 130.0, 200.0, 50.0)];
	_tutorialView.hidden = YES;
	//[self.view addSubview:_tutorialView];
	
	_takePhotoButton = [HONButton buttonWithType:UIButtonTypeCustom];
	_takePhotoButton.frame = CGRectMake((self.view.frame.size.width - _openCommentButton.frame.size.width) * 0.5, self.view.frame.size.height - 82.0, 72.0, 72.0);
	[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_nonActive"] forState:UIControlStateNormal];
	[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_Active"] forState:UIControlStateHighlighted];
	[_takePhotoButton addTarget:self action:@selector(_goImageComment) forControlEvents:UIControlEventTouchUpInside];
	_takePhotoButton.hidden = YES;
	[self.view addSubview:_takePhotoButton];
	
	NSLog(@"FRAME:%@", NSStringFromCGRect(_cameraPreviewView.frame));
	_takePhotoButton.frame = CGRectMake(_takePhotoButton.frame.origin.x, ([[HONDeviceIntrinsics sharedInstance] isPhoneType6]) ? 595.0 : ([[HONDeviceIntrinsics sharedInstance] isPhoneType6Plus]) ? 736.0 : 489.0, _takePhotoButton.frame.size.width, _takePhotoButton.frame.size.height);
	
	_messengerButton = [HONButton buttonWithType:UIButtonTypeCustom];
	_messengerButton.frame = CGRectMake(self.view.frame.size.width - 88.0, self.view.frame.size.height - 80.0, 72.0, 72.0);
	[_messengerButton setBackgroundImage:[UIImage imageNamed:@"shareButton_nonActive"] forState:UIControlStateNormal];
	[_messengerButton setBackgroundImage:[UIImage imageNamed:@"shareButton_Active"] forState:UIControlStateHighlighted];
	[_messengerButton addTarget:self action:@selector(_goShare) forControlEvents:UIControlEventTouchUpInside];
	_messengerButton.alpha = 0.0;
	[self.view addSubview:_messengerButton];
	
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
	_commentTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
	_commentTextField.keyboardType = UIKeyboardTypeDefault;
	_commentTextField.placeholder = @"";
	_commentTextField.text = @"";
	_commentTextField.delegate = self;
	[_commentFooterView addSubview:_commentTextField];
	
	_submitCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitCommentButton.frame = CGRectMake(_commentFooterView.frame.size.width - 46.0, 6.0, 46.0, 46.0);
	[_submitCommentButton setBackgroundImage:[UIImage imageNamed:@"submitCommentButton_nonActive"] forState:UIControlStateNormal];
	[_submitCommentButton setBackgroundImage:[UIImage imageNamed:@"submitCommentButton_Active"] forState:UIControlStateHighlighted];
	[_submitCommentButton setBackgroundImage:[UIImage imageNamed:@"submitCommentButton_Disabled"] forState:UIControlStateDisabled];
	[_submitCommentButton addTarget:self action:@selector(_goTextComment) forControlEvents:UIControlEventTouchUpInside];
	_submitCommentButton.hidden = YES;
	[_commentFooterView addSubview:_submitCommentButton];
	
	_commentCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_commentCloseButton.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - (216.0 + _commentFooterView.frame.size.height));
	_commentCloseButton.backgroundColor = [[HONColorAuthority sharedInstance] honDebugDefaultColor];
	[_commentCloseButton addTarget:self action:@selector(_goCancelComment) forControlEvents:UIControlEventTouchUpInside];
	
	_countdownLabel = [[UILabel alloc] initWithFrame:_expireLabel.frame];
	_countdownLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
	_countdownLabel.backgroundColor = [UIColor clearColor];
	_countdownLabel.textAlignment = NSTextAlignmentCenter;
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
//	[_messengerShare addAllMessengerShareTypes];
	[_messengerShare addMessengerShareTypes:@[@(GSMessengerShareTypeFBMessenger), @(GSMessengerShareTypeKik), @(GSMessengerShareTypeWhatsApp), @(GSMessengerShareTypeLine), @(GSMessengerShareTypeKakaoTalk), @(GSMessengerShareTypeWeChat), @(GSMessengerShareTypeSMS), @(GSMessengerShareTypeHike), @(GSMessengerShareTypeViber)]];
	_messengerShare.delegate = self;
	[_messengerShare showMessengerSharePickerOnViewController:self];
	
//	_shareHolderView = [[UIView alloc] initWithFrame:self.view.frame];
//	[self.view addSubview:_shareHolderView];
//	
//	[_shareHolderView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shareBG"]]];
//	
//	HONButton *kikButton = [HONButton buttonWithType:UIButtonTypeCustom];
//	[kikButton setBackgroundImage:[UIImage imageNamed:@"kikButton_nonActive"] forState:UIControlStateNormal];
//	[kikButton setBackgroundImage:[UIImage imageNamed:@"kikButton_Active"] forState:UIControlStateHighlighted];
//	[kikButton addTarget:self action:@selector(_goKik) forControlEvents:UIControlEventTouchUpInside];
//	kikButton.frame = CGRectMake(55.0, 280.0 * (([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? kScreenMult.height : 1.0), kikButton.frame.size.width, kikButton.frame.size.height);
//	[_shareHolderView addSubview:kikButton];
//	
//	HONButton *fbButton = [HONButton buttonWithType:UIButtonTypeCustom];
//	[fbButton setBackgroundImage:[UIImage imageNamed:@"fbButton_nonActive"] forState:UIControlStateNormal];
//	[fbButton setBackgroundImage:[UIImage imageNamed:@"fbButton_Active"] forState:UIControlStateHighlighted];
//	[fbButton addTarget:self action:@selector(_goFB) forControlEvents:UIControlEventTouchUpInside];
//	fbButton.frame = CGRectMake((self.view.frame.size.width - fbButton.frame.size.width) * 0.5, 280.0 * (([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? kScreenMult.height : 1.0), fbButton.frame.size.width, fbButton.frame.size.height);
//	[_shareHolderView addSubview:fbButton];
//	
//	HONButton *kakaoButton = [HONButton buttonWithType:UIButtonTypeCustom];
//	[kakaoButton setBackgroundImage:[UIImage imageNamed:@"kakaoButton_nonActive"] forState:UIControlStateNormal];
//	[kakaoButton setBackgroundImage:[UIImage imageNamed:@"kakaoButton_Active"] forState:UIControlStateHighlighted];
//	[kakaoButton addTarget:self action:@selector(_goKakao) forControlEvents:UIControlEventTouchUpInside];
//	kakaoButton.frame = CGRectMake((self.view.frame.size.width - 55.0) - kikButton.frame.size.width, 280.0 * (([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? kScreenMult.height : 1.0), kikButton.frame.size.width, kikButton.frame.size.height);
//	[_shareHolderView addSubview:kakaoButton];
//	
//	HONButton *skipButton = [HONButton buttonWithType:UIButtonTypeCustom];
//	[skipButton setBackgroundImage:[UIImage imageNamed:@"skipNameButton_nonActive"] forState:UIControlStateNormal];
//	[skipButton setBackgroundImage:[UIImage imageNamed:@"skipNameButton_Active"] forState:UIControlStateHighlighted];
//	[skipButton addTarget:self action:@selector(_goSkipName) forControlEvents:UIControlEventTouchUpInside];
//	skipButton.frame = CGRectMake(0.0, self.view.frame.size.height - skipButton.frame.size.height, skipButton.frame.size.width, skipButton.frame.size.height);
//	[_shareHolderView addSubview:skipButton];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
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
		[alertView setTag:HONStatusUpdateAlertViewTypeBack];
		[alertView show];
		
	} else {
		[_statusUpdateHeaderView changeTitle:@"Cleaning up…"];
		[self _popBack];
	}
}

- (void)_goKik {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"card://tap2install.com/ios-app.php"]];
	
	//dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.33 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
		_takePhotoButton.frame = CGRectMake(_takePhotoButton.frame.origin.x, ([[HONDeviceIntrinsics sharedInstance] isPhoneType6]) ? 595.0 : ([[HONDeviceIntrinsics sharedInstance] isPhoneType6Plus]) ? 736.0 : 489.0, _takePhotoButton.frame.size.width, _takePhotoButton.frame.size.height);
		_cameraPreviewView.frame =CGRectMake(_cameraPreviewView.frame.origin.x, ([[HONDeviceIntrinsics sharedInstance] isPhoneType6]) ? 333.0 : ([[HONDeviceIntrinsics sharedInstance] isPhoneType6Plus]) ? 368.0 : 284.0, _cameraPreviewView.frame.size.width, _cameraPreviewView.frame.size.height);
		//_takePhotoButton.frame = CGRectOffset(_takePhotoButton.frame, _takePhotoButton.frame.origin.x, ([[HONDeviceIntrinsics sharedInstance] isPhoneType6]) ? 595.0 : ([[HONDeviceIntrinsics sharedInstance] isPhoneType6Plus]) ? 736.0 : 496.0);
		
		NSLog(@"TAKEPHOTO:[%@]", NSStringFromCGRect(_takePhotoButton.frame));
		
		_shareHolderView.hidden = YES;
		
		[_statusUpdateHeaderView changeTitle:@""];
		_cameraPreviewView.hidden = NO;
		
		if ([_nameTextField isFirstResponder])
			[_nameTextField resignFirstResponder];
		
		_nameButton.hidden = YES;
		_nameTextField.hidden = YES;
		
		_commentTextField.hidden = NO;
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_cameraPreviewView.alpha = 1.0;
			_nameImageView.alpha = 0.0;
		} completion:^(BOOL finished) {
			[_nameImageView removeFromSuperview];
		}];
	
		_cameraPreviewView.hidden = NO;
		
		[self _goCancelComment];
	//});
}

- (void)_goKakao {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"kakaolink"]];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.33 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
		[self _goSkipName];
	});
}

- (void)_goFB {
	FBSDKMessengerShareOptions *options = [[FBSDKMessengerShareOptions alloc] init];
	options.metadata = [NSString stringWithFormat:@"{\"channel\":\"%@\"}", _channel.name];
	options.contextOverride = [[FBSDKMessengerBroadcastContext alloc] init];
	
	[FBSDKMessengerSharer shareAnimatedGIF:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"popup_sharefb" ofType:@"gif"]]
								 withOptions:options];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.33 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
		[self _goSkipName];
	});
}

- (void)_goSkipName {
	_nameTextField.text = @"anon";
	_shareHolderView.hidden = YES;
	
	[self _goSetName];
	
//	if (![_nameTextField isFirstResponder])
//		[_nameTextField becomeFirstResponder];
//	
//	_nameButton = [HONButton buttonWithType:UIButtonTypeCustom];
//	_nameButton.frame = CGRectMake(0.0, self.view.frame.size.height - (65.0), self.view.frame.size.width, 65.0);
//	[_nameButton setBackgroundImage:[UIImage imageNamed:@"nameButton_nonActive"] forState:UIControlStateNormal];
//	[_nameButton setBackgroundImage:[UIImage imageNamed:@"nameButton_Active"] forState:UIControlStateHighlighted];
//	[_nameButton addTarget:self action:@selector(_goSetName) forControlEvents:UIControlEventTouchUpInside];
//	[self.view addSubview:_nameButton];
//	
//	[UIView animateWithDuration:0.25 animations:^(void) {
//		_nameButton.frame = CGRectMake(0.0, self.view.frame.size.height - (216.0 + _nameButton.frame.size.height), self.view.frame.size.width, _nameButton.frame.size.height);
//	} completion:^(BOOL finished) {
//		[_nameImageView removeFromSuperview];
//	}];
}

- (void)_goShare {
//	[[HONAnalyticsReporter sharedInstance] trackEvent:@"0527Cohort - shareiOS" withProperties:@{@"chat"	: @(_statusUpdateVO.statusUpdateID)}];
	
	_isIntro = NO;
//	[_messengerShare overrrideWithOutboundURL:[NSString stringWithFormat:@"http://popup.rocks/route.php?d=%@&a=popup", _channel.name]];
	[_messengerShare showMessengerSharePickerOnViewController:self];
	
//	NSDictionary *params = @{@"longUrl"	: [NSString stringWithFormat:@"http://popup.rocks/route.php?d=%@&a=popup", _channel.name]};
//	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", @"https://www.googleapis.com/urlshortener/v1", @"url?key=AIzaSyBX_DeA87Df3IXHuARGaRjevIKoaT03FoU", params);
//	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.googleapis.com/urlshortener/v1"]];
//	[httpClient setDefaultHeader:@"Content-Type" value:@"application/json"];
//	[httpClient setDefaultHeader:@"Referrer" value:@"com.builtinmenlo.marsh"];
//	[httpClient setParameterEncoding:AFJSONParameterEncoding];
//	[httpClient postPath:@"url?key=AIzaSyBX_DeA87Df3IXHuARGaRjevIKoaT03FoU" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		NSError *error = nil;
//		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//		
//		if (error != nil) {
//			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
//			[[HONAPICaller sharedInstance] showDataErrorHUD];
//			
//		} else {
//			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
//			NSLog(@"short:[%@]", [result objectForKey:@"id"]);
//			[_messengerShare overrrideWithOutboundURL:[result objectForKey:@"id"]];
//			[_messengerShare showMessengerSharePickerOnViewController:self];
//		}
//		
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], @"https://www.googleapis.com/urlshortener/v1", @"url?key=AIzaSyBX_DeA87Df3IXHuARGaRjevIKoaT03FoU", [error localizedDescription]);
//		[[HONAPICaller sharedInstance] showDataErrorHUD];
//	}];
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
	
//	[[KikClient sharedInstance] openProfileForKikUsername:@"kikteam"];
	
//	KikMessage *message = [KikMessage photoMessageWithImageURL:@"http://popup.rocks/images/my_icon.png"
//													previewURL:@"http://popup.rocks/images/my_icon.png"];
//	[[KikClient sharedInstance] sendKikMessage:message];
	
//	UIImage *image = [UIImage imageNamed:@"noNetworkBG"];
//	KikMessage *message = [KikMessage photoMessageWithImage:image];
//	[[KikClient sharedInstance] sendKikMessage:message];
}

- (void)_goImageComment {
	[[[UIAlertView alloc] initWithTitle:nil
								message:@"Tan and hold to record"
								 delegate:nil
						cancelButtonTitle:NSLocalizedString(@"alert_ok", @"Cancel")
						otherButtonTitles:nil] show];
	
//	[[HONAnalyticsReporter sharedInstance] trackEvent:@"0527Cohort - image"];
	
//	_loadingOverlayView = [[HONLoadingOverlayView alloc] init];
//	_loadingOverlayView.delegate = self;
//	[[PBJVision sharedInstance] capturePhoto];
	
//	[[PBJVision sharedInstance] startVideoCapture];
//	_statusUpdateHeaderView.hidden = YES;
//	_scrollView.hidden = YES;
//	_expireLabel.hidden = YES;
	
//	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
//		[[PBJVision sharedInstance] endVideoCapture];
//		_statusUpdateHeaderView.hidden = NO;
//		_scrollView.hidden = NO;
//		_expireLabel.hidden = NO;
//	});
	
}

- (void)_goSetName {
	
	_comment = _nameTextField.text;
	[_statusUpdateHeaderView changeTitle:@""];
	
//	NSMutableDictionary *userInfo = [[[HONUserAssistant sharedInstance] activeUserInfo] mutableCopy];
//	[userInfo replaceObject:_comment forKey:@"username"];
//	[[HONUserAssistant sharedInstance] writeActiveUserInfo:[userInfo copy]];
//	
//	[[HONAPICaller sharedInstance] updateUsernameForUser:_comment completion:^(NSDictionary *result) {
//		if (![[result objectForKey:@"result"] isEqualToString:@"fail"])
//			[[HONUserAssistant sharedInstance] writeActiveUserInfo:result];
//	}];
	
	_cameraPreviewView.hidden = NO;
	
	if ([_nameTextField isFirstResponder])
		[_nameTextField resignFirstResponder];
	
	_nameButton.hidden = YES;
	_nameTextField.hidden = YES;
	_tutorialView.hidden = NO;
	_commentTextField.hidden = NO;
	
//	[UIView animateWithDuration:0.25 animations:^(void) {
//		_cameraPreviewView.alpha = 1.0;
//		_nameImageView.alpha = 0.0;
//	} completion:^(BOOL finished) {
//		[_nameImageView removeFromSuperview];
//	}];
	
	_cameraPreviewView.hidden = NO;
	
	[self _goCancelComment];
}

- (void)_goTextComment {
	[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - sendChat"]];
	
	_isSubmitting = YES;
	[_submitCommentButton setEnabled:NO];
	
	_comment = _commentTextField.text;
	_commentTextField.text = @"";
	[self _submitTextComment];
	
//	if ([_comment isSuffixedByString:@".mp4"]) {
//		[PubNub sendMessage:[NSString stringWithFormat:@"%d|%.04f_%.04f|__VID__:%@", [[HONUserAssistant sharedInstance] activeUserID], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude, _comment]
//					toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
//						NSLog(@"\nSEND MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
//					}];
//	} else {
//		[self _submitTextComment];
//	}
	
//	if (++_comments == 1) {
//		[[HONAPICaller sharedInstance] updateUsernameForUser:_comment completion:^(NSDictionary *result) {
//			if (![[result objectForKey:@"result"] isEqualToString:@"fail"])
//				[[HONUserAssistant sharedInstance] writeActiveUserInfo:result];
//		}];
//
//		NSMutableDictionary *userInfo = [[[HONUserAssistant sharedInstance] activeUserInfo] mutableCopy];
//		[userInfo replaceObject:_comment forKey:@"username"];
//		[[HONUserAssistant sharedInstance] writeActiveUserInfo:[userInfo copy]];
//
//		NSDictionary *dict = @{@"id"				: @"0",
//								 @"msg_id"			: @"0",
//								 @"content_type"		: @((int)HONChatMessageTypeBOT),
//								 
//								 @"owner_member"		: @{@"id"	: @(2392),
//														@"name"	: @"Botly"},
//								 @"image"				: [@"coords://" stringByAppendingFormat:@"%.04f_%.04f", [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude],
//								 @"text"				: [NSString stringWithFormat:@"You changed your name to “%@”", _comment],
//								 
//								 @"net_vote_score"	: @(0),
//								 @"status"			: NSStringFromInt(0),
//								 @"added"				: [NSDate stringFormattedISO8601],
//								 @"updated"			: [NSDate stringFormattedISO8601]};
//		
//		[self _appendComment:[HONCommentVO commentWithDictionary:dict]];
//
//	} else
//		[self _submitTextComment];
}

- (void)_goOpenComment {
	if (![_commentTextField isFirstResponder])
		[_commentTextField becomeFirstResponder];
}

- (void)_goCancelComment {
	_commentTextField.text = @"";
	_footerImageView.image = [UIImage imageNamed:@"commentInputBG"];
	_commentFooterView.hidden = NO;
	_takePhotoButton.hidden = NO;
	_openCommentButton.hidden = NO;
	_scrollView.hidden = YES;
	_cameraFlipButton.hidden = NO;
	_lpGestureRecognizer.enabled = YES;
	
	[_tintBGView removeFromSuperview];
	
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
	_commentFooterView.backgroundColor = [UIColor clearColor];
	_scrollView.hidden = YES;
	_scrollView.frame = CGRectResizeHeight(_scrollView.frame, self.view.frame.size.height - (_statusUpdateHeaderView.frameEdges.bottom + 60.0 + [UIApplication sharedApplication].statusBarFrame.size.height));
	
	_takePhotoButton.frame = CGRectMake(_takePhotoButton.frame.origin.x, ([[HONDeviceIntrinsics sharedInstance] isPhoneType6]) ? 588.0 : ([[HONDeviceIntrinsics sharedInstance] isPhoneType6Plus]) ? 729.0 : 489.0, _takePhotoButton.frame.size.width, _takePhotoButton.frame.size.height);
	_submitCommentButton.hidden = YES;
	_movieFillView.hidden = YES;
	
	_moviePlayer.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height * 0.62);
	_cameraPreviewView.frame = CGRectMake(0.0, self.view.frame.size.height * 0.62, self.view.frame.size.width, self.view.frame.size.height * 0.62);
	_cameraPreviewLayer.frame = _cameraPreviewView.bounds;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
//		if ([_moviePlayer isPreparedToPlay])
			_moviePlayer.view.alpha = 1.0;
		
		_cameraPreviewView.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
	
	if (_scrollView.contentSize.height - _scrollView.frame.size.height > 0)
		[_scrollView setContentOffset:CGPointMake(0.0, MAX(0.0, _scrollView.contentSize.height - _scrollView.frame.size.height)) animated:YES];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_flagButton.alpha = 1.0;
		_messengerButton.alpha = 1.0;
		_commentFooterView.frame = CGRectTranslateY(_commentFooterView.frame, self.view.frame.size.height - _commentFooterView.frame.size.height);
//		_expireLabel.frame = CGRectTranslateY(_expireLabel.frame, _scrollView.frameEdges.bottom);
		[_scrollView setContentInset:UIEdgeInsetsMake(MAX(0.0, (_scrollView.frame.size.height - _commentsHolderView.frame.size.height)), _scrollView.contentInset.left, _scrollView.contentInset.bottom, _scrollView.contentInset.right)];
	} completion:^(BOOL finished) {
		//[_commentCloseButton removeFromSuperview];
	}];
}

-(void)_goLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		NSLog(@"gestureRecognizer.state:[%@]", NSStringFromUIGestureRecognizerState(gestureRecognizer.state));
		
		CGPoint touchPoint = [gestureRecognizer locationInView:self.view];
		NSLog(@"TOUCH:%@", NSStringFromCGPoint(touchPoint));
		
		if (CGRectContainsPoint(_takePhotoButton.frame, touchPoint)) {
//			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
				[[PBJVision sharedInstance] startVideoCapture];
//			});
			
			_tutorialView.hidden = YES;
			_nameImageView.hidden = YES;
			_cameraFlipButton.hidden = YES;
			
			if ([_commentTextField isFirstResponder])
				[_commentTextField resignFirstResponder];
			
			_commentTextField.text = @"";
			//[self _goCancelComment];
			
			_countdown = 5;
			_countdownLabel.text = NSStringFromInt(_countdown);
			_expireLabel.hidden = YES;
			_countdownLabel.hidden = NO;
			_moviePlayer.view.hidden = YES;
			
			_countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.00
																 target:self
															 selector:@selector(_updateCountdown)
															 userInfo:nil repeats:YES];
			
			
//			_gestureTimer = [NSTimer scheduledTimerWithTimeInterval:1.00
//															 target:self
//														   selector:@selector(_updateGesture)
//														   userInfo:nil repeats:NO];
			
			//_animationImageView.frame = CGRectMake(20.0, 20.0, 50.0, 50.0);
			//_animationImageView.hidden = NO;
			
			_moviePlayer.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height * 0.62);
			_openCommentButton.hidden = YES;
			_submitCommentButton.hidden = YES;
			_movieFillView.hidden = YES;
			_commentFooterView.frame = CGRectTranslateY(_commentFooterView.frame, self.view.frame.size.height - _commentFooterView.frame.size.height);
			
			[_moviePlayer stop];
			_cameraPreviewView.frame = CGRectMake(0.0, self.view.frame.size.height * 0.19, self.view.frame.size.width, self.view.frame.size.height * 0.62);
			_cameraPreviewLayer.frame = CGRectFromSize(_cameraPreviewView.frame.size);
			_cameraPreviewLayer.opacity = 1.0;
			
			_statusUpdateHeaderView.hidden = YES;
			_commentFooterView.hidden = YES;
			_scrollView.hidden = YES;
			_flagButton.hidden = YES;
			_messengerButton.hidden = YES;
			
//			[UIView animateKeyframesWithDuration:3.00 delay:0.00
//										 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveLinear)
//										animations:^(void) {
//											_bgView.frame = CGRectResizeWidth(_bgView.frame, self.view.frame.size.width);
//										} completion:^(BOOL finished) {
//										}];
		}
		
	} else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		if (gestureRecognizer.enabled) {
			[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - sendVideo"] withProperties:@{@"channel"	: @(_statusUpdateVO.statusUpdateID)}];
			
			NSLog(@"gestureRecognizer.state:[%@]", NSStringFromUIGestureRecognizerState(gestureRecognizer.state));
			//_takePhotoButton.frame = CGRectMake(_takePhotoButton.frame.origin.x, ([[HONDeviceIntrinsics sharedInstance] isPhoneType6]) ? 588.0 : ([[HONDeviceIntrinsics sharedInstance] isPhoneType6Plus]) ? 728.0 : 489.0, _takePhotoButton.frame.size.width, _takePhotoButton.frame.size.height);
			_cameraPreviewView.frame = CGRectMake(0.0, self.view.frame.size.height * 0.62, self.view.frame.size.width, self.view.frame.size.height * 0.62);
			_commentFooterView.backgroundColor = [UIColor clearColor];
			
			_statusLabel.text = @"Sending popup…";
			_animationImageView.hidden = NO;
			_animationImageView.frame = CGRectMake((self.view.frame.size.width - 206.0) * 0.5, 20.0 + (((self.view.frame.size.height * 0.5) - 206.0) * 0.5), 206.0, 206.0);
			
			[[PBJVision sharedInstance] endVideoCapture];
			_statusUpdateHeaderView.hidden = NO;
			_commentFooterView.hidden = NO;
			_openCommentButton.hidden = NO;
			_flagButton.hidden = NO;
			_messengerButton.hidden = NO;
			_countdownLabel.text = @"";
			_countdownLabel.hidden = YES;
			_moviePlayer.view.hidden = NO;
			_cameraFlipButton.hidden = NO;
			_expireLabel.hidden = NO;
			gestureRecognizer.enabled = YES;
		
		} else
			gestureRecognizer.enabled = YES;
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
	_statusLabel.text = @"Send a pop…";
	[_moviePlayer stop];
}

- (void)_appLeavingBackground:(NSNotification *)notification {
	_isActive = YES;
}

- (void)_playbackStateChanged:(NSNotification *)notification {
	NSLog(@"_playbackStateChangedNotification:[%d][%d]", (int)_moviePlayer.loadState, (int)_moviePlayer.playbackState);
	
	if (_moviePlayer.loadState == 0) {
		_animationImageView.hidden = YES;
		
//		[UIView animateKeyframesWithDuration:0.25 delay:0.00
//									 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut)
//									animations:^(void) {
										_imageView.alpha = 0.0;
										_moviePlayer.view.alpha = 1.0;
//									} completion:^(BOOL finished) {
										_imageView.hidden = YES;
//									}];
	}
	
	if (_moviePlayer.loadState == 3 && _moviePlayer.playbackState == 1) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - playVideo"] withProperties:@{@"file"	: [[_moviePlayer.contentURL absoluteString] lastComponentByDelimeter:@"/"],
																									 @"channel"	: _channel.name}];

	}
}

- (void)_playbackEnded:(NSNotification *)notification {
	NSLog(@"_playbackEndedNotification:[%@]", [notification object]);
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
	//_footerImageView.hidden = ([textField.text length] > 0);
	
	if (textField.tag == 0 && [textField.text length] == 0)
		textField.text = @"What is your name?";
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
	vision.additionalCompressionProperties = @{AVVideoProfileLevelKey : AVVideoProfileLevelH264HighAutoLevel}; //-- AVVideoProfileLevelH264Baseline30}; // AVVideoProfileLevelKey requires specific captureSessionPreset
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
	
//	for (UIView *view in _commentsHolderView.subviews) {
//		view.alpha = MIN(1.0, (1.0 - (((_commentsHolderView.frameEdges.bottom - view.frame.origin.y) - 22.0) / 55.0)) + 0.33);
//		view.alpha = MIN(1.0, (1.0 - (((_commentsHolderView.frameEdges.bottom - view.frame.origin.y) - 22.0) / 198.352)) + 0.33);
//	}
	
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
		_expireLabel.hidden = NO;
//		_openCommentButton.hidden = NO;
//		
//		[[HONAnalyticsReporter sharedInstance] trackEvent:@"0527Cohort - sendVideo" withProperties:@{@"channel"	: @(_statusUpdateVO.statusUpdateID)}];
//		
//		_takePhotoButton.frame = CGRectMake(_takePhotoButton.frame.origin.x, ([[HONDeviceIntrinsics sharedInstance] isPhoneType6]) ? 595.0 : ([[HONDeviceIntrinsics sharedInstance] isPhoneType6Plus]) ? 736.0 : 496.0, _takePhotoButton.frame.size.width, _takePhotoButton.frame.size.height);
//		_cameraPreviewView.frame = CGRectMake(0.0, self.view.frame.size.height * 0.5, self.view.frame.size.width, self.view.frame.size.height * 0.5);
//		_commentFooterView.backgroundColor = [UIColor clearColor];
//		
//		if (_lpGestureRecognizer.enabled) {
//			_statusLabel.text = @"Sending popup…";
//			_animationImageView.hidden = NO;
//			_animationImageView.frame = CGRectMake((self.view.frame.size.width - 206.0) * 0.5, 20.0 + (((self.view.frame.size.height * 0.5) - 206.0) * 0.5), 206.0, 206.0);
//			
//			[[PBJVision sharedInstance] endVideoCapture];
//		}
//		
//		_lpGestureRecognizer.enabled = NO;
//		_statusUpdateHeaderView.hidden = NO;
//		_commentFooterView.hidden = NO;
//		_scrollView.hidden = NO;
//		_flagButton.hidden = NO;
//		_messengerButton.hidden = NO;
	}
	
	_countdownLabel.text = NSStringFromInt(_countdown);
}


- (void)_updateTint {
	NSArray *colors = @[//[UIColor colorWithRed:0.396 green:0.596 blue:0.922 alpha:1.00],
						[UIColor colorWithRed:0.839 green:0.729 blue:0.400 alpha:1.00],
						[UIColor colorWithRed:0.400 green:0.839 blue:0.698 alpha:1.00],
						[UIColor colorWithRed:0.337 green:0.239 blue:0.510 alpha:1.00]];
	
	UIColor *color = [colors randomElement];
	[UIView animateWithDuration:0.25 animations:^(void) {
		[[HONViewDispensor sharedInstance] tintView:_tintBGView withColor:color];
	} completion:nil];
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
//	[PubNub sendMessage:[NSString stringWithFormat:@"%d|%.04f_%.04f|__BYE__:", [[HONUserAssistant sharedInstance] activeUserID], [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.latitude, [[HONDeviceIntrinsics sharedInstance] deviceLocation].coordinate.longitude] toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
		//if (messageState == PNMessageSent) {
		//	NSLog(@"\nSEND MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
//			[PubNub unsubscribeFrom:@[_channel] withCompletionHandlingBlock:^(NSArray *array, PNError *error) {
//			}];
	
			[[PNObservationCenter defaultCenter] removeClientChannelSubscriptionStateObserver:self];
			[[PNObservationCenter defaultCenter] removeMessageReceiveObserver:self];
		//}
//	}];
	
	[[NSUserDefaults standardUserDefaults] setObject:NSStringFromBOOL(NO) forKey:@"chat_share"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
//	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.125 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
		[[PBJVision sharedInstance] stopPreview];
		[self.navigationController popToRootViewControllerAnimated:YES];
//	});
	
	[_moviePlayer stop];
//	_moviePlayer.view.hidden = YES;
	
	[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"in_chat"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - GSMessengerShare Delegates
- (void)didCloseMessengerShare {
	NSLog(@"[*:*] didCloseMessengerShare [*:*]");
	
	if (_isIntro)
		[self _popBack];
}

- (void)didSelectMessengerShareWithType:(GSMessengerShareType)messengerType {
	NSLog(@"[*:*] didSelectMessengerShareWithType:[%d] [*:*]", (int)messengerType);
	[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - sharePopup"] withProperties:@{@"channel"	: _channel.name, @"messenger"	: (messengerType == GSMessengerShareTypeFBMessenger) ? @"Messenger" : (messengerType == GSMessengerShareTypeHike) ? @"Hike" : (messengerType == GSMessengerShareTypeKakaoTalk) ? @"Kakao" : (messengerType == GSMessengerShareTypeKik) ? @"Kik" : (messengerType == GSMessengerShareTypeLine) ? @"Line" : (messengerType == GSMessengerShareTypeSMS) ? @"SMS" : (messengerType == GSMessengerShareTypeViber) ? @"Viber" : (messengerType == GSMessengerShareTypeWeChat) ? @"WeChat" : (messengerType == GSMessengerShareTypeWhatsApp) ? @"WhatsApp" : @"OTHER"}];
	
	[[GSMessengerShare sharedInstance] dismissMessengerSharePicker];
}

- (void)didSkipMessengerShare {
	NSLog(@"[*:*] didSkipMessengerShare [*:*]");
	
	if ([[_moviePlayer.contentURL absoluteString] length] > 0) {
		_nameImageView.hidden = YES;
		[_moviePlayer stop];
		[_moviePlayer play];
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
	
	_footerImageView.image = [UIImage imageNamed:@"commentInput3BG"];
	_commentFooterView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.20];
	
	_nameImageView.hidden = YES;
	_tutorialView.hidden = YES;
	_scrollView.hidden = NO;
	_cameraFlipButton.hidden = YES;
	_scrollView.frame = CGRectResizeHeight(_scrollView.frame, self.view.frame.size.height - (_statusUpdateHeaderView.frameEdges.bottom + _commentFooterView.frame.size.height + 216.0 + 10.0));
	_submitCommentButton.hidden = NO;
	
	if (textField.tag == 1) {
		_cameraPreviewView.hidden = YES;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
			_cameraPreviewView.hidden = NO;
		});
		
		_cameraPreviewView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.width * 0.62);
		_cameraPreviewLayer.frame = _cameraPreviewView.bounds;
		_moviePlayer.view.frame = CGRectMake(self.view.frame.size.width * 0.5, 0.0, self.view.frame.size.width * 0.5, self.view.frame.size.width * 0.62);
		
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"text"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		_commentTextField.placeholder = @"Type a message…";
		_movieFillView.hidden = NO;
		_scrollView.hidden = NO;
		//_takePhotoButton.frame = CGRectTranslateY(_takePhotoButton.frame, (_movieFillView.frame.size.height - 72.0));
	
	} else {
	}
	
	if (_scrollView.contentSize.height - _scrollView.frame.size.height > 0)
		[_scrollView setContentOffset:CGPointMake(0.0, MAX(0.0, _scrollView.contentSize.height - _scrollView.frame.size.height)) animated:YES];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		[_scrollView setContentInset:UIEdgeInsetsMake(MAX(0.0, (_scrollView.frame.size.height - _commentsHolderView.frame.size.height)), _scrollView.contentInset.left, _scrollView.contentInset.bottom, _scrollView.contentInset.right)];
//		_expireLabel.frame = CGRectTranslateY(_expireLabel.frame, _scrollView.frameEdges.bottom);
		_commentFooterView.frame = CGRectTranslateY(_commentFooterView.frame, self.view.frame.size.height - (_commentFooterView.frame.size.height + 216.0));
		_messengerButton.alpha = 0.0;
		_flagButton.alpha = 0.0;
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


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == HONStatusUpdateAlertViewTypeEmpty) {
		if (buttonIndex == 1) {
			if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"kik://"]]) {
				[[[UIAlertView alloc] initWithTitle:@"Not Avialable"
											message:@"This device isn't allowed or doesn't recognize Kik!"
											 delegate:nil
									cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
									otherButtonTitles:nil] show];
				
			} else {
				KikMessage *message = [KikMessage articleMessageWithTitle:@"[LIVE NOW]"
																	 text:@"Walkie talkie style video chat."
																 contentURL:[NSString stringWithFormat:@"http://popup.rocks/deep.php?id=%d", _statusUpdateVO.statusUpdateID]
																 previewURL:@"http://popup.rocks/images/my_icon.png"];
				[[KikClient sharedInstance] sendKikMessage:message];
				
				//_comment = @"Shared on Kik!";
				//[self _submitTextComment];
			}
		}
		
	} else if (alertView.tag == HONStatusUpdateAlertViewTypeBack) {
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
	
	} else if (alertView.tag == HONStatusUpdateAlertViewTypeShare) {
		if (buttonIndex == 1) {
//			[[HONAnalyticsReporter sharedInstance] trackEvent:@"0527Cohort - shareClipboard"];
			
			[[[UIAlertView alloc] initWithTitle:@"Paste anywhere to share!"
										message:@""
										 delegate:nil
								cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								otherButtonTitles:nil] show];
			
		} else if (buttonIndex == 2) {
//			[[HONAnalyticsReporter sharedInstance] trackEvent:@"0527Cohort - shareSMS"];
			
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
//			[[HONAnalyticsReporter sharedInstance] trackEvent:@"0527Cohort - shareKik"];
			
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
				KikMessage *message = [KikMessage articleMessageWithTitle:@"[LIVE POPUP]"
																	 text:@"Join my Popup."
																 contentURL:[NSString stringWithFormat:@"http://popup.rocks/deep.php?id=%d", _statusUpdateVO.statusUpdateID]
																 previewURL:@"http://popup.rocks/images/my_icon.png"];
				[[KikClient sharedInstance] sendKikMessage:message];
				
				//_comment = @"Shared on Kik!";
				//[self _submitTextComment];
			}
			
		} else if (buttonIndex == 4) {
//			[[HONAnalyticsReporter sharedInstance] trackEvent:@"0527Cohort - shareLine"];
			
//			AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://kikgames.trydood.com/"]];
//			[httpClient getPath:@"popupapp.php" parameters:@{@"url"	: [NSString stringWithFormat:@"popup.vlly.im/%d", _statusUpdateVO.statusUpdateID]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
//				NSError *error = nil;
//				NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//				
//				if (error != nil) {
//					SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
//					[[HONAPICaller sharedInstance] showDataErrorHUD];
//					
//				} else {
//					SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
//				}
//				
//			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//				SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] pythonAPIBasePath], @"newsfeed/member/", [error localizedDescription]);
//				[[HONAPICaller sharedInstance] showDataErrorHUD];
//			}];

			
		} else if (buttonIndex == 5) {
//			[[HONAnalyticsReporter sharedInstance] trackEvent:@"0527Cohort - shareKakao"];
			
			if ([FBSDKMessengerSharer messengerPlatformCapabilities] & FBSDKMessengerPlatformCapabilityImage) {
				
				FBSDKMessengerShareOptions *options = [[FBSDKMessengerShareOptions alloc] init];
				options.metadata = [NSString stringWithFormat:@"{\"channel\":\"%@\"}", _channel.name];
				options.contextOverride = [[FBSDKMessengerBroadcastContext alloc] init];
				
				[FBSDKMessengerSharer shareAnimatedGIF:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"popup_sharefb" ofType:@"gif"]]
											 withOptions:options];
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
		
	} else {
		[self _uploadPhoto:[photoDict objectForKey:PBJVisionPhotoImageKey]];
	}
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error {
	NSLog(@"[*:*] vision:capturedVideo:[%@] [*:*]", videoDict);
	_lpGestureRecognizer.enabled = NO;
	
	NSString *bucketName = @"hotornot-challenges";
	
	NSString *path = [videoDict objectForKey:PBJVisionVideoPathKey];
	_vidName = [[path pathComponents] lastObject];
	
	
	_imageView.image = [[videoDict objectForKey:PBJVisionVideoThumbnailArrayKey] lastObject];
	_imageView.hidden = NO;
	_imageView.alpha = 1.0;
	
//	NSDictionary *params = @{@"action"	: @(1),
//							 @"channel"	: _channel.name,
//							 @"userID"	: @([[HONUserAssistant sharedInstance] activeUserID]),
//							 @"vidURL"	: _vidName};
//	
//	SelfieclubJSONLog(@"_/:[%@]—//%@> (%@/%@) %@\n\n", [[self class] description], @"POST", @"http://gs.trydood.com", @"popup.php", params);
//	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://gs.trydood.com"]];
//	[httpClient postPath:@"popup.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		NSError *error = nil;
//		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//		
//		if (error != nil) {
//			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
//			[[HONAPICaller sharedInstance] showDataErrorHUD];
//			
//		} else {
//			SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
//			
//			
//		}
//		
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], @"http://gs.trydood.com", @"popup.php", [error localizedDescription]);
//		[[HONAPICaller sharedInstance] showDataErrorHUD];
//	}];
	
	
//	if (_gestureDur >= 1) {
		
		NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
		
		AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
		uploadRequest.bucket = bucketName;
		uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
		uploadRequest.key = [[path pathComponents] lastObject];
		uploadRequest.contentType = @"video/mp4";
		uploadRequest.body = url;
		
		AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
		[[transferManager upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
			_lpGestureRecognizer.enabled = YES;
			if (task.error)
				NSLog(@"AWSS3TransferManager: **ERROR** [%@]", task.error);
			
			else {
				NSLog(@"AWSS3TransferManager: !!SUCCESS!! [%@]", task.error);
				
//				AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://kikgames.trydood.com/"]];
//				[httpClient getPath:@"postVideo.php" parameters:@{@"channel"	: _channel.name,
//																	@"file"		: [[path pathComponents] lastObject]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
//																		 NSError *error = nil;
//																		 NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//																		 
//																		 if (error != nil) {
//																			 SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) - Failed to parse JSON: %@", [[self class] description], [[operation request] URL], [error localizedFailureReason]);
//																			 [[HONAPICaller sharedInstance] showDataErrorHUD];
//																			 
//																		 } else {
//																			 SelfieclubJSONLog(@"//—> -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
//																		 }
//																		 
//																		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//																			SelfieclubJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [[HONAPICaller sharedInstance] pythonAPIBasePath], @"newsfeed/member/", [error localizedDescription]);
//																			[[HONAPICaller sharedInstance] showDataErrorHUD];
//																		}];
				
				[[HONAnalyticsReporter sharedInstance] trackEvent:[kAnalyticsCohort stringByAppendingString:@" - sendVideo"] withProperties:@{@"channel"	: @(_statusUpdateVO.statusUpdateID)}];
				
				[PubNub sendMessage:@"Somebody posted a video!"
						  toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
							  NSLog(@"\nSEND MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
						  }];
				
				[PubNub sendMessage:[[path pathComponents] lastObject]
							toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
								NSLog(@"\nSEND MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
							}];
				
				[PubNub sendMessage:[NSString stringWithFormat:@"{\"pn_apns\": {\"aps\": {\"alert\": \"Someone on Popup has sent a video moment.\",\"badge\": %d,\"sound\": \"selfie_notification.aif\", \"channel\": \"%@\"}}}", _messageTotal, _channel.name]
						  toChannel:_channel withCompletionBlock:^(PNMessageState messageState, id data) {
							  NSLog(@"\nSEND MessageState - [%@](%@)", (messageState == PNMessageSent) ? @"MessageSent" : (messageState == PNMessageSending) ? @"MessageSending" : (messageState == PNMessageSendingError) ? @"MessageSendingError" : @"UNKNOWN", data);
						  }];
			}
			
			return (nil);
		}];
//	}
}


// progress
- (void)vision:(PBJVision *)vision didCaptureVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
	NSLog(@"[*:*] vision:didCaptureVideoSampleBuffer:[%.04f] [*:*]", vision.capturedVideoSeconds);
	
//	_takePhotoButton.frame = CGRectMake(_takePhotoButton.frame.origin.x, ([[HONDeviceIntrinsics sharedInstance] isPhoneType6]) ? 588.0 : ([[HONDeviceIntrinsics sharedInstance] isPhoneType6Plus]) ? 728.0 : 489.0, _takePhotoButton.frame.size.width, _takePhotoButton.frame.size.height);
//	_cameraPreviewView.frame = CGRectMake(0.0, self.view.frame.size.height * 0.62, self.view.frame.size.width, self.view.frame.size.height * 0.62);
//	_commentFooterView.backgroundColor = [UIColor clearColor];
//	
//	_statusLabel.text = @"Sending popup…";
//	_animationImageView.hidden = NO;
//	_animationImageView.frame = CGRectMake((self.view.frame.size.width - 206.0) * 0.5, 20.0 + (((self.view.frame.size.height * 0.5) - 206.0) * 0.5), 206.0, 206.0);
//	
//	[[PBJVision sharedInstance] endVideoCapture];
//	_statusUpdateHeaderView.hidden = NO;
//	_commentFooterView.hidden = NO;
//	_openCommentButton.hidden = NO;
//	_flagButton.hidden = NO;
//	_messengerButton.hidden = NO;
//	_countdownLabel.text = @"";
//	_countdownLabel.hidden = YES;
//	_moviePlayer.view.hidden = NO;
//	_cameraFlipButton.hidden = NO;
//	_expireLabel.hidden = NO;
//	_lpGestureRecognizer.enabled = YES;
}

- (void)vision:(PBJVision *)vision didCaptureAudioSample:(CMSampleBufferRef)sampleBuffer {
	NSLog(@"[*:*] vision:didCaptureAudioSample:[%.04f] [*:*]", vision.capturedAudioSeconds);
}


@end
