//
//  HONChallengerPickerViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AWSiOSSDK/S3/AmazonS3Client.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "Facebook.h"
#import "TapForTap.h"
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
@property(nonatomic, strong) UIButton *randomButton;
@property(nonatomic, strong) UITextField *usernameTextField;
@property(nonatomic, strong) UIImageView *bgTextImageView;
@property(nonatomic) BOOL isFlipped;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (retain, nonatomic) UISearchBar *searchBar;
@property (retain, nonatomic) NSString *searchText;
@property (retain, nonatomic) NSMutableArray *friends;
@property (nonatomic, retain) HONHeaderView *friendPickerHeaderView;
@end

@implementation HONChallengerPickerViewController

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
		_isFlipped = NO;
		self.view.backgroundColor = [UIColor blackColor];
		_challengeImage = img;
		_subjectName = subject;
				
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
		_isFlipped = YES;
		self.view.backgroundColor = [UIColor blackColor];
		_challengeImage = img;
		_subjectName = subject;
		
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
	
	
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"cameraExperience3rdStepBackground-568h" : @"cameraExperience3rdStepBackground"];
	[self.view addSubview:bgImgView];
	
	HONHeaderView *mainHeaderView = [[HONHeaderView alloc] initWithTitle:@"SUBMIT"];
	[self.view addSubview:mainHeaderView];
		
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(5.0, 5.0, 74.0, 34.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"cameraBackButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"cameraBackButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[mainHeaderView addSubview:backButton];
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = CGRectMake(253.0, 5.0, 64.0, 34.0);
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
	[mainHeaderView addSubview:cancelButton];
	
	UIImageView *subjectBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(128.0, 78.0, 174.0, 44.0)];
	subjectBGImageView.image = [UIImage imageNamed:@"cameraExperience3rdStepInutField"];
	subjectBGImageView.userInteractionEnabled = YES;
	[self.view addSubview:subjectBGImageView];
		
	_subjectTextField = [[UITextField alloc] initWithFrame:CGRectMake(15.0, 14.0, 125.0, 20.0)];
	//[_subjectTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_subjectTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_subjectTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_subjectTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_subjectTextField setReturnKeyType:UIReturnKeyDone];
	[_subjectTextField setTextColor:[UIColor blackColor]];
	[_subjectTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_subjectTextField.font = [[HONAppDelegate freightSansBlack] fontWithSize:16];
	_subjectTextField.keyboardType = UIKeyboardTypeDefault;
	_subjectTextField.text = _subjectName;
	_subjectTextField.delegate = self;
	[_subjectTextField setTag:0];
	[subjectBGImageView addSubview:_subjectTextField];
		
	_editButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_editButton.frame = CGRectMake(137.0, 6.0, 34.0, 34.0);
	[_editButton setBackgroundImage:[UIImage imageNamed:@"clearTextButton_nonActive"] forState:UIControlStateNormal];
	[_editButton setBackgroundImage:[UIImage imageNamed:@"clearTextButton_Active"] forState:UIControlStateHighlighted];
	[_editButton addTarget:self action:@selector(_goEditSubject) forControlEvents:UIControlEventTouchUpInside];
	[subjectBGImageView addSubview:_editButton];
	
	
	
	_randomButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_randomButton.frame = CGRectMake(23.0, 203.0, 274.0, 74.0);
	[_randomButton setBackgroundImage:[UIImage imageNamed:@"submitChallengeButton2_nonActive"] forState:UIControlStateNormal];
	[_randomButton setBackgroundImage:[UIImage imageNamed:@"submitChallengeButton2_Active"] forState:UIControlStateHighlighted];
	[_randomButton addTarget:self action:@selector(_goRandomChallenge) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_randomButton];
	
	_loginFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_loginFriendsButton.frame = CGRectMake(23.0, 300.0, 274.0, 58.0);
	[_loginFriendsButton setBackgroundImage:[UIImage imageNamed:@"challengeFacebookFriends_nonActive"] forState:UIControlStateNormal];
	[_loginFriendsButton setBackgroundImage:[UIImage imageNamed:@"challengeFacebookFriends_Active"] forState:UIControlStateHighlighted];
	[_loginFriendsButton addTarget:self action:(FBSession.activeSession.state == 513) ? @selector(_goChallengeFriends) : @selector(_goLogin) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_loginFriendsButton];
	
	_bgTextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 55.0, 320.0, 55.0)];
	_bgTextImageView.image = [UIImage imageNamed:@"keyboardInputField"];
	_bgTextImageView.userInteractionEnabled = YES;
	_bgTextImageView.hidden = YES;
	[self.view addSubview:_bgTextImageView];
	
	UIImageView *usernameBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(23.0, 380.0, 274.0, 44.0)];
	usernameBGImageView.image = [UIImage imageNamed:@"cameraInputField_nonActive"];
	usernameBGImageView.userInteractionEnabled = YES;
	[self.view addSubview:usernameBGImageView];
	
	UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
	sendButton.frame = CGRectMake(237.0, 6.0, 34.0, 34.0);
	[sendButton setBackgroundImage:[UIImage imageNamed:@"submitText"] forState:UIControlStateNormal];
	[sendButton setBackgroundImage:[UIImage imageNamed:@"submitText"] forState:UIControlStateHighlighted];
	[sendButton addTarget:self action:@selector(_goUsernameSubmit) forControlEvents:UIControlEventTouchUpInside];
	[usernameBGImageView addSubview:sendButton];
	
	_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(16.0, 14.0, 230.0, 20.0)];
	//[_usernameTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_usernameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_usernameTextField setReturnKeyType:UIReturnKeyDone];
	[_usernameTextField setTextColor:[HONAppDelegate honGreyTxtColor]];
	[_usernameTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_usernameTextField.font = [[HONAppDelegate freightSansBlack] fontWithSize:14];
	_usernameTextField.keyboardType = UIKeyboardTypeDefault;
	_usernameTextField.text = @"ENTER A USERNAME HERE";
	_usernameTextField.delegate = self;
	[_usernameTextField setTag:1];
	
//	_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(16.0, 14.0, 230.0, 20.0)];
//	//[_usernameTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
//	[_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
//	_usernameTextField.backgroundColor = [UIColor redColor];
//	[_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
//	_usernameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
//	[_usernameTextField setReturnKeyType:UIReturnKeyDone];
//	[_usernameTextField setTextColor:[HONAppDelegate honGreyTxtColor]];
//	[_usernameTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
//	_usernameTextField.font = [[HONAppDelegate freightSansBlack] fontWithSize:14];
//	_usernameTextField.keyboardType = UIKeyboardTypeDefault;
//	_usernameTextField.text = @"ENTER A USERNAME HERE";
//	_usernameTextField.delegate = self;
//	[_usernameTextField setTag:1];
	[usernameBGImageView addSubview:_usernameTextField];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(20.0, 63.0, 90.0, 90.0)];
	holderView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	holderView.clipsToBounds = YES;
	[self.view addSubview:holderView];
	
	UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -10.0, 90.0, 90.0 * kPhotoRatio)];
	imgView.image = [HONAppDelegate scaleImage:_challengeImage toSize:CGSizeMake(kLargeW * 0.5, kLargeH * 0.5)];
	[holderView addSubview:imgView];
	
