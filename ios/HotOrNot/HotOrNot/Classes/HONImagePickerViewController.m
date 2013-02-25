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
#import "MBProgressHUD.h"
#import "UIImage+fixOrientation.h"
#import "Mixpanel.h"

#import "HONImagePickerViewController.h"
#import "HONAppDelegate.h"
#import "HONCameraOverlayView.h"
#import "HONChallengerPickerViewController.h"
#import "HONFacebookCaller.h"
#import "HONHeaderView.h"

@interface HONImagePickerViewController () <HONCameraOverlayViewDelegate>
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) NSString *iTunesPreview;
@property (nonatomic, strong) NSString *iTunesPreviewURL;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSString *fbID;
@property (nonatomic) int submitAction;
@property (nonatomic) int challengerID;
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
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadStateDidChangeNotification:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
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
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadStateDidChangeNotification:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
		
		_needsChallenger = NO;
	}
	
	return (self);
}

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Accept Challenge"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
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
		[[Mixpanel sharedInstance] track:@"Create Challenge - With Hashtag"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
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

- (id)initAsDailyChallenge:(NSString *)subject {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Create Challenge - Daily Challenge"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
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
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Take Challenge"];
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
	if (_subjectName.length > 0) {
		AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
		NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSString stringWithFormat:@"%d", 5], @"action",
										_subjectName, @"subjectName",
										nil];
		
		[httpClient postPath:kChallengesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSError *error = nil;
			if (error != nil) {
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
				
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
			_progressHUD.labelText = NSLocalizedString(@"Connection Error!", @"Status message when no network detected");
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
	
	_filename = [NSString stringWithFormat:@"%@_%@", [HONAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
	NSLog(@"https://hotornot-challenges.s3.amazonaws.com/%@", _filename);
	
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
		[s3 putObject:por1];
		 
		S3PutObjectRequest *por2 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_m.jpg", _filename] inBucket:@"hotornot-challenges"];
		por2.contentType = @"image/jpeg";
		por2.data = UIImageJPEGRepresentation(mImage, kJPEGCompress);
		[s3 putObject:por2];
		
		S3PutObjectRequest *por3 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_l.jpg", _filename] inBucket:@"hotornot-challenges"];
		por3.contentType = @"image/jpeg";
		por3.data = UIImageJPEGRepresentation(lImage, kJPEGCompress);
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

- (void)_submitChallenge {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:[NSString stringWithFormat:@"%d", _submitAction] forKey:@"action"];
	[params setObject:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[params setObject:[NSString stringWithFormat:@"https://hotornot-challenges.s3.amazonaws.com/%@", _filename] forKey:@"imgURL"];
	
	if (_submitAction == 1)
		[params setObject:_subjectName forKey:@"subject"];
	
	else if (_submitAction == 4)
		[params setObject:[NSString stringWithFormat:@"%d", _challengeVO.challengeID] forKey:@"challengeID"];
	
	else if (_submitAction == 8) {
		[params setObject:_subjectName forKey:@"subject"];
		[params setObject:_fbID forKey:@"fbID"];
		
	} else if (_submitAction == 9) {
		[params setObject:_subjectName forKey:@"subject"];
		[params setObject:[NSString stringWithFormat:@"%d", _challengerID] forKey:@"challengerID"];
	}
	
	[httpClient postPath:kChallengesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"Download Failed", @"Status message when downloading fails");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
			
		} else {
			NSDictionary *challengeResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			
			[_progressHUD hide:YES];
			_progressHUD = nil;
			
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:nil];
			
			[HONFacebookCaller postToTimeline:[HONChallengeVO challengeWithDictionary:challengeResult]];
			
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
			}];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"ImagePickerViewController AFNetworking %@", [error localizedDescription]);
		
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
	
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
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
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
	}];
}

- (void)cameraOverlayViewClosePreview:(HONCameraOverlayView *)cameraOverlayView {
	[_cameraOverlayView hidePreview];
	[self _acceptPhoto];
}

