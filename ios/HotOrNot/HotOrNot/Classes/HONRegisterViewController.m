//
//  HONRegisterViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.02.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <AWSiOSSDK/S3/AmazonS3Client.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "UIImage+fixOrientation.h"
#import "UIImageView+AFNetworking.h"

#import "HONRegisterViewController.h"
#import "HONHeaderView.h"
#import "HONRegisterCameraViewController.h"
#import "HONImagingDepictor.h"


@interface HONRegisterViewController () <AmazonServiceRequestDelegate>
@property (nonatomic, strong) UIImagePickerController *previewPicker;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) UIView *plCameraIrisAnimationView;  // view that animates the opening/closing of the iris
@property (nonatomic, strong) UIImageView *cameraIrisImageView;  // static image of the closed iris
@property (nonatomic, strong) UIView *usernameHolderView;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, retain) UIButton *submitButton;
@property (nonatomic, retain) UIButton *usernameButton;
@property (nonatomic, retain) UIButton *emailButton;
@property (nonatomic, retain) UIButton *birthdayButton;
@property (nonatomic, strong) UIView *tutorialHolderView;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UILabel *birthdayLabel;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSTimer *clockTimer;
@property (nonatomic, strong) UIView *cameraOverlayView;
@property (nonatomic, strong) UIImageView *overlayImageView;
@property (nonatomic, strong) UIView *splashTintView;
@property (nonatomic, strong) UIImageView *tutorialBubbleImageView;

@property (nonatomic) int selfieAttempts;
@property (nonatomic) int uploadCounter;
@property (nonatomic) BOOL isFirstAppearance;
@end

@implementation HONRegisterViewController

- (id)init {
	if ((self = [super init])) {
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didShowViewController:) name:@"UINavigationControllerDidShowViewControllerNotification" object:nil];
		_username = [[HONAppDelegate infoForUser] objectForKey:@"name"];
		
		[[Mixpanel sharedInstance] track:@"Register - Show"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		_isFirstAppearance = YES;
		_selfieAttempts = 0;
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
- (void)_uploadPhoto:(UIImage *)image {
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	
	_uploadCounter = 0;
	_filename = [NSString stringWithFormat:@"%@-%d",[HONAppDelegate deviceToken], (int)[[NSDate date] timeIntervalSince1970]];
	NSLog(@"FILENAME: %@/%@", [HONAppDelegate s3BucketForType:@"avatars"], _filename);
	
	@try {
//		float avatarSize = kSnapLargeDim;
//		CGSize ratio = CGSizeMake(image.size.width / image.size.height, image.size.height / image.size.width);
		
		UIImage *oImage = image;
		UIImage *largeImage = [HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:image toSize:CGSizeMake(852.0, 1136.0)] toRect:CGRectMake(106.0, 0.0, 640.0, 1136.0)];
		
//		UIImage *lImage = [HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:image toSize:CGSizeMake(640.0, 854.0)] toRect:CGRectMake(0.0, 202.0, 640.0, 450.0)];
//		UIImage *tImage = (ratio.height >= 1.0) ? [HONImagingDepictor scaleImage:image toSize:CGSizeMake(avatarSize, avatarSize * ratio.height)] : [HONImagingDepictor scaleImage:image toSize:CGSizeMake(avatarSize * ratio.width, avatarSize)];
//		tImage = [HONImagingDepictor cropImage:tImage toRect:CGRectMake(0.0, 0.0, avatarSize, avatarSize)];
		
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-avatars"]];
		
		S3PutObjectRequest *por1 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@Large_640x1136.jpg", _filename] inBucket:@"hotornot-avatars"];
		por1.contentType = @"image/jpeg";
		por1.data = UIImageJPEGRepresentation(largeImage, kSnapJPEGCompress);
		por1.delegate = self;
		[s3 putObject:por1];
		
		S3PutObjectRequest *por2 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@_o.jpg", _filename] inBucket:@"hotornot-avatars"];
		por2.contentType = @"image/jpeg";
		por2.data = UIImageJPEGRepresentation(oImage, kSnapJPEGCompress);
		por2.delegate = self;
		[s3 putObject:por2];
		
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

- (void)_finalizeUser {
	if ([[_username substringToIndex:1] isEqualToString:@"@"])
		_username = [_username substringFromIndex:1];
	
	_filename = ([[[HONAppDelegate infoForUser] objectForKey:@"token"] isEqualToString:@"0000000000000000000000000000000000000000000000000000000000000000"]) ? @"https://graph.facebook.com/1149169958/picture?type=square" : [NSString stringWithFormat:@"%@/%@Large_640x1136.jpg", [HONAppDelegate s3BucketForType:@"avatars"], _filename];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 9], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							_username, @"username",
							_email, @"password",
							_birthday, @"age",
							_filename, @"imgURL",
							nil];
	
	NSLog(@"PARAMS:[%@]", params);
	NSMutableString *avatarURL = [_filename mutableCopy];
	[avatarURL replaceOccurrencesOfString:@"Large_640x1136" withString:@"_o" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [avatarURL length])];
