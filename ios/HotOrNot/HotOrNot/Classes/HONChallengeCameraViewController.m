//
//  HONChallengeCameraViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/6/13 @ 12:01 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import <AWSiOSSDK/S3/AmazonS3Client.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "UIImage+fixOrientation.h"

#import "HONChallengeCameraViewController.h"
#import "HONImagingDepictor.h"
#import "HONSnapCameraOverlayView.h"
#import "HONCreateChallengePreviewView.h"


@interface HONChallengeCameraViewController () <AmazonServiceRequestDelegate, HONSnapCameraOverlayViewDelegate, HONCreateChallengePreviewViewDelegate>
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) HONSnapCameraOverlayView *cameraOverlayView;
@property (nonatomic, strong) HONCreateChallengePreviewView *previewView;
@property (readonly, nonatomic, assign) HONVolleySubmitType volleySubmitType;
@property (nonatomic, strong) NSMutableArray *subscribers;
@property (nonatomic, strong) NSMutableArray *subscriberIDs;
@property (nonatomic, strong) HONChallengeVO *challengeVO;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic) int uploadCounter;
@property (nonatomic, strong) NSArray *s3Uploads;
@property (nonatomic, strong) UIImage *rawImage;
@property (nonatomic, strong) UIImage *challangeImage;
@property (nonatomic, strong) NSMutableArray *usernames;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSDictionary *challengeParams;
@property (nonatomic, strong) UIImageView *submitImageView;
@property (nonatomic) BOOL hasSubmitted;
@property (nonatomic) BOOL isMainCamera;
@end


@implementation HONChallengeCameraViewController

- (id)initAsNewChallenge {
	NSLog(@"%@ - initAsNewChallenge", [self description]);
	if ((self = [super init])) {
		_volleySubmitType = HONVolleySubmitTypeMatch;
		
		_subscribers = [NSMutableArray array];
		_subscriberIDs = [NSMutableArray array];
		_subjectName = @"";
	}
	
	return (self);
}

- (id)initAsJoinChallenge:(HONChallengeVO *)challengeVO {
	NSLog(@"%@ - initAsJoinChallenge:[%d] (%d/%d)", [self description], challengeVO.challengeID, challengeVO.creatorVO.userID, ((HONOpponentVO *)[challengeVO.challengers lastObject]).userID);
	if ((self = [super init])) {
		_volleySubmitType = HONVolleySubmitTypeJoin;
		
		_subscribers = [NSMutableArray array];
		_subscriberIDs = [NSMutableArray array];
		_challengeVO = challengeVO;
		_subjectName = challengeVO.subjectName;
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
- (void)_retrieveUser {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 5], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			[HONAppDelegate writeUserInfo:userResult];
			
			for (HONUserVO *vo in [HONAppDelegate friendsList]) {
				if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != vo.userID) {
					BOOL isFound = NO;
					for (NSNumber *userID in _subscriberIDs) {
						if ([userID intValue] == vo.userID) {
							isFound = YES;
							break;
						}
					}
					
					if (!isFound) {
						[_subscribers addObject:[HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
																			   [NSString stringWithFormat:@"%d", vo.userID], @"id",
																			   [NSString stringWithFormat:@"%d", 0], @"points",
																			   [NSString stringWithFormat:@"%d", 0], @"votes",
																			   [NSString stringWithFormat:@"%d", 0], @"pokes",
																			   [NSString stringWithFormat:@"%d", 0], @"pics",
																			   [NSString stringWithFormat:@"%d", 0], @"age",
																			   vo.username, @"username",
																			   vo.fbID, @"fb_id",
																			   vo.imageURL, @"avatar_url", nil]]];
						[_subscriberIDs addObject:[NSNumber numberWithInt:vo.userID]];
					}
				}
			}
			
			[_cameraOverlayView updateChallengers:[_subscribers copy] asJoining:(_volleySubmitType == HONVolleySubmitTypeJoin)];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}