//	UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 63.0, 90.0, 90.0)];
//	imgView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
//	imgView.image = [HONAppDelegate cropImage:[HONAppDelegate scaleImage:_challengeImage toSize:CGSizeMake(kLargeW * 0.5, kLargeH * 0.5)] toRect:CGRectMake(0.0, (((kLargeH - kLargeW) * 0.5) * 0.5), kLargeW * 0.5, kLargeW * 0.5)];
//	[self.view addSubview:imgView];
	
	if (_isFlipped)
		imgView.image = [UIImage imageWithCGImage:imgView.image.CGImage scale:1.0 orientation:UIImageOrientationUpMirrored];
	
	UIImageView *watermarkImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 200.0)];
	watermarkImgView.image = [UIImage imageNamed:@"512x512_cameraOverlay"];
	//[imgView addSubview:watermarkImgView];
	
	_subjectTextField.text = _subjectName;
	//NSLog(@"IMAGE:[%f, %f]", _challengeImage.size.width, _challengeImage.size.height);
}


#pragma mark - Navigation
- (void)_goBack {
	[[Mixpanel sharedInstance] track:@"Pick Challenger Back"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self.navigationController popViewControllerAnimated:NO];
}

- (void)_goCancel {
	[[Mixpanel sharedInstance] track:@"Pick Challenger Cancel"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void){
	}];
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
	
	_subjectTextField.text = @"#";
	[_subjectTextField becomeFirstResponder];
}

