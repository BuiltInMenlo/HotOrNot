//
//  HONChallengeCameraViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/6/13 @ 12:01 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import <AWSiOSSDK/S3/AmazonS3Client.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

#import "ImageFilter.h"
#import "MBProgressHUD.h"
#import "TSTapstream.h"

#import "NSString+DataTypes.h"
#import "UIImage+fixOrientation.h"

#import "HONSelfieCameraViewController.h"
#import "HONSelfieCameraOverlayView.h"
#import "HONSelfieCameraPreviewView.h"
#import "HONSelfieCameraSubmitViewController.h"
#import "HONProtoChallengeVO.h"
#import "HONTrivialUserVO.h"


@interface HONSelfieCameraViewController () <HONSelfieCameraOverlayViewDelegate, HONSelfieCameraPreviewViewDelegate, AmazonServiceRequestDelegate>
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) HONSelfieCameraOverlayView *cameraOverlayView;
@property (nonatomic, strong) HONSelfieCameraPreviewView *previewView;
@property (nonatomic, assign, readonly) HONSelfieCameraSubmitType selfieSubmitType;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONProtoChallengeVO *protoChallengeVO;
@property (nonatomic, strong) HONMessageVO *messageVO;
@property (nonatomic, strong) HONUserClubVO *userClubVO;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) NSArray *recipients;
@property (nonatomic, strong) S3PutObjectRequest *por1;
@property (nonatomic, strong) S3PutObjectRequest *por2;
@property (nonatomic, strong) UIImage *processedImage;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSDictionary *challengeParams;
@property (nonatomic, strong) UIImageView *submitImageView;
@property (nonatomic) int tintIndex;
@property (nonatomic) BOOL hasSubmitted;
@property (nonatomic) BOOL isFirstAppearance;
@property (nonatomic) BOOL isFirstCamera;
@property (nonatomic) BOOL isUploadComplete;
@property (nonatomic) int uploadCounter;
@property (nonatomic) int selfieAttempts;
@end


@implementation HONSelfieCameraViewController

- (id)init {
	if ((self = [super init])) {
		_selfieAttempts = 0;
		_isFirstAppearance = YES;
	}
	
	return (self);
}

- (id)initAsNewChallenge {
	NSLog(@"%@ - initAsNewChallenge", [self description]);
	if ((self = [self init])) {
		_selfieSubmitType = HONSelfieCameraSubmitTypeCreateChallenge;
		
		_subjectName = @"";
	}
	
	return (self);
}

- (id)initAsJoinChallenge:(HONChallengeVO *)challengeVO {
	NSLog(@"%@ - initAsJoinChallenge:[%d] \"%@\"", [self description], challengeVO.challengeID, challengeVO.subjectName);
	if ((self = [self init])) {
		_selfieSubmitType = HONSelfieCameraSubmitTypeReplyChallenge;
		
		_challengeVO = challengeVO;
		_subjectName = challengeVO.subjectName;
		
		NSMutableArray *participants = [NSMutableArray arrayWithObject:[HONTrivialUserVO userWithDictionary:@{@"id"			: [@"" stringFromInt:_challengeVO.creatorVO.userID],
																											  @"username"	: _challengeVO.creatorVO.username,
																											  @"img_url"	: _challengeVO.creatorVO.avatarPrefix}]];
		
//		for (HONOpponentVO *vo in _challengeVO.challengers) {
//			[participants addObject:[HONTrivialUserVO userWithDictionary:@{@"id"		: [@"" stringFromInt:_challengeVO.creatorVO.userID],
//																		   @"username"	: _challengeVO.creatorVO.username,
//																		   @"img_url"	: _challengeVO.creatorVO.avatarPrefix}]];
//		}
		
		_recipients = [participants copy];
	}
	
	return (self);
}

- (id)initAsNewMessageWithRecipients:(NSArray *)recipients {
	NSLog(@"%@ - initAsNewMessageWithRecipients:[%@]", [self description], recipients);
	if ((self = [self init])) {
		_selfieSubmitType = HONSelfieCameraSubmitTypeCreateMessage;
		_recipients = recipients;
		_subjectName = @"";
	}
	
	return (self);
}