//	[avatarURL replaceOccurrencesOfString:@".png" withString:@"_o.png" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [avatarURL length])];
	[HONImagingDepictor writeImageFromWeb:avatarURL withDimensions:CGSizeMake(612.0, 816.0) withUserDefaultsKey:@"avatar_image"];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsersFirstRunComplete);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsersFirstRunComplete parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_updateFail", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			if (![[userResult objectForKey:@"result"] isEqualToString:@"fail"]) {
				if (_progressHUD != nil) {
					[_progressHUD hide:YES];
					_progressHUD = nil;
				}
				
				[HONAppDelegate writeUserInfo:userResult];
				[TestFlight passCheckpoint:@"PASSED REGISTRATION"];
				
				[[Mixpanel sharedInstance] track:@"Register - Pass Fist Run"
									  properties:[NSDictionary dictionaryWithObjectsAndKeys:
												  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"passed_registration"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
					NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
					[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
					
					if ([HONAppDelegate ageForDate:[dateFormat dateFromString:[[HONAppDelegate infoForUser] objectForKey:@"age"]]] < 19)
						[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:nil];
						[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_INVITE" object:nil];
				}];
				
			} else {
				if (_progressHUD == nil)
					_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = NSLocalizedString(@"hud_usernameTaken", nil);
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:1.5];
				_progressHUD = nil;
				
				[_usernameTextField becomeFirstResponder];
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@ ) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
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


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_headerView = [[HONHeaderView alloc] initAsModalWithTitle:@""];
	_headerView.frame = CGRectOffset(_headerView.frame, 0.0, -13.0);
	_headerView.backgroundColor = [UIColor blackColor];
	[_headerView hideRefreshing];
	[self.view addSubview:_headerView];
	
	UILabel *headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 41.0, 200.0, 24.0)];
	headerTitleLabel.backgroundColor = [UIColor clearColor];
	headerTitleLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18];
	headerTitleLabel.textColor = [UIColor whiteColor];
	headerTitleLabel.textAlignment = NSTextAlignmentCenter;
	headerTitleLabel.text = @"Register for Volley";
	[_headerView addSubview:headerTitleLabel];
	
	_usernameHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, -[UIScreen mainScreen].bounds.size.height, 320.0, [UIScreen mainScreen].bounds.size.height)];
	[self.view addSubview:_usernameHolderView];
	
	_usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_usernameButton.frame = CGRectMake(0.0, 64.0, 320.0, 64.0);
	[_usernameButton setBackgroundImage:[UIImage imageNamed:@"registerSelected"] forState:UIControlStateSelected];
	[_usernameButton addTarget:self action:@selector(_goUsername) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_usernameButton];
	
	_usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 82.0, 308.0, 30.0)];
	_usernameLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18];
	_usernameLabel.textColor = [HONAppDelegate honGrey710Color];
	_usernameLabel.backgroundColor = [UIColor clearColor];
	_usernameLabel.text = @"Enter username";
	[self.view addSubview:_usernameLabel];
	
	_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 82.0, 308.0, 30.0)];
	//[_usernameTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_usernameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_usernameTextField setReturnKeyType:UIReturnKeyDone];
	[_usernameTextField setTextColor:[UIColor blackColor]];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_usernameTextField.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18];
	_usernameTextField.keyboardType = UIKeyboardTypeAlphabet;
	_usernameTextField.text = @"";
	[_usernameTextField setTag:0];
	_usernameTextField.delegate = self;
	[self.view addSubview:_usernameTextField];
	
	UIImageView *divider1ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstRunDivider"]];
	divider1ImageView.frame = CGRectOffset(divider1ImageView.frame, 0.0, 128.0);
	[self.view addSubview:divider1ImageView];
	
	_emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_emailButton.frame = CGRectMake(0.0, 129.0, 320.0, 64.0);
	[_emailButton setBackgroundImage:[UIImage imageNamed:@"registerSelected"] forState:UIControlStateSelected];
	[_emailButton addTarget:self action:@selector(_goEmail) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_emailButton];
	
	_emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 147.0, 230.0, 30.0)];
	//[_usernameTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_emailTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_emailTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_emailTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_emailTextField setReturnKeyType:UIReturnKeyDone];
	[_emailTextField setTextColor:[UIColor blackColor]];
	[_emailTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_emailTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_emailTextField.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18];
	_emailTextField.keyboardType = UIKeyboardTypeAlphabet;
	_emailTextField.placeholder = @"Enter email";
	_emailTextField.text = @"";
	[_emailTextField setTag:1];
	_emailTextField.delegate = self;
	[self.view addSubview:_emailTextField];
	
	UIImageView *divider2ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstRunDivider"]];
	divider2ImageView.frame = CGRectOffset(divider2ImageView.frame, 0.0, 193.0);
	[self.view addSubview:divider2ImageView];
	
	_birthdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 212.0, 296.0, 30.0)];
	_birthdayLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18];
	_birthdayLabel.textColor = [HONAppDelegate honGrey710Color];
	_birthdayLabel.backgroundColor = [UIColor clearColor];
	_birthdayLabel.text = @"What is your birthday?";
	[self.view addSubview:_birthdayLabel];
	
	_birthdayButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_birthdayButton.frame = CGRectMake(0.0, 194.0, 320.0, 64.0);
	[_birthdayButton setBackgroundImage:[UIImage imageNamed:@"registerSelected"] forState:UIControlStateSelected];
	[_birthdayButton addTarget:self action:@selector(_goPicker) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_birthdayButton];
	
	UIImageView *divider3ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstRunDivider"]];
	divider3ImageView.frame = CGRectOffset(divider3ImageView.frame, 0.0, 258.0);
	[self.view addSubview:divider3ImageView];
	
	_submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 53.0, 320.0, 53.0);
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitUsernameButton_nonActive"] forState:UIControlStateNormal];
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitUsernameButton_Active"] forState:UIControlStateHighlighted];
	[_submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	_submitButton.hidden = YES;
	[self.view addSubview:_submitButton];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	
	NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
	[dateFormat2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	_datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height, 320.0, 216.0)];
	_datePicker.date = ([[[HONAppDelegate infoForUser] objectForKey:@"age"] isEqualToString:@"0000-00-00 00:00:00"]) ? [dateFormat dateFromString:@"1970-01-01"] : [dateFormat2 dateFromString:[[HONAppDelegate infoForUser] objectForKey:@"age"]];//[dateFormat2 dateFromString:[[HONAppDelegate infoForUser] objectForKey:@"age"]];
	_datePicker.datePickerMode = UIDatePickerModeDate;
	_datePicker.minimumDate = [dateFormat dateFromString:@"1970-01-01"];
	_datePicker.maximumDate = [NSDate date];
	[_datePicker addTarget:self action:@selector(_pickerValueChanged) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:_datePicker];
	_birthday = [dateFormat2 stringFromDate:_datePicker.date];//[[HONAppDelegate infoForUser] objectForKey:@"age"];
	
	_tutorialHolderView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_tutorialHolderView.backgroundColor = [UIColor blackColor];
	_tutorialHolderView.alpha = 0.0;
	[self.view addSubview:_tutorialHolderView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (_isFirstAppearance) {
		_isFirstAppearance = NO;
		
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
			imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
			imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
			imagePickerController.delegate = self;
		
			imagePickerController.showsCameraControls = NO;
			imagePickerController.cameraViewTransform = CGAffineTransformScale(imagePickerController.cameraViewTransform, ([HONAppDelegate isRetina5]) ? 1.65f : 1.25f, ([HONAppDelegate isRetina5]) ? 1.65f : 1.25f);
			imagePickerController.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
			
			_cameraOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height * 2.0)];
			_cameraOverlayView.alpha = 0.0;
			
			_splashTintView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
			_splashTintView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
			[_cameraOverlayView addSubview:_splashTintView];
			
			_overlayImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
			_overlayImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"whySelfie-568h@2x" : @"whySelfie"];
			_overlayImageView.userInteractionEnabled = YES;
			[_cameraOverlayView addSubview:_overlayImageView];
			
			UIButton *signupButton = [UIButton buttonWithType:UIButtonTypeCustom];
			signupButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 156.0, 320.0, 49.0);
			[signupButton setBackgroundImage:[UIImage imageNamed:@"registerButton_nonActive"] forState:UIControlStateNormal];
			[signupButton setBackgroundImage:[UIImage imageNamed:@"registerButton_Active"] forState:UIControlStateHighlighted];
			[signupButton addTarget:self action:@selector(_goProfileCamera) forControlEvents:UIControlEventTouchUpInside];
			[_overlayImageView addSubview:signupButton];
			
			imagePickerController.cameraOverlayView = _cameraOverlayView;
			
			[UIView animateWithDuration:0.33 animations:^(void) {
				_cameraOverlayView.alpha = 1.0;
			}];
		
			self.previewPicker = imagePickerController;
			[self presentViewController:self.previewPicker animated:NO completion:nil];
		
		} else {
			_overlayImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
			_overlayImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"whySelfie-568h@2x" : @"whySelfie"];
			_overlayImageView.userInteractionEnabled = YES;
			_overlayImageView.alpha = 0.0;
			[_tutorialHolderView addSubview:_overlayImageView];
			
			UIButton *closeSplashButton = [UIButton buttonWithType:UIButtonTypeCustom];
			closeSplashButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 156.0, 320.0, 49.0);
			[closeSplashButton setBackgroundImage:[UIImage imageNamed:@"registerButton_nonActive"] forState:UIControlStateNormal];
			[closeSplashButton setBackgroundImage:[UIImage imageNamed:@"registerButton_Active"] forState:UIControlStateHighlighted];
			[closeSplashButton addTarget:self action:@selector(_goCloseSplash) forControlEvents:UIControlEventTouchUpInside];
			[_tutorialHolderView addSubview:closeSplashButton];
			
			[UIView animateWithDuration:0.33 animations:^(void) {
				_overlayImageView.alpha = 1.0;
				_tutorialHolderView.alpha = 1.0;
			}];
		}
	}
}


