//
//  HONChallengerPickerViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AWSiOSSDK/S3/AmazonS3Client.h>
//#import <FacebookSDK/FacebookSDK.h>
#import "Facebook.h"
#import "TapForTap.h"

#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#import "Mixpanel.h"

#import "HONChallengerPickerViewController.h"
#import "HONAppDelegate.h"
#import "HONChallengeVO.h"
#import "HONFacebookCaller.h"
#import "HONHeaderView.h"

@interface HONChallengerPickerViewController () <UITextFieldDelegate, FBFriendPickerDelegate, TapForTapAdViewDelegate>
@property(nonatomic, strong) NSString *subjectName;
@property(nonatomic) int challengerID;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@property(nonatomic, strong) UIImage *challengeImage;
@property(nonatomic, strong) NSString *fbID;
@property(nonatomic, strong) NSString *fbName;
@property(nonatomic, strong) NSString *filename;
@property(nonatomic, strong) UITextField *subjectTextField;
@property(nonatomic, strong) UIButton *editButton;
@property(nonatomic) BOOL isFlipped;
//@property(nonatomic, strong) NSString *rndSubject;
@end

@implementation HONChallengerPickerViewController

@synthesize subjectName = _subjectName;
@synthesize challengerID = _challengerID;
@synthesize progressHUD = _progressHUD;
@synthesize fbID = _fbID;
@synthesize fbName = _fbName;
@synthesize challengeImage = _challengeImage;
@synthesize filename = _filename;
@synthesize subjectTextField = _subjectTextField;
@synthesize editButton = _editButton;
//@synthesize rndSubject = _rndSubject;

- (id)init {
	if ((self = [super init])) {
		//NSLog(@"init");
		self.view.backgroundColor = [UIColor blackColor];
		
		[[Mixpanel sharedInstance] track:@"Pick Challenger"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	}
	
	return (self);
}

- (id)initWithImage:(UIImage *)img subjectName:(NSString *)subject{
	if ((self = [super init])) {
		NSLog(@"initWithImage:[%f, %f]", img.size.width, img.size.height);
		self.isFlipped = NO;
		self.view.backgroundColor = [UIColor blackColor];
		self.challengeImage = img;
		self.subjectName = subject;
		
		[[Mixpanel sharedInstance] track:@"Pick Challenger"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	}
	
	return (self);
}

- (id)initWithFlippedImage:(UIImage *)img subjectName:(NSString *)subject {
	if ((self = [super init])) {
		NSLog(@"initWithFlippedImage:[%f, %f]", img.size.width, img.size.height);
		self.isFlipped = YES;
		self.view.backgroundColor = [UIColor blackColor];
		self.challengeImage = img;
		self.subjectName = subject;
		
		[[Mixpanel sharedInstance] track:@"Pick Challenger"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	}
	
	return (self);
}

#pragma mark - View lifecycle
- (void)loadView {
	//NSLog(@"loadView");
	[super loadView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Confirm Challenge" hasFBSwitch:NO];
	[self.view addSubview:headerView];
		
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 0.0, 74.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backButton];
		
	//_rndSubject = [NSString stringWithFormat:@"#%@", [HONAppDelegate rndDefaultSubject]];
	
	if (![self.subjectName hasPrefix:@"#"])
		self.subjectName = [NSString stringWithFormat:@"#%@", self.subjectName];
	
	_subjectTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 70.0, 240.0, 20.0)];
	//[_subjectTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_subjectTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_subjectTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_subjectTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_subjectTextField setReturnKeyType:UIReturnKeyDone];
	[_subjectTextField setTextColor:[UIColor whiteColor]];
	[_subjectTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_subjectTextField.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
	_subjectTextField.keyboardType = UIKeyboardTypeDefault;
	_subjectTextField.text = self.subjectName;
	_subjectTextField.delegate = self;
	[self.view addSubview:_subjectTextField];
		
	_editButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_editButton.frame = CGRectMake(265.0, 60.0, 44.0, 44.0);
	[_editButton setBackgroundImage:[UIImage imageNamed:@"closeXButton_nonActive.png"] forState:UIControlStateNormal];
	[_editButton setBackgroundImage:[UIImage imageNamed:@"closeXButton_Active.png"] forState:UIControlStateHighlighted];
	[_editButton addTarget:self action:@selector(_goEditSubject) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_editButton];
	
	UIButton *friendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	friendsButton.frame = CGRectMake(18.0, 338.0, 284.0, 49.0);
	[friendsButton setBackgroundImage:[UIImage imageNamed:(FBSession.activeSession.state == 513) ? @"challengeFriendsButton_nonActive.png" : @"loginFacebook_nonActive.png"] forState:UIControlStateNormal];
	[friendsButton setBackgroundImage:[UIImage imageNamed:(FBSession.activeSession.state == 513) ? @"challengeFriendsButton_Active.png" : @"loginFacebook_Active.png"] forState:UIControlStateHighlighted];
	
	if (FBSession.activeSession.state == 513)
		[friendsButton addTarget:self action:@selector(_goChallengeFriends) forControlEvents:UIControlEventTouchUpInside];
	
	else
		[friendsButton addTarget:self action:@selector(_goLogin) forControlEvents:UIControlEventTouchUpInside];
	
	friendsButton.hidden = (FBSession.activeSession.state != 513);
	[self.view addSubview:friendsButton];
	
	UIButton *randomButton = [UIButton buttonWithType:UIButtonTypeCustom];
	randomButton.frame = CGRectMake(18.0, 338.0 + ((int)(FBSession.activeSession.state == 513) * 60), 284.0, 49.0);
	[randomButton setBackgroundImage:[UIImage imageNamed:@"challengeRandomButton_nonActive.png"] forState:UIControlStateNormal];
	[randomButton setBackgroundImage:[UIImage imageNamed:@"challengeRandomButton_Active.png"] forState:UIControlStateHighlighted];
	[randomButton addTarget:self action:@selector(_goRandomChallenge) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:randomButton];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(60.0, 117.0, 200.0, 200.0)];
	imgView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	imgView.image = [HONAppDelegate cropImage:[HONAppDelegate scaleImage:self.challengeImage toSize:CGSizeMake(kLargeW * 0.5, kLargeH * 0.5)] toRect:CGRectMake(0.0, (((kLargeH - kLargeW) * 0.5) * 0.5), kLargeW * 0.5, kLargeW * 0.5)];
	[self.view addSubview:imgView];
	
	if (self.isFlipped)
		imgView.image = [UIImage imageWithCGImage:imgView.image.CGImage scale:1.0 orientation:UIImageOrientationUpMirrored];
	
	UIImageView *watermarkImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 200.0)];
	watermarkImgView.image = [UIImage imageNamed:@"512x512_cameraOverlay.png"];
	//[imgView addSubview:watermarkImgView];
	
	_subjectTextField.text = self.subjectName;
	//NSLog(@"IMAGE:[%f, %f]", self.challengeImage.size.width, self.challengeImage.size.height);
}


