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

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "UIImage+fixOrientation.h"

#import "HONChallengeCameraViewController.h"
#import "HONImagingDepictor.h"
#import "HONSnapCameraOverlayView.h"
#import "HONCreateChallengePreviewView.h"


@interface HONChallengeCameraViewController () <AmazonServiceRequestDelegate, HONSnapCameraOverlayViewDelegate, HONCreateChallengePreviewViewDelegate>
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) HONSnapCameraOverlayView *cameraOverlayView;
@property (nonatomic, strong) HONCreateChallengePreviewView *previewView;
@property (readonly, nonatomic, assign) HONVolleySubmitType volleySubmitType;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) S3PutObjectRequest *por;
@property (nonatomic, strong) UIImage *rawImage;
@property (nonatomic, strong) UIImage *processedImage;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSDictionary *challengeParams;
@property (nonatomic, strong) UIImageView *submitImageView;
@property (nonatomic) BOOL hasSubmitted;
@property (nonatomic) BOOL isFirstAppearance;
@property (nonatomic) BOOL isMainCamera;
@property (nonatomic) BOOL isFirstCamera;
@property (nonatomic) BOOL isImageUploaded;
@property (nonatomic) int selfieAttempts;
@property (nonatomic, strong) NSTimer *uploadTimer;
@end


@implementation HONChallengeCameraViewController

- (id)initAsNewChallenge {
	NSLog(@"%@ - initAsNewChallenge", [self description]);
	if ((self = [super init])) {
		_volleySubmitType = HONVolleySubmitTypeCreate;
		
//		_subscribers = [NSMutableArray array];
//		_subscriberIDs = [NSMutableArray array];
		_subjectName = @"";
		_selfieAttempts = 0;
		_isFirstAppearance = YES;
	}
	
	return (self);
}

- (id)initAsJoinChallenge:(HONChallengeVO *)challengeVO {
	NSLog(@"%@ - initAsJoinChallenge:[%d] \"%@\"", [self description], challengeVO.challengeID, challengeVO.subjectName);
	if ((self = [super init])) {
		_volleySubmitType = HONVolleySubmitTypeJoin;
		
//		_subscribers = [NSMutableArray array];
//		_subscriberIDs = [NSMutableArray array];
		_challengeVO = challengeVO;
		_subjectName = challengeVO.subjectName;
		_selfieAttempts = 0;
		_isFirstAppearance = YES;
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
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	
	_isImageUploaded = NO;
	_uploadTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(_uploadTimeout) userInfo:nil repeats:NO];
	
	_filename = [NSString stringWithFormat:@"%@-%@_%@", [[HONAppDelegate identifierForVendorWithoutSeperators:YES] lowercaseString], [[HONAppDelegate advertisingIdentifierWithoutSeperators:YES] lowercaseString], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
	NSLog(@"FILE PREFIX: %@/%@", [HONAppDelegate s3BucketForType:@"challenges"], _filename);
	
	@try {
		UIImage *largeImage = [HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:_processedImage toSize:CGSizeMake(852.0, 1136.0)] toRect:CGRectMake(106.0, 0.0, 640.0, 1136.0)];
		
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-challenges"]];
		_por = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@%@", _filename, kSnapLargeSuffix] inBucket:@"hotornot-challenges"];
		_por.delegate = self;
		_por.contentType = @"image/jpeg";
		_por.data = UIImageJPEGRepresentation(largeImage, kSnapJPEGCompress);
		[s3 putObject:_por];
				
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
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], (_volleySubmitType == HONVolleySubmitTypeJoin) ? kAPIJoinChallenge : kAPIChallenges);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:(_volleySubmitType == HONVolleySubmitTypeCreate) ? kAPICreateChallenge : kAPIJoinChallenge parameters:_challengeParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_dlFailed", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			NSDictionary *challengeResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@ %@", [[self class] description], challengeResult);
			
			if (_isImageUploaded) {
				[UIView animateWithDuration:0.5 animations:^(void) {
					_submitImageView.alpha = 0.0;
				} completion:^(BOOL finished) {
					[_submitImageView removeFromSuperview];
					_submitImageView = nil;
				}];
			}
			
			if ([[challengeResult objectForKey:@"result"] isEqualToString:@"fail"]) {
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
				if (_isImageUploaded) {
					[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
						[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:@"Y"];
						[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
						
						if (_isFirstCamera && [HONAppDelegate switchEnabledForKey:@"volley_share"])
							[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SELF" object:(_rawImage.size.width >= 1936.0) ? [HONImagingDepictor scaleImage:_rawImage toSize:CGSizeMake(960.0, 1280.0)] : _rawImage];
					}];
				}
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}

- (void)_finalizeUpload {
	
	NSString *urlPath = [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:@"challenges"], _filename];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							urlPath, @"imgURL",
							nil];
	
	NSLog(@"PARAMS:[%@]", params);
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIProcessChallengeImage);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIProcessChallengeImage parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
//			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
				[self.imagePickerController dismissViewControllerAnimated:YES completion:^(void) {
					_previewView = (_isMainCamera) ? [[HONCreateChallengePreviewView alloc] initWithFrame:[UIScreen mainScreen].bounds withSubject:_subjectName withImage:_processedImage] : [[HONCreateChallengePreviewView alloc] initWithFrame:[UIScreen mainScreen].bounds withSubject:_subjectName withMirroredImage:_processedImage];
					_previewView.delegate = self;
					_previewView.isFirstCamera = _isFirstCamera;
					_previewView.isJoinChallenge = (_volleySubmitType == HONVolleySubmitTypeJoin);
					[_previewView showKeyboard];
					
					[self.view addSubview:_previewView];
				}];
			}
		}
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
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
        imagePickerController.showsCameraControls = NO;
		float scale = ([HONAppDelegate isRetina4Inch]) ? 1.55f : 1.25f;
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
	_isImageUploaded = NO;
	[_por.urlConnection cancel];
	_por = nil;
}