#pragma mark - Navigation
- (void)_goProfileCamera {
	[UIView animateWithDuration:0.5 animations:^(void) {
		_overlayImageView.frame = CGRectOffset(_overlayImageView.frame, 0.0, -self.view.frame.size.height);
		_overlayImageView.alpha = 0.0;
		_splashTintView.alpha = 0.0;
	} completion:^(BOOL finished) {
		_tutorialBubbleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlayStep2"]];
		_tutorialBubbleImageView.frame = CGRectOffset(_tutorialBubbleImageView.frame, 18.0, [UIScreen mainScreen].bounds.size.height - 250.0);
		_tutorialBubbleImageView.alpha = 0.0;
		[_cameraOverlayView addSubview:_tutorialBubbleImageView];
		
		UIButton *takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
		takePhotoButton.frame = CGRectMake(118.0, [UIScreen mainScreen].bounds.size.height - 133.0, 84.0, 84.0);
		[takePhotoButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_nonActive"] forState:UIControlStateNormal];
		[takePhotoButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_Active"] forState:UIControlStateHighlighted];
		[takePhotoButton addTarget:self action:@selector(_goTakePhoto:) forControlEvents:UIControlEventTouchUpInside];
		takePhotoButton.alpha = 0.0;
		[_cameraOverlayView addSubview:takePhotoButton];
		
		UIButton *closeTutorialButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeTutorialButton.frame = _cameraOverlayView.frame;
		[closeTutorialButton addTarget:self action:@selector(_goCloseTutorial:) forControlEvents:UIControlEventTouchUpInside];
		[_cameraOverlayView addSubview:closeTutorialButton];
		
		UIImageView *headerBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraBackgroundHeader"]];
		headerBGImageView.frame = CGRectOffset(headerBGImageView.frame, 0.0, -20.0);
		[_cameraOverlayView addSubview:headerBGImageView];
		
		UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		skipButton.frame = CGRectMake(253.0, 0.0, 64.0, 44.0);
		[skipButton setBackgroundImage:[UIImage imageNamed:@"skipButton_nonActive"] forState:UIControlStateNormal];
		[skipButton setBackgroundImage:[UIImage imageNamed:@"skipButton_Active"] forState:UIControlStateHighlighted];
		[skipButton addTarget:self action:@selector(_goSkip) forControlEvents:UIControlEventTouchUpInside];
		[_cameraOverlayView addSubview:skipButton];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			takePhotoButton.alpha = 1.0;
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.33 animations:^(void) {
				_tutorialBubbleImageView.alpha = 1.0;
				_tutorialBubbleImageView.frame = CGRectOffset(_tutorialBubbleImageView.frame, 0.0, -35.0);
			}];
		}];
	}];
}

