//
//  HONImagePickerViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.09.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import <AWSiOSSDK/S3/AmazonS3Client.h>
#import <AVFoundation/AVFoundation.h>
//#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "Mixpanel.h"
#import "UIImage+fixOrientation.h"

#import "HONAppDelegate.h"
#import "HONImagePickerViewController.h"
#import "HONImagingDepictor.h"
#import "HONSnapCameraOverlayView.h"
#import "HONCreateChallengePreviewView.h"
#import "HONAddContactsViewController.h"
#import "HONUserVO.h"
#import "HONOpponentVO.h"
#import "HONContactUserVO.h"


const CGFloat kFocusInterval = 0.5f;

@interface HONImagePickerViewController () <UIAlertViewDelegate, AmazonServiceRequestDelegate, HONSnapCameraOverlayViewDelegate, HONCreateChallengePreviewViewDelegate>
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) NSString *challengerName;
@property (nonatomic, strong) NSMutableArray *addFollowing;
@property (nonatomic, strong) NSMutableArray *addFollowingIDs;
@property (nonatomic, strong) NSMutableArray *addContacts;
@property (nonatomic, strong) NSMutableArray *usernames;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSString *fbID;
@property (readonly, nonatomic, assign) HONChallengeSubmitType challengeSubmitType;
@property (nonatomic) BOOL isPrivate;
@property (nonatomic) HONUserVO *userVO;
@property (nonatomic) int uploadCounter;
@property (nonatomic, strong) NSArray *s3Uploads;
@property (readonly, nonatomic, assign) HONChallengeExpireType challengeExpireType;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic) BOOL isFirstAppearance;
@property (nonatomic) BOOL hasSubmitted;
@property (nonatomic, strong) NSTimer *focusTimer;
@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, strong) HONSnapCameraOverlayView *cameraOverlayView;
@property (nonatomic, strong) HONCreateChallengePreviewView *previewView;
@property (nonatomic, strong) UIView *plCameraIrisAnimationView;  // view that animates the opening/closing of the iris
@property (nonatomic, strong) UIImageView *cameraIrisImageView;  // static image of the closed iris
@property (nonatomic, strong) UIImage *challangeImage;
@property (nonatomic, strong) UIImage *rawImage;
@property (nonatomic, strong) UIImageView *submitImageView;
@end

@implementation HONImagePickerViewController

