//
//  HONRegisterViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.02.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <AWSiOSSDK/S3/AmazonS3Client.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "Mixpanel.h"
#import "UIImage+fixOrientation.h"

#import "HONRegisterViewController.h"
#import "HONAppDelegate.h"
#import "HONRegisterCameraOverlayView.h"

@interface HONRegisterViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, HONRegisterCameraOverlayViewDelegate, AmazonServiceRequestDelegate>
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) HONRegisterCameraOverlayView *cameraOverlayView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) UIView *plCameraIrisAnimationView;  // view that animates the opening/closing of the iris
@property (nonatomic, strong) UIImageView *cameraIrisImageView;  // static image of the closed iris
@end

@implementation HONRegisterViewController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(_didShowViewController:)
																	name:@"UINavigationControllerDidShowViewControllerNotification"
																 object:nil];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - Data Calls
- (void)_uploadPhoto:(UIImage *)image {
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	
	_filename = [NSString stringWithFormat:@"%@.jpg", [HONAppDelegate deviceToken]];
	NSLog(@"FILENAME: https://hotornot-challenges.s3.amazonaws.com/%@", _filename);
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Uploading Photo…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	@try {
		CGSize ratio = CGSizeMake(image.size.width / image.size.height, image.size.height / image.size.width);
		
		UIImage *lImage = (ratio.height >= 1.0) ? [HONAppDelegate scaleImage:image toSize:CGSizeMake(100.0, 100.0 * ratio.height)] : [HONAppDelegate scaleImage:image toSize:CGSizeMake(100.0 * ratio.width, 100.0)];
		lImage =	[HONAppDelegate cropImage:lImage toRect:CGRectMake(0.0, 0.0, 100.0, 100.0)];
		
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-challenges"]];
		S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:_filename inBucket:@"hotornot-challenges"];
		por.contentType = @"image/jpeg";
		por.data = UIImageJPEGRepresentation(lImage, kJPEGCompress);
		por.delegate = self;
		[s3 putObject:por];
		
	} @catch (AmazonClientException *exception) {
		//[[[UIAlertView alloc] initWithTitle:@"Upload Error" message:exception.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"Upload Error", @"Status message when internet connectivity is lost");
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}
}

- (void)_submitUser:(NSString *)username {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 9], @"action",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									[NSString stringWithFormat:@"https://hotornot-challenges.s3.amazonaws.com/%@", _filename], @"imgURL",
									username, @"username",
									nil];
	
	[httpClient postPath:kUsersAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		
		if (error != nil) {
			NSLog(@"HONRegisterViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"Download Failed", @"Status message when downloading fails");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
			
		} else {
			NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			NSLog(@"HONRegisterViewController AFNetworking: %@", userResult);
			
			if ([userResult objectForKey:@"id"] != [NSNull null])
				[HONAppDelegate writeUserInfo:userResult];
			
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
			}];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"HONRegisterViewController AFNetworking %@", [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"Connection Error!", @"Status message when no network detected");
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}

#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
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
		_imagePicker.navigationBar.barStyle = UIBarStyleDefault;
		
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


#pragma mark - UI Presentation
- (void)_showOverlay {
	_cameraOverlayView = [[HONRegisterCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_cameraOverlayView.delegate = self;
	[_cameraOverlayView setUsername:[[HONAppDelegate infoForUser] objectForKey:@"name"]];
	
	_imagePicker.cameraOverlayView = _cameraOverlayView;
	//_focusTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(autofocusCamera) userInfo:nil repeats:YES];
}

#pragma mark - Navigation


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
	
	//[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UINavigationControllerDidShowViewControllerNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_irisAnimationDidEnd:) name:@"PLCameraViewIrisAnimationDidEndNotification" object:nil];
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
	if (_imagePicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
		[self dismissViewControllerAnimated:NO completion:^(void) {
			[_cameraOverlayView showUsername];
		}];
	
	} else
		[_cameraOverlayView showUsername];
	
	[self _uploadPhoto:[[info objectForKey:UIImagePickerControllerOriginalImage] fixOrientation]];
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


#pragma mark - CameraOverlayView Delegates
- (void)cameraOverlayViewCancelCamera:(HONRegisterCameraOverlayView *)cameraOverlayView {
	[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
	}];
}

- (void)cameraOverlayViewTakePicture:(HONRegisterCameraOverlayView *)cameraOverlayView {
	[_imagePicker takePicture];
}

- (void)cameraOverlayViewChangeCamera:(HONRegisterCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"First Run - Switch Camera"
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

- (void)cameraOverlayViewShowCameraRoll:(HONRegisterCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"First Run - Camera Roll Button"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
	_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)cameraOverlayViewSubmitWithUsername:(HONRegisterCameraOverlayView *)cameraOverlayView username:(NSString *)username {
	[self _submitUser:username];
}

#pragma mark - AWS Delegates
- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
	//NSLog(@"\nAWS didCompleteWithResponse:\n%@", response);
	
	[_progressHUD hide:YES];
	_progressHUD = nil;
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
	//NSLog(@"AWS didFailWithError:\n%@", error);
}
@end
