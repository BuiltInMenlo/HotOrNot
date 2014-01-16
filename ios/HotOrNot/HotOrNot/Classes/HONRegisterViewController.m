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
#import "ImageFilter.h"
#import "MBProgressHUD.h"
#import "UIImage+fixOrientation.h"
#import "UIImageView+AFNetworking.h"

#import "HONRegisterViewController.h"
#import "HONHeaderView.h"
#import "HONAPICaller.h"
#import "HONImagingDepictor.h"


#define SPLASH_BLUE_TINT_COLOR		[UIColor colorWithRed:0.008 green:0.373 blue:0.914 alpha:0.667]
#define SPLASH_MAGENTA_TINT_COLOR	[UIColor colorWithRed:0.910 green:0.009 blue:0.520 alpha:0.667]
#define SPLASH_GREEN_TINT_COLOR		[UIColor colorWithRed:0.009 green:0.910 blue:0.178 alpha:0.667]
#define SPLASH_TINT_FADE_DURATION	2.50f
#define SPLASH_TINT_TIMER_DURATION	3.33f


@interface HONRegisterViewController ()
@property (nonatomic, strong) MFMailComposeViewController *mailComposeViewController;
@property (nonatomic, strong) UIImagePickerController *splashImagePickerController;
@property (nonatomic, strong) UIImagePickerController *profileImagePickerController;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIView *rotatingTintView;
@property (nonatomic, strong) NSTimer *tintTimer;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, retain) UIButton *usernameButton;
@property (nonatomic, retain) UIButton *emailButton;
@property (nonatomic, retain) UIButton *birthdayButton;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UILabel *birthdayLabel;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) UIView *profileCameraOverlayView;
@property (nonatomic, strong) UIView *irisView;
@property (nonatomic, strong) UIView *tintedMatteView;
@property (nonatomic, strong) UIButton *changeTintButton;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic, strong) UIView *splashHolderView;
@property (nonatomic, strong) NSString *splashImageURL;
@property (nonatomic) int tintIndex;

@property (nonatomic) int selfieAttempts;
@property (nonatomic) BOOL isFirstAppearance;
@end

@implementation HONRegisterViewController