- (id)initAsMessageReply:(HONMessageVO *)messageVO withRecipients:(NSArray *)recipients {
	NSLog(@"%@ - initAsMessageReply:[%@]", [self description], messageVO.dictionary);
	if ((self = [self init])) {
		_selfieSubmitType = HONSelfieCameraSubmitTypeReplyMessage;
		
		_messageVO = messageVO;
		_subjectName = _messageVO.subjectName;
		_recipients = recipients;
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}

- (BOOL)shouldAutorotate {
	return (NO);
}


#pragma mark - Data Calls
- (void)_uploadPhotos {
	_isUploadComplete = NO;
	_uploadCounter = 0;
	
	_filename = [NSString stringWithFormat:@"%@-%@_%@", [[[HONDeviceIntrinsics sharedInstance] identifierForVendorWithoutSeperators:YES] lowercaseString], [[[HONDeviceIntrinsics sharedInstance] advertisingIdentifierWithoutSeperators:YES] lowercaseString], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
	NSLog(@"FILE PREFIX: %@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], _filename);
	
	UIImage *largeImage = [HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:_processedImage toSize:CGSizeMake(852.0, kSnapLargeSize.height * 2.0)] toRect:CGRectMake(106.0, 0.0, kSnapLargeSize.width * 2.0, kSnapLargeSize.height * 2.0)];
	UIImage *tabImage = [HONImagingDepictor cropImage:largeImage toRect:CGRectMake(0.0, 0.0, kSnapTabSize.width * 2.0, kSnapTabSize.height * 2.0)];
	
//	[[HONAPICaller sharedInstance] uploadPhotosToS3:@[UIImageJPEGRepresentation(largeImage, [HONAppDelegate compressJPEGPercentage]), UIImageJPEGRepresentation(tabImage, [HONAppDelegate compressJPEGPercentage] * 0.85)] intoBucket:@"hotornot-challenges" withFilename:_filename completion:^(NSObject *result){
//		_isUploadComplete = YES;
//		[_previewView uploadComplete];
//		
//		if (_progressHUD != nil) {
//			[_progressHUD hide:YES];
//			_progressHUD = nil;
//		}
//		if (_hasSubmitted) {
//			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
//
//			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
//				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
//			}];
//		}
//	}];

	
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	
	@try {
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-challenges"]];
		_por1 = [[S3PutObjectRequest alloc] initWithKey:[_filename stringByAppendingString:kSnapLargeSuffix] inBucket:@"hotornot-challenges"];
		_por1.delegate = self;
		_por1.contentType = @"image/jpeg";
		_por1.data = UIImageJPEGRepresentation(largeImage, [HONAppDelegate compressJPEGPercentage]);
		[s3 putObject:_por1];
		
		_por2 = [[S3PutObjectRequest alloc] initWithKey:[_filename stringByAppendingString:kSnapTabSuffix] inBucket:@"hotornot-challenges"];
		_por2.delegate = self;
		_por2.contentType = @"image/jpeg";
		_por2.data = UIImageJPEGRepresentation(tabImage, [HONAppDelegate compressJPEGPercentage] * 0.85);
		[s3 putObject:_por2];
		
	} @catch (AmazonClientException *exception) {
		NSLog(@"AWS FAIL:[%@]", exception.message);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}
}

- (void)_submitChallenge {
	_submitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(133.0, ([UIScreen mainScreen].bounds.size.height - 14.0) * 0.5, 54.0, 14.0)];
	_submitImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"cameraUpload_001"],
										[UIImage imageNamed:@"cameraUpload_002"],
										[UIImage imageNamed:@"cameraUpload_003"], nil];
	_submitImageView.animationDuration = 0.5f;
	_submitImageView.animationRepeatCount = 0;
	_submitImageView.alpha = 0.0;
	[_submitImageView startAnimating];
	[[[UIApplication sharedApplication] delegate].window addSubview:_submitImageView];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_submitImageView.alpha = 1.0;
	} completion:nil];
	
	[[HONAPICaller sharedInstance] submitChallengeWithDictionary:_challengeParams completion:^(NSObject *result) {
//		[UIView animateWithDuration:0.5 animations:^(void) {
//			_submitImageView.alpha = 0.0;
//		} completion:^(BOOL finished) {
//			[_submitImageView removeFromSuperview];
//			_submitImageView = nil;
//		}];
		
		[self _submitCompleted:(NSDictionary *)result];
	}];
}

