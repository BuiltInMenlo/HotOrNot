//
//  HONChangeAvatarViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 04.30.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <AWSiOSSDK/S3/AmazonS3Client.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "ImageFilter.h"
#import "MBProgressHUD.h"
#import "UIImage+fixOrientation.h"

#import "HONChangeAvatarViewController.h"
#import "HONImagingDepictor.h"
#import "HONAvatarCameraOverlayView.h"


@interface HONChangeAvatarViewController () <HONAvatarCameraOverlayDelegate>
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) HONAvatarCameraOverlayView *cameraOverlayView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic) int tintIndex;
@property (nonatomic) int uploadCounter;
@property (nonatomic) int selfieAttempts;
@property (nonatomic) BOOL isFirstAppearance;
@end

@implementation HONChangeAvatarViewController

- (id)init {
	if ((self = [super init])) {
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
- (void)_uploadPhotos:(UIImage *)image {
	_uploadCounter = 0;
    
	_filename = [NSString stringWithFormat:@"%@_%@-%d", [[HONAppDelegate identifierForVendorWithoutSeperators:YES] lowercaseString], [[HONAppDelegate advertisingIdentifierWithoutSeperators:YES] lowercaseString], (int)[[NSDate date] timeIntervalSince1970]];
	
	UIImage *largeImage = [HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:image toSize:CGSizeMake(852.0, kSnapLargeSize.height * 2.0)] toRect:CGRectMake(106.0, 0.0, kSnapLargeSize.width * 2.0, kSnapLargeSize.height * 2.0)];
	UIImage *tabImage = [HONImagingDepictor cropImage:largeImage toRect:CGRectMake(0.0, 0.0, kSnapTabSize.width * 2.0, kSnapTabSize.height * 2.0)];
	
	NSLog(@"FILE PREFIX: %@/%@", [HONAppDelegate s3BucketForType:@"avatars"], _filename);
	
	S3PutObjectRequest *por1 = [[S3PutObjectRequest alloc] initWithKey:[_filename stringByAppendingString:kSnapLargeSuffix] inBucket:@"hotornot-avatars"];
	por1.data = UIImageJPEGRepresentation(largeImage, [HONAppDelegate compressJPEGPercentage]);
	por1.contentType = @"image/jpeg";
	
	S3PutObjectRequest *por2 = [[S3PutObjectRequest alloc] initWithKey:[_filename stringByAppendingString:kSnapTabSuffix] inBucket:@"hotornot-avatars"];
	por2.data = UIImageJPEGRepresentation(tabImage, [HONAppDelegate compressJPEGPercentage] * 0.85);
	por2.contentType = @"image/jpeg";
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UPLOAD_IMAGES_TO_AWS" object:@{@"url"	: [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:@"avatars"], [_filename stringByAppendingString:kSnapLargeSuffix]],
																								@"pors"	: @[por1, por2]}];
	[_cameraOverlayView uploadComplete];
	[self _finalizeUser];
}

