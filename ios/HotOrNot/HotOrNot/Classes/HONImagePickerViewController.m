//
//  HONImagePickerViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.09.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AWSiOSSDK/S3/AmazonS3Client.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "UIImage+fixOrientation.h"

#import "HONImagePickerViewController.h"
#import "HONAppDelegate.h"
#import "HONImagingDepictor.h"
#import "HONCameraOverlayView.h"
#import "HONAddChallengersViewController.h"
#import "HONChallengerPickerViewController.h"
#import "HONCreateChallengePreviewView.h"
#import "HONUserVO.h"
#import "HONContactUserVO.h"


const CGFloat kFocusInterval = 0.5f;

@interface HONImagePickerViewController () <AmazonServiceRequestDelegate, HONCameraOverlayViewDelegate, HONAddChallengersDelegate, HONCreateChallengePreviewViewDelegate>
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) NSString *challengerName;
@property (nonatomic, strong) NSMutableArray *addContacts;
@property (nonatomic, strong) NSMutableArray *addFollowing;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSString *fbID;
@property (nonatomic) int submitAction;
@property (nonatomic) HONUserVO *userVO;
@property (nonatomic) int uploadCounter;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic) BOOL isFirstAppearance;
@property (nonatomic, strong) NSTimer *focusTimer;
@property (nonatomic, strong) HONCameraOverlayView *cameraOverlayView;
@property (nonatomic, strong) HONCreateChallengePreviewView *previewView;
@property (nonatomic, strong) UIView *plCameraIrisAnimationView;  // view that animates the opening/closing of the iris
@property (nonatomic, strong) UIImageView *cameraIrisImageView;  // static image of the closed iris
@property (nonatomic, strong) UIImage *challangeImage;
@end

