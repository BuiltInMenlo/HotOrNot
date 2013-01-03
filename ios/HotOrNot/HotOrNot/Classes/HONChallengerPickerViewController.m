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

@interface HONChallengerPickerViewController () <UITextFieldDelegate, UISearchBarDelegate, FBFriendPickerDelegate, TapForTapAdViewDelegate> {
	CGFloat fbHeaderHeight;
}

@property(nonatomic, strong) NSString *subjectName;
@property(nonatomic) int challengerID;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@property(nonatomic, strong) UIImage *challengeImage;
@property(nonatomic, strong) NSString *fbID;
@property(nonatomic, strong) NSString *fbName;
@property(nonatomic, strong) NSString *filename;
@property(nonatomic, strong) UITextField *subjectTextField;
@property(nonatomic, strong) UIButton *editButton;
@property(nonatomic, strong) UIButton *loginFriendsButton;
@property(nonatomic, strong) UITextField *usernameTextField;
@property(nonatomic) BOOL isFlipped;

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (retain, nonatomic) UISearchBar *searchBar;
@property (retain, nonatomic) NSString *searchText;
@property (retain, nonatomic) NSMutableArray *friends;
@property (nonatomic, retain) HONHeaderView *friendPickerHeaderView;

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


@synthesize friendPickerController = _friendPickerController;
@synthesize searchBar = _searchBar;
@synthesize searchText = _searchText;


//@synthesize rndSubject = _rndSubject;

- (id)init {
	if ((self = [super init])) {
		//NSLog(@"init");
		self.view.backgroundColor = [UIColor blackColor];
		
		[[Mixpanel sharedInstance] track:@"Pick Challenger"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(_sessionStateChanged:)
																	name:HONSessionStateChangedNotification
																 object:nil];
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
		
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(_sessionStateChanged:)
																	name:HONSessionStateChangedNotification
																 object:nil];
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
		
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(_sessionStateChanged:)
																	name:HONSessionStateChangedNotification
																 object:nil];
	}
	
	return (self);
}

#pragma mark - View lifecycle
- (void)loadView {
	//NSLog(@"loadView");
	[super loadView];
	
	HONHeaderView *mainHeaderView = [[HONHeaderView alloc] initWithTitle:@"Confirm Challenge"];
	[self.view addSubview:mainHeaderView];
		
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 0.0, 74.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[mainHeaderView addSubview:backButton];
		
	//_rndSubject = [NSString stringWithFormat:@"#%@", [HONAppDelegate rndDefaultSubject]];
	
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
	[_subjectTextField setTag:0];
	[self.view addSubview:_subjectTextField];
		
	_editButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_editButton.frame = CGRectMake(265.0, 60.0, 44.0, 44.0);
	[_editButton setBackgroundImage:[UIImage imageNamed:@"closeXButton_nonActive.png"] forState:UIControlStateNormal];
	[_editButton setBackgroundImage:[UIImage imageNamed:@"closeXButton_Active.png"] forState:UIControlStateHighlighted];
	[_editButton addTarget:self action:@selector(_goEditSubject) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_editButton];
	
	_loginFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_loginFriendsButton.frame = CGRectMake(18.0, 338.0, 284.0, 49.0);
	[_loginFriendsButton setBackgroundImage:[UIImage imageNamed:(FBSession.activeSession.state == 513) ? @"challengeFriendsButton_nonActive.png" : @"loginFacebook_nonActive.png"] forState:UIControlStateNormal];
	[_loginFriendsButton setBackgroundImage:[UIImage imageNamed:(FBSession.activeSession.state == 513) ? @"challengeFriendsButton_Active.png" : @"loginFacebook_Active.png"] forState:UIControlStateHighlighted];
	
	if (FBSession.activeSession.state == 513)
		[_loginFriendsButton addTarget:self action:@selector(_goChallengeFriends) forControlEvents:UIControlEventTouchUpInside];
	else
		[_loginFriendsButton addTarget:self action:@selector(_goLogin) forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:_loginFriendsButton];
	
	UIButton *randomButton = [UIButton buttonWithType:UIButtonTypeCustom];
	randomButton.frame = CGRectMake(18.0, 398.0, 284.0, 49.0);
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
	
	
	_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 308.0, 200.0, 20.0)];
	//[_usernameTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_usernameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_usernameTextField setReturnKeyType:UIReturnKeyDone];
	[_usernameTextField setTextColor:[UIColor whiteColor]];
	[_usernameTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_usernameTextField.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
	_usernameTextField.keyboardType = UIKeyboardTypeDefault;
	_usernameTextField.text = @"Enter a username…";
	_usernameTextField.delegate = self;
	[_usernameTextField setTag:1];
	[self.view addSubview:_usernameTextField];
	
	UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
	acceptButton.frame = CGRectMake(220.0, 280.0, 96.0, 60.0);
	[acceptButton setBackgroundImage:[UIImage imageNamed:@"tableButtonAccept_nonActive.png"] forState:UIControlStateNormal];
	[acceptButton setBackgroundImage:[UIImage imageNamed:@"tableButtonAccept_Active.png"] forState:UIControlStateHighlighted];
	[acceptButton addTarget:self action:@selector(_goUsernameSubmit) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:acceptButton];
}


