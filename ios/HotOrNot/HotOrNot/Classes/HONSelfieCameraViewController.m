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
#import "HONInviteContactsViewController.h"
#import "HONTrivialUserVO.h"


@interface HONSelfieCameraViewController () <HONSelfieCameraOverlayViewDelegate, HONSelfieCameraPreviewViewDelegate, AmazonServiceRequestDelegate>
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) HONSelfieCameraOverlayView *cameraOverlayView;
@property (nonatomic, strong) HONSelfieCameraPreviewView *previewView;
@property (nonatomic, assign, readonly) HONSelfieCameraSubmitType selfieSubmitType;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) HONMessageVO *messageVO;
@property (nonatomic, strong) HONUserClubVO *userClubVO;
@property (nonatomic, strong) NSArray *recipients;
@property (nonatomic, strong) S3PutObjectRequest *por1;
@property (nonatomic, strong) S3PutObjectRequest *por2;
@property (nonatomic, strong) UIImage *processedImage;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSDictionary *submitParams;
@property (nonatomic, strong) UIImageView *submitImageView;
@property (nonatomic) BOOL hasSubmitted;
@property (nonatomic) BOOL isFirstAppearance;
@property (nonatomic) BOOL isUploadComplete;
@property (nonatomic) int uploadCounter;
@property (nonatomic) int selfieAttempts;
@end


@implementation HONSelfieCameraViewController
@synthesize delegate = _delegate;

- (id)init {
	if ((self = [super init])) {
		_selfieAttempts = 0;
		_isFirstAppearance = YES;
		
		[[HONStickerAssistant sharedInstance] retrieveStickersWithPakType:HONStickerPakTypeFree completion:nil];
		[[HONStickerAssistant sharedInstance] retrieveStickersWithPakType:HONStickerPakTypeInviteBonus completion:nil];
	}
	
	return (self);
}


- (id)initWithClub:(HONUserClubVO *)clubVO {
	NSLog(@"%@ - initWithClub:[%d] (%@)", [self description], clubVO.clubID, clubVO.clubName);
	if ((self = [self init])) {
		_userClubVO = clubVO;
		_selfieSubmitType = (_userClubVO != nil) ? HONSelfieCameraSubmitTypeReplyClub : HONSelfieCameraSubmitTypeCreateClub;
	}
	
	return (self);
}


- (id)initAsNewChallenge {
	NSLog(@"%@ - initAsNewChallenge", [self description]);
	if ((self = [self init])) {
		_selfieSubmitType = HONSelfieCameraSubmitTypeCreateChallenge;
	}
	
	return (self);
}

- (id)initAsJoinChallenge:(HONChallengeVO *)challengeVO {
	NSLog(@"%@ - initAsJoinChallenge:[%d] \"%@\"", [self description], challengeVO.challengeID, [challengeVO.subjectNames firstObject]);
	if ((self = [self init])) {
		_selfieSubmitType = HONSelfieCameraSubmitTypeReplyChallenge;
		
		_challengeVO = challengeVO;
	}
	
	return (self);
}

- (id)initAsNewMessageWithRecipients:(NSArray *)recipients {
	NSLog(@"%@ - initAsNewMessageWithRecipients:[%@]", [self description], recipients);
	if ((self = [self init])) {
		_selfieSubmitType = HONSelfieCameraSubmitTypeCreateMessage;
		_recipients = recipients;
	}
	
	return (self);
}

