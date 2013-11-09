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


@interface HONChangeAvatarViewController () <HONAvatarCameraOverlayDelegate>// AmazonServiceRequestDelegate>
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) HONAvatarCameraOverlayView *cameraOverlayView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIView *plCameraIrisAnimationView;  // view that animates the opening/closing of the iris
@property (nonatomic, strong) UIImageView *cameraIrisImageView;  // static image of the closed iris
@property (nonatomic, strong) NSString *filename;
//@property (nonatomic, strong) S3PutObjectRequest *por1;
//@property (nonatomic, strong) S3PutObjectRequest *por2;
@property (nonatomic) int uploadCounter;
@property (nonatomic) int selfieAttempts;
@property (nonatomic) BOOL isFirstAppearance;
@end

@implementation HONChangeAvatarViewController

- (id)init {
	if ((self = [super init])) {
		_selfieAttempts = 0;
		_isFirstAppearance = YES;
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didShowViewController:)	name:@"UINavigationControllerDidShowViewControllerNotification" object:nil];
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
	
//	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
    
	_filename = [NSString stringWithFormat:@"%@_%@-%d", [[HONAppDelegate identifierForVendorWithoutSeperators:YES] lowercaseString], [[HONAppDelegate identifierForVendorWithoutSeperators:YES] lowercaseString], (int)[[NSDate date] timeIntervalSince1970]];
	
	UIImage *largeImage = [HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:image toSize:CGSizeMake(852.0, kSnapLargeSize.height * 2.0)] toRect:CGRectMake(106.0, 0.0, kSnapLargeSize.width * 2.0, kSnapLargeSize.height * 2.0)];
	UIImage *tabImage = [HONImagingDepictor cropImage:largeImage toRect:CGRectMake(0.0, 0.0, kSnapTabSize.width * 2.0, kSnapTabSize.height * 2.0)];
	
	NSLog(@"FILE PREFIX: %@/%@", [HONAppDelegate s3BucketForType:@"avatars"], _filename);
	
	S3PutObjectRequest *por1 = [[S3PutObjectRequest alloc] initWithKey:[_filename stringByAppendingString:kSnapLargeSuffix] inBucket:@"hotornot-avatars"];
	por1.data = UIImageJPEGRepresentation(largeImage, kSnapJPEGCompress);
	por1.contentType = @"image/jpeg";
	
	S3PutObjectRequest *por2 = [[S3PutObjectRequest alloc] initWithKey:[_filename stringByAppendingString:kSnapTabSuffix] inBucket:@"hotornot-avatars"];
	por2.data = UIImageJPEGRepresentation(tabImage, kSnapJPEGCompress * 0.80);
	por2.contentType = @"image/jpeg";
	
	NSDictionary *uploadDict = @{@"url"		: [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:@"avatars"], [_filename stringByAppendingString:kSnapLargeSuffix]],
								 @"pors"	: @[por1, por2]};
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UPLOAD_AVATAR_TO_AWS" object:uploadDict];
	[_cameraOverlayView uploadComplete];
	[self _finalizeUser];
	
//	@try {
//		_por1 = [[S3PutObjectRequest alloc] initWithKey:[_filename stringByAppendingString:kSnapLargeSuffix] inBucket:@"hotornot-avatars"];
//		_por1.contentType = @"image/jpeg";
//		_por1.data = UIImageJPEGRepresentation(largeImage, kSnapJPEGCompress);
//		_por1.delegate = self;
//		[s3 putObject:_por1];
//		
//		_por2 = [[S3PutObjectRequest alloc] initWithKey:[_filename stringByAppendingString:kSnapTabSuffix] inBucket:@"hotornot-avatars"];
//		_por2.contentType = @"image/jpeg";
//		_por2.data = UIImageJPEGRepresentation(tabImage, kSnapJPEGCompress * 0.80);
//		_por2.delegate = self;
//		[s3 putObject:_por2];
//				
//	} @catch (AmazonClientException *exception) {
//		//[[[UIAlertView alloc] initWithTitle:@"Upload Error" message:exception.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//		
//		if (_progressHUD == nil)
//			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
//		
//		_progressHUD.minShowTime = kHUDTime;
//		_progressHUD.mode = MBProgressHUDModeCustomView;
//		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
//		_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
//		[_progressHUD show:NO];
//		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
//		_progressHUD = nil;
//	}
}

- (void)_finalizeUser {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 9], @"action",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									[[HONAppDelegate infoForUser] objectForKey:@"username"], @"username",
									[NSString stringWithFormat:@"%@/%@%@", [HONAppDelegate s3BucketForType:@"avatars"], _filename, kSnapLargeSuffix], @"imgURL",
									nil];
	
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
				
				[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
					[self.navigationController dismissViewControllerAnimated:YES completion:^(void) {
					}];
				}];
				
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

