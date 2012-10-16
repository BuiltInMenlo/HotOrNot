//
//  HONChallengerPickerViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <AWSiOSSDK/S3/AmazonS3Client.h>
#import <FacebookSDK/FacebookSDK.h>

#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"

#import "HONChallengerPickerViewController.h"
#import "HONAppDelegate.h"
#import "HONChallengeVO.h"
#import "HONFacebookCaller.h"
#import "HONHeaderView.h"

@interface HONChallengerPickerViewController () <UITextFieldDelegate, FBFriendPickerDelegate>
@property(nonatomic, strong) NSString *subjectName;
@property (nonatomic) int challengerID;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@property(nonatomic, strong) UIImage *challengeImage;
@property(nonatomic, strong) NSString *fbID;
@property(nonatomic, strong) NSString *filename;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UITextField *subjectTextField;
@end

@implementation HONChallengerPickerViewController

@synthesize subjectName = _subjectName;
@synthesize challengerID = _challengerID;
@synthesize progressHUD = _progressHUD;
@synthesize fbID = _fbID;
@synthesize challengeImage = _challengeImage;
@synthesize filename = _filename;
@synthesize placeholderLabel = _placeholderLabel;
@synthesize subjectTextField = _subjectTextField;

- (id)init {
	if ((self = [super init])) {
		NSLog(@"init");
		self.view.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	}
	
	return (self);
}

- (id)initWithImage:(UIImage *)img {
	if ((self = [super init])) {
		NSLog(@"initWithImage:[%f, %f]", img.size.width, img.size.height);
		self.view.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
		self.challengeImage = img;
	}
	
	return (self);
}

#pragma mark - View lifecycle
- (void)loadView {
	NSLog(@"loadView");
	[super loadView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Edit Challenge"];
	[self.view addSubview:headerView];
		
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(5.0, 0.0, 74.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backButton];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 45.0, 320.0, 480.0)];
	[bgImgView setImage:[UIImage imageNamed:@"challengePreviewBG.png"]];
	bgImgView.userInteractionEnabled = YES;
	[self.view addSubview:bgImgView];
	
	_subjectTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 25.0, 280.0, 20.0)];
	//[_subjectTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_subjectTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_subjectTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_subjectTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
	[_subjectTextField setReturnKeyType:UIReturnKeyDone];
	[_subjectTextField setTextColor:[UIColor colorWithWhite:0.482 alpha:1.0]];
	[_subjectTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
	//_subjectTextField.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	_subjectTextField.keyboardType = UIKeyboardTypeDefault;
	_subjectTextField.text = @"";
	_subjectTextField.delegate = self;
	[bgImgView addSubview:_subjectTextField];
	
	_placeholderLabel = [[UILabel alloc] initWithFrame:_subjectTextField.frame];
	//_placeholderLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
	_placeholderLabel.textColor = [UIColor colorWithWhite:0.620 alpha:1.0];
	_placeholderLabel.backgroundColor = [UIColor clearColor];
	_placeholderLabel.textAlignment = NSTextAlignmentCenter;
	_placeholderLabel.text = @"Give your challenge a #hashtag";
	[bgImgView addSubview:self.placeholderLabel];
	
	UIButton *friendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	friendsButton.frame = CGRectMake(20.0, 350.0, 284.0, 49.0);
	[friendsButton setBackgroundImage:[UIImage imageNamed:@"challengeFriendsButton_nonActive.png"] forState:UIControlStateNormal];
	[friendsButton setBackgroundImage:[UIImage imageNamed:@"challengeFriendsButton_Active.png"] forState:UIControlStateHighlighted];
	[friendsButton addTarget:self action:@selector(_goChallengeFriends) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:friendsButton];
	
	UIButton *randomButton = [UIButton buttonWithType:UIButtonTypeCustom];
	randomButton.frame = CGRectMake(20.0, 400.0, 284.0, 49.0);
	[randomButton setBackgroundImage:[UIImage imageNamed:@"challengeRandomButton_nonActive.png"] forState:UIControlStateNormal];
	[randomButton setBackgroundImage:[UIImage imageNamed:@"challengeRandomButton_Active.png"] forState:UIControlStateHighlighted];
	[randomButton addTarget:self action:@selector(_goRandomChallenge) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:randomButton];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(30.0, 105.0, 240.0, 240.0)];
	holderView.clipsToBounds = YES;
	[self.view addSubview:holderView];
	
	UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(-85.0, -40.0, 480.0, 360.0)];
	imgView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	imgView.image = self.challengeImage;
	imgView.transform = CGAffineTransformMakeRotation(M_PI / 2);
	[holderView addSubview:imgView];
	
	NSLog(@"IMAGE:[%f, %f]", self.challengeImage.size.width, self.challengeImage.size.height);
}