- (void)_goCloseTutorial:(id)sender {
	UIButton *button = (UIButton *)sender;
	[button removeTarget:self action:@selector(_goCloseTutorial:) forControlEvents:UIControlEventTouchUpInside];
	[button removeFromSuperview];
	button = nil;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_tutorialBubbleImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[_tutorialBubbleImageView removeFromSuperview];
		_tutorialBubbleImageView = nil;
	}];
}

- (void)_goSkip {
	[[[UIAlertView alloc] initWithTitle:@""
								message:@"Sorry! at this time we require all members of Volley to have a selfie. It keeps things safe."
							   delegate:nil
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}

- (void)_goTakePhoto:(id)sender {
//	UIButton *button = (UIButton *)sender;
//	[button removeTarget:self action:@selector(_goTakePhoto:) forControlEvents:UIControlEventTouchUpInside];
//	button.alpha = 0.5;
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Verifying Selfie…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_tutorialBubbleImageView.alpha = 0.0;
		_cameraOverlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[_tutorialBubbleImageView removeFromSuperview];
		_tutorialBubbleImageView = nil;
	}];
	
	[self.previewPicker takePicture];
}

- (void)_goCloseSplash {
	[[Mixpanel sharedInstance] track:@"Register - Close Splash"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self.previewPicker dismissViewControllerAnimated:NO completion:^(void) {}];
	
	[_usernameTextField becomeFirstResponder];
	[_usernameButton setSelected:YES];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelay:0.33];
	_tutorialHolderView.frame = CGRectOffset(_tutorialHolderView.frame, 0.0, [UIScreen mainScreen].bounds.size.height);
	[UIView commitAnimations];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelay:0.33];
	_usernameHolderView.frame = CGRectOffset(_usernameHolderView.frame, 0.0, [UIScreen mainScreen].bounds.size.height);
	[UIView commitAnimations];
}