- (id)initAsMessageReply:(HONMessageVO *)messageVO withRecipients:(NSArray *)recipients {
	NSLog(@"%@ - initAsMessageReply:[%@]", [self description], messageVO.dictionary);
	if ((self = [self init])) {
		_selfieSubmitType = HONSelfieCameraSubmitTypeReplyMessage;
		
		_messageVO = messageVO;
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
	
	_filename = [NSString stringWithFormat:@"%@_%d", [[[HONDeviceIntrinsics sharedInstance] identifierForVendorWithoutSeperators:YES] lowercaseString], (int)[[NSDate date] timeIntervalSince1970]];
	NSLog(@"FILE PREFIX: %@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], _filename);
	
	UIImage *largeImage = [[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:_processedImage toSize:CGSizeMake(852.0, kSnapLargeSize.height * 2.0)] toRect:CGRectMake(106.0, 0.0, kSnapLargeSize.width * 2.0, kSnapLargeSize.height * 2.0)];
	UIImage *tabImage = [[HONImageBroker sharedInstance] cropImage:largeImage toRect:CGRectMake(0.0, 0.0, kSnapTabSize.width * 2.0, kSnapTabSize.height * 2.0)];
	
//	[[HONAPICaller sharedInstance] uploadPhotosToS3:@[UIImageJPEGRepresentation(largeImage, [HONAppDelegate compressJPEGPercentage]), UIImageJPEGRepresentation(tabImage, [HONAppDelegate compressJPEGPercentage] * 0.85)] intoBucket:@"hotornot-challenges" withFilename:_filename completion:^(NSObject *result) {
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
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}
}

- (void)_submitClubPhoto {
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
	
	[[HONAPICaller sharedInstance] submitClubPhotoWithDictionary:_submitParams completion:^(NSDictionary *result) {
		[self _submitCompleted:result];
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
	
	[[HONAPICaller sharedInstance] submitNewMessageWithDictionary:_submitParams completion:^(NSDictionary *result) {
		[self _submitCompleted:result];
	}];
}


- (void)_submitCompleted:(NSDictionary *)result {
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
		
	} else {
		_hasSubmitted = YES;
		
		if (_isUploadComplete) {
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
			
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
				NSLog(@"_selfieSubmitType:[%d]", _selfieSubmitType);
				
				if (_selfieSubmitType == HONSelfieCameraSubmitTypeCreateMessage)
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
	self.view.backgroundColor = [UIColor blackColor];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
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
	
	if (_isFirstAppearance) {
		_isFirstAppearance = NO;
		[self showImagePickerForSourceType:([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [[NSString string] stringFromBOOL:animated]);
	[super viewDidAppear:animated];
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
	if (self.imagePickerController != nil)
		self.imagePickerController = nil;
	
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
		if (sourceType == UIImagePickerControllerSourceTypeCamera) {
			[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
			self.imagePickerController.cameraOverlayView = _cameraOverlayView;
		}
	}];
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
	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
	_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
	[_progressHUD show:NO];
	[_progressHUD hide:YES afterDelay:kHUDErrorTime];
	_progressHUD = nil;
}


#pragma mark - CameraOverlay Delegates
- (void)cameraOverlayViewShowCameraRoll:(HONSelfieCameraOverlayView *)cameraOverlayView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Selfie - Camera Roll"];
	
	self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

}

- (void)cameraOverlayViewChangeCamera:(HONSelfieCameraOverlayView *)cameraOverlayView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Selfie - Flip Camera"
								   withCameraDevice:self.imagePickerController.cameraDevice];
	
	self.imagePickerController.cameraDevice = (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront) ? UIImagePickerControllerCameraDeviceRear : UIImagePickerControllerCameraDeviceFront;
	
	if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceRear)
		self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
}

- (void)cameraOverlayViewCloseCamera:(HONSelfieCameraOverlayView *)cameraOverlayView {
	NSLog(@"cameraOverlayViewCloseCamera");
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Selfie - Cancel"];
	
	[self _cancelUpload];
	[self.imagePickerController dismissViewControllerAnimated:NO completion:^(void) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		
		if ([self.delegate respondsToSelector:@selector(selfieCameraViewController:didDismissByCanceling:)])
			[self.delegate selfieCameraViewController:self didDismissByCanceling:YES];
		
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
	}];
}

- (void)cameraOverlayViewTakePhoto:(HONSelfieCameraOverlayView *)cameraOverlayView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Selfie - Camera Step 2 Take Photo"];
	
//	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
//	_progressHUD.labelText = @"Loading…";
//	_progressHUD.mode = MBProgressHUDModeIndeterminate;
//	_progressHUD.minShowTime = kHUDTime;
//	_progressHUD.taskInProgress = YES;
	
	[self.imagePickerController takePicture];
}


#pragma mark - CameraPreviewView Delegates
- (void)cameraPreviewViewBackToCamera:(HONSelfieCameraPreviewView *)previewView {
	NSLog(@"cameraPreviewViewBackToCamera");
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Selfie - Retake Photo"];
	[self _cancelUpload];
	
	NSLog(@"SOURCE:[%d]", self.imagePickerController.sourceType);
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
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
			self.imagePickerController.cameraOverlayView = _cameraOverlayView;
		}];
	}
	
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[self presentViewController:self.imagePickerController animated:NO completion:^(void) {
		}];
	}
	
//	if (self.imagePickerController.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
//		[self presentViewController:self.imagePickerController animated:NO completion:^(void) {
//		}];
//	}
}

