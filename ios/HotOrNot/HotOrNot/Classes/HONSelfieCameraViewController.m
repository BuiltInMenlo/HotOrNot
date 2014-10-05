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
#import "UIImage+ImageEffects.h"

#import "HONSelfieCameraViewController.h"
#import "HONCameraOverlayView.h"
#import "HONSelfieCameraPreviewView.h"
#import "HONStatusUpdateSubmitViewController.h"
#import "HONStoreTransactionObserver.h"
#import "HONTrivialUserVO.h"


@interface HONSelfieCameraViewController () <HONCameraOverlayViewDelegate, HONSelfieCameraPreviewViewDelegate, AmazonServiceRequestDelegate>
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) HONCameraOverlayView *cameraOverlayView;
@property (nonatomic, strong) HONSelfieCameraPreviewView *previewView;
@property (nonatomic, assign, readonly) HONSelfieSubmitType selfieSubmitType;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONMessageVO *messageVO;
@property (nonatomic, strong) HONUserClubVO *userClubVO;
@property (nonatomic, strong) HONTrivialUserVO *trivialUserVO;
@property (nonatomic, strong) HONContactUserVO *contactUserVO;
@property (nonatomic, strong) NSArray *recipients;
@property (nonatomic, strong) S3PutObjectRequest *por1;
@property (nonatomic, strong) S3PutObjectRequest *por2;
@property (nonatomic, strong) UIImage *processedImage;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSDictionary *submitParams;
@property (nonatomic) BOOL isUploadComplete;
@property (nonatomic) BOOL isBlurred;
@property (nonatomic) int uploadCounter;
@property (nonatomic) int selfieAttempts;
@property (nonatomic, strong) HONStoreTransactionObserver *storeTransactionObserver;
@end


@implementation HONSelfieCameraViewController
@synthesize delegate = _delegate;

- (id)init {
	if ((self = [super init])) {
		_selfieAttempts = 0;
		_filename = [[HONClubAssistant sharedInstance] rndCoverImageURL];
	}
	
	return (self);
}

- (void)dealloc {
	_por1.delegate = nil;
	_por2.delegate = nil;
	_previewView.delegate = nil;
	_cameraOverlayView.delegate = nil;
}

- (id)initWithContact:(HONContactUserVO *)contactUserVO {
	NSLog(@"%@ - initWithContact", [self description]);
	if ((self = [self init])) {
		_contactUserVO = contactUserVO;
		_selfieSubmitType = HONSelfieSubmitTypeCreate;
	}
	
	return (self);
}

- (id)initWithUser:(HONTrivialUserVO *)trivialUserVO {
	NSLog(@"%@ - initWithUser", [self description]);
	if ((self = [self init])) {
		_trivialUserVO = trivialUserVO;
		_selfieSubmitType = HONSelfieSubmitTypeCreate;
	}
	
	return (self);
}

- (id)initWithClub:(HONUserClubVO *)clubVO {
	NSLog(@"%@ - initWithClub:[%d] (%@)", [self description], clubVO.clubID, clubVO.clubName);
	if ((self = [self init])) {
		_userClubVO = clubVO;
		_selfieSubmitType = HONSelfieSubmitTypeReply;
	}
	
	return (self);
}


- (id)initAsNewStatusUpdate {
	NSLog(@"%@ - initAsNewChallenge", [self description]);
	if ((self = [self init])) {
		_selfieSubmitType = HONSelfieSubmitTypeCreate;
	}
	
	return (self);
}


#pragma mark - Data Calls
- (void)_uploadPhotos {
	_isUploadComplete = NO;
	_uploadCounter = 0;
	
	_filename = [NSString stringWithFormat:@"%@_%d", [[[HONDeviceIntrinsics sharedInstance] identifierForVendorWithoutSeperators:YES] lowercaseString], (int)[[NSDate date] timeIntervalSince1970]];
	NSLog(@"FILE PREFIX: %@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], _filename);
	
	UIImage *largeImage = [[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:_processedImage toSize:CGSizeMake(852.0, kSnapLargeSize.height * 2.0)] toRect:CGRectMake(106.0, 0.0, kSnapLargeSize.width * 2.0, kSnapLargeSize.height * 2.0)];
	UIImage *tabImage = [[HONImageBroker sharedInstance] cropImage:largeImage toRect:CGRectMake(0.0, 0.0, kSnapTabSize.width * 2.0, kSnapTabSize.height * 2.0)];
	
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
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}
}