- (id)init {
	if ((self = [super init])) {
		NSLog(@"%@ - init", [self description]);
		self.view.backgroundColor = [UIColor blackColor];
		_subjectName = @"";//[HONAppDelegate rndDefaultSubject];
		_challengeSubmitType = HONChallengeSubmitTypeMatch;
		_challengerName = @"";
		_isFirstAppearance = YES;
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithUser:(HONUserVO *)userVO {
	if ((self = [super init])) {
		NSLog(@"%@ - initWithUser:[%d/%@]", [self description], userVO.userID, userVO.username);
		_subjectName = @"";//[HONAppDelegate rndDefaultSubject];
		_userVO = userVO;
		_challengerName = userVO.username;
		_challengeSubmitType = HONChallengeSubmitTypeOpponentID;
		_isFirstAppearance = YES;
		_isPrivate = NO;
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithSubject:(NSString *)subject {
	if ((self = [super init])) {
		NSLog(@"%@ - initWithSubject:[%@]", [self description], subject);
		_subjectName = subject;
		_challengeSubmitType = HONChallengeSubmitTypeMatch;
		_challengerName = @"";
		_isFirstAppearance = YES;
		_isPrivate = NO;
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithUser:(HONUserVO *)userVO withSubject:(NSString *)subject {
	if ((self = [super init])) {
		NSLog(@"%@ - initWithUser:[%d/%@] subject:[%@]", [self description], userVO.userID, userVO.username, subject);
		_subjectName = subject;
		_userVO = userVO;
		_challengerName = userVO.username;
		_challengeSubmitType = HONChallengeSubmitTypeOpponentID;
		_isFirstAppearance = YES;
		_isPrivate = NO;
		
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		NSLog(@"%@ - initWithChallenge:[%d]", [self description], vo.challengeID);
		_challengeVO = vo;
		_fbID = vo.creatorVO.fbID;
		_subjectName = vo.subjectName;
		_challengeSubmitType = HONChallengeSubmitTypeAccept;
		_challengerName = (_challengeVO.creatorVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? ((HONOpponentVO *)[_challengeVO.challengers lastObject]).username : _challengeVO.creatorVO.username;;
		_isFirstAppearance = YES;
		_isPrivate = NO;//vo.isPrivate;
		[self _registerNotifications];
	}
	
	return (self);
}

- (id)initWithJoinChallenge:(HONChallengeVO *)vo {
	NSLog(@"%@ - initWithJoinChallenge:[%d] (%d/%d)", [self description], vo.challengeID, vo.creatorVO.userID, ((HONOpponentVO *)[vo.challengers lastObject]).userID);
	if ((self = [super init])) {
		_challengeVO = vo;
		_fbID = vo.creatorVO.fbID;
		_subjectName = vo.subjectName;
		_challengeSubmitType = HONChallengeSubmitTypeJoin;
		_challengerName = @"";
		_isFirstAppearance = YES;
		_isPrivate = NO;//vo.isPrivate;
		[self _registerNotifications];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"PLCameraControllerPreviewStartedNotification" object:nil];
}

- (BOOL)shouldAutorotate {
	return (NO);
}

- (void)_registerNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_notificationReceived:)
												 name:nil
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_didShowViewController:)
												 name:@"UINavigationControllerDidShowViewControllerNotification"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_previewStarted:)
												 name:@"PLCameraControllerPreviewStartedNotification"
											   object:nil];
}


#pragma mark - Data Calls
- (void)_uploadPhoto:(UIImage *)image {
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	_uploadCounter = 0;
	
	_filename = [NSString stringWithFormat:@"%@_%@", [HONAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
	NSLog(@"FILE PREFIX: %@/%@", [HONAppDelegate s3BucketForType:@"challenges"], _filename);
	
//	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
//	_progressHUD.labelText = NSLocalizedString(@"hud_uploadPhoto", nil);
//	_progressHUD.mode = MBProgressHUDModeIndeterminate;
//	_progressHUD.minShowTime = kHUDTime;
//	_progressHUD.taskInProgress = YES;
	
	@try {
		UIImage *oImage = _rawImage;
		UIImage *lImage = [HONImagingDepictor scaleImage:image toSize:CGSizeMake(kSnapLargeDim * 2.0, kSnapLargeDim * 2.0)];
		UIImage *mImage = [HONImagingDepictor scaleImage:image toSize:CGSizeMake(kSnapMediumDim * 2.0, kSnapMediumDim * 2.0)];
		//UIImage *tImage = [HONImagingDepictor scaleImage:image toSize:CGSizeMake(kSnapThumbDim * 2.0, kSnapThumbDim * 2.0)];
		
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-challenges"]];
		
		//stream.delay = 0.2;
		//stream.packetSize = 16;
		
		S3PutObjectRequest *por1 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_m.jpg", _filename] inBucket:@"hotornot-challenges"];
		por1.delegate = self;
		por1.contentType = @"image/jpeg";
//		por1.data = UIImageJPEGRepresentation(mImage, kSnapJPEGCompress);
		por1.contentLength = [UIImageJPEGRepresentation(mImage, kSnapJPEGCompress) length];
		por1.stream = [S3UploadInputStream inputStreamWithData:UIImageJPEGRepresentation(mImage, kSnapJPEGCompress)];
		[s3 putObject:por1];
		
		S3PutObjectRequest *por2 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_l.jpg", _filename] inBucket:@"hotornot-challenges"];
		por2.delegate = self;
		por2.contentType = @"image/jpeg";
//		por2.data = UIImageJPEGRepresentation(lImage, kSnapJPEGCompress);
		por2.contentLength = [UIImageJPEGRepresentation(lImage, kSnapJPEGCompress) length];
		por2.stream = [S3UploadInputStream inputStreamWithData:UIImageJPEGRepresentation(lImage, kSnapJPEGCompress)];
		[s3 putObject:por2];
		
		S3PutObjectRequest *por3 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_o.jpg", _filename] inBucket:@"hotornot-challenges"];
		por3.delegate = self;
		por3.contentType = @"image/jpeg";
//		por3.data = UIImageJPEGRepresentation(oImage, kSnapJPEGCompress);
		por3.contentLength = [UIImageJPEGRepresentation(oImage, kSnapJPEGCompress) length];
		por3.stream = [S3UploadInputStream inputStreamWithData:UIImageJPEGRepresentation(oImage, kSnapJPEGCompress)];
		[s3 putObject:por3];
		
		_s3Uploads = [NSArray arrayWithObjects:por1, por2, por3, nil];
		
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

- (void)_submitChallenge:(NSMutableDictionary *)params {
	_submitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(81.0, ([UIScreen mainScreen].bounds.size.height - 124.0) * 0.5, 150.0, 124.0)];
	_submitImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"overlayLoader001"],
										[UIImage imageNamed:@"overlayLoader002"],
										[UIImage imageNamed:@"overlayLoader003"], nil];
	_submitImageView.animationDuration = 0.5f;
	_submitImageView.animationRepeatCount = 0;
	_submitImageView.alpha = 0.0;
	[_submitImageView startAnimating];
	[[[UIApplication sharedApplication] delegate].window addSubview:_submitImageView];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_submitImageView.alpha = 1.0;
	} completion:nil];
	
	_hasSubmitted = NO;
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], (_challengeSubmitType == HONChallengeSubmitTypeJoin) ? kAPIJoinChallenge : kAPIChallenges, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:(_challengeSubmitType == HONChallengeSubmitTypeJoin) ? kAPIJoinChallenge : kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_dlFailed", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			NSDictionary *challengeResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@ %@", [[self class] description], challengeResult);
			
			if (_uploadCounter == [_s3Uploads count]) {
				[UIView animateWithDuration:0.5 animations:^(void) {
					_submitImageView.alpha = 0.0;
				} completion:^(BOOL finished) {
					[_submitImageView removeFromSuperview];
					_submitImageView = nil;
				}];
			}
			
			if ([[challengeResult objectForKey:@"result"] isEqualToString:@"fail"]) {
				if (_progressHUD == nil)
					_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = NSLocalizedString(@"hud_usernameNotFound", nil);
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:kHUDErrorTime];
				_progressHUD = nil;
				
			} else {
				///[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:@"Y"];
				
				_hasSubmitted = YES;
				if (_uploadCounter == [_s3Uploads count]) {
					if (_imagePicker.parentViewController != nil) {
						[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
							[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
						}];
						
					} else
						[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
				}
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
		
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


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	_challengeExpireType = HONChallengeExpireTypeNone;
	_isPrivate = NO;
	_addContacts = [NSMutableArray array];
	_addFollowing = [NSMutableArray array];
	_addFollowingIDs = [NSMutableArray array];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
		
	if (_isFirstAppearance) {
		_isFirstAppearance = NO;
		
		[self _showCamera];
		//[self performSelector:@selector(_showCamera) withObject:nil afterDelay:0.25];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	//_isFirstAppearance = YES;
}


#pragma mark - UI Presentation
- (void)_removeIris {
	if (_imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
		
		if (_cameraIrisImageView != nil) {
			_cameraIrisImageView.hidden = YES;
			[_cameraIrisImageView removeFromSuperview];
		}
		
		if (_plCameraIrisAnimationView != nil) {
			_plCameraIrisAnimationView.hidden = YES;
			[_plCameraIrisAnimationView removeFromSuperview];
		}
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

- (void)_showCamera {
	//NSLog(@"_showCamera");
	
	_imagePicker = [[UIImagePickerController alloc] init];
	_imagePicker.delegate = self;
	_imagePicker.navigationBarHidden = YES;
	_imagePicker.toolbarHidden = YES;
	_imagePicker.allowsEditing = NO;
	
	if (_challengeSubmitType == HONChallengeSubmitTypeOpponentID && [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != _userVO.userID) {
		[_addFollowing addObject:_userVO];
		[_addFollowingIDs addObject:[NSNumber numberWithInt:_userVO.userID]];
		
	} else if (_challengeSubmitType == HONChallengeSubmitTypeJoin) {
		if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != _challengeVO.creatorVO.userID) {
			[_addFollowing addObject:[HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
																	[NSString stringWithFormat:@"%d", _challengeVO.creatorVO.userID], @"id",
																	[NSString stringWithFormat:@"%d", 0], @"points",
																	[NSString stringWithFormat:@"%d", 0], @"votes",
																	[NSString stringWithFormat:@"%d", 0], @"pokes",
																	[NSString stringWithFormat:@"%d", 0], @"pics",
																	[NSString stringWithFormat:@"%d", 0], @"age",
																	_challengeVO.creatorVO.username, @"username",
																	_challengeVO.creatorVO.fbID, @"fb_id",
																	_challengeVO.creatorVO.avatarURL, @"avatar_url", nil]]];
			[_addFollowingIDs addObject:[NSNumber numberWithInt:_challengeVO.creatorVO.userID]];
		}
		
		for (HONOpponentVO *vo in _challengeVO.challengers) {
			if ([vo.imagePrefix length] > 0 && vo.userID != [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) {
				
				BOOL isFound = NO;
				for (NSNumber *userID in _addFollowingIDs) {
					if ([userID intValue] == vo.userID) {
						isFound = YES;
						break;
					}
				}
				
				if (!isFound) {
					[_addFollowing addObject:[HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
																			[NSString stringWithFormat:@"%d", vo.userID], @"id",
																			[NSString stringWithFormat:@"%d", 0], @"points",
																			[NSString stringWithFormat:@"%d", 0], @"votes",
																			[NSString stringWithFormat:@"%d", 0], @"pokes",
																			[NSString stringWithFormat:@"%d", 0], @"pics",
																			[NSString stringWithFormat:@"%d", 0], @"age",
																			vo.username, @"username",
																			vo.fbID, @"fb_id",
																			vo.avatarURL, @"avatar_url", nil]]];
					[_addFollowingIDs addObject:[NSNumber numberWithInt:vo.userID]];
				}
			}
		}
	
	} else if (_challengeSubmitType == HONChallengeSubmitTypeMatch) {
		for (HONUserVO *vo in [HONAppDelegate friendsList]) {
			if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != vo.userID) {
				BOOL isFound = NO;
				for (NSNumber *userID in _addFollowingIDs) {
					if ([userID intValue] == vo.userID) {
						isFound = YES;
						break;
					}
				}
				
				if (!isFound) {
					[_addFollowing addObject:[HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
																			[NSString stringWithFormat:@"%d", vo.userID], @"id",
																			[NSString stringWithFormat:@"%d", 0], @"points",
																			[NSString stringWithFormat:@"%d", 0], @"votes",
																			[NSString stringWithFormat:@"%d", 0], @"pokes",
																			[NSString stringWithFormat:@"%d", 0], @"pics",
																			[NSString stringWithFormat:@"%d", 0], @"age",
																			vo.username, @"username",
																			vo.fbID, @"fb_id",
																			vo.imageURL, @"avatar_url", nil]]];
					[_addFollowingIDs addObject:[NSNumber numberWithInt:vo.userID]];
				}
			}
		}
	}
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		_imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		
		// these two fuckers don't work in ios7 right now!!
		_imagePicker.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		_imagePicker.showsCameraControls = NO;
		// ---------------------------------------------------------------------------
		
		_imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		_imagePicker.cameraViewTransform = CGAffineTransformScale(_imagePicker.cameraViewTransform, ([HONAppDelegate isRetina5]) ? 1.5f : 1.25f, ([HONAppDelegate isRetina5]) ? 1.5f : 1.25f);
		
		if (_cameraOverlayView == nil) {
			_cameraOverlayView = [[HONSnapCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds withSubject:_subjectName withUsername:_challengerName];
			_cameraOverlayView.delegate = self;
		}
		
	} else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	}
	
	///[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	[self presentViewController:_imagePicker animated:NO completion:^(void) {
	}];
}

