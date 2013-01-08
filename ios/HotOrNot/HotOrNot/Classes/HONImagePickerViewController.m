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

@interface HONImagePickerViewController () <ASIHTTPRequestDelegate, HONCameraOverlayViewDelegate>
@property(nonatomic, strong) NSString *subjectName;
@property(nonatomic, strong) NSString *iTunesPreview;
@property(nonatomic, strong) NSString *iTunesPreviewURL;
@property(nonatomic, strong) HONChallengeVO *challengeVO;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@property(nonatomic, strong) NSString *fbID;
@property(nonatomic) int submitAction;
@property(nonatomic) int challengerID;
@property(nonatomic) BOOL needsChallenger;
@property(nonatomic, strong) UIImagePickerController *imagePicker;
@property(nonatomic) BOOL isFirstAppearance;
@property(nonatomic) BOOL hasPlayedAudio;
@property(nonatomic, strong) NSTimer *focusTimer;
@property(nonatomic, strong) HONCameraOverlayView *cameraOverlayView;
@property(nonatomic, strong) UIView *plCameraIrisAnimationView;  // view that animates the opening/closing of the iris
@property(nonatomic, strong) UIImageView *cameraIrisImageView;  // static image of the closed iris
@property(nonatomic, strong) UIImage *challangeImage;
@property (nonatomic, strong) MPMoviePlayerController *mpMoviePlayerController;// *sfxPlayer;
@end

@implementation HONImagePickerViewController

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor blackColor];
		_subjectName = [HONAppDelegate rndDefaultSubject];
		_iTunesPreview = @"";
		_submitAction = 1;
		_needsChallenger = YES;
		_isFirstAppearance = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(_didShowViewController:)
																	name:@"UINavigationControllerDidShowViewControllerNotification"
																 object:nil];
	}
	
	return (self);
}

- (id)initWithUser:(int)userID {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Create Challenge - With User"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		_subjectName = [HONAppDelegate rndDefaultSubject];
		_iTunesPreview = @"";
		_challengerID = userID;
		_needsChallenger = NO;
		_submitAction = 9;
		_isFirstAppearance = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(_didShowViewController:)
																	name:@"UINavigationControllerDidShowViewControllerNotification"
																 object:nil];
	}
	
	return (self);
}

- (id)initWithUser:(int)userID withSubject:(NSString *)subject {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Create Challenge - With User & Hashtag"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		_needsChallenger = NO;
		_subjectName = subject;
		_iTunesPreview = @"";
		_challengerID = userID;
		_submitAction = 9;
		_isFirstAppearance = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(_didShowViewController:)
																	name:@"UINavigationControllerDidShowViewControllerNotification"
																 object:nil];
		
		_needsChallenger = NO;
	}
	
	return (self);
}

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Accept Challenge"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		
		_challengeVO = vo;
		_fbID = vo.creatorFB;
		_subjectName = vo.subjectName;
		_iTunesPreview = vo.itunesPreview;
		_submitAction = 4;
		_needsChallenger = NO;
		_isFirstAppearance = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(_didShowViewController:)
																	name:@"UINavigationControllerDidShowViewControllerNotification"
																 object:nil];
	}
	
	return (self);
}

- (id)initWithSubject:(NSString *)subject {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Create Challenge - With Hashtag"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		
		_subjectName = subject;
		_iTunesPreview = @"";
		_submitAction = 1;
		_needsChallenger = YES;
		_isFirstAppearance = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(_didShowViewController:)
																	name:@"UINavigationControllerDidShowViewControllerNotification"
																 object:nil];
	}
	
	return (self);
}

- (id)initAsDailyChallenge:(NSString *)subject {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Create Challenge - Daily Challenge"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		
		_subjectName = subject;
		_iTunesPreview = @"";
		_submitAction = 1;
		_needsChallenger = YES;
		_isFirstAppearance = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(_didShowViewController:)
																	name:@"UINavigationControllerDidShowViewControllerNotification"
																 object:nil];		
	}
	
	return (self);
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


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Take Challenge"];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 0.0, 74.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backButton];
	
	_hasPlayedAudio = NO;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"Y"];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
		
	if (_isFirstAppearance) {
		_isFirstAppearance = NO;
		
		if (!_hasPlayedAudio) {
			_hasPlayedAudio = YES;
			[self performSelector:@selector(_playAudio) withObject:self afterDelay:1.0];
		}
		
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_SOURCE_CAMERA" object:nil];
						
			if (_subjectName != @"")
				[_cameraOverlayView setSubjectName:_subjectName];
			
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
			
			[self.navigationController presentViewController:_imagePicker animated:NO completion:nil];
		}
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	_isFirstAppearance = YES;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate {
	return (NO);
}

