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
#import "Facebook.h"
#import "MBProgressHUD.h"
#import "Mixpanel.h"
#import "UIImage+fixOrientation.h"

#import "HONImagePickerViewController.h"
#import "HONAppDelegate.h"
#import "HONCameraOverlayView.h"
#import "HONFacebookCaller.h"
#import "HONHeaderView.h"


@interface HONImagePickerViewController () <AmazonServiceRequestDelegate, UISearchBarDelegate, FBFriendPickerDelegate, HONCameraOverlayViewDelegate> {
	CGFloat fbHeaderHeight;
}

@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) NSString *iTunesPreview;
@property (nonatomic, strong) NSString *iTunesPreviewURL;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSString *fbID;
@property (nonatomic) int submitAction;
@property (nonatomic) HONUserVO *userVO;
@property (nonatomic) int uploadCounter;
@property (nonatomic) BOOL needsChallenger;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic) BOOL isFirstAppearance;
@property (nonatomic) BOOL hasPlayedAudio;
@property (nonatomic, strong) NSTimer *focusTimer;
@property (nonatomic, strong) HONCameraOverlayView *cameraOverlayView;
@property (nonatomic, strong) UIView *plCameraIrisAnimationView;  // view that animates the opening/closing of the iris
@property (nonatomic, strong) UIImageView *cameraIrisImageView;  // static image of the closed iris
@property (nonatomic, strong) UIImage *challangeImage;
@property (nonatomic, strong) MPMoviePlayerController *mpMoviePlayerController;// *sfxPlayer;

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (retain, nonatomic) UISearchBar *searchBar;
@property (retain, nonatomic) NSString *searchText;
@property (retain, nonatomic) NSMutableArray *friends;
@property (nonatomic, retain) HONHeaderView *friendPickerHeaderView;
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
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadStateDidChangeNotification:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
	}
	
	return (self);
}

- (id)initWithUser:(HONUserVO *)userVO {
	if ((self = [super init])) {
		_subjectName = [HONAppDelegate rndDefaultSubject];
		_iTunesPreview = @"";
		_userVO = userVO;
		_needsChallenger = NO;
		_submitAction = 9;
		_isFirstAppearance = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(_didShowViewController:)
																	name:@"UINavigationControllerDidShowViewControllerNotification"
																 object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadStateDidChangeNotification:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
	}
	
	return (self);
}

- (id)initWithUser:(HONUserVO *)userVO withSubject:(NSString *)subject {
	if ((self = [super init])) {
		_needsChallenger = NO;
		_subjectName = subject;
		_iTunesPreview = @"";
		_userVO = userVO;
		_submitAction = 9;
		_isFirstAppearance = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(_didShowViewController:)
																	name:@"UINavigationControllerDidShowViewControllerNotification"
																 object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadStateDidChangeNotification:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
		
		_needsChallenger = NO;
	}
	
	return (self);
}

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		_challengeVO = vo;
		_fbID = vo.creatorFB;
		_subjectName = vo.subjectName;
		_iTunesPreview = @"";//vo.itunesPreview;
		_submitAction = 4;
		_needsChallenger = NO;
		_isFirstAppearance = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(_didShowViewController:)
																	name:@"UINavigationControllerDidShowViewControllerNotification"
																 object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadStateDidChangeNotification:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
	}
	
	return (self);
}

- (id)initWithSubject:(NSString *)subject {
	if ((self = [super init])) {
		_subjectName = subject;
		_iTunesPreview = @"";
		_submitAction = 1;
		_needsChallenger = YES;
		_isFirstAppearance = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(_didShowViewController:)
																	name:@"UINavigationControllerDidShowViewControllerNotification"
																 object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadStateDidChangeNotification:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (NO);
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Take snap"];
	//[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(3.0, 0.0, 64.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backButton];
	
	_hasPlayedAudio = NO;
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
		
	if (_isFirstAppearance) {
		_isFirstAppearance = NO;
		
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_SOURCE_CAMERA" object:nil];
						
			if (![_subjectName isEqualToString: @""])
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
				//[self performSelector:@selector(_showOverlay) withObject:self afterDelay:0.15];
				[self _showOverlay];
				
				if (!_hasPlayedAudio) {
					_hasPlayedAudio = YES;
					[self performSelector:@selector(_playAudio) withObject:self afterDelay:0.5];
				}
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
				if (!_hasPlayedAudio) {
					_hasPlayedAudio = YES;
					[self performSelector:@selector(_playAudio) withObject:self afterDelay:0.5];
				}
			}];
		}
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	_isFirstAppearance = YES;
}


