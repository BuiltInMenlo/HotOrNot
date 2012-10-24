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

#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#import "UIImage+fixOrientation.h"
#import "Mixpanel.h"

#import "HONImagePickerViewController.h"
#import "HONAppDelegate.h"
#import "HONCameraOverlayView.h"
#import "HONChallengerPickerViewController.h"
#import "HONFacebookCaller.h"
#import "HONHeaderView.h"

@interface HONImagePickerViewController () <ASIHTTPRequestDelegate>
@property(nonatomic, strong) NSString *subjectName;
@property(nonatomic, strong) HONChallengeVO *challengeVO;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@property(nonatomic, strong) NSString *fbID;
@property(nonatomic) int submitAction;
@property(nonatomic) int challengerID;
@property(nonatomic) BOOL needsChallenger;
@property(nonatomic, strong) UIImagePickerController *imagePicker;
@property(nonatomic) BOOL isFirstAppearance;
@property(nonatomic, strong) NSTimer *focusTimer;
@property(nonatomic, strong) HONCameraOverlayView *cameraOverlayView;
@end

@implementation HONImagePickerViewController

@synthesize subjectName = _subjectName;
@synthesize submitAction = _submitAction;
@synthesize challengeVO = _challengeVO;
@synthesize progressHUD = _progressHUD;
@synthesize fbID = _fbID;
@synthesize challengerID = _challengerID;
@synthesize needsChallenger = _needsChallenger;
@synthesize isFirstAppearance = _isFirstAppearance;
@synthesize focusTimer = _focusTimer;
@synthesize cameraOverlayView = _cameraOverlayView;

- (id)init {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Create Challenge"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		self.view.backgroundColor = [UIColor blackColor];
		//self.tabBarItem.image = [UIImage imageNamed:@"tab03_nonActive"];
		self.subjectName = @"";
		self.submitAction = 1;
		self.needsChallenger = YES;
		self.isFirstAppearance = YES;
	}
	
	return (self);
}

- (id)initWithUser:(int)userID {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Create Challenge"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		self.subjectName = @"";
		self.challengerID = userID;
		self.needsChallenger = NO;
		self.submitAction = 9;
		self.isFirstAppearance = YES;
	}
	
	return (self);
}

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Accept Challenge"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		
		self.challengeVO = vo;
		self.subjectName = vo.subjectName;
		self.submitAction = 4;
		self.needsChallenger = NO;
		self.isFirstAppearance = YES;
	}
	
	return (self);
}

- (id)initWithSubject:(NSString *)subject {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Create Challenge"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		
		self.subjectName = subject;
		self.submitAction = 1;
		self.needsChallenger = NO;
		self.isFirstAppearance = YES;
	}
	
	return (self);
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Choose Photo" hasFBSwitch:NO];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 0.0, 74.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (self.isFirstAppearance) {
		self.isFirstAppearance = NO;
		
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_SOURCE_CAMERA" object:nil];
						
			if (self.subjectName != @"")
				[_cameraOverlayView setSubjectName:self.subjectName];
			
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
				[self performSelector:@selector(_showOverlay) withObject:nil afterDelay:1.33];
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
			
			[self.navigationController presentViewController:_imagePicker animated:NO completion:nil];
		}
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	self.isFirstAppearance = YES;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate {
	return (NO);
}

- (void)_showOverlay {
	_cameraOverlayView = [[HONCameraOverlayView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.view.frame.size.height)];
	_cameraOverlayView.delegate = self;
	
	_imagePicker.cameraOverlayView = _cameraOverlayView;
	_focusTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(autofocusCamera) userInfo:nil repeats:YES];
}

- (void)autofocusCamera {
	NSArray *devices = [AVCaptureDevice devices];
	NSError *error;
	for (AVCaptureDevice *device in devices) {
		if ([device position] == AVCaptureDevicePositionBack) {
			[device lockForConfiguration:&error];
			if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            device.focusMode = AVCaptureFocusModeAutoFocus;
			}
			
			[device unlockForConfiguration];
		}
	}
}

#pragma mark - Navigation
- (void)_goBack {
	[_focusTimer invalidate];
	_focusTimer = nil;
	
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)takePicture {
	[_focusTimer invalidate];
	_focusTimer = nil;
	
	[_imagePicker takePicture];
}