- (void)_uploadTimeout {
	if (_uploadTimer != nil) {
		[_uploadTimer invalidate];
		_uploadTimer = nil;
	}
	
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
	[self.imagePickerController dismissViewControllerAnimated:NO completion:^(void) {
		///[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
	}];
}

- (void)cameraOverlayViewTakePhoto:(HONSnapCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Create Volley - Take Photo"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
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
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
}

- (void)previewViewSubmit:(HONCreateChallengePreviewView *)previewView {
	[[Mixpanel sharedInstance] track:@"Create Volley - Submit"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	_hasSubmitted = NO;
	int friend_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"friend_total"] intValue];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++friend_total] forKey:@"friend_total"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if ([[HONAppDelegate friendsList] count] == 1 && friend_total == 0) {
		UIAlertView *alertView = [[UIAlertView alloc]
								  initWithTitle:@"Find Friends"
								  message:@"Volley is more fun with friends! Find some now?"
								  delegate:self
								  cancelButtonTitle:@"Yes"
								  otherButtonTitles:@"No", nil];
		[alertView setTag:2];
		[alertView show];
		
	} else {
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   [[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									   [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:@"challenges"], _filename], @"imgURL",
									   [NSString stringWithFormat:@"%d", (_challengeVO == nil) ? 0 : _challengeVO.challengeID], @"challengeID",
									   _subjectName, @"subject", nil];

		_challengeParams = [params copy];
		NSLog(@"PARAMS:[%@]", _challengeParams);
		
		[self _submitChallenge];
	}
}


#pragma mark - AWS Delegates
- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
	//NSLog(@"\nAWS didCompleteWithResponse:\n%@", response);
	
	if (_uploadTimer != nil) {
		[_uploadTimer invalidate];
		_uploadTimer = nil;
	}
	
	_isImageUploaded = YES;;
	if (_submitImageView != nil) {
		[UIView animateWithDuration:0.5 animations:^(void) {
			_submitImageView.alpha = 0.0;
		} completion:^(BOOL finished) {
			[_submitImageView removeFromSuperview];
			_submitImageView = nil;
		}];
	}
	
	[_previewView uploadComplete];
	[self _finalizeUpload];
	
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
		
	if (_hasSubmitted) {
//		if (_isFirstCamera) {
//			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Share Volley"
//																message:@"Great! You have just completed your first Volley update, would you like to share Volley with friends on Instagram?"
//															   delegate:self
//													  cancelButtonTitle:@"No"
//													  otherButtonTitles:@"Yes", nil];
//			[alertView show];
//		
//		} else {
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:@"Y"];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
				
				if (_isFirstCamera && [HONAppDelegate switchEnabledForKey:@"share_volley"])
					[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SELF" object:(_rawImage.size.width >= 1936.0) ? [HONImagingDepictor scaleImage:_rawImage toSize:CGSizeMake(960.0, 1280.0)] : _rawImage];
			}];
//		}
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
}


#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	_rawImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	if (_rawImage.imageOrientation != 0)
		_rawImage = [_rawImage fixOrientation];
	
	NSLog(@"RAW IMAGE:[%@]", NSStringFromCGSize(_rawImage.size));
	
	// image is wider than tall (800x600)
	if (_rawImage.size.width > _rawImage.size.height) {
		_isMainCamera = (_rawImage.size.height > 1000);
		_processedImage = [HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:_rawImage toSize:CGSizeMake(1707.0, 1280.0)] toRect:CGRectMake(374.0, 0.0, 960.0, 1280.0)];//_processedImage = [HONImagingDepictor scaleImage:_rawImage toSize:CGSizeMake(1280.0, 960.0)];
		
	// image is taller than wide (600x800)
	} else if (_rawImage.size.width < _rawImage.size.height) {
		_isMainCamera = (_rawImage.size.width > 1000);
		_processedImage = [HONImagingDepictor scaleImage:_rawImage toSize:CGSizeMake(960.0, 1280.0)];
	}
	
	NSLog(@"PROCESSED IMAGE:[%@][%f]", NSStringFromCGSize(_processedImage.size), [HONImagingDepictor totalLuminance:_processedImage]);
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		_previewView = (_isMainCamera) ? [[HONCreateChallengePreviewView alloc] initWithFrame:[UIScreen mainScreen].bounds withSubject:_subjectName withImage:_processedImage] : [[HONCreateChallengePreviewView alloc] initWithFrame:[UIScreen mainScreen].bounds withSubject:_subjectName withMirroredImage:_processedImage];
		_previewView.delegate = self;
		_previewView.isFirstCamera = _isFirstCamera;
		_previewView.isJoinChallenge = (_volleySubmitType == HONVolleySubmitTypeJoin);
		[_previewView showKeyboard];
		
		[_cameraOverlayView submitStep:_previewView];
	}
	
	[self _uploadPhotos];
	
	
	int friend_total = 0;
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"friend_total"]) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:friend_total] forKey:@"friend_total"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	} else {
		friend_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"friend_total"] intValue];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++friend_total] forKey:@"friend_total"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	NSLog(@"imagePickerControllerDidCancel");
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	
	else {
		[self dismissViewControllerAnimated:YES completion:^(void) {
			///[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
		}];
	}
}


@end