@implementation HONImagePickerViewController

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor blackColor];
		_subjectName = [HONAppDelegate rndDefaultSubject];
		_submitAction = 1;
		_challengerName = @"";
		_isFirstAppearance = YES;
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithUser:(HONUserVO *)userVO {
	if ((self = [super init])) {
		_subjectName = [HONAppDelegate rndDefaultSubject];
		_userVO = userVO;
		_challengerName = userVO.username;
		_submitAction = 9;
		_isFirstAppearance = YES;
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithSubject:(NSString *)subject {
	if ((self = [super init])) {
		_subjectName = subject;
		_submitAction = 1;
		_challengerName = @"";
		_isFirstAppearance = YES;
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithUser:(HONUserVO *)userVO withSubject:(NSString *)subject {
	if ((self = [super init])) {
		_subjectName = subject;
		_userVO = userVO;
		_challengerName = userVO.username;
		_submitAction = 9;
		_isFirstAppearance = YES;
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		_challengeVO = vo;
		_fbID = vo.creatorFB;
		_subjectName = vo.subjectName;
		_submitAction = 4;
		_challengerName = vo.challengerName;
		_isFirstAppearance = YES;
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"PLCameraControllerPreviewStartedNotification" object:nil];
}

- (BOOL)shouldAutorotate {
	return (NO);
}

- (void)_registerNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self
														  selector:@selector(_notificationReceived:)
																name:nil
															 object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
														  selector:@selector(_previewStarted:)
																name:@"PLCameraControllerPreviewStartedNotification"
															 object:nil];
}


#pragma mark - Data Calls
- (void)_uploadPhoto:(UIImage *)image {
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	_uploadCounter = 0;
	
	_filename = [NSString stringWithFormat:@"%@_%@", [HONAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
	NSLog(@"FILE PREFIX: https://hotornot-challenges.s3.amazonaws.com/%@", _filename);
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_uploadPhoto", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	@try {
		UIImage *lImage = [HONImagingDepictor scaleImage:image toSize:CGSizeMake(kSnapLargeDim * 2.0, kSnapLargeDim * 2.0)];
		UIImage *mImage = [HONImagingDepictor scaleImage:image toSize:CGSizeMake(kSnapMediumDim * 2.0, kSnapMediumDim * 2.0)];
		UIImage *tImage = [HONImagingDepictor scaleImage:image toSize:CGSizeMake(kSnapThumbDim * 2.0, kSnapThumbDim * 2.0)];
		
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-challenges"]];
		S3PutObjectRequest *por1 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_t.jpg", _filename] inBucket:@"hotornot-challenges"];
		por1.contentType = @"image/jpeg";
		por1.data = UIImageJPEGRepresentation(tImage, kSnapJPEGCompress);
		por1.delegate = self;
		[s3 putObject:por1];
		
		S3PutObjectRequest *por2 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_m.jpg", _filename] inBucket:@"hotornot-challenges"];
		por2.contentType = @"image/jpeg";
		por2.data = UIImageJPEGRepresentation(mImage, kSnapJPEGCompress);
		por2.delegate = self;
		[s3 putObject:por2];
		
		S3PutObjectRequest *por3 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_l.jpg", _filename] inBucket:@"hotornot-challenges"];
		por3.contentType = @"image/jpeg";
		por3.data = UIImageJPEGRepresentation(lImage, kSnapJPEGCompress);
		por3.delegate = self;
		[s3 putObject:por3];
		
	} @catch (AmazonClientException *exception) {
		//[[[UIAlertView alloc] initWithTitle:@"Upload Error" message:exception.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}
}

- (void)_submitChallenge:(NSMutableDictionary *)params {
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_submit", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"ImagePickerViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_dlFailed", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
			
		} else {
			NSDictionary *challengeResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//NSLog(@"ImagePickerViewController AFNetworking %@", challengeResult);
			
			[_progressHUD hide:YES];
			_progressHUD = nil;
			
			if ([[challengeResult objectForKey:@"result"] isEqualToString:@"fail"]) {
				if (_progressHUD == nil)
					_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = NSLocalizedString(@"hud_usernameNotFound", nil);
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:1.5];
				_progressHUD = nil;
				
			} else {
				[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:nil];
				
				if (_imagePicker.parentViewController != nil) {
					[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
						[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
					}];
					
				} else
					[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"ImagePickerViewController AFNetworking %@", [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	_addContacts = [NSMutableArray array];
	_addFollowing = [NSMutableArray array];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
		
	if (_isFirstAppearance) {
		_isFirstAppearance = NO;
		
		[self _showCamera];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	//NSLog(@"viewDidDisappear");
}


#pragma mark - UI Presentation
- (void)_removeIris {
	if (_imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
		_cameraIrisImageView.hidden = YES;
		[_cameraIrisImageView removeFromSuperview];
		
		_plCameraIrisAnimationView.hidden = YES;
		[_plCameraIrisAnimationView removeFromSuperview];
	}
}

- (void)_restoreIris {
	if (_imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
		_cameraIrisImageView.hidden = NO;
		[self.view insertSubview:_cameraIrisImageView atIndex:1];
		
		_plCameraIrisAnimationView.hidden = NO;
		
		UIView *view = self.view;
		while (view.subviews.count && (view = [view.subviews objectAtIndex:2])) {
			if ([[[view class] description] isEqualToString:@"PLCropOverlay"]) {
				[view insertSubview:_plCameraIrisAnimationView atIndex:0];
				_plCameraIrisAnimationView = nil;
				break;
			}
		}
	}
}

- (void)_showCamera {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_SOURCE_CAMERA" object:nil];
		
		_imagePicker = [[UIImagePickerController alloc] init];
		_imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
		_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
		_imagePicker.delegate = self;
		_imagePicker.allowsEditing = NO;
		_imagePicker.cameraOverlayView = nil;
		_imagePicker.navigationBarHidden = YES;
		_imagePicker.toolbarHidden = YES;
		_imagePicker.wantsFullScreenLayout = NO;
		_imagePicker.showsCameraControls = NO;
		_imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		_imagePicker.cameraViewTransform = CGAffineTransformScale(_imagePicker.cameraViewTransform, ([HONAppDelegate isRetina5]) ? 1.5f : 1.25f, ([HONAppDelegate isRetina5]) ? 1.5f : 1.25f);
		
		[self.navigationController presentViewController:_imagePicker animated:NO completion:^(void) {
			[self _showOverlay];
		}];
		
	} else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		_imagePicker = [[UIImagePickerController alloc] init];
		_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		_imagePicker.delegate = self;
		_imagePicker.allowsEditing = NO;
		_imagePicker.navigationBarHidden = YES;
		_imagePicker.toolbarHidden = YES;
		_imagePicker.wantsFullScreenLayout = NO;
//		_imagePicker.navigationBar.tintColor = [UIColor colorWithRed:0.039 green:0.396 blue:0.647 alpha:1.0];
		
		[self.navigationController presentViewController:_imagePicker animated:NO completion:^(void) {
		}];
	}
}

- (void)_showOverlay {
	_cameraOverlayView = [[HONCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds withSubject:_subjectName withUsername:_challengerName];
	_cameraOverlayView.delegate = self;
	
	_imagePicker.cameraOverlayView = _cameraOverlayView;
}

- (void)_autofocusCamera {
	NSArray *devices = [AVCaptureDevice devices];
	NSError *error;
	
	for (AVCaptureDevice *device in devices) {
		if ([device position] == AVCaptureDevicePositionBack) {
			[device lockForConfiguration:&error];
			
			if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
            device.focusMode = AVCaptureFocusModeAutoFocus;
			
			[device unlockForConfiguration];
		}
	}
}


#pragma mark - Navigation


#pragma mark - Notifications
- (void)_notificationReceived:(NSNotification *)notification {
	//NSLog(@"_notificationReceived:[%@]", [notification name]);
	
//	if ([[notification name] isEqualToString:@"UINavigationControllerDidShowViewControllerNotification"])
//		_isFirstAppearance = YES;
}


- (void)_previewStarted:(NSNotification *)notification {
	[self _removeIris];
	
	_focusTimer = [NSTimer scheduledTimerWithTimeInterval:kFocusInterval target:self selector:@selector(_autofocusCamera) userInfo:nil repeats:YES];
}


#pragma mark - NavigationController Delegates
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	//NSLog(@"navigationController:[%@] willShowViewController:[%@]", [navigationController description], [viewController description]);
	
	navigationController.navigationBar.barStyle = UIBarStyleDefault;
	
	if (_imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
		_cameraIrisImageView = [[viewController.view subviews] objectAtIndex:1];
		_plCameraIrisAnimationView = [[[[viewController.view subviews] objectAtIndex:2] subviews] objectAtIndex:0];
		
		
//		NSLog(@"VC:view:subviews\n %@\n\n", [[viewController view] subviews]);
//		
//		UIView *uiView = [[[viewController view] subviews] objectAtIndex:0];
//		NSLog(@"VC:view:UIView:subviews\n %@\n\n", [uiView subviews]);
//			UIView *PLCameraPreviewView = [[uiView subviews] objectAtIndex:0];
//			NSLog(@"VC:view:PLCameraPreviewView:subviews\n %@\n\n", [PLCameraPreviewView subviews]);
//			
//		UIView *uiImageView = [[[viewController view] subviews] objectAtIndex:1];
//		NSLog(@"VC:view:UIImageView:subviews\n %@\n\n", [uiImageView subviews]);
//			
//		UIView *PLCropOverlay = [[[viewController view] subviews] objectAtIndex:2];
//		NSLog(@"VC:view:PLCropOverlay:subviews\n %@\n\n", [PLCropOverlay subviews]);
//			UIView *PLCameraIrisAnimationView = [[PLCropOverlay subviews] objectAtIndex:0];
//			NSLog(@"VC:view:PLCropOverlay:PLCameraIrisAnimationView:subviews\n %@\n\n", [PLCameraIrisAnimationView subviews]);
	}
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	//NSLog(@"navigationController:[%@] didShowViewController:[%@]", [navigationController description], [viewController description]);
	
	
//	NSLog(@"VC:view:subviews\n %@\n\n", [[viewController view] subviews]);
//	
//	UIView *uiView = [[[viewController view] subviews] objectAtIndex:0];
//	NSLog(@"VC:view:UIView:subviews\n %@\n\n", [uiView subviews]);
//	UIView *PLCameraPreviewView = [[uiView subviews] objectAtIndex:0];
//	NSLog(@"VC:view:PLCameraPreviewView:subviews\n %@\n\n", [PLCameraPreviewView subviews]);
//	
//	UIView *uiImageView = [[[viewController view] subviews] objectAtIndex:1];
//	NSLog(@"VC:view:UIImageView:subviews\n %@\n\n", [uiImageView subviews]);
//	
//	UIView *PLCropOverlay = [[[viewController view] subviews] objectAtIndex:2];
//	NSLog(@"VC:view:PLCropOverlay:subviews\n %@\n\n", [PLCropOverlay subviews]);
//	UIView *PLCameraIrisAnimationView = [[PLCropOverlay subviews] objectAtIndex:0];
//	NSLog(@"VC:view:PLCropOverlay:PLCameraIrisAnimationView:subviews\n %@\n\n", [PLCameraIrisAnimationView subviews]);
//	UIView *PLCropOverlayBottomBar = [[PLCropOverlay subviews] objectAtIndex:1];
//	NSLog(@"VC:view:PLCropOverlay:PLCropOverlayBottomBar:subviews\n %@\n\n", [PLCropOverlayBottomBar subviews]);
	
	[self _removeIris];
}


#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	if (_focusTimer != nil) {
		[_focusTimer invalidate];
		_focusTimer = nil;
	}
	
	UIImage *rawImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	if (rawImage.imageOrientation != 0)
		rawImage = [rawImage fixOrientation];
	
	NSLog(@"RAW IMAGE:[%@]", NSStringFromCGSize(rawImage.size));
	
	// image is wider than tall (800x600)
	if (rawImage.size.width > rawImage.size.height) {
		float offset = (rawImage.size.width - rawImage.size.height) * 0.5;
		_challangeImage = [HONImagingDepictor cropImage:rawImage toRect:CGRectMake(offset, 0.0, rawImage.size.height, rawImage.size.height)];
		
		// image is taller than wide (600x800)
	} else if (rawImage.size.width < rawImage.size.height) {
		float offset = (rawImage.size.height - rawImage.size.width) * 0.5;
		_challangeImage = [HONImagingDepictor cropImage:rawImage toRect:CGRectMake(0.0, offset, rawImage.size.width, rawImage.size.width)];
		
		// image is square
	} else {
		_challangeImage = rawImage;
	}
	
	if (_imagePicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
		[self dismissViewControllerAnimated:NO completion:^(void) {
			_previewView = [[HONCreateChallengePreviewView alloc] initWithFrame:self.view.frame withSubject:_subjectName withImage:_challangeImage];
			_previewView.delegate = self;
			[self.view addSubview:_previewView];
		}];
		
	} else {
		[self dismissViewControllerAnimated:NO completion:^(void) {
			if (_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
				_previewView = [[HONCreateChallengePreviewView alloc] initWithFrame:self.view.frame withSubject:_subjectName withMirroredImage:rawImage];
			
			else
				_previewView = [[HONCreateChallengePreviewView alloc] initWithFrame:self.view.frame withSubject:_subjectName withImage:rawImage];
			
			_previewView.delegate = self;
			[self.view addSubview:_previewView];
		}];
	}
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	[self _uploadPhoto:_challangeImage];
	
	
	//	[self.navigationController pushViewController:[[HONChallengerPickerViewController alloc] initWithSubject:_subjectName imagePrefix:_filename previewImage:_challangeImage userVO:_userVO challengeVO:_challengeVO] animated:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		_imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		_imagePicker.cameraOverlayView = nil;
		_imagePicker.navigationBarHidden = YES;
		_imagePicker.toolbarHidden = YES;
		_imagePicker.wantsFullScreenLayout = NO;
		_imagePicker.showsCameraControls = NO;
		_imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		_imagePicker.navigationBar.barStyle = UIBarStyleDefault;
		
		[self _showOverlay];
		
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
	}
}


#pragma mark - CameraOverlay Delegates
- (void)cameraOverlayViewTakePicture:(HONCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Create Snap - Take Photo"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if (_focusTimer != nil) {
		[_focusTimer invalidate];
		_focusTimer = nil;
	}
	
	[_imagePicker takePicture];
}

- (void)cameraOverlayViewShowCameraRoll:(HONCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Create Snap - Camera Roll"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
	_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)cameraOverlayViewChangeCamera:(HONCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Create Snap - Switch Camera"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if (_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
		_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
		//overlay.flashButton.hidden = NO;
	
	} else {
		_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
		//overlay.flashButton.hidden = YES;
	}
}

- (void)cameraOverlayViewCloseCamera:(HONCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Create Snap - Cancel"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if (_focusTimer != nil) {
		[_focusTimer invalidate];
		_focusTimer = nil;
	}
	
	[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
	}];
}