- (void)showLibrary {
	[[Mixpanel sharedInstance] track:@"Camera Roll Button"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)changeCamera {
	[[Mixpanel sharedInstance] track:@"Switch Camera"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d", _imagePicker.cameraDevice], nil]];
	
	if (_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
		_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
		//overlay.flashButton.hidden = NO;
	
	} else {
		_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
		//overlay.flashButton.hidden = YES;
	}
}

- (void)closeCamera {
	[_focusTimer invalidate];
	_focusTimer = nil;
	[[Mixpanel sharedInstance] track:@"Canceled Create Challenge"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
	}];
}

#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[_focusTimer invalidate];
	_focusTimer = nil;
	
	[[Mixpanel sharedInstance] track:@"Take Photo"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];

	
	[[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
	
	if (_imagePicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary || self.needsChallenger)
		[self dismissViewControllerAnimated:YES completion:nil];
	
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	if (image.size.width > image.size.height) {
		CGAffineTransform transform = CGAffineTransformIdentity;
		transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
		transform = CGAffineTransformRotate(transform, M_PI / 2.0);
	}
	
	image = [image fixOrientation];
	
	NSLog(@"imageOrientation:[%d]", image.imageOrientation);
	
	if (!self.needsChallenger) {
		[_cameraOverlayView hidePreview];
		
		AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
		
		NSString *filename = [NSString stringWithFormat:@"%@_%@", [HONAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
		NSLog(@"https://hotornot-challenges.s3.amazonaws.com/%@", filename);
		
		@try {
			UIImageView *canvasView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW, kLargeH)];
			canvasView.image = [HONAppDelegate scaleImage:image toSize:CGSizeMake(kLargeW, kLargeH)];
			
			UIImageView *watermarkImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 23.0, 620.0, 830.0)];
			watermarkImgView.image = [UIImage imageNamed:@"waterMark.png"];
			[canvasView addSubview:watermarkImgView];
			
			CGSize size = [canvasView bounds].size;
			UIGraphicsBeginImageContext(size);
			[[canvasView layer] renderInContext:UIGraphicsGetCurrentContext()];
			UIImage *lImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();

			UIImage *mImage = [HONAppDelegate scaleImage:image toSize:CGSizeMake(kMediumW * 2.0, kMediumH * 2.0)];
			UIImage *t1Image = [HONAppDelegate scaleImage:image toSize:CGSizeMake(kThumb1W * 2.0, kThumb1H * 2.0)];
			
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.labelText = @"Submitting Challenge…";
			_progressHUD.mode = MBProgressHUDModeIndeterminate;
			_progressHUD.graceTime = 2.0;
			_progressHUD.taskInProgress = YES;
			
			[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-challenges"]];
			S3PutObjectRequest *por1 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_t.jpg", filename] inBucket:@"hotornot-challenges"];
			por1.contentType = @"image/jpeg";
			por1.data = UIImageJPEGRepresentation(t1Image, 0.5);
			[s3 putObject:por1];
			
//			S3PutObjectRequest *por2 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_t2.jpg", filename] inBucket:@"hotornot-challenges"];
//			por2.contentType = @"image/jpeg";
//			por2.data = UIImageJPEGRepresentation(t2Image, 1.0);
//			[s3 putObject:por2];
			
			S3PutObjectRequest *por3 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_m.jpg", filename] inBucket:@"hotornot-challenges"];
			por3.contentType = @"image/jpeg";
			por3.data = UIImageJPEGRepresentation(mImage, 0.5);
			[s3 putObject:por3];
			
			S3PutObjectRequest *por4 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_l.jpg", filename] inBucket:@"hotornot-challenges"];
			por4.contentType = @"image/jpeg";
			por4.data = UIImageJPEGRepresentation(lImage, 0.5);
			[s3 putObject:por4];
			
			
			
			ASIFormDataRequest *submitChallengeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
			[submitChallengeRequest setDelegate:self];
			[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"%d", self.submitAction] forKey:@"action"];
			[submitChallengeRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
			[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"https://hotornot-challenges.s3.amazonaws.com/%@", filename] forKey:@"imgURL"];
			
			if (self.submitAction == 1)
				[submitChallengeRequest setPostValue:self.subjectName forKey:@"subject"];
			
			else if (self.submitAction == 4) {
				[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"%d", self.challengeVO.challengeID] forKey:@"challengeID"];
			
			} else if (self.submitAction == 8) {
				[submitChallengeRequest setPostValue:self.subjectName forKey:@"subject"];
				[submitChallengeRequest setPostValue:self.fbID forKey:@"fbID"];
			
			} else if (self.submitAction == 9) {
				[submitChallengeRequest setPostValue:self.subjectName forKey:@"subject"];
				[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"%d", self.challengerID] forKey:@"challengerID"];
			}
			
			[submitChallengeRequest startAsynchronous];
			
		} @catch (AmazonClientException *exception) {
			[[[UIAlertView alloc] initWithTitle:@"Upload Error" message:exception.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
		}
	
	} else {
		[self.navigationController pushViewController:[[HONChallengerPickerViewController alloc] initWithImage:image] animated:YES];
	}
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
		[[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
	}
}

#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"HONImagePickerViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		_progressHUD.taskInProgress = NO;
		
		NSError *error = nil;
		NSDictionary *challengeResult = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		
		if (error != nil) {
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			_progressHUD.graceTime = 0.0;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
			_progressHUD.labelText = NSLocalizedString(@"Download Failed", @"Status message when downloading fails");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
		}
		
		else {
			[_progressHUD hide:YES];
			_progressHUD = nil;
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_LIST" object:nil];
			
			[HONFacebookCaller postToTimeline:[HONChallengeVO challengeWithDictionary:challengeResult]];
			[HONFacebookCaller postToFriendTimeline:self.fbID article:[HONChallengeVO challengeWithDictionary:challengeResult]];
			
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
			//[self.navigationController dismissViewControllerAnimated:YES completion:nil];
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}


@end