- (id)init {
	if ((self = [super init])) {
		_username = [[HONAppDelegate infoForUser] objectForKey:@"username"];
		
		[[Mixpanel sharedInstance] track:@"Register - Show"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
		_filename = @"";
		_isFirstAppearance = YES;
		_selfieAttempts = 0;
		_tintIndex = 0;
		
		_splashImageURL = [[[NSUserDefaults standardUserDefaults] objectForKey:@"splash_image"] stringByAppendingString:[[NSString stringWithFormat:([HONAppDelegate isRetina4Inch]) ? @"_%@-568h" : @"_%@", [[HONAppDelegate brandedAppName] lowercaseString]] stringByAppendingString:@"@2x.png"]];
		NSLog(@"SPLASH TEXT:[%@]", _splashImageURL);
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
- (void)_checkUsername {
	[[HONAPICaller sharedInstance] checkForAvailableUsername:_username andEmail:_email completion:^(NSObject *result){
		if ([[(NSDictionary *)result objectForKey:@"result"] intValue] == 0) {
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			if ([HONAppDelegate switchEnabledForKey:@"firstrun_camera"])
				[self _goCamera];
			
			else {
				[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"skipped_selfie"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
				[self _finalizeUser];
			}
			
		} else {
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			
			[_progressHUD setYOffset:-80.0];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = ([[(NSDictionary *)result objectForKey:@"result"] intValue] == 1) ? @"Username taken!" : ([[(NSDictionary *)result objectForKey:@"result"] intValue] == 2) ? @"Email taken!" : @"Username & email taken!";
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
			[_usernameTextField becomeFirstResponder];
		}
	}];
}

- (void)_uploadPhotos:(UIImage *)image {
	_filename = [NSString stringWithFormat:@"%@_%@-%d", [[HONAppDelegate identifierForVendorWithoutSeperators:YES] lowercaseString], [[HONAppDelegate advertisingIdentifierWithoutSeperators:YES] lowercaseString], (int)[[NSDate date] timeIntervalSince1970]];
	
	UIImage *largeImage = [HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:image toSize:CGSizeMake(852.0, kSnapLargeSize.height * 2.0)] toRect:CGRectMake(106.0, 0.0, kSnapLargeSize.width * 2.0, kSnapLargeSize.height * 2.0)];
	UIImage *tabImage = [HONImagingDepictor cropImage:largeImage toRect:CGRectMake(0.0, 0.0, kSnapTabSize.width * 2.0, kSnapTabSize.height * 2.0)];
	
	NSLog(@"FILE PREFIX: %@/%@", [HONAppDelegate s3BucketForType:@"avatars"], _filename);
	
	S3PutObjectRequest *por1 = [[S3PutObjectRequest alloc] initWithKey:[_filename stringByAppendingString:kSnapLargeSuffix] inBucket:@"hotornot-avatars"];
	por1.data = UIImageJPEGRepresentation(largeImage, [HONAppDelegate compressJPEGPercentage]);
	por1.contentType = @"image/jpeg";
	
	S3PutObjectRequest *por2 = [[S3PutObjectRequest alloc] initWithKey:[_filename stringByAppendingString:kSnapTabSuffix] inBucket:@"hotornot-avatars"];
	por2.data = UIImageJPEGRepresentation(tabImage, [HONAppDelegate compressJPEGPercentage] * 0.85);
	por2.contentType = @"image/jpeg";
	
	[self _finalizeUser];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UPLOAD_IMAGES_TO_AWS" object:@{@"url"	: [NSString stringWithFormat:@"%@/%@", [HONAppDelegate s3BucketForType:@"avatars"], [_filename stringByAppendingString:kSnapLargeSuffix]],
																								@"pors"	: @[por1, por2]}];
}

- (void)_finalizeUser {
	[[HONAPICaller sharedInstance] finalizeUserWithDictionary:@{@"user_id"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
																@"username"	: _username,
																@"email"	: _email,
																@"birthday"	: _birthday,
																@"filename"	: _filename} completion:^(NSObject *result){
		if (result != nil) {
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			[HONAppDelegate writeUserInfo:(NSDictionary *)result];
			[TestFlight passCheckpoint:@"PASSED REGISTRATION"];
			
			[[Mixpanel sharedInstance] track:@"Register - Pass Fist Run"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			
			Mixpanel *mixpanel = [Mixpanel sharedInstance];
			[mixpanel identify:[HONAppDelegate advertisingIdentifierWithoutSeperators:NO]];
			[mixpanel.people set:@{@"$email"		: [[HONAppDelegate infoForUser] objectForKey:@"email"],
								   @"$created"		: [[HONAppDelegate infoForUser] objectForKey:@"added"],
								   @"id"			: [[HONAppDelegate infoForUser] objectForKey:@"id"],
								   @"username"		: [[HONAppDelegate infoForUser] objectForKey:@"username"],
								   @"deactivated"	: [[NSUserDefaults standardUserDefaults] objectForKey:@"is_deactivated"]}];
			
			[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"passed_registration"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			[[HONAPICaller sharedInstance] retrieveFollowersForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result){
				[HONAppDelegate writeFollowingList:(NSArray *)result];
			}];
			
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:nil];
				
				if ([HONAppDelegate switchEnabledForKey:@"firstrun_subscribe"])
					[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUGGESTED_FOLLOWING" object:nil];
				
				else
					[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_HOME_TUTORIAL" object:nil];
			}];
			
		} else {
			int errorCode = [[(NSDictionary *)result objectForKey:@"result"] intValue];
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			
			[_progressHUD setYOffset:-80.0];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = (errorCode == 1) ? @"Username taken!" : (errorCode == 2) ? @"Email taken!" : (errorCode == 3) ? @"Username & email taken!" : @"Unknown Error";
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
			if (errorCode == 2)
				[_emailTextField becomeFirstResponder];
			
			else
				[_usernameTextField becomeFirstResponder];
		}
	}];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
	
	_headerView = [[HONHeaderView alloc] initAsModalWithTitle:@"Register" hasTranslucency:NO];
	[self.view addSubview:_headerView];
	
	_usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_usernameButton.frame = CGRectMake(0.0, 64.0, 320.0, 64.0);
	[_usernameButton setBackgroundImage:[UIImage imageNamed:@"registerSelected"] forState:UIControlStateSelected];
	[_usernameButton addTarget:self action:@selector(_goUsername) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_usernameButton];
	
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
	_usernameTextField.placeholder = @"Enter username";
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
	//[_emailTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_emailTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_emailTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_emailTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_emailTextField setReturnKeyType:UIReturnKeyDone];
	[_emailTextField setTextColor:[UIColor blackColor]];
	[_emailTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_emailTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_emailTextField.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18];
	_emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
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
	_birthdayLabel.textColor = [HONAppDelegate honPlaceholderTextColor];
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
	
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
	[dateComponents setYear:-[HONAppDelegate minimumAge]];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	
	_datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height, 320.0, 216.0)];
	_datePicker.date = (![[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"] || [[[HONAppDelegate infoForUser] objectForKey:@"age"] isEqualToString:@"0000-00-00 00:00:00"]) ? [dateFormat dateFromString:@"1970-01-01"] : [dateFormat dateFromString:[[[[HONAppDelegate infoForUser] objectForKey:@"age"]componentsSeparatedByString:@" "] objectAtIndex:0]];
	_datePicker.datePickerMode = UIDatePickerModeDate;
	_datePicker.minimumDate = [dateFormat dateFromString:@"1930-01-01"];
	_datePicker.maximumDate = [calendar dateByAddingComponents:dateComponents toDate:[[NSDate alloc] init] options:0];
	[_datePicker addTarget:self action:@selector(_pickerValueChanged) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:_datePicker];
	
	_birthday = [dateFormat stringFromDate:_datePicker.date];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = ([HONAppDelegate isRetina4Inch]) ? CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 269.0, 320.0, 53.0) : CGRectMake(254.0, 28.0, 59.0, 24.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:([HONAppDelegate isRetina4Inch]) ? @"submitUsernameButton_nonActive" : @"smallSubmit_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:([HONAppDelegate isRetina4Inch]) ? @"submitUsernameButton_Active" : @"smallSubmit_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:submitButton];
	
	_splashHolderView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_splashHolderView.alpha = 0.0;
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	_rotatingTintView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_rotatingTintView.backgroundColor = SPLASH_BLUE_TINT_COLOR;
	[_splashHolderView addSubview:_rotatingTintView];
	
	if (_tintTimer != nil) {
		[_tintTimer invalidate];
		_tintTimer = nil;
	}
	
	_tintTimer = [NSTimer scheduledTimerWithTimeInterval:SPLASH_TINT_TIMER_DURATION target:self selector:@selector(_nextSplashTint) userInfo:nil repeats:YES];
	
	UIImageView *splashTxtImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	[_splashHolderView addSubview:splashTxtImageView];
	
	if ([HONAppDelegate switchEnabledForKey:@"splash_camera"]) {
		void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			splashTxtImageView.image = image;
		};
		
		void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			splashTxtImageView.image = [UIImage imageNamed:[NSString stringWithFormat:([HONAppDelegate isRetina4Inch]) ? @"splashText_%@-568h@2x" : @"splashText_%@", [[HONAppDelegate brandedAppName] lowercaseString]]];
		};
		
		[splashTxtImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_splashImageURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
								  placeholderImage:nil
										   success:successBlock
										   failure:failureBlock];
		
		
		UIButton *signupButton = [UIButton buttonWithType:UIButtonTypeCustom];
		signupButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - (190.0 - (((int)![HONAppDelegate isRetina4Inch]) * 19.0)), 320.0, 64.0);
		[signupButton setBackgroundImage:[UIImage imageNamed:@"registerButton_nonActive"] forState:UIControlStateNormal];
		[signupButton setBackgroundImage:[UIImage imageNamed:@"registerButton_Active"] forState:UIControlStateHighlighted];
		[signupButton addTarget:self action:@selector(_goCloseSplash) forControlEvents:UIControlEventTouchUpInside];
		[_splashHolderView addSubview:signupButton];

		//>>
