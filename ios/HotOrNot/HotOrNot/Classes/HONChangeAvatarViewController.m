//
//  HONChangeAvatarViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 04.30.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <AWSiOSSDK/S3/AmazonS3Client.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "UIImage+fixOrientation.h"

#import "HONChangeAvatarViewController.h"
#import "HONImagingDepictor.h"
#import "HONAvatarCameraOverlayView.h"

@interface HONChangeAvatarViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, HONAvatarCameraOverlayDelegate, AmazonServiceRequestDelegate>
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) HONAvatarCameraOverlayView *cameraOverlayView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIView *plCameraIrisAnimationView;  // view that animates the opening/closing of the iris
@property (nonatomic, strong) UIImageView *cameraIrisImageView;  // static image of the closed iris
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSTimer *clockTimer;
@property (nonatomic) int clockCounter;
@property (nonatomic) int uploadCounter;
@end

@implementation HONChangeAvatarViewController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didShowViewController:)	name:@"UINavigationControllerDidShowViewControllerNotification" object:nil];
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
- (void)_uploadPhoto:(UIImage *)image {
	_uploadCounter = 0;
	
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
    
	// NSString *currentTimestamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
	NSString *currentTimestamp = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
    
	_filename = [NSString stringWithFormat:@"%@-%@", [HONAppDelegate deviceToken], currentTimestamp];
	NSLog(@"FILENAME: %@/%@.jpg", [HONAppDelegate s3BucketForType:@"avatars"], _filename);
	
	@try {
//		float avatarSize = 200.0;
//		CGSize ratio = CGSizeMake(image.size.width / image.size.height, image.size.height / image.size.width);
		
		UIImage *oImage = image;
		UIImage *largeImage = [HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:image toSize:CGSizeMake(852.0, 1136.0)] toRect:CGRectMake(106.0, 0.0, 640.0, 1136.0)];
//		UIImage *lImage = [HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:image toSize:CGSizeMake(640.0, 854.0)] toRect:CGRectMake(0.0, 202.0, 640.0, 450.0)];
//		UIImage *tImage = (ratio.height >= 1.0) ? [HONImagingDepictor scaleImage:image toSize:CGSizeMake(avatarSize, avatarSize * ratio.height)] : [HONImagingDepictor scaleImage:image toSize:CGSizeMake(avatarSize * ratio.width, avatarSize)];
//		tImage = [HONImagingDepictor cropImage:tImage toRect:CGRectMake(0.0, 0.0, avatarSize, avatarSize)];
		
		
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-avatars"]];
		S3PutObjectRequest *por1 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@Large_640x1136.jpg", _filename] inBucket:@"hotornot-avatars"];
		por1.contentType = @"image/jpeg";
		por1.data = UIImageJPEGRepresentation(largeImage, kSnapJPEGCompress);
		por1.delegate = self;
		[s3 putObject:por1];
		
		S3PutObjectRequest *por2 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_o.jpg", _filename] inBucket:@"hotornot-avatars"];
		por2.contentType = @"image/jpeg";
		por2.data = UIImageJPEGRepresentation(oImage, kSnapJPEGCompress);
		por2.delegate = self;
		[s3 putObject:por2];
		
	} @catch (AmazonClientException *exception) {
		//[[[UIAlertView alloc] initWithTitle:@"Upload Error" message:exception.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
		
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

- (void)_finalizeUser {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 9], @"action",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									[[HONAppDelegate infoForUser] objectForKey:@"name"], @"username",
									[NSString stringWithFormat:@"%@/%@.jpg", [HONAppDelegate s3BucketForType:@"avatars"], _filename], @"imgURL",
									nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
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
				[_cameraOverlayView verifyOverlay:NO];
				[HONAppDelegate writeUserInfo:userResult];
				[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:@"Y"];
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


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor blackColor];
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h@2x" : @"mainBG"]];
	bgImageView.frame = self.view.bounds;
	[self.view addSubview:bgImageView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self _presentCamera];
}


#pragma mark - UI Presentation
- (void)_presentCamera {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		_imagePicker = [[UIImagePickerController alloc] init];
		_imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
		_imagePicker.delegate = self;
		_imagePicker.allowsEditing = NO;
		_imagePicker.cameraOverlayView = nil;
		_imagePicker.navigationBarHidden = YES;
		_imagePicker.toolbarHidden = YES;
		_imagePicker.wantsFullScreenLayout = NO;
		_imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		_imagePicker.navigationBar.barStyle = UIBarStyleDefault;
		_imagePicker.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		
		// this fuck don't work in ios7 right now!!
		_imagePicker.showsCameraControls = NO;
		// ---------------------------------------------------------------------------
		
		_imagePicker.cameraViewTransform = CGAffineTransformScale(_imagePicker.cameraViewTransform, ([HONAppDelegate isRetina5]) ? 1.65f : 1.25f, ([HONAppDelegate isRetina5]) ? 1.65f : 1.25f);
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
		_imagePicker.navigationBar.barStyle = UIBarStyleDefault;
		
		[self.navigationController presentViewController:_imagePicker animated:NO completion:^(void) {
		}];
	}
}