- (void)_submitMessage {
	_submitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(133.0, ([UIScreen mainScreen].bounds.size.height - 14.0) * 0.5, 54.0, 14.0)];
	_submitImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"cameraUpload_001"],
										[UIImage imageNamed:@"cameraUpload_002"],
										[UIImage imageNamed:@"cameraUpload_003"], nil];
	_submitImageView.animationDuration = 0.5f;
	_submitImageView.animationRepeatCount = 0;
	_submitImageView.alpha = 0.0;
	[_submitImageView startAnimating];
	[[[UIApplication sharedApplication] delegate].window addSubview:_submitImageView];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_submitImageView.alpha = 1.0;
	} completion:nil];
	
	[[HONAPICaller sharedInstance] submitNewMessageWithDictionary:_challengeParams completion:^(NSObject *result){
		[self _submitCompleted:(NSDictionary *)result];
	}];
}


- (void)_submitCompleted:(NSDictionary *)result {
	if ([[result objectForKey:@"result"] isEqualToString:@"fail"]) {
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = @"Error!";
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
		
	} else {
		_hasSubmitted = YES;
		
		if (_isUploadComplete) {
			TSTapstream *tracker = [TSTapstream instance];
			
			TSEvent *e = [TSEvent eventWithName:@"Submitted Photo" oneTimeOnly:YES];
			[e addValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
			[e addValue:[[HONAppDelegate infoForUser] objectForKey:@"username"] forKey:@"username"];
			[tracker fireEvent:e];
			
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
			
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
				NSLog(@"_selfieSubmitType:[%d]", _selfieSubmitType);
				
				if (_selfieSubmitType == HONSelfieCameraSubmitTypeCreateChallenge || _selfieSubmitType == HONSelfieCameraSubmitTypeReplyChallenge)
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:nil];
				
				else if (_selfieSubmitType == HONSelfieCameraSubmitTypeCreateMessage)
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_MESSAGES" object:nil];
				
				else if (_selfieSubmitType == HONSelfieCameraSubmitTypeReplyMessage) {
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_MESSAGES" object:nil];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_MESSAGE" object:nil];
				}
			}];
		}
	}
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
}