//		UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		loginButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - (103.0 - (((int)![HONAppDelegate isRetina4Inch]) * 18.0)), 320.0, 49.0);
//		[loginButton setBackgroundImage:[UIImage imageNamed:@"loginButton_nonActive"] forState:UIControlStateNormal];
//		[loginButton setBackgroundImage:[UIImage imageNamed:@"loginButton_Active"] forState:UIControlStateHighlighted];
//		[loginButton addTarget:self action:@selector(_goLogin) forControlEvents:UIControlEventTouchUpInside];
//		[_splashHolderView addSubview:loginButton];
		
		if (_isFirstAppearance) {
			_isFirstAppearance = NO;
			
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
				UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
				imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
				imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
				imagePickerController.delegate = nil;
				imagePickerController.showsCameraControls = NO;
				imagePickerController.cameraViewTransform = CGAffineTransformScale(imagePickerController.cameraViewTransform, ([HONAppDelegate isRetina4Inch]) ? 1.65f : 1.0f, ([HONAppDelegate isRetina4Inch]) ? 1.65f : 1.0f);
				imagePickerController.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
				
				imagePickerController.cameraOverlayView = _splashHolderView;
				self.splashImagePickerController = imagePickerController;
				
				[self presentViewController:self.splashImagePickerController animated:NO completion:^(void) {
					[UIView animateWithDuration:0.33 delay:0.125 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
						_splashHolderView.alpha = 1.0;
					} completion:^(BOOL finished) {
					}];
				}];
				
			} else {
				[self.view addSubview:_splashHolderView];
				
				[UIView animateWithDuration:0.33 animations:^(void) {
					_splashHolderView.alpha = 1.0;
				} completion:^(BOOL finished) {
				}];
				
#if __DEV_BUILD__ == 1
				UIButton *easterEggButton = [UIButton buttonWithType:UIButtonTypeCustom];
				easterEggButton.frame = CGRectMake(154.0, 16.0, 16.0, 8.0);
				easterEggButton.backgroundColor = [HONAppDelegate honDebugColorByName:@"fuschia" atOpacity:0.875];
				[easterEggButton addTarget:self action:@selector(_goFillForm) forControlEvents:UIControlEventTouchDown];
				[_splashHolderView addSubview:easterEggButton];
#endif

			}
		}
	
	} else {
		[self.view addSubview:_splashHolderView];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_splashHolderView.alpha = 1.0;
		} completion:^(BOOL finished) {}];
	}
}