#pragma mark - Navigation
- (void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goChallengeFriends {
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
			 [[[UIAlertView alloc] initWithTitle:@"You Picked:"
												  message:@"<No Friends Selected>"
												 delegate:nil
									 cancelButtonTitle:@"OK"
									 otherButtonTitles:nil]
			  show];
			 
		 } else {
			 // submit
			 self.filename = [NSString stringWithFormat:@"%@_%@", [HONAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
			 self.fbID = [[friendPickerController.selection lastObject] objectForKey:@"id"];
			 
			 [self _goFriendChallenge];
		 }
	 }];
}

- (void)_goFriendChallenge {
	//NSData *imageData = UIImageJPEGRepresentation(self.image, 1.0);
	
	UIImage *lImage = [HONAppDelegate scaleImage:self.challengeImage toSize:CGSizeMake(kLargeW, kLargeH)];
	UIImage *mImage = [HONAppDelegate scaleImage:self.challengeImage toSize:CGSizeMake(kMediumW, kMediumH)];
	UIImage *t1Image = [HONAppDelegate scaleImage:self.challengeImage toSize:CGSizeMake(kThumb1W, kThumb1H)];
	//UIImage *t2Image = [HONAppDelegate scaleImage:self.challengeImage toSize:CGSizeMake(kThumb2W, kThumb2H)];
	
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:@"AKIAJVS6Y36AQCMRWLQQ" withSecretKey:@"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"];
	
	@try {
		NSLog(@"https://hotornot-challenges.s3.amazonaws.com/%@", self.filename);
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
		
//		S3PutObjectRequest *por2 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_t2.jpg", self.filename] inBucket:@"hotornot-challenges"];
//		por2.contentType = @"image/jpeg";
//		por2.data = UIImageJPEGRepresentation(t2Image, 1.0);
//		[s3 putObject:por2];
		
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
		[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"%d", 8] forKey:@"action"];
		[submitChallengeRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
		[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"https://hotornot-challenges.s3.amazonaws.com/%@", self.filename] forKey:@"imgURL"];
		[submitChallengeRequest setPostValue:self.subjectName forKey:@"subject"];
		[submitChallengeRequest setPostValue:self.fbID forKey:@"fbID"];
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
	//NSData *imageData = UIImageJPEGRepresentation(self.image, 1.0);
	
	UIImage *lImage = [HONAppDelegate scaleImage:self.challengeImage toSize:CGSizeMake(kLargeW, kLargeH)];
	UIImage *mImage = [HONAppDelegate scaleImage:self.challengeImage toSize:CGSizeMake(kMediumW, kMediumH)];
	UIImage *t1Image = [HONAppDelegate scaleImage:self.challengeImage toSize:CGSizeMake(kThumb1W, kThumb1H)];
	//UIImage *t2Image = [HONAppDelegate scaleImage:self.challengeImage toSize:CGSizeMake(kThumb2W, kThumb2H)];
	
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:@"AKIAJVS6Y36AQCMRWLQQ" withSecretKey:@"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"];
	
	self.filename = [NSString stringWithFormat:@"%@_%@", [HONAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
	NSLog(@"https://hotornot-challenges.s3.amazonaws.com/%@", self.filename);
	
	@try {
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
		
//		S3PutObjectRequest *por2 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_t2.jpg", self.filename] inBucket:@"hotornot-challenges"];
//		por2.contentType = @"image/jpeg";
//		por2.data = UIImageJPEGRepresentation(t2Image, 1.0);
//		[s3 putObject:por2];
		
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
			
//			if (self.fbID != nil)
//				[HONFacebookCaller postToFriendTimeline:self.fbID article:vo];
			
			
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
			//[self.navigationController dismissViewControllerAnimated:YES completion:nil];
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}


@end
