//
//  HONCameraViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONCameraViewController.h"
#import "HONCameraOverlayView.h"

#import "HONChallengerPickerViewController.h"

#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"

#import "HONAppDelegate.h"

#define CAMERA_TRANSFORM_X 1
#define CAMERA_TRANSFORM_Y 1

// Screen dimensions
#define SCREEN_WIDTH  320
#define SCREEN_HEIGTH 480

@interface HONCameraViewController ()
@property(nonatomic, strong) NSString *subjectName;
@property(nonatomic, strong) HONChallengeVO *challengeVO;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@property(nonatomic, strong) NSString *fbID;
@property(nonatomic) int submitAction;
@property(nonatomic) int challengerID;
@end

@implementation HONCameraViewController {
	HONCameraOverlayView *overlayView;
	BOOL _didCancel;
}

@synthesize imagePickerController = _imagePickerController;
@synthesize subjectName = _subjectName;
@synthesize submitAction = _submitAction;
@synthesize challengeVO = _challengeVO;
@synthesize progressHUD = _progressHUD;
@synthesize fbID = _fbID;
@synthesize challengerID = _challengerID;

- (id)init {
	if ((self = [super init])) {
		
	}
	
	return (self);
}

- (id)initWithUser:(int)userID {
	if ((self = [super init])) {
		_challengerID = userID;
		
		_submitAction = 9;
	}
	
	return (self);
}

- (id)initWithSubject:(NSString *)subject {
	if ((self = [super init])) {
		_subjectName = subject;
		_submitAction = 1;
	}
	
	return (self);
}

- (id)initWithSubject:(NSString *)subject withFriendID:(NSString *)fbID {
	if ((self = [super init])) {
		_subjectName = subject;
		_fbID = fbID;
		
		_submitAction = 8;
	}
	
	return (self);
}

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		_challengeVO = vo;
		_subjectName = vo.subjectName;
		
		_submitAction = 4;
	}
	
	return (self);
}

- (id)initWithSubject:(NSString *)subject withUser:(int)userID {
	if ((self = [super init])) {
		_subjectName = subject;
		_challengerID = userID;
				
		_submitAction = 9;
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - View lifecycle
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	overlayView = [[HONCameraOverlayView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGTH)];
	overlayView.delegate = self;
	
	self.imagePickerController = [[UIImagePickerController alloc] init];
	self.imagePickerController.delegate = self;
	self.imagePickerController.navigationBarHidden = YES;
	self.imagePickerController.toolbarHidden = YES;
	self.imagePickerController.wantsFullScreenLayout = YES;
	
	void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
		if(result)
			[_assets addObject:result];
			
		else
			[self performSelectorOnMainThread:@selector(showCamera) withObject:nil waitUntilDone:NO];
	};
	
	void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) =  ^(ALAssetsGroup *group, BOOL *stop) {
		if(group)
			[group enumerateAssetsUsingBlock:assetEnumerator];
	};
	
	_assets = [[NSMutableArray alloc] init];
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	[library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:assetGroupEnumerator failureBlock:^(NSError *error) {
		NSLog(@"Failure");
	}];
}

- (void) showCamera {
	self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	self.imagePickerController.showsCameraControls = NO;
	self.imagePickerController.cameraViewTransform = CGAffineTransformScale(self.imagePickerController.cameraViewTransform, CAMERA_TRANSFORM_X, CAMERA_TRANSFORM_Y);
	self.imagePickerController.cameraOverlayView = overlayView;
	
	if (overlayView.flashButton.hidden) {
		overlayView.flashButton.hidden = NO;
	}
	
	
	if (!_didCancel)
		[self.navigationController presentViewController:self.imagePickerController animated:NO completion:nil];
	
	else
		_didCancel = NO;
}

- (void)takePicture {
	[self.imagePickerController takePicture];
}

- (void) imagePickerController:(UIImagePickerController *)aPicker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *aImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
	
	if (aPicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
		UIImageWriteToSavedPhotosAlbum (aImage, nil, nil , nil);
		overlayView.captureButton.enabled = YES;
	
	} else {
		[_imageView removeFromSuperview];
		_imageView = nil;
		
		// reset our zoomScale
		CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
		_imageView = [[UIImageView alloc] initWithImage:aImage];
		_scrollView.contentSize = aImage.size;
		_scrollView.bounces = NO;
		_scrollView.delegate = self;
		
		// set up our content size and min/max zoomscale
		CGFloat xScale = applicationFrame.size.width / aImage.size.width;    // the scale needed to perfectly fit the image width-wise
		CGFloat yScale = applicationFrame.size.height / aImage.size.height;  // the scale needed to perfectly fit the image height-wise
		CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
		
		// on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
		// maximum zoom scale to 0.5.
		CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];
		
		// don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
		minScale = MIN(minScale, maxScale);
		
		_scrollView.contentSize = aImage.size;
		_scrollView.maximumZoomScale = maxScale;
		_scrollView.minimumZoomScale = minScale;
		_scrollView.zoomScale = minScale;
		
		
		//////////////
		
		CGSize boundsSize = applicationFrame.size;
		CGRect frameToCenter = _imageView.frame;
		
		// center horizontally
		if (frameToCenter.size.width < boundsSize.width)
			frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
		
		else
			frameToCenter.origin.x = 0;
		
		// center vertically
		if (frameToCenter.size.height < boundsSize.height)
			frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
		
		else
			frameToCenter.origin.y = 0;
		
		//////////////
		
		_imageView.frame = frameToCenter;
		[_scrollView addSubview:_imageView];
		
		[self.imagePickerController dismissViewControllerAnimated:NO completion:nil];
	}
	
	[self.navigationController pushViewController:[[HONChallengerPickerViewController alloc] init] animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	_didCancel = YES;
	[self showCamera];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _imageView;
}

- (IBAction) backButton:(id)sender {
	self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	[self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (IBAction)doneButton:(id)sender {
	self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	if (overlayView.flashButton.hidden) {
		overlayView.flashButton.hidden = NO;
	}
	[self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void) changeFlash:(id)sender {
	switch (self.imagePickerController.cameraFlashMode) {
		case UIImagePickerControllerCameraFlashModeAuto:
			[(UIButton *)sender setImage:[UIImage imageNamed:@"flash01"] forState:UIControlStateNormal];
			self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
			break;
			
		case UIImagePickerControllerCameraFlashModeOn:
			[(UIButton *)sender setImage:[UIImage imageNamed:@"flash03"] forState:UIControlStateNormal];
			self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
			break;
			
		case UIImagePickerControllerCameraFlashModeOff:
			[(UIButton *)sender setImage:[UIImage imageNamed:@"flash02"] forState:UIControlStateNormal];
			self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
			break;
	}
}

- (void)changeCamera {
	if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
		self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
		overlayView.flashButton.hidden = NO;
		
	} else {
		self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
		overlayView.flashButton.hidden = YES;
	}
}

- (void)showLibrary {
	self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
}



@end