- (void)cameraOverlayViewAddChallengers:(HONCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Create Snap - Add Friends"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	HONAddChallengersViewController *addChallengersViewController = [[HONAddChallengersViewController alloc] initWithFollowersSelected:[_addFollowing copy] contactsSelected:[_addContacts copy]];
	addChallengersViewController.delegate = self;
	[_imagePicker presentViewController:addChallengersViewController animated:YES completion:nil];
}


#pragma mark - AddFriends Delegate
- (void)addChallengers:(HONAddChallengersViewController *)viewController selectFollowing:(NSArray *)following forAppending:(BOOL)isAppend {
	if (isAppend) {
		[_addFollowing addObjectsFromArray:following];
	
	} else {
		NSMutableArray *removeVOs = [NSMutableArray array];
		for (HONUserVO *vo in _addFollowing) {
			for (HONUserVO *dropVO in following) {
				if (vo.userID == dropVO.userID) {
					[removeVOs addObject:vo];
					continue;
				}
			}
		}
		
		[_addFollowing removeObjectsInArray:removeVOs];
		removeVOs = nil;
	}
	
	NSLog(@"following:%@", following);
	NSLog(@"_addFollowing:%@", _addFollowing);
	
	NSMutableArray *usernames = [NSMutableArray array];
	for (HONUserVO *vo in _addFollowing)
		[usernames addObject:[NSString stringWithFormat:@"@%@", vo.username]];
	
	for (HONContactUserVO *vo in _addContacts)
		[usernames addObject:vo.fullName];
	
	
	if ([_addFollowing count] > 0)
		_challengerName = [_addFollowing objectAtIndex:0];
	
	
	if ([_addFollowing count] == 0 && (_challengeVO != nil || _userVO != nil))
		_submitAction = 1;
	
	[_cameraOverlayView updateChallengers:[usernames copy]];
}