- (void)_showOverlay {
	[_cameraOverlayView intro];
	[_cameraOverlayView updateChallengers:[_addFollowing copy] asJoining:(_challengeSubmitType == HONChallengeSubmitTypeJoin)];
	_imagePicker.cameraOverlayView = _cameraOverlayView;
}

- (void)_autofocusCamera {
	NSArray *devices = [AVCaptureDevice devices];
	NSError *error;
	
	for (AVCaptureDevice *device in devices) {
		if ([device position] == AVCaptureDevicePositionBack) {
			[device lockForConfiguration:&error];
			
			if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
            device.focusMode = AVCaptureFocusModeAutoFocus;
			
			[device unlockForConfiguration];
		}
	}
}

- (void)_restartProgress {
	[_cameraOverlayView startProgress];
}

- (void)_takePhoto {
	
	if (_progressTimer != nil) {
		[_progressTimer invalidate];
		_progressTimer = nil;
	}
	
	if (_focusTimer != nil) {
		[_focusTimer invalidate];
		_focusTimer = nil;
	}
	
	[_cameraOverlayView takePhoto];
	[_imagePicker takePicture];
}


#pragma mark - Navigation
- (void)_goCloseInfoOverlay {
	[_cameraOverlayView toggleInfoOverlay:NO];
	
	[[Mixpanel sharedInstance] track:@"Create Volley - Close Overlay"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if (_progressTimer != nil) {
		[_progressTimer invalidate];
		_progressTimer = nil;
	}
	
	[_cameraOverlayView startProgress];
	_progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.6 target:self selector:@selector(_takePhoto) userInfo:nil repeats:NO];
}