#pragma mark - Navigation
- (void)_goBack {
	[[Mixpanel sharedInstance] track:@"Pick Challenger Back"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self.navigationController popViewControllerAnimated:NO];
}

- (void)_goLogin {
	[[Mixpanel sharedInstance] track:@"Preview Challenge - Facebook Login"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[FBSession.activeSession closeAndClearTokenInformation];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[HONLoginViewController alloc] init]];
	[navController setNavigationBarHidden:YES];
	[self presentViewController:navController animated:YES completion:nil];
}

- (void)_goEditSubject {
	[[Mixpanel sharedInstance] track:@"Preview Challenge - Edit Hashtag"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_subjectTextField.text = @"";
	[_subjectTextField becomeFirstResponder];
}

- (void)_goUsernameSubmit {
	[[Mixpanel sharedInstance] track:@"Preview Challenge - Username Submit"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	self.filename = [NSString stringWithFormat:@"%@_%@", [HONAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
	self.fbName = _usernameTextField.text;
	[self _goUsernameChallenge];
}

- (void)_goChallengeFriends {
	[[Mixpanel sharedInstance] track:@"Pick Challenger - Friend"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	self.friendPickerController = [[FBFriendPickerViewController alloc] init];
	self.friendPickerController.title = @"Pick Friends";
	self.friendPickerController.allowsMultipleSelection = NO;
	self.friendPickerController.delegate = self;
	self.friendPickerController.sortOrdering = FBFriendDisplayByLastName;
	[self addCustomHeaderToFriendPickerView];
	[self.friendPickerController loadData];
	[self.friendPickerController clearSelection];
	
	// Use the modal wrapper method to display the picker.
	[self presentViewController:self.friendPickerController animated:YES completion:^(void){[self addSearchBarToFriendPickerView];}];
}

- (void)_goFriendChallenge {
	//NSData *imageData = UIImageJPEGRepresentation(self.image, kJPEGCompress);
	
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	
	@try {
		UIImageView *canvasView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
		canvasView.image = [HONAppDelegate cropImage:[HONAppDelegate scaleImage:self.challengeImage toSize:CGSizeMake(kLargeW, kLargeH)] toRect:CGRectMake(0.0, (((kLargeH - kLargeW) * 0.5) * 0.5), kLargeW, kLargeW)];
		
//		UIImageView *watermarkImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
//		watermarkImgView.image = [UIImage imageNamed:@"612x612_overlay@2x.png"];
//		[canvasView addSubview:watermarkImgView];
		
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
		por1.data = UIImageJPEGRepresentation(t1Image, kJPEGCompress);
		[s3 putObject:por1];
				
		S3PutObjectRequest *por3 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_m.jpg", self.filename] inBucket:@"hotornot-challenges"];
		por3.contentType = @"image/jpeg";
		por3.data = UIImageJPEGRepresentation(mImage, kJPEGCompress);
		[s3 putObject:por3];
		
		S3PutObjectRequest *por4 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_l.jpg", self.filename] inBucket:@"hotornot-challenges"];
		por4.contentType = @"image/jpeg";
		por4.data = UIImageJPEGRepresentation(lImage, kJPEGCompress);
		[s3 putObject:por4];
		
		if ([self.subjectName length] == 0)
			self.subjectName = [HONAppDelegate rndDefaultSubject];
		
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
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
			_progressHUD.labelText = NSLocalizedString(@"Upload Error", @"Status message when internet connectivity is lost");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
		}
		
		//[[[UIAlertView alloc] initWithTitle:@"Upload Error" message:exception.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}
}

- (void)_goUsernameChallenge {
	//NSData *imageData = UIImageJPEGRepresentation(self.image, kJPEGCompress);
	
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	
	@try {
		UIImageView *canvasView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
		canvasView.image = [HONAppDelegate cropImage:[HONAppDelegate scaleImage:self.challengeImage toSize:CGSizeMake(kLargeW, kLargeH)] toRect:CGRectMake(0.0, (((kLargeH - kLargeW) * 0.5) * 0.5), kLargeW, kLargeW)];
		
//		UIImageView *watermarkImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
//		watermarkImgView.image = [UIImage imageNamed:@"612x612_overlay@2x.png"];
//		[canvasView addSubview:watermarkImgView];
		
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
		por1.data = UIImageJPEGRepresentation(t1Image, kJPEGCompress);
		[s3 putObject:por1];
		
		S3PutObjectRequest *por3 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_m.jpg", self.filename] inBucket:@"hotornot-challenges"];
		por3.contentType = @"image/jpeg";
		por3.data = UIImageJPEGRepresentation(mImage, kJPEGCompress);
		[s3 putObject:por3];
		
		S3PutObjectRequest *por4 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_l.jpg", self.filename] inBucket:@"hotornot-challenges"];
		por4.contentType = @"image/jpeg";
		por4.data = UIImageJPEGRepresentation(lImage, kJPEGCompress);
		[s3 putObject:por4];
		
		if ([self.subjectName length] == 0)
			self.subjectName = [HONAppDelegate rndDefaultSubject];
		
		ASIFormDataRequest *submitChallengeRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
		[submitChallengeRequest setDelegate:self];
		[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"%d", 7] forKey:@"action"];
		[submitChallengeRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
		[submitChallengeRequest setPostValue:[NSString stringWithFormat:@"https://hotornot-challenges.s3.amazonaws.com/%@", self.filename] forKey:@"imgURL"];
		[submitChallengeRequest setPostValue:self.subjectName forKey:@"subject"];
		[submitChallengeRequest setPostValue:self.fbName forKey:@"username"];
		[submitChallengeRequest startAsynchronous];
		
	} @catch (AmazonClientException *exception) {
		if (_progressHUD != nil) {
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
			_progressHUD.labelText = NSLocalizedString(@"Upload Error", @"Status message when internet connectivity is lost");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
		}
		
		//[[[UIAlertView alloc] initWithTitle:@"Upload Error" message:exception.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}
}


- (void)_goRandomChallenge {
	[[Mixpanel sharedInstance] track:@"Pick Challenger - Random"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	//NSData *imageData = UIImageJPEGRepresentation(self.image, kJPEGCompress);
	
	if ([self.subjectName length] == 0)
		self.subjectName = [HONAppDelegate rndDefaultSubject];
	
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	
	self.filename = [NSString stringWithFormat:@"%@_%@", [HONAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
	NSLog(@"https://hotornot-challenges.s3.amazonaws.com/%@", self.filename);
	
	@try {
		UIImageView *canvasView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
		canvasView.image = [HONAppDelegate cropImage:[HONAppDelegate scaleImage:self.challengeImage toSize:CGSizeMake(kLargeW, kLargeH)] toRect:CGRectMake(0.0, (((kLargeH - kLargeW) * 0.5) * 0.5), kLargeW, kLargeW)];
		
//		UIImageView *watermarkImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
//		watermarkImgView.image = [UIImage imageNamed:@"612x612_overlay@2x.png"];
//		[canvasView addSubview:watermarkImgView];
		
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
		por1.data = UIImageJPEGRepresentation(t1Image, kJPEGCompress);
		[s3 putObject:por1];
				
		S3PutObjectRequest *por3 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_m.jpg", self.filename] inBucket:@"hotornot-challenges"];
		por3.contentType = @"image/jpeg";
		por3.data = UIImageJPEGRepresentation(mImage, kJPEGCompress);
		[s3 putObject:por3];
		
		S3PutObjectRequest *por4 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_l.jpg", self.filename] inBucket:@"hotornot-challenges"];
		por4.contentType = @"image/jpeg";
		por4.data = UIImageJPEGRepresentation(lImage, kJPEGCompress);
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
	
	self.friendPickerHeaderView = [[HONHeaderView alloc] initWithTitle:@"Select Friends"];
	self.friendPickerHeaderView.autoresizingMask = self.friendPickerHeaderView.autoresizingMask | UIViewAutoresizingFlexibleWidth;
	
	// Cancel Button
	UIButton *customCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[customCancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
	[customCancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
	[customCancelButton addTarget:self action:@selector(facebookViewControllerCancelWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	customCancelButton.frame = CGRectMake(0, 0, 74.0, 44.0);
	[self.friendPickerHeaderView addSubview:customCancelButton];
	
	// Done Button
	UIButton *customDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[customDoneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[customDoneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[customDoneButton addTarget:self action:@selector(facebookViewControllerDoneWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	customDoneButton.frame = CGRectMake(self.view.bounds.size.width - 59.0, 5.0, 54.0, 34.0);
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
		self.searchBar.tintColor = [UIColor colorWithRed:0.2863 green:0.2706 blue:0.7098 alpha:1.0];
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
	
		self.filename = [NSString stringWithFormat:@"%@_%@", [HONAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
		self.fbID = [[self.friendPickerController.selection lastObject] objectForKey:@"id"];
		self.fbName = [[self.friendPickerController.selection lastObject] objectForKey:@"username"];
		NSLog(@"FRIEND:[%@]", [self.friendPickerController.selection lastObject]);
		
		[self handlePickerDone];
		[self _goFriendChallenge];
	}
}

- (void)handlePickerDone
{
	self.searchBar = nil;
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISearchBarDelegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
	[self handleSearch:searchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
	self.searchText = nil;
	[searchBar resignFirstResponder];
}




#pragma mark - Notifications
- (void)_sessionStateChanged:(NSNotification *)notification {
	FBSession *session = (FBSession *)[notification object];
	NSLog(@"FBSession:[%d] (HONChallengerPickerViewController)", session.state);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"Y"];
	
	[_loginFriendsButton setBackgroundImage:[UIImage imageNamed:(FBSession.activeSession.state == 513) ? @"challengeFriendsButton_nonActive.png" : @"loginFacebook_nonActive.png"] forState:UIControlStateNormal];
	[_loginFriendsButton setBackgroundImage:[UIImage imageNamed:(FBSession.activeSession.state == 513) ? @"challengeFriendsButton_Active.png" : @"loginFacebook_Active.png"] forState:UIControlStateHighlighted];
	
	[_loginFriendsButton removeTarget:self action:@selector(_goChallengeFriends) forControlEvents:UIControlEventTouchUpInside];
	[_loginFriendsButton removeTarget:self action:@selector(_goLogin) forControlEvents:UIControlEventTouchUpInside];
	
	if (FBSession.activeSession.state == 513)
		[_loginFriendsButton addTarget:self action:@selector(_goChallengeFriends) forControlEvents:UIControlEventTouchUpInside];
	else
		[_loginFriendsButton addTarget:self action:@selector(_goLogin) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	
	if (textField.tag == 0) {
		[[Mixpanel sharedInstance] track:@"Preview Challenge - Edit Hashtag"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		_editButton.hidden = YES;
	
	} else if (textField.tag == 1) {
		[[Mixpanel sharedInstance] track:@"Preview Challenge - Edit Usernme"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		textField.text = @"#";
	}
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	
	return (YES);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	if (textField.tag == 0) {
		_editButton.hidden = NO;
		
		if ([textField.text length] == 0)
			textField.text = self.subjectName;
		
		else
			self.subjectName = textField.text;
	
	} else if (textField.tag == 1) {
		if ([textField.text length] == 0)
			textField.text = @"Enter a username…";
		
		else
			self.fbName = textField.text;
	}
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
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
			_progressHUD.labelText = NSLocalizedString(@"Submission Failed!", @"Status message when submit fails");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
		
		} else {
			if (![[challengeResult objectForKey:@"result"] isEqualToString:@"fail"]) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
				
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:challengeResult];
				[HONFacebookCaller postToTimeline:vo];
				
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_LIST" object:nil];
				
				if (vo.statusID == 7)
					[HONFacebookCaller sendAppRequestToUser:self.fbID];
				
				
				if (vo.statusID == 4) {
					_progressHUD.minShowTime = kHUDTime;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
					_progressHUD.labelText = [NSString stringWithFormat:@"Matched w/ %@!", vo.challengerName];
					[_progressHUD show:NO];
					[_progressHUD hide:YES afterDelay:1.5];
					_progressHUD = nil;
				}
				
				if ([self.fbID length] > 0) {
					if ([[[HONAppDelegate facebookFriendPosting] objectForKey:@"invite"] isEqualToString:@"Y"])
						[HONFacebookCaller sendAppRequestToUser:self.fbID challenge:vo];
					
					if ([[[HONAppDelegate facebookFriendPosting] objectForKey:@"friend_wall"] isEqualToString:@"Y"])
						[HONFacebookCaller postToFriendTimeline:self.fbID challenge:vo];
				}
				
				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void){
					[[NSNotificationCenter defaultCenter] postNotificationName:@"FB_SWITCH_HIDDEN" object:@"N"];
					
					if ([[[[[NSUserDefaults standardUserDefaults] objectForKey:@"web_ctas"] objectAtIndex:1] objectForKey:@"enabled"] isEqualToString:@"Y"])
						[[NSNotificationCenter defaultCenter] postNotificationName:@"WEB_CTA" object:[[[NSUserDefaults standardUserDefaults] objectForKey:@"web_ctas"] objectAtIndex:1]];
				}];
			
			} else {
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
				_progressHUD.labelText = NSLocalizedString(@"Username not found!", @"Status message when username isn't in the system");
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:1.5];
				_progressHUD = nil;
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


- (UIViewController *)rootViewController {
	return (self);
}

@end