- (void)_uploadPhoto:(UIImage *)image {
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	_uploadCounter = 0;
	
	_filename = [NSString stringWithFormat:@"%@_%@", [HONAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
	NSLog(@"FILE PREFIX: %@/%@", [HONAppDelegate s3BucketForType:@"challenges"], _filename);
	
	@try {
		UIImage *oImage = [HONImagingDepictor scaleImage:image toSize:CGSizeMake(960.0, 1280.0)];
		UIImage *lImage = [HONImagingDepictor scaleImage:image toSize:CGSizeMake(kSnapLargeDim * 2.0, kSnapLargeDim * 2.0)];
		UIImage *mImage = [HONImagingDepictor scaleImage:image toSize:CGSizeMake(kSnapMediumDim * 2.0, kSnapMediumDim * 2.0)];
		
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-challenges"]];
		
		S3PutObjectRequest *por1 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_m.jpg", _filename] inBucket:@"hotornot-challenges"];
		por1.delegate = self;
		por1.contentType = @"image/jpeg";
		por1.data = UIImageJPEGRepresentation(mImage, kSnapJPEGCompress);
		[s3 putObject:por1];
		
		S3PutObjectRequest *por2 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_l.jpg", _filename] inBucket:@"hotornot-challenges"];
		por2.delegate = self;
		por2.contentType = @"image/jpeg";
		por2.data = UIImageJPEGRepresentation(lImage, kSnapJPEGCompress);
		[s3 putObject:por2];
		
		S3PutObjectRequest *por3 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_o.jpg", _filename] inBucket:@"hotornot-challenges"];
		por3.delegate = self;
		por3.contentType = @"image/jpeg";
		por3.data = UIImageJPEGRepresentation(oImage, kSnapJPEGCompress);
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

- (void)_submitChallenge {
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
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], (_volleySubmitType == HONVolleySubmitTypeJoin) ? kAPIJoinChallenge : kAPIChallenges, [_challengeParams objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:(_volleySubmitType == HONVolleySubmitTypeJoin) ? kAPIJoinChallenge : kAPIChallenges parameters:_challengeParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
				_progressHUD.labelText = @"Error!";
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:kHUDErrorTime];
				_progressHUD = nil;
				
			} else {
				_hasSubmitted = YES;
				if (_uploadCounter == [_s3Uploads count]) {
					[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
						[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:@"Y"];
						[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
					}];
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
	//self.view.backgroundColor = [UIColor greenColor];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self showImagePickerForSourceType:([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - UI Presentation
- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
	if (_volleySubmitType == HONVolleySubmitTypeJoin) {
		if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != _challengeVO.creatorVO.userID) {
			[_subscribers addObject:[HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
																   [NSString stringWithFormat:@"%d", _challengeVO.creatorVO.userID], @"id",
																   [NSString stringWithFormat:@"%d", 0], @"points",
																   [NSString stringWithFormat:@"%d", 0], @"votes",
																   [NSString stringWithFormat:@"%d", 0], @"pokes",
																   [NSString stringWithFormat:@"%d", 0], @"pics",
																   [NSString stringWithFormat:@"%d", 0], @"age",
																   _challengeVO.creatorVO.username, @"username",
																   _challengeVO.creatorVO.fbID, @"fb_id",
																   _challengeVO.creatorVO.avatarURL, @"avatar_url", nil]]];
			[_subscriberIDs addObject:[NSNumber numberWithInt:_challengeVO.creatorVO.userID]];
		}
		
		for (HONOpponentVO *vo in _challengeVO.challengers) {
			if ([vo.imagePrefix length] > 0 && vo.userID != [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) {
				
				BOOL isFound = NO;
				for (NSNumber *userID in _subscriberIDs) {
					if ([userID intValue] == vo.userID) {
						isFound = YES;
						break;
					}
				}
				
				if (!isFound) {
					[_subscribers addObject:[HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
																		   [NSString stringWithFormat:@"%d", vo.userID], @"id",
																		   [NSString stringWithFormat:@"%d", 0], @"points",
																		   [NSString stringWithFormat:@"%d", 0], @"votes",
																		   [NSString stringWithFormat:@"%d", 0], @"pokes",
																		   [NSString stringWithFormat:@"%d", 0], @"pics",
																		   [NSString stringWithFormat:@"%d", 0], @"age",
																		   vo.username, @"username",
																		   vo.fbID, @"fb_id",
																		   vo.avatarURL, @"avatar_url", nil]]];
					[_subscriberIDs addObject:[NSNumber numberWithInt:vo.userID]];
				}
			}
		}
	}
	
	
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.showsCameraControls = NO;
		imagePickerController.cameraViewTransform = CGAffineTransformScale(imagePickerController.cameraViewTransform, ([HONAppDelegate isRetina5]) ? 1.65f : 1.25f, ([HONAppDelegate isRetina5]) ? 1.65f : 1.25f);
		imagePickerController.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		
		_cameraOverlayView = [[HONSnapCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		_cameraOverlayView.delegate = self;
    }
	
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:^(void) {
		if (sourceType == UIImagePickerControllerSourceTypeCamera)
			[self _showOverlay];
	}];
}

- (void)_showOverlay {
	self.imagePickerController.cameraOverlayView = _cameraOverlayView;
	
	[_cameraOverlayView intro];
	
	if (_volleySubmitType == HONVolleySubmitTypeJoin) {
		[_cameraOverlayView updateChallengers:[_subscribers copy] asJoining:(_volleySubmitType == HONVolleySubmitTypeJoin)];
	
	} else
		[self _retrieveUser];
}

- (void)_takePhoto {
//	if (_progressTimer != nil) {
//		[_progressTimer invalidate];
//		_progressTimer = nil;
//	}
//	
//	[_cameraOverlayView takePhoto];
//	[self.imagePickerController takePicture];
}


#pragma mark - CameraOverlay Delegates
- (void)cameraOverlayViewShowCameraRoll:(HONSnapCameraOverlayView *)cameraOverlayView {
	self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)cameraOverlayViewChangeCamera:(HONSnapCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Create Volley - Flip Camera"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront) ? @"rear" : @"front", @"type", nil]];
	
	self.imagePickerController.cameraDevice = (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront) ? UIImagePickerControllerCameraDeviceRear : UIImagePickerControllerCameraDeviceFront;
}

- (void)cameraOverlayViewCameraBack:(HONSnapCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Create Volley - Back"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	for (S3PutObjectRequest *por in _s3Uploads)
		[por.urlConnection cancel];
}

- (void)cameraOverlayViewCloseCamera:(HONSnapCameraOverlayView *)cameraOverlayView {
	NSLog(@"cameraOverlayViewCloseCamera");
	[[Mixpanel sharedInstance] track:@"Create Volley - Cancel"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	for (S3PutObjectRequest *por in _s3Uploads)
		[por.urlConnection cancel];
	
	[self.imagePickerController dismissViewControllerAnimated:NO completion:^(void) {
		///[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
	}];
}

- (void)cameraOverlayViewTakePhoto:(HONSnapCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Create Volley - Take Photo"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self.imagePickerController takePicture];
}


#pragma mark - PreviewView Delegates
- (void)previewView:(HONCreateChallengePreviewView *)previewView removeChallenger:(HONUserVO *)userVO {
	[[Mixpanel sharedInstance] track:@"Create Volley - Remove Opponent"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", userVO.userID, userVO.username], @"challenger", nil]];
	
	NSMutableArray *removeVOs = [NSMutableArray array];
	for (HONUserVO *vo in _subscribers) {
		if (vo.userID == userVO.userID) {
			[removeVOs addObject:vo];
			break;
		}
	}
	
	[_subscribers removeObjectsInArray:removeVOs];
	removeVOs = nil;
	
	[_previewView setOpponents:[_subscribers copy] asJoining:(_volleySubmitType == HONVolleySubmitTypeJoin) redrawTable:YES];
}

- (void)previewViewBackToCamera:(HONCreateChallengePreviewView *)previewView {
	NSLog(@"previewViewBackToCamera");
	
	[[Mixpanel sharedInstance] track:@"Create Volley - Retake Photo"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	for (S3PutObjectRequest *por in _s3Uploads)
		[por.urlConnection cancel];
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
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
}

- (void)previewViewSubmit:(HONCreateChallengePreviewView *)previewView {
	[[Mixpanel sharedInstance] track:@"Create Volley - Submit"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_hasSubmitted = NO;
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
									   [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:@"challenges"], _filename], @"imgURL",
									   [NSString stringWithFormat:@"%d", _volleySubmitType], @"action",
									   [[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									   [NSString stringWithFormat:@"%d", 1], @"expires",
									   _subjectName, @"subject",
									   @"", @"username",
									   @"N", @"isPrivate",
									   @"0", @"challengerID",
									   @"0", @"fbID", nil];
		
		NSString *usernames = @"";
		if ([_subscribers count] > 0) {
			for (HONUserVO *vo in _subscribers)
				usernames = [usernames stringByAppendingFormat:@"%@|", vo.username];
		}
		[params setObject:[usernames substringToIndex:([usernames length] > 0) ? [usernames length] - 1 : 0] forKey:@"usernames"];
		
		
		if (_challengeVO != nil)
			[params setObject:[NSString stringWithFormat:@"%d", _challengeVO.challengeID] forKey:@"challengeID"];
		
		_challengeParams = [params copy];
		NSLog(@"PARAMS:[%@]", _challengeParams);
		
		[self _submitChallenge];
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
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:@"Y"];
			}];
		}
	}
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"AWS didFailWithError:\n%@", error);
}