- (void)_modifySubmitParamsAndSubmit:(NSArray *)subjectNames {
	if ([subjectNames count] == 0) {
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_noemotions_title", @"No Emotions Selected!")
									message:NSLocalizedString(@"alert_noemotions_msg", @"You need to choose some emotions to make a status update.")
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
		
	} else {
		_isPushing = YES;
		
		NSError *error;
		NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:subjectNames options:0 error:&error]
													 encoding:NSUTF8StringEncoding];
		_submitParams = @{@"user_id"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
						  @"img_url"		: [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], _filename],
						  @"club_id"		: [@"" stringFromInt:(_selfieSubmitType == HONSelfieSubmitTypeReply) ? _userClubVO.clubID : 0],
						  @"owner_id"		: [@"" stringFromInt:(_selfieSubmitType == HONSelfieSubmitTypeReply) ? _userClubVO.ownerID : 0],
						  @"subject"		: @"",
						  @"subjects"		: jsonString,
						  @"challenge_id"	: [@"" stringFromInt:0],
						  @"recipients"		: (_trivialUserVO != nil) ? [@"" stringFromInt:_trivialUserVO.userID] : (_contactUserVO != nil) ? (_contactUserVO.isSMSAvailable) ? _contactUserVO.mobileNumber : _contactUserVO.email : @"",
						  @"api_endpt"		: kAPICreateChallenge};
		NSLog(@"|:|◊≈◊~~◊~~◊≈◊~~◊~~◊≈◊| SUBMIT PARAMS:[%@]", _submitParams);
		
//		[self.navigationController pushViewController:[[HONStatusUpdateSubmitViewController alloc] initWithSubmitParameters:_submitParams] animated:YES];


		if (_selfieSubmitType != HONSelfieSubmitTypeReply) {
			_isPushing = YES;
			[self.navigationController pushViewController:[[HONStatusUpdateSubmitViewController alloc] initWithSubmitParameters:_submitParams] animated:YES];
 
		
		} else {
			[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Submit Reply"
											   withUserClub:_userClubVO];
			
			[[HONAPICaller sharedInstance] submitClubPhotoWithDictionary:_submitParams completion:^(NSDictionary *result) {
				if ([[result objectForKey:@"result"] isEqualToString:@"fail"]) {
					if (_progressHUD == nil)
						_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
					_progressHUD.minShowTime = kHUDTime;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
					_progressHUD.labelText = @"Error!";
					[_progressHUD show:NO];
					[_progressHUD hide:YES afterDelay:kHUDErrorTime];
					_progressHUD = nil;
				}
				
				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
				//[self dismissViewControllerAnimated:YES completion:^(void) {
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUB_TIMELINE" object:@"Y"];
					
				}];
			}];
		}
	}
}

- (void)_cancelUpload {
	_isUploadComplete = NO;
	_uploadCounter = 0;
	
	if (_por1 != nil) {
		[_por1.urlConnection cancel];
		_por1 = nil;
	}
	
	if (_por2 != nil) {
		[_por2.urlConnection cancel];
		_por2 = nil;
	}
}

- (void)_uploadTimeout {
	[self _cancelUpload];
	
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.mode = MBProgressHUDModeCustomView;
	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
	_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
	[_progressHUD show:NO];
	[_progressHUD hide:YES afterDelay:kHUDErrorTime];
	_progressHUD = nil;
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_isBlurred = false;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	
	_previewView = [[HONSelfieCameraPreviewView alloc] initWithFrame:[UIScreen mainScreen].bounds withPreviewImage:_processedImage];
	_previewView.delegate = self;
	[self.view addSubview:_previewView];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	_panGestureRecognizer.enabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:animated:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillAppear:animated];
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:animated:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidAppear:animated];
	
	if (_previewView != nil)
		[_previewView enableSubmitButton];
}