#pragma mark - Notifications
- (void)_notificationReceived:(NSNotification *)notification {
	//NSLog(@"_notificationReceived:[%@]", [notification name]);
}


- (void)_didShowViewController:(NSNotification *)notification {
	//NSLog(@"_didShowViewController:[%@]", [notification object]);
	
	//_isFirstAppearance = YES;
}


- (void)_previewStarted:(NSNotification *)notification {
	//NSLog(@"_previewStarted");
	
//	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
//		[self _removeIris];
	
	[self _showOverlay];
	
	int camera_total = 0;
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"camera_total"])
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:camera_total] forKey:@"camera_total"];
	
	else {
		camera_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"camera_total"] intValue];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++camera_total] forKey:@"camera_total"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	if (_progressTimer != nil) {
		[_progressTimer invalidate];
		_progressTimer = nil;
	}
	
	if (camera_total == 0) {
		[_cameraOverlayView toggleInfoOverlay:YES];
		
		UIButton *infoOverlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
		infoOverlayButton.frame = _cameraOverlayView.frame;
		[infoOverlayButton addTarget:self action:@selector(_goCloseInfoOverlay) forControlEvents:UIControlEventTouchUpInside];
		[_cameraOverlayView addSubview:infoOverlayButton];
		
		[_cameraOverlayView startProgress];
		_progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.6 target:self selector:@selector(_restartProgress) userInfo:nil repeats:YES];
		
	} else {
		[_cameraOverlayView startProgress];
		_progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.6 target:self selector:@selector(_takePhoto) userInfo:nil repeats:NO];
	}
	
	//_focusTimer = [NSTimer scheduledTimerWithTimeInterval:kFocusInterval target:self selector:@selector(_autofocusCamera) userInfo:nil repeats:YES];
}


