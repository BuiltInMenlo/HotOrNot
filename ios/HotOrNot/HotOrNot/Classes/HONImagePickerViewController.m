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
#import "HONHeaderView.h"
#import "HONAddChallengersViewController.h"
#import "HONChallengerPickerViewController.h"

const CGFloat kFocusInterval = 0.5f;

@interface HONImagePickerViewController () <AmazonServiceRequestDelegate, HONCameraOverlayViewDelegate>
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) NSString *challengerName;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSString *fbID;
@property (nonatomic) int submitAction;
@property (nonatomic) HONUserVO *userVO;
@property (nonatomic) int uploadCounter;
@property (nonatomic) BOOL needsChallenger;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic) BOOL isFirstAppearance;
@property (nonatomic, strong) NSTimer *focusTimer;
@property (nonatomic, strong) HONCameraOverlayView *cameraOverlayView;
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
		_needsChallenger = YES;
		_isFirstAppearance = YES;
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithUser:(HONUserVO *)userVO {
	if ((self = [super init])) {
		_subjectName = [HONAppDelegate rndDefaultSubject];
		_userVO = userVO;
		_needsChallenger = NO;
		_submitAction = 9;
		_isFirstAppearance = YES;
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithUser:(HONUserVO *)userVO withSubject:(NSString *)subject {
	if ((self = [super init])) {
		_needsChallenger = NO;
		_subjectName = subject;
		_userVO = userVO;
		_needsChallenger = NO;
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
		_needsChallenger = NO;
		_isFirstAppearance = YES;
		
		_needsChallenger = NO;
	}
	
	return (self);
}

- (id)initWithSubject:(NSString *)subject {
	if ((self = [super init])) {
		_subjectName = subject;
		_submitAction = 1;
		_needsChallenger = YES;
		_isFirstAppearance = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(_didShowViewController:)
																	name:@"UINavigationControllerDidShowViewControllerNotification"
																 object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_notificationReceived:) name:nil object:nil];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (NO);
}

- (void)_registerNotifications {
//	[[NSNotificationCenter defaultCenter] addObserver:self
//														  selector:@selector(_notificationReceived:)
//																name:nil
//															 object:nil];
	
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
			NSLog(@"ImagePickerViewController AFNetworking %@", challengeResult);
			
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
				
				if (_uploadCounter == 3) {
					if (_imagePicker.parentViewController != nil) {
						[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
							[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
							[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
						}];
						
					} else {
						[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
						[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
					}
				}
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
	NSLog(@"loadView");
	[super loadView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:NSLocalizedString(@"header_create", nil)];
	//[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(3.0, 0.0, 64.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backButton];
}

- (void)viewDidLoad {
	NSLog(@"viewDidLoad");
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"viewDidAppear");
	[super viewDidAppear:animated];
		
	if (_isFirstAppearance) {
		_isFirstAppearance = NO;
		
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
//			_imagePicker.navigationBar.tintColor = [UIColor colorWithRed:0.039 green:0.396 blue:0.647 alpha:1.0];
			
			[self.navigationController presentViewController:_imagePicker animated:NO completion:^(void) {
			}];
		}
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	NSLog(@"viewDidDisappear");
	[super viewDidDisappear:animated];
	
	_isFirstAppearance = YES;
}


#pragma mark - UI Presentation
- (void)_removeIris {
	_cameraIrisImageView.hidden = YES;
	[_cameraIrisImageView removeFromSuperview];
	
	_plCameraIrisAnimationView.hidden = YES;
	[_plCameraIrisAnimationView removeFromSuperview];
}

- (void)_restoreIris {
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

- (void)_showOverlay {
	_challengerName = @"";
	if (_challengeVO != nil)
		_challengerName = _challengeVO.creatorName;
	
	if (_userVO != nil)
		_challengerName = _userVO.username;
	
	_cameraOverlayView = [[HONCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds withSubject:_subjectName withUsername:_challengerName withAvatar:(_challengeVO != nil) ? _challengeVO.creatorAvatar : _userVO.imageURL];
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
- (void)_goBack {
	
	if (_focusTimer != nil) {
		[_focusTimer invalidate];
		_focusTimer = nil;
	}
	
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:^(void) {
		if (_imagePicker != nil)
			_imagePicker = nil;
		
		_cameraOverlayView = nil;
		;
	}];
}


#pragma mark - Notifications
- (void)_notificationReceived:(NSNotification *)notification {
	//NSLog(@"_notificationReceived:[%@]", [notification name]);
}


- (void)_previewStarted:(NSNotification *)notification {
	[self _removeIris];
	
	_focusTimer = [NSTimer scheduledTimerWithTimeInterval:kFocusInterval target:self selector:@selector(_autofocusCamera) userInfo:nil repeats:YES];
}


#pragma mark - NavigationController Delegates
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	navigationController.navigationBar.barStyle = UIBarStyleDefault;
	
	_cameraIrisImageView = [[viewController.view subviews] objectAtIndex:1];
	_plCameraIrisAnimationView = [[[[viewController.view subviews] objectAtIndex:2] subviews] objectAtIndex:0];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	[self _removeIris];
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

- (void)cameraOverlayViewSubmitChallenge:(HONCameraOverlayView *)cameraOverlayView {
	NSLog(@"cameraOverlayViewSubmitChallenge [%@]", _challengerName);
	
	[[Mixpanel sharedInstance] track:@"Create Snap - Submit"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[params setObject:[NSString stringWithFormat:@"%d", _userVO.userID] forKey:@"challengerID"];
	[params setObject:[NSString stringWithFormat:@"https://hotornot-challenges.s3.amazonaws.com/%@", _filename] forKey:@"imgURL"];
	[params setObject:[NSString stringWithFormat:@"%d", (_challengeVO == nil) ? 7 : _submitAction] forKey:@"action"];
	[params setObject:_subjectName forKey:@"subject"];
	[params setObject:_challengerName forKey:@"username"];
	
	if (_challengeVO != nil)
		[params setObject:[NSString stringWithFormat:@"%d", _challengeVO.challengeID] forKey:@"challengeID"];
	
	if (_fbID != nil)
		[params setObject:_fbID forKey:@"fbID"];
	
	[self _submitChallenge:params];
}

- (void)cameraOverlayViewChangeSubject:(HONCameraOverlayView *)cameraOverlayView subject:(NSString *)subjectName {
	[[Mixpanel sharedInstance] track:@"Create Snap - Edit Hashtag"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  subjectName, @"subject", nil]];
	
	_subjectName = subjectName;
}

- (void)cameraOverlayViewPreviewBack:(HONCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Create Snap - Back to Camera"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
}

- (void)cameraOverlayViewAddChallengers:(HONCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Create Snap - Add Friends"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[_imagePicker presentViewController:[[HONAddChallengersViewController alloc] init] animated:YES completion:nil];
}


#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	if (_focusTimer != nil) {
		[_focusTimer invalidate];
		_focusTimer = nil;
	}
	
	//_subjectName = _cameraOverlayView.subjectName;
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	NSLog(@"ORIENTATION:[%d]", image.imageOrientation);
	if (image.imageOrientation != 0)
		image = [image fixOrientation];
		
	// image is wider than tall (800x600)
	if (image.size.width > image.size.height) {
//		float offset = image.size.height * (image.size.height / image.size.width);
//		image = [HONImagingDepictor cropImage:image toRect:CGRectMake(offset * 0.5, 0.0, offset, image.size.height)];
		
		float offset = (image.size.width - image.size.height) * 0.5;
		_challangeImage = [HONImagingDepictor cropImage:image toRect:CGRectMake(offset, 0.0, image.size.height, image.size.height)];
	
		// image is taller than wide (600x800)
	} else if (image.size.width < image.size.height) {
		float offset = (image.size.height - image.size.width) * 0.5;
		_challangeImage = [HONImagingDepictor cropImage:image toRect:CGRectMake(0.0, offset, image.size.width, image.size.width)];
	
		// image is square
	} else {
		_challangeImage = image;
	}
	
//	if (image.size.height / image.size.width == 1.5) {
//		float offset = image.size.height - (image.size.width * kSnapRatio);
//		image = [HONImagingDepictor cropImage:image toRect:CGRectMake(0.0, offset * 0.5, image.size.width, (image.size.width * kSnapRatio))];
//	}
	 
//	_challangeImage = image;
	
	[self _uploadPhoto:_challangeImage];
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[self dismissViewControllerAnimated:YES completion:nil];
	[self.navigationController pushViewController:[[HONChallengerPickerViewController alloc] initWithSubject:_subjectName imagePrefix:_filename previewImage:_challangeImage userVO:_userVO challengeVO:_challengeVO] animated:NO];
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
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:nil];
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
	}
}

//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//	navigationController.navigationBar.barStyle = UIBarStyleDefault;
//}


#pragma mark - AWS Delegates
- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
	//NSLog(@"\nAWS didCompleteWithResponse:\n%@", response);
	
	_uploadCounter++;
	if (_uploadCounter == 3) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
	//NSLog(@"AWS didFailWithError:\n%@", error);
}

@end