- (void)_goUsername {
	[_usernameTextField becomeFirstResponder];
}

- (void)_goEmail {
	[_emailTextField becomeFirstResponder];
}

- (void)_goPicker {
	[_usernameButton setSelected:NO];
	[_emailButton setSelected:NO];
	[_birthdayButton setSelected:YES];
	[_usernameTextField resignFirstResponder];
	[_emailTextField resignFirstResponder];
	
	_submitButton.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_submitButton.frame = CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 216.0) - _submitButton.frame.size.height, _submitButton.frame.size.width, _submitButton.frame.size.height);
		_datePicker.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 216.0, 320.0, 216.0);
	} completion:^(BOOL finished) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterLongStyle];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		_birthdayLabel.text = [dateFormatter stringFromDate:_datePicker.date];
	}];
}

- (void)_goSubmit {
	if ([_usernameTextField.text isEqualToString:@""] || [_usernameTextField.text isEqualToString:@"@"]) {
		[[[UIAlertView alloc] initWithTitle:@"No Username!"
									message:@"You need to enter a username to start snapping"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		[_usernameTextField becomeFirstResponder];
	
	} else {
		if ([[NSDate date] timeIntervalSinceDate:_datePicker.date] > ((60 * 60 * 24) * 365) * 20) {
			[[[UIAlertView alloc] initWithTitle:@""
										message:@"Volley is intended for young adults 14 to 19. You may get flagged by the community."
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
			
			[self _finalizeUser];
		
		} else {
			if ([_emailTextField.text length] == 0) {
				[[[UIAlertView alloc] initWithTitle:@"No email!"
											message:@"You need to enter an email address to use Volley"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
				[_emailTextField becomeFirstResponder];
			
			} else
				[self _finalizeUser];
		}
	}
}

#pragma mark - UI Presentation
- (void)_presentCamera {
	[self.navigationController pushViewController:[[HONRegisterCameraViewController alloc] initWithPassword:_email andBirthday:_birthday] animated:NO];
}

- (void)_pickerValueChanged {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	_birthdayLabel.text = [dateFormatter stringFromDate:_datePicker.date];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	_birthday = [dateFormat stringFromDate:_datePicker.date];
	
	
	//NSLog(@"DIFF:[%f]", [[NSDate date] timeIntervalSinceDate:_datePicker.date]);
}


#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	NSLog(@"imagePickerController:didFinishPickingMediaWithInfo");
	
	UIImage *image = [[info objectForKey:UIImagePickerControllerOriginalImage] fixOrientation];
	
//	UIImageView *previewImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
//	previewImageView.image = image;
//	[_cameraOverlayView addSubview:previewImageView];
	
	CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
	CIDetector *detctor = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
	NSArray *features = [detctor featuresInImage:ciImage];
	
	[_progressHUD hide:YES];
	_progressHUD = nil;
	
	if ([features count] > 0) {
		[self _uploadPhoto:image];
		[self dismissViewControllerAnimated:YES completion:^(void) {}];
		
		_tutorialHolderView.frame = CGRectOffset(_tutorialHolderView.frame, 0.0, [UIScreen mainScreen].bounds.size.height);
		
		[_usernameTextField becomeFirstResponder];
		[_usernameButton setSelected:YES];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationDelay:0.33];
		_usernameHolderView.frame = CGRectOffset(_usernameHolderView.frame, 0.0, [UIScreen mainScreen].bounds.size.height);
		[UIView commitAnimations];
	
	} else {
		_selfieAttempts++;
		
		if (_selfieAttempts < 2) {
			[[[UIAlertView alloc] initWithTitle:@"No selfie detected!"
										message:@"Please retake your photo"
									   delegate:self
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
		
//			[previewImageView removeFromSuperview];
//			previewImageView = nil;
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"No selfie detected!"
										message:@"You may get flagged by the community."
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
			
			[self _uploadPhoto:image];
			[self dismissViewControllerAnimated:YES completion:^(void) {}];
			
			_tutorialHolderView.frame = CGRectOffset(_tutorialHolderView.frame, 0.0, [UIScreen mainScreen].bounds.size.height);
			
			[_usernameTextField becomeFirstResponder];
			[_usernameButton setSelected:YES];
			
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.5];
			[UIView setAnimationDelay:0.33];
			_usernameHolderView.frame = CGRectOffset(_usernameHolderView.frame, 0.0, [UIScreen mainScreen].bounds.size.height);
			[UIView commitAnimations];
		}
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	NSLog(@"imagePickerControllerDidCancel");
	
	[self dismissViewControllerAnimated:YES completion:^(void) {
		[TestFlight passCheckpoint:@"PASSED REGISTRATION"];
		
		[[Mixpanel sharedInstance] track:@"Register - Pass Fist Run"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"passed_registration"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
			NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
			[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
			
			if ([HONAppDelegate ageForDate:[dateFormat dateFromString:_birthday]] < 19)
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_INVITE" object:nil];
		}];
	}];
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	if (textField.tag == 0) {
		[_usernameButton setSelected:YES];
		[_emailButton setSelected:NO];
		[_birthdayButton setSelected:NO];
	
	} else {
		[_usernameButton setSelected:NO];
		[_emailButton setSelected:YES];
		[_birthdayButton setSelected:NO];
	}
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_datePicker.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height, 320.0, 216.0);
		_submitButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - _submitButton.frame.size.height, _submitButton.frame.size.width, _submitButton.frame.size.height);
	} completion:^(BOOL finished) {
		_submitButton.hidden = YES;
	}];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (textField.tag == 0) {
		if ([textField.text isEqualToString:@""])
			textField.text = @"@";
		
		_usernameLabel.hidden = (textField.tag == 0);
	}
	
	return (YES);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	_usernameLabel.hidden = ([_usernameTextField.text length] > 0);
	
	_submitButton.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_submitButton.frame = CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 216.0) - _submitButton.frame.size.height, _submitButton.frame.size.width, _submitButton.frame.size.height);
		_datePicker.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 216.0, 320.0, 216.0);
	} completion:^(BOOL finished) {
	}];
}

- (void)_onTextEditingDidEnd:(id)sender {
	_username = ([_usernameTextField.text length] > 0 && [[_usernameTextField.text substringToIndex:1] isEqualToString:@"@"]) ? [_usernameTextField.text substringFromIndex:1] : _usernameTextField.text;
	_email = _emailTextField.text;
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
}


#pragma mark - AlertView Deleagtes
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	_cameraOverlayView.alpha = 1.0;
}

#pragma mark - AWS Delegates
- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
	//NSLog(@"\nAWS didCompleteWithResponse:\n%@", response);
	
	_uploadCounter++;
	if (_uploadCounter == 2) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"AWS didFailWithError:\n%@", error);
}
@end