#pragma mark - NavigationController Delegates
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	//NSLog(@"navigationController:[%@] willShowViewController:[%@]", [navigationController description], [viewController description]);
	
	navigationController.navigationBar.barStyle = UIBarStyleDefault;
	
	if (_imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
		if ([[viewController.view subviews] objectAtIndex:1] != nil)
			_cameraIrisImageView = [[viewController.view subviews] objectAtIndex:1];
		
		if ([[[viewController.view subviews] objectAtIndex:2] subviews] != nil)
			_plCameraIrisAnimationView = [[[[viewController.view subviews] objectAtIndex:2] subviews] objectAtIndex:0];
		
		
//		NSLog(@"VC:view:subviews\n %@\n\n", [[viewController view] subviews]);
//
//		UIView *uiView = [[[viewController view] subviews] objectAtIndex:0];
//		NSLog(@"VC:view:UIView:subviews\n %@\n\n", [uiView subviews]);
//			UIView *PLCameraPreviewView = [[uiView subviews] objectAtIndex:0];
//			NSLog(@"VC:view:PLCameraPreviewView:subviews\n %@\n\n", [PLCameraPreviewView subviews]);
//
//		UIView *uiImageView = [[[viewController view] subviews] objectAtIndex:1];
//		NSLog(@"VC:view:UIImageView:subviews\n %@\n\n", [uiImageView subviews]);
//			
//		UIView *PLCropOverlay = [[[viewController view] subviews] objectAtIndex:2];
//		NSLog(@"VC:view:PLCropOverlay:subviews\n %@\n\n", [PLCropOverlay subviews]);
//			UIView *PLCameraIrisAnimationView = [[PLCropOverlay subviews] objectAtIndex:0];
//			NSLog(@"VC:view:PLCropOverlay:PLCameraIrisAnimationView:subviews\n %@\n\n", [PLCameraIrisAnimationView subviews]);
	}
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	//NSLog(@"navigationController:[%@] didShowViewController:[%@]", [navigationController description], [viewController description]);
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		[self _removeIris];
	