#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	_rawImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	if (_rawImage.imageOrientation != 0)
		_rawImage = [_rawImage fixOrientation];
	
	NSLog(@"RAW IMAGE:[%@]", NSStringFromCGSize(_rawImage.size));
	
//	CIImage *image = [CIImage imageWithCGImage:_rawImage.CGImage];
//	CIDetector *detctor = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
//	NSArray *features = [detctor featuresInImage:image];
//	NSLog(@"FEATURES:[%d]", [features count]);
	
	UIImage *workingImage = _rawImage;
	
	// image is wider than tall (800x600)
	if (_rawImage.size.width > _rawImage.size.height) {
		_isMainCamera = (_rawImage.size.height > 1000);
		if (_isMainCamera)
			workingImage = [HONImagingDepictor scaleImage:_rawImage toSize:CGSizeMake(1280.0, 960.0)];
		
		float offset = (workingImage.size.width - workingImage.size.height) * 0.5;
		_challangeImage = [HONImagingDepictor cropImage:workingImage toRect:CGRectMake(offset, 0.0, workingImage.size.height, workingImage.size.height)];
		
		// image is taller than wide (600x800)
	} else if (_rawImage.size.width < _rawImage.size.height) {
		_isMainCamera = (_rawImage.size.width > 1000);
		if (_isMainCamera)
			workingImage = [HONImagingDepictor scaleImage:_rawImage toSize:CGSizeMake(960.0, 1280.0)];
		
		float offset = (workingImage.size.height - workingImage.size.width) * 0.5;
		_challangeImage = [HONImagingDepictor cropImage:workingImage toRect:CGRectMake(0.0, offset, workingImage.size.width, workingImage.size.width)];
		
		// image is square
	} else
		_challangeImage = workingImage;
	
	
	_usernames = [NSMutableArray array];
	for (HONUserVO *vo in _subscribers)
		[_usernames addObject:vo.username];
	
	if (_isMainCamera)
		_previewView = [[HONCreateChallengePreviewView alloc] initWithFrame:[UIScreen mainScreen].bounds withSubject:_subjectName withImage:workingImage];
	else
		_previewView = [[HONCreateChallengePreviewView alloc] initWithFrame:[UIScreen mainScreen].bounds withSubject:_subjectName withMirroredImage:workingImage];
	
	_previewView.delegate = self;
	[_previewView setOpponents:[_subscribers copy] asJoining:(_volleySubmitType == HONVolleySubmitTypeJoin) redrawTable:YES];
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
		self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	
	else {
		[self dismissViewControllerAnimated:YES completion:^(void) {
			///[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
		}];
	}
}


@end
