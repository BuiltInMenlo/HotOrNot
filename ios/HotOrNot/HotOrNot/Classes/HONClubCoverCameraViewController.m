//
//  HONClubCoverCameraViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/31/2014 @ 20:54 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import <AssetsLibrary/AssetsLibrary.h>
#import <AWSiOSSDK/S3/AmazonS3Client.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

#import "NSString+DataTypes.h"
#import "UIImage+fixOrientation.h"
#import "UIImageView+AFNetworking.h"

#import "MBProgressHUD.h"

#import "HONClubCoverCameraViewController.h"

@interface HONClubCoverCameraViewController ()
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSString *imagePrefix;
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


#pragma mark - Data Calls
- (void)_uploadPhotos:(UIImage *)image {
	NSString *filename = [NSString stringWithFormat:@"%@_%d", [[[HONDeviceIntrinsics sharedInstance] identifierForVendorWithoutSeperators:YES] lowercaseString], (int)[[NSDate date] timeIntervalSince1970]];
	_imagePrefix = [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeClubsSource], filename];
	
	NSLog(@"FILE PREFIX: %@", _imagePrefix);
	
	UIImage *largeImage = [[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:image toSize:CGSizeMake(852.0, kSnapLargeSize.height * 2.0)] toRect:CGRectMake(106.0, 0.0, kSnapLargeSize.width * 2.0, kSnapLargeSize.height * 2.0)];
	UIImage *tabImage = [[HONImageBroker sharedInstance] cropImage:largeImage toRect:CGRectMake(0.0, 0.0, kSnapTabSize.width * 2.0, kSnapTabSize.height * 2.0)];
	
	if ([self.delegate respondsToSelector:@selector(clubCoverCameraViewController:didFinishProcessingImage:withPrefix:)])
		[self.delegate clubCoverCameraViewController:self didFinishProcessingImage:largeImage withPrefix:_imagePrefix];
	
	[[HONAPICaller sharedInstance] uploadPhotosToS3:@[UIImageJPEGRepresentation(largeImage, [HONAppDelegate compressJPEGPercentage]), UIImageJPEGRepresentation(tabImage, [HONAppDelegate compressJPEGPercentage] * 0.85)] intoBucketType:HONS3BucketTypeClubs withFilename:filename completion:^(NSObject *result) {
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBOOL:animated]);
	[super viewDidAppear:animated];
	
	if (_isFirstAppearance) {
		_isFirstAppearance = NO;
		[self _presentCamera];
	}
}


#pragma mark - UI Presentation
- (void)_presentCamera {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		_imagePicker = [[UIImagePickerController alloc] init];
		_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		_imagePicker.delegate = self;
		_imagePicker.allowsEditing = NO;
		_imagePicker.navigationBarHidden = YES;
		_imagePicker.toolbarHidden = YES;
		_imagePicker.navigationBar.barStyle = UIBarStyleDefault;
		_imagePicker.view.backgroundColor = [UIColor whiteColor];
		_imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
		
		self.modalPresentationStyle = UIModalPresentationCurrentContext;
		[self.navigationController presentViewController:_imagePicker animated:YES completion:^(void) {}];
	}
}


#pragma mark - Navigation
- (void)_goCancel {
	[self.navigationController dismissViewControllerAnimated:NO completion:^(void){}];
}


#pragma mark - ImagePickerViewController Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *processedImage = [[HONImageBroker sharedInstance] prepForUploading:[info objectForKey:UIImagePickerControllerOriginalImage]];
	
	NSLog(@"PROCESSED IMAGE:[%@]", NSStringFromCGSize(processedImage.size));
	UIView *canvasView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, processedImage.size.width, processedImage.size.height)];
	[canvasView addSubview:[[UIImageView alloc] initWithImage:processedImage]];
	
	processedImage = [[HONImageBroker sharedInstance] createImageFromView:canvasView];
	[self _uploadPhotos:processedImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[_imagePicker dismissViewControllerAnimated:NO completion:^(void){
		[self _goCancel];
	}];
}


#pragma mark - NavigationController Delegates
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

@end