#pragma mark - Navigation
- (void)_goFillForm {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	
	_usernameTextField.text = @"snap";
	_emailTextField.text = @"snap@snap.com";
	_datePicker.date = [dateFormat dateFromString:@"1996-07-10"];
	
	_birthdayLabel.text = [dateFormat stringFromDate:_datePicker.date];
	[self _goCloseSplash];
}


- (void)_goCloseSplash {
	[[Mixpanel sharedInstance] track:@"Register - Close Splash"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if (_tintTimer != nil) {
		[_tintTimer invalidate];
		_tintTimer = nil;
	}
	
	_tintIndex = 0;
	[self.splashImagePickerController dismissViewControllerAnimated:NO completion:^(void) {}];
	_filename = @"";
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"] == nil) {
		[[HONAPICaller sharedInstance] recreateUserWithCompletion:^(NSObject *result){
			if ([(NSDictionary *)result objectForKey:@"id"] != [NSNull null] || [(NSDictionary *)result count] > 0) {
				[HONAppDelegate writeUserInfo:(NSDictionary *)result];
				[HONImagingDepictor writeImageFromWeb:[(NSDictionary *)result objectForKey:@"avatar_url"] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
			}
		}];
	}
	
	[_usernameTextField becomeFirstResponder];
	[_usernameButton setSelected:YES];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelay:0.33];
	_splashHolderView.frame = CGRectOffset(_splashHolderView.frame, 0.0, -[UIScreen mainScreen].bounds.size.height);
	[UIView commitAnimations];
}

