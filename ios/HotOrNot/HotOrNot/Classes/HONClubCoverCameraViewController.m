//
//  HONClubCoverCameraViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/31/2014 @ 20:54 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import <AWSiOSSDK/S3/AmazonS3Client.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

#import "NSString+DataTypes.h"
#import "UIImage+fixOrientation.h"

#import "ImageFilter.h"
#import "MBProgressHUD.h"

#import "HONClubCoverCameraViewController.h"
#import "HONClubCoverCameraOverlayView.h"

@interface HONClubCoverCameraViewController () <HONClubCoverCameraOverlayViewDelegate>
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) HONClubCoverCameraOverlayView *cameraOverlayView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSString *imagePrefix;
@property (nonatomic) int tintIndex;
@property (nonatomic) int selfieAttempts;
@property (nonatomic) BOOL isFirstAppearance;
@end


@implementation HONClubCoverCameraViewController
@synthesize delegate = _delegate;

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
	NSString *filename = [NSString stringWithFormat:@"%@-%@_%@", [[[HONDeviceIntrinsics sharedInstance] identifierForVendorWithoutSeperators:YES] lowercaseString], [[[HONDeviceIntrinsics sharedInstance] advertisingIdentifierWithoutSeperators:YES] lowercaseString], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
	_imagePrefix = [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], filename];
	
	NSLog(@"FILE PREFIX: %@", _imagePrefix);
	
	UIImage *largeImage = [HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:image toSize:CGSizeMake(852.0, kSnapLargeSize.height * 2.0)] toRect:CGRectMake(106.0, 0.0, kSnapLargeSize.width * 2.0, kSnapLargeSize.height * 2.0)];
	UIImage *tabImage = [HONImagingDepictor cropImage:largeImage toRect:CGRectMake(0.0, 0.0, kSnapTabSize.width * 2.0, kSnapTabSize.height * 2.0)];
	
	[self.delegate clubCoverCameraViewController:self didFinishProcessingImage:largeImage withPrefix:_imagePrefix];
	
	[[HONAPICaller sharedInstance] uploadPhotosToS3:@[UIImageJPEGRepresentation(largeImage, [HONAppDelegate compressJPEGPercentage]), UIImageJPEGRepresentation(tabImage, [HONAppDelegate compressJPEGPercentage] * 0.85)] intoBucketType:HONS3BucketTypeClubs withFilename:filename completion:^(NSObject *result) {
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		[_cameraOverlayView uploadComplete];
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[self.navigationController dismissViewControllerAnimated:YES completion:^(void) {}];
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidAppear:animated];
	
	if (_isFirstAppearance) {
		_isFirstAppearance = NO;
		
		[self _presentCamera];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillDisappear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidDisappear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload {
	ViewControllerLog(@"[:|:] [%@ viewDidUnload] [:|:]", self.class);
	[super viewDidUnload];
}


#pragma mark - UI Presentation
- (void)_presentCamera {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		_imagePicker = [[UIImagePickerController alloc] init];
		_imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
		_imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
		_imagePicker.delegate = self;
		
		_imagePicker.showsCameraControls = NO;
		_imagePicker.cameraViewTransform = CGAffineTransformScale(_imagePicker.cameraViewTransform, ([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? 1.65f : 1.25f, ([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? 1.65f : 1.25f);
		_imagePicker.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		_imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		
		_cameraOverlayView = [[HONClubCoverCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
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

-(void)_destroyCamera {
	_cameraOverlayView = nil;
	_imagePicker.cameraOverlayView = nil;
	_imagePicker = nil;
}


#pragma mark - Navigation




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
	[self dismissViewControllerAnimated:NO completion:^(void) {
		[self _uploadPhotos:processedImage];
	}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
		picker.showsCameraControls = NO;
		picker.cameraViewTransform = CGAffineTransformMakeTranslation(24.0, 90.0);
		picker.cameraViewTransform = CGAffineTransformScale(_imagePicker.cameraViewTransform, ([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? 1.55f : 1.25f, ([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? 1.55f : 1.25f);
		picker.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		
		_cameraOverlayView = [[HONClubCoverCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_cameraOverlayView.delegate = self;
		_imagePicker.cameraOverlayView = _cameraOverlayView;
		
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
		}];
	}
}


#pragma mark - NavigationController Delegates
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	navigationController.navigationBar.barStyle = UIBarStyleDefault;
}


#pragma mark - CameraOverlayView Delegates
- (void)cameraOverlayViewCloseCamera:(HONClubCoverCameraOverlayView *)cameraOverlayView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Cover Photo - Cancel"];
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			[self.navigationController dismissViewControllerAnimated:YES completion:^(void) {
				[self _destroyCamera];
			}];
		
		} else
			[self _destroyCamera];
	}];
}

- (void)cameraOverlayViewChangeCamera:(HONClubCoverCameraOverlayView *)cameraOverlayView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Cover Photo - Switch Camera"
								   withCameraDevice:_imagePicker.cameraDevice];
	
	if (_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
		_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
		_imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		//overlay.flashButton.hidden = NO;
		
	} else {
		_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
		//overlay.flashButton.hidden = YES;
	}
}

- (void)cameraOverlayViewShowCameraRoll:(HONClubCoverCameraOverlayView *)cameraOverlayView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Cover Photo - Camera Roll"];
	
	_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
	_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)cameraOverlayViewTakePicture:(HONClubCoverCameraOverlayView *)cameraOverlayView withTintIndex:(int)tintIndex {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Cover Photo - Take Photo"
									 withProperties:@{@"tint"	: [@"" stringFromInt:tintIndex]}];
	
	_tintIndex = tintIndex;
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Loading…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[_imagePicker takePicture];
}

- (void)cameraOverlayViewRetake:(HONClubCoverCameraOverlayView *)cameraOverlayView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Cover Photo - Retake"];
}

- (void)cameraOverlayViewSubmit:(HONClubCoverCameraOverlayView *)cameraOverlayView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Club Cover Photo - Submit"];
	
//	UIImage *processedImage = [HONImagingDepictor prepForUploading:[info objectForKey:UIImagePickerControllerOriginalImage]];
//
//	NSLog(@"PROCESSED IMAGE:[%@]", NSStringFromCGSize(processedImage.size));
//	UIView *canvasView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, processedImage.size.width, processedImage.size.height)];
//	[canvasView addSubview:[[UIImageView alloc] initWithImage:processedImage]];
//
//	UIView *overlayTintView = [[UIView alloc] initWithFrame:canvasView.frame];
//	overlayTintView.backgroundColor = [[HONAppDelegate colorsForOverlayTints] objectAtIndex:_tintIndex];
//	[canvasView addSubview:overlayTintView];
//
//	processedImage = [HONImagingDepictor createImageFromView:canvasView];
//	[self _uploadPhotos:processedImage];
}

@end