#pragma mark - Navigation
- (void)_goBack {
	[[Mixpanel sharedInstance] track:@"Pick Challenger Back"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goLogin {
	[FBSession.activeSession closeAndClearTokenInformation];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[HONLoginViewController alloc] init]];
	[navController setNavigationBarHidden:YES];
	[self presentViewController:navController animated:YES completion:nil];
}

- (void)_goEditSubject {
	_subjectTextField.text = @"";
	[_subjectTextField becomeFirstResponder];
}

- (void)_goChallengeFriends {
	[[Mixpanel sharedInstance] track:@"Pick Challenger - Friend"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[FBRequestConnection startWithGraphPath:@"me/friends" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
		for (NSDictionary *friend in [(NSDictionary *)result objectForKey:@"data"]) {
			//NSLog(@"FRIEND:[%@]", friend);
		}
	}];
	
	
	FBFriendPickerViewController *friendPickerController = [[FBFriendPickerViewController alloc] init];
	friendPickerController.title = @"Pick Friends";
	friendPickerController.allowsMultipleSelection = NO;
	friendPickerController.delegate = self;
	friendPickerController.sortOrdering = FBFriendDisplayByLastName;
	friendPickerController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
																				  initWithTitle:@"Cancel!"
																				  style:UIBarButtonItemStyleBordered
																				  target:self
																				  action:@selector(cancelButtonWasPressed:)];
	
	friendPickerController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
																					initWithTitle:@"Done!"
																					style:UIBarButtonItemStyleBordered
																					target:self
																					action:@selector(doneButtonWasPressed:)];
	[friendPickerController loadData];
	
	// Use the modal wrapper method to display the picker.
	[friendPickerController presentModallyFromViewController:self animated:YES handler:
	 ^(FBViewController *sender, BOOL donePressed) {
		 if (!donePressed)
			 return;
		 
		 if (friendPickerController.selection.count == 0) {
			 [[[UIAlertView alloc] initWithTitle:@"No Friend Selected"
												  message:@"You need to pick a friend."
												 delegate:nil
									 cancelButtonTitle:@"OK"
									 otherButtonTitles:nil]
			  show];
			 
		 } else {
			 // submit
			 self.filename = [NSString stringWithFormat:@"%@_%@", [HONAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
			 self.fbID = [[friendPickerController.selection lastObject] objectForKey:@"id"];
			 self.fbName = [[friendPickerController.selection lastObject] objectForKey:@"first_name"];
			 //NSLog(@"FRIEND:[%@]", [friendPickerController.selection lastObject]);
			 
			 [self _goFriendChallenge];
		 }
	 }];
}

- (void)_goFriendChallenge {
	//NSData *imageData = UIImageJPEGRepresentation(self.image, 1.0);
	
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	
	@try {
		UIImageView *canvasView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
		canvasView.image = [HONAppDelegate cropImage:[HONAppDelegate scaleImage:self.challengeImage toSize:CGSizeMake(kLargeW, kLargeH)] toRect:CGRectMake(0.0, (((kLargeH - kLargeW) * 0.5) * 0.5), kLargeW, kLargeW)];
		
		UIImageView *watermarkImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
		watermarkImgView.image = [UIImage imageNamed:@"612x612_overlay@2x.png"];
		[canvasView addSubview:watermarkImgView];
		
		CGSize size = [canvasView bounds].size;
		UIGraphicsBeginImageContext(size);
		[[canvasView layer] renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *lImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		UIImage *mImage = [HONAppDelegate scaleImage:self.challengeImage toSize:CGSizeMake(kMediumW * 2.0, kMediumH * 2.0)];
		UIImage *t1Image = [HONAppDelegate scaleImage:self.challengeImage toSize:CGSizeMake(kThumb1W * 2.0, kThumb1H * 2.0)];
		
		NSLog(@"https://hotornot-challenges.s3.amazonaws.com/%@", self.filename);
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.labelText = @"Submitting Challenge…";
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.taskInProgress = YES;
		
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-challenges"]];
		S3PutObjectRequest *por1 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_t.jpg", self.filename] inBucket:@"hotornot-challenges"];
		por1.contentType = @"image/jpeg";
		por1.data = UIImageJPEGRepresentation(t1Image, 0.5);
		[s3 putObject:por1];
				
		S3PutObjectRequest *por3 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_m.jpg", self.filename] inBucket:@"hotornot-challenges"];
		por3.contentType = @"image/jpeg";
		por3.data = UIImageJPEGRepresentation(mImage, 0.5);
		[s3 putObject:por3];
		
		S3PutObjectRequest *por4 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_l.jpg", self.filename] inBucket:@"hotornot-challenges"];
		por4.contentType = @"image/jpeg";
		por4.data = UIImageJPEGRepresentation(lImage, 0.5);
		[s3 putObject:por4];
		
		if ([self.subjectName length] == 0)
			self.subjectName = [HONAppDelegate rndDefaultSubject];
		
		if ([self.subjectName hasPrefix:@"#"])
			self.subjectName = [self.subjectName substringFromIndex:1];
		
		ASIFormDataRequest *submitChallengeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
		[submitChallengeRequest setDelegate:self];
		[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"%d", 8] forKey:@"action"];
		[submitChallengeRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
		[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"https://hotornot-challenges.s3.amazonaws.com/%@", self.filename] forKey:@"imgURL"];
		[submitChallengeRequest setPostValue:self.subjectName forKey:@"subject"];
		[submitChallengeRequest setPostValue:self.fbID forKey:@"fbID"];
		[submitChallengeRequest setPostValue:self.fbName forKey:@"fbName"];
		[submitChallengeRequest startAsynchronous];
		
	} @catch (AmazonClientException *exception) {
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		[[[UIAlertView alloc] initWithTitle:@"Upload Error" message:exception.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}
}


- (void)_goRandomChallenge {
	[[Mixpanel sharedInstance] track:@"Pick Challenger - Random"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	//NSData *imageData = UIImageJPEGRepresentation(self.image, 1.0);
	
	if ([self.subjectName length] == 0)
		self.subjectName = [HONAppDelegate rndDefaultSubject];
	
	if ([self.subjectName hasPrefix:@"#"])
		self.subjectName = [self.subjectName substringFromIndex:1];
	
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	
	self.filename = [NSString stringWithFormat:@"%@_%@", [HONAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
	NSLog(@"https://hotornot-challenges.s3.amazonaws.com/%@", self.filename);
	
	@try {
		UIImageView *canvasView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
		canvasView.image = [HONAppDelegate cropImage:[HONAppDelegate scaleImage:self.challengeImage toSize:CGSizeMake(kLargeW, kLargeH)] toRect:CGRectMake(0.0, (((kLargeH - kLargeW) * 0.5) * 0.5), kLargeW, kLargeW)];
		
		UIImageView *watermarkImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
		watermarkImgView.image = [UIImage imageNamed:@"612x612_overlay@2x.png"];
		[canvasView addSubview:watermarkImgView];
		
		CGSize size = [canvasView bounds].size;
		UIGraphicsBeginImageContext(size);
		[[canvasView layer] renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *lImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		UIImage *mImage = [HONAppDelegate scaleImage:self.challengeImage toSize:CGSizeMake(kMediumW * 2.0, kMediumH * 2.0)];
		UIImage *t1Image = [HONAppDelegate scaleImage:self.challengeImage toSize:CGSizeMake(kThumb1W * 2.0, kThumb1H * 2.0)];
		
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.labelText = @"Submitting Challenge…";
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.taskInProgress = YES;
		
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-challenges"]];
		S3PutObjectRequest *por1 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_t.jpg", self.filename] inBucket:@"hotornot-challenges"];
		por1.contentType = @"image/jpeg";
		por1.data = UIImageJPEGRepresentation(t1Image, 1.0);
		[s3 putObject:por1];
				
		S3PutObjectRequest *por3 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_m.jpg", self.filename] inBucket:@"hotornot-challenges"];
		por3.contentType = @"image/jpeg";
		por3.data = UIImageJPEGRepresentation(mImage, 1.0);
		[s3 putObject:por3];
		
		S3PutObjectRequest *por4 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_l.jpg", self.filename] inBucket:@"hotornot-challenges"];
		por4.contentType = @"image/jpeg";
		por4.data = UIImageJPEGRepresentation(lImage, 1.0);
		[s3 putObject:por4];
		
		ASIFormDataRequest *submitChallengeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
		[submitChallengeRequest setDelegate:self];
		[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[submitChallengeRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
		[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"https://hotornot-challenges.s3.amazonaws.com/%@", self.filename] forKey:@"imgURL"];
		[submitChallengeRequest setPostValue:self.subjectName forKey:@"subject"];
		[submitChallengeRequest startAsynchronous];
		
	} @catch (AmazonClientException *exception) {
		[[[UIAlertView alloc] initWithTitle:@"Upload Error" message:exception.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	_editButton.hidden = YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	_editButton.hidden = NO;
	
	if ([textField.text length] == 0)
		textField.text = self.subjectName;
	
	else
		self.subjectName = textField.text;
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request {
	//NSLog(@"HONChallengerPickerViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		_progressHUD.taskInProgress = NO;
		
		NSError *error = nil;
		NSDictionary *challengeResult = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		
		if (error != nil) {
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
			_progressHUD.labelText = NSLocalizedString(@"Download Failed", @"Status message when downloading fails");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
		
		} else {
			[_progressHUD hide:YES];
			_progressHUD = nil;
			
			HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:challengeResult];
			[HONFacebookCaller postToTimeline:vo];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_LIST" object:nil];
			
			if ([[challengeResult objectForKey:@"status"] intValue] == 7) {
				NSLog(@"-----------SEND INVITE-------------");
				[HONFacebookCaller sendAppRequestToUser:self.fbID];
			}
			
			NSLog(@"fbID:[%@][%@]", self.fbID, _fbID);
			if ([self.fbID length] > 0)
				[HONFacebookCaller postToFriendTimeline:self.fbID article:vo];
			
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void){
				[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
			}];
			//[self.navigationController dismissViewControllerAnimated:YES completion:nil];
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


- (UIViewController *) rootViewController { return self; }

@end