- (void)_goLogin {
	[[Mixpanel sharedInstance] track:@"Register - Login"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] != nil) {
		if ([MFMailComposeViewController canSendMail]) {
			_mailComposeViewController = [[MFMailComposeViewController alloc] init];
			_mailComposeViewController.mailComposeDelegate = self;
			[_mailComposeViewController setToRecipients:[NSArray arrayWithObject:@"support@selfieclubapp.com"]];
			[_mailComposeViewController setSubject:@"Selfieclub - Help! I need to log back in"];
			[_mailComposeViewController setMessageBody:[NSString stringWithFormat:@"My name is %@ and I need to log back into my account. Please help, my email is %@. Thanks!", [[HONAppDelegate infoForUser] objectForKey:@"username"], [[HONAppDelegate infoForUser] objectForKey:@"email"]] isHTML:NO];
			
			if (self.splashImagePickerController != nil)
				[self.splashImagePickerController presentViewController:_mailComposeViewController animated:YES completion:^(void) {}];
			
			else
				[self presentViewController:_mailComposeViewController animated:YES completion:^(void) {}];
			
			[_rotatingTintView.layer removeAllAnimations];
			if (_tintTimer != nil) {
				[_tintTimer invalidate];
				_tintTimer = nil;
			}
		
		} else {
			[[[UIAlertView alloc] initWithTitle:@"Email Error"
										message:@"Cannot send email from this device!"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
		}
		
	} else {
		[[[UIAlertView alloc] initWithTitle:@"This device has never been logged in!"
									message:@""
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	}
}

- (void)_goCamera {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Register - Camera %@Available", ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) ? @"" : @"Not "]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
	imagePickerController.view.backgroundColor = [UIColor whiteColor];
	imagePickerController.sourceType = ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
	imagePickerController.delegate = self;
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		imagePickerController.showsCameraControls = NO;
		imagePickerController.cameraViewTransform = CGAffineTransformScale(imagePickerController.cameraViewTransform, ([HONAppDelegate isRetina4Inch]) ? 1.65f : 1.0f, ([HONAppDelegate isRetina4Inch]) ? 1.65f : 1.0f);
		imagePickerController.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		
		_profileCameraOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height)];
		_profileCameraOverlayView.alpha = 0.0;
		
		imagePickerController.cameraOverlayView = _profileCameraOverlayView;
		
		[UIView animateWithDuration:0.33 delay:0.125 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_profileCameraOverlayView.alpha = 1.0;
		} completion:^(BOOL finished) {}];
		
		_tintIndex = 0;
		_tintedMatteView = [[UIView alloc] initWithFrame:_profileCameraOverlayView.frame];
		_tintedMatteView.backgroundColor = [[HONAppDelegate colorsForOverlayTints] objectAtIndex:_tintIndex];
		[_profileCameraOverlayView addSubview:_tintedMatteView];
		
		UIView *headerBGView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)];
		headerBGView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
		[_profileCameraOverlayView addSubview:headerBGView];
		
		UIButton *flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		flipButton.frame = CGRectMake(3.0, 3.0, 44.0, 44.0);
		[flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_nonActive"] forState:UIControlStateNormal];
		[flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_Active"] forState:UIControlStateHighlighted];
		[flipButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
		[_profileCameraOverlayView addSubview:flipButton];
		
		UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		skipButton.frame = CGRectMake(228.0, 3.0, 84.0, 44.0);
		[skipButton setBackgroundImage:[UIImage imageNamed:@"skipThis_nonActive"] forState:UIControlStateNormal];
		[skipButton setBackgroundImage:[UIImage imageNamed:@"skipThis_Active"] forState:UIControlStateHighlighted];
		[skipButton addTarget:self action:@selector(_goSkip) forControlEvents:UIControlEventTouchUpInside];
		[_profileCameraOverlayView addSubview:skipButton];
		
		UIView *gutterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 141.0, 320.0, 141.0)];
		gutterView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
		[_profileCameraOverlayView addSubview:gutterView];
		
		_tutorialImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_1stRun"]];
		_tutorialImageView.frame = CGRectOffset(_tutorialImageView.frame, 0.0, [UIScreen mainScreen].bounds.size.height - 185.0);
		_tutorialImageView.alpha = 0.0;
		[_profileCameraOverlayView addSubview:_tutorialImageView];
		
		_changeTintButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_changeTintButton.frame = CGRectMake(-5.0, [UIScreen mainScreen].bounds.size.height - 60.0, 64.0, 64.0);
		[_changeTintButton setBackgroundImage:[UIImage imageNamed:@"filterIcon_nonActive"] forState:UIControlStateNormal];
		[_changeTintButton setBackgroundImage:[UIImage imageNamed:@"filterIcon_Active"] forState:UIControlStateHighlighted];
		[_changeTintButton addTarget:self action:@selector(_goChangeTint) forControlEvents:UIControlEventTouchUpInside];
		[_profileCameraOverlayView addSubview:_changeTintButton];
		
		UIButton *takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
		takePhotoButton.frame = CGRectMake(113.0, [UIScreen mainScreen].bounds.size.height - 118.0, 94.0, 94.0);
		[takePhotoButton setBackgroundImage:[UIImage imageNamed:@"profileCameraButton_nonActive"] forState:UIControlStateNormal];
		[takePhotoButton setBackgroundImage:[UIImage imageNamed:@"profileCameraButton_Active"] forState:UIControlStateHighlighted];
		[takePhotoButton addTarget:self action:@selector(_goTakePhoto) forControlEvents:UIControlEventTouchUpInside];
		takePhotoButton.alpha = 0.0;
		[_profileCameraOverlayView addSubview:takePhotoButton];
		
		UIButton *cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraRollButton.frame = CGRectMake(249.0, [UIScreen mainScreen].bounds.size.height - 42.0, 64.0, 44.0);
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive"] forState:UIControlStateNormal];
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active"] forState:UIControlStateHighlighted];
		[cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
		[_profileCameraOverlayView addSubview:cameraRollButton];
		
		
//		UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		cancelButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height + 300.0, 106.0, 24.0);
//		[cancelButton setBackgroundImage:[UIImage imageNamed:@"skipThis_nonActive"] forState:UIControlStateNormal];
//		[cancelButton setBackgroundImage:[UIImage imageNamed:@"skipThis_Active"] forState:UIControlStateHighlighted];
//		[cancelButton addTarget:self action:@selector(_goRetake) forControlEvents:UIControlEventTouchUpInside];
//		[_profileCameraOverlayView addSubview:cancelButton];
//
//		UIButton *retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		retakeButton.frame = CGRectMake(106.0, [UIScreen mainScreen].bounds.size.height + 300.0, 106.0, 24.0);
//		[retakeButton setBackgroundImage:[UIImage imageNamed:@"skipThis_nonActive"] forState:UIControlStateNormal];
//		[retakeButton setBackgroundImage:[UIImage imageNamed:@"skipThis_Active"] forState:UIControlStateHighlighted];
//		[retakeButton addTarget:self action:@selector(_goRetake) forControlEvents:UIControlEventTouchUpInside];
//		[_profileCameraOverlayView addSubview:retakeButton];
//		
//		UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		acceptButton.frame = CGRectMake(212.0, [UIScreen mainScreen].bounds.size.height + 300.0, 106.0, 24.0);
//		[acceptButton setBackgroundImage:[UIImage imageNamed:@"skipThis_nonActive"] forState:UIControlStateNormal];
//		[acceptButton setBackgroundImage:[UIImage imageNamed:@"skipThis_Active"] forState:UIControlStateHighlighted];
//		[acceptButton addTarget:self action:@selector(_goAccept) forControlEvents:UIControlEventTouchUpInside];
//		[_profileCameraOverlayView addSubview:acceptButton];
			
		[UIView animateWithDuration:0.25 animations:^(void) {
			takePhotoButton.alpha = 1.0;
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.33 animations:^(void) {
				_tutorialImageView.alpha = 1.0;
			}];
		}];
	}
	
	self.profileImagePickerController = imagePickerController;
	[self presentViewController:self.profileImagePickerController animated:NO completion:^(void) {}];
}