- (void)viewDidUnload {
	ViewControllerLog(@"[:|:] [%@ viewDidUnload] [:|:]", self.class);
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, [[NSString string] stringFromBOOL:animated]);
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [[NSString string] stringFromBOOL:animated]);
	[super viewDidAppear:animated];
	
	if (_isFirstAppearance) {
		_isFirstAppearance = NO;
		[self showImagePickerForSourceType:([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillDisappear:%@] [:|:]", self.class, [[NSString string] stringFromBOOL:animated]);
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidDisappear:%@] [:|:]", self.class, [[NSString string] stringFromBOOL:animated]);
	[super viewDidDisappear:animated];
}


#pragma mark - UI Presentation
- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
	UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
	imagePickerController.view.backgroundColor = [UIColor whiteColor];
	imagePickerController.sourceType = sourceType;
	imagePickerController.delegate = self;
	
	if (sourceType == UIImagePickerControllerSourceTypeCamera) {
		float scale = ([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? 1.55f : 1.25f;
		
		imagePickerController.showsCameraControls = NO;
		imagePickerController.cameraViewTransform = CGAffineTransformMakeTranslation(24.0, 90.0);
		imagePickerController.cameraViewTransform = CGAffineTransformScale(imagePickerController.cameraViewTransform, scale, scale);
		imagePickerController.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		
		_cameraOverlayView = [[HONSelfieCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_cameraOverlayView.delegate = self;
 	}
	
	self.imagePickerController = imagePickerController;
	[self presentViewController:self.imagePickerController animated:NO completion:^(void) {
		if (sourceType == UIImagePickerControllerSourceTypeCamera)
			[self _showOverlay];
	}];
}

- (void)_showOverlay {
	int camera_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"camera_total"] intValue];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++camera_total] forKey:@"camera_total"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	_isFirstCamera = (camera_total == 0);
	self.imagePickerController.cameraOverlayView = _cameraOverlayView;
	[_cameraOverlayView introWithTutorial:_isFirstCamera];
}


#pragma mark - Upload Handling
- (void)_cancelUpload {
	_isUploadComplete = NO;
	_uploadCounter = 0;
	
	[_por1.urlConnection cancel];
	_por1 = nil;
	
	[_por2.urlConnection cancel];
	_por2 = nil;
}

- (void)_uploadTimeout {
	[self _cancelUpload];
	
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.mode = MBProgressHUDModeCustomView;
	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
	_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
	[_progressHUD show:NO];
	[_progressHUD hide:YES afterDelay:kHUDErrorTime];
	_progressHUD = nil;
}


#pragma mark - CameraOverlay Delegates
- (void)cameraOverlayViewShowCameraRoll:(HONSelfieCameraOverlayView *)cameraOverlayView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Volley - Camera Roll"];
	
	self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

}

- (void)cameraOverlayViewChangeCamera:(HONSelfieCameraOverlayView *)cameraOverlayView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Volley - Flip Camera"
								   withCameraDevice:self.imagePickerController.cameraDevice];
	
	self.imagePickerController.cameraDevice = (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront) ? UIImagePickerControllerCameraDeviceRear : UIImagePickerControllerCameraDeviceFront;
	
	if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceRear)
		self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
}

- (void)cameraOverlayViewCameraBack:(HONSelfieCameraOverlayView *)cameraOverlayView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Volley - Back"];
	[self _cancelUpload];
}

- (void)cameraOverlayViewCloseCamera:(HONSelfieCameraOverlayView *)cameraOverlayView {
	NSLog(@"cameraOverlayViewCloseCamera");
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Cancel"];
	
	[self _cancelUpload];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[self.imagePickerController dismissViewControllerAnimated:NO completion:^(void) {
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
	}];
}

- (void)cameraOverlayViewTakePhoto:(HONSelfieCameraOverlayView *)cameraOverlayView withTintIndex:(int)tintIndex {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Volley - Take Photo"
									 withProperties:@{@"tint"	: [@"" stringFromInt:tintIndex]}];
	
	_tintIndex = tintIndex;
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Loading…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[self.imagePickerController takePicture];
}