//- (void)_finalizeUpload {
//	NSDictionary *params = @{@"imgURL"	: [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:@"avatars"], [_filename stringByAppendingString:kSnapLargeSuffix]]};
//	
//	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIProcessUserImage);
//	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
//	[httpClient postPath:kAPIProcessUserImage parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//		NSError *error = nil;
//		if (error != nil) {
//			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
//			
//			if (_progressHUD == nil)
//				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
//			_progressHUD.minShowTime = kHUDTime;
//			_progressHUD.mode = MBProgressHUDModeCustomView;
//			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
//			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
//			[_progressHUD show:NO];
//			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
//			_progressHUD = nil;
//			
//		} else {
//			//NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//			//VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
//		}
//		
//		if (_progressHUD != nil) {
//			[_progressHUD hide:YES];
//			_progressHUD = nil;
//		}
//		
//	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
//		
//		if (_progressHUD == nil)
//			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
//		_progressHUD.minShowTime = kHUDTime;
//		_progressHUD.mode = MBProgressHUDModeCustomView;
//		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
//		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
//		[_progressHUD show:NO];
//		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
//		_progressHUD = nil;
//	}];
//}



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
		
		_cameraOverlayView = [[HONAvatarCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_cameraOverlayView.delegate = self;
		
		_imagePicker.cameraOverlayView = _cameraOverlayView;
		
		[self.navigationController presentViewController:_imagePicker animated:NO completion:^(void) {
		}];
		
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
	UIImage *image = [[info objectForKey:UIImagePickerControllerOriginalImage] fixOrientation];
		
	if (image.imageOrientation != 0)
		image = [image fixOrientation];
	
	NSLog(@"RAW IMAGE:[%@]", NSStringFromCGSize(image.size));
	
	UIImage *processedImage;
	
	// image is wider than tall (800x600)
	if (image.size.width > image.size.height) {
//		_isMainCamera = (_rawImage.size.height > 1000);
		processedImage = [HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:image toSize:CGSizeMake(1707.0, 1280.0)] toRect:CGRectMake(374.0, 0.0, 960.0, 1280.0)];//_processedImage = [HONImagingDepictor scaleImage:_rawImage toSize:CGSizeMake(1280.0, 960.0)];
		
		// image is taller than wide (600x800)
	} else if (image.size.width < image.size.height) {
//		_isMainCamera = (_rawImage.size.width > 1000);
		processedImage = [HONImagingDepictor scaleImage:image toSize:CGSizeMake(960.0, 1280.0)];
	
	} else
		processedImage = [UIImage imageWithCGImage:[image CGImage]];
	
	if ([HONImagingDepictor totalLuminance:image] > kMinLuminosity) {
		
		
		double lum = [HONImagingDepictor totalLuminance:processedImage];
		NSLog(@"PROCESSED IMAGE:[%@][%f]", NSStringFromCGSize(processedImage.size), lum);
//		NSDictionary *attribs = [[NSUserDefaults standardUserDefaults] objectForKey:@"filter_vals"];
//		processedImage = (lum <= [[attribs objectForKey:@"luminosity"] floatValue]) ? [[[processedImage brightness:[[attribs objectForKey:@"d_brightness"] floatValue]] contrast:[[attribs objectForKey:@"d_contrast"] floatValue]] saturate:[[attribs objectForKey:@"d_saturation"] floatValue]] : [[[processedImage brightness:[[attribs objectForKey:@"l_brightness"] floatValue]] contrast:[[attribs objectForKey:@"l_contrast"] floatValue]] saturate:[[attribs objectForKey:@"l_saturation"] floatValue]];
		
		
//		CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
//		CIDetector *detctor = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
//		NSArray *features = [detctor featuresInImage:ciImage];
//		
//		if ([features count] > 0 || [HONAppDelegate isPhoneType5s]) {
			[self _uploadPhotos:processedImage];
//			
//		} else {
//			[[Mixpanel sharedInstance] track:@"Change Avatar - Face Detection Failed"
//								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
//											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
//			
//			[[[UIAlertView alloc] initWithTitle:@"NO SELFIE DETECTED!"
//										message:@"Please retry taking your selfie photo, good lighting helps!"
//									   delegate:self
//							  cancelButtonTitle:@"OK"
//							  otherButtonTitles:nil] show];
//			
//			[_progressHUD hide:YES];
//			_progressHUD = nil;
//			
//			[_cameraOverlayView resetControls];
//		}
	
	} else {
		[[Mixpanel sharedInstance] track:@"Change Avatar - Photo Luminosity Failed"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
		[[[UIAlertView alloc] initWithTitle:@"Light Level Too Low!"
									message:@"You need better lighting in your photo."
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		
		[_progressHUD hide:YES];
		_progressHUD = nil;
		
		[_cameraOverlayView resetControls];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		_imagePicker = [[UIImagePickerController alloc] init];
		_imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
		_imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
		_imagePicker.delegate = self;
		
		_imagePicker.showsCameraControls = NO;
		_imagePicker.cameraViewTransform = CGAffineTransformScale(_imagePicker.cameraViewTransform, ([HONAppDelegate isRetina4Inch]) ? 1.65f : 1.25f, ([HONAppDelegate isRetina4Inch]) ? 1.65f : 1.25f);
		_imagePicker.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		
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
}


#pragma mark - CameraOverlayView Delegates
- (void)cameraOverlayViewCloseCamera:(HONAvatarCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Change Avatar - Cancel"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
		
	//[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
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

- (void)cameraOverlayViewTakePicture:(HONAvatarCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Change Avatar - Take Photo"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
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


//#pragma mark - AWS Delegates
//- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
//	//NSLog(@"\nAWS didCompleteWithResponse:\n%@", response);
//	
//	_uploadCounter++;
//	if (_uploadCounter == 2) {
//		[_progressHUD hide:YES];
//		_progressHUD = nil;
//	
//		[_cameraOverlayView uploadComplete];
//		//[_cameraOverlayView animateAccept];
//		
//		NSString *avatarURL = [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:@"avatars"], [_filename stringByAppendingString:kSnapLargeSuffix]];
//		[HONImagingDepictor writeImageFromWeb:avatarURL withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
//		[self _finalizeUpload];
//		[self _finalizeUser];
//	}
//}
//
//- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
//	//NSLog(@"AWS didFailWithError:\n%@", error);
//}

@end
