//
//  HONImagePickerViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.09.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <AWSiOSSDK/S3/AmazonS3Client.h>

#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"

#import "HONImagePickerViewController.h"
#import "HONAppDelegate.h"
#import "HONCameraOverlayView.h"
#import "HONChallengerPickerViewController.h"

@interface HONImagePickerViewController () <ASIHTTPRequestDelegate>
@property(nonatomic, strong) NSString *subjectName;
@property(nonatomic, strong) HONChallengeVO *challengeVO;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@property(nonatomic, strong) NSString *fbID;
@property(nonatomic) int submitAction;
@property(nonatomic) int challengerID;
@property(nonatomic) BOOL needsChallenger;
@property(nonatomic, strong) UIImagePickerController *imagePicker;
@end

@implementation HONImagePickerViewController

@synthesize subjectName = _subjectName;
@synthesize submitAction = _submitAction;
@synthesize challengeVO = _challengeVO;
@synthesize progressHUD = _progressHUD;
@synthesize fbID = _fbID;
@synthesize challengerID = _challengerID;
@synthesize needsChallenger = _needsChallenger;


- (id)init {
	if ((self = [super init])) {
		NSLog(@"init");
		self.view.backgroundColor = [UIColor blackColor];
		self.tabBarItem.image = [UIImage imageNamed:@"tab03_nonActive"];
		self.subjectName = @"";
		self.submitAction = 1;
		self.needsChallenger = YES;
	}
	
	return (self);
}

- (id)initWithUser:(int)userID {
	if ((self = [super init])) {
		NSLog(@"initWithUser");
		self.subjectName = @"";
		self.challengerID = userID;
		self.needsChallenger = NO;
		self.submitAction = 9;
	}
	
	return (self);
}

- (id)initWithChallenge:(HONChallengeVO *)vo {
	if ((self = [super init])) {
		NSLog(@"initWithChallenge");
		self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		
		self.challengeVO = vo;
		self.subjectName = vo.subjectName;
		self.submitAction = 4;
		self.needsChallenger = NO;
	}
	
	return (self);
}

- (id)initWithSubject:(NSString *)subject {
	if ((self = [super init])) {
		NSLog(@"initWithSubject");
		self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		
		self.subjectName = subject;
		self.submitAction = 1;
		self.needsChallenger = NO;
	}
	
	return (self);
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 45.0)];
	headerImgView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	[headerImgView setImage:[UIImage imageNamed:@"headerTitleBackground.png"]];
	headerImgView.userInteractionEnabled = YES;
//	[self.view addSubview:headerImgView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(5.0, 5.0, 54.0, 34.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	//backButton = [[SNAppDelegate snHelveticaNeueFontMedium] fontWithSize:11.0];
	[backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[backButton setTitle:@"Done" forState:UIControlStateNormal];
	[headerImgView addSubview:backButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPOSE_SOURCE_CAMERA" object:nil];
		
		HONCameraOverlayView *camerOverlayView = [[HONCameraOverlayView alloc] initWithFrame:CGRectMake(0, 0, 640.0, 480.0)];
		camerOverlayView.delegate = self;
		
		if (self.subjectName != @"")
			[camerOverlayView setSubjectName:self.subjectName];
		
		_imagePicker = [[UIImagePickerController alloc] init];
		_imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
		_imagePicker.delegate = self;
		_imagePicker.allowsEditing = NO;
		_imagePicker.cameraOverlayView = camerOverlayView;
		_imagePicker.navigationBarHidden = YES;
		_imagePicker.toolbarHidden = YES;
		_imagePicker.wantsFullScreenLayout = YES;
		_imagePicker.showsCameraControls = NO;
		_imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		
		[self.navigationController presentViewController:_imagePicker animated:NO completion:nil];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate {
	return (NO);
}

#pragma mark - Navigation
- (void)_goDone {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (void)takePicture {
	[_imagePicker takePicture];
}

- (void)showLibrary {
	_imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
}

- (void)closeCamera {
	[_imagePicker dismissViewControllerAnimated:NO completion:^(void){
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
	}];
}


#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *image = [HONAppDelegate scaleImage:[info objectForKey:UIImagePickerControllerOriginalImage] toSize:CGSizeMake(480.0, 360.0)];
	[self dismissViewControllerAnimated:YES completion:nil];
	
	NSLog(@"self.needsChallenger:[%d]", self.needsChallenger);
	
	if (!self.needsChallenger) {
		NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
		AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:@"AKIAJVS6Y36AQCMRWLQQ" withSecretKey:@"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"];
		
		NSString *filename = [NSString stringWithFormat:@"%@.jpg", [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
		NSLog(@"https://hotornot-challenges.s3.amazonaws.com/%@", filename);
		
		@try {
			_progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
			_progressHUD.labelText = @"Submitting Challenge…";
			_progressHUD.mode = MBProgressHUDModeIndeterminate;
			_progressHUD.graceTime = 2.0;
			_progressHUD.taskInProgress = YES;
			
			[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-challenges"]];
			S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:filename inBucket:@"hotornot-challenges"];
			por.contentType = @"image/jpeg";
			por.data = imageData;
			[s3 putObject:por];
			
			ASIFormDataRequest *submitChallengeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
			[submitChallengeRequest setDelegate:self];
			[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"%d", self.submitAction] forKey:@"action"];
			[submitChallengeRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
			[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"https://hotornot-challenges.s3.amazonaws.com/%@", filename] forKey:@"imgURL"];
			
			if (self.submitAction == 1)
				[submitChallengeRequest setPostValue:self.subjectName forKey:@"subject"];
			
			else if (self.submitAction == 4)
				[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"%d", self.challengeVO.challengeID] forKey:@"challengeID"];
			
			else if (self.submitAction == 8) {
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
		[self.navigationController pushViewController:[[HONChallengerPickerViewController alloc] initWithSubject:self.subjectName withImage:image] animated:YES];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"HONImagePickerViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		_progressHUD.taskInProgress = NO;
		
		NSError *error = nil;
		//NSDictionary *challengeResult = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		
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
			
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
			//[self.navigationController dismissViewControllerAnimated:YES completion:nil];
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}


@end