- (void)addChallengers:(HONAddChallengersViewController *)viewController selectContacts:(NSArray *)contacts forAppending:(BOOL)isAppend {
	if (isAppend)
		[_addContacts addObjectsFromArray:contacts];
	
	else  {
		NSMutableArray *removeVOs = [NSMutableArray array];
		for (HONContactUserVO *vo in _addContacts) {
			for (HONContactUserVO *dropVO in contacts) {
				if ([vo.fullName isEqualToString:dropVO.fullName]) {
					[removeVOs addObject:vo];
					continue;
				}
			}
		}
		
		[_addContacts removeObjectsInArray:removeVOs];
		removeVOs = nil;
	}
	
	
	NSMutableArray *usernames = [NSMutableArray array];
	for (HONUserVO *vo in _addFollowing)
		[usernames addObject:[NSString stringWithFormat:@"@%@", vo.username]];
	
	for (HONContactUserVO *vo in _addContacts)
		[usernames addObject:vo.fullName];
	
	[_cameraOverlayView updateChallengers:[usernames copy]];
}


#pragma mark - PreviewView Delegates
- (void)previewViewBackToCamera:(HONCreateChallengePreviewView *)previewView {
	[self _showCamera];
}

- (void)previewView:(HONCreateChallengePreviewView *)previewView changeSubject:(NSString *)subject {
	NSLog(@"previewView:changeSubject:[%@]", subject);
	_subjectName = subject;
	
	[[Mixpanel sharedInstance] track:@"Camera Preview - Change Hashtag"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 _subjectName, @"subject", nil]];
	
	
	
	// accepting, now submit new against username w/ subject
	if (_submitAction == 4 && (_challengeVO != nil && ![_subjectName isEqualToString:_challengeVO.subjectName])) {
		_submitAction = 7;
		_challengerName = (_challengeVO.creatorID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? _challengeVO.challengerName : _challengeVO.creatorName;
		//_challengeVO = nil;
	}
}

- (void)previewViewSubmit:(HONCreateChallengePreviewView *)previewView {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											 [[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
											 [NSString stringWithFormat:@"https://hotornot-challenges.s3.amazonaws.com/%@", _filename], @"imgURL",
											 [NSString stringWithFormat:@"%d", _submitAction], @"action",
											 _subjectName, @"subject",
											 _challengerName, @"username", nil];
	
	if (_challengeVO != nil)
		[params setObject:[NSString stringWithFormat:@"%d", _challengeVO.challengeID] forKey:@"challengeID"];
	
	if (_userVO != nil)
		[params setObject:[NSString stringWithFormat:@"%d", _userVO.userID] forKey:@"challengerID"];
	
	if (_fbID != nil)
		[params setObject:_fbID forKey:@"fbID"];
	
	NSLog(@"PARAMS:[%@]", params);
	[self _submitChallenge:params];
}


#pragma mark - AWS Delegates
- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
	//NSLog(@"\nAWS didCompleteWithResponse:\n%@", response);
	
	_uploadCounter++;
	if (_uploadCounter == 3) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
		
		//[_cameraOverlayView enablePreview];
		[_previewView showKeyboard];
	}
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
	//NSLog(@"AWS didFailWithError:\n%@", error);
}

@end