//	NSLog(@"VC:view:subviews\n %@\n\n", [[viewController view] subviews]);
//
//	UIView *uiView = [[[viewController view] subviews] objectAtIndex:0];
//	NSLog(@"VC:view:UIView:subviews\n %@\n\n", [uiView subviews]);
//	UIView *PLCameraPreviewView = [[uiView subviews] objectAtIndex:0];
//	NSLog(@"VC:view:PLCameraPreviewView:subviews\n %@\n\n", [PLCameraPreviewView subviews]);
//	
//	UIView *uiImageView = [[[viewController view] subviews] objectAtIndex:1];
//	NSLog(@"VC:view:UIImageView:subviews\n %@\n\n", [uiImageView subviews]);
//	
//	UIView *PLCropOverlay = [[[viewController view] subviews] objectAtIndex:2];
//	NSLog(@"VC:view:PLCropOverlay:subviews\n %@\n\n", [PLCropOverlay subviews]);
//	UIView *PLCameraIrisAnimationView = [[PLCropOverlay subviews] objectAtIndex:0];
//	NSLog(@"VC:view:PLCropOverlay:PLCameraIrisAnimationView:subviews\n %@\n\n", [PLCameraIrisAnimationView subviews]);
//	UIView *PLCropOverlayBottomBar = [[PLCropOverlay subviews] objectAtIndex:1];
//	NSLog(@"VC:view:PLCropOverlay:PLCropOverlayBottomBar:subviews\n %@\n\n", [PLCropOverlayBottomBar subviews]);
}


#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	if (_focusTimer != nil) {
		[_focusTimer invalidate];
		_focusTimer = nil;
	}
	
	_rawImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	if (_rawImage.imageOrientation != 0)
		_rawImage = [_rawImage fixOrientation];
	
	NSLog(@"RAW IMAGE:[%@]", NSStringFromCGSize(_rawImage.size));
	
	// image is wider than tall (800x600)
	if (_rawImage.size.width > _rawImage.size.height) {
		float offset = (_rawImage.size.width - _rawImage.size.height) * 0.5;
		_challangeImage = [HONImagingDepictor cropImage:_rawImage toRect:CGRectMake(offset, 0.0, _rawImage.size.height, _rawImage.size.height)];
		
		// image is taller than wide (600x800)
	} else if (_rawImage.size.width < _rawImage.size.height) {
		float offset = (_rawImage.size.height - _rawImage.size.width) * 0.5;
		_challangeImage = [HONImagingDepictor cropImage:_rawImage toRect:CGRectMake(0.0, offset, _rawImage.size.width, _rawImage.size.width)];
		
		// image is square
	} else
		_challangeImage = _rawImage;
	
	
	_usernames = [NSMutableArray array];
	for (HONUserVO *vo in _addFollowing)
		[_usernames addObject:vo.username];
	
	for (HONContactUserVO *vo in _addContacts)
		[_usernames addObject:vo.fullName];
	
	_previewView = [[HONCreateChallengePreviewView alloc] initWithFrame:[UIScreen mainScreen].bounds withSubject:_subjectName withMirroredImage:_rawImage];
	_previewView.delegate = self;
	[_previewView setOpponents:[_addFollowing copy] asJoining:(_challengeSubmitType == HONChallengeSubmitTypeJoin) redrawTable:YES];
	[_previewView showKeyboard];
	
	[_cameraOverlayView submitStep:_previewView];
		
	[self _uploadPhoto:_challangeImage];
	
	
	int friend_total = 0;
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"friend_total"]) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:friend_total] forKey:@"friend_total"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	} else {
		friend_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"friend_total"] intValue];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++friend_total] forKey:@"friend_total"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	NSLog(@"imagePickerControllerDidCancel");
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		_imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;

	else {
		[self dismissViewControllerAnimated:YES completion:^(void) {
			///[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
		}];
	}
}