- (void)_goUsernameSubmit {
	if ([[[HONAppDelegate infoForUser] objectForKey:@"name"] isEqualToString:_usernameTextField.text]) {
		UIAlertView *alert = [[UIAlertView alloc]
									 initWithTitle:@"Username Error"
									 message:@"You cannot challenge yourself!"
									 delegate:nil
									 cancelButtonTitle:@"OK"
									 otherButtonTitles:nil];
		
		[alert show];
	
	} else {
		[[Mixpanel sharedInstance] track:@"Preview Challenge - Username Submit"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		_filename = [NSString stringWithFormat:@"%@_%@", [HONAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
		_fbName = _usernameTextField.text;
		[self _goUsernameChallenge];
	}
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
	//NSData *imageData = UIImageJPEGRepresentation(_image, kJPEGCompress);
	
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	
	@try {
		float ratio = _challengeImage.size.height / _challengeImage.size.width;
		UIImage *lImage = [HONAppDelegate scaleImage:_challengeImage toSize:CGSizeMake(kLargeW, kLargeW * ratio)];
		lImage = [HONAppDelegate cropImage:lImage toRect:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
		
		UIImage *mImage = [HONAppDelegate scaleImage:_challengeImage toSize:CGSizeMake(kMediumW * 2.0, kMediumH * 2.0)];
		UIImage *t1Image = [HONAppDelegate scaleImage:_challengeImage toSize:CGSizeMake(kThumb1W * 2.0, kThumb1H * 2.0)];
		
//		UIImageView *sqCanvasView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
//		sqCanvasView.backgroundColor = [UIColor blackColor];
//		sqCanvasView.image = [HONAppDelegate cropImage:[HONAppDelegate scaleImage:_challengeImage toSize:CGSizeMake(kLargeW, kLargeH)] toRect:CGRectMake(0.0, (((kLargeH - kLargeW) * 0.5) * 0.5), kLargeW, kLargeW)];
//		size = [sqCanvasView bounds].size;
//		UIGraphicsBeginImageContext(size);
//		[[sqCanvasView layer] renderInContext:UIGraphicsGetCurrentContext()];
//		lImage = UIGraphicsGetImageFromCurrentImageContext();
//		UIGraphicsEndImageContext();
		
		
		NSLog(@"https://hotornot-challenges.s3.amazonaws.com/%@", _filename);
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.labelText = @"Submitting Challenge…";
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.taskInProgress = YES;
		
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-challenges"]];
		S3PutObjectRequest *por1 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_t.jpg", _filename] inBucket:@"hotornot-challenges"];
		por1.contentType = @"image/jpeg";
		por1.data = UIImageJPEGRepresentation(t1Image, kJPEGCompress);
		[s3 putObject:por1];
				
		S3PutObjectRequest *por3 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_m.jpg", _filename] inBucket:@"hotornot-challenges"];
		por3.contentType = @"image/jpeg";
		por3.data = UIImageJPEGRepresentation(mImage, kJPEGCompress);
		[s3 putObject:por3];
		
		S3PutObjectRequest *por4 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_l.jpg", _filename] inBucket:@"hotornot-challenges"];
		por4.contentType = @"image/jpeg";
		por4.data = UIImageJPEGRepresentation(lImage, kJPEGCompress);
		[s3 putObject:por4];
		
		if ([_subjectName length] == 0)
			_subjectName = [HONAppDelegate rndDefaultSubject];
		
		AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
		NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSString stringWithFormat:@"%d", 8], @"action",
										[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
										[NSString stringWithFormat:@"https://hotornot-challenges.s3.amazonaws.com/%@", _filename], @"imgURL",
										_subjectName, @"subject",
										_fbID, @"fbID",
										_fbName, @"fbName", 
										nil];
		
		[httpClient postPath:kChallengesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSError *error = nil;
			NSDictionary *challengeResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			
			if (error != nil) {
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = NSLocalizedString(@"Submission Failed!", @"Status message when submit fails");
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:1.5];
				_progressHUD = nil;
			
			} else {
				NSLog(@"HONChallengerPickerViewController AFNetworking: %@", challengeResult);
				
				if (![[challengeResult objectForKey:@"result"] isEqualToString:@"fail"]) {
					[_progressHUD hide:YES];
					_progressHUD = nil;
					
					HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:challengeResult];
					[HONFacebookCaller postToTimeline:vo];
					
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:nil];
					
					if (vo.statusID == 7)
						[HONFacebookCaller sendAppRequestToUser:_fbID];
					
					
					if (vo.statusID == 4) {
						_progressHUD.minShowTime = kHUDTime;
						_progressHUD.mode = MBProgressHUDModeCustomView;
						_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkIcon"]];
						_progressHUD.labelText = @"Challenge Matched!";
						[_progressHUD show:NO];
						[_progressHUD hide:YES afterDelay:1.5];
						_progressHUD = nil;
					}
					
					if ([_fbID length] > 0) {
						if ([[[HONAppDelegate facebookFriendPosting] objectForKey:@"invite"] isEqualToString:@"Y"])
							[HONFacebookCaller sendAppRequestToUser:_fbID challenge:vo];
						
						if ([[[HONAppDelegate facebookFriendPosting] objectForKey:@"friend_wall"] isEqualToString:@"Y"])
							[HONFacebookCaller postToFriendTimeline:_fbID challenge:vo];
					}
					
					[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
						if ([[[[[NSUserDefaults standardUserDefaults] objectForKey:@"web_ctas"] objectAtIndex:1] objectForKey:@"enabled"] isEqualToString:@"Y"])
							[[NSNotificationCenter defaultCenter] postNotificationName:@"WEB_CTA" object:[[[NSUserDefaults standardUserDefaults] objectForKey:@"web_ctas"] objectAtIndex:1]];
					}];
				}
			}
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"ChallengerPickerViewController AFNetworking %@", [error localizedDescription]);
			
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"Submission Failed!", @"Status message when submit fails");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
		}];
		
	} @catch (AmazonClientException *exception) {
		if (_progressHUD != nil) {
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"Upload Error", @"Status message when internet connectivity is lost");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
		}
		
		//[[[UIAlertView alloc] initWithTitle:@"Upload Error" message:exception.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}
}