- (void)_finalizeUser {
	NSDictionary *params = @{@"action"		: [NSString stringWithFormat:@"%d", 9],
							 @"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"username"	: [[HONAppDelegate infoForUser] objectForKey:@"username"],
							 @"imgURL"		: [[NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:@"avatars"], _filename] stringByAppendingString:kSnapLargeSuffix]};
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"], params);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_updateFail", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			if (![[userResult objectForKey:@"result"] isEqualToString:@"fail"]) {
				if (_progressHUD != nil) {
					[_progressHUD hide:YES];
					_progressHUD = nil;
				}
				
				[HONAppDelegate writeUserInfo:userResult];
				
				[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"skipped_selfie"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
//				[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
					[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
					[self.navigationController dismissViewControllerAnimated:YES completion:^(void) {}];
//				}];
				
			} else {
				if (_progressHUD == nil)
					_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = NSLocalizedString(@"hud_submitFailed", nil);
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:kHUDErrorTime];
				_progressHUD = nil;
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
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


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (_isFirstAppearance) {
		_isFirstAppearance = NO;
	
		[self _presentCamera];
	}
}


#pragma mark - UI Presentation
- (void)_presentCamera {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		_imagePicker = [[UIImagePickerController alloc] init];
		_imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
		_imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
		_imagePicker.delegate = self;
		
		_imagePicker.showsCameraControls = NO;
		_imagePicker.cameraViewTransform = CGAffineTransformScale(_imagePicker.cameraViewTransform, ([HONAppDelegate isRetina4Inch]) ? 1.65f : 1.25f, ([HONAppDelegate isRetina4Inch]) ? 1.65f : 1.25f);
		_imagePicker.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		_imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		
		_cameraOverlayView = [[HONAvatarCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_cameraOverlayView.delegate = self;
		_imagePicker.cameraOverlayView = _cameraOverlayView;
		
		[self.navigationController presentViewController:_imagePicker animated:NO completion:^(void) {}];
		
	} else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		_imagePicker = [[UIImagePickerController alloc] init];
		_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		_imagePicker.delegate = self;
		_imagePicker.allowsEditing = NO;
		_imagePicker.navigationBarHidden = YES;
		_imagePicker.toolbarHidden = YES;
//		_imagePicker.wantsFullScreenLayout = NO;
		_imagePicker.navigationBar.barStyle = UIBarStyleDefault;
		
		[self.navigationController presentViewController:_imagePicker animated:NO completion:^(void) {
		}];
	}
}


#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *processedImage = [HONImagingDepictor prepForUploading:[info objectForKey:UIImagePickerControllerOriginalImage]];
	
	NSLog(@"PROCESSED IMAGE:[%@]", NSStringFromCGSize(processedImage.size));
	UIView *canvasView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, processedImage.size.width, processedImage.size.height)];
	[canvasView addSubview:[[UIImageView alloc] initWithImage:processedImage]];
	
	UIView *overlayTintView = [[UIView alloc] initWithFrame:canvasView.frame];
	overlayTintView.backgroundColor = [[HONAppDelegate colorsForOverlayTints] objectAtIndex:_tintIndex];
	[canvasView addSubview:overlayTintView];
	
	processedImage = [HONImagingDepictor createImageFromView:canvasView];
	
	[self _uploadPhotos:processedImage];
	[self dismissViewControllerAnimated:NO completion:^(void) {}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
		picker.showsCameraControls = NO;
		picker.cameraViewTransform = CGAffineTransformMakeTranslation(24.0, 90.0);
		picker.cameraViewTransform = CGAffineTransformScale(_imagePicker.cameraViewTransform, ([HONAppDelegate isRetina4Inch]) ? 1.55f : 1.25f, ([HONAppDelegate isRetina4Inch]) ? 1.55f : 1.25f);
		picker.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		
		_cameraOverlayView = [[HONAvatarCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_cameraOverlayView.delegate = self;
		_imagePicker.cameraOverlayView = _cameraOverlayView;
	
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
		}];
	}
}


#pragma mark - NavigationController Delegates
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	navigationController.navigationBar.barStyle = UIBarStyleDefault;
	
//	if (viewController.navigationItem.hidesBackButton || viewController.navigationItem.rightBarButtonItem == nil) {
//        [viewController.navigationController.navigationBar setNeedsLayout];
//    }
}


#pragma mark - CameraOverlayView Delegates
- (void)cameraOverlayViewCloseCamera:(HONAvatarCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Change Avatar - Cancel"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
		
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
		[self.navigationController dismissViewControllerAnimated:YES completion:^(void) {
			_cameraOverlayView = nil;
			_imagePicker.cameraOverlayView = nil;
			_imagePicker = nil;
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
		}];
	}];
}

- (void)cameraOverlayViewChangeCamera:(HONAvatarCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Change Avatar - Switch Camera"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	if (_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
		_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
		_imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		//overlay.flashButton.hidden = NO;
		
	} else {
		_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
		//overlay.flashButton.hidden = YES;
	}
}

- (void)cameraOverlayViewShowCameraRoll:(HONAvatarCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Change Avatar - Camera Roll"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
	_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)cameraOverlayViewTakePicture:(HONAvatarCameraOverlayView *)cameraOverlayView withTintIndex:(int)tintIndex {
	[[Mixpanel sharedInstance] track:@"Change Avatar - Take Photo"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d", tintIndex], @"tint", nil]];
	
	_tintIndex = tintIndex;
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Loading…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[_imagePicker takePicture];
}

- (void)cameraOverlayViewRetake:(HONAvatarCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Change Avatar - Retake"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
}

- (void)cameraOverlayViewSubmit:(HONAvatarCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Change Avatar - Submit"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	[self _finalizeUser];
}

@end