#pragma mark - UI Presentation
- (void)_playAudio {
	if (_subjectName.length == 0) {
		AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
		NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSString stringWithFormat:@"%d", 5], @"action",
										_subjectName, @"subjectName",
										nil];
		
		[httpClient postPath:kChallengesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSError *error = nil;
			if (error != nil) {
				NSLog(@"ImagePickerViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
				
			} else {
				NSDictionary *subjectResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
				
				_iTunesPreview = [subjectResult objectForKey:@"preview_url"];
				_iTunesPreviewURL = [subjectResult objectForKey:@"itunes_id"];
				
				if (_iTunesPreview.length > 0) {
					[_cameraOverlayView artistName:[subjectResult objectForKey:@"artist"] songName:[subjectResult objectForKey:@"song_name"] artworkURL:[subjectResult objectForKey:@"img_url"] storeURL:[subjectResult objectForKey:@"itunes_url"]];
					
					if (_mpMoviePlayerController != nil) {
						[_mpMoviePlayerController stop];
						_mpMoviePlayerController = nil;
					}
					
					//_mpMoviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:@"http://a931.phobos.apple.com/us/r1000/071/Music/66/ac/5a/mzm.imtvrpsi.aac.p.m4a"]];
					_mpMoviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:_iTunesPreview]];
					_mpMoviePlayerController.movieSourceType = MPMovieSourceTypeFile;
					_mpMoviePlayerController.view.hidden = YES;
					[self.view addSubview:_mpMoviePlayerController.view];
					[_mpMoviePlayerController prepareToPlay];
					[_mpMoviePlayerController play];
					
//					MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(0.0, 100.0, 200.0, 60.0)];
//					[_cameraOverlayView addSubview:volumeView];
//					[volumeView sizeToFit];
					
					[[MPMusicPlayerController applicationMusicPlayer] setVolume:([HONAppDelegate audioMuted]) ? 0.0 : 0.5];
					
				}
			}
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"ImagePickerViewController AFNetworking %@", [error localizedDescription]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"Connection Error", @"Status message when no network detected");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
		}];
	}
}

