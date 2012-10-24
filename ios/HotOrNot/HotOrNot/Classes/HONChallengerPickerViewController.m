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

#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#import "Mixpanel.h"

#import "HONChallengerPickerViewController.h"
#import "HONAppDelegate.h"
#import "HONChallengeVO.h"
#import "HONFacebookCaller.h"
#import "HONHeaderView.h"

@interface HONChallengerPickerViewController () <UITextFieldDelegate, FBFriendPickerDelegate>
@property(nonatomic, strong) NSString *subjectName;
@property(nonatomic) int challengerID;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@property(nonatomic, strong) UIImage *challengeImage;
@property(nonatomic, strong) NSString *fbID;
@property(nonatomic, strong) NSString *fbName;
@property(nonatomic, strong) NSString *filename;
@property(nonatomic, strong) UILabel *placeholderLabel;
@property(nonatomic, strong) UITextField *subjectTextField;
@property(nonatomic, strong) NSString *rndSubject;
@end

@implementation HONChallengerPickerViewController

@synthesize subjectName = _subjectName;
@synthesize challengerID = _challengerID;
@synthesize progressHUD = _progressHUD;
@synthesize fbID = _fbID;
@synthesize fbName = _fbName;
@synthesize challengeImage = _challengeImage;
@synthesize filename = _filename;
@synthesize placeholderLabel = _placeholderLabel;
@synthesize subjectTextField = _subjectTextField;
@synthesize rndSubject = _rndSubject;

- (id)init {
	if ((self = [super init])) {
		NSLog(@"init");
		self.view.backgroundColor = [UIColor whiteColor];
		
		[[Mixpanel sharedInstance] track:@"Pick Challenger"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	}
	
	return (self);
}

- (id)initWithImage:(UIImage *)img {
	if ((self = [super init])) {
		NSLog(@"initWithImage:[%f, %f]", img.size.width, img.size.height);
		self.view.backgroundColor = [UIColor whiteColor];
		self.challengeImage = img;
		
		[[Mixpanel sharedInstance] track:@"Pick Challenger"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	}
	
	return (self);
}

#pragma mark - View lifecycle
- (void)loadView {
	NSLog(@"loadView");
	[super loadView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Edit Challenge" hasFBSwitch:NO];
	[self.view addSubview:headerView];
		
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 0.0, 74.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backButton];
	
	UIImageView *bgImgView;
	
//	if ([HONAppDelegate isRetina5]) {
//		bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 56.0, 320.0, 480.0)];
//		[bgImgView setImage:[UIImage imageNamed:@"challengeCameraBackground-568h.png"]];
//	
//	} else {
		bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 40.0, 320.0, 419.0)];
		[bgImgView setImage:[UIImage imageNamed:@"challengeCameraBackground.png"]];
//	}
	
	bgImgView.userInteractionEnabled = YES;
	[self.view addSubview:bgImgView];
	
	_rndSubject = [NSString stringWithFormat:@"#%@", [HONAppDelegate rndDefaultSubject]];
	
	_subjectTextField = [[UITextField alloc] initWithFrame:CGRectMake(40.0, 30.0, 240.0, 20.0)];
	//[_subjectTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_subjectTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_subjectTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_subjectTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_subjectTextField setReturnKeyType:UIReturnKeyDone];
	[_subjectTextField setTextColor:[UIColor colorWithWhite:0.482 alpha:1.0]];
	[_subjectTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_subjectTextField.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:14];
	_subjectTextField.keyboardType = UIKeyboardTypeDefault;
	_subjectTextField.text = @"";
	_subjectTextField.delegate = self;
	[bgImgView addSubview:_subjectTextField];
	
	_placeholderLabel = [[UILabel alloc] initWithFrame:_subjectTextField.frame];
	_placeholderLabel.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:14];
	_placeholderLabel.textColor = [UIColor colorWithWhite:0.29803921568627 alpha:1.0];
	_placeholderLabel.backgroundColor = [UIColor clearColor];
	_placeholderLabel.textAlignment = NSTextAlignmentCenter;
	_placeholderLabel.text = _rndSubject;//@"tap here to add challenge #hashtag";
	[bgImgView addSubview:self.placeholderLabel];
	
	int offset = 0;//([HONAppDelegate isRetina5]) ? 0 : 6;
	UIButton *friendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	friendsButton.frame = CGRectMake(18.0, offset + (self.view.frame.size.height - 129.0), 284.0, 49.0);
	[friendsButton setBackgroundImage:[UIImage imageNamed:@"challengeFriendsButton_nonActive.png"] forState:UIControlStateNormal];
	[friendsButton setBackgroundImage:[UIImage imageNamed:@"challengeFriendsButton_Active.png"] forState:UIControlStateHighlighted];
	[friendsButton addTarget:self action:@selector(_goChallengeFriends) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:friendsButton];
	
	UIButton *randomButton = [UIButton buttonWithType:UIButtonTypeCustom];
	randomButton.frame = CGRectMake(18.0, offset + (self.view.frame.size.height - 72.0), 284.0, 49.0);
	[randomButton setBackgroundImage:[UIImage imageNamed:@"challengeRandomButton_nonActive.png"] forState:UIControlStateNormal];
	[randomButton setBackgroundImage:[UIImage imageNamed:@"challengeRandomButton_Active.png"] forState:UIControlStateHighlighted];
	[randomButton addTarget:self action:@selector(_goRandomChallenge) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:randomButton];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	UIView *holderView;
	
	float imgSize;
	
	if ([HONAppDelegate isRetina5])
		imgSize = 269.0;
		
	else
		imgSize = 200.0;
	
	imgSize = 200.0;
	int offset = 0;//([HONAppDelegate isRetina5]) ? 0 : 9;
	holderView = [[UIView alloc] initWithFrame:CGRectMake(26.0 + ((269.0 - imgSize) * 0.5), offset + 128.0, imgSize, imgSize)];
	holderView.clipsToBounds = YES;
	[self.view addSubview:holderView];
	
	UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, imgSize, imgSize * kPhotoRatio)];
	imgView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	imgView.image = self.challengeImage;
	[holderView addSubview:imgView];
	
	NSLog(@"IMAGE:[%f, %f]", self.challengeImage.size.width, self.challengeImage.size.height);
}