- (void)cameraOverlayViewRandomSubject:(HONCameraOverlayView *)cameraOverlayView subject:(NSString *)subjectName {
	_subjectName = subjectName;
	[_cameraOverlayView setSubjectName:_subjectName];
	
	if (_mpMoviePlayerController != nil) {
		[_mpMoviePlayerController stop];
		_mpMoviePlayerController = nil;
	}
	
	[self _playAudio];
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

- (void)cameraOverlayViewPreviewBack:(HONCameraOverlayView *)cameraOverlayView {
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
	
	[self _uploadPhoto:_challangeImage];
	
	if (_imagePicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {		
		[self dismissViewControllerAnimated:NO completion:^(void) {
			[self _acceptPhoto];
		}];
		
	} else {
		if (_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
			[_cameraOverlayView showPreviewFlipped:image];
	
		else
			[_cameraOverlayView showPreview:image];
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
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
	}
}



- (void)_acceptPhoto {
	UIImage *image = _challangeImage;
	
	if (_mpMoviePlayerController != nil) {
		[_mpMoviePlayerController stop];
		_mpMoviePlayerController = nil;
	}
	
	if (!_needsChallenger) {
		[[Mixpanel sharedInstance] track:@"Submit Challenge"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"],
													  [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if ([_subjectName length] == 0)
			_subjectName = [HONAppDelegate rndDefaultSubject];
		
		AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
		
		NSString *filename = [NSString stringWithFormat:@"%@_%@", [HONAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
		NSLog(@"https://hotornot-challenges.s3.amazonaws.com/%@", filename);
		
		@try {
			float ratio = image.size.height / image.size.width;
			
			UIImage *lImage = [HONAppDelegate scaleImage:image toSize:CGSizeMake(kLargeW, kLargeW * ratio)];
			lImage = [HONAppDelegate cropImage:lImage toRect:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
			
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
			
			S3PutObjectRequest *por2 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_m.jpg", filename] inBucket:@"hotornot-challenges"];
			por2.contentType = @"image/jpeg";
			por2.data = UIImageJPEGRepresentation(mImage, kJPEGCompress);
			[s3 putObject:por2];
			
			S3PutObjectRequest *por3 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_l.jpg", filename] inBucket:@"hotornot-challenges"];
			por3.contentType = @"image/jpeg";
			por3.data = UIImageJPEGRepresentation(lImage, kJPEGCompress);
			[s3 putObject:por3];
			
			AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
			NSMutableDictionary *params = [NSMutableDictionary dictionary];
			[params setObject:[NSString stringWithFormat:@"%d", _submitAction] forKey:@"action"];
			[params setObject:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
			[params setObject:[NSString stringWithFormat:@"https://hotornot-challenges.s3.amazonaws.com/%@", filename] forKey:@"imgURL"];
			
			if (_submitAction == 1)
				[params setObject:_subjectName forKey:@"subject"];
			
			else if (_submitAction == 4)
				[params setObject:[NSString stringWithFormat:@"%d", _challengeVO.challengeID] forKey:@"challengeID"];
			
			else if (_submitAction == 8) {
				[params setObject:_subjectName forKey:@"subject"];
				[params setObject:_fbID forKey:@"fbID"];
			
			} else if (_submitAction == 9) {
				[params setObject:_subjectName forKey:@"subject"];
				[params setObject:[NSString stringWithFormat:@"%d", _challengerID] forKey:@"challengerID"];
			}
			
			[httpClient postPath:kChallengesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
				NSError *error = nil;
				if (error != nil) {
					NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
					_progressHUD.minShowTime = kHUDTime;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
					_progressHUD.labelText = NSLocalizedString(@"Download Failed", @"Status message when downloading fails");
					[_progressHUD show:NO];
					[_progressHUD hide:YES afterDelay:1.5];
					_progressHUD = nil;
					
				} else {
					NSDictionary *challengeResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
					
					[_progressHUD hide:YES];
					_progressHUD = nil;
					
					[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:nil];
					
					[HONFacebookCaller postToTimeline:[HONChallengeVO challengeWithDictionary:challengeResult]];
					[HONFacebookCaller postToFriendTimeline:_fbID challenge:[HONChallengeVO challengeWithDictionary:challengeResult]];
					
					[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
					}];
				}
				
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				NSLog(@"ImagePickerViewController AFNetworking %@", [error localizedDescription]);
				
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
		
		NSLog(@"_imagePicker.cameraDevice:[%d]", _imagePicker.cameraDevice);
		NSLog(@"sourceType:[%d]", _imagePicker.sourceType);
		NSLog(@"UIImagePickerControllerSourceTypeCamera:[%d]", UIImagePickerControllerSourceTypeCamera);
		NSLog(@"UIImagePickerControllerSourceTypePhotoLibrary:[%d]", UIImagePickerControllerSourceTypePhotoLibrary);
		
		if (_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront && _imagePicker.sourceType != UIImagePickerControllerSourceTypePhotoLibrary)
			[self.navigationController pushViewController:[[HONChallengerPickerViewController alloc] initWithFlippedImage:image subjectName:_subjectName] animated:NO];
		
		else
			[self.navigationController pushViewController:[[HONChallengerPickerViewController alloc] initWithImage:image subjectName:_subjectName] animated:NO];
		
		_hasPlayedAudio = NO;
	}
}

@end
