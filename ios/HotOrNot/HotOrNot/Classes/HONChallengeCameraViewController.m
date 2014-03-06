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
#import "UIImage+fixOrientation.h"

#import "HONChallengeCameraViewController.h"
#import "HONAPICaller.h"
#import "HONDeviceTraits.h"
#import "HONImagingDepictor.h"
#import "HONSnapCameraOverlayView.h"
#import "HONCreateChallengePreviewView.h"
#import "HONTrivialUserVO.h"


@interface HONChallengeCameraViewController () <HONSnapCameraOverlayViewDelegate, HONCreateChallengePreviewViewDelegate, AmazonServiceRequestDelegate>
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) HONSnapCameraOverlayView *cameraOverlayView;
@property (nonatomic, strong) HONCreateChallengePreviewView *previewView;
@property (readonly, nonatomic, assign) HONSelfieSubmitType selfieSubmitType;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONMessageVO *messageVO;
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


@implementation HONChallengeCameraViewController

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
		_selfieSubmitType = HONSelfieSubmitTypeCreateChallenge;
		
		_subjectName = @"";
	}
	
	return (self);
}

- (id)initAsJoinChallenge:(HONChallengeVO *)challengeVO {
	NSLog(@"%@ - initAsJoinChallenge:[%d] \"%@\"", [self description], challengeVO.challengeID, challengeVO.subjectName);
	if ((self = [self init])) {
		_selfieSubmitType = HONSelfieSubmitTypeReplyChallenge;
		
		_challengeVO = challengeVO;
		_subjectName = challengeVO.subjectName;
	}
	
	return (self);
}

- (id)initAsNewMessageWithRecipients:(NSArray *)recipients {
	NSLog(@"%@ - initAsNewMessageWithRecipients:[%@]", [self description], recipients);
	if ((self = [self init])) {
		_selfieSubmitType = HONSelfieSubmitTypeCreateMessage;
		_recipients = recipients;
		_subjectName = @"";
	}
	
	return (self);
}