#pragma mark - Navigation
- (void)_goBack {
	[[Mixpanel sharedInstance] track:@"Pick Challenger Back"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self.navigationController popViewControllerAnimated:YES];
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
		UIImageView *canvasView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW, kLargeH)];
		canvasView.image = self.challengeImage;
		
		UIImageView *watermarkImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 23.0, 620.0, 830.0)];
		watermarkImgView.image = [UIImage imageNamed:@"waterMark.png"];
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
		_progressHUD.graceTime = 2.0;
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
	
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	
	self.filename = [NSString stringWithFormat:@"%@_%@", [HONAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
	NSLog(@"https://hotornot-challenges.s3.amazonaws.com/%@", self.filename);
	
	@try {
		UIImageView *canvasView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW, kLargeH)];
		canvasView.image = self.challengeImage;
		
		UIImageView *watermarkImgView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0, kLargeH - 84.0, 568.0, 68.0)];
		watermarkImgView.image = [UIImage imageNamed:@"waterMark.png"];
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
		_progressHUD.graceTime = 2.0;
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
	self.placeholderLabel.hidden = YES;
	
	if ([textField.text length] == 0)
		textField.text = _rndSubject;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	if ([textField.text length] == 0)
		self.placeholderLabel.hidden = NO;
	
	self.subjectName = textField.text;
}


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"HONChallengerPickerViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
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
		
		} else {
			[_progressHUD hide:YES];
			_progressHUD = nil;
			
			HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:challengeResult];
			[HONFacebookCaller postToTimeline:vo];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_LIST" object:nil];
			
			if ([[challengeResult objectForKey:@"status"] intValue] == 7) {
				NSLog(@"-----------SEND INVITE-------------");
				[HONFacebookCaller sendAppRequest:self.fbID];
			}
			
			if ([self.fbID length] > 0)
				[HONFacebookCaller postToFriendTimeline:self.fbID article:vo];
			
			
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
			//[self.navigationController dismissViewControllerAnimated:YES completion:nil];
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}


@end