- (void)_playAudio {
	if (_subjectName.length > 0) {
		ASIFormDataRequest *subjectRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
		[subjectRequest setDelegate:self];
		[subjectRequest setPostValue:[NSString stringWithFormat:@"%d", 5] forKey:@"action"];
		[subjectRequest setPostValue:_subjectName forKey:@"subjectName"];
		[subjectRequest setTag:1];
		[subjectRequest startAsynchronous];
	}
}

- (void)_showOverlay {
	_cameraOverlayView = [[HONCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_cameraOverlayView.delegate = self;
	[_cameraOverlayView setSubjectName:_subjectName];
	
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
	
	[_mpMoviePlayerController stop];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - CameraOverlay Delegates
- (void)cameraOverlayViewTakePicture:(HONCameraOverlayView *)cameraOverlayView {
	[_focusTimer invalidate];
	_focusTimer = nil;
	
	[_imagePicker takePicture];
}

- (void)cameraOverlayViewShowCameraRoll:(HONCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Camera Roll Button"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)cameraOverlayViewChangeCamera:(HONCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Switch Camera"
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
	[_focusTimer invalidate];
	_focusTimer = nil;
	
	[_mpMoviePlayerController stop];
	
	[[Mixpanel sharedInstance] track:@"Canceled Create Challenge"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
	[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
	}];
}

- (void)cameraOverlayViewClosePreview:(HONCameraOverlayView *)cameraOverlayView {
	[_cameraOverlayView hidePreview];
	[self _acceptPhoto];
}



- (void)cameraOverlayViewPlayTrack:(HONCameraOverlayView *)cameraOverlayView audioURL:(NSString *)url {
	_iTunesPreview = url;
	
	if (_mpMoviePlayerController != nil) {
		[_mpMoviePlayerController stop];
		[_mpMoviePlayerController setContentURL:[NSURL URLWithString:_iTunesPreview]];
	
	} else {
		_mpMoviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:_iTunesPreview]];
		_mpMoviePlayerController.view.hidden = YES;
		[self.view addSubview:_mpMoviePlayerController.view];
	}
	
	_mpMoviePlayerController.movieSourceType = MPMovieSourceTypeFile;
	[_mpMoviePlayerController prepareToPlay];
	[_mpMoviePlayerController play];
	[[MPMusicPlayerController applicationMusicPlayer] setVolume:0.5];
}

#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[_focusTimer invalidate];
	_focusTimer = nil;
	_subjectName = _cameraOverlayView.subjectName;
	
	[[Mixpanel sharedInstance] track:@"Take Photo"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];

	
	//[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	image = [image fixOrientation];
	
	if (image.size.width > image.size.height) {
		float offset = image.size.height * (image.size.height / image.size.width);
		image = [HONAppDelegate cropImage:image toRect:CGRectMake(offset * 0.5, 0.0, offset, image.size.height)];
	}
	
	if (image.size.height / image.size.width == 1.5) {
		float offset = image.size.height - (image.size.width * kPhotoRatio);
		image = [HONAppDelegate cropImage:image toRect:CGRectMake(0.0, offset * 0.5, image.size.width, (image.size.width * kPhotoRatio))];
	}
	
	_challangeImage = image;
	
	if (_imagePicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {		
		[self dismissViewControllerAnimated:NO completion:^(void) {
			[self _acceptPhoto];
		}];
		
	} else
		[_cameraOverlayView showPreview:image];
}

- (void)cameraOverlayViewPreviewBack:(HONCameraOverlayView *)cameraOverlayView {
}


- (void)_acceptPhoto {
	UIImage *image = _challangeImage;
	
	[_mpMoviePlayerController stop];
	
	if (!_needsChallenger) {
		[[Mixpanel sharedInstance] track:@"Submit Challenge"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if ([_subjectName length] == 0)
			_subjectName = [HONAppDelegate rndDefaultSubject];
		
		AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
		
		NSString *filename = [NSString stringWithFormat:@"%@_%@", [HONAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
		NSLog(@"https://hotornot-challenges.s3.amazonaws.com/%@", filename);
		
		@try {
			UIImageView *canvasView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
			canvasView.image = [HONAppDelegate cropImage:[HONAppDelegate scaleImage:image toSize:CGSizeMake(kLargeW, kLargeH)] toRect:CGRectMake(0.0, (((kLargeH - kLargeW) * 0.5) * 0.5), kLargeW, kLargeW)];
			
//			UIImageView *watermarkImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
//			watermarkImgView.image = [UIImage imageNamed:@"612x612_overlay@2x"];
//			[canvasView addSubview:watermarkImgView];
			
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
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.taskInProgress = YES;
			
			[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-challenges"]];
			S3PutObjectRequest *por1 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_t.jpg", filename] inBucket:@"hotornot-challenges"];
			por1.contentType = @"image/jpeg";
			por1.data = UIImageJPEGRepresentation(t1Image, kJPEGCompress);
			[s3 putObject:por1];
			
//			S3PutObjectRequest *por2 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_t2.jpg", filename] inBucket:@"hotornot-challenges"];
//			por2.contentType = @"image/jpeg";
//			por2.data = UIImageJPEGRepresentation(t2Image, kJPEGCompress);
//			[s3 putObject:por2];
			
			S3PutObjectRequest *por3 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_m.jpg", filename] inBucket:@"hotornot-challenges"];
			por3.contentType = @"image/jpeg";
			por3.data = UIImageJPEGRepresentation(mImage, kJPEGCompress);
			[s3 putObject:por3];
			
			S3PutObjectRequest *por4 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_l.jpg", filename] inBucket:@"hotornot-challenges"];
			por4.contentType = @"image/jpeg";
			por4.data = UIImageJPEGRepresentation(lImage, kJPEGCompress);
			[s3 putObject:por4];
			
			
			
			ASIFormDataRequest *submitChallengeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
			[submitChallengeRequest setDelegate:self];
			[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"%d", _submitAction] forKey:@"action"];
			[submitChallengeRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
			[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"https://hotornot-challenges.s3.amazonaws.com/%@", filename] forKey:@"imgURL"];
			
			if (_submitAction == 1)
				[submitChallengeRequest setPostValue:_subjectName forKey:@"subject"];
			
			else if (_submitAction == 4) {
				[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"%d", _challengeVO.challengeID] forKey:@"challengeID"];
			
			} else if (_submitAction == 8) {
				[submitChallengeRequest setPostValue:_subjectName forKey:@"subject"];
				[submitChallengeRequest setPostValue:_fbID forKey:@"fbID"];
			
			} else if (_submitAction == 9) {
				[submitChallengeRequest setPostValue:_subjectName forKey:@"subject"];
				[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"%d", _challengerID] forKey:@"challengerID"];
			}
			
			[submitChallengeRequest setTag:0];
			[submitChallengeRequest startAsynchronous];
			
		} @catch (AmazonClientException *exception) {
			//[[[UIAlertView alloc] initWithTitle:@"Upload Error" message:exception.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
			
			if (_progressHUD != nil) {
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = NSLocalizedString(@"Upload Error", @"Status message when internet connectivity is lost");
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:1.5];
				_progressHUD = nil;
			}
		}
	
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[self dismissViewControllerAnimated:YES completion:nil];
		
		if (_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
			[self.navigationController pushViewController:[[HONChallengerPickerViewController alloc] initWithFlippedImage:image subjectName:_subjectName] animated:NO];
		
		else
			[self.navigationController pushViewController:[[HONChallengerPickerViewController alloc] initWithImage:image subjectName:_subjectName] animated:NO];
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
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
	}
}

#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"HONImagePickerViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	if (request.tag == 0) {
		@autoreleasepool {
			_progressHUD.taskInProgress = NO;
			
			NSError *error = nil;
			NSDictionary *challengeResult = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			
			if (error != nil) {
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = NSLocalizedString(@"Download Failed", @"Status message when downloading fails");
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:1.5];
				_progressHUD = nil;
			}
			
			else {
				[_progressHUD hide:YES];
				_progressHUD = nil;
				[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_LIST" object:nil];
				[HONFacebookCaller postToTimeline:[HONChallengeVO challengeWithDictionary:challengeResult]];
				[HONFacebookCaller postToFriendTimeline:_fbID challenge:[HONChallengeVO challengeWithDictionary:challengeResult]];
				
				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void){
					[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
				}];
				//[self.navigationController dismissViewControllerAnimated:YES completion:nil];
			}
		}
	
	} else if (request.tag == 1) {
		@autoreleasepool {
			NSError *error = nil;
			NSDictionary *subjectResult = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
			
			if (error != nil) {
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			}
			
			else {
				_iTunesPreview = [subjectResult objectForKey:@"preview_url"];
				_iTunesPreviewURL = [subjectResult objectForKey:@"itunes_id"];
				
				if (_iTunesPreview.length > 0) {
					[_cameraOverlayView artistName:[subjectResult objectForKey:@"artist"] songName:[subjectResult objectForKey:@"song_name"] artworkURL:[subjectResult objectForKey:@"img_url"] storeURL:[subjectResult objectForKey:@"itunes_url"]];
					
					//_mpMoviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:@"http://a931.phobos.apple.com/us/r1000/071/Music/66/ac/5a/mzm.imtvrpsi.aac.p.m4a"]];
					_mpMoviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:_iTunesPreview]];
					_mpMoviePlayerController.movieSourceType = MPMovieSourceTypeFile;
					_mpMoviePlayerController.view.hidden = YES;
					[self.view addSubview:_mpMoviePlayerController.view];
					[_mpMoviePlayerController prepareToPlay];
					[_mpMoviePlayerController play];
					
					[[MPMusicPlayerController applicationMusicPlayer] setVolume:0.5];
				}
			}
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
	
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
}


@end