- (void)_showOverlay {
	_cameraOverlayView = [[HONCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_cameraOverlayView.delegate = self;
	[_cameraOverlayView setSubjectName:_subjectName];
	
	_imagePicker.cameraOverlayView = _cameraOverlayView;
	//_focusTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(autofocusCamera) userInfo:nil repeats:YES];
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


#pragma mark - Data Calls
- (void)_uploadPhoto:(UIImage *)image {
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	_uploadCounter = 0;
	
	_filename = [NSString stringWithFormat:@"%@_%@", [HONAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
	NSLog(@"FILE PREFIX: https://hotornot-challenges.s3.amazonaws.com/%@", _filename);
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Uploading Photo…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	@try {
		float ratio = image.size.height / image.size.width;
		
		UIImage *lImage = [HONAppDelegate scaleImage:image toSize:CGSizeMake(kLargeW, kLargeW * ratio)];
		lImage = [HONAppDelegate cropImage:lImage toRect:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
		
		UIImage *mImage = [HONAppDelegate scaleImage:image toSize:CGSizeMake(kMediumW * 2.0, kMediumH * 2.0)];
		UIImage *t1Image = [HONAppDelegate scaleImage:image toSize:CGSizeMake(kThumb1W * 2.0, kThumb1H * 2.0)];
				
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-challenges"]];
		S3PutObjectRequest *por1 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_t.jpg", _filename] inBucket:@"hotornot-challenges"];
		por1.contentType = @"image/jpeg";
		por1.data = UIImageJPEGRepresentation(t1Image, kJPEGCompress);
		por1.delegate = self;
		[s3 putObject:por1];
		 
		S3PutObjectRequest *por2 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_m.jpg", _filename] inBucket:@"hotornot-challenges"];
		por2.contentType = @"image/jpeg";
		por2.data = UIImageJPEGRepresentation(mImage, kJPEGCompress);
		por2.delegate = self;
		[s3 putObject:por2];
		
		S3PutObjectRequest *por3 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_l.jpg", _filename] inBucket:@"hotornot-challenges"];
		por3.contentType = @"image/jpeg";
		por3.data = UIImageJPEGRepresentation(lImage, kJPEGCompress);
		por3.delegate = self;
		[s3 putObject:por3];
		
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

- (void)_submitChallenge:(NSMutableDictionary *)params {
	
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Submitting Snap…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kChallengesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"ImagePickerViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"Download Failed", @"Status message when downloading fails");
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
				_progressHUD.labelText = @"Username not found!";
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:1.5];
				_progressHUD = nil;
			
			} else {
				[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:nil];
				
				[HONFacebookCaller postToTimeline:[HONChallengeVO challengeWithDictionary:challengeResult]];
				
				[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
					[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
					[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
				}];
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"ImagePickerViewController AFNetworking %@", [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"Connection Error", @"Status message when no network detected");
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}


#pragma mark - Navigation
- (void)_goBack {
	
	if (_focusTimer != nil) {
		[_focusTimer invalidate];
		_focusTimer = nil;
	}
	
	if (_mpMoviePlayerController != nil) {
		[_mpMoviePlayerController stop];
		_mpMoviePlayerController = nil;
	}
	
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:^(void) {
		if (_imagePicker != nil)
			_imagePicker = nil;
		
		_cameraOverlayView = nil;
		;
	}];
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

- (void)_loadStateDidChangeNotification:(NSNotification *)notification {
	NSLog(@"----[LOAD STATE CHANGED[%d]]----", _mpMoviePlayerController.loadState);
	
	switch (_mpMoviePlayerController.loadState) {
		case MPMovieLoadStatePlayable:
			[_cameraOverlayView endBuffering];
			break;
	}
}


#pragma mark - CameraOverlay Delegates
- (void)cameraOverlayViewTakePicture:(HONCameraOverlayView *)cameraOverlayView {
	if (_focusTimer != nil) {
		[_focusTimer invalidate];
		_focusTimer = nil;
	}
	
	[_imagePicker takePicture];
}

- (void)cameraOverlayViewShowCameraRoll:(HONCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Camera Roll Button"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
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
	if (_focusTimer != nil) {
		[_focusTimer invalidate];
		_focusTimer = nil;
	}
	
	if (_mpMoviePlayerController != nil) {
		[_mpMoviePlayerController stop];
		_mpMoviePlayerController = nil;
	}
	
	[[Mixpanel sharedInstance] track:@"Canceled Create Challenge"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:nil];
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
	}];
}

- (void)cameraOverlayViewSubmitChallenge:(HONCameraOverlayView *)cameraOverlayView username:(NSString *)username comments:(NSString *)comments {
	NSLog(@"cameraOverlayViewSubmitChallenge [%@][%@]", username, comments);
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[params setObject:[NSString stringWithFormat:@"%d", _userVO.userID] forKey:@"challengerID"];
	[params setObject:[NSString stringWithFormat:@"https://hotornot-challenges.s3.amazonaws.com/%@", _filename] forKey:@"imgURL"];
	[params setObject:_subjectName forKey:@"subject"];
	
	if (![username isEqualToString:@"@"] && _challengeVO == nil)
		_submitAction = 7;
	
	[params setObject:[username substringFromIndex:1] forKey:@"username"];
	
	if (_challengeVO != nil)
		[params setObject:[NSString stringWithFormat:@"%d", _challengeVO.challengeID] forKey:@"challengeID"];
	
	if (_fbID != nil)
		[params setObject:_fbID forKey:@"fbID"];
	
	[params setObject:[NSString stringWithFormat:@"%d", _submitAction] forKey:@"action"];
	[self _submitChallenge:params];
}

- (void)cameraOverlayViewChangeSubject:(HONCameraOverlayView *)cameraOverlayView subject:(NSString *)subjectName {
	_subjectName = subjectName;
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
	
	[[MPMusicPlayerController applicationMusicPlayer] setVolume:([HONAppDelegate audioMuted]) ? 0.0 : 0.5];
}

- (void)cameraOverlayViewPickFBFriends:(HONCameraOverlayView *)cameraOverlayView {
	self.friendPickerController = [[FBFriendPickerViewController alloc] init];
	self.friendPickerController.title = @"Pick Friends";
	self.friendPickerController.allowsMultipleSelection = NO;
	self.friendPickerController.delegate = self;
	self.friendPickerController.sortOrdering = FBFriendDisplayByLastName;
	[self addCustomHeaderToFriendPickerView];
	[self.friendPickerController loadData];
	[self.friendPickerController clearSelection];
	
//	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.friendPickerController];
//	[navigationController setNavigationBarHidden:YES];
//	[self presentViewController:navigationController animated:YES completion:^(void) {
//		[self addSearchBarToFriendPickerView];
//	}];
	

	[self.navigationController presentViewController:self.friendPickerController animated:YES completion:^(void){[self addSearchBarToFriendPickerView];}];
}

- (void)cameraOverlayViewPreviewBack:(HONCameraOverlayView *)cameraOverlayView {
}


#pragma mark - Custom Facebook Select Friends Header Methods
// Method to that adds a custom header bar to the built-in Friend Selector View.
// We add this to the canvasView of the FBFriendPickerViewController.
// We have to set cancelButton and doneButton to nil so that default header is removed.
// We then add a UIView as a header.
- (void)addCustomHeaderToFriendPickerView
{
	self.friendPickerController.cancelButton = nil;
	self.friendPickerController.doneButton = nil;
	
	CGFloat headerBarHeight = 45.0;
	fbHeaderHeight = headerBarHeight;
	
	self.friendPickerHeaderView = [[HONHeaderView alloc] initWithTitle:[@"Select Friend" uppercaseString]];
	self.friendPickerHeaderView.autoresizingMask = self.friendPickerHeaderView.autoresizingMask | UIViewAutoresizingFlexibleWidth;
	
	// Cancel Button
	UIButton *customCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[customCancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
	[customCancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
	[customCancelButton addTarget:self action:@selector(facebookViewControllerCancelWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	customCancelButton.frame = CGRectMake(5.0, 0.0, 64.0, 44.0);
	[self.friendPickerHeaderView addSubview:customCancelButton];
	
	// Done Button
	UIButton *customDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[customDoneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[customDoneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[customDoneButton addTarget:self action:@selector(facebookViewControllerDoneWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	customDoneButton.frame = CGRectMake(self.view.bounds.size.width - 69.0, 0.0, 64.0, 44.0);
	[self.friendPickerHeaderView addSubview:customDoneButton];
	
}

#pragma mark - Custom Facebook Select Friends Search Methods
// Method to that adds a search bar to the built-in Friend Selector View.
// We add this search bar to the canvasView of the FBFriendPickerViewController.
- (void)addSearchBarToFriendPickerView
{
	if (self.searchBar == nil) {
		CGFloat searchBarHeight = 44.0;
		self.searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(0, 45.0, self.view.bounds.size.width, searchBarHeight)];
		self.searchBar.autoresizingMask = self.searchBar.autoresizingMask | UIViewAutoresizingFlexibleWidth;
		self.searchBar.tintColor = [UIColor colorWithWhite:0.75 alpha:1.0];
		self.searchBar.delegate = self;
		self.searchBar.showsCancelButton = NO;
		
		[self.friendPickerController.canvasView addSubview:self.friendPickerHeaderView];
		[self.friendPickerController.canvasView addSubview:self.searchBar];
		CGRect updatedFrame = self.friendPickerController.view.bounds;
		updatedFrame.size.height -= (fbHeaderHeight + searchBarHeight);
		updatedFrame.origin.y = fbHeaderHeight + searchBarHeight;
		self.friendPickerController.tableView.frame = updatedFrame;
		
		self.friendPickerController.parentViewController.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.3137 green:0.6431 blue:0.9333 alpha:1.0];
		//setBackgroundImage:[UIImage imageNamed:@"header"] forBarMetrics:UIBarMetricsDefault];
	}
	
	UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchBarSearchTextDidChange:)name:UITextFieldTextDidChangeNotification object:searchField];
}


// There is no delegate UISearchBarDelegate method for when text changes.
// This is a custom method using NSNotificationCenter
- (void)searchBarSearchTextDidChange:(NSNotification*)notification
{
	UITextField *searchField = notification.object;
	self.searchText = searchField.text;
	[self.friendPickerController updateView];
}

// Private Method that handles the search functionality
- (void)handleSearch:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	self.searchText = searchBar.text;
	[self.friendPickerController updateView];
}

// Method that actually does the sorting.
// This filters the data without having to call the server.
- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker shouldIncludeUser:(id<FBGraphUser>)user
{
	if (self.searchText && ![self.searchText isEqualToString:@""]) {
		NSRange result = [user.name rangeOfString:self.searchText options:NSCaseInsensitiveSearch];
		if (result.location != NSNotFound) {
			return YES;
		} else {
			return NO;
		}
	} else {
		return YES;
	}
	return YES;
}

#pragma mark - Facebook FBFriendPickerDelegate Methods
- (void)facebookViewControllerCancelWasPressed:(id)sender
{
	NSLog(@"Friend selection cancelled.");
	[self handlePickerDone];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender
{
	for (id<FBGraphUser> user in self.friendPickerController.selection) {
		NSLog(@"Friend selected: %@", user.name);
	}
	
	if (self.friendPickerController.selection.count == 0) {
		[[[UIAlertView alloc] initWithTitle:@"No Friend Selected"
											 message:@"You need to pick a friend."
											delegate:nil
								cancelButtonTitle:@"OK"
								otherButtonTitles:nil]
		 show];
		
		[self handlePickerDone];
	} else {
		
		_filename = [NSString stringWithFormat:@"%@_%@", [HONAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
		_fbID = [[self.friendPickerController.selection lastObject] objectForKey:@"id"];
		//_fbName = [[self.friendPickerController.selection lastObject] objectForKey:@"username"];
		NSLog(@"FRIEND:[%@]", [self.friendPickerController.selection lastObject]);
		
		[self handlePickerDone];
		//[self _goFriendChallenge];
	}
}

- (void)handlePickerDone
{
	self.searchBar = nil;
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	if (_focusTimer != nil) {
		[_focusTimer invalidate];
		_focusTimer = nil;
	}
	
	_subjectName = _cameraOverlayView.subjectName;
	
	[[Mixpanel sharedInstance] track:@"Take Photo"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];

	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	NSLog(@"ORIENTATION:[%d]", image.imageOrientation);
	if (image.imageOrientation != 0)
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
	
	[self _uploadPhoto:_challangeImage];
	
	NSString *challengerName = @"";
	if (_challengeVO != nil)
		challengerName = _challengeVO.creatorName;
	
	if (_userVO != nil)
		challengerName = _userVO.username;
	
	if (_imagePicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {		
		[self dismissViewControllerAnimated:NO completion:^(void) {
			[_cameraOverlayView showPreviewImage:image withUsername:challengerName];
		}];
		
	} else {
		if (_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
			[_cameraOverlayView showPreviewImageFlipped:image withUsername:challengerName];
	
		else
			[_cameraOverlayView showPreviewImage:image withUsername:challengerName];
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
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:nil];
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
	}
}


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