- (void)_goFlipCamera {
	[[Mixpanel sharedInstance] track:@"Register - Switch Camera"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	if (self.profileImagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
		self.profileImagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
		self.profileImagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		
	} else {
		self.profileImagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
	}
}

- (void)_goCameraRoll {
	[[Mixpanel sharedInstance] track:@"Register - Camera Roll"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	self.profileImagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
	self.profileImagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)_goChangeTint {
	[[Mixpanel sharedInstance] track:@"Register - Change Tint Overlay"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	_tintIndex = ++_tintIndex % [[HONAppDelegate colorsForOverlayTints] count];
	
	[UIView beginAnimations:@"fade" context:nil];
	[UIView setAnimationDuration:0.33];
	[_tintedMatteView setBackgroundColor:[[HONAppDelegate colorsForOverlayTints] objectAtIndex:_tintIndex]];
	[UIView commitAnimations];
}

- (void)_goSkip {
	[[Mixpanel sharedInstance] track:@"Register - Skip Photo"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_filename = @"";
	[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"skipped_selfie"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self _finalizeUser];
}

- (void)_goTakePhoto {
	[[Mixpanel sharedInstance] track:@"Register - Take Photo"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Loading…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	_irisView = [[UIView alloc] initWithFrame:_profileCameraOverlayView.frame];
	_irisView.backgroundColor = [UIColor blackColor];
	_irisView.alpha = 0.0;
	[_profileCameraOverlayView addSubview:_irisView];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_irisView.alpha = 1.0;
	}];
	
	[self.profileImagePickerController performSelector:@selector(takePicture) withObject:nil afterDelay:0.25];
	
	[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"skipped_selfie"];
	[[NSUserDefaults standardUserDefaults] synchronize];
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
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_datePicker.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 216.0, 320.0, 216.0);
	} completion:^(BOOL finished) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterLongStyle];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		_birthdayLabel.text = [dateFormatter stringFromDate:_datePicker.date];
	}];
}