- (void)cameraPreviewViewSubmit:(HONSelfieCameraPreviewView *)previewView withSubjects:(NSArray *)subjects {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Volley - Submit"];
	
	_hasSubmitted = NO;
	self.view.backgroundColor = [UIColor whiteColor];
	
	NSError *error;
	NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:subjects options:0 error:&error]
												 encoding:NSUTF8StringEncoding];
	
	_submitParams = @{@"user_id"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
					  @"img_url"		: [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], _filename],
					  @"club_id"		: [@"" stringFromInt:(_selfieSubmitType == HONSelfieCameraSubmitTypeReplyClub) ? _userClubVO.clubID : 0],
					  @"owner_id"		: [@"" stringFromInt:(_selfieSubmitType == HONSelfieCameraSubmitTypeReplyClub) ? _userClubVO.ownerID : 0],
					  @"subject"		: @"",
					  @"subjects"		: jsonString,
					  @"challenge_id"	: [@"" stringFromInt:0],
					  @"recipients"		: @"",
					  @"api_endpt"		: kAPICreateChallenge};
	
	NSLog(@"SUBMIT PARAMS:[%@]", _submitParams);
	//[self _submitClubPhoto];
	
	_isFirstAppearance = YES;
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Selfie - Camera Step 3 Club Selected"];
	[self.navigationController pushViewController:[[HONSelfieCameraSubmitViewController alloc] initWithSubmitParameters:_submitParams] animated:NO];
	
//	if (self.imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
//		[self.imagePickerController dismissViewControllerAnimated:NO completion:^(void) {
//			NSLog(@"---CLUB SELECT---CAMERA");
//			_isFirstAppearance = YES;
//			[self.navigationController pushViewController:[[HONSelfieCameraSubmitViewController alloc] initWithSubmitParameters:_submitParams] animated:NO];
//		}];
//		
//	} else {
//		NSLog(@"---CLUB SELECT---LIB");
//		_isFirstAppearance = YES;
//		[[HONAnalyticsParams sharedInstance] trackEvent:@"Create Selfie - Camera Step 3 Club Selected"];
//		[self.navigationController pushViewController:[[HONSelfieCameraSubmitViewController alloc] initWithSubmitParameters:_submitParams] animated:NO];
//	}
}

- (void)cameraPreviewViewShowInviteContacts:(HONSelfieCameraPreviewView *)previewView {
	HONUserClubVO *vo = [HONUserClubVO clubWithDictionary:[[[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:@"owned"] firstObject]];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:vo viewControllerPushed:NO]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
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
	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
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
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	_processedImage = [[HONImageBroker sharedInstance] prepForUploading:[info objectForKey:UIImagePickerControllerOriginalImage]];
	NSLog(@"PROCESSED IMAGE:[%@]", NSStringFromCGSize(_processedImage.size));
	
	UIView *canvasView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _processedImage.size.width, _processedImage.size.height)];
	[canvasView addSubview:[[UIImageView alloc] initWithImage:_processedImage]];
	
	_processedImage = (isSourceImageMirrored) ? [[HONImageBroker sharedInstance] mirrorImage:[[HONImageBroker sharedInstance] createImageFromView:canvasView]] : [[HONImageBroker sharedInstance] createImageFromView:canvasView];
	_previewView = [[HONSelfieCameraPreviewView alloc] initWithFrame:[UIScreen mainScreen].bounds withPreviewImage:_processedImage];
	_previewView.delegate = self;
    
	
	[self dismissViewControllerAnimated:NO completion:^(void) {
		[self.view addSubview:_previewView];
	}];
//
//	HONViewController *emotionsViewConteroller = [[HONViewController alloc] init];
//    emotionsViewConteroller.view = _previewView;
//    [self.navigationController pushViewController:emotionsViewConteroller animated:YES];
	
	
//	if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
//		[_cameraOverlayView submitStep:_previewView];
//	
//	} else {
//		[self dismissViewControllerAnimated:NO completion:^(void) {
//			[self.view addSubview:_previewView];
//		}];
//	}
	
	[self _uploadPhotos];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	NSLog(@"imagePickerControllerDidCancel");
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
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
		
		self.imagePickerController.cameraOverlayView = _cameraOverlayView;
		
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		
		if ([self.delegate respondsToSelector:@selector(selfieCameraViewController:didDismissByCanceling:)])
			[self.delegate selfieCameraViewController:self didDismissByCanceling:YES];
		
		[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
	}
}


@end