#pragma mark - CameraOverlay Delegates
- (void)cameraOverlayView:(HONSnapCameraOverlayView *)cameraOverlayView toggleLongPress:(BOOL)isPressed {
	if (isPressed) {
		[[Mixpanel sharedInstance] track:@"Create Volley - Long Press"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	}
	
	if (_progressTimer){
		[_progressTimer invalidate];
		_progressTimer = nil;
	}
	
	if (!isPressed) {
		[_cameraOverlayView startProgress];
		_progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.6 target:self selector:@selector(_takePhoto) userInfo:nil repeats:NO];
	}
}

- (void)cameraOverlayViewShowCameraRoll:(HONSnapCameraOverlayView *)cameraOverlayView {
	_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)cameraOverlayViewChangeCamera:(HONSnapCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Create Volley - Flip Camera"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  (_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront) ? @"rear" : @"front", @"type", nil]];
	
	if (_progressTimer){
		[_progressTimer invalidate];
		_progressTimer = nil;
	}
	
	_imagePicker.cameraDevice = (_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront) ? UIImagePickerControllerCameraDeviceRear : UIImagePickerControllerCameraDeviceFront;
	
	[_cameraOverlayView startProgress];
	_progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.6 target:self selector:@selector(_takePhoto) userInfo:nil repeats:NO];
}

- (void)cameraOverlayViewCameraBack:(HONSnapCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Create Volley - Back"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	for (S3PutObjectRequest *por in _s3Uploads)
		[por.urlConnection cancel];
	
	if (_progressTimer){
		[_progressTimer invalidate];
		_progressTimer = nil;
	}
	
	[_cameraOverlayView startProgress];
	_progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.6 target:self selector:@selector(_takePhoto) userInfo:nil repeats:NO];
}

- (void)cameraOverlayViewCloseCamera:(HONSnapCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Create Volley - Cancel"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if (_focusTimer != nil) {
		[_focusTimer invalidate];
		_focusTimer = nil;
	}
	
	if (_progressTimer){
		[_progressTimer invalidate];
		_progressTimer = nil;
	}
	
	for (S3PutObjectRequest *por in _s3Uploads)
		[por.urlConnection cancel];
	
	[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
		///[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
	}];
}


#pragma mark - PreviewView Delegates
- (void)previewView:(HONCreateChallengePreviewView *)previewView removeChallenger:(HONUserVO *)userVO {
	[[Mixpanel sharedInstance] track:@"Create Volley - Remove Opponent"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", userVO.userID, userVO.username], @"challenger", nil]];
	
	NSMutableArray *removeVOs = [NSMutableArray array];
	for (HONUserVO *vo in _addFollowing) {
		if (vo.userID == userVO.userID) {
			[removeVOs addObject:vo];
			break;
		}
	}
	
	[_addFollowing removeObjectsInArray:removeVOs];
	removeVOs = nil;
	
	[_previewView setOpponents:[_addFollowing copy] asJoining:(_challengeSubmitType == HONChallengeSubmitTypeJoin) redrawTable:YES];
}

- (void)previewViewBackToCamera:(HONCreateChallengePreviewView *)previewView {
	NSLog(@"previewViewBackToCamera");
	
	[[Mixpanel sharedInstance] track:@"Create Volley - Retake Photo"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	for (S3PutObjectRequest *por in _s3Uploads)
		[por.urlConnection cancel];
	
	if (_progressTimer != nil) {
		[_progressTimer invalidate];
		_progressTimer = nil;
	}
	
	[_cameraOverlayView startProgress];
	_progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.6 target:self selector:@selector(_takePhoto) userInfo:nil repeats:NO];
}

- (void)previewView:(HONCreateChallengePreviewView *)previewView changeSubject:(NSString *)subject {
	NSLog(@"previewView:changeSubject:[%@]", subject);
	_subjectName = subject;	
}

- (void)previewViewClose:(HONCreateChallengePreviewView *)previewView {
	[[Mixpanel sharedInstance] track:@"Create Volley - Close"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	for (S3PutObjectRequest *por in _s3Uploads)
		[por.urlConnection cancel];
	
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)previewViewSubmit:(HONCreateChallengePreviewView *)previewView {
	[[Mixpanel sharedInstance] track:@"Create Volley - Submit"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	int friend_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"friend_total"] intValue];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++friend_total] forKey:@"friend_total"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	//if ([[HONAppDelegate friendsList] count] > 1) {
	if ([[HONAppDelegate friendsList] count] == 1 && friend_total == 0) {
		UIAlertView *alertView = [[UIAlertView alloc]
								  initWithTitle:@"Find Friends"
								  message:@"Volley is more fun with friends! Find some now?"
								  delegate:self
								  cancelButtonTitle:@"Yes"
								  otherButtonTitles:@"No", nil];
		[alertView setTag:2];
		[alertView show];
	
	} else {
		if ([_subjectName length] == 0)
			_subjectName = [HONAppDelegate rndDefaultSubject];
		
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   [[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									   [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:@"challenges"], _filename], @"imgURL",
									   [NSString stringWithFormat:@"%d", _challengeExpireType], @"expires",
									   _subjectName, @"subject",
									   _challengerName, @"username",
									   (_isPrivate) ? @"Y" : @"N", @"isPrivate", nil];
		
		if ([_addFollowing count] > 0) {
			NSString *usernames = @"";
			for (HONUserVO *vo in _addFollowing)
				usernames = [usernames stringByAppendingFormat:@"%@|", vo.username];
			
			[params setObject:[usernames substringToIndex:[usernames length] - 1] forKey:@"usernames"];
		}
		
		if (_challengeVO != nil)
			[params setObject:[NSString stringWithFormat:@"%d", _challengeVO.challengeID] forKey:@"challengeID"];
		
		if (_userVO != nil)
			[params setObject:[NSString stringWithFormat:@"%d", _userVO.userID] forKey:@"challengerID"];
		
		if (_fbID != nil)
			[params setObject:_fbID forKey:@"fbID"];
		
		[params setObject:[NSString stringWithFormat:@"%d", _challengeSubmitType] forKey:@"action"];
		
		NSLog(@"PARAMS:[%@]", params);
		[self _submitChallenge:params];
	}
}