#pragma mark - CameraPreviewView Delegates
- (void)cameraPreviewViewBackToCamera:(HONSelfieCameraPreviewView *)previewView {
	NSLog(@"cameraPreviewViewBackToCamera");
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Volley - Retake Photo"];
	[self _cancelUpload];
	
	NSLog(@"SOURCE:[%d]", self.imagePickerController.sourceType);
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && self.imagePickerController.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
		float scale = ([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? 1.55f : 1.25f;
		
		self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
		self.imagePickerController.showsCameraControls = NO;
		self.imagePickerController.cameraViewTransform = CGAffineTransformMakeTranslation(24.0, 90.0);
		self.imagePickerController.cameraViewTransform = CGAffineTransformScale(self.imagePickerController.cameraViewTransform, scale, scale);
		self.imagePickerController.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		
		_cameraOverlayView = [[HONSelfieCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_cameraOverlayView.delegate = self;
		
		[self presentViewController:self.imagePickerController animated:NO completion:^(void) {
			[self _showOverlay];
		}];
	}
}

- (void)cameraPreviewViewClose:(HONSelfieCameraPreviewView *)previewView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Volley - Close"];
	
	[self _cancelUpload];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)cameraPreviewViewSubmit:(HONSelfieCameraPreviewView *)previewView withSubject:(NSString *)subject {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Volley - Submit"];
	
	_hasSubmitted = NO;
	_subjectName = subject;
	
	NSString *recipients = @"";
	for (HONTrivialUserVO *vo in _recipients)
		recipients = [[recipients stringByAppendingString:[@"" stringFromInt:vo.userID]] stringByAppendingString:@","];
	
	
	HONProtoChallengeVO *protoChallengeVO = [HONProtoChallengeVO protoChallengeWithDictionary:@{@"user_id"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
																								@"img_url"		: [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeEmoticonsCloudFront], _filename],
																								@"challenge_id"	: [@"" stringFromInt:(_selfieSubmitType == HONSelfieCameraSubmitTypeReplyMessage && _messageVO != nil) ? _messageVO.messageID : (_selfieSubmitType == HONSelfieCameraSubmitTypeReplyChallenge && _challengeVO != nil) ? _challengeVO.challengeID : 0],
																								@"club_id"		: [@"" stringFromInt:_userClubVO.clubID],
																								@"subject"		: _subjectName,
																								@"recipients"	: ([recipients length] > 0) ? [recipients substringToIndex:[recipients length] - 1] : @""}];
	
	
	NSLog(@"protoChallengeVO:[%@]", protoChallengeVO.dictionary);
	//[self.navigationController pushViewController:[[HONSelfieCameraSubmitViewController alloc] initWithProtoChallenge:protoChallengeVO] animated:YES];
	
	/*
	_challengeParams = @{@"user_id"			: [[HONAppDelegate infoForUser] objectForKey:@"id"],
						 @"img_url"			: [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:@"challenges"], _filename],
						 @"challenge_id"	: [@"" stringFromInt:(_selfieSubmitType == HONCameraSubmitTypeReplyMessage && _messageVO != nil) ? _messageVO.messageID : (_selfieSubmitType == HONCameraSubmitTypeReplyChallenge && _challengeVO != nil) ? _challengeVO.challengeID : 0],
						 @"club_id"			: [@"" stringFromInt:_userClubVO.clubID],
						 @"subject"			: _subjectName,
						 @"recipients"		: ([recipients length] > 0) ? [recipients substringToIndex:[recipients length] - 1] : @"",
						 @"api_endpt"		: (_selfieSubmitType == HONCameraSubmitTypeCreateChallenge) ? kAPICreateChallenge : kAPIJoinChallenge};
	
	
	NSLog(@"SUBMIT PARAMS:[%@]", _challengeParams);
	if (_selfieSubmitType == HONCameraSubmitTypeCreateMessage)
		[self _submitMessage];
	
	else
		[self _submitChallenge];
	 */
	
	
	
	_challengeParams = @{@"user_id"			: [[HONAppDelegate infoForUser] objectForKey:@"id"],
						 @"img_url"			: [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], _filename],
						 @"challenge_id"	: [@"" stringFromInt:(_selfieSubmitType == HONSelfieCameraSubmitTypeReplyChallenge && _challengeVO != nil) ? _challengeVO.challengeID : 0],
						 @"club_id"			: [@"" stringFromInt:_userClubVO.clubID],
						 @"subject"			: _subjectName,
						 @"recipients"		: ([recipients length] > 0) ? [recipients substringToIndex:[recipients length] - 1] : @"",
						 @"api_endpt"		: (_selfieSubmitType == HONSelfieCameraSubmitTypeCreateChallenge) ? kAPICreateChallenge : kAPIJoinChallenge};
	
	
	NSLog(@"SUBMIT PARAMS:[%@]", _challengeParams);
	[self _submitChallenge];
}