- (void)_goSubmit {
	[[Mixpanel sharedInstance] track:@"Register - Submit Username & Email"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];

	
	HONRegisterErrorType registerErrorType = ((int)([_usernameTextField.text length] > 0) * 1) + ((int)([HONAppDelegate isValidEmail:_emailTextField.text]) * 2) + ((int)(![_birthdayLabel.text isEqualToString:@"What is your birthday?"]) * 4);
	if (registerErrorType == HONRegisterErrorTypeUsernameEmailBirthday) {
		[[[UIAlertView alloc] initWithTitle:@"No Username, Email or Birthday!"
									message:@"You need to enter a username, email & birthday address to start snapping"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		[_usernameTextField becomeFirstResponder];
	 
	} else if (registerErrorType == HONRegisterErrorTypeEmailBirthday) {
		[[[UIAlertView alloc] initWithTitle:@"No Email & Birthday!"
									message:@"You need to enter an email address & birthday to start snapping"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		[_usernameTextField becomeFirstResponder];
	
	} else if (registerErrorType == HONRegisterErrorTypeUsernameBirthday) {
		[[[UIAlertView alloc] initWithTitle:@"No Username & Birthday!"
									message:@"You need to enter a username and birthday to start snapping"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		[_emailTextField becomeFirstResponder];
	
	} else if (registerErrorType == HONRegisterErrorTypeBirthday) {
		[[[UIAlertView alloc] initWithTitle:@"No Birthday!"
									message:@"You need to a birthday to keep the communty safe."
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		[self _goPicker];
	
	} else if (registerErrorType == HONRegisterErrorTypeUsernameEmail) {
		[[[UIAlertView alloc] initWithTitle:@"No Username & Email!"
									message:@"You need to enter a username and email address to start snapping"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		[_usernameTextField becomeFirstResponder];
	
	} else if (registerErrorType == HONRegisterErrorTypeEmail) {
		[[[UIAlertView alloc] initWithTitle:@"No email!"
									message:[NSString stringWithFormat:@"You need to enter a valid email address to use %@", [HONAppDelegate brandedAppName]]
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		[_emailTextField becomeFirstResponder];
	
	} else if (registerErrorType == HONRegisterErrorTypeUsername) {
		[[[UIAlertView alloc] initWithTitle:@"No Username!"
									message:@"You need to enter a username to start snapping"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		[_usernameTextField becomeFirstResponder];
	
	} else {
		_username = _usernameTextField.text;
		_email = _emailTextField.text;
		
		[self _checkUsername];
	}
}


#pragma mark - Notifications
- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
	//	NSLog(@"UITextFieldTextDidChangeNotification:[%@]", [notification object]);
	
	NSArray *tdls = @[@"cc", @"net", @"mil", @"jp", @"fk", @"sm", @"biz"];
	NSString *emailFiller = @"";
	
	
//	BOOL _isHeads = ((BOOL)roundf(((float)rand() / RAND_MAX)));
	for (int i=0; i<((arc4random() % 8) + 3); i++)
		emailFiller = [emailFiller stringByAppendingString:[NSString stringWithFormat:@"%c", (arc4random() % 26 + 65 + (((BOOL)roundf(((float)rand() / RAND_MAX))) * 32))]];
	emailFiller = [emailFiller stringByAppendingString:@"@"];
	
	for (int i=0; i<((arc4random() % 8) + 3); i++)
		emailFiller = [emailFiller stringByAppendingString:[NSString stringWithFormat:@"%c", (arc4random() % 26 + 65 + (((BOOL)roundf(((float)rand() / RAND_MAX))) * 32))]];
	emailFiller = [[emailFiller stringByAppendingString:@"."] stringByAppendingString:[tdls objectAtIndex:(arc4random() % [tdls count])]];
	
#if __APPSTORE_BUILD__ == 0
	if ([_emailTextField.text isEqualToString:@"¡"])
		_emailTextField.text = emailFiller;//@"dfsfhsdfo@fssf.com";
#endif
}


#pragma mark - UI Presentation
- (void)_pickerValueChanged {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	_birthdayLabel.text = [dateFormatter stringFromDate:_datePicker.date];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	_birthday = [dateFormat stringFromDate:_datePicker.date];
}

- (void)_nextSplashTint {
	_tintIndex = ++_tintIndex % 3;
	
	[UIView beginAnimations:@"fade" context:nil];
	[UIView setAnimationDuration:SPLASH_TINT_FADE_DURATION];
	[_rotatingTintView setBackgroundColor:(_tintIndex == 0) ? SPLASH_BLUE_TINT_COLOR : (_tintIndex == 1) ? SPLASH_MAGENTA_TINT_COLOR : SPLASH_GREEN_TINT_COLOR];
	[UIView commitAnimations];
}


#pragma mark - NavigationController Delegates
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	navigationController.navigationBar.barStyle = UIBarStyleDefault;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}


#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	NSLog(@"imagePickerController:didFinishPickingMediaWithInfo:[%f]", [HONAppDelegate minSnapLuminosity]);
	
	UIImage *processedImage = [HONImagingDepictor prepForUploading:[info objectForKey:UIImagePickerControllerOriginalImage]];
	
	NSLog(@"PROCESSED IMAGE:[%@]", NSStringFromCGSize(processedImage.size));
	UIView *canvasView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, processedImage.size.width, processedImage.size.height)];
	[canvasView addSubview:[[UIImageView alloc] initWithImage:processedImage]];
	
	UIView *overlayTintView = [[UIView alloc] initWithFrame:canvasView.frame];
	overlayTintView.backgroundColor = [[HONAppDelegate colorsForOverlayTints] objectAtIndex:_tintIndex];
	[canvasView addSubview:overlayTintView];
	
	processedImage = [HONImagingDepictor createImageFromView:canvasView];
	
	[self _uploadPhotos:processedImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	NSLog(@"imagePickerControllerDidCancel");
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		float scale = ([HONAppDelegate isRetina4Inch]) ? 1.55f : 1.25f;
		
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
		picker.showsCameraControls = NO;
		picker.cameraViewTransform = CGAffineTransformMakeTranslation(24.0, 90.0);
		picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, scale, scale);
		picker.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		
		_profileCameraOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height)];
		_profileCameraOverlayView.alpha = 0.0;
		
	} else
		[self _finalizeUser];
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
	} completion:^(BOOL finished) {}];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_textFieldTextDidChangeChange:)
												 name:UITextFieldTextDidChangeNotification
											   object:textField];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	return (YES);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
		
	_username = _usernameTextField.text;
	_email = _emailTextField.text;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_datePicker.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 216.0, 320.0, 216.0);
	} completion:^(BOOL finished) {}];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UITextFieldTextDidChangeNotification"
												  object:textField];
}