#pragma mark - AWS Delegates
- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
	//NSLog(@"\nAWS didCompleteWithResponse:\n%@", response);
	
	_uploadCounter++;
	if (_uploadCounter == [_s3Uploads count]) {
		if (_submitImageView != nil) {
			[UIView animateWithDuration:0.5 animations:^(void) {
				_submitImageView.alpha = 0.0;
			} completion:^(BOOL finished) {
				[_submitImageView removeFromSuperview];
				_submitImageView = nil;
			}];
		}
		
		[_previewView uploadComplete];
		
		if (_hasSubmitted) {
			if (_imagePicker.parentViewController != nil) {
				[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
					[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
				}];
				
			} else
				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:@"Y"];
		}
	}
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"AWS didFailWithError:\n%@", error);
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[_previewView showKeyboard];
	
	} else if (alertView.tag == 2) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Create Volley - Find Friends %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if (buttonIndex == 0) {
			int friend_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"friend_total"] intValue];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++friend_total] forKey:@"friend_total"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		
		} else if (buttonIndex == 1) {
			if ([_subjectName length] == 0)
				_subjectName = [HONAppDelegate rndDefaultSubject];
			
			NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										   [[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
										   [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:@"challenges"], _filename], @"imgURL",
										   [NSString stringWithFormat:@"%d", _challengeExpireType], @"expires",
										   _subjectName, @"subject",
										   _challengerName, @"username",
										   (_isPrivate) ? @"Y" : @"N", @"isPrivate", nil];
			
			if ([_addFollowing count] > 1) {
				NSString *usernames = @"";
				for (HONUserVO *vo in _addFollowing)
					usernames = [usernames stringByAppendingFormat:@"%@|", vo.username];
				
				[params setObject:[usernames substringToIndex:[usernames length] - 1] forKey:@"usernames"];
			}
			
			if (_challengeVO != nil)
				[params setObject:[NSString stringWithFormat:@"%d", _challengeVO.challengeID] forKey:@"challengeID"];
			
			if (_userVO != nil)
				[params setObject:[NSString stringWithFormat:@"%d", _userVO.userID] forKey:@"challengerID"];
			
			if (_fbID != nil)
				[params setObject:_fbID forKey:@"fbID"];
			
			[params setObject:[NSString stringWithFormat:@"%d", _challengeSubmitType] forKey:@"action"];
			
			NSLog(@"PARAMS:[%@]", params);
			[self _submitChallenge:params];
		}
	}
}

@end