- (void)viewWillDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillDisappear:animated:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillDisappear:animated];
	
	NSLog(@"\n\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=||=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]");
	UIViewController *nextVC = (UIViewController *)[self.navigationController.viewControllers lastObject];
	NSLog(@"\nnextVC:[%@]\nselfVC:[%@]", nextVC.class, self.class);
	NSLog(@"[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=||=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\n\n");
	
	if ([nextVC isKindOfClass:self.class]) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	}
}


#pragma mark - Navigation
- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
//	NSLog(@"[:|:] _goPanGesture:[%@]-=(%@)=-", NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	[super _goPanGesture:gestureRecognizer];
	
	if ([gestureRecognizer velocityInView:self.view].y >= 2000 || [gestureRecognizer velocityInView:self.view].x >= 2000) {
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Dismiss SWIPE"];
		
		[self _cancelUpload];
		[self dismissViewControllerAnimated:YES completion:^(void) {
		}];
	}
	
	if ([gestureRecognizer velocityInView:self.view].x <= -2000 && !_isPushing) {
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Next SWIPE"];
		[self _modifySubmitParamsAndSubmit:[_previewView getSubjectNames]];
	}
}


#pragma mark - UI Presentation
- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
	if (self.imagePickerController != nil)
		self.imagePickerController = nil;
	
	UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
	imagePickerController.view.backgroundColor = [UIColor whiteColor];
	imagePickerController.sourceType = sourceType;
	imagePickerController.delegate = self;
	
	if (sourceType == UIImagePickerControllerSourceTypeCamera) {
		float scale = ([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? ([[HONDeviceIntrinsics sharedInstance] isIOS8]) ? 1.65f : 1.55f : 1.25f;
		
		imagePickerController.showsCameraControls = NO;
		imagePickerController.cameraViewTransform = CGAffineTransformMakeTranslation(24.0, 90.0);
		imagePickerController.cameraViewTransform = CGAffineTransformScale(imagePickerController.cameraViewTransform, scale, scale);
		imagePickerController.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		
		_cameraOverlayView = [[HONCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_cameraOverlayView.delegate = self;
		imagePickerController.cameraOverlayView = _cameraOverlayView;
	}
	
	self.imagePickerController = imagePickerController;
	[self presentViewController:self.imagePickerController animated:YES completion:^(void) {
		if (sourceType == UIImagePickerControllerSourceTypeCamera) {
			[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
		}
	}];
}


#pragma mark - CameraOverlay Delegates
- (void)cameraOverlayViewShowCameraRoll:(HONCameraOverlayView *)cameraOverlayView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Camera Roll"];
	
	self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	
}

- (void)cameraOverlayViewChangeCamera:(HONCameraOverlayView *)cameraOverlayView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Flip Camera"
								   withCameraDevice:self.imagePickerController.cameraDevice];
	
	self.imagePickerController.cameraDevice = (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront) ? UIImagePickerControllerCameraDeviceRear : UIImagePickerControllerCameraDeviceFront;
	
	if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceRear)
		self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
}

- (void)cameraOverlayViewCloseCamera:(HONCameraOverlayView *)cameraOverlayView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Close Camera"
								   withCameraDevice:self.imagePickerController.cameraDevice];
	
	[self _cancelUpload];
//	[_previewView updateProcessedImage:[UIImage imageNamed:@"blank_64"]];
	[self.imagePickerController dismissViewControllerAnimated:YES completion:^(void) {
		self.imagePickerController.delegate = nil;
	}];
}