- (void)_showOverlay {
	_cameraOverlayView = [[HONAvatarCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_cameraOverlayView.delegate = self;
	
	[_cameraOverlayView startProgress];
	_clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.6 target:self selector:@selector(_restartProgress) userInfo:nil repeats:YES];
	
	_imagePicker.cameraOverlayView = _cameraOverlayView;
	//_focusTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(autofocusCamera) userInfo:nil repeats:YES];
}

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

- (void)_restartProgress {
	[_cameraOverlayView startProgress];
}

- (void)_takePhoto {
	if (_clockTimer != nil) {
		[_clockTimer invalidate];
		_clockTimer = nil;
	}
	
	[_imagePicker takePicture];
	[_cameraOverlayView takePhoto];
}


#pragma mark - Notifications
- (void)_didShowViewController:(NSNotification *)notification {
	UIView *view = _imagePicker.view;
	_plCameraIrisAnimationView = nil;
	_cameraIrisImageView = nil;
	
	while (view.subviews.count && (view = [view.subviews objectAtIndex:0])) {
		if ([[[view class] description] isEqualToString:@"PLCameraView"]) {
			for (UIView *subview in view.subviews) {
				if ([subview isKindOfClass:[UIImageView class]])
					_cameraIrisImageView = (UIImageView *)subview;
				
				else if ([[[subview class] description] isEqualToString:@"PLCropOverlay"]) {
					for (UIView *subsubview in subview.subviews) {
						if ([[[subsubview class] description] isEqualToString:@"PLCameraIrisAnimationView"])
							_plCameraIrisAnimationView = subsubview;
					}
				}
			}
		}
	}
	_cameraIrisImageView.hidden = YES;
	[_cameraIrisImageView removeFromSuperview];
	[_plCameraIrisAnimationView removeFromSuperview];
	
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UINavigationControllerDidShowViewControllerNotification" object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_irisAnimationDidEnd:) name:@"PLCameraViewIrisAnimationDidEndNotification" object:nil];
}

- (void)_irisAnimationEnded:(NSNotification *)notification {
	_cameraIrisImageView.hidden = NO;
	
	UIView *view = _imagePicker.view;
	while (view.subviews.count && (view = [view.subviews objectAtIndex:0])) {
		if ([[[view class] description] isEqualToString:@"PLCameraView"]) {
			for (UIView *subview in view.subviews) {
				if ([[[subview class] description] isEqualToString:@"PLCropOverlay"]) {
					[subview insertSubview:_plCameraIrisAnimationView atIndex:1];
					_plCameraIrisAnimationView = nil;
					break;
				}
			}
		}
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"PLCameraViewIrisAnimationDidEndNotification" object:nil];
}


#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *image = [[info objectForKey:UIImagePickerControllerOriginalImage] fixOrientation];
	
	if (_imagePicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
		[self dismissViewControllerAnimated:NO completion:^(void) {
			[_cameraOverlayView addPreview:image];
		}];
		
	} else {
		if (_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
			[_cameraOverlayView addPreviewAsFlipped:image];
		
		else
			[_cameraOverlayView addPreview:image];
	}
	
	[self _uploadPhoto:image];
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
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	navigationController.navigationBar.barStyle = UIBarStyleDefault;
}


#pragma mark - CameraOverlayView Delegates
- (void)cameraOverlayViewStartClock:(HONAvatarCameraOverlayView *)cameraOverlayView {
	if (_clockTimer != nil) {
		[_clockTimer invalidate];
		_clockTimer = nil;
	}
	
	[_cameraOverlayView startProgress];
	_clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.6 target:self selector:@selector(_takePhoto) userInfo:nil repeats:NO];
}

- (void)cameraOverlayView:(HONAvatarCameraOverlayView *)cameraOverlayView toggleLongPress:(BOOL)isPressed {
	if (isPressed) {
		[[Mixpanel sharedInstance] track:@"Change Avatar - Long Press"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if (_clockTimer){
			[_clockTimer invalidate];
			_clockTimer = nil;
		}
		
	} else {
		[_cameraOverlayView startProgress];
		_clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.6 target:self selector:@selector(_takePhoto) userInfo:nil repeats:NO];
	}
}

- (void)cameraOverlayViewCloseCamera:(HONAvatarCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Change Avatar - Cancel"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if (_clockTimer){
		[_clockTimer invalidate];
		_clockTimer = nil;
	}
	
	//[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
			_cameraOverlayView = nil;
			_imagePicker.cameraOverlayView = nil;
			_imagePicker = nil;
		}];
	}];
}

- (void)cameraOverlayViewChangeCamera:(HONAvatarCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Change Avatar - Switch Camera"
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

- (void)cameraOverlayViewShowCameraRoll:(HONAvatarCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Change Avatar - Camera Roll"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
	_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)cameraOverlayViewTakePicture:(HONAvatarCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Change Avatar - Take Photo"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[_imagePicker takePicture];
}

- (void)cameraOverlayViewRetake:(HONAvatarCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Change Avatar - Retake"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if (_clockTimer != nil) {
		[_clockTimer invalidate];
		_clockTimer = nil;
	}
	
	[_cameraOverlayView startProgress];
	_clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.6 target:self selector:@selector(_takePhoto) userInfo:nil repeats:NO];
}

- (void)cameraOverlayViewSubmit:(HONAvatarCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Change Avatar - Submit"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self _finalizeUser];
	[_cameraOverlayView verifyOverlay:YES];
}


#pragma mark - AWS Delegates
- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
	//NSLog(@"\nAWS didCompleteWithResponse:\n%@", response);
	
	_uploadCounter++;
	if (_uploadCounter == 2) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	
		[_cameraOverlayView uploadComplete];
		[_cameraOverlayView animateAccept];
		
		NSString *avatarURL = [NSString stringWithFormat:@"%@/%@_o.jpg", [HONAppDelegate s3BucketForType:@"avatars"], _filename];
		[HONImagingDepictor writeImageFromWeb:avatarURL withDimensions:CGSizeMake(612.0, 816.0) withUserDefaultsKey:@"avatar_image"];
	}
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
	//NSLog(@"AWS didFailWithError:\n%@", error);
}

@end