#pragma mark - AWS Delegates
- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
	NSLog(@"\nAWS didCompleteWithResponse:\n%@", response);
	
	_uploadCounter++;
	_isUploadComplete = (_uploadCounter == 2);
	
	if (_isUploadComplete) {
		if (_submitImageView != nil) {
			[UIView animateWithDuration:0.5 animations:^(void) {
				_submitImageView.alpha = 0.0;
			} completion:^(BOOL finished) {
				[_submitImageView removeFromSuperview];
				_submitImageView = nil;
			}];
		}

		[_previewView uploadComplete];
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsCloudFront], _filename] forBucketType:HONS3BucketTypeSelfies completion:^(NSObject *result) {
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
		
			if (_hasSubmitted) {
				[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
				}];
			}
		}];
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
			
		if (_hasSubmitted) {
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
				
//			if (_isFirstCamera && [HONAppDelegate switchEnabledForKey:@"share_volley"])
//				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SELF" object:(_rawImage.size.width >= 1936.0) ? [HONImagingDepictor scaleImage:_rawImage toSize:CGSizeMake(960.0, 1280.0)] : _rawImage];
			}];
		}
	}
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"AWS didFailWithError:\n%@", error);
	
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.mode = MBProgressHUDModeCustomView;
	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
	_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
	[_progressHUD show:NO];
	[_progressHUD hide:YES afterDelay:kHUDErrorTime];
	_progressHUD = nil;
	
	[_previewView uploadComplete];
	
	if (_submitImageView != nil) {
		[UIView animateWithDuration:0.5 animations:^(void) {
			_submitImageView.alpha = 0.0;
		} completion:^(BOOL finished) {
			[_submitImageView removeFromSuperview];
			_submitImageView = nil;
		}];
	}
}


#pragma mark - NavigationController Delegates
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	BOOL isSourceImageMirrored = (picker.sourceType == UIImagePickerControllerSourceTypeCamera && picker.cameraDevice == UIImagePickerControllerCameraDeviceFront);
	
	_processedImage = [HONImagingDepictor prepForUploading:[info objectForKey:UIImagePickerControllerOriginalImage]];
	NSLog(@"PROCESSED IMAGE:[%@]", NSStringFromCGSize(_processedImage.size));
	
	UIView *canvasView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _processedImage.size.width, _processedImage.size.height)];
	[canvasView addSubview:[[UIImageView alloc] initWithImage:_processedImage]];
	
	UIView *overlayTintView = [[UIView alloc] initWithFrame:canvasView.frame];
	overlayTintView.backgroundColor = [[HONAppDelegate colorsForOverlayTints] objectAtIndex:_tintIndex];
	[canvasView addSubview:overlayTintView];
	
	_processedImage = (isSourceImageMirrored) ? [HONImagingDepictor mirrorImage:[HONImagingDepictor createImageFromView:canvasView]] : [HONImagingDepictor createImageFromView:canvasView];
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	_previewView = [[HONSelfieCameraPreviewView alloc] initWithFrame:[UIScreen mainScreen].bounds withPreviewImage:_processedImage asSubmittingType:_selfieSubmitType withSubject:_subjectName withRecipients:_recipients];
	_previewView.delegate = self;
	
	if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
		[_cameraOverlayView submitStep:_previewView];
	
	} else {
		[self dismissViewControllerAnimated:NO completion:^(void) {
			[self.view addSubview:_previewView];
		}];
	}
	
	[self _uploadPhotos];
	
	
	[HONAppDelegate incTotalForCounter:@"friend"];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	NSLog(@"imagePickerControllerDidCancel");
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
		
		float scale = ([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? 1.55f : 1.25f;
		
		self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
		self.imagePickerController.showsCameraControls = NO;
		self.imagePickerController.cameraViewTransform = CGAffineTransformMakeTranslation(24.0, 90.0);
		self.imagePickerController.cameraViewTransform = CGAffineTransformScale(self.imagePickerController.cameraViewTransform, scale, scale);
		self.imagePickerController.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		
		_cameraOverlayView = [[HONSelfieCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_cameraOverlayView.delegate = self;
		[self _showOverlay];
		
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		
		// We want to dismiss the image picker + ourselves so we need to call dismiss on our parent.
		[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
	}
}


@end