- (void)cameraOverlayViewTakePhoto:(HONCameraOverlayView *)cameraOverlayView includeFilter:(BOOL)isFiltered {
	_isBlurred = isFiltered;
	[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Camera Step - %@ Photo", (isFiltered) ? @"Blur" : @"Take"]];
	
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", @"Loading…");
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[self.imagePickerController takePicture];
}


#pragma mark - CameraPreviewView Delegates
- (void)cameraPreviewViewShowCamera:(HONSelfieCameraPreviewView *)previewView {
	NSLog(@"[*:*] cameraPreviewViewShowCamera");
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Open Camera"];
	
	_isBlurred = NO;
	[self showImagePickerForSourceType:([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)cameraPreviewViewCancel:(HONSelfieCameraPreviewView *)previewView {
	NSLog(@"[*:*] cameraPreviewViewCancel");
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Cancel"];
	[self _cancelUpload];
	[self dismissViewControllerAnimated:YES completion:^(void) {
	}];
}

- (void)cameraPreviewViewShowInviteContacts:(HONSelfieCameraPreviewView *)previewView {
	NSLog(@"[*:*] cameraPreviewViewShowInviteContacts");
	
	if ([self.delegate respondsToSelector:@selector(selfieCameraViewControllerDidDismissByInviteOverlay:)]) {
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
			[self.delegate selfieCameraViewControllerDidDismissByInviteOverlay:self];
		}];
	}
}

- (void)cameraPreviewViewSubmit:(HONSelfieCameraPreviewView *)previewView withSubjects:(NSArray *)subjects {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Next"];
	
	_isPushing = YES;
	[self _modifySubmitParamsAndSubmit:subjects];
}


#pragma mark - NavigationController Delegates
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	navigationController.navigationBar.barStyle = UIBarStyleDefault;
}


#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	BOOL isSourceImageMirrored = (picker.sourceType == UIImagePickerControllerSourceTypeCamera && picker.cameraDevice == UIImagePickerControllerCameraDeviceFront);
	
	if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
		[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Camera Roll Photo"];
	
	_processedImage = [[HONImageBroker sharedInstance] prepForUploading:[info objectForKey:UIImagePickerControllerOriginalImage]];
	_processedImage = (_isBlurred) ? [_processedImage applyBlurWithRadius:32.0
																tintColor:[UIColor colorWithWhite:0.00 alpha:0.50]
													saturationDeltaFactor:1.0
																maskImage:nil] : _processedImage;
	NSLog(@"PROCESSED IMAGE:[%@]", NSStringFromCGSize(_processedImage.size));
	
	UIView *canvasView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _processedImage.size.width, _processedImage.size.height)];
	[canvasView addSubview:[[UIImageView alloc] initWithImage:_processedImage]];
	
	_processedImage = (isSourceImageMirrored) ? [[HONImageBroker sharedInstance] mirrorImage:[[HONImageBroker sharedInstance] createImageFromView:canvasView]] : [[HONImageBroker sharedInstance] createImageFromView:canvasView];
	[_previewView updateProcessedImage:_processedImage];
	
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	[self dismissViewControllerAnimated:YES completion:^(void) {
		[self _uploadPhotos];
	}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	NSLog(@"imagePickerControllerDidCancel:[%@]", (self.imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) ? @"CAMERA" : @"LIBRARY");
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Camera Step - Cancel Camera Roll"];
	
	_isBlurred = NO;
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
		
		float scale = ([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? ([[HONDeviceIntrinsics sharedInstance] isIOS8]) ? 1.65f : 1.55f : 1.25f;
		
		self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
		self.imagePickerController.showsCameraControls = NO;
		self.imagePickerController.cameraViewTransform = CGAffineTransformMakeTranslation(24.0, 90.0);
		self.imagePickerController.cameraViewTransform = CGAffineTransformScale(self.imagePickerController.cameraViewTransform, scale, scale);
		self.imagePickerController.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		
		_cameraOverlayView = [[HONCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_cameraOverlayView.delegate = self;
		
		self.imagePickerController.cameraOverlayView = _cameraOverlayView;
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
		
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
		[self dismissViewControllerAnimated:YES completion:^(void) {
		}];
	}
}


#pragma mark - AWS Delegates
- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
	NSLog(@"\nAWS didCompleteWithResponse:\n%@", response);
	
	_uploadCounter++;
	_isUploadComplete = (_uploadCounter == 2);
	
	if (_isUploadComplete) {
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		[[HONAPICaller sharedInstance] notifyToCreateImageSizesForPrefix:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsCloudFront], _filename] forBucketType:HONS3BucketTypeSelfies completion:^(NSObject *result) {
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
		}];
	}
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"AWS didFailWithError:\n%@", error);
	
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.mode = MBProgressHUDModeCustomView;
	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
	_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
	[_progressHUD show:NO];
	[_progressHUD hide:YES afterDelay:kHUDErrorTime];
	_progressHUD = nil;
}

@end