- (id)initAsMessageReply:(HONMessageVO *)messageVO withRecipients:(NSArray *)recipients {
	NSLog(@"%@ - initAsMessageReply:[%@]", [self description], messageVO.dictionary);
	if ((self = [self init])) {
		_selfieSubmitType = HONSelfieSubmitTypeReplyMessage;
		
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
	
	_filename = [NSString stringWithFormat:@"%@-%@_%@", [[[HONDeviceTraits sharedInstance] identifierForVendorWithoutSeperators:YES] lowercaseString], [[[HONDeviceTraits sharedInstance] advertisingIdentifierWithoutSeperators:YES] lowercaseString], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
	NSLog(@"FILE PREFIX: %@/%@", [HONAppDelegate s3BucketForType:@"challenges"], _filename);
	
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
//			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//			
//			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
//				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:@"Y"];
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
	
	[[HONAPICaller sharedInstance] submitChallengeWithDictionary:_challengeParams completion:^(NSObject *result){
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
			
			
//			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
//			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
			
			
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
				NSLog(@"_selfieSubmitType:[%d]", _selfieSubmitType);
				
				if (_selfieSubmitType == HONSelfieSubmitTypeCreateChallenge || _selfieSubmitType == HONSelfieSubmitTypeReplyChallenge)
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:nil];
				
				else if (_selfieSubmitType == HONSelfieSubmitTypeCreateMessage)
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_MESSAGES" object:nil];
				
				else if (_selfieSubmitType == HONSelfieSubmitTypeReplyMessage) {
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_MESSAGES" object:nil];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_MESSAGE" object:nil];
				}
			}];
		}
	}
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_STATUS_BAR_TINT" object:@"NO"];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (_isFirstAppearance) {
		_isFirstAppearance = NO;
		[self showImagePickerForSourceType:([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
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
		float scale = ([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? 1.55f : 1.25f;
		
		imagePickerController.showsCameraControls = NO;
		imagePickerController.cameraViewTransform = CGAffineTransformMakeTranslation(24.0, 90.0);
		imagePickerController.cameraViewTransform = CGAffineTransformScale(imagePickerController.cameraViewTransform, scale, scale);
		imagePickerController.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		
		_cameraOverlayView = [[HONSnapCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
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
- (void)cameraOverlayViewShowCameraRoll:(HONSnapCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Create Volley - Camera Roll"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)cameraOverlayViewChangeCamera:(HONSnapCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Create Volley - Flip Camera"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront) ? @"rear" : @"front", @"type", nil]];
	
	self.imagePickerController.cameraDevice = (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront) ? UIImagePickerControllerCameraDeviceRear : UIImagePickerControllerCameraDeviceFront;
	
	if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceRear)
		self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
}

- (void)cameraOverlayViewCameraBack:(HONSnapCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Create Volley - Back"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	[self _cancelUpload];
}

- (void)cameraOverlayViewCloseCamera:(HONSnapCameraOverlayView *)cameraOverlayView {
	NSLog(@"cameraOverlayViewCloseCamera");
	[[Mixpanel sharedInstance] track:@"Create Volley - Cancel"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	[self _cancelUpload];
//	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[self.imagePickerController dismissViewControllerAnimated:NO completion:^(void) {
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
	}];
}

- (void)cameraOverlayViewTakePhoto:(HONSnapCameraOverlayView *)cameraOverlayView withTintIndex:(int)tintIndex {
	[[Mixpanel sharedInstance] track:@"Create Volley - Take Photo"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d", tintIndex], @"tint", nil]];
	
	_tintIndex = tintIndex;
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Loading…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[self.imagePickerController takePicture];
}


#pragma mark - PreviewView Delegates
- (void)previewViewBackToCamera:(HONCreateChallengePreviewView *)previewView {
	NSLog(@"previewViewBackToCamera");
	
	[[Mixpanel sharedInstance] track:@"Create Volley - Retake Photo"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	[self _cancelUpload];
	
	NSLog(@"SOURCE:[%d]", self.imagePickerController.sourceType);
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && self.imagePickerController.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
		float scale = ([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? 1.55f : 1.25f;
		
		self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
		self.imagePickerController.showsCameraControls = NO;
		self.imagePickerController.cameraViewTransform = CGAffineTransformMakeTranslation(24.0, 90.0);
		self.imagePickerController.cameraViewTransform = CGAffineTransformScale(self.imagePickerController.cameraViewTransform, scale, scale);
		self.imagePickerController.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		
		_cameraOverlayView = [[HONSnapCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_cameraOverlayView.delegate = self;
		
		[self presentViewController:self.imagePickerController animated:NO completion:^(void) {
			[self _showOverlay];
		}];
	}
}

- (void)previewView:(HONCreateChallengePreviewView *)previewView changeSubject:(NSString *)subject {
	NSLog(@"previewView:changeSubject:[%@]", subject);	
	_subjectName = subject;
}

- (void)previewViewClose:(HONCreateChallengePreviewView *)previewView {
	[[Mixpanel sharedInstance] track:@"Create Volley - Close"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	[self _cancelUpload];
//	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)previewViewSubmit:(HONCreateChallengePreviewView *)previewView {
	[[Mixpanel sharedInstance] track:@"Create Volley - Submit"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	_hasSubmitted = NO;
	int friend_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"friend_total"] intValue];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++friend_total] forKey:@"friend_total"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if ([[HONAppDelegate followersListWithRefresh:NO] count] == 1 && friend_total == 0) {
		UIAlertView *alertView = [[UIAlertView alloc]
								  initWithTitle:@"Find Friends"
								  message:@"Selfieclub is more fun with friends! Find some now?"
								  delegate:self
								  cancelButtonTitle:@"Yes"
								  otherButtonTitles:@"No", nil];
		[alertView setTag:2];
		[alertView show];
		
	} else {
		NSString *recipients = @"";
		for (HONTrivialUserVO *vo in _recipients)
			recipients = [[recipients stringByAppendingString:[NSString stringWithFormat:@"%d", vo.userID]] stringByAppendingString:@","];
		
		_challengeParams = @{@"user_id"			: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"img_url"			: [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:@"challenges"], _filename],
							 @"challenge_id"	: [NSString stringWithFormat:@"%d", (_selfieSubmitType == HONSelfieSubmitTypeReplyMessage && _messageVO != nil) ? _messageVO.messageID : (_selfieSubmitType == HONSelfieSubmitTypeReplyChallenge && _challengeVO != nil) ? _challengeVO.challengeID : 0],
							 @"subject"			: _subjectName,
							 @"recipients"		: ([recipients length] > 0) ? [recipients substringToIndex:[recipients length] - 1] : @"",
							 @"api_endpt"		: (_selfieSubmitType == HONSelfieSubmitTypeCreateChallenge) ? kAPICreateChallenge : kAPIJoinChallenge};
		
		NSLog(@"SUBMIT PARAMS:[%@]", _challengeParams);
		if (_selfieSubmitType == HONSelfieSubmitTypeCreateMessage)
			[self _submitMessage];
		
		else
			[self _submitChallenge];
	}
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
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForURL:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:@"challenges"], _filename] forAvatarBucket:NO preDelay:1.0 completion:^(NSObject *result){
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
		
			if (_hasSubmitted) {
//				[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
				[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
				
				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:@"Y"];
				}];
			}
		}];
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
			
		if (_hasSubmitted) {
//			[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
			
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:@"Y"];
				
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
//	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
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
	_previewView = [[HONCreateChallengePreviewView alloc] initWithFrame:[UIScreen mainScreen].bounds withPreviewImage:_processedImage asSubmittingType:_selfieSubmitType withSubject:_subjectName withRecipients:_recipients];
	_previewView.delegate = self;
	[_previewView showKeyboard];
	
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
		float scale = ([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? 1.55f : 1.25f;
		
		self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
		self.imagePickerController.showsCameraControls = NO;
		self.imagePickerController.cameraViewTransform = CGAffineTransformMakeTranslation(24.0, 90.0);
		self.imagePickerController.cameraViewTransform = CGAffineTransformScale(self.imagePickerController.cameraViewTransform, scale, scale);
		self.imagePickerController.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		
		_cameraOverlayView = [[HONSnapCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_cameraOverlayView.delegate = self;
		[self _showOverlay];
		
	} else {
//		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		
		// We want to dismiss the image picker + ourselves so we need to call dismiss on our parent.
		[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
	}
}


@end