- (void)_goUsernameChallenge {
	//NSData *imageData = UIImageJPEGRepresentation(_image, kJPEGCompress);
	
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	
	@try {
		float ratio = _challengeImage.size.height / _challengeImage.size.width;
		UIImage *lImage = [HONAppDelegate scaleImage:_challengeImage toSize:CGSizeMake(kLargeW, kLargeW * ratio)];
		lImage = [HONAppDelegate cropImage:lImage toRect:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
		
		UIImage *mImage = [HONAppDelegate scaleImage:_challengeImage toSize:CGSizeMake(kMediumW * 2.0, kMediumH * 2.0)];
		UIImage *t1Image = [HONAppDelegate scaleImage:_challengeImage toSize:CGSizeMake(kThumb1W * 2.0, kThumb1H * 2.0)];
		
//		UIImageView *sqCanvasView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
//		sqCanvasView.backgroundColor = [UIColor blackColor];
//		sqCanvasView.image = [HONAppDelegate cropImage:[HONAppDelegate scaleImage:_challengeImage toSize:CGSizeMake(kLargeW, kLargeH)] toRect:CGRectMake(0.0, (((kLargeH - kLargeW) * 0.5) * 0.5), kLargeW, kLargeW)];
//		size = [sqCanvasView bounds].size;
//		UIGraphicsBeginImageContext(size);
//		[[sqCanvasView layer] renderInContext:UIGraphicsGetCurrentContext()];
//		lImage = UIGraphicsGetImageFromCurrentImageContext();
//		UIGraphicsEndImageContext();
		
		NSLog(@"https://hotornot-challenges.s3.amazonaws.com/%@", _filename);
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.labelText = @"Submitting Challenge…";
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.taskInProgress = YES;
		
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-challenges"]];
		S3PutObjectRequest *por1 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_t.jpg", _filename] inBucket:@"hotornot-challenges"];
		por1.contentType = @"image/jpeg";
		por1.data = UIImageJPEGRepresentation(t1Image, kJPEGCompress);
		[s3 putObject:por1];
		
		S3PutObjectRequest *por3 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_m.jpg", _filename] inBucket:@"hotornot-challenges"];
		por3.contentType = @"image/jpeg";
		por3.data = UIImageJPEGRepresentation(mImage, kJPEGCompress);
		[s3 putObject:por3];
		
		S3PutObjectRequest *por4 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_l.jpg", _filename] inBucket:@"hotornot-challenges"];
		por4.contentType = @"image/jpeg";
		por4.data = UIImageJPEGRepresentation(lImage, kJPEGCompress);
		[s3 putObject:por4];
		
		if ([_subjectName length] == 0)
			_subjectName = [HONAppDelegate rndDefaultSubject];
		
		
		AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
		NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSString stringWithFormat:@"%d", 7], @"action",
										[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
										[NSString stringWithFormat:@"https://hotornot-challenges.s3.amazonaws.com/%@", _filename], @"imgURL",
										_subjectName, @"subject",
										_fbName, @"username",
										nil];
		
		[httpClient postPath:kChallengesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSError *error = nil;
			NSDictionary *challengeResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			
			if (error != nil) {
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
				
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = NSLocalizedString(@"Submission Failed!", @"Status message when submit fails");
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:1.5];
				_progressHUD = nil;
			
			} else {
				NSLog(@"HONChallengerPickerViewController AFNetworking: %@", challengeResult);
				
				if (![[challengeResult objectForKey:@"result"] isEqualToString:@"fail"]) {
					[_progressHUD hide:YES];
					_progressHUD = nil;
					
					HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:challengeResult];
					[HONFacebookCaller postToTimeline:vo];
					
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:nil];
					
					if (vo.statusID == 7)
						[HONFacebookCaller sendAppRequestToUser:_fbID];
					
					
					if (vo.statusID == 4) {
						_progressHUD.minShowTime = kHUDTime;
						_progressHUD.mode = MBProgressHUDModeCustomView;
						_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkIcon"]];
						_progressHUD.labelText = @"Challenge Matched!";
						[_progressHUD show:NO];
						[_progressHUD hide:YES afterDelay:1.5];
						_progressHUD = nil;
					}
					
					if ([_fbID length] > 0) {
						if ([[[HONAppDelegate facebookFriendPosting] objectForKey:@"invite"] isEqualToString:@"Y"])
							[HONFacebookCaller sendAppRequestToUser:_fbID challenge:vo];
						
						if ([[[HONAppDelegate facebookFriendPosting] objectForKey:@"friend_wall"] isEqualToString:@"Y"])
							[HONFacebookCaller postToFriendTimeline:_fbID challenge:vo];
					}
					
					[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
						if ([[[[[NSUserDefaults standardUserDefaults] objectForKey:@"web_ctas"] objectAtIndex:1] objectForKey:@"enabled"] isEqualToString:@"Y"])
							[[NSNotificationCenter defaultCenter] postNotificationName:@"WEB_CTA" object:[[[NSUserDefaults standardUserDefaults] objectForKey:@"web_ctas"] objectAtIndex:1]];
					}];
				
				} else {
					_progressHUD.minShowTime = kHUDTime;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
					_progressHUD.labelText = @"Username Not Found!";
					[_progressHUD show:NO];
					[_progressHUD hide:YES afterDelay:1.5];
					_progressHUD = nil;
					
					_usernameTextField.text = @"ENTER A USERNAME HERE";
				}
			}
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"ChallengerPickerViewController AFNetworking %@", [error localizedDescription]);
			
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"Submission Failed!", @"Status message when submit fails");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
		}];
		
	} @catch (AmazonClientException *exception) {
		if (_progressHUD != nil) {
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
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
	
	//NSData *imageData = UIImageJPEGRepresentation(_image, kJPEGCompress);
	
	if ([_subjectName length] == 0)
		_subjectName = [HONAppDelegate rndDefaultSubject];
	
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	
	_filename = [NSString stringWithFormat:@"%@_%@", [HONAppDelegate deviceToken], [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]] stringValue]];
	NSLog(@"https://hotornot-challenges.s3.amazonaws.com/%@", _filename);
	
	@try {
		float ratio = _challengeImage.size.height / _challengeImage.size.width;
		
		UIImage *lImage = [HONAppDelegate scaleImage:_challengeImage toSize:CGSizeMake(kLargeW, kLargeW * ratio)];
		lImage = [HONAppDelegate cropImage:lImage toRect:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
		
		UIImage *mImage = [HONAppDelegate scaleImage:_challengeImage toSize:CGSizeMake(kMediumW * 2.0, kMediumH * 2.0)];
		UIImage *t1Image = [HONAppDelegate scaleImage:_challengeImage toSize:CGSizeMake(kThumb1W * 2.0, kThumb1H * 2.0)];
		
//		UIImageView *sqCanvasView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLargeW, kLargeW)];
//		sqCanvasView.backgroundColor = [UIColor blackColor];
//		sqCanvasView.image = [HONAppDelegate cropImage:[HONAppDelegate scaleImage:_challengeImage toSize:CGSizeMake(kLargeW, kLargeH)] toRect:CGRectMake(0.0, (((kLargeH - kLargeW) * 0.5) * 0.5), kLargeW, kLargeW)];
//		size = [sqCanvasView bounds].size;
//		UIGraphicsBeginImageContext(size);
//		[[sqCanvasView layer] renderInContext:UIGraphicsGetCurrentContext()];
//		lImage = UIGraphicsGetImageFromCurrentImageContext();
//		UIGraphicsEndImageContext();
		
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.labelText = @"Submitting Challenge…";
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.taskInProgress = YES;
		
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-challenges"]];
		S3PutObjectRequest *por1 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_t.jpg", _filename] inBucket:@"hotornot-challenges"];
		por1.contentType = @"image/jpeg";
		por1.data = UIImageJPEGRepresentation(t1Image, kJPEGCompress);
		[s3 putObject:por1];
				
		S3PutObjectRequest *por3 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_m.jpg", _filename] inBucket:@"hotornot-challenges"];
		por3.contentType = @"image/jpeg";
		por3.data = UIImageJPEGRepresentation(mImage, kJPEGCompress);
		[s3 putObject:por3];
		
		S3PutObjectRequest *por4 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_l.jpg", _filename] inBucket:@"hotornot-challenges"];
		por4.contentType = @"image/jpeg";
		por4.data = UIImageJPEGRepresentation(lImage, kJPEGCompress);
		[s3 putObject:por4];
		
		AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
		NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSString stringWithFormat:@"%d", 1], @"action",
										[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
										[NSString stringWithFormat:@"https://hotornot-challenges.s3.amazonaws.com/%@", _filename], @"imgURL",
										_subjectName, @"subject",
										nil];
		
		[httpClient postPath:kChallengesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSError *error = nil;
			NSDictionary *challengeResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			
			if (error != nil) {
				NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
				
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = NSLocalizedString(@"Submission Failed!", @"Status message when submit fails");
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:1.5];
				_progressHUD = nil;
			
			} else {
				NSLog(@"HONChallengerPickerViewController AFNetworking: %@", challengeResult);
				
				if (![[challengeResult objectForKey:@"result"] isEqualToString:@"fail"]) {
					[_progressHUD hide:YES];
					_progressHUD = nil;
					
					HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:challengeResult];
					[HONFacebookCaller postToTimeline:vo];
					
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:nil];
					
					if (vo.statusID == 7)
						[HONFacebookCaller sendAppRequestToUser:_fbID];
					
					
					if (vo.statusID == 4) {
						_progressHUD.minShowTime = kHUDTime;
						_progressHUD.mode = MBProgressHUDModeCustomView;
						_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkIcon"]];
						_progressHUD.labelText = @"Challenge Matched!";
						[_progressHUD show:NO];
						[_progressHUD hide:YES afterDelay:1.5];
						_progressHUD = nil;
					}
					
					if ([_fbID length] > 0) {
						if ([[[HONAppDelegate facebookFriendPosting] objectForKey:@"invite"] isEqualToString:@"Y"])
							[HONFacebookCaller sendAppRequestToUser:_fbID challenge:vo];
						
						if ([[[HONAppDelegate facebookFriendPosting] objectForKey:@"friend_wall"] isEqualToString:@"Y"])
							[HONFacebookCaller postToFriendTimeline:_fbID challenge:vo];
					}
					
					[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
						if ([[[[[NSUserDefaults standardUserDefaults] objectForKey:@"web_ctas"] objectAtIndex:1] objectForKey:@"enabled"] isEqualToString:@"Y"])
							[[NSNotificationCenter defaultCenter] postNotificationName:@"WEB_CTA" object:[[[NSUserDefaults standardUserDefaults] objectForKey:@"web_ctas"] objectAtIndex:1]];
					}];
				}
			}
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"ChallengerPickerViewController AFNetworking %@", [error localizedDescription]);
			
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"Submission Failed!", @"Status message when submit fails");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
		}];
				
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
	
	self.friendPickerHeaderView = [[HONHeaderView alloc] initWithTitle:[@"Select Friend" uppercaseString]];
	self.friendPickerHeaderView.autoresizingMask = self.friendPickerHeaderView.autoresizingMask | UIViewAutoresizingFlexibleWidth;
	
	// Cancel Button
	UIButton *customCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[customCancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
	[customCancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
	[customCancelButton addTarget:self action:@selector(facebookViewControllerCancelWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	customCancelButton.frame = CGRectMake(5.0, 5.0, 64.0, 34.0);
	[self.friendPickerHeaderView addSubview:customCancelButton];
	
	// Done Button
	UIButton *customDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[customDoneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[customDoneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[customDoneButton addTarget:self action:@selector(facebookViewControllerDoneWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	customDoneButton.frame = CGRectMake(self.view.bounds.size.width - 69.0, 5.0, 64.0, 34.0);
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
		_fbName = [[self.friendPickerController.selection lastObject] objectForKey:@"username"];
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
	
	[_loginFriendsButton removeTarget:self action:@selector(_goChallengeFriends) forControlEvents:UIControlEventTouchUpInside];
	[_loginFriendsButton removeTarget:self action:@selector(_goLogin) forControlEvents:UIControlEventTouchUpInside];
	[_loginFriendsButton addTarget:self action:(FBSession.activeSession.state == 513) ? @selector(_goChallengeFriends) : @selector(_goLogin) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	
	if (textField.tag == 0) {
		[[Mixpanel sharedInstance] track:@"Preview Challenge - Edit Hashtag"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		_editButton.hidden = YES;
		//textField.text = @"#";
	
	} else if (textField.tag == 1) {
		[[Mixpanel sharedInstance] track:@"Preview Challenge - Edit Usernme"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		[_randomButton removeTarget:self action:@selector(_goRandomChallenge) forControlEvents:UIControlEventTouchUpInside];
		[_loginFriendsButton removeTarget:self action:(FBSession.activeSession.state == 513) ? @selector(_goChallengeFriends) : @selector(_goLogin) forControlEvents:UIControlEventTouchUpInside];
		
		textField.text = @"";
		_usernameTextField.frame = CGRectMake(1.0, _usernameTextField.frame.origin.y, _usernameTextField.frame.size.width, _usernameTextField.frame.size.height);
		
		_bgTextImageView.hidden = NO;
		int offset = ([HONAppDelegate isRetina5]) ? 94.0 : 182.0;
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^(void) {
			_bgTextImageView.frame = CGRectMake(_bgTextImageView.frame.origin.x, _bgTextImageView.frame.origin.y - 235.0, _bgTextImageView.frame.size.width, _bgTextImageView.frame.size.height);
			_usernameTextField.frame = CGRectMake(_usernameTextField.frame.origin.x, _usernameTextField.frame.origin.y - offset, _usernameTextField.frame.size.width, _usernameTextField.frame.size.height);
		} completion:nil];
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
		
		if ([textField.text length] == 0 || [textField.text isEqualToString:@"#"])
			textField.text = _subjectName;
		
		else {
			NSArray *hashTags = [textField.text componentsSeparatedByString:@"#"];
			
			if ([hashTags count] > 2) {
				NSString *hashTag = ([[hashTags objectAtIndex:1] hasSuffix:@" "]) ? [[hashTags objectAtIndex:1] substringToIndex:[[hashTags objectAtIndex:1] length] - 1] : [hashTags objectAtIndex:1];
				textField.text = [NSString stringWithFormat:@"#%@", hashTag];
			}
			
			_subjectName = textField.text;
		}
	
	} else if (textField.tag == 1) {
		_usernameTextField.frame = CGRectMake(16.0, _usernameTextField.frame.origin.y, _usernameTextField.frame.size.width, _usernameTextField.frame.size.height);
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^(void){
			_bgTextImageView.frame = CGRectMake(_bgTextImageView.frame.origin.x, [UIScreen mainScreen].bounds.size.height - 55.0, _bgTextImageView.frame.size.width, _bgTextImageView.frame.size.height);
			_usernameTextField.frame = CGRectMake(_usernameTextField.frame.origin.x, 14.0, _usernameTextField.frame.size.width, _usernameTextField.frame.size.height);
			
		} completion:^(BOOL finished) {
			_bgTextImageView.hidden = YES;
			
			[_randomButton addTarget:self action:@selector(_goRandomChallenge) forControlEvents:UIControlEventTouchUpInside];
			[_loginFriendsButton addTarget:self action:(FBSession.activeSession.state == 513) ? @selector(_goChallengeFriends) : @selector(_goLogin) forControlEvents:UIControlEventTouchUpInside];
		}];
		
		if ([textField.text length] == 0)
			textField.text = @"ENTER A USERNAME HERE";
		
		else {
			_fbName = textField.text;
			[self _goUsernameSubmit];
		}
	}
}

#pragma mark - AdView Delegates
- (UIViewController *)rootViewController {
	return (self);
}

@end