- (void)_onTextEditingDidEnd:(id)sender {
	_username = _usernameTextField.text;
	_email = _emailTextField.text;
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
}


#pragma mark - AlertView Deleagtes
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		_profileCameraOverlayView.alpha = 1.0;
		[_irisView removeFromSuperview];
		_irisView = nil;
	}
	
	else if (alertView.tag == 1) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Register - Skip Photo %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if (buttonIndex == 1) {
			_filename = @"";
			[self.profileImagePickerController dismissViewControllerAnimated:NO completion:^(void) {}];
			
			_splashHolderView.frame = CGRectOffset(_splashHolderView.frame, 0.0, [UIScreen mainScreen].bounds.size.height);
			
			[_usernameTextField becomeFirstResponder];
			[_usernameButton setSelected:YES];
		}
	
	} else if (alertView.tag == 2) {
		[self _checkUsername];
	}
}


#pragma mark - MailCompose Delegates
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	
	NSString *mpAction = @"";
	switch (result) {
		case MFMailComposeResultCancelled:
			mpAction = @"Canceled";
			break;
			
		case MFMailComposeResultFailed:
			mpAction = @"Failed";
			break;
			
		case MFMailComposeResultSaved:
			mpAction = @"Saved";
			break;
			
		case MFMailComposeResultSent:
			mpAction = @"Sent";
			break;
			
		default:
			mpAction = @"Not Sent";
			break;
	}
	
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Register - Login Message %@", mpAction]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[_mailComposeViewController dismissViewControllerAnimated:YES completion:^(void) {
	}];
}

@end
